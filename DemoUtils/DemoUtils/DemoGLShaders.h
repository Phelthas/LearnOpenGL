//
//  DemoGLShaders.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import <Foundation/Foundation.h>

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NS_ASSUME_NONNULL_BEGIN


UIKIT_EXTERN NSString *const kGPUImageVertexShaderString;
UIKIT_EXTERN NSString *const kGPUImageRotationVertexShaderString;
UIKIT_EXTERN NSString *const kGPUImageTransversalVertexShaderString;


UIKIT_EXTERN const GLfloat kColorConversion601[];
UIKIT_EXTERN const GLfloat kColorConversion601FullRange[];
UIKIT_EXTERN const GLfloat kColorConversion709[];

UIKIT_EXTERN NSString *const kGPUImagePassthroughFragmentShaderString;
UIKIT_EXTERN NSString *const kGPUImageYUVFullRangeConversionForLAFragmentShaderString;
UIKIT_EXTERN NSString *const kGPUImageYUVVideoRangeConversionForLAFragmentShaderString;


@interface DemoGLShaders : NSObject

@end

NS_ASSUME_NONNULL_END
