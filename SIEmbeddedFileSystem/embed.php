<?php
error_reporting(E_ALL);

function e($str){echo $str;}
function p($obj){e('<pre>');print_r($obj);e('</pre>'."\n");}
function glob_recursive($dir, $filter = '*')
{
	$return = glob($dir . '/' . $filter);
    $items = glob($dir . '/*');

    for ($i = 0; $i < count($items); $i++) {
        if (is_dir($items[$i])) {
            $files = glob_recursive($items[$i], $filter);
            $return = array_merge($return, $files);
        }
    }

    return $return;
}

// $_ENV['SRCROOT'] = '/Users/shauninman/Desktop/Ejecta/ejecta-1.3';

$project 	= $_ENV['SRCROOT'];
$app 		= $project.'/App';

$files = glob_recursive($app, '*.js');

$c = '';
$path_to_var = array();

// do all App files first
foreach ($files as $file)
{
	$path = str_replace("{$app}/", '', $file);
	
	if ($path == 'Desktop/ejecta.js' || $path == 'Desktop/touche.js') continue; // skip Ejecta Desktop Polyfill
	
	$output = array();
	exec("cd {$app}; xxd -i {$path}", $output);
	
	if (preg_match('/unsigned char ([^\[]+)/', $output[0], $m))
	{
		$var = $m[1];
		$path_to_var[$path] = $var;
		$c .= join("\n",$output)."\n";
	}
}

// now manually do files outside of App (only one currently)
$output = array();
exec("cd {$project}/Source/Ejecta; xxd -i Ejecta.js", $output);
if (preg_match('/unsigned char ([^\[]+)/', $output[0], $m))
{
	$var = $m[1];
	$path_to_var['../Ejecta.js'] = $var;
	$c .= join("\n",$output)."\n";
}


$m = '';
foreach ($path_to_var as $path=>$var)
{
	$m .= <<<OBJC
		data		= [NSData dataWithBytes:{$var} length:{$var}_len];
		jsString	= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		[files setObject:jsString forKey:@"{$path}"];
		

OBJC;
}

$m = <<<OBJC
//
//  SIEmbeddedFileSystem.m
//  SIEmbeddedFileSystem
//
//  Created by Shaun Inman on 6/1/13.
//  Copyright (c) 2013 Shaun Inman. All rights reserved.
//

#import "SIEmbeddedFileSystem.h"

{$c}

@implementation SIEmbeddedFileSystem

-(id)init
{
	if (self = [super init])
	{
		files = [[NSMutableDictionary alloc] init];
		NSData *data;
		NSString *jsString;

{$m}
	}
	return self;
}

+(SIEmbeddedFileSystem *)sharedInstance
{
    static SIEmbeddedFileSystem *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SIEmbeddedFileSystem alloc] init];
    });
    return sharedInstance;
}

-(NSString *)stringWithContentsOfFile:(NSString *)path
{
	return [files objectForKey:path];
}

@end

OBJC;

$efs = 'SIEmbeddedFileSystem/SIEmbeddedFileSystem.m';
file_put_contents($efs, $m);
touch($efs, time()+5); // force Xcode to notice changes