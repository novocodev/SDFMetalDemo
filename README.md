# SDF Metal Demo
A Signed Distance Function Demo using Apple's Metal compute shaders

## Intro

SP is a 3d rendering engine initially focused on immersive 3D User Interfaces for use in VR, AR and MR.

Rather than use a triangle mesh based renderer SP uses Signed distance function (SDF) renderer.

SDF renderers use mathmatical functions to define serfaces, they do not use pre-created model assets.

## SDF Refereneces

IQ's Signed Distance Bounds [demo on shadertoy](https://www.shadertoy.com/view/Xds3zN)

And the [hg_sdf](http://mercury.sexy/hg_sdf/) Signed distance library by mercury

Wikipedias [SDF page](https://en.wikipedia.org/wiki/Signed_distance_function)

## Known Issues

When a shader is re-compiled previous versions are not garbage collected on iOS

## License

