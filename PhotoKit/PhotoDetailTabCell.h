//
//  PhotoDetailTabCell.h
//  PhotoKit
//
//  Created by 贾辰 on 17/1/4.
//  Copyright © 2017年 贾辰. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CellPhoto <NSObject>
-(void)showPhoto:(NSInteger)order;

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

@property(assign,nonatomic)NSInteger intOriImageLeft;
@property(assign,nonatomic)NSInteger intOriImageRight;
@property(assign,nonatomic)NSInteger intOriImageMid;
@property(strong,nonatomic)UIImage *miniImageLeft;
@property(strong,nonatomic)UIImage *miniImageMid;
@property(strong,nonatomic)UIImage *miniImageRight;

@property(strong,nonatomic)UIImageView *imgVSelL;
@property(strong,nonatomic)UIImageView *imgVSelM;
@property(strong,nonatomic)UIImageView *imgVSelR;

@property(weak,nonatomic)id<CellPhoto> delegate;

-(void)setSelectL;
-(void)cancelSelectL;
-(void)setSelectM;
-(void)cancelSelectM;
-(void)setSelectR;
-(void)cancelSelectR;
@end
