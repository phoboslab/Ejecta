#import <Foundation/Foundation.h>
#import <math.h>

typedef union { 
	struct { 
		unsigned char r, g, b, a;
	} rgba;
	unsigned char components[4];
	unsigned int hex;
} EJColorRGBA;

typedef struct {
	float x, y;
} EJVector2;

static inline EJVector2 EJVector2Make( float x, float y ) {
  EJVector2 p = {x, y};
  return p;
}

static inline EJVector2 EJVector2Add( EJVector2 a, EJVector2 b ) {
	EJVector2 p = {a.x + b.x, a.y + b.y};
	return p;
}

static inline EJVector2 EJVector2Sub( EJVector2 a, EJVector2 b ) {
	EJVector2 p = {a.x - b.x, a.y - b.y};
	return p;
}

static inline EJVector2 EJVector2Normalize( EJVector2 v ) {
	double ln = sqrtf( v.x*v.x + v.y*v.y );
	if (ln == 0) { return v; }
	
	v.x /= ln;
	v.y /= ln;
	return v;
}

static inline float EJVector2Length( EJVector2 v ) {
	return sqrtf( v.x*v.x + v.y*v.y );
}

static inline float EJVector2LengthSquared( EJVector2 v ) {
	return v.x*v.x + v.y*v.y;
}

static inline float EJVector2Dot( const EJVector2 v1, const EJVector2 v2 ) {
	return v1.x * v2.x + v1.y * v2.y;
}

static inline EJVector2 EJVector2ApplyTransform(EJVector2 p, CGAffineTransform t) {
	EJVector2 pt = {
		t.a * p.x + t.c * p.y + t.tx,
		t.b * p.x + t.d * p.y + t.ty
	};
	return pt;
}

static inline float CGAffineTransformGetScale( CGAffineTransform t ) {
	return sqrtf( t.a*t.a + t.c*t.c );
}

typedef struct {
	EJVector2 pos;
	EJVector2 uv;
	EJColorRGBA color;
} EJVertex;

