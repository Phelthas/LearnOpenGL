//
//  DemoGLShaders.m
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import "DemoGLShaders.h"


NSString *const kGPUImageVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );


NSString *const kGPUImageRotationVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 uniform mat4 rotateXMatrix; //用来做x轴旋转
 uniform mat4 rotateYMatrix; //用来做y轴旋转
 uniform mat4 rotateZMatrix; //用来做z轴旋转
 varying vec2 textureCoordinate;
 
 void main()
 {
    //因为OpenGL是列向量，所以矩阵是从右向左起作用的，position要在最后
    //这里的意思是，postion先做z旋转，再做y旋转，再做x旋转
     gl_Position = rotateXMatrix * rotateYMatrix * rotateZMatrix * position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );


NSString *const kGPUImageTransversalVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 uniform mat4 rotateMatrix; //用来做旋转
 uniform mat4 scaleMatrix; //用来做缩放
 varying vec2 textureCoordinate;
 
 void main()
 {
    //写成position * matrix时，OpenGL会把position当初横向量来计算，注意此时rotateMatrix也需要是横向量
    //https://stackoverflow.com/questions/24593939/matrix-multiplication-with-vector-in-glsl
    gl_Position = position * rotateMatrix * scaleMatrix;
    textureCoordinate = inputTextureCoordinate.xy;
 }
 );



NSString *const kGPUImagePassthroughFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
);



// Color Conversion Constants (YUV to RGB) including adjustment from 16-235/16-240 (video range)

// BT.601, which is the standard for SDTV.
const GLfloat kColorConversion601[] = {
    1.164,  1.164, 1.164,
    0.0, -0.392, 2.017,
    1.596, -0.813,   0.0,
};

// BT.709, which is the standard for HDTV.
const GLfloat kColorConversion709[] = {
    1.164,  1.164, 1.164,
    0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};

// BT.601 full range (ref: http://www.equasys.de/colorconversion.html)
const GLfloat kColorConversion601FullRange[] = {
    1.0,    1.0,    1.0,
    0.0,    -0.343, 1.765,
    1.4,    -0.711, 0.0,
};

NSString *const kGPUImageYUVFullRangeConversionForLAFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D luminanceTexture;
 uniform sampler2D chrominanceTexture;
 uniform mediump mat3 colorConversionMatrix;
 
 void main()
 {
     mediump vec3 yuv;
     lowp vec3 rgb;
     
     yuv.x = texture2D(luminanceTexture, textureCoordinate).r;
     yuv.yz = texture2D(chrominanceTexture, textureCoordinate).ra - vec2(0.5, 0.5);
     rgb = colorConversionMatrix * yuv;
     
     gl_FragColor = vec4(rgb, 1);
 }
 );

NSString *const kGPUImageYUVVideoRangeConversionForLAFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D luminanceTexture;
 uniform sampler2D chrominanceTexture;
 uniform mediump mat3 colorConversionMatrix;
 
 void main()
 {
     mediump vec3 yuv;
     lowp vec3 rgb;
     
     yuv.x = texture2D(luminanceTexture, textureCoordinate).r - (16.0/255.0);
     yuv.yz = texture2D(chrominanceTexture, textureCoordinate).ra - vec2(0.5, 0.5);
     rgb = colorConversionMatrix * yuv;
     
     gl_FragColor = vec4(rgb, 1);
 }
 );



NSString *const kGPUImageYUVFullRangeConversionForI420ShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D yTexture;
 uniform sampler2D uTexture;
 uniform sampler2D vTexture;
 uniform mediump mat3 colorConversionMatrix;
 
 void main()
 {
     mediump vec3 yuv;
     lowp vec3 rgb;
     
     yuv.x = texture2D(yTexture, textureCoordinate).r;
     yuv.y = texture2D(uTexture, textureCoordinate).r - 0.5;
     yuv.z = texture2D(vTexture, textureCoordinate).r - 0.5;
     rgb = colorConversionMatrix * yuv;
     
     gl_FragColor = vec4(rgb, 1);
    
 }
 );

@implementation DemoGLShaders

@end
