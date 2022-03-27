//
//  DemoGLSpriteSheetFilter.h
//  DemoUtils
//
//  Created by lu xiaoming on 2022/3/26.
//

#import "DemoGLFilter.h"
#import "DemoGLPicture.h"
#import "DemoGLModels.h"


NS_ASSUME_NONNULL_BEGIN

@interface DemoGLSpriteSheetFilter : DemoGLFilter

- (instancetype)initWithGLPicture:(DemoGLPicture *)glPicture spriteSheetModel:(DemoGLSpriteSheetModel *)spriteSheetModel;

- (void)setupWithTexture2Frame:(CGRect)frame superViewSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
