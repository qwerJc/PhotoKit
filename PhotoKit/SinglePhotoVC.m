//
//  SinglePhotoVC.m
//  PhotoKit
//
//  Created by 贾辰 on 17/1/5.
//  Copyright © 2017年 贾辰. All rights reserved.
//

#import "SinglePhotoVC.h"

@interface SinglePhotoVC ()

@end

@implementation SinglePhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor grayColor]];
}
-(void)calSize:(UIImage *)img{
    NSLog(@"calsize : %@",img);
    
    _rect=[[UIScreen mainScreen] bounds];
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
    
    NSLog(@"%f,%f",_imgWidth,_imgHeight);
    
    
    
    UIImageView *imgV=[[UIImageView alloc] initWithFrame:CGRectMake(0,([UIScreen mainScreen].bounds.size.height-_imgHeight)/2,_imgWidth, _imgHeight)];
    imgV.image=img;
    [self.view addSubview:imgV];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.view sendSubviewToBack:self.navigationController.navigationBar];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
