//
//  PhotoListVC.m
//  PhotoKit
//
//  Created by 贾辰 on 17/1/4.
//  Copyright © 2017年 贾辰. All rights reserved.
//
#include <Photos/Photos.h>
#import "PhotoDetailTabCell.h"
#import "SinglePhotoVC.h"
#import "PhotoListVC.h"

@interface PhotoListVC ()<CellPhoto,UITableViewDelegate,UITableViewDataSource>
{
    CGRect rect;
    PHAsset *asset;                         //照片库中的一个资源
    CGSize SomeSize;
    UITableView *tableViewPhoto;
    
    UIImageView *img1;
}
@property(strong,nonatomic)SinglePhotoVC *sPhotoVC;
@property(strong,nonatomic)PHCachingImageManager *imageManager;
@property(strong,nonatomic)PHFetchResult *assetsFetchResults;
@property(strong,nonatomic)PHFetchOptions *options;
@property(assign,nonatomic)id blockLID;
@property(assign,nonatomic)id blockMID;
@property(assign,nonatomic)id blockRID;



@end

@implementation PhotoListVC

- (void)viewDidLoad {
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    _options = [[PHFetchOptions alloc] init];
    _options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    _imageManager = [[PHCachingImageManager alloc] init];
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    rect=[[UIScreen mainScreen] bounds];

    SomeSize=CGSizeMake(240, 300);
    
    UIView *viewTopBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 70)];
    viewTopBar.backgroundColor=[UIColor orangeColor];
    [self.view addSubview:viewTopBar];
    
    UIButton *btnCamera = [[UIButton alloc] initWithFrame:CGRectMake(rect.size.width-180, 30, 50, 30)];
    [btnCamera setTitle:@"相机" forState:UIControlStateNormal];
    [btnCamera addTarget:self action:@selector(btnCameraClick) forControlEvents:UIControlEventTouchUpInside];
    [btnCamera setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCamera setBackgroundColor:[UIColor redColor]];
    [viewTopBar addSubview:btnCamera];
    
    //height_start:65
    tableViewPhoto=[[UITableView alloc] initWithFrame:CGRectMake(0,70, rect.size.width, rect.size.height-70) style:UITableViewStyleGrouped];
    tableViewPhoto.dataSource = self;
    tableViewPhoto.delegate = self;
    tableViewPhoto.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableViewPhoto];
}
-(void)updateFetchRes:(PHAssetCollection *)assetCollection{
    _assetsFetchResults=[PHAsset fetchAssetsInAssetCollection:assetCollection options:_options];
    [tableViewPhoto reloadData];
}
-(void)updateFetchRes{
    _assetsFetchResults= [PHAsset fetchAssetsWithOptions:_options];
    [tableViewPhoto reloadData];
}
-(void)btnCameraClick{
    NSLog(@"Print path!");
}
-(void)showPhoto:(UIImage*)p{
    if(p==nil){
        return;
    }
    _sPhotoVC=[[SinglePhotoVC alloc] init];
    [self.navigationController pushViewController:_sPhotoVC animated:YES];
    [_sPhotoVC calSize:p];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int res=_assetsFetchResults.count%3;
    if(res==0){
        return _assetsFetchResults.count/3;
    }else{
        return _assetsFetchResults.count/3+1;
    }


}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

//返回每个item
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CIdentifier = @"Cell";
    PhotoDetailTabCell *cell = [tableView dequeueReusableCellWithIdentifier:CIdentifier];
    
    
    if (cell == nil) {
        cell = [[PhotoDetailTabCell alloc]initWithStyle:UITableViewCellStyleDefault   reuseIdentifier:CIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.delegate=self;
    }
    
    [self addPhoto:cell andIndxPath:indexPath];
    
    return cell;
}

-(void)addPhoto:(PhotoDetailTabCell *)cell andIndxPath:(NSIndexPath *)indexPath{
    PHImageRequestOptions *tryOp=[[PHImageRequestOptions alloc] init];
    tryOp.deliveryMode=PHImageRequestOptionsDeliveryModeHighQualityFormat;
    tryOp.resizeMode=PHImageRequestOptionsResizeModeExact;
    

    [cell setPhoto1:nil andOriginImage:nil];
    [cell setPhoto2:nil andOriginImage:nil];
    [cell setPhoto2:nil andOriginImage:nil];
    
    if(indexPath.row*3>=_assetsFetchResults.count)
    {
        [cell setPhoto1:nil andOriginImage:nil];
    }else{
        asset = _assetsFetchResults[indexPath.row*3];
        [_imageManager requestImageForAsset:asset
                                       targetSize:SomeSize
                                      contentMode:PHImageContentModeAspectFill
                                          options:tryOp
                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                        [cell setPhoto1:[self getThumbnail:result targetSize:CGSizeMake(80, 100)] andOriginImage:result];    // 得到一张 UIImage，展示到界面上
                                    }];
    }

    if(indexPath.row*3+1>=_assetsFetchResults.count)
    {
        [cell setPhoto2:nil andOriginImage:nil];
    }else{
        asset = _assetsFetchResults[indexPath.row*3+1];
        [_imageManager requestImageForAsset:asset
                                       targetSize:SomeSize
                                      contentMode:PHImageContentModeAspectFill
                                          options:tryOp
                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                    
                                    [cell setPhoto2:[self getThumbnail:result targetSize:CGSizeMake(80, 100)] andOriginImage:result];
                                }];
    }
    
    if(indexPath.row*3+2>=_assetsFetchResults.count)
    {
        [cell setPhoto3:nil andOriginImage:nil];
    }else{
        asset = _assetsFetchResults[indexPath.row*3+2];
        [_imageManager requestImageForAsset:asset
                                       targetSize:SomeSize
                                      contentMode:PHImageContentModeAspectFill
                                          options:tryOp
                                    resultHandler:^(UIImage *result, NSDictionary *info) {

                                    [cell setPhoto3:[self getThumbnail:result targetSize:CGSizeMake(80, 100)] andOriginImage:result];
                                }];
    }
    
}
-(UIImage *)getThumbnail:(UIImage *)sourceImage targetSize:(CGSize)size{
    
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    
    CGFloat width = imageSize.width;
    
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = size.width;
    
    CGFloat targetHeight = size.height;
    
    CGFloat scaleFactor = 0.0;
    
    CGFloat scaledWidth = targetWidth;
    
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            
            scaleFactor = widthFactor;
            
        }
        
        else{
            
            scaleFactor = heightFactor;
            
        }
        
        scaledWidth = width * scaleFactor;
        
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            
        }
        
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 3.0);
    
    CGRect thumbnailRect = CGRectZero;
    
    thumbnailRect.origin = thumbnailPoint;
    
    thumbnailRect.size.width = scaledWidth;
    
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        NSLog(@"scale image fail");
        
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
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

@end
