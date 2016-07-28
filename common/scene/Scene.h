
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
    fLineSegmentType = 17,
    pUnionType = 18,
    pSubtractionType = 19,
    pModOffsetType = 20,
    pModRotateType = 21,
    pModPolarType = 22,
    pModResetType = 23,
    pMod3Type = 24
};

typedef struct SDFMaterial {
    vector_float3 ambient;
    vector_float3 diffuse;
    vector_float3 specular;
    vector_float3 reflect;
    vector_float3 bac;
    vector_float3 frensel;
} SDFMaterial;

typedef struct SDFNode {
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


typedef struct SDFTouch {
    uint touchPointX;
    uint touchPointY;
} SDFTouch;

typedef struct Touches {
    float viewWidth;
    float viewHeight;
    SDFTouch touches[32];
} Touches;

typedef struct SDFHit {
    bool  isHit;
    float hitPointX;
    float hitPointY;
    float hitPointZ;
    uint  hitNodeId;
} SDFHit;

typedef struct Hits {
    SDFHit hits[32];
} Hits;


@protocol SceneDelegate;

@interface Scene : NSObject

@property (nonatomic, readonly) float targetFramerate;
@property (nonatomic, readonly) BOOL supportsPicking;
@property (nonatomic, retain) id <SceneDelegate> delegate;


- (instancetype) initWithTargetFramerate:(float)tfr supportsPicking:(BOOL)supportsPicking;

- (void) setupScene: (SDFScene *)scene;
- (void) updateScene: (SDFScene *) scene atMediaTime:(float)mediaTime;

- (void) nodesSelected:(NSMutableArray <NSValue *> *)hits inScene:(SDFScene *)scene;

- (matrix_float3x3) setupCamera: (vector_float3 )origin target: (vector_float3)target rotation:(float) rotation;
@end


@protocol SceneDelegate <NSObject>
    - (void)sceneDidUpdate:(Scene *)scene;
@end

#endif /* Scene_h */
