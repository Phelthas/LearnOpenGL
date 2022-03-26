//
//  DemoGLModels.h
//  Demo_OpenGLES_6
//
//  Created by lu xiaoming on 2022/3/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


#pragma mark ----------------------------------DemoGLSpriteSheetModel----------------------------------

@class DemoGLSpriteSheetMetaModel;
@class DemoGLSpriteSheetFrameModel;
@class DemoGLSpriteSheetRectModel;

@interface DemoGLSpriteSheetModel : NSObject

@property (nonatomic, strong) UIImage *spriteSheetImage;

@property (nonatomic, strong) DemoGLSpriteSheetMetaModel *meta;
@property (nonatomic, strong) NSArray<DemoGLSpriteSheetFrameModel *> *frames;

+ (instancetype)modelWithSpriteSheetJson:(id)json;

@end



#pragma mark ----------------------------------DemoGLSpriteSheetMetaModel----------------------------------

/**
 "app": "https://www.codeandweb.com/texturepacker",
 "version": "1.0",
 "image": "heart.png",
 "format": "RGBA8888",
 "size": {
 "w": 1800,
 "h": 1200
 },
 "scale": "1",
 "smartupdate": "$TexturePacker:SmartUpdate:cc937004783940ed881d3abaaba7e243:2919dde04c324f00eb4a9102f51ce8f8:cb39580ce6d86b4835ef90f0a2df983e$"
 */

@interface DemoGLSpriteSheetMetaModel : NSObject

@property (nonatomic, copy) NSString *app;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *format;
@property (nonatomic, strong) DemoGLSpriteSheetRectModel *size;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, copy) NSString *smartupdate;

@end



#pragma mark ----------------------------------DemoGLSpriteSheetFrameModel----------------------------------

/**
 "filename": "F_MouceHeart_000.png",
 "frame": {
     "x": 0,
     "y": 0,
     "w": 200,
     "h": 150
 },
 "rotated": false,
 "trimmed": false,
 "spriteSourceSize": {
     "x": 0,
     "y": 0,
     "w": 200,
     "h": 150
 },
 "sourceSize": {
     "w": 200,
     "h": 150
 }
 */


@interface DemoGLSpriteSheetFrameModel : NSObject

@property (nonatomic, copy) NSString *filename;
@property (nonatomic, strong) DemoGLSpriteSheetRectModel *frame;
@property (nonatomic, assign) BOOL rotated;
@property (nonatomic, assign) BOOL trimmed;
@property (nonatomic, strong) DemoGLSpriteSheetRectModel *spriteSourceSize;
@property (nonatomic, strong) DemoGLSpriteSheetRectModel *sourceSize;

@end


#pragma mark ----------------------------------DemoGLSpriteSheetRectModel----------------------------------


@interface DemoGLSpriteSheetRectModel : NSObject

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat w;
@property (nonatomic, assign) CGFloat h;

@end

NS_ASSUME_NONNULL_END
