//
//  SinglePhotoVC.h
//  PhotoKit
//
//  Created by 贾辰 on 17/1/5.
//  Copyright © 2017年 贾辰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SinglePhotoVC : UIViewController
@property(nonatomic)CGRect rect;
@property(nonatomic)float imgHeight;
@property(nonatomic)float imgWidth;
-(void)calSize:(UIImage *)img;
@end
