#ifndef __SP_SDB_STATIC_SHADER
#define __SP_SDB_STATIC_SHADER

#include <metal_stdlib>
namespace staticshader {

	using namespace metal;
	
////////////////////////////////////////////////////////////////
//
//                           HG_SDF
//
//     GLSL LIBRARY FOR BUILDING SIGNED DISTANCE BOUNDS
//
//     version 2016-01-10
//
//     Check http://mercury.sexy/hg_sdf for updates
//     and usage examples. Send feedback to spheretracing@mercury.sexy.
//
//     Brought to you by MERCURY http://mercury.sexy
//
//
//
// Released as Creative Commons Attribution-NonCommercial (CC BY-NC)
//
////////////////////////////////////////////////////////////////
//
// How to use this:
//
// 1. Build some system to #include glsl files in each other.
//   Include this one at the very start. Or just paste everywhere.
// 2. Build a sphere tracer. See those papers:
//   * "Sphere Tracing" http://graphics.cs.illinois.edu/sites/default/files/zeno.pdf
//   * "Enhanced Sphere Tracing" http://lgdv.cs.fau.de/get/2234
//   The Raymnarching Toolbox Thread on pouet can be helpful as well
//   http://www.pouet.net/topic.php?which=7931&page=1
//   and contains links to many more resources.
// 3. Use the tools in this library to build your distance bound f().
// 4. ???
// 5. Win a compo.
//
// (6. Buy us a beer or a good vodka or something, if you like.)
//
////////////////////////////////////////////////////////////////
//
// Table of Contents:
//
// * Helper functions and macros
// * Collection of some primitive objects
// * Domain Manipulation operators
// * Object combination operators
//
////////////////////////////////////////////////////////////////
//
// Why use this?
//
// The point of this lib is that everything is structured according
// to patterns that we ended up using when building geometry.
// It makes it more easy to write code that is reusable and that somebody
// else can actually understand. Especially code on Shadertoy (which seems
// to be what everybody else is looking at for "inspiration") tends to be
// really ugly. So we were forced to do something about the situation and
// release this lib ;)
//
// Everything in here can probably be done in some better way.
// Please experiment. We'd love some feedback, especially if you
// use it in a scene production.
//
// The main patterns for building geometry this way are:
// * Stay Lipschitz continuous. That means: don't have any distance
//   gradient larger than 1. Try to be as close to 1 as possible -
//   Distances are euclidean distances, don't fudge around.
//   Underestimating distances will happen. That's why calling
//   it a "distance bound" is more correct. Don't ever multiply
//   distances by some value to "fix" a Lipschitz continuity
//   violation. The invariant is: each fSomething() function returns
//   a correct distance bound.
// * Use very few primitives and combine them as building blocks
//   using combine opertors that preserve the invariant.
// * Multiply objects by repeating the domain (space).
//   If you are using a loop inside your distance function, you are
//   probably doing it wrong (or you are building boring fractals).
// * At right-angle intersections between objects, build a new local
//   coordinate system from the two distances to combine them in
//   interesting ways.
// * As usual, there are always times when it is best to not follow
//   specific patterns.
//
////////////////////////////////////////////////////////////////
//
// FAQ
//
// Q: Why is there no sphere tracing code in this lib?
// A: Because our system is way too complex and always changing.
//    This is the constant part. Also we'd like everyone to
//    explore for themselves.
//
// Q: This does not work when I paste it into Shadertoy!!!!
// A: Yes. It is GLSL, not GLSL ES. We like real OpenGL
//    because it has way more features and is more likely
//    to work compared to browser-based WebGL. We recommend
//    you consider using OpenGL for your productions. Most
//    of this can be ported easily though.
//
// Q: How do I material?
// A: We recommend something like this:
//    Write a material ID, the distance and the local coordinate
//    p into some global variables whenever an object's distance is
//    smaller than the stored distance. Then, at the end, evaluate
//    the material to get color, roughness, etc., and do the shading.
//
// Q: I found an error. Or I made some function that would fit in
//    in this lib. Or I have some suggestion.
// A: Awesome! Drop us a mail at spheretracing@mercury.sexy.
//
// Q: Why is this not on github?
// A: Because we were too lazy. If we get bugged about it enough,
//    we'll do it.
//
// Q: Your license sucks for me.
// A: Oh. What should we change it to?
//
// Q: I have trouble understanding what is going on with my distances.
// A: Some visualization of the distance field helps. Try drawing a
//    plane that you can sweep through your scene with some color
//    representation of the distance field at each point and/or iso
//    lines at regular intervals. Visualizing the length of the
//    gradient (or better: how much it deviates from being equal to 1)
//    is immensely helpful for understanding which parts of the
//    distance field are broken.
//
////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////
//
//             HELPER FUNCTIONS/MACROS
//
////////////////////////////////////////////////////////////////

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
	
	
	
	
////////////////////////////////////////////////////////////////
//
//             PRIMITIVE DISTANCE FUNCTIONS
//
////////////////////////////////////////////////////////////////
//
// Conventions:
//
// Everything that is a distance function is called fSomething.
// The first argument is always a point in 2 or 3-space called <p>.
// Unless otherwise noted, (if the object has an intrinsic "up"
// side or direction) the y axis is "up" and the object is
// centered at the origin.
//
////////////////////////////////////////////////////////////////

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
	   
////////////////////////////////////////////////////////////////
//
//                DOMAIN MANIPULATION OPERATORS
//
////////////////////////////////////////////////////////////////
//
// Conventions:
//
// Everything that modifies the domain is named pSomething.
//
// Many operate only on a subset of the three dimensions. For those,
// you must choose the dimensions that you want manipulated
// by supplying e.g. <p.x> or <p.zx>
//
// <inout p> is always the first argument and modified in place.
//
// Many of the operators partition space into cells. An identifier
// or cell index is returned, if possible. This return value is
// intended to be optionally used e.g. as a random seed to change
// parameters of the distance functions inside the cells.
//
// Unless stated otherwise, for cell index 0, <p> is unchanged and cells
// are centered on the origin so objects don't have to be moved to fit.
//
//
////////////////////////////////////////////////////////////////

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
	float pModPolar(thread vec3 &p, int axis1, int axis2, float repetitions);
	float pModPolar(thread vec3 &p, int axis1, int axis2, float repetitions) {
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
		return c;
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
	
	
////////////////////////////////////////////////////////////////
//
//             OBJECT COMBINATION OPERATORS
//
////////////////////////////////////////////////////////////////
//
// We usually need the following boolean operators to combine two objects:
// Union: OR(a,b)
// Intersection: AND(a,b)
// Difference: AND(a,!b)
// (a and b being the distances to the objects).
//
// The trivial implementations are min(a,b) for union, max(a,b) for intersection
// and max(a,-b) for difference. To combine objects in more interesting ways to
// produce rounded edges, chamfers, stairs, etc. instead of plain sharp edges we
// can use combination operators. It is common to use some kind of "smooth minimum"
// instead of min(), but we don't like that because it does not preserve Lipschitz
// continuity in many cases.
//
// Naming convention: since they return a distance, they are called fOpSomething.
// The different flavours usually implement all the boolean operators above
// and are called fOpUnionRound, fOpIntersectionRound, etc.
//
// The basic idea: Assume the object surfaces intersect at a right angle. The two
// distances <a> and <b> constitute a new local two-dimensional coordinate system
// with the actual intersection as the origin. In this coordinate system, we can
// evaluate any 2D distance function we want in order to shape the edge.
//
// The operators below are just those that we found useful or interesting and should
// be seen as examples. There are infinitely more possible operators.
//
// They are designed to actually produce correct distances or distance bounds, unlike
// popular "smooth minimum" operators, on the condition that the gradients of the two
// SDFs are at right angles. When they are off by more than 30 degrees or so, the
// Lipschitz condition will no longer hold (i.e. you might get artifacts). The worst
// case is parallel surfaces that are close to each other.
//
// Most have a float argument <r> to specify the radius of the feature they represent.
// This should be much smaller than the object size.
//
// Some of them have checks like "if ((-a < r) && (-b < r))" that restrict
// their influence (and computation cost) to a certain area. You might
// want to lift that restriction or enforce it. We have left it as comments
// in some cases.
//
// usage example:
//
// float fTwoBoxes(vec3 p) {
//   float box0 = fBox(p, vec3(1));
//   float box1 = fBox(p-vec3(1), vec3(1));
//   return fOpUnionChamfer(box0, box1, 0.2);
// }
//
////////////////////////////////////////////////////////////////


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
 
 
////////////////////////////////////////////////////////////////
//
//             PRIMITIVE DISTANCE FUNCTIONS
//
////////////////////////////////////////////////////////////////
//
// Conventions:
//
// Everything that is a distance function is called fSomething.
// The first argument is always a point in 2 or 3-space called &lt;p&gt;.
// Unless otherwise noted, (if the object has an intrinsic "up"
// side or direction) the y axis is "up" and the object is
// centered at the origin.
//
////////////////////////////////////////////////////////////////

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
	vec2 pU( vec2 d1, vec2 d2 );
	vec2 pU( vec2 d1, vec2 d2 )
	{
		return (d1.x<d2.x) ? d1 : d2;
	}
	
vec2 pS( vec2 d1, vec2 d2, float nodeId);
vec2 pS( vec2 d1, vec2 d2, float nodeId)
{
return vec2(max(-d2.x,d1.x), nodeId);
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
	
	
////////////////////////////////////////////////////////////////
//
//                DOMAIN MANIPULATION OPERATORS
//
////////////////////////////////////////////////////////////////
//
// Conventions:
//
// Everything that modifies the domain is named pSomething.
//
// Many operate only on a subset of the three dimensions. For those,
// you must choose the dimensions that you want manipulated
// by supplying e.g. <p.x> or <p.zx>
//
// &lt;inout p&gt; is always the first argument and modified in place.
//
// Many of the operators partition space into cells. An identifier
// or cell index is returned, if possible. This return value is
// intended to be optionally used e.g. as a random seed to change
// parameters of the distance functions inside the cells.
//
// Unless stated otherwise, for cell index 0, &lt;p&gt; is unchanged and cells
// are centered on the origin so objects don't have to be moved to fit.
//
//
////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////
//
//             OBJECT COMBINATION OPERATORS
//
////////////////////////////////////////////////////////////////
//
// We usually need the following boolean operators to combine two objects:
// Union: OR(a,b)
// Intersection: AND(a,b)
// Difference: AND(a,!b)
// (a and b being the distances to the objects).
//
// The trivial implementations are min(a,b) for union, max(a,b) for intersection
// and max(a,-b) for difference. To combine objects in more interesting ways to
// produce rounded edges, chamfers, stairs, etc. instead of plain sharp edges we
// can use combination operators. It is common to use some kind of "smooth minimum"
// instead of min(), but we don't like that because it does not preserve Lipschitz
// continuity in many cases.
//
// Naming convention: since they return a distance, they are called fOpSomething.
// The different flavours usually implement all the boolean operators above
// and are called fOpUnionRound, fOpIntersectionRound, etc.
//
// The basic idea: Assume the object surfaces intersect at a right angle. The two
// distances &lt;a&gt; and &lt;b&gt; constitute a new local two-dimensional coordinate system
// with the actual intersection as the origin. In this coordinate system, we can
// evaluate any 2D distance function we want in order to shape the edge.
//
// The operators below are just those that we found useful or interesting and should
// be seen as examples. There are infinitely more possible operators.
//
// They are designed to actually produce correct distances or distance bounds, unlike
// popular "smooth minimum" operators, on the condition that the gradients of the two
// SDFs are at right angles. When they are off by more than 30 degrees or so, the
// Lipschitz condition will no longer hold (i.e. you might get artifacts). The worst
// case is parallel surfaces that are close to each other.
//
// Most have a float argument &lt;r&gt; to specify the radius of the feature they represent.
// This should be much smaller than the object size.
//
// Some of them have checks like "if ((-a &lt; r) &amp;&amp; (-b &lt; r))" that restrict
// their influence (and computation cost) to a certain area. You might
// want to lift that restriction or enforce it. We have left it as comments
// in some cases.
//
// usage example:
//
// float fTwoBoxes(vec3 p) {
//   float box0 = fBox(p, vec3(1));
//   float box1 = fBox(p-vec3(1), vec3(1));
//   return fOpUnionChamfer(box0, box1, 0.2);
// }
//
////////////////////////////////////////////////////////////////

/*
 * END OF Ported Primitives
 */

    enum nodeType {
        fPlaneType = 1,
        fSphereType = 2,
        fBoxCheapType = 3,
        fRoundBoxType = 4,
        fTorusType = 5,
        fTorus82Type = 6,
        fTorus88Type = 7,
        fCapsuleType = 8,
        fTriPrismType = 9,
        fCylinderType = 10,
        fCylinder6Type = 11,
        fConeType = 12,
        fOctahedronType = 13,
        fEllipsoidType = 14,
        fHexagonIncircleType = 15,
        fBlobType = 16,
        pUnionType = 17,
        pSubtractionType = 18,
        pModOffsetType = 19,
        pModRotateType = 20,
        pModPolarType = 21,
        pModResetType = 22,
        pMod3Type = 23
    };

	struct SDFMaterial {
		float red;
		float green;
		float blue;
		float alpha;
	};

	struct SDFNode {
		size_t functionHash;
		enum nodeType type;
		unsigned char flags;
		float materialId;
		float4x4 transform;
		int ints[32];
		float floats[32];
	};
	
	struct SDFScene {
		float modelVersion;
		float deviceAttitudePitch;
		float deviceAttitudeRoll;
		float deviceAttitudeYaw;
		mat3 cameraTransform;
		vec3 rayOrigin;
		uint nodeCount;
		struct SDFNode nodes[60];
		struct SDFMaterial materials[10];
	};

    struct SDFUniforms {
        float modelVersion;
        mat3 cameraTransform;
        vec3 rayOrigin;
        uint nodeCount;
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
	
	
//NEW DISTANCE FUNCTIONS

	vec2 spfSphere(vec3 p, SDFNode n, uint nodeId);
	vec2 spfSphere(vec3 p, SDFNode n, uint nodeId) {
		return vec2(length(p) - n.floats[9],nodeId);
	}
	
// Cheap Box: distance to corners is overestimated
	vec2 spfBoxCheap(vec3 p, SDFNode n, uint nodeId);
	vec2 spfBoxCheap(vec3 p, SDFNode n, uint nodeId) { //cheap box
		return vec2(vmax(abs(p) - vec3(n.floats[9],n.floats[10],n.floats[11])),nodeId);
	}
	
	vec2 sppU( vec2 d1, vec2 d2 );
	vec2 sppU( vec2 d1, vec2 d2 )
	{
		return (d1.x<d2.x) ? d1 : d2;
	}
	
	vec2 sppS( vec2 d1, vec2 d2, SDFNode n, uint nodeId);
	vec2 sppS( vec2 d1, vec2 d2, SDFNode n, uint nodeId)
	{
		return vec2(max(-d2.x,d1.x), nodeId);
	}
	
	void pModOffset( thread vec3 &p, vec3 offset);
	void pModOffset( thread vec3 &p, vec3 offset) {
		p -= offset;
	}
	
	void sppModOffset( thread vec3 &p, SDFNode n);
	void sppModOffset( thread vec3 &p, SDFNode n) {
		p -= vec3(n.floats[0],n.floats[1],n.floats[2]);
	}
	
// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
	float sppModPolar( thread vec2 &p, SDFNode n);
	float sppModPolar( thread vec2 &p, SDFNode n) {
	
		float repetitions = n.floats[0];
		float angle = 2*PI/repetitions;
		float a = fma(angle,0.5,atan2(p.y, p.x));
		float r = length(p);
		float c = floor(a/angle);
		
		a = fma(angle,-0.5,mod(a,angle));
		p = vec2(cos(a), sin(a))*r;
// For an odd number of repetitions, fix cell index of the cell in -x direction
// (cell index would be e.g. -5 and 5 in the two halves of the cell):
		if (abs(c) >= (repetitions/2)) c = abs(c);
		return c;
	}
	
	
//Static distance functions for scene
//Ferformance is non optimal, minimum number of distance
//functions should be processed here
	vec2 map( vec3 pos);
	vec2 map( vec3 pos)
	{
		vec3 origPos = pos;
        vec2 res;
        float cell;
        vec2 cells2;
        vec3 cells3;
        
        %@
        
		return res;
	}
	
	
	vec2 castRay( vec3 ro, vec3 rd);
	vec2 castRay( vec3 ro, vec3 rd)
	{
        const int maxIterations = 256;
		float tmin = 0.1;
		float tmax = 100.0;
		float precis = 0.000001;
		float t = tmin;
		float m = -1.0;
		int i = 0;
		for(; i<maxIterations; i++ )
		{
			vec2 res = map( fma(rd,t,ro));
			if( res.x<precis || t>tmax ) break;
			t += res.x;
			m = res.y;
		}

        if( i == maxIterations) m=-1.0;
		return vec2( t, m );
	}

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
            vec2 res = map( fma(rd,t,ro));
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



	float softshadow( vec3 ro, vec3 rd, float mint, float tmax);
	float softshadow( vec3 ro, vec3 rd, float mint, float tmax)
	{
		float res = 1.0;
		float t = mint;
		for( int i=0; i<16; i++ )
		{
			float h = map( fma(rd,t,ro)).x;
			res = min( res, 8.0*h/t );
			t += clamp( h, 0.02, 0.10 );
			if( h<0.001 || t>tmax ) break;
		}
		return clamp( res, 0.0, 1.0 );
		
	}
	
	vec3 calcNormal( vec3 pos);
	vec3 calcNormal( vec3 pos)
	{
		vec3 eps = vec3( 0.001, 0.0, 0.0 );
		vec3 nor = vec3(
		        map(pos+eps.xyy).x - map(pos-eps.xyy).x,
		        map(pos+eps.yxy).x - map(pos-eps.yxy).x,
		        map(pos+eps.yyx).x - map(pos-eps.yyx).x );
		return normalize(nor);
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
	float calcAO( vec3 pos, vec3 nor);
	float calcAO( vec3 pos, vec3 nor)
	{
		float occ = 0.0;
		float sca = 1.0;
		for( int i=0; i<5; i++ )
		{
			float hr = fma(0.03,float(i),0.01);
			vec3 aopos =  fma(nor, hr, pos);
			float dd = map( aopos).x;
			occ += -(dd-hr)*sca;
			sca *= 0.95;
		}
		return clamp( fma(-3.0,occ,1.0 ), 0.0, 1.0 );
	}
	
	vec3 render( vec3 ro, vec3 rd, device SDFScene &scene);
	vec3 render( vec3 ro, vec3 rd, device SDFScene &scene)
	{
	
//Set default background colour
		vec3 col = fma(rd.y,0.8,vec3(0.7, 0.6, 0.7));
		
		vec2 res = castRay(ro,rd);

        //vec2 res = castRayRelaxed(ro,rd);

		
		if( res.y>-0.5 )
		{
		
			float t = res.x;
			int m = scene.nodes[int(res.y)].materialId;
			
//Position of the ray hit
			vec3 pos = fma(t,rd,ro);
			
//Surface normal at the ray hit point
			vec3 nor = calcNormal( pos);
			
			vec3 ref = reflect( rd, nor );
			
// material
			col = vec3(scene.materials[m].red, scene.materials[m].green, scene.materials[m].blue);
            //col = vec3(0.5, 0.7, 0.8);
            
// lighitng
			float occ = calcAO( pos, nor);
			
//Light direction?
			vec3 lig = normalize( vec3(-0.6, 0.7, -0.5) );
			
//Ambient
			float amb = clamp( fma(0.5,nor.y,0.5), 0.0, 1.0 );
			
//Diffuse
			float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
			float bac = clamp( dot( nor, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-pos.y,0.0,1.0);
//Sky dome?
			float dom = smoothstep( -0.1, 0.1, ref.y );
			
			float fre = pow( clamp(1.0+dot(nor,rd),0.0,1.0), 2.0 );
			
//Specular
			float spe = pow(clamp( dot( ref, lig ), 0.0, 1.0 ),16.0);
			
			dif *= softshadow( pos, lig, 0.02, 2.5);
			dom *= softshadow( pos, ref, 0.02, 2.5);
			
			vec3 lin = vec3(0.0);
			lin += 1.20*dif*vec3(1.00,0.85,0.55);
			lin += 1.20*spe*vec3(1.00,0.85,0.55)*dif;
			lin += 0.20*amb*vec3(0.50,0.70,1.00)*occ;
			lin += 0.30*dom*vec3(0.50,0.70,1.00)*occ;
			lin += 0.30*bac*vec3(0.25,0.25,0.25)*occ;
			lin += 0.40*fre*vec3(1.00,1.00,1.00)*occ;
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
	
	
	kernel void static_signed_distance_bounds(
	        texture2d<float, access::write> outTexture [[texture(0)]],
	        device SDFScene &scene [[buffer(0)]],
	        uint2 gid [[thread_position_in_grid]])
	{
		vec2 fragCoord = {(float)gid[0], (float)gid[1]};
		
		vec2 iResolution = vec2 (outTexture.get_width(),outTexture.get_height());
		vec2 q = fragCoord.xy/iResolution.xy;
		vec2 p = fma(2.0,q,-1.0);
		p.x *= iResolution.x/iResolution.y;
		
		vec3 rd = scene.cameraTransform * normalize( vec3(p.xy,2.0) );
		
		vec3 col = render( scene.rayOrigin, rd,scene);
		
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


    kernel void static_signed_distance_bounds_hit_test(
        constant SDFScene &scene [[buffer(0)]],
        constant SDFTouch &touch [[buffer(1)]],
        device SDFHit &hit [[buffer(2)]],
        uint2 gid [[thread_position_in_grid]])
    {

        vec2 fragCoord = {(float)touch.touchPointX, (float)touch.touchPointY};
        vec2 iResolution = vec2(touch.viewWidth,touch.viewHeight);

        vec2 q = fragCoord.xy/iResolution.xy;
        vec2 p = fma(2.0,q,-1.0);
        p.x *= iResolution.x/iResolution.y;

        vec3 rd = scene.cameraTransform * normalize( vec3(p.xy,2.0) );

        vec3 ro = scene.rayOrigin;
        vec2 res = castRay(ro,rd);

//vec2 res = vec2(1.0, -1.0);

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
