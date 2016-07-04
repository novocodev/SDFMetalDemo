#ifndef __SP_SDB_STATIC_SHADER
#define __SP_SDB_STATIC_SHADER

#include <metal_stdlib>
namespace staticshader {

	using namespace metal;

	typedef float2 vec2;
	typedef float3 vec3;
	typedef float4 vec4;
	
	typedef float2x2 mat2;
	typedef float3x3 mat3;
	typedef float4x4 mat4;
	
#define PI 3.1415926535897932384626433832795
#define TAU (2*PI)
#define PHI 1.618033988749894848204586834


// Clamp to [0,1] - this operation is free under certain circumstances.
// For further information see
// http://www.humus.name/Articles/Persson_LowLevelThinking.pdf and
// http://www.humus.name/Articles/Persson_LowlevelShaderOptimization.pdf
#define saturate(x) clamp(x, (float)0, (float)1)

// Sign function that doesn't return 0
	float sgn(float x);
	float sgn(float x) {
		return (x<0) ? -1 : 1;
	}
	
	vec2 sgn2(vec2 v);
	vec2 sgn2(vec2 v) {
		return vec2((v.x<0) ? -1 : 1, (v.y<0) ? -1 : 1);
	}
	
	float square (float x);
	float square (float x) {
		return x*x;
	}
	
	vec2 square (vec2 x);
	vec2 square (vec2 x) {
		return x*x;
	}
	
	vec3 square (vec3 x);
	vec3 square (vec3 x) {
		return x*x;
	}
	
	float lengthSqr(vec3 x);
	float lengthSqr(vec3 x) {
		return dot(x, x);
	}
	
	
// Maximum/minumum elements of a vector
	float vmax(vec2 v);
	float vmax(vec2 v) {
		return max(v.x, v.y);
	}
	
	float vmax(vec3 v);
	float vmax(vec3 v) {
		return max(max(v.x, v.y), v.z);
	}
	
	float vmax(vec4 v);
	float vmax(vec4 v) {
		return max(max(v.x, v.y), max(v.z, v.w));
	}
	
	float vmin(vec2 v);
	float vmin(vec2 v) {
		return min(v.x, v.y);
	}
	
	float vmin(vec3 v);
	float vmin(vec3 v) {
		return min(min(v.x, v.y), v.z);
	}
	
	float vmin(vec4 v);
	float vmin(vec4 v) {
		return min(min(v.x, v.y), min(v.z, v.w));
	}

	float fSphere(vec3 p, float r);
	float fSphere(vec3 p, float r) {
		return length(p) - r;
	}
	
// Plane with normal n (n is normalized) at some distance from the origin
	float fPlane(vec3 p, vec3 n, float distanceFromOrigin);
	float fPlane(vec3 p, vec3 n, float distanceFromOrigin) {
		return dot(p, n) + distanceFromOrigin;
	}
	
// Cheap Box: distance to corners is overestimated
	float fBoxCheap(vec3 p, vec3 b);
	float fBoxCheap(vec3 p, vec3 b) { //cheap box
		return vmax(abs(p) - b);
	}
	
// Box: correct distance to corners
	float fBox(vec3 p, vec3 b);
	float fBox(vec3 p, vec3 b) {
		vec3 d = abs(p) - b;
		return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
	}
	
// Same as above, but in two dimensions (an endless box)
	float fBox2Cheap(vec2 p, vec2 b);
	float fBox2Cheap(vec2 p, vec2 b) {
		return vmax(abs(p)-b);
	}
	
	float fBox2(vec2 p, vec2 b);
	float fBox2(vec2 p, vec2 b) {
		vec2 d = abs(p) - b;
		return length(max(d, vec2(0))) + vmax(min(d, vec2(0)));
	}
	
// Endless "corner"
	float fCorner (vec2 p);
	float fCorner (vec2 p) {
		return length(max(p, vec2(0))) + vmax(min(p, vec2(0)));
	}
	
// Blobby ball object. You've probably seen it somewhere. This is not a correct distance bound, beware.
	float fBlob(vec3 p);
	float fBlob(vec3 p) {
		p = abs(p);
		if (p.x < max(p.y, p.z)) p = p.yzx;
		if (p.x < max(p.y, p.z)) p = p.yzx;
		float b = max(max(max(
		                          dot(p, normalize(vec3(1, 1, 1))),
		                          dot(p.xz, normalize(vec2(PHI+1, 1)))),
		                  dot(p.yx, normalize(vec2(1, PHI)))),
		              dot(p.xz, normalize(vec2(1, PHI))));
		float l = length(p);
		return l - 1.5 - 0.2 * (1.5 / 2)* cos(min(sqrt(1.01 - b / l)*(PI / 0.25), PI));
	}
	
// Cylinder standing upright on the xz plane
	float fCylinder(vec3 p, float r, float height);
	float fCylinder(vec3 p, float r, float height) {
		float d = length(p.xz) - r;
		d = max(d, abs(p.y) - height);
		return d;
	}
	
// Capsule: A Cylinder with round caps on both sides
	float fCapsule(vec3 p, float r, float c);
	float fCapsule(vec3 p, float r, float c) {
		return mix(length(p.xz) - r, length(vec3(p.x, abs(p.y) - c, p.z)) - r, step(c, abs(p.y)));
	}
	
// Distance to line segment between <a> and <b>, used for fCapsule() version 2below
	float fLineSegment(vec3 p, vec3 a, vec3 b);
	float fLineSegment(vec3 p, vec3 a, vec3 b) {
		vec3 ab = b - a;
		float t = saturate(dot(p - a, ab) / dot(ab, ab));
		return length(fma(ab,t,a) - p);
	}
	
// Capsule version 2: between two end points <a> and <b> with radius r
	float fCapsule(vec3 p, vec3 a, vec3 b, float r);
	float fCapsule(vec3 p, vec3 a, vec3 b, float r) {
		return fLineSegment(p, a, b) - r;
	}
	
// Torus in the XZ-plane
	float fTorus(vec3 p, float smallRadius, float largeRadius);
	float fTorus(vec3 p, float smallRadius, float largeRadius) {
		return length(vec2(length(p.xz) - largeRadius, p.y)) - smallRadius;
	}
	
// A circle line. Can also be used to make a torus by subtracting the smaller radius of the torus.
	float fCircle(vec3 p, float r);
	float fCircle(vec3 p, float r) {
		float l = length(p.xz) - r;
		return length(vec2(p.y, l));
	}
	
// A circular disc with no thickness (i.e. a cylinder with no height).
// Subtract some value to make a flat disc with rounded edge.
	float fDisc(vec3 p, float r);
	float fDisc(vec3 p, float r) {
		float l = length(p.xz) - r;
		return l < 0 ? abs(p.y) : length(vec2(p.y, l));
	}
	
// Hexagonal prism, circumcircle variant
	float fHexagonCircumcircle(vec3 p, vec2 h);
	float fHexagonCircumcircle(vec3 p, vec2 h) {
		vec3 q = abs(p);
		return max(q.y - h.y, max(fma(q.x,0.86602540378444, q.z*0.5), q.z) - h.x);
//this is mathematically equivalent to this line, but less efficient:
//return max(q.y - h.y, max(dot(vec2(cos(PI/3), sin(PI/3)), q.zx), q.z) - h.x);
	}
	
// Hexagonal prism, incircle variant
	float fHexagonIncircle(vec3 p, vec2 h);
	float fHexagonIncircle(vec3 p, vec2 h) {
		return fHexagonCircumcircle(p, vec2(h.x*0.86602540378444, h.y));
	}
	
// Cone with correct distances to tip and base circle. Y is up, 0 is in the middle of the base.
	float fCone(vec3 p, float radius, float height);
	float fCone(vec3 p, float radius, float height) {
		vec2 q = vec2(length(p.xz), p.y);
		vec2 tip = q - vec2(0, height);
		vec2 mantleDir = normalize(vec2(height, radius));
		float mantle = dot(tip, mantleDir);
		float d = max(mantle, -q.y);
		float projected = dot(tip, vec2(mantleDir.y, -mantleDir.x));
		
// distance to tip
		if ((q.y > height) && (projected < 0)) {
			d = max(d, length(tip));
		}
		
// distance to base ring
		if ((q.x > radius) && (projected > length(vec2(height, radius)))) {
			d = max(d, length(q - vec2(radius, 0)));
		}
		return d;
	}
	
//
// "Generalized Distance Functions" by Akleman and Chen.
// see the Paper at https://www.viz.tamu.edu/faculty/ergun/research/implicitmodeling/papers/sm99.pdf
//
// This set of constants is used to construct a large variety of geometric primitives.
// Indices are shifted by 1 compared to the paper because we start counting at Zero.
// Some of those are slow whenever a driver decides to not unroll the loop,
// which seems to happen for fIcosahedron und fTruncatedIcosahedron on nvidia 350.12 at least.
// Specialized implementations can well be faster in all cases.
//

	   constant vec3 GDFVectors[19] = {
	        normalize(vec3(1, 0, 0)),
	        normalize(vec3(0, 1, 0)),
	        normalize(vec3(0, 0, 1)),
	        
	        normalize(vec3(1, 1, 1 )),
	        normalize(vec3(-1, 1, 1)),
	        normalize(vec3(1, -1, 1)),
	        normalize(vec3(1, 1, -1)),
	        
	        normalize(vec3(0, 1, PHI+1)),
	        normalize(vec3(0, -1, PHI+1)),
	        normalize(vec3(PHI+1, 0, 1)),
	        normalize(vec3(-PHI-1, 0, 1)),
	        normalize(vec3(1, PHI+1, 0)),
	        normalize(vec3(-1, PHI+1, 0)),
	        
	        normalize(vec3(0, PHI, 1)),
	        normalize(vec3(0, -PHI, 1)),
	        normalize(vec3(1, 0, PHI)),
	        normalize(vec3(-1, 0, PHI)),
	        normalize(vec3(PHI, 1, 0)),
	        normalize(vec3(-PHI, 1, 0))
	   };
	   
	   // Version with variable exponent.
	   // This is slow and does not produce correct distances, but allows for bulging of objects.
	   float fGDF(vec3 p, float r, float e, int begin, int end);
	   float fGDF(vec3 p, float r, float e, int begin, int end) {
	        float d = 0;
	        for (int i = begin; i <= end; ++i)
	                d += pow(abs(dot(p, GDFVectors[i])), e);
	        return pow(d, 1/e) - r;
	   }
	   
	   // Version with without exponent, creates objects with sharp edges and flat faces
	   float fGDF(vec3 p, float r, int begin, int end);
	   float fGDF(vec3 p, float r, int begin, int end) {
	        float d = 0;
	        for (int i = begin; i <= end; ++i)
	                d = max(d, abs(dot(p, GDFVectors[i])));
	        return d - r;
	   }
	   
	   // Primitives follow:
	   float fOctahedron(vec3 p, float r, float e);
	   float fOctahedron(vec3 p, float r, float e) {
	        return fGDF(p, r, e, 3, 6);
	   }
	   float fDodecahedron(vec3 p, float r, float e);
	   float fDodecahedron(vec3 p, float r, float e) {
	        return fGDF(p, r, e, 13, 18);
	   }
	   float fIcosahedron(vec3 p, float r, float e);
	   float fIcosahedron(vec3 p, float r, float e) {
	        return fGDF(p, r, e, 3, 12);
	   }
	   
	   float fTruncatedOctahedron(vec3 p, float r, float e);
	   float fTruncatedOctahedron(vec3 p, float r, float e) {
	        return fGDF(p, r, e, 0, 6);
	   }
	   
	   float fTruncatedIcosahedron(vec3 p, float r, float e);
	   float fTruncatedIcosahedron(vec3 p, float r, float e) {
	        return fGDF(p, r, e, 3, 18);
	   }
	   
	   float fOctahedron(vec3 p, float r);
	   float fOctahedron(vec3 p, float r) {
	        return fGDF(p, r, 3, 6);
	   }
	   
	   float fDodecahedron(vec3 p, float r);
	   float fDodecahedron(vec3 p, float r) {
	        return fGDF(p, r, 13, 18);
	   }
	   
	   float fIcosahedron(vec3 p, float r);
	   float fIcosahedron(vec3 p, float r) {
	        return fGDF(p, r, 3, 12);
	   }
	   
	   float fTruncatedOctahedron(vec3 p, float r);
	   float fTruncatedOctahedron(vec3 p, float r) {
	        return fGDF(p, r, 0, 6);
	   }
	   
	   float fTruncatedIcosahedron(vec3 p, float r);
	   float fTruncatedIcosahedron(vec3 p, float r) {
	        return fGDF(p, r, 3, 18);
	   }


/*
 * Implements GLSL mod
 * rather than HLSL which does not honour negative co-ords
 */
float mod(float x, float y);
float mod(float x, float y)
{
return x - y * floor(x/y);
}

vec2 mod(vec2 x, vec2 y);
vec2 mod(vec2 x, vec2 y)
{
return x - y * floor(x/y);
}

vec3 mod(vec3 x, vec3 y);
vec3 mod(vec3 x, vec3 y)
{
    return x - y * floor(x/y);
}

// Rotate around a coordinate axis (i.e. in a plane perpendicular to that axis) by angle <a>.
// Read like this: R(p.xz, a) rotates "x towards z".
// This is fast if <a> is a compile-time constant and slower (but still practical) if not.
	void pR(thread vec2 &p, float a);
	void pR(thread vec2 &p, float a) {
		p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
	}

// Rotate around a coordinate axis (i.e. in a plane perpendicular to that axis) by angle <a>.
// Read like this: R(p.xz, a) rotates "x towards z".
// This is fast if <a> is a compile-time constant and slower (but still practical) if not.
    void pR(thread vec3 &p, int axis1, int axis2, float a);
    void pR(thread vec3 &p, int axis1, int axis2, float a) {
        vec2 v = cos(a)*vec2(p[axis1],p[axis2]) + sin(a)*vec2(p[axis2], -p[axis1]);
        p[axis1] = v.x;
        p[axis2] = v.y;
    }

// Shortcut for 45-degrees rotation
	void pR45(thread vec2 &p);
	void pR45(thread vec2 &p) {
		p = (p + vec2(p.y, -p.x))*0.707106781186548;
	}
	
// Repeat space along one axis. Use like this to repeat along the x axis:
// <float cell = pMod1(p.x,5);> - using the return value is optional.
	float pMod1(thread float &p, float size);
	float pMod1(thread float &p, float size) {
		float halfsize = size*0.5;
		float c = floor((p + halfsize)/size);
		p = mod(p + halfsize, size) - halfsize;
		return c;
	}
	
// Same, but mirror every second cell so they match at the boundaries
	float pModMirror1(thread float &p, float size);
	float pModMirror1(thread float &p, float size) {
		float halfsize = size*0.5;
		float c = floor((p + halfsize)/size);
		p = mod(p + halfsize,size) - halfsize;
		p *= mod(c, 2.0)*2 - 1;
		return c;
	}
	
// Repeat the domain only in positive direction. Everything in the negative half-space is unchanged.
	float pModSingle1(thread float &p, float size);
	float pModSingle1(thread float &p, float size) {
		float halfsize = size*0.5;
		float c = floor((p + halfsize)/size);
		if (p >= 0)
			p = mod(p + halfsize, size) - halfsize;
		return c;
	}
	
// Repeat only a few times: from indices <start> to <stop> (similar to above, but more flexible)
	float pModInterval1(thread float &p, float size, float start, float stop);
	float pModInterval1(thread float &p, float size, float start, float stop) {
		float halfsize = size*0.5;
		float c = floor((p + halfsize)/size);
		p = mod(p+halfsize, size) - halfsize;
		if (c > stop) { //yes, this might not be the best thing numerically.
			p += size*(c - stop);
			c = stop;
		}
		if (c <start) {
			p += size*(c - start);
			c = start;
		}
		return c;
	}
	
	
// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
	float pModPolar(thread vec2 &p, float repetitions);
	float pModPolar(thread vec2 &p, float repetitions) {
		float angle = 2*PI/repetitions;
		float a = atan2(p.y, p.x) + angle/2.;
		float r = length(p);
		float c = floor(a/angle);
		a = mod(a,angle) - angle/2.;
		p = vec2(cos(a), sin(a))*r;
// For an odd number of repetitions, fix cell index of the cell in -x direction
// (cell index would be e.g. -5 and 5 in the two halves of the cell):
		if (abs(c) >= (repetitions/2)) c = abs(c);
		return c;
	}
	
// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
	vec3 pModPolar(thread vec3 &p, int axis1, int axis2, float repetitions);
	vec3 pModPolar(thread vec3 &p, int axis1, int axis2, float repetitions) {
		float angle = 2*PI/repetitions;
		float a = atan2(p[axis2], p[axis1]) + angle/2.;
		float r = length(vec2(p[axis1],p[axis2]));
		float c = floor(a/angle);
		a = mod(a,angle) - angle/2.;
		vec2 v = vec2(cos(a), sin(a))*r;
		p[axis1] = v.x;
		p[axis2] = v.y;
// For an odd number of repetitions, fix cell index of the cell in -x direction
// (cell index would be e.g. -5 and 5 in the two halves of the cell):
		if (abs(c) >= (repetitions/2)) c = abs(c);
		return vec3(c,0,0);
	}
	
	
	
// Repeat in two dimensions
	vec2 pMod2(thread vec2 &p, vec2 size);
	vec2 pMod2(thread vec2 &p, vec2 size) {
		vec2 c = floor((p + size*0.5)/size);
		p = mod(fma(size,0.5,p),size) - size*0.5;
		return c;
	}
	
// Same, but mirror every second cell so all boundaries match
	vec2 pModMirror2(thread vec2 &p, vec2 size);
	vec2 pModMirror2(thread vec2 &p, vec2 size) {
		vec2 halfsize = size*0.5;
		vec2 c = floor((p + halfsize)/size);
		p = mod(p + halfsize, size) - halfsize;
		p *= mod(c,vec2(2))*2 - vec2(1);
		return c;
	}
	
// Same, but mirror every second cell at the diagonal as well
	vec2 pModGrid2(thread vec2 &p, vec2 size);
	vec2 pModGrid2(thread vec2 &p, vec2 size) {
		vec2 c = floor((p + size*0.5)/size);
		p = mod(fma(size,0.5,p), size) - size*0.5;
		p *= mod(c,vec2(2))*2 - vec2(1);
		p -= size/2;
		if (p.x > p.y) p.xy = p.yx;
		return floor(c/2);
	}
	
// Repeat in three dimensions
	vec3 pMod3(thread vec3 &p, vec3 size);
	vec3 pMod3(thread vec3 &p, vec3 size) {
        vec3 halfsize = size*0.5;
		vec3 c = floor((p + halfsize )/size);
		p = mod(fma(size,0.5,p), size) - size*0.5;
		return c;
	}
	
// Mirror at an axis-aligned plane which is at a specified distance <dist> from the origin.
	float pMirror (thread float &p, float dist);
	float pMirror (thread float &p, float dist) {
		float s = sgn(p);
		p = abs(p)-dist;
		return s;
	}
	
// Mirror in both dimensions and at the diagonal, yielding one eighth of the space.
// translate by dist before mirroring.
	vec2 pMirrorOctant (thread vec2 &p, vec2 dist);
	vec2 pMirrorOctant (thread vec2 &p, vec2 dist) {
		vec2 s = sgn2(p);
		
		float px = p.x;
		pMirror(px, dist.x);
		p.x = px;
		
		float py = p.y;
		pMirror(py, dist.y);
		p.y = py;
		
		if (p.y > p.x)
			p.xy = p.yx;
		return s;
	}
	
// Reflect space at a plane
	float pReflect(thread vec3 &p, vec3 planeNormal, float offset);
	float pReflect(thread vec3 &p, vec3 planeNormal, float offset) {
		float t = dot(p, planeNormal)+offset;
		if (t < 0) {
			p = p - (2*t)*planeNormal;
		}
		return sgn(t);
	}
	

// The "Chamfer" flavour makes a 45-degree chamfered edge (the diagonal of a square of size <r>):
	float fOpUnionChamfer(float a, float b, float r);
	float fOpUnionChamfer(float a, float b, float r) {
		return min(min(a, b), (a - r + b)*0.707106781186548);
	}
	
// Intersection has to deal with what is normally the inside of the resulting object
// when using union, which we normally don't care about too much. Thus, intersection
// implementations sometimes differ from union implementations.
	float fOpIntersectionChamfer(float a, float b, float r);
	float fOpIntersectionChamfer(float a, float b, float r) {
		return max(max(a, b), (a + r + b)*0.707106781186548);
	}
	
// Difference can be built from Intersection or Union:
	float fOpDifferenceChamfer (float a, float b, float r);
	float fOpDifferenceChamfer (float a, float b, float r) {
		return fOpIntersectionChamfer(a, -b, r);
	}
	
// The "Round" variant uses a quarter-circle to join the two objects smoothly:
	float fOpUnionRound(float a, float b, float r);
	float fOpUnionRound(float a, float b, float r) {
		vec2 u = max(vec2(r - a,r - b), vec2(0));
		return max(r, min (a, b)) - length(u);
	}
	
	float fOpIntersectionRound(float a, float b, float r);
	float fOpIntersectionRound(float a, float b, float r) {
		vec2 u = max(vec2(r + a,r + b), vec2(0));
		return min(-r, max (a, b)) + length(u);
	}
	
	float fOpDifferenceRound (float a, float b, float r);
	float fOpDifferenceRound (float a, float b, float r) {
		return fOpIntersectionRound(a, -b, r);
	}
	
	
// The "Columns" flavour makes n-1 circular columns at a 45 degree angle:
	float fOpUnionColumns(float a, float b, float r, float n);
	float fOpUnionColumns(float a, float b, float r, float n) {
		if ((a < r) && (b < r)) {
			vec2 p = vec2(a, b);
			float columnradius = r*1.414213562373095/((n-1)*2+1.414213562373095);
			pR45(p);
			p.x -= 1.414213562373095/2*r;
			p.x += columnradius*1.414213562373095;
			if (mod(n,(float)2) == (float)1) {
				p.y += columnradius;
			}
// At this point, we have turned 45 degrees and moved at a point on the
// diagonal that we want to place the columns on.
// Now, repeat the domain along this direction and place a circle.
			float py = p.y;
			pMod1(py, columnradius*2);
			p.y = py;
			float result = length(p) - columnradius;
			result = min(result, p.x);
			result = min(result, a);
			return min(result, b);
		} else {
			return min(a, b);
		}
	}
	
	float fOpDifferenceColumns(float a, float b, float r, float n);
	float fOpDifferenceColumns(float a, float b, float r, float n) {
		a = -a;
		float m = min(a, b);
//avoid the expensive computation where not needed (produces discontinuity though)
		if ((a < r) && (b < r)) {
			vec2 p = vec2(a, b);
			float columnradius = r*0.70710678118655/n;
			columnradius = r*1.414213562373095/fma((n-1),2,1.414213562373095);
			
			pR45(p);
			p.y += columnradius;
			p.x -= 1.414213562373095/2*r;
			p.x += -columnradius*1.414213562373095/2;
			
			if (mod(n,2) == 1) {
				p.y += columnradius;
			}
			
			float py = p.y;
			pMod1(py,columnradius*2);
			p.y = py;
			
			float result = -length(p) + columnradius;
			result = max(result, p.x);
			result = min(result, a);
			return -min(result, b);
		} else {
			return -m;
		}
	}
	
	float fOpIntersectionColumns(float a, float b, float r, float n);
	float fOpIntersectionColumns(float a, float b, float r, float n) {
		return fOpDifferenceColumns(a,-b,r, n);
	}
	
// The "Stairs" flavour produces n-1 steps of a staircase:
// much less stupid version by paniq
	float fOpUnionStairs(float a, float b, float r, float n);
	float fOpUnionStairs(float a, float b, float r, float n) {
		float s = r/n;
		float u = b-r;
		return min(min(a,b), 0.5 * (u + a + abs ((mod (u - a + s, 2 * s)) - s)));
	}
	
// We can just call Union since stairs are symmetric.
	float fOpIntersectionStairs(float a, float b, float r, float n);
	float fOpIntersectionStairs(float a, float b, float r, float n) {
		return -fOpUnionStairs(-a, -b, r, n);
	}
	
	float fOpDifferenceStairs(float a, float b, float r, float n);
	float fOpDifferenceStairs(float a, float b, float r, float n) {
		return -fOpUnionStairs(-a, b, r, n);
	}
	
	
// Similar to fOpUnionRound, but more lipschitz-y at acute angles
// (and less so at 90 degrees). Useful when fudging around too much
// by MediaMolecule, from Alex Evans' siggraph slides
	float fOpUnionSoft(float a, float b, float r);
	float fOpUnionSoft(float a, float b, float r) {
		float e = max(r - abs(a - b), float(0));
		return min(a, b) - e*e*0.25/r;
	}
	
	
// produces a cylindical pipe that runs along the intersection.
// No objects remain, only the pipe. This is not a boolean operator.
	float fOpPipe(float a, float b, float r);
	float fOpPipe(float a, float b, float r) {
		return length(vec2(a, b)) - r;
	}
	
// first object gets a v-shaped engraving where it intersect the second
	float fOpEngrave(float a, float b, float r);
	float fOpEngrave(float a, float b, float r) {
		return max(a, (a + r - abs(b))*0.707106781186548);
	}
	
// first object gets a capenter-style groove cut out
	float fOpGroove(float a, float b, float ra, float rb);
	float fOpGroove(float a, float b, float ra, float rb) {
		return max(a, min(a + ra, rb - abs(b)));
	}
	
// first object gets a capenter-style tongue attached
	float fOpTongue(float a, float b, float ra, float rb);
	float fOpTongue(float a, float b, float ra, float rb) {
		return min(a, max(a - ra, abs(b) - rb));
	}
	
/*
 * END OF - __HG_SDF
 */
 
 

	float fEllipsoid( vec3 p, vec3 r );
	float fEllipsoid( vec3 p, vec3 r )
	{
		return (length( p/r ) - 1.0) * min(min(r.x,r.y),r.z);
	}
	
	float fRoundBox( vec3 p, vec3 b, float r );
	float fRoundBox( vec3 p, vec3 b, float r )
	{
		return length(max(abs(p)-b,0.0))-r;
	}
	
	float length2( vec2 p );
	float length2( vec2 p )
	{
		return sqrt( p.x*p.x + p.y*p.y );
	}
	
	float length6( vec2 p );
	float length6( vec2 p )
	{
		p = p*p*p; p = p*p;
		return pow( p.x + p.y, 1.0/6.0 );
	}
	
	float length8( vec2 p );
	float length8( vec2 p )
	{
		p = p*p; p = p*p; p = p*p;
		return pow( p.x + p.y, 1.0/8.0 );
	}
	
	float fTorus82( vec3 p, vec2 t );
	float fTorus82( vec3 p, vec2 t )
	{
		vec2 q = vec2(length2(p.xz)-t.x,p.y);
		return length8(q)-t.y;
	}
	
	float fTorus88( vec3 p, vec2 t );
	float fTorus88( vec3 p, vec2 t )
	{
		vec2 q = vec2(length8(p.xz)-t.x,p.y);
		return length8(q)-t.y;
	}
	
	float fCylinder6( vec3 p, vec2 h );
	float fCylinder6( vec3 p, vec2 h )
	{
		return max( length6(p.xz)-h.x, abs(p.y)-h.y );
	}
	
	float pS( float d1, float d2 );
	float pS( float d1, float d2 )
	{
		return max(-d2,d1);
	}
	
	vec3 pRep( vec3 p, vec3 c );
	vec3 pRep( vec3 p, vec3 c )
	{
		return fma(-0.5,c,mod(p,c));
	}
	
	vec3 pTwist( vec3 p );
	vec3 pTwist( vec3 p )
	{
		float c = cos(fma(10.0,p.y,10.0));
		float s = sin(fma(10.0,p.y,10.0));
		mat2 m = mat2(vec2(c,-s),vec2(s,c));
		return vec3(m*p.xz,p.y);
	}
	
//Union that only checks vector.x, this is used as primitives .y is not part of a true vector
	vec3 pU( vec3 d1, vec3 d2 );
	vec3 pU( vec3 d1, vec3 d2 )
	{
		return (d1.x<d2.x) ? d1 : d2;
	}
	

vec3 pS( vec3 d1, vec3 d2);
vec3 pS( vec3 d1, vec3 d2)
{
    //return vec3(max(-d2.x,d1.x), d1.y, d1.z);

    return (-d2.x>d1.x) ? vec3(-d2.x, d2.yz) : d1;
}

// The "Round" variant uses a quarter-circle to join the two objects smoothly:
	vec2 pUnionRound(vec2 a, vec2 b, float r);
	vec2 pUnionRound(vec2 a, vec2 b, float r) {
		vec2 u = max(vec2(r - a.x,r - b.x), vec2(0));
		
		return vec2((max(r, min (a.x, b.x)) - length(u)),a.y);
	}
	
	
	float fTriPrism( vec3 p, vec2 h );
	float fTriPrism( vec3 p, vec2 h )
	{
		vec3 q = abs(p);
//#if 0
		return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
//#else
//float d1 = q.z-h.y;
//float d2 = max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5;
//return length(max(vec2(d1,d2),0.0)) + min(max(d1,d2), 0.);
//#endif
	}
	
// ported from primitives
	float fConeSection( vec3 p, float h, float r1, float r2 );
	float fConeSection( vec3 p, float h, float r1, float r2 )
	{
		float d1 = -p.y - h;
		float q = p.y - h;
		float si = 0.5*(r1-r2)/h;
		float d2 = max( sqrt( dot(p.xz,p.xz)*(1.0-si*si)) + q*si - r2, q );
		return length(max(vec2(d1,d2),0.0)) + min(max(d1,d2), 0.);
	}
	


/*
 * END OF Ported Primitives
 */

    struct SDFMaterial {
        vec3 diffuse;
        vec3 specular;
        vec3 ambient;
        vec3 dome;
        vec3 bac;
        vec3 frensel;
    };

    struct SDFUniforms {
        float modelVersion;
        mat3 cameraTransform;
        vec3 rayOrigin;
    };

	struct Stack {
		uint count;
		float2x2 stack;
	};
	
	Stack newstack();
	Stack newstack() {
		Stack s;
		s.count = 0;
		
		return s;
	}
	
	void push(thread Stack &s, vec2 v);
	void push(thread Stack &s, vec2 v) {
		s.stack[s.count++] = v;
	}
	
	vec2 pop(thread Stack &s);
	vec2 pop(thread Stack &s) {
		return s.stack[--s.count];
	}

    //Template for in-lined materials
    constant SDFMaterial materials[%i] = {
        %@
    };

//NEW DISTANCE FUNCTIONS


    void pModOffset( thread vec3 &p, vec3 offset);
    void pModOffset( thread vec3 &p, vec3 offset) {
        p -= offset;
    }

//Static distance functions for scene
//Ferformance is non optimal, minimum number of distance
//functions should be processed here
	vec3 map( vec3 pos);
	vec3 map( vec3 pos)
	{
		vec3 origPos = pos;
        vec3 res = vec3(0);
        vec3 cells = vec3(0);

        //Template for Signed Distance Function for this scene
        %@

        origPos = origPos;
        cells = cells;
		return res;
	}

    half3 maph( half3 pos);
    half3 maph( half3 pos)
    {
        return half3(map(vec3(pos)));
    }

	vec3 castRay( vec3 ro, vec3 rd);
	vec3 castRay( vec3 ro, vec3 rd)
	{
        const int maxIterations = 256;
		float tmin = 0.1;
		float tmax = 100.0;
		float precis = 0.000001;
		float t = tmin;
		float m = -1.0;
        float o = -1.0;
		int i = 0;
        vec3 res = 0.0;
		for(; i<maxIterations; i++ )
		{
			res = map( fma(rd,t,ro));
            if( res.x<precis ) {
                o = res.y;
                m = res.z;
                break;
            }
            if(t>tmax ) break;
			t += res.x;

		}
		return vec3( t, o, m );
	}

/*
    vec2 castRayRelaxed( vec3 ro, vec3 rd);
    vec2 castRayRelaxed( vec3 ro, vec3 rd)
    {
        const int MAX_ITERATIONS = 256;
        const float t_min = 0.1;
        const float t_max = 100.0;
        const float pixelRadius = 0.00001;
        const bool forceHit = true;

        // ro, rd : ray origin, direction (normalized)
        // t_min, t_max: minimum, maximum t values
        // pixelRadius: radius of a pixel at t = 1
        // forceHit: boolean enforcing to use the
        // candidate_t value as result
        float omega = 1.2;
        float t = t_min;
        float candidate_error = INFINITY;
        float candidate_t = t_min;
        float previousRadius = 0;
        float stepLength = 0;
        float functionSign = 1.0; //map(ro).x < 0 ? -1 : +1;
        float m = -1.0;

        for (int i = 0; i < MAX_ITERATIONS; ++i) {
            vec3 res = map( fma(rd,t,ro));
            float signedRadius = functionSign * res.x;
            float radius = abs(signedRadius);

            bool sorFail = omega > 1 && (radius + previousRadius) < stepLength;
            if (sorFail) {
                stepLength -= omega * stepLength;
                omega = 1;
            }
            else
            {
                stepLength = signedRadius * omega;
            }

            previousRadius = radius;
            float error = radius / t;

            if (!sorFail && error < candidate_error) {
                candidate_t = t;
                candidate_error = error;
            }

            if(!sorFail && (error < pixelRadius || t > t_max)) {
                break;
            }
            t += stepLength;
            m = res.y;
        }

        if ((t > t_max || candidate_error > pixelRadius) && !forceHit) {
            return vec2(INFINITY,-1.0);
        }

        return vec2( candidate_t, m );
    }
*/

    half softshadow( vec3 ro, vec3 rd, float mint, float tmax);
    half softshadow( vec3 ro, vec3 rd, float mint, float tmax)
    {
        half3 roh = half3(ro);
        half3 rdh = half3(rd);
        half minth = half(mint);
        half tmaxh = half(tmax);

        half res = 1.0h;
        half t = minth;
        for( int i=0; i<16; i++ )
        {
            half h = maph( fma(rdh,t,roh)).x;
            res = min( res, 8.0h*h/t );
            t += clamp( h, 0.02h, 0.10h );
            if( h<0.001h || t>tmaxh ) break;
        }
        return clamp( res, 0.0h, 1.0h );
    }


    vec3 calcNormal( vec3 pos);
    vec3 calcNormal( vec3 pos)
    {
        half3 posh = half3(pos);
        half3 eps = half3( 0.001h, 0.0h, 0.0h );
        half3 nor = half3(
            maph(posh+eps.xyy).x - maph(posh-eps.xyy).x,
            maph(posh+eps.yxy).x - maph(posh-eps.yxy).x,
            maph(posh+eps.yyx).x - maph(posh-eps.yyx).x );
        return normalize(vec3(nor));
    }

/*
 * This calculates whether there is a reflection at a point
 * but it seems to be limited to objects 1.0 or less distance
 * from point being tested.
 * Also there are no reflections below the x/z plane
 *
 * These restrictions are probably for performance but it limits the
 * visual appearane of the scene, make this more generic.
 */
    half calcAO( vec3 pos, vec3 nor);
    half calcAO( vec3 pos, vec3 nor)
    {
        half3 posh = half3(pos);
        half3 norh = half3(nor);
        half occ = 0.0;
        half sca = 1.0;
        for( int i=0; i<5; i++ )
        {
            half hr = fma(0.03h,half(i),0.01h);
            half3 aopos =  fma(norh, hr, posh);
            half dd = maph( aopos).x;
            occ += -(dd-hr)*sca;
            sca *= 0.95;
        }
        return clamp( fma(-3.0h,occ,1.0h ), 0.0h, 1.0h );
    }

	vec3 render( vec3 ro, vec3 rd, constant SDFUniforms &scene);
	vec3 render( vec3 ro, vec3 rd, constant SDFUniforms &scene)
	{
	
//Set default background colour
		vec3 col = fma(rd.y,0.8,vec3(0.7, 0.6, 0.7));
		
		vec3 res = castRay(ro,rd);

        //vec2 res = castRayRelaxed(ro,rd);

		
		if( res.y>-0.5 )
		{
		
			float t = res.x;
            int m = res.z;
//Position of the ray hit
			vec3 pos = fma(t,rd,ro);
			
//Surface normal at the ray hit point
			vec3 nor = calcNormal( pos);
			
			vec3 ref = reflect( rd, nor );
			
// material
            col = vec3(materials[m].ambient[0], materials[m].ambient[1], materials[m].ambient[2]);
            
//ambient occlusion
			float occ = float(calcAO( pos, nor));
			
//Light direction
			vec3 lig = normalize( vec3(-0.6, 0.7, -0.5) );
			
//Ambient
			float amb = clamp( fma(0.5,nor.y,0.5), 0.0, 1.0 );
			
//Diffuse
			float dif = clamp( dot( nor, lig ), 0.0, 1.0 );


			float bac = clamp( dot( nor, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-pos.y,0.0,1.0);
//Sky dome
			float dom = smoothstep( -0.1, 0.1, ref.y );

//Frensel component of reflections
			float fre = pow( clamp(1.0+dot(nor,rd),0.0,1.0), 2.0 );
			
//Specular
			float spe = pow(clamp( dot( ref, lig ), 0.0, 1.0 ),16.0);
			
			dif *= softshadow( pos, lig, 0.02, 2.5);
			dom *= softshadow( pos, ref, 0.02, 2.5);
			
			vec3 lin = vec3(0.0);

            lin += 1.20*dif*materials[m].diffuse;
            lin += 1.20*spe*materials[m].specular*dif;
            lin += 0.20*amb*materials[m].ambient*occ;
            lin += 0.30*dom*materials[m].dome*occ;
            lin += 0.30*bac*materials[m].bac*occ;
            lin += 0.40*fre*materials[m].frensel*occ;

			col = col*lin;

			col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.002*t*t ) );
			
		}
		
		return vec3( clamp(col,0.0,1.0) );
	}
	
	mat3 setCamera( vec3 ro, vec3 ta, float cr );
	mat3 setCamera( vec3 ro, vec3 ta, float cr )
	{
		vec3 cw = normalize(ta-ro);
		vec3 cp = vec3(sin(cr), cos(cr),0.0);
		vec3 cu = normalize( cross(cw,cp) );
		vec3 cv = normalize( cross(cu,cw) );
		return mat3( cu, cv, cw );
	}
	
	
	kernel void signed_distance_bounds(
	        texture2d<float, access::write> outTexture [[texture(0)]],
            constant SDFUniforms &uniforms [[buffer(0)]],
	        uint2 gid [[thread_position_in_grid]])
	{
		vec2 fragCoord = {(float)gid[0], (float)gid[1]};
		
		vec2 iResolution = vec2 (outTexture.get_width(),outTexture.get_height());
		vec2 q = fragCoord.xy/iResolution.xy;
		vec2 p = fma(2.0,q,-1.0);
		p.x *= iResolution.x/iResolution.y;
		
		vec3 rd = uniforms.cameraTransform * normalize( vec3(p.xy,2.0) );
		
		vec3 col = render( uniforms.rayOrigin, rd, uniforms);
		
		col = pow( col, vec3(0.4545) );
		
		vec4 fragColor=vec4( col, 1.0 );
		
		outTexture.write(fragColor, gid);
	}

    struct SDFTouch {
        uint touchPointX;
        uint touchPointY;
        float viewWidth;
        float viewHeight;
    };

    struct SDFHit {
        bool  isHit;
        float hitPointX;
        float hitPointY;
        float hitPointZ;
        uint  hitNodeId;
    };


    kernel void signed_distance_bounds_hit_test(
        constant SDFUniforms &uniforms [[buffer(0)]],
        constant SDFTouch &touch [[buffer(1)]],
        device SDFHit &hit [[buffer(2)]],
        uint2 gid [[thread_position_in_grid]])
    {
        vec2 fragCoord = {(float)touch.touchPointX, (float)touch.touchPointY};
        vec2 iResolution = vec2(touch.viewWidth,touch.viewHeight);

        vec2 q = fragCoord.xy/iResolution.xy;
        vec2 p = fma(2.0,q,-1.0);
        p.x *= iResolution.x/iResolution.y;

        vec3 rd = uniforms.cameraTransform * normalize( vec3(p.xy,2.0) );

        vec3 ro = uniforms.rayOrigin;
        vec3 res = castRay(ro,rd);

        if(res.y == -1.0) {
            hit.isHit = false;
        } else {
            hit.isHit = true;
            hit.hitPointX = res.x;
            hit.hitNodeId = int(res.y);
        }
    }


} //namespace primitives

#endif /* __PRIMITIVES_SAMPLER */
