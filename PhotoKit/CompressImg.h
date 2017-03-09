//
//  CompressImg.h
//  try1
//
//  Created by 贾辰 on 17/3/3.
//  Copyright © 2017年 贾辰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompressImg : UIImage
+(UIImage *)getThumbnail:(UIImage *)sourceImage targetSize:(CGSize)size;
@end
