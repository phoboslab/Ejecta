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


// $_ENV['BUILT_PRODUCTS_DIR'] = '/long/path/to/build';
// $_ENV['UNLOCALIZED_RESOURCES_FOLDER_PATH'] = 'Ejecta.app';
// $_ENV['SRCROOT'] = '/Users/shauninman/Desktop/Ejecta/ejecta-1.3';

$resources = $_ENV['BUILT_PRODUCTS_DIR'].'/'.$_ENV['UNLOCALIZED_RESOURCES_FOLDER_PATH'];
$project 	= $_ENV['SRCROOT'];
$app 		= $project.'/App';

$all = glob_recursive($app);
$files = array();
$dirs	= array($app);

// filter out javascript
foreach ($all as $file)
{
	if (preg_match('/\.(js)$/', $file)) continue; // skip JavaScript files
	if ($file == $app.'/index.html') continue; // skip Ejecta Desktop Polyfill
	
	if (is_dir($file)) {
		$dirs[] = $file;
	}
	else
	{
		$files[] = $file;
	}
}

// create directories, skipping empty ones
foreach($dirs as $dir) {
	$found = false;
	foreach($files as $file)
	{
		if (preg_match('#^'.preg_quote($dir).'#', $file)) {
			$found = true;
			break;
		}
	}
	
	if (!$found) continue;
	
	$name = str_replace("{$app}/", '', $dir);
	if ($dir == $app) $path = $resources.'/App';
	else $path = $resources.'/App/'.$name;
	if (!is_dir($path)) mkdir($path);
}

// now copy over files
foreach($files as $file)
{
	$name = str_replace("{$app}/", '', $file);
	$path = $resources.'/App/'.$name;
	copy($file, $path);
}