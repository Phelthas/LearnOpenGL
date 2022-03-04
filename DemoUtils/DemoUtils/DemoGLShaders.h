//
//  DemoGLShaders.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>  //UIKIT_EXTERN

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NS_ASSUME_NONNULL_BEGIN


FOUNDATION_EXTERN NSString *const kGPUImageVertexShaderString;
FOUNDATION_EXTERN NSString *const kGPUImageRotationVertexShaderString;
FOUNDATION_EXTERN NSString *const kGPUImageTransversalVertexShaderString;


FOUNDATION_EXTERN const GLfloat kColorConversion601[];
FOUNDATION_EXTERN const GLfloat kColorConversion601FullRange[];
FOUNDATION_EXTERN const GLfloat kColorConversion709[];

FOUNDATION_EXTERN NSString *const kGPUImagePassthroughFragmentShaderString;
FOUNDATION_EXTERN NSString *const kGPUImageYUVFullRangeConversionForLAFragmentShaderString;
FOUNDATION_EXTERN NSString *const kGPUImageYUVVideoRangeConversionForLAFragmentShaderString;
FOUNDATION_EXTERN NSString *const kGPUImageYUVFullRangeConversionForI420ShaderString;

@interface DemoGLShaders : NSObject

@end

NS_ASSUME_NONNULL_END
