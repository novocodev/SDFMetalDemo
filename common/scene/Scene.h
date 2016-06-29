
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

typedef struct SDFMaterial {
    vector_float3 diffuse;
    vector_float3 specular;
    vector_float3 ambient;
    vector_float3 dome;
    vector_float3 bac;
    vector_float3 frensel;
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
    matrix_float3x3 cameraTransform;
    vector_float3 rayOrigin;
    uint materialCount;
    struct SDFMaterial materials[10];
    uint nodeCount;
    struct SDFNode nodes[60];
} SDFScene;


typedef struct SDFUniforms {
    float modelVersion;
    matrix_float3x3 cameraTransform;
    vector_float3 rayOrigin;
} SDFUniforms;

@protocol SceneDelegate;

@interface Scene : NSObject

@property (nonatomic, readonly) float targetFramerate;
@property (nonatomic, readonly) BOOL supportsPicking;
@property (nonatomic, retain) id <SceneDelegate> delegate;


- (instancetype) initWithTargetFramerate:(float)tfr supportsPicking:(BOOL)supportsPicking;

- (void) setupScene: (SDFScene *)scene;
- (void) updateScene: (SDFScene *) scene atMediaTime:(float)mediaTime;

- (void) nodeSelected:(uint) nodeId inScene:(SDFScene *)scene;

- (matrix_float3x3) setupCamera: (vector_float3 )origin target: (vector_float3)target rotation:(float) rotation;
@end


@protocol SceneDelegate <NSObject>
    - (void)sceneDidUpdate:(Scene *)scene;
@end

#endif /* Scene_h */
