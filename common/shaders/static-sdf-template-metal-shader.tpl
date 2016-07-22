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

    struct SDFMaterial {
        vector_float3 ambient;
        vector_float3 diffuse;
        vector_float3 specular;
        vector_float3 reflect;
        vector_float3 bac;
        vector_float3 frensel;
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

    constant SDFMaterial materials[%i] = {
        %@
    };

    void pModOffset( thread vec3 &p, vec3 offset);
    void pModOffset( thread vec3 &p, vec3 offset) {
        p -= offset;
    }

	vec3 map( thread vec3 const &pos);
	vec3 map( thread vec3 const &pos)
	{
        vec3 tempPos = pos;
        vec3 res = vec3(0);
        vec3 cells = vec3(0);

        %@

        cells = cells;
		return res;
	}

    half3 maph( thread half3 const &pos);
    half3 maph( thread half3 const &pos)
    {
        return half3(map(vec3(pos)));
    }

	vec3 castRay( thread vec3 const &ro, thread vec3 const &rd);
	vec3 castRay( thread vec3 const &ro, thread vec3 const &rd)
	{
		float t = kTmin;
		float m = -1.0;
        float o = -1.0;
		int i = 0;
        vec3 res = 0.0;
		for(; i<kMaxIterations; i++ )
		{
			res = map( fma(rd,t,ro));
            if( res.x<kPrecis ) {
                o = res.y;
                m = res.z;
                break;
            }
            if(t>kTmax ) break;
			t += res.x;

		}
		return vec3( t, o, m );
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

    vec3 calcNormal( thread vec3 const &pos);
    vec3 calcNormal( thread vec3 const &pos)
    {
        half3 posh = half3(pos);
        half3 eps = half3( 0.001h, 0.0h, 0.0h );
        half3 nor = half3(
            maph(posh+eps.xyy).x - maph(posh-eps.xyy).x,
            maph(posh+eps.yxy).x - maph(posh-eps.yxy).x,
            maph(posh+eps.yyx).x - maph(posh-eps.yyx).x );
        return normalize(vec3(nor));
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


	vec3 render(thread vec3 const &ro, thread vec3 const &rd, constant SDFUniforms &scene);
	vec3 render(thread vec3 const &ro, thread vec3 const &rd, constant SDFUniforms &scene)
	{
        vec3 pixcolour = fma(rd.y,0.8,vec3(0.7, 0.6, 0.7));
		vec3 res = castRay(ro,rd);

		if( res.y>-0.5 )
		{
			float t = res.x;
            int m = res.z;
			vec3 pos = fma(t,rd,ro);
			vec3 nor = calcNormal( pos);
			vec3 ref = reflect( rd, nor );
            //col = vec3(materials[m].ambient[0], materials[m].ambient[1], materials[m].ambient[2]);
			float occ = float(calcAO( pos, nor));

			vec3 lig = normalize( vec3(1.0, 1.0, 1.0) );
            vec3 lAmb = vec3( 0.4, 0.4, 0.4 );
            vec3 lDif = max(0.0,dot( nor, lig )) * vec3(0.6,0.6,0.6);
            vec3 lSpe = pow(clamp( dot( ref, lig ), 0.0, 1.0 ),16.0) * vec3(0.8,0.8,0.8);

            pixcolour = lAmb * materials[m].ambient;
            pixcolour += lDif * materials[m].diffuse * softshadow( pos, lig, 0.02, 4.5) * occ;
            pixcolour += lSpe * materials[m].specular;
            pixcolour += materials[m].reflect * materials[int(res.z)].ambient * softshadow( pos, ref, 0.02, 4.5);

			pixcolour = mix( pixcolour, vec3(0.8,0.9,1.0), 1.0-exp( -0.002*t*t ) );
		}
		return vec3( clamp(pixcolour,0.0,1.0) );
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
		vec3 col = render( ro, rd, uniforms);
		
		col = pow( col, vec3(0.4545) );
		
		vec4 fragColor=vec4( col, 1.0 );
		
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
        vec3 res = castRay(ro,rd);

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
