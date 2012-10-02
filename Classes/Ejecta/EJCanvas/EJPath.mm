#import "EJPath.h"
#import "EJCanvasContext.h"

#include <vector>

// We're using the C++ std::vector here to store our points. Boxing and unboxing
// so many EJVectors to NSValue types seemed wasteful.
typedef std::vector<EJVector2> subpath_t;
typedef std::vector<subpath_t> path_t;

@interface EJPath() {
	subpath_t currentPath;
	path_t paths;
}
@end


@implementation EJPath

@synthesize transform;

- (id)init {
	self = [super init];
	if(self) {
		transform = CGAffineTransformIdentity;
	}
	return self;
}

- (void)dealloc {
	if( vertexBuffer ) {
		free(vertexBuffer);
	}
	[super dealloc];
}

- (void)reset {
	longestSubpath = 0;
	paths.clear();
	currentPath.clear();
	
	currentPos = EJVector2Make( 0, 0 );
	startPos = EJVector2Make( 0, 0 );
}

- (void)close {
	if( currentPos.x != startPos.x || currentPos.y != startPos.y ) {
		currentPath.push_back(startPos);
		currentPos = startPos;
	}
	[self endSubPath];
}

- (void)endSubPath {
	if( currentPath.size() > 1 ) {
		paths.push_back(currentPath);
		longestSubpath = MAX( longestSubpath, currentPath.size() );
		
		currentPath.clear();
		startPos = currentPos;
	}
}

- (void)moveToX:(float)x y:(float)y {
	[self endSubPath];
	currentPos = startPos = EJVector2ApplyTransform( EJVector2Make( x, y ), transform);
	currentPath.push_back(currentPos);
}

- (void)lineToX:(float)x y:(float)y {
	currentPos = EJVector2ApplyTransform( EJVector2Make(x, y), transform);
	currentPath.push_back(currentPos);
}

- (void)bezierCurveToCpx1:(float)cpx1 cpy1:(float)cpy1 cpx2:(float)cpx2 cpy2:(float)cpy2 x:(float)x y:(float)y scale:(float)scale {
	distanceTolerance = EJ_PATH_DISTANCE_EPSILON / scale;
	distanceTolerance *= distanceTolerance;
	
	EJVector2 cp1 = EJVector2ApplyTransform(EJVector2Make(cpx1, cpy2), transform);
	EJVector2 cp2 = EJVector2ApplyTransform(EJVector2Make(cpx2, cpy2), transform);
	EJVector2 p = EJVector2ApplyTransform(EJVector2Make(x, y), transform);
	
	[self recursiveBezierX1:currentPos.x y1:currentPos.y x2:cp1.x y2:cp1.y x3:cp2.x y3:cp2.y x4:p.x y4:p.y level:0];
	currentPos = p;
	currentPath.push_back(currentPos);
}

- (void)recursiveBezierX1:(float)x1 y1:(float)y1
					   x2:(float)x2 y2:(float)y2
					   x3:(float)x3 y3:(float)y3
					   x4:(float)x4 y4:(float)y4
					level:(int)level
{
	// Based on http://www.antigrain.com/research/adaptive_bezier/index.html
	
	// Calculate all the mid-points of the line segments
	float x12   = (x1 + x2) / 2;
	float y12   = (y1 + y2) / 2;
	float x23   = (x2 + x3) / 2;
	float y23   = (y2 + y3) / 2;
	float x34   = (x3 + x4) / 2;
	float y34   = (y3 + y4) / 2;
	float x123  = (x12 + x23) / 2;
	float y123  = (y12 + y23) / 2;
	float x234  = (x23 + x34) / 2;
	float y234  = (y23 + y34) / 2;
	float x1234 = (x123 + x234) / 2;
	float y1234 = (y123 + y234) / 2;
	
	if( level > 0 ) {
		// Enforce subdivision first time
		// Try to approximate the full cubic curve by a single straight line
		float dx = x4-x1;
		float dy = y4-y1;
		
		float d2 = fabsf(((x2 - x4) * dy - (y2 - y4) * dx));
		float d3 = fabsf(((x3 - x4) * dy - (y3 - y4) * dx));
		
		if( d2 > EJ_PATH_COLLINEARITY_EPSILON && d3 > EJ_PATH_COLLINEARITY_EPSILON ) {
			// Regular care
			if((d2 + d3)*(d2 + d3) <= distanceTolerance * (dx*dx + dy*dy)) {
				// If the curvature doesn't exceed the distance_tolerance value
				// we tend to finish subdivisions.
				currentPath.push_back(EJVector2Make(x1234, y1234));
				return;
			}
		}
		else {
			if( d2 > EJ_PATH_COLLINEARITY_EPSILON ) {
				// p1,p3,p4 are collinear, p2 is considerable
				if( d2 * d2 <= distanceTolerance * (dx*dx + dy*dy) ) {
					currentPath.push_back(EJVector2Make(x1234, y1234));
					return;
				}
			}
			else if( d3 > EJ_PATH_COLLINEARITY_EPSILON ) {
				// p1,p2,p4 are collinear, p3 is considerable
				if( d3 * d3 <= distanceTolerance * (dx*dx + dy*dy) ) {
					currentPath.push_back(EJVector2Make(x1234, y1234));
					return;
				}
			}
			else {
				// Collinear case
				dx = x1234 - (x1 + x4) / 2;
				dy = y1234 - (y1 + y4) / 2;
				if( dx*dx + dy*dy <= distanceTolerance ) {
					currentPath.push_back(EJVector2Make(x1234, y1234));
					return;
				}
			}
		}
	}
	
	if( level <= EJ_PATH_RECURSION_LIMIT ) {
		// Continue subdivision
		[self recursiveBezierX1:x1 y1:y1 x2:x12 y2:y12 x3:x123 y3:y123 x4:x1234 y4:y1234 level:level + 1];
		[self recursiveBezierX1:x1234 y1:y1234 x2:x234 y2:y234 x3:x34 y3:y34 x4:x4 y4:y4 level:level + 1];
	}
}

- (void)quadraticCurveToCpx:(float)cpx cpy:(float)cpy x:(float)x y:(float)y scale:(float)scale {
	distanceTolerance = EJ_PATH_DISTANCE_EPSILON / scale;
	distanceTolerance *= distanceTolerance;
	
	EJVector2 cp = EJVector2ApplyTransform(EJVector2Make(cpx, cpy), transform);
	EJVector2 p = EJVector2ApplyTransform(EJVector2Make(x, y), transform);
	
	[self recursiveQuadraticX1:currentPos.x y1:currentPos.y x2:cp.x y2:cp.y x3:p.x y3:p.y level:0];
	currentPos = p;
	currentPath.push_back(currentPos);
}

- (void)recursiveQuadraticX1:(float)x1 y1:(float)y1
						  x2:(float)x2 y2:(float)y2
						  x3:(float)x3 y3:(float)y3
					   level:(int)level
{
	// Based on http://www.antigrain.com/research/adaptive_bezier/index.html
	
	// Calculate all the mid-points of the line segments
	float x12   = (x1 + x2) / 2;
	float y12   = (y1 + y2) / 2;
	float x23   = (x2 + x3) / 2;
	float y23   = (y2 + y3) / 2;
	float x123  = (x12 + x23) / 2;
	float y123  = (y12 + y23) / 2;
	
	float dx = x3-x1;
	float dy = y3-y1;
	float d = fabsf(((x2 - x3) * dy - (y2 - y3) * dx));
	
	if( d > EJ_PATH_COLLINEARITY_EPSILON ) {
		// Regular care
		if( d * d <= distanceTolerance * (dx*dx + dy*dy) ) {
			currentPath.push_back(EJVector2Make(x123, y123));
			return;
		}
	}
	else {
		// Collinear case
		dx = x123 - (x1 + x3) / 2;
		dy = y123 - (y1 + y3) / 2;
		if( dx*dx + dy*dy <= distanceTolerance ) {
			currentPath.push_back(EJVector2Make(x123, y123));
			return;
		}
	}
	
	if( level <= EJ_PATH_RECURSION_LIMIT ) {
		// Continue subdivision
		[self recursiveQuadraticX1:x1 y1:y1 x2:x12 y2:y12 x3:x123 y3:y123 level:level + 1];
		[self recursiveQuadraticX1:x123 y1:y123 x2:x23 y2:y23 x3:x3 y3:y3 level:level + 1];
	}
}

- (void)arcToX1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 radius:(float)radius {
	
	// Lifted from http://code.google.com/p/fxcanvas/
	// I have no idea what this code is doing, but it seems to work.
	
	// get untransformed currentPos
	EJVector2 cp = EJVector2ApplyTransform(EJVector2Make(x1, y1), CGAffineTransformInvert(transform));
	
	float a1 = cp.y - y1;
	float b1 = cp.x - x1;
	float a2 = y2   - y1;
	float b2 = x2   - x1;
	float mm = fabsf(a1 * b2 - b1 * a2);

	if( mm < 1.0e-8 || radius == 0 ) {
		[self lineToX:x1 y:y1];
	}
	else {
		float dd = a1 * a1 + b1 * b1;
		float cc = a2 * a2 + b2 * b2;
		float tt = a1 * a2 + b1 * b2;
		float k1 = radius * sqrtf(dd) / mm;
		float k2 = radius * sqrtf(cc) / mm;
		float j1 = k1 * tt / dd;
		float j2 = k2 * tt / cc;
		float cx = k1 * b2 + k2 * b1;
		float cy = k1 * a2 + k2 * a1;
		float px = b1 * (k2 + j1);
		float py = a1 * (k2 + j1);
		float qx = b2 * (k1 + j2);
		float qy = a2 * (k1 + j2);
		float startAngle = atan2f(py - cy, px - cx);
		float endAngle = atan2f(qy - cy, qx - cx);
		
		[self arcX:cx + x1 y:cy + y1 radius:radius startAngle:startAngle endAngle:endAngle antiClockwise:(b1 * a2 > b2 * a1)];
	}
}

- (void)arcX:(float)x y:(float)y
	radius:(float)radius
	startAngle:(float)startAngle endAngle:(float)endAngle
	antiClockwise:(BOOL)antiClockwise
{
	startAngle = fmodf(startAngle, 2 * M_PI);
    endAngle = fmodf(endAngle, 2 * M_PI);

	if( !antiClockwise && endAngle <= startAngle ) {
		endAngle += 2 * M_PI;
	}
	else if( antiClockwise && startAngle <= endAngle ) {
		startAngle += 2 * M_PI;
	}

    float span = antiClockwise
        ? (startAngle - endAngle) *-1
        : (endAngle - startAngle);
	
	int steps = ceil(fabsf(span) * (EJ_PATH_STEPS_FOR_CIRCLE / (2 * M_PI)) );
	float stepSize = span / (float)steps;
	
	float angle = startAngle;
	for( int i = 0; i <= steps; i++, angle += stepSize ) {
		currentPos = EJVector2ApplyTransform( EJVector2Make( x + cosf(angle) * radius, y + sinf(angle) * radius ), transform);
		currentPath.push_back( currentPos );
	}
}

- (void)drawPolygonsToContext:(EJCanvasContext *)context {
	[self endSubPath];
	if( longestSubpath < 3 ) { return; }
	
	[context setTexture:NULL];
	
	EJCanvasState * state = context.state;
	EJColorRGBA color = state->fillColor;
	color.rgba.a = (float)color.rgba.a * state->globalAlpha;
	
	
	// For potentially concave polygons (those with more than 3 unique vertices), we
	// need to draw to the context twice: first to create a stencil mask, and then again
	// to fill the created mask with the polygons color.
	// TODO: add a fast path for polygons that only have 3 vertices
	
	// Make sure the vertex buffer holds enough space for the longest subpath
	if( vertexBufferLength < longestSubpath ) {
		vertexBuffer = (EJVector2 *)realloc( vertexBuffer, sizeof(EJVector2) * longestSubpath );
		vertexBufferLength = longestSubpath;
	}
	
	[context flushBuffers];
	[context createStencilBufferOnce];
	
	
	// Enable drawing to the stencil buffer, disable drawing to the color buffer and
	// draw the polygons to the stencil buffer as a triangle fan.
	
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glDisable(GL_BLEND);
	glEnable(GL_STENCIL_TEST);
	glStencilMask(0x01);
	glStencilOp(GL_KEEP, GL_KEEP, GL_INVERT);
	glStencilFunc(GL_ALWAYS, 0, ~0);
	glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
	
	float minX = INFINITY, minY = INFINITY, maxX = -INFINITY, maxY = -INFINITY;
	for( path_t::iterator sp = paths.begin(); sp != paths.end(); ++sp ) {
		int vertexIndex = 0;
		for( subpath_t::iterator vertex = sp->begin(); vertex != sp->end(); ++vertex, ++vertexIndex ) {
			minX = MIN( minX, vertex->x );
			minY = MIN( minY, vertex->y );
			maxX = MAX( maxX, vertex->x );
			maxY = MAX( maxY, vertex->y );
			
			vertexBuffer[vertexIndex] = *vertex;
		}
		glVertexPointer(2, GL_FLOAT, sizeof(EJVector2), vertexBuffer);
		glDrawArrays(GL_TRIANGLE_FAN, 0, vertexIndex);
	}
	[context bindVertexBuffer];
	
	
	// Disable drawing to the stencil buffer, enable drawing to the color buffer and push a rect
	// with the correct size and color to the context.
	
	glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glEnable(GL_BLEND);
	glStencilFunc(GL_EQUAL, 0x01, 0x01);
    glStencilOp(GL_ZERO, GL_ZERO, GL_ZERO);
	[context pushRectX:minX y:minY w:maxX-minX h:maxY-minY tx:0 ty:0 tw:0 th:0 color:color withTransform:CGAffineTransformIdentity];
	[context flushBuffers];
	glDisable(GL_STENCIL_TEST);
}


- (void)drawLinesToContext:(EJCanvasContext *)context {
	[self endSubPath];
	
	EJCanvasState * state = context.state;
	
	// Find the width of the line as it is projected onto the screen.
	float projectedLineWidth = CGAffineTransformGetScale( state->transform ) * state->lineWidth;
	[context setLineTextureForWidth:projectedLineWidth];
	
	// Figure out if we need to add line caps and set the cap texture coord for square or round caps.
	// For thin lines we disable texturing and line caps.
	float width2 = state->lineWidth/2;
	BOOL addCaps = (projectedLineWidth > 2 && (state->lineCap == kEJLineCapRound || state->lineCap == kEJLineCapSquare));
	
	float capTexXCoord = (state->lineCap == kEJLineCapRound) ? 0.0f : 0.5f;
	EJVector2 capTex1 = { capTexXCoord, 0 };
	EJVector2 capTex2 = { capTexXCoord, 1 };
	
	EJVector2 midTex1 = { 0.5, 0 };
	EJVector2 midTex2 = { 0.5, 1 };
	
	
	// The actual miter limit is the product of the miterLimit and lineWidth properties.
	// For thin lines we skip computing the miter completely.
	BOOL addMiter = (projectedLineWidth >= 1 && state->lineJoin == kEJLineJoinMiter);
	float miterLimit = (state->miterLimit * state->lineWidth);
	
	EJColorRGBA color = state->strokeColor;
	color.rgba.a = (float)color.rgba.a * state->globalAlpha;
	
	
	// To draw the line correctly with transformations, we need to construct the line
	// vertices from the untransformed points and only apply the transformation in
	// the last step (pushQuad) again.	
	CGAffineTransform inverseTransform = CGAffineTransformIsIdentity(transform)
		? transform
		: CGAffineTransformInvert(transform);
	
	
	// Oh god, I'm so sorry... This code sucks quite a bit. I'd be surprised if I
	// will understand what I've written in 3 days :/
	// Calculating line miters for potentially closed paths is serious business!
	// And it doesn't even handle all the edge cases.
			
	EJVector2
		*transCurrent, *transNext,	// Pointers to current and next vertices on the line
		current, next,				// Untransformed current and next points
		firstMiter1, firstMiter2,	// First miter vertices (left, right) needed for closed paths
		miter11, miter12,			// Current miter vertices (left, right)
		miter21, miter22,			// Next miter vertices (left, right)
		currentEdge, currentExt,	// Current edge and its normal * width/2
		nextEdge, nextExt;			// Next edge and its normal * width/2
	
	for( path_t::iterator sp = paths.begin(); sp != paths.end(); ++sp ) {
		EJVector2
			front = sp->front(),
			back = sp->back();
		
		// If back and front are equal, this subpath is closed.
		BOOL subPathIsClosed = (sp->size() > 2 && front.x == back.x && front.y == back.y);
		BOOL ignoreFirstSegment = addMiter && subPathIsClosed;
		BOOL firstInSubPath = true;
		
		// If this subpath is closed, initialize the first vertex for the loop ("next")
		// to the last vertex in the subpath. This way, the miter between the last and
		// the first segment will be computed and used to draw the first segment's first
		// miter, as well as the last segment's last miter outside the loop.
		transNext = subPathIsClosed ? &sp->at(sp->size()-2) : NULL;
		transCurrent = NULL;

		for( subpath_t::iterator vertex = sp->begin(); vertex != sp->end(); ++vertex) {
			transCurrent = transNext;
			transNext = &(*vertex);
			
			current = next;
			next = EJVector2ApplyTransform( *transNext, inverseTransform );
			
			if( !transCurrent ) { continue; }
			
			
			currentEdge	= nextEdge;
			currentExt = nextExt;
			nextEdge = EJVector2Normalize(EJVector2Sub(next, current));
			nextExt = EJVector2Make( -nextEdge.y * width2, nextEdge.x * width2 );
			
			if( firstInSubPath ) {
				firstMiter1 = miter21 = EJVector2Add( current, nextExt );
				firstMiter2 = miter22 = EJVector2Sub( current, nextExt );
				firstInSubPath = false;
				
				// Start cap
				if( addCaps && !subPathIsClosed ) {
					EJVector2 capExt = { -nextExt.y, nextExt.x };
					EJVector2 cap11 = EJVector2Add( miter21, capExt );
					EJVector2 cap12 = EJVector2Add( miter22, capExt );
					
					[context
						pushQuadV1:cap11 v2:cap12 v3:miter21 v4:miter22
						t1:capTex1 t2:capTex2 t3:midTex1 t4:midTex2
						color:color withTransform:transform];
				}
				
				continue;
			}
			
			
			miter11 = miter21;
			miter12 = miter22;
			
			BOOL miterAdded = false;
			if( addMiter ) {
				EJVector2 miterEdge = EJVector2Add( currentEdge, nextEdge );
				float miterExt = (1/EJVector2Dot(miterEdge, miterEdge)) * state->lineWidth;
				
				if( miterExt < miterLimit ) {
					miterEdge.x *= miterExt;
					miterEdge.y *= miterExt;
					miter21 = EJVector2Make( current.x - miterEdge.y, current.y + miterEdge.x );
					miter22 = EJVector2Make( current.x + miterEdge.y, current.y - miterEdge.x );
					
					miterAdded = true;
				}
			}
			
			// No miter added? Calculate the butt for the current segment
			if( !miterAdded ) {
				miter21 = EJVector2Add(current, currentExt);
				miter22 = EJVector2Sub(current, currentExt);
			}
			
			if( ignoreFirstSegment ) {
				// True when starting from the back vertex of a closed path. This run was just
				// to calculate the first miter.
				firstMiter1 = miter21;
				firstMiter2 = miter22;
				ignoreFirstSegment = false;
				continue;
			}
			
			[context
				pushQuadV1:miter11 v2:miter12 v3:miter21 v4:miter22
				t1:midTex1 t2:midTex2 t3:midTex1 t4:midTex2
				color:color withTransform:transform];
			
			// No miter added? The "miter" for the next segment needs to be the butt for the next segment,
			// not the butt for the current one.
			if( !miterAdded ) {
				miter21 = EJVector2Add(current, nextExt);
				miter22 = EJVector2Sub(current, nextExt);
			}
		} // for each subpath
		
		
		// The last segment, not handled in the loop
		if( subPathIsClosed ) {
			miter11 = firstMiter1;
			miter12 = firstMiter2;
		}
		else {
			EJVector2 untransformedBack = EJVector2ApplyTransform(back, inverseTransform);
			miter11 = EJVector2Add(untransformedBack, nextExt);
			miter12 = EJVector2Sub(untransformedBack, nextExt);
		}
		
		[context
			pushQuadV1:miter11 v2:miter12 v3:miter21 v4:miter22
			t1:midTex1 t2:midTex2 t3:midTex1 t4:midTex2
			color:color withTransform:transform];		
		
		// End cap
		if( addCaps && !subPathIsClosed ) {
			EJVector2 capExt = { nextExt.y, -nextExt.x };
			EJVector2 cap11 = EJVector2Add( miter11, capExt );
			EJVector2 cap12 = EJVector2Add( miter12, capExt );
			
			[context
				pushQuadV1:cap11 v2:cap12 v3:miter11 v4:miter12
				t1:capTex1 t2:capTex2 t3:midTex1 t4:midTex2
				color:color withTransform:transform];
		}
	} // for each path
}


@end
