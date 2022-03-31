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

@implementation DemoGLRoundRectFilter

- (instancetype)init {
    return [self initWithVertexShaderString:kGPUImageRoundRectVertexShaderString fragmentShaderString:kGPUImageRoundRectFragmentShaderString];
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
