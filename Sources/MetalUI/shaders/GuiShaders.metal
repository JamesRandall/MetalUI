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
    simd_float2 texCoord;
    int shouldTexture;
    int textureIndex;
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
    float2 texCoord [[attribute(1)]];
} GuiVertex;

typedef struct
{
    matrix_float4x4 projectionMatrix;
} GuiUniforms;

typedef struct {
    simd_float4 color;
    simd_float2 position;
    simd_float2 size;
    simd_float2 texTopLeft;
    simd_float2 texBottomRight;
    int textureIndex;
    int shouldTexture;
    int isVisible;
} GuiInstanceData;

// Vertex shader
vertex GuiOut guiVertexShader(GuiVertex in [[stage_in]],
                              constant GuiUniforms& uniforms [[buffer(1)]],
                              constant GuiInstanceData *instanceData [[buffer(2)]],
                              uint instanceID [[instance_id]]) {
    GuiOut out;
    GuiInstanceData instance = instanceData[instanceID];
    if (instance.isVisible == 0) {
        out.position = float4(10000.0, 10000.0, 10000.0, 1.0);
        return out;
    }
    
    float4x4 scaleMatrix = createScaleMatrix(float3(instance.size, 1.0));
    float4x4 translationMatrix = createTranslateMatrix(float3(instance.position, 0.0));
    float4x4 modelViewMatrix = translationMatrix * scaleMatrix;
    
    
    out.position = uniforms.projectionMatrix * modelViewMatrix * float4(in.position,1.0);
    out.color = instance.color;
    float x = in.texCoord.x == 0.0 ? instance.texTopLeft.x : instance.texBottomRight.x;
    float y = in.texCoord.y == 0.0 ? instance.texTopLeft.y : instance.texBottomRight.y;
    out.texCoord = float2(x,y);
    out.shouldTexture = instance.shouldTexture;
    out.textureIndex = instance.textureIndex;
    return out;
}

// Fragment shader
fragment float4 guiFragmentShader(GuiOut in [[stage_in]],
                                  texture2d<float> colorMap [[ texture(0) ]]
                                  ) {
    if (in.shouldTexture > 0) {
        //return float4(1.0, 1.0, 1.0, 1.0);
        
        constexpr sampler colorSampler(mip_filter::linear,
                                       mag_filter::linear,
                                       min_filter::linear);
        float4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);
        return float4(colorSample);
    }
    return in.color;
}
