# SDF Metal Demo
A Signed Distance Function Demo using Apple's Metal compute shaders.

## Intro

SDF renderers use mathmatical functions to define surfaces, they do not use pre-created model assets.

## SDF Refereneces

IQ's Signed Distance Bounds [demo on shadertoy](https://www.shadertoy.com/view/Xds3zN)

And the [hg_sdf](http://mercury.sexy/hg_sdf/) Signed distance library by mercury

Wikipedias [SDF page](https://en.wikipedia.org/wiki/Signed_distance_function)

## Features

This demo exhibits some interesting features.

1. Resolution variable rendering

The View controller tracks rendered frames per second and adjusts the view content scale dynamically to maintain a target frame rate. Typically 15FPS across desktop and mobile devices will give acceptable resolution.

2. Shader JIT compilation

To support dynamic shader content the shader is re-compiled inflight when the structure of a scene changes. This ensures that the shader is always optimised for maximum rendering FPS.


## Demo scenes

When the Demo app is launched the following scenes will be displayed for 10 seconds each

 1. 3D Space Warping
 
SDF can warp space to generate multiple instances of an object, this is really cheap as it uses modulus to acheive this. The demo has an infinaite number of cubes with spherical holes, the limits of the scene are controlled by the maximum distance renderd by the camera.

 2. Polar Space Warping
 A demo of space warping using polar coordinates rather then linear coordinates. A single object (cube minus sphere) is repeated 6 times around an origin.

 3. Blob
 
Demonstrates objects with non planar surfaces.

 4. Primitives
 
Demonstrates the wide range of SDF's supported, initially a port (in progress) of IQ's Signed Distance Bounds [demo on shadertoy](https://www.shadertoy.com/view/Xds3zN), will be updated as more functions are added).

## Known Issues

When a shader is re-compiled previous versions are not garbage collected on iOS.

Rendering is too slow to consistently support full resolution rendering on device screens.

## License

[Apache License Version 2.0, January 2004](http://www.apache.org/licenses/)
