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
        
        UIImage *imgSel=[UIImage imageNamed:@"Img_Sel"];
        
        _imgVSelL=[[UIImageView alloc] initWithFrame:CGRectMake(59,79, 20, 20)];
        [_imgVSelL setImage:imgSel];
        [_imgVSelL setHidden:YES];
        _imgVSelM=[[UIImageView alloc] initWithFrame:CGRectMake(59,79, 20, 20)];
        [_imgVSelM setImage:imgSel];
        [_imgVSelM setHidden:YES];
        _imgVSelR=[[UIImageView alloc] initWithFrame:CGRectMake(59,79, 20, 20)];
        [_imgVSelR setImage:imgSel];
        [_imgVSelR setHidden:YES];
        
        [imgVPhoto1 addSubview:_imgVSelL];
        [imgVPhoto2 addSubview:_imgVSelM];
        [imgVPhoto3 addSubview:_imgVSelR];
        
    }


    return self;
}
-(void)setMiniImageLeft:(UIImage *)miniImageLeft{
    imgVPhoto1.image=miniImageLeft;
    if(imgVPhoto1.image==nil){
        [imgVPhoto1 setAlpha:1];
        [_imgVSelL setHidden:YES];
    }
}
-(void)setMiniImageMid:(UIImage *)miniImageMid{
    imgVPhoto2.image=miniImageMid;
    if(imgVPhoto2.image==nil){
        [imgVPhoto2 setAlpha:1];
        [_imgVSelM setHidden:YES];
    }
}
-(void)setMiniImageRight:(UIImage *)miniImageRight{
    imgVPhoto3.image=miniImageRight;
    if(imgVPhoto3.image==nil){
        [imgVPhoto3 setAlpha:1];
        [_imgVSelR setHidden:YES];
    }

}

-(void)singleTapAction:(UIGestureRecognizer *)gest
{
    switch (gest.view.tag) {
        case 1:
            NSLog(@"点了图片1");
            if([_delegate respondsToSelector:@selector(showPhoto:)]){

                [_delegate showPhoto:_intOriImageLeft]; //在listVC中第一次初始化view时赋值

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

-(void)setSelectL{
    [imgVPhoto1 setAlpha:0.5];
    [_imgVSelL setHidden:NO];
}
-(void)cancelSelectL{
    [imgVPhoto1 setAlpha:1];
    [_imgVSelL setHidden:YES];
}
-(void)setSelectM{
    [imgVPhoto2 setAlpha:0.5];
    [_imgVSelM setHidden:NO];
}
-(void)cancelSelectM{
    [imgVPhoto2 setAlpha:1];
    [_imgVSelM setHidden:YES];
}
-(void)setSelectR{
    [imgVPhoto3 setAlpha:0.5];
    [_imgVSelR setHidden:NO];
}
-(void)cancelSelectR{
    [imgVPhoto3 setAlpha:1];
    [_imgVSelR setHidden:YES];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
