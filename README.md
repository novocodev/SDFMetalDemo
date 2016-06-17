# Spatial Photonics (SP)
A Signed Distance Bounds dynamic 3D rendering engine using Apple's Metal compute pipeline

Inspired by IQ's Signed Distance Bounds [demo on shadertoy](https://www.shadertoy.com/view/Xds3zN)

And the [hg_sdf](http://mercury.sexy/hg_sdf/) Signed distance library by mercury

## Intro

SP is a 3d rendering engine initially focused on immersive 3D User Interfaces for use in VR, AR and MR.

Rather than use a triangle mesh based renderer SP uses Signed distance function (SDF) renderer.

SDF renderers use mathmatical functions to define serfaces, they do not use pre-created model assets so they are more flexible.



## Current Features

Supports dynamic scenes

Metal haders are re-compiled online in the background when structural changes to the scene occur

Supports picking using the same shader as the scene renderer

Comes with a simple demos

Works on iOS, tvOS and OSX

## Target Features

Support more geometric primitives

Better support for materials

Better shader performance

Support for animating object properties

Support for more camera projectsions

## Known Issues

When a shader is re-compiled previous versions are not garbage collected on iOS
