//
//  VSinglePho.h
//  PhotoKit
//
//  Created by 贾辰 on 17/3/8.
//  Copyright © 2017年 贾辰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SinglePhoView : UIView
@property(nonatomic)CGRect rect;
@property(nonatomic)float imgHeight;
@property(nonatomic)float imgWidth;
@property(strong,nonatomic)UIImageView *imgView;
-(void)viewInit;
-(void)showImg:(UIImage *)img;

@end
