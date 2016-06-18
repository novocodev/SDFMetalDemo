
#ifndef Scene_h
#define Scene_h

@import simd;
@import Metal;


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
    fBlobType = 15,
    pUnionType = 16,
    pSubtractionType = 17,
    pModOffsetType = 18,
    pModPolarType = 19,
    pModResetType = 20,
    pMod3Type = 21
};

typedef struct SDFMaterial {
    float red;
    float green;
    float blue;
    float alpha;
} SDFMaterial;

typedef struct SDFNode {
    unsigned long functionHash;
    enum nodeType type;
    unsigned char flags;
    float materialId;
    matrix_float4x4 transform;
    int ints[32];
    float floats[32];
} SDFNode;

typedef struct SDFScene {
    float modelVersion;
    float deviceAttitudePitch;
    float deviceAttitudeRoll;
    float deviceAttitudeYaw;
    matrix_float3x3 cameraTransform;
    vector_float3 rayOrigin;
    unsigned int nodeCount;
    struct SDFNode nodes[60];
    struct SDFMaterial materials[10];
} SDFScene;

typedef struct SDFUniforms {
    float modelVersion;
    matrix_float3x3 cameraTransform;
    vector_float3 rayOrigin;
    uint nodeCount;
} SDFUniforms;

@protocol SceneDelegate;

@interface Scene : NSObject

@property (nonatomic, readonly) NSString *kernelName;
@property (nonatomic, readonly) float targetFramerate;
@property (nonatomic, readonly) BOOL supportsPicking;
@property (nonatomic, retain) id <SceneDelegate> delegate;


- (instancetype) initWithTargetFramerate:(float)tfr supportsPicking:(BOOL)supportsPicking;

- (void) setupScene: (SDFScene *)scene;
- (BOOL) updateScene: (SDFScene *) scene atMediaTime:(float)mediaTime;

- (void) nodeSelected:(uint) nodeId inScene:(SDFScene *)scene;

- (matrix_float3x3) setupCamera: (vector_float3 )origin target: (vector_float3)target rotation:(float) rotation;
@end


@protocol SceneDelegate <NSObject>
    - (void)sceneDidUpdate:(Scene *)scene;
@end

#endif /* Scene_h */
