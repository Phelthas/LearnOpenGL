//
//  ThreeViewController.h
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/8/15.
//

#import "OneViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ShaderAttributeIndexPosition = 0,
    ShaderAttributeIndexCoordinate,
    ShaderAttributeIndexCount,  //不实际使用，只是为了计数
} ShaderAttributeIndex;


@interface ThreeViewController : OneViewController

@end


#pragma mark ----------------------------------DemoGLView3----------------------------------

@interface DemoGLView3 : DemoGLView

- (GLKTextureInfo *)textureInfoForTest;

@end

NS_ASSUME_NONNULL_END
