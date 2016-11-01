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
	typedef float4x4 mat4x4;

#define TAU (2*M_PI_F)
#define PHI 1.618033988749894848204586834

	float sgn(thread float const &x);
	float sgn(thread float const &x) {
		return (x<0) ? -1 : 1;
	}
	
	vec2 sgn2(thread vec2 const &v);
	vec2 sgn2(thread vec2 const &v) {
		return vec2((v.x<0) ? -1 : 1, (v.y<0) ? -1 : 1);
	}
	
	float square (thread float const &x);
	float square (thread float const &x) {
		return x*x;
	}
	
	vec2 square (thread vec2 const &x);
	vec2 square (thread vec2 const &x) {
		return x*x;
	}
	
	vec3 square (thread vec3 const &x);
	vec3 square (thread vec3 const &x) {
		return x*x;
	}
	
	float lengthSqr(thread vec3 const &x);
	float lengthSqr(thread vec3 const &x) {
		return dot(x, x);
	}

	float vmax(thread vec2 const &v);
	float vmax(thread vec2 const &v) {
		return max(v.x, v.y);
	}
	
	float vmax(thread vec3 const &v);
	float vmax(thread vec3 const &v) {
		return max(max(v.x, v.y), v.z);
	}
	
	float vmax(thread vec4 const &v);
	float vmax(thread vec4 const &v) {
		return max(max(v.x, v.y), max(v.z, v.w));
	}
	
	float vmin(thread vec2 const &v);
	float vmin(thread vec2 const &v) {
		return min(v.x, v.y);
	}
	
	float vmin(thread vec3 const &v);
	float vmin(thread vec3 const &v) {
		return min(min(v.x, v.y), v.z);
	}
	
	float vmin(thread vec4 const &v);
	float vmin(thread vec4 const &v) {
		return min(min(v.x, v.y), min(v.z, v.w));
	}

	float fSphere(thread vec3 const &p, thread float const &r);
	float fSphere(thread vec3 const &p, thread float const &r) {
		return length(p) - r;
	}

	float fPlane(thread vec3 const &p, thread vec3 const &n, thread float const &distanceFromOrigin);
	float fPlane(thread vec3 const &p, thread vec3 const &n, thread float const &distanceFromOrigin) {
		return dot(p, n) + distanceFromOrigin;
	}

	float fBoxCheap(thread vec3 const &p, thread vec3 const &b);
	float fBoxCheap(thread vec3 const &p, thread vec3 const &b) {
		return vmax(abs(p) - b);
	}

	float fBlob(thread vec3 const &p);
	float fBlob(thread vec3 const &p) {
		vec3 bp = abs(p);
		if (bp.x < max(bp.y, bp.z)) bp = bp.yzx;
		if (bp.x < max(bp.y, bp.z)) bp = bp.yzx;
		float b = max(max(max(
		                          dot(bp, normalize(vec3(1, 1, 1))),
		                          dot(bp.xz, normalize(vec2(PHI+1, 1)))),
		                  dot(bp.yx, normalize(vec2(1, PHI)))),
		              dot(bp.xz, normalize(vec2(1, PHI))));
		float l = length(bp);
		return l - 1.5 - 0.2 * (1.5 / 2)* cos(min(sqrt(1.01 - b / l)*(M_PI_F / 0.25), M_PI_F));
	}

	float fCylinder(thread vec3 const &p, thread float const &r, thread float const &height);
	float fCylinder(thread vec3 const &p, thread float const &r, thread float const &height) {
		float d = length(p.xz) - r;
		d = max(d, abs(p.y) - height);
		return d;
	}

	float fCapsule(thread vec3 const &p, thread float const &r, thread float const &c);
	float fCapsule(thread vec3 const &p, thread float const &r, thread float const &c) {
		return mix(length(p.xz) - r, length(vec3(p.x, abs(p.y) - c, p.z)) - r, step(c, abs(p.y)));
	}

	float fLineSegment(thread vec3 const &p, thread vec3 const &a, thread vec3 const &b);
	float fLineSegment(thread vec3 const &p, thread vec3 const &a, thread vec3 const &b) {
		vec3 ab = b - a;
		float t = clamp(dot(p - a, ab) / dot(ab, ab),0.0,1.0);
		return length(fma(ab,t,a) - p);
	}

	float fCapsule(thread vec3 const &p, thread vec3 const &a, thread vec3 const &b, thread float const &r);
	float fCapsule(thread vec3 const &p, thread vec3 const &a, thread vec3 const &b, thread float const &r) {
		return fLineSegment(p, a, b) - r;
	}

	float fTorus(thread vec3 const &p, thread float const &smallRadius, thread float const &largeRadius);
	float fTorus(thread vec3 const &p, thread float const &smallRadius, thread float const &largeRadius) {
		return length(vec2(length(p.xz) - largeRadius, p.y)) - smallRadius;
	}

	float fHexagonCircumcircle(thread vec3 const &p, thread vec2 const &h);
	float fHexagonCircumcircle(thread vec3 const &p, thread vec2 const &h) {
		vec3 q = abs(p);
		return max(q.y - h.y, max(fma(q.x,0.86602540378444, q.z*0.5), q.z) - h.x);
	}


	float fHexagonIncircle(thread vec3 const &p, thread vec2 const &h);
	float fHexagonIncircle(thread vec3 const &p, thread vec2 const &h) {
		return fHexagonCircumcircle(p, vec2(h.x*0.86602540378444, h.y));
	}

	float fCone(thread vec3 const &p, thread float const &radius, thread float const &height);
	float fCone(thread vec3 const &p, thread float const &radius, thread float const &height) {
		vec2 q = vec2(length(p.xz), p.y);
		vec2 tip = q - vec2(0, height);
		vec2 mantleDir = normalize(vec2(height, radius));
		float mantle = dot(tip, mantleDir);
		float d = max(mantle, -q.y);
		float projected = dot(tip, vec2(mantleDir.y, -mantleDir.x));

		if ((q.y > height) && (projected < 0)) {
			d = max(d, length(tip));
		}

		if ((q.x > radius) && (projected > length(vec2(height, radius)))) {
			d = max(d, length(q - vec2(radius, 0)));
		}
		return d;
	}

float mod(thread float const &x, thread float const &y);
float mod(thread float const &x, thread float const &y)
{
return x - y * floor(x/y);
}

vec2 mod(thread vec2 const &x, thread vec2 const &y);
vec2 mod(thread vec2 const &x, thread vec2 const &y)
{
return x - y * floor(x/y);
}

vec3 mod(thread vec3 const &x, thread vec3 const &y);
vec3 mod(thread vec3 const &x, thread vec3 const &y)
{
    return x - y * floor(x/y);
}

    void pR(thread vec3 &p, thread int const &axis1, thread int const &axis2, thread float const &a);
    void pR(thread vec3 &p, thread int const &axis1, thread int const &axis2, thread float const &a) {
        vec2 v = cos(a)*vec2(p[axis1],p[axis2]) + sin(a)*vec2(p[axis2], -p[axis1]);
        p[axis1] = v.x;
        p[axis2] = v.y;
    }

	vec3 pModPolar(thread vec3 &p, thread int const &axis1, thread int const &axis2, thread float const &repetitions);
	vec3 pModPolar(thread vec3 &p, thread int const &axis1, thread int const &axis2, thread float const &repetitions) {
		float angle = TAU/repetitions;
		float a = atan2(p[axis2], p[axis1]) + angle/2.;
		float r = length(vec2(p[axis1],p[axis2]));
		float c = floor(a/angle);
		a = mod(a,angle) - angle/2.;
		vec2 v = vec2(cos(a), sin(a))*r;
		p[axis1] = v.x;
		p[axis2] = v.y;
		if (abs(c) >= (repetitions/2)) c = abs(c);
		return vec3(c,0,0);
	}

	vec3 pMod3(thread vec3 &p, thread vec3 const &size);
	vec3 pMod3(thread vec3 &p, thread vec3 const &size) {
        vec3 halfsize = size*0.5;
		vec3 c = floor((p + halfsize )/size);
		p = mod(fma(size,0.5,p), size) - size*0.5;
		return c;
	}

	float fEllipsoid( thread vec3 const &p, thread vec3 const &r );
	float fEllipsoid( thread vec3 const &p, thread vec3 const &r )
	{
		return (length( p/r ) - 1.0) * min(min(r.x,r.y),r.z);
	}
	
	float fRoundBox( thread vec3 const &p, thread vec3 const &b, thread float const &r );
	float fRoundBox( thread vec3 const &p, thread vec3 const &b, thread float const &r )
	{
		return length(max(abs(p)-b,0.0))-r;
	}
	
	float length2( thread vec2 const &p );
	float length2( thread vec2 const &p )
	{
		return sqrt( p.x*p.x + p.y*p.y );
	}
	
	float length6( thread vec2 const &p );
	float length6( thread vec2 const &p )
	{
		vec2 lp = p*p*p;
        lp = lp*lp;
		return pow( lp.x + lp.y, 1.0/6.0 );
	}
	
	float length8( thread vec2 const &p );
	float length8( thread vec2 const &p )
	{
		vec2 lp = p*p;
        lp = lp*lp;
        lp = lp*lp;
		return pow( lp.x + lp.y, 1.0/8.0 );
	}
	
	float fTorus82( thread vec3 const &p, thread vec2 const &t );
	float fTorus82( thread vec3 const &p, thread vec2 const &t )
	{
		vec2 q = vec2(length2(p.xz)-t.x,p.y);
		return length8(q)-t.y;
	}
	
	float fTorus88( thread vec3 const &p, thread vec2 const &t );
	float fTorus88( thread vec3 const &p, thread vec2 const &t )
	{
		vec2 q = vec2(length8(p.xz)-t.x,p.y);
		return length8(q)-t.y;
	}
	
	float fCylinder6( thread vec3 const &p, thread vec2 const &h );
	float fCylinder6( thread vec3 const &p, thread vec2 const &h )
	{
		return max( length6(p.xz)-h.x, abs(p.y)-h.y );
	}
	
	float pS( thread float const &d1, thread float const &d2 );
	float pS( thread float const &d1, thread float const &d2 )
	{
		return max(-d2,d1);
	}
	
	vec3 pRep( thread vec3 const &p, thread vec3 const &c );
	vec3 pRep( thread vec3 const &p, thread vec3 const &c )
	{
		return fma(-0.5,c,mod(p,c));
	}
	
	vec3 pTwist( thread vec3 const &p );
	vec3 pTwist( thread vec3 const &p )
	{
		float c = cos(fma(10.0,p.y,10.0));
		float s = sin(fma(10.0,p.y,10.0));
		mat2 m = mat2(vec2(c,-s),vec2(s,c));
		return vec3(m*p.xz,p.y);
	}

	vec3 pU( thread vec3 const &d1, thread vec3 const &d2 );
	vec3 pU( thread vec3 const &d1, thread vec3 const &d2 )
	{
		return (d1.x<d2.x) ? d1 : d2;
	}
	

vec3 pS( thread vec3 const &d1, thread vec3 const &d2);
vec3 pS( thread vec3 const &d1, thread vec3 const &d2)
{
    return (-d2.x>d1.x) ? vec3(-d2.x, d2.yz) : d1;
}
	
	float fTriPrism( thread vec3 const &p, thread vec2 const &h );
	float fTriPrism( thread vec3 const &p, thread vec2 const &h )
	{
		vec3 q = abs(p);
		return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
	}

	float fConeSection( thread vec3 const &p, thread float const &h, thread float const &r1, thread float const &r2 );
	float fConeSection( thread vec3 const &p, thread float const &h, thread float const &r1, thread float const &r2 )
	{
		float d1 = -p.y - h;
		float q = p.y - h;
		float si = 0.5*(r1-r2)/h;
		float d2 = max( sqrt( dot(p.xz,p.xz)*(1.0-si*si)) + q*si - r2, q );
		return length(max(vec2(d1,d2),0.0)) + min(max(d1,d2), 0.);
	}
/*
    struct SDFMaterial {
        float3 ambient;
        float3 diffuse;
        float3 specular;
        float3 reflect;
        float3 bac;
        float3 frensel;
    };
*/
struct SDFMaterial {
half3 ambient;
half3 diffuse;
half3 specular;
half3 reflect;
half3 bac;
half3 frensel;
};

struct SDFMaterialFloat {
float3 ambient;
float3 diffuse;
float3 specular;
float3 reflect;
float3 bac;
float3 frensel;
};


    struct SDFUniforms {
        float modelVersion;
        mat3 cameraTransform;
        vec3 rayOrigin;
    };

    constant const int kMaxIterations = 256;
    constant const float kTmin = 0.1;
    constant const float kTmax = 100.0;
    constant const float kPrecis = 0.000001;

    constant  half3 mat0ambient   [[function_constant(0)]];
    constant  half3 mat0diffuse   [[function_constant(1)]];
    constant  half3 mat0specular  [[function_constant(2)]];
    constant  half3 mat0reflect   [[function_constant(3)]];
    constant  half3 mat0bac       [[function_constant(4)]];
    constant  half3 mat0frensel   [[function_constant(5)]];

    constant  half3 mat1ambient   [[function_constant(6)]];
    constant  half3 mat1diffuse   [[function_constant(7)]];
    constant  half3 mat1specular  [[function_constant(8)]];
    constant  half3 mat1reflect   [[function_constant(9)]];
    constant  half3 mat1bac       [[function_constant(10)]];
    constant  half3 mat1frensel   [[function_constant(11)]];

    constant  half3 mat2ambient   [[function_constant(12)]];
    constant  half3 mat2diffuse   [[function_constant(13)]];
    constant  half3 mat2specular  [[function_constant(14)]];
    constant  half3 mat2reflect   [[function_constant(15)]];
    constant  half3 mat2bac       [[function_constant(16)]];
    constant  half3 mat2frensel   [[function_constant(17)]];

    constant  half3 mat3ambient   [[function_constant(18)]];
    constant  half3 mat3diffuse   [[function_constant(19)]];
    constant  half3 mat3specular  [[function_constant(20)]];
    constant  half3 mat3reflect   [[function_constant(21)]];
    constant  half3 mat3bac       [[function_constant(22)]];
    constant  half3 mat3frensel   [[function_constant(23)]];

/*
constant const SDFMaterial materialRed = {
mat0ambient,
mat0diffuse,
mat0specular,
mat0reflect,
mat0bac,
mat0frensel
};

constant const SDFMaterial materialGreen = {
mat1ambient,
mat1diffuse,
mat1specular,
mat1reflect,
mat1bac,
mat1frensel
};

constant const SDFMaterial materialBlue = {
mat2ambient,
mat2diffuse,
mat2specular,
mat2reflect,
mat2bac,
mat2frensel
};

constant const SDFMaterial materialYellow = {
mat3ambient,
mat3diffuse,
mat3specular,
mat3reflect,
mat3bac,
mat3frensel
};


    constant float3 materials2[1] = {
        mat0ambient
    };
*/

    constant const SDFMaterialFloat materials[%i] = {
        %@
    };


    void pModOffset( thread vec3 &p, vec3 offset);
    void pModOffset( thread vec3 &p, vec3 offset) {
        p -= offset;
    }

	//vec3 map( thread vec3 const &pos);
	//vec3 map( thread vec3 const &pos)
    float3x3 map( thread vec3 const &pos);
    float3x3 map( thread vec3 const &pos)
	{
        vec3 tempPos = pos;
        vec3 res = vec3(0);
        vec3 cells = vec3(0);
        vec3 eps = vec3( 0.001, 0.0, 0.0 );
        vec3 lastHitNormal;
        vec3 lastHitVector;

        cells = pMod3(tempPos,vec3(0.250000,0.250000,0.250000));
        vec3 res1 = vec3(fSphere(tempPos, 0.062500),1,0.000000);

        //If this is a surface hit then savw the surface normal
        if (res1.x < kPrecis) {
            lastHitVector = tempPos;
            lastHitNormal = normalize(vec3(
                fSphere((tempPos+eps.xyy), 0.062500)
                - fSphere((tempPos-eps.xyy), 0.062500),
                fSphere((tempPos+eps.yxy), 0.062500)
                - fSphere((tempPos-eps.yxy), 0.062500),
                fSphere((tempPos+eps.yyx), 0.062500)
                - fSphere((tempPos-eps.yyx), 0.062500)
            ));
        }
        vec3 res2 = vec3(fBoxCheap(tempPos, vec3(0.053000,0.053000,0.053000)),2,1.000000);

        //If this is a surface hit then savw the surface normal
        if (res2.x < kPrecis) {
            lastHitVector = tempPos;
            lastHitNormal = normalize(vec3(
                fBoxCheap((tempPos+eps.xyy), vec3(0.053000,0.053000,0.053000))
                - fBoxCheap((tempPos-eps.xyy), vec3(0.053000,0.053000,0.053000)),
                fBoxCheap((tempPos+eps.yxy), vec3(0.053000,0.053000,0.053000))
                - fBoxCheap((tempPos-eps.yxy), vec3(0.053000,0.053000,0.053000)),
                fBoxCheap((tempPos+eps.yyx), vec3(0.053000,0.053000,0.053000))
                - fBoxCheap((tempPos-eps.yyx), vec3(0.053000,0.053000,0.053000))
            ));
        }

        res = pS(res2,res1);

        tempPos = pos;
        cells = vec3(0.0);
        vec3 res5 = vec3(fSphere(tempPos, 0.125000),5,0.000000);

        //If this is a surface hit then savw the surface normal
        if (res5.x < kPrecis) {
            lastHitVector = tempPos;
            lastHitNormal = normalize(vec3(
                fSphere((tempPos+eps.xyy), 0.125000)
                - fSphere((tempPos-eps.xyy), 0.125000),
                fSphere((tempPos+eps.yxy), 0.125000)
                - fSphere((tempPos-eps.yxy), 0.125000),
                fSphere((tempPos+eps.yyx), 0.125000)
                - fSphere((tempPos-eps.yyx), 0.125000)
            ));
        }

        res = pU(res5,res);

        pModOffset(tempPos, vec3(-0.500000,-0.650000,-0.500000));
        vec3 res8 = vec3(fSphere(tempPos, 0.075000),8,1.000000);

        //If this is a surface hit then savw the surface normal
        if (res8.x < kPrecis) {
            lastHitVector = tempPos;
            lastHitNormal = normalize(vec3(
                fSphere((tempPos+eps.xyy), 0.075000)
                - fSphere((tempPos-eps.xyy), 0.075000),
                fSphere((tempPos+eps.yxy), 0.075000)
                - fSphere((tempPos-eps.yxy), 0.075000),
                fSphere((tempPos+eps.yyx), 0.075000)
                - fSphere((tempPos-eps.yyx), 0.075000)
            ));
        }

        res = pU(res8,res);

        cells = cells;
        return float3x3(res, lastHitNormal, lastHitVector);
	}

    half3 maph( thread half3 const &pos);
    half3 maph( thread half3 const &pos)
    {
        return half3(map(vec3(pos))[0]);
    }


	float3x3 castRay( thread vec3 const &ro, thread vec3 const &rd);
	float3x3 castRay( thread vec3 const &ro, thread vec3 const &rd)
	{
		float t = kTmin;
		float m = -1.0;
        float o = -1.0;
		int i = 0;
        vec3 res = 0.0;
        float3x3 composite;
		for(; i<kMaxIterations; i++ )
		{
			composite = map( fma(rd,t,ro));
            res = composite[0];
            if( res.x<kPrecis ) {
                o = res.y;
                m = res.z;
                break;
            }
            if(t>kTmax ) break;
			t += res.x;

		}
		return float3x3(vec3( t, o, m ), composite[1], composite[2]);
	}


    half softshadow( thread vec3 const &ro, thread vec3 const &rd, thread float const &mint, thread float const &tmax);
    half softshadow( thread vec3 const &ro, thread vec3 const &rd, thread float const &mint, thread float const &tmax)
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

        return clamp( res/tmaxh, 0.0h, 1.0h );
    }

    half calcAO( thread vec3 const &pos, thread vec3 const &nor);
    half calcAO( thread vec3 const &pos, thread vec3 const &nor)
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

    half3 generateAmbientColour(thread vec3 const &normal, thread half3 const &textureParams);
    half3 generateAmbientColour(thread vec3 const &normal, thread half3 const &textureParams) {
        return half3(normalize(fabs(normal)));
    }

	half3 render(thread vec3 const &ro, thread vec3 const &rd, constant SDFUniforms &scene);
	half3 render(thread vec3 const &ro, thread vec3 const &rd, constant SDFUniforms &scene)
	{
        const SDFMaterial materials2[4] = {
            {
                mat0ambient,
                mat0diffuse,
                mat0specular,
                mat0reflect,
                mat0bac,
                mat0frensel
            },
            {
mat1ambient,
mat1diffuse,
mat1specular,
mat1reflect,
mat1bac,
mat1frensel
            },
            {
mat2ambient,
mat2diffuse,
mat2specular,
mat2reflect,
mat2bac,
mat2frensel
            },
            {
mat3ambient,
mat3diffuse,
mat3specular,
mat3reflect,
mat3bac,
mat3frensel
            }
        };

        half3 pixcolour = fma(rd.y,0.8,half3(0.7, 0.6, 0.7));
		float3x3 composite = castRay(ro,rd);
        vec3 res = composite[0];
		if( res.y>-0.5 )
		{
			half t = res.x;
            int m = res.z;
			vec3 pos = fma(t,rd,ro);
			//vec3 nor = calcNormal( pos);
            vec3 nor = composite[1];
            vec3 hitVec = composite[2];
			vec3 ref = reflect( rd, nor );
            //col = vec3(materials[m].ambient[0], materials[m].ambient[1], materials[m].ambient[2]);
			float occ = float(calcAO( pos, nor));

			half3 lig = normalize( half3(1.0, 1.0, 1.0) );
            //half3 lAmb = half3( 0.4, 0.4, 0.4 );
            half3 lAmb = half3( 1.0, 1.0, 1.0 );
            half3 lDif = max(0.0h,dot( half3(nor.x,nor.y,nor.z), lig )) * half3(0.6,0.6,0.6);
            half3 lSpe = pow(clamp( dot( half3(ref.x,ref.y,ref.z), lig ), 0.0h, 1.0h ),16.0h) * half3(0.8,0.8,0.8);

            //pixcolour = lAmb * materials[m].ambient;
            //pixcolour += lDif * materials[m].diffuse * softshadow( pos, lig, 0.02, 4.5) * occ;
            //pixcolour += lSpe * materials[m].specular;
            //pixcolour += materials[m].reflect * materials[int(res.z)].ambient * softshadow( pos, ref, 0.02, 4.5);

            //pixcolour = lAmb * materials2[m].ambient;
            pixcolour = lAmb * generateAmbientColour(hitVec,materials2[m].ambient);
            //Softshadow is called with light source vactor to calculate shadow
            pixcolour += lDif * materials2[m].diffuse * softshadow( pos, vec3(1.0, 1.0, 1.0), 0.02, 4.5) * occ;
            pixcolour += lSpe * materials2[m].specular;
            //Softshadow is called with reflected vactor to calculate reflection
            pixcolour += materials2[m].reflect * materials2[int(ref.z)].ambient * softshadow( pos, ref, 0.02, 4.5);


            //pixcolour = lAmb * mat0ambient;
            //pixcolour += lDif * mat0diffuse * softshadow( pos, lig, 0.02, 4.5) * occ;
            //pixcolour += lSpe * mat0specular;
            //pixcolour += mat0reflect * materials[int(res.z)].ambient * softshadow( pos, ref, 0.02, 4.5);

			pixcolour = mix( pixcolour, half3(0.8,0.9,1.0), 1.0h-exp( -0.002h*t*t ) );
		}
		return half3( clamp(pixcolour,0.0h,1.0h) );
	}



	kernel void signed_distance_bounds(
	        texture2d<float, access::write> outTexture [[texture(0)]],
            constant SDFUniforms const &uniforms [[buffer(0)]],
	        uint2 gid [[thread_position_in_grid]])
	{
		vec2 fragCoord = {(float)gid[0], (float)gid[1]};
		
		vec2 iResolution = vec2 (outTexture.get_width(),outTexture.get_height());
		vec2 q = fragCoord.xy/iResolution.xy;
		vec2 p = fma(2.0,q,-1.0);
		p.x *= iResolution.x/iResolution.y;
		
		vec3 rd = uniforms.cameraTransform * normalize( vec3(p.xy,2.0) );

        vec3 ro = uniforms.rayOrigin;
		half3 col = render( ro, rd, uniforms);
		
		col = pow( col, half3(0.4545) );
		
		vec4 fragColor=vec4( col.x, col.y, col.z, 1.0 );
		
		outTexture.write(fragColor, gid);
	}

    struct SDFTouch {
        uint touchPointX;
        uint touchPointY;
    };

    struct Touches {
        float viewWidth;
        float viewHeight;
        SDFTouch touches[32];
    };

    struct SDFHit {
        bool  isHit;
        float hitPointX;
        float hitPointY;
        float hitPointZ;
        uint  hitNodeId;
    };

    struct Hits {
        SDFHit hits[32];
    };


    kernel void signed_distance_bounds_hit_test(
        constant SDFUniforms const &uniforms [[buffer(0)]],
        constant Touches const &touches [[buffer(1)]],
        device Hits &hits [[buffer(2)]],
        uint touchIndex [[thread_position_in_grid]])
    {
        vec2 fragCoord = {(float)touches.touches[touchIndex].touchPointX, (float)touches.touches[touchIndex].touchPointY};
        vec2 iResolution = vec2(touches.viewWidth,touches.viewHeight);

        vec2 q = fragCoord.xy/iResolution.xy;
        vec2 p = fma(2.0,q,-1.0);
        p.x *= iResolution.x/iResolution.y;

        vec3 rd = uniforms.cameraTransform * normalize( vec3(p.xy,2.0) );

        vec3 ro = uniforms.rayOrigin;
        float3x3 composite = castRay(ro,rd);
        vec3 res = composite[0];
        if(res.y < -0.5) {
            hits.hits[touchIndex].isHit = false;
        } else {
            hits.hits[touchIndex].isHit = true;
            hits.hits[touchIndex].hitPointX = res.x;
            hits.hits[touchIndex].hitNodeId = uint(res.y);
            //hits.hits[touchIndex].hitCoord = fma(res.x,rd,ro);
        }
    }

} //namespace primitives

#endif /* __PRIMITIVES_SAMPLER */
