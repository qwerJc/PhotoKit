//
//  SinglePhotoVC.m
//  PhotoKit
//
//  Created by 贾辰 on 17/1/5.
//  Copyright © 2017年 贾辰. All rights reserved.
//

#import "SinglePhoController.h"
#import "SinglePhoView.h"

@interface SinglePhoController ()
@property(nonatomic,strong)SinglePhoView *viewSinglePho;
@end

@implementation SinglePhoController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self.view setBackgroundColor:[UIColor grayColor]];
        _viewSinglePho=[[SinglePhoView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width)];
        [_viewSinglePho viewInit];
        [self.view addSubview:_viewSinglePho];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)show:(UIImage *)img{
    [_viewSinglePho showImg:img];
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
