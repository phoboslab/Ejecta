//
//  EJBindingCanvasPattern.h
//  Ejecta
//
//  Created by James Cash on 31-10-12.
//
//

#import "EJBindingBase.h"
#import "EJBindingImage.h"
#import "EJTexture.h"

typedef enum {
	REPEAT,
	REPEAT_X,
	REPEAT_Y,
	REPEAT_NONE
} EJCanvasPatternRepetitionType;

@interface EJBindingCanvasPattern : EJBindingBase {
	EJTexture * texture;
	NSString *repetition;
	EJCanvasPatternRepetitionType repetitionType;
}

- (id)initWithContext:(JSContextRef)ctxp object:(JSObjectRef)obj imageData:(EJBindingImage*)img repetition:(NSString*)repetition;

@property (nonatomic,readonly) EJTexture * texture;
@property (nonatomic,readonly) EJCanvasPatternRepetitionType repetitionType;

@end
