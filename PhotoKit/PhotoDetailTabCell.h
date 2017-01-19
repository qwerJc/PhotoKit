//
//  PhotoDetailTabCell.h
//  PhotoKit
//
//  Created by 贾辰 on 17/1/4.
//  Copyright © 2017年 贾辰. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CellPhoto <NSObject>

-(void)showPhoto:(UIImage*)p;

@end

@interface PhotoDetailTabCell : UITableViewCell
{
    UIImageView *imgVPhoto1;
    UIImageView *imgVPhoto2;
    UIImageView *imgVPhoto3;

    UIControl *conV1;
    UIControl *conV2;
    UIControl *conV3;
}
@property(strong,nonatomic)UIImage *oriImageLeft;
@property(strong,nonatomic)UIImage *oriImageMid;
@property(strong,nonatomic)UIImage *oriImageRight;
-(void)setPhoto1:(UIImage *)thumbnail andOriginImage:(UIImage*)oriImage;
-(void)setPhoto2:(UIImage *)thumbnail andOriginImage:(UIImage*)oriImage;
-(void)setPhoto3:(UIImage *)thumbnail andOriginImage:(UIImage*)oriImage;
@property(weak,nonatomic)id<CellPhoto> delegate;
@end
