 //
//  VSinglePho.m
//  PhotoKit
//
//  Created by 贾辰 on 17/3/8.
//  Copyright © 2017年 贾辰. All rights reserved.
//

#import "SinglePhoView.h"

@implementation SinglePhoView
-(void)viewInit{
    _rect=[[UIScreen mainScreen] bounds];
    
    _imgView=[[UIImageView alloc] init];
    [self addSubview:_imgView];
}
-(void)calSize:(UIImage *)img{
    float width,height;
    width=img.size.width;
    height=img.size.height;
    
    float real_height;
    real_height=_rect.size.width*height/width;
    
    if(real_height>_rect.size.height){
        _imgHeight=_rect.size.height;
        _imgWidth=_imgHeight*width/height;
    }else{
        _imgHeight=real_height;
        _imgWidth=_rect.size.width;
    }
}
-(void)showImg:(UIImage *)img{
    [self setBackgroundColor:[UIColor grayColor]];
    
    [self calSize:img];
    _imgView.image=img;
    [_imgView setFrame:CGRectMake(0,(_rect.size.height-_imgHeight)/2,_imgWidth, _imgHeight)];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
