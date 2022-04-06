//
//  DemoGLRoundRectFilter.m
//  DemoUtils
//
//  Created by billthaslu on 2022/3/31.
//

#import "DemoGLRoundRectFilter.h"
#import "DemoGLShaders.h"

NSString *const kGPUImageRoundRectVertexShaderString = SHADER_STRING
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


NSString *const kGPUImageRoundRectFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     mediump vec4 color = texture2D(inputImageTexture, textureCoordinate);

     if (distance(textureCoordinate, vec2(0.5, 0.5)) > 0.5) {
         gl_FragColor = vec4(color.rgb, 0.0);
     } else {
         gl_FragColor = color;
     }
 }
);




NSString *const kGPUImageRoundRectFragmentShaderString2 = SHADER_STRING
(
 precision highp float; //加这一句，下面就不用每个float前面都加highp了

 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 /**
  参考 https://stackoverflow.com/questions/43970170/bordered-rounded-rectangle-in-glsl
  p是任意一采样点（纹理坐标0-1范围）相对于（0.5，0.5）的坐标，b是第一象限内切圆圆心相对于（0.5，0.5）坐标，r是内切圆半径；
  p取绝对值，即把这一点调整到第一象限进行计算；
  abs(p) - b，就是单纯的对应坐标相减，在b右上方的点x，y结果都为正，其余的x或y结果为负；
  max(abs(p) - b, 0.0)，是把结果为负的值改为0，因为最后要算距离，负值的距离也可能比较大，小于x的取0，相当于只取了第一象限的点；
  length函数去向量的长度，这里即某一点相对于b点的距离；
  距离减去r小于0，说明这一点在内切圆范围内，可以正在显示；反之则在内切圆范围外，应该设置透明。
  */
 float udRoundRect(vec2 p, vec2 b, float r)
 {
     return length(max(abs(p) - b, 0.0)) - r;
 }
 
 void main()
 {
    
    vec4 color = texture2D(inputImageTexture, textureCoordinate);
     //这里暂时用textureCoordinate计算，要更精确应该用gl_FragCoord考虑宽高不一样的情况
    float a = udRoundRect(textureCoordinate - vec2(0.5, 0.5), vec2(0.4, 0.4), 0.1);
    gl_FragColor = vec4(color.rgb, step(a, 0.0));
 }
);

@implementation DemoGLRoundRectFilter

- (instancetype)init {
    return [self initWithVertexShaderString:kGPUImageRoundRectVertexShaderString fragmentShaderString:kGPUImageRoundRectFragmentShaderString2];
}

- (void)newFrameReadyAtTime:(CMTime)frameTime timimgInfo:(CMSampleTimingInfo)timimgInfo {
    static const GLfloat imageVertices[] = {
        -0.5f, -0.5f,
        0.5f, -0.5f,
        -0.5f,  0.5f,
        0.5f,  0.5f,
    };
    
//    static const GLfloat textureCoordinates[] = {
//        0.0f, 0.0f,
//        1.0f, 0.0f,
//        0.0f, 1.0f,
//        1.0f, 1.0f,
//    };
    
    static const GLfloat textureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    [self renderToTextureWithVertices:imageVertices textureCoordinates:textureCoordinates];

    [self informTargetsAboutNewFrameAtTime:frameTime];
}

@end
