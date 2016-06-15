# Spatial Photonics (SP)
A Signed Distance Bounds dynamic 3D rendering engine using Apple's Metal compute pipeline

Inspired by IQ's Signed Distance Bounds [demo on shadertoy](https://www.shadertoy.com/view/Xds3zN)

And the [hg_sdf](http://mercury.sexy/hg_sdf/) Signed distance library by mercury

## Intro

SP is a 3d rendering engine initially focused on immersive 3D User Interfaces for use in VR, AR and MR.

Rather than use a triangle mesh based renderer SP uses Signed distance function (SDF) renderer.

SDF renderers use mathmatical functions to define serfaces, they do not use pre-created model assets so they are more flexible.



## SP Features

Allows a scene to be dynamically created and updated

Scenes are continuousy compiled in a background thread and replace the dynamic scene as soon as possible

Supports picking using the same Metal shader as the view renderer 

Supports iOS, tvOS and OSX




