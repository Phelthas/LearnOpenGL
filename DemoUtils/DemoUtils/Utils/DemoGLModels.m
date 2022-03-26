//
//  DemoGLModels.m
//  Demo_OpenGLES_6
//
//  Created by lu xiaoming on 2022/3/26.
//

#import "DemoGLModels.h"
#import "YYModel.h"


#pragma mark ----------------------------------DemoGLSpriteSheetModel----------------------------------


@implementation DemoGLSpriteSheetModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"frames" : [DemoGLSpriteSheetFrameModel class],
    };
}

+ (instancetype)modelWithSpriteSheetJson:(id)json {
    DemoGLSpriteSheetModel *model = [DemoGLSpriteSheetModel yy_modelWithJSON:json];
    return model;
}

@end



#pragma mark ----------------------------------DemoGLSpriteSheetMetaModel----------------------------------

@implementation DemoGLSpriteSheetMetaModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"imageName"  : @"image",
    };
}


@end



#pragma mark ----------------------------------DemoGLSpriteSheetFrameModel----------------------------------

@implementation DemoGLSpriteSheetFrameModel

@end



#pragma mark ----------------------------------DemoGLSpriteSheetRectModel----------------------------------


@implementation DemoGLSpriteSheetRectModel

@end
