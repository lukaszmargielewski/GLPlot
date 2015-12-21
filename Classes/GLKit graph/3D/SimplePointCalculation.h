
#pragma mark -
#pragma mark Helper functions for generic math operations on CGPoints

#if !defined(HALF_PI)
#define HALF_PI	    1.57079632679489661923f
#endif
#if !defined(M_PI)
#define M_PI	    3.14159265358979323846f
#endif
/// Trig Macros ///////////////////////////////////////////////////////////////
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__ * 180.0f) / M_PI)

#pragma mark -
#pragma mark CGVector
#pragma mark -

#define CGVector CGPoint

static inline CGFloat CGVectorLen(CGVector a) {
	return sqrtf(a.x*a.x+a.y*a.y);
}
static inline CGVector CGVectorNorm(CGVector a) {
	CGFloat m = sqrtf(a.x*a.x+a.y*a.y);
	CGVector c;
	c.x = a.x/m;
	c.y = a.y/m;
	return c;
}

static inline CGVector CGPointVector(CGPoint a,CGPoint b) {
	CGVector c = {b.x-a.x,b.y-a.y};
	return c;
}
static inline CGFloat CGVectorAngle(CGVector v){
	
	CGFloat a = atan2(v.x, v.y);
	
	//if(a < 0)a+=M_PI;
	//return RADIANS_TO_DEGREES(a);
	return a;
}

#pragma mark -
#pragma mark CGPoint
#pragma mark -

static inline CGFloat CGPointDot(CGPoint a,CGPoint b) {
	return a.x*b.x+a.y*b.y;
}

static inline CGFloat CGPointLen(CGPoint a) {
	return sqrtf(a.x*a.x+a.y*a.y);
}


static inline CGPoint CGPointSub(CGPoint a,CGPoint b) {
	CGPoint c = {a.x-b.x,a.y-b.y};
	return c;
}



static inline CGFloat CGPointDist(CGPoint a,CGPoint b) {
	CGPoint c = CGPointSub(a,b);
	return CGPointLen(c);
}

static inline CGPoint CGPointNorm(CGPoint a) {
	CGFloat m = sqrtf(a.x*a.x+a.y*a.y);
	CGPoint c;
	c.x = a.x/m;
	c.y = a.y/m;
	return c;
}