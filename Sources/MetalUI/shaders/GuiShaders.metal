//
//  GuiShaders.metal
//  starship-tactics
//
//  Created by James Randall on 01/12/2024.
//

#include <metal_stdlib>
#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    float4 position [[position]];
    float4 color;
} GuiOut;

float4x4 createScaleMatrix(float3 scale) {
    return float4x4(
        float4(scale.x, 0.0,    0.0,    0.0),
        float4(0.0,    scale.y, 0.0,    0.0),
        float4(0.0,    0.0,    scale.z, 0.0),
        float4(0.0,    0.0,    0.0,    1.0)
    );
}

float4x4 createTranslateMatrix(float3 translation) {
    return float4x4(
        float4(1.0, 0.0, 0.0, 0.0),
        float4(0.0, 1.0, 0.0, 0.0),
        float4(0.0, 0.0, 1.0, 0.0),
        float4(translation.x, translation.y, translation.z, 1.0)
    );
}

typedef struct {
    float3 position [[attribute(0)]];
} GuiVertex;

// Vertex shader
vertex GuiOut guiVertexShader(GuiVertex in [[stage_in]],
                              constant GuiUniforms& uniforms [[buffer(1)]],
                              constant GuiInstanceData *instanceData [[buffer(2)]],
                              uint instanceID [[instance_id]]) {
    GuiInstanceData instance = instanceData[instanceID];
    
    float4x4 scaleMatrix = createScaleMatrix(float3(instance.size, 1.0));
    float4x4 translationMatrix = createTranslateMatrix(float3(instance.position, 0.0));
    float4x4 modelViewMatrix = translationMatrix * scaleMatrix;
    
    GuiOut out;
    out.position = uniforms.projectionMatrix * modelViewMatrix * float4(in.position,1.0);
    out.color = instance.color;
    return out;
}

// Fragment shader
fragment float4 guiFragmentShader(GuiOut in [[stage_in]]) {
    return in.color;
}
