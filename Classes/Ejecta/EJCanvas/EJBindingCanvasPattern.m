//
//  EJBindingCanvasPattern.m
//  Ejecta
//
//  Created by James Cash on 31-10-12.
//
//

#import "EJBindingCanvasPattern.h"

@interface EJBindingCanvasPattern ()
- (void)determineRepetitionType;
@end

@implementation EJBindingCanvasPattern

@synthesize texture;
@synthesize repetitionType;

- (id)initWithContext:(JSContextRef)ctxp object:(JSObjectRef)obj imageData:(EJBindingImage *)img repetition:(NSString *)repetitionp
{
	if (self = [super initWithContext:ctxp object:obj argc:0 argv:NULL]) {
		texture = [[EJTexture alloc] initWithPath:[[EJApp instance] pathForResource:img.path]];
		repetition = repetitionp;
		[repetition retain];
		[self determineRepetitionType];
	}
	return self;
}

- (void)dealloc
{
	[texture release];
	[repetition release];
	[super dealloc];
}

- (void)determineRepetitionType
{
	if ([repetition isEqualToString:@"repeat-x"]) {
		repetitionType = REPEAT_X;
	} else if ([repetition isEqualToString:@"repeat-y"]) {
		repetitionType = REPEAT_Y;
	} else if ([repetition isEqualToString:@"no-repeat"]) {
		repetitionType = REPEAT_NONE;
	} else {
		repetitionType = REPEAT;
	}
}

@end
