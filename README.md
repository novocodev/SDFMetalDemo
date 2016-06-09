# spatial-photonics (SP)
A Signed Distance Bounds 3D renderer using Apple's Metal compute pipeline

Inspired by IQ's Signed Distance Bounds [demo on shadertoy](https://www.shadertoy.com/view/Xds3zN)

And the [hg_sdf](http://mercury.sexy/hg_sdf/) Signed distance library by mercury

## Intro

Signed Distance Bounds demos are written as static GPU shaders, uniforms can be passed in to modify some parameters.
By using static code shader compilers can apply maximum optimisation, but are limited in usability as general 3D renderes.

## Features

SP allows a scene to be dynamically created and updated

Scenes are continuousy compiled in a background thread and replace the dynamic scene as soon as possible

Supports iOS, tvOS and OSX




