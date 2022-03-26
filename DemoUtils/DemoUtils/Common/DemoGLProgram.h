//
//  DemoGLProgram.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoGLProgram : NSObject

- (instancetype)initWithVertexShaderString:(NSString *)vShaderString fragmentShaderString:(NSString *)fShaderString;

- (void)addAttribute:(NSString *)attributeName;

- (GLuint)attributeIndex:(NSString *)attributeName;

- (GLuint)uniformIndex:(NSString *)uniformName;

- (BOOL)link;

- (void)use;

- (void)validate;

@end

NS_ASSUME_NONNULL_END
