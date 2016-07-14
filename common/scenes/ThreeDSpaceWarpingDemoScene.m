
#import "ThreeDSpaceWarpingDemoScene.h"

@implementation ThreeDSpaceWarpingDemoScene
{
    int updatecount;
}

- (instancetype) init {
	if (self = [super initWithTargetFramerate: 15 supportsPicking: true])
	{
        //Add custom setup here
	}
	return self;
}
    
    -(void) callDelegate{
        [self.delegate sceneDidUpdate:self];
    }

- (void) setupScene: (SDFScene *)scene {

	scene->modelVersion = 1.0; //Model version to allow shaders to barf if they are not compatible
    
    // camera
    vector_float3 origin = { -0.5+1.5*cos(0.0), 0.5, 0.5 + 1.5*sin(0.0) };

    vector_float3 target = { 0.0, 0.0, 0.0 };
    
    matrix_float3x3 camera = [self setupCamera:origin target: target rotation:M_PI];
    
    scene->cameraTransform = camera;
    scene->rayOrigin = origin;

	scene->nodeCount = 10;
	
    struct SDFMaterial materialRed = {
        {1.20,0.00,0.00},
        {1.20,1.02,0.66},
        {1.00,0.00,0.00},
        {0.15,0.21,0.30},
        {0.075,0.075,0.075},
        {0.40,0.40,0.40}
    };

    struct SDFMaterial materialGreen = {
        {0.00,1.00,0.00},
        {1.00,0.85,0.55},
        {0.00,1.00,0.00},
        {0.50,0.70,1.00},
        {0.25,0.25,0.25},
        {1.00,1.00,1.00}
    };

    struct SDFMaterial materialBlue = {
        {0.00,0.00,1.00},
        {1.00,0.85,0.55},
        {0.00,0.00,1.00},
        {0.50,0.70,1.00},
        {0.25,0.25,0.25},
        {1.00,1.00,1.00}
    };
	
    struct SDFMaterial materialYellow = {
        {1.00,1.00,0.00},
        {1.00,0.85,0.55},
        {1.00,1.00,0.00},
        {0.50,0.70,1.00},
        {0.25,0.25,0.25},
        {1.00,1.00,1.00}
    };
	
	scene->materials[0] = materialRed;
	scene->materials[1] = materialGreen;
	scene->materials[2] = materialBlue;
	scene->materials[3] = materialYellow;
    
    scene->materialCount = 4;
    
    struct SDFNode node0Mod3;
    node0Mod3.type = pMod3Type;
    node0Mod3.floats[0] = 0.25; // repetitions
    node0Mod3.floats[1] = 0.25; // repetitions
    node0Mod3.floats[2] = 0.25; // repetitions
    scene->nodes[0] = node0Mod3;
    
	struct SDFNode node0RedSphere;
	node0RedSphere.type = fSphereType;
	node0RedSphere.materialId = 0;
	node0RedSphere.floats[9] = 0.0625; // radius
	scene->nodes[1] = node0RedSphere;
	
	struct SDFNode node1GreenBoxCheap;
	node1GreenBoxCheap.type = fBoxCheapType;
	node1GreenBoxCheap.materialId = 1;
	node1GreenBoxCheap.floats[9] = 0.053; // x dim
	node1GreenBoxCheap.floats[10] = 0.053; // y dim
	node1GreenBoxCheap.floats[11] = 0.053; // z dim
	scene->nodes[2] = node1GreenBoxCheap;
	
	struct SDFNode node2Subtraction;
	node2Subtraction.type = pSubtractionType;
	node2Subtraction.materialId = 3;
	scene->nodes[3] = node2Subtraction;
	
	struct SDFNode node4ModReset;
	node4ModReset.type = pModResetType;
	scene->nodes[4] = node4ModReset;
	
	struct SDFNode node5RedSphere;
	node5RedSphere.type = fSphereType;
	node5RedSphere.materialId = 0;
	node5RedSphere.floats[9] = 0.125; // radius
	scene->nodes[5] = node5RedSphere;
	
	struct SDFNode node7Union;
	node7Union.type = pUnionType;
	scene->nodes[6] = node7Union;
	
	struct SDFNode node8ModOffset;
	node8ModOffset.type = pModOffsetType;
	node8ModOffset.floats[0] = -0.5; // x-offset
	node8ModOffset.floats[1] = -0.65; // y-offset
	node8ModOffset.floats[2] = -0.5; // z-offset
	scene->nodes[7] = node8ModOffset;
	
	
	struct SDFNode node9GreenSphere;
	node9GreenSphere.type = fSphereType;
	node9GreenSphere.materialId = 1;
	node9GreenSphere.floats[9] = 0.075; // radius
	scene->nodes[8] = node9GreenSphere;

	struct SDFNode node10Union;
	node10Union.type = pUnionType;
	scene->nodes[9] = node10Union;
}

- (void) updateScene:(SDFScene *)scene atMediaTime:(float) mediaTime {

	// camera
	vector_float3 origin = { -0.5+1.5*cos(0.1*mediaTime), 1.0, 0.5 + 1.5*sin(0.1*mediaTime) };
	//vector_float3 origin = { 0.0, 0.0, 10.0 };
	vector_float3 target = { 0.0, 0.0, 0.0 };
	
	matrix_float3x3 camera = [self setupCamera:origin target: target rotation:M_PI];
	
	scene->cameraTransform = camera;
	scene->rayOrigin = origin;
}

- (void) nodesSelected:(NSMutableArray <NSValue *> *)hits  inScene:(SDFScene *)scene {
    
    for(int i=0; i<hits.count; i++) {
        
        SDFHit hitValue;
        [hits[i] getValue:&hitValue];
        int materialid = scene->nodes[hitValue.hitNodeId].materialId;
        
        scene->materials[materialid].ambient[0]= 1.0;
        scene->materials[materialid].ambient[1] = 0.0;
        scene->materials[materialid].ambient[2] = 0.0;
    }
    
    [self callDelegate];
}




@end
