# SDF Metal Demo
A Signed Distance Function Demo using Apple's Metal compute shaders.

## Intro

SDF shaders use mathmatical functions to define object surfaces, they do not use pre-created model assets. SDF shaders trivially support Constructive solid geometry to generate complex objects by combining simple reometric primitives.

## SDF Refereneces

IQ's Signed Distance Bounds [demo on shadertoy](https://www.shadertoy.com/view/Xds3zN)

And the [hg_sdf](http://mercury.sexy/hg_sdf/) Signed distance library by mercury

Wikipedia's [SDF page](https://en.wikipedia.org/wiki/Signed_distance_function)

## Features

This demo includes some interesting features.

1. Resolution variable rendering

 The View controller tracks rendered frames per second and adjusts the view content scale dynamically to maintain a target frame rate. Typically 15FPS across desktop and mobile devices will give acceptable resolution.

2. Shader JIT compilation

 To support dynamic shader content the shader is re-compiled inflight when the structure of a scene changes. The metal Shader compiler  aggressively optimises the shader for maximum rendering FPS.

3. Shader based picking

 The same shader is used to pick scene objects in response to touch or mouse events, picking uses exactly the same model state as the last frame rendered, giving perfect picking accuracy.

## Demo scenes

When the Demo app is launched the following scenes will be displayed for 10 seconds each

 1. 3D Space Warping
 
 SDF can fold space to generate infinite instances of an object, this is very cheap as it uses the modulus function on the projected light ray to acheive this. The number of visible instances in the scene is only limited by the cameras far clipping plane.

![Alt text](/SDFMetalDemoScene1.png?raw=true "3D Space Warping")

 2. Polar Space Warping
 
 A demo of space folding using polar coordinates rather than linear coordinates. A single complex object (cube minus sphere) is repeated 6 times around an origin.

![Alt text](/SDFMetalDemoScene2.png?raw=true "Polar Space Warping")

 3. Blob
 
 Demonstrates an object with non planar surfaces.

![Alt text](/SDFMetalDemoScene3.png?raw=true "The Blob")

 4. Primitives
 
 Demonstrates the range of supported SDF's, this is a port (in progress) of IQ's Signed Distance Bounds [demo on shadertoy](https://www.shadertoy.com/view/Xds3zN), this demo will continue to be updated as more functions are supported.

![Alt text](/SDFMetalDemoScene4.png?raw=true "Primitives")

## Known Issues

When a shader is re-compiled inflight in iOS, previous versions are not garbage collected.

The shader is too slow to support full resolution rendering on device screens, the shader has not been optimised for Metal yet.

## License

[Apache License Version 2.0, January 2004](http://www.apache.org/licenses/)
