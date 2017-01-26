//
//  PhotoDetailTabCell.m
//  PhotoKit
//
//  Created by 贾辰 on 17/1/4.
//  Copyright © 2017年 贾辰. All rights reserved.
//

#import "PhotoDetailTabCell.h"

@implementation PhotoDetailTabCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];//点击手势
        [singleTap1 setNumberOfTouchesRequired:1];
        singleTap1.delegate=self;
        [singleTap1 setNumberOfTapsRequired:1];
        
        
        imgVPhoto1=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 100)];
        imgVPhoto1.tag=1;
        [imgVPhoto1 addGestureRecognizer:singleTap1];
        imgVPhoto1.userInteractionEnabled=YES;
        [self.contentView addSubview:imgVPhoto1];
        
        UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];//点击手势
        [singleTap2 setNumberOfTouchesRequired:1];
        singleTap2.delegate=self;
        [singleTap2 setNumberOfTapsRequired:1];
        
        imgVPhoto2=[[UIImageView alloc] initWithFrame:CGRectMake(110, 10, 80, 100)];
        imgVPhoto2.tag=2;
        imgVPhoto2.userInteractionEnabled=YES;
        [imgVPhoto2 addGestureRecognizer:singleTap2];
        [self.contentView addSubview:imgVPhoto2];
        
        UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];//点击手势
        [singleTap3 setNumberOfTouchesRequired:1];
        singleTap3.delegate=self;
        [singleTap3 setNumberOfTapsRequired:1];
        
        imgVPhoto3=[[UIImageView alloc] initWithFrame:CGRectMake(200, 10, 80, 100)];
        imgVPhoto3.tag=3;
        imgVPhoto3.userInteractionEnabled=YES;
        [imgVPhoto3 addGestureRecognizer:singleTap3];
        [self.contentView addSubview:imgVPhoto3];
        
    }
    return self;
}
-(void)setPhoto1:(UIImage *)thumbnail andOriginImage:(UIImage*)oriImage{
//    _miniImageLefttt=oriImage;

}
-(void)setPhoto2:(UIImage *)thumbnail andOriginImage:(UIImage*)oriImage{
    imgVPhoto2.image=thumbnail;
}
-(void)setPhoto3:(UIImage *)thumbnail andOriginImage:(UIImage*)oriImage{

}
-(void)setMiniImageLeft:(UIImage *)miniImageLeft{
    imgVPhoto1.image=miniImageLeft;
}
-(void)setMiniImageMid:(UIImage *)miniImageMid{
    imgVPhoto2.image=miniImageMid;
}
-(void)setMiniImageRight:(UIImage *)miniImageRight{
    imgVPhoto3.image=miniImageRight;
}
-(void)singleTapAction:(UIGestureRecognizer *)gest
{
    switch (gest.view.tag) {
        case 1:
            NSLog(@"点了图片1");
            if([_delegate respondsToSelector:@selector(showPhoto:)]){
                [_delegate showPhoto:_intOriImageLeft];
            }
            break;
        case 2:
            NSLog(@"点了图片2");
            if([_delegate respondsToSelector:@selector(showPhoto:)]){
                [_delegate showPhoto:_intOriImageMid];
            }
            break;
        case 3:
            NSLog(@"点了图片3");
            if([_delegate respondsToSelector:@selector(showPhoto:)]){
                [_delegate showPhoto:_intOriImageRight];
            }
            break;
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
