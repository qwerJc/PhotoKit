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


@interface PhotoListVC ()<CellPhoto,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    CGRect rect;
    PHAsset *asset;                         //照片库中的一个资源
    CGSize SomeSize;
    UITableView *tableViewPhoto;
    
    UIImageView *img1;

}
@property(strong,nonatomic)PHCachingImageManager *imageManager;
@property(strong,nonatomic)PHFetchResult *assetsFetchResults;
@property(strong,nonatomic)PHFetchOptions *options;
@property(strong,nonatomic)UIImagePickerController *imgPicker;



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
    
    //监听拍照事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraNotification:) name:AVCaptureSessionDidStartRunningNotification object:nil];
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
    _imgPicker=[[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        _imgPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        _imgPicker.delegate=self;
        _imgPicker.allowsEditing = NO;
        _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imgPicker.showsCameraControls = NO;//不使用系统默认拍照按钮
        
        UIToolbar* tool = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-75, self.view.frame.size.width, 75)];
        tool.barStyle = UIBarStyleBlackTranslucent;
        
        //创建灵活调节按钮单元,设置间隔
        UIBarButtonItem *flexibleitem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemFlexibleSpace) target:self action:nil];
        UIBarButtonItem* cancel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(btnCancelCamera)];
        UIBarButtonItem* add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(btnTakePhoto)];
        UIBarButtonItem* change = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:nil];
        [tool setItems:[NSArray arrayWithObjects:cancel,flexibleitem,add,flexibleitem,change, nil]];
        //把自定义的view设置到imagepickercontroller的overlay属性中
        _imgPicker.cameraOverlayView = tool;
        
        
        [self presentViewController:_imgPicker animated:NO completion:nil];
    }else{
        NSLog(@"不支持手机");
    }

}
- (void)btnTakePhoto{
    [_imgPicker takePicture];         //确认拍照
    _imgPicker.sourceType =    UIImagePickerControllerSourceTypeCamera;
}
- (void)btnCancelCamera{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [tableViewPhoto reloadData];
}
//拍照后跳转到下面 imagePickerController
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
//    UIImageWriteToSavedPhotosAlbum(image, self, nil, (__bridge void *)self);
    NSError *error = nil;
    __block NSString *createdAssetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //----block 执行的时候还没有保存成功--获取占位图片的 id，通过 id 获取图片---同步
        createdAssetID = [PHAssetChangeRequest             creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    

    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
    if(_nowAssetCollection!=nil){
        [self savePhoToSelfAlbum:assets];
    }
}
-(void)savePhoToSelfAlbum:(PHFetchResult<PHAsset *> *)temAsset{
    NSLog(@"collection name : %@",_nowAssetCollection.localizedTitle);
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //--告诉系统，要操作哪个相册
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:_nowAssetCollection];
        //--添加图片到自定义相册--追加--就不能成为封面了
        //--[collectionChangeRequest addAssets:assets];
        //--插入图片到自定义相册--插入--可以成为封面
        [collectionChangeRequest insertAssets:temAsset atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
}
//监听拍照通知（设置界面为全屏）
- (void)cameraNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 这里实现
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        float aspectRatio = 4.0/3.0;
        float scale = screenSize.height/screenSize.width * aspectRatio;
        _imgPicker.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
        
    });
}

-(void)showPhoto:(NSInteger)order{
    if(order<0){
        return;
    }

    PHImageRequestOptions *tryOp=[[PHImageRequestOptions alloc] init];
    tryOp.deliveryMode=PHImageRequestOptionsDeliveryModeFastFormat;
    tryOp.resizeMode=PHImageRequestOptionsResizeModeFast;
    
    SinglePhotoVC *sPhotoVC=[[SinglePhotoVC alloc] init];
    [self.navigationController pushViewController:sPhotoVC animated:YES];
    
    asset = _assetsFetchResults[order];
    
    [_imageManager requestImageForAsset:asset
                             targetSize:PHImageManagerMaximumSize
                            contentMode:PHImageContentModeAspectFill
                                options:tryOp
                          resultHandler:^(UIImage *result, NSDictionary *info) {
                              [sPhotoVC calSize:result];
                          }];
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
    
    [cell setIntOriImageLeft:-1];
    [cell setIntOriImageMid:-1];
    [cell setIntOriImageRight:-1];
    
    [cell setMiniImageLeft:nil];
    [cell setMiniImageMid:nil];
    [cell setMiniImageRight:nil];
    
    if(indexPath.row*3<_assetsFetchResults.count)
    {
        asset = _assetsFetchResults[indexPath.row*3];
        [_imageManager requestImageForAsset:asset
                                       targetSize:SomeSize
                                      contentMode:PHImageContentModeAspectFill
                                          options:tryOp
                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                        [cell setMiniImageLeft:result];
                                    }];
        [cell setIntOriImageLeft:indexPath.row*3];
        
    }

    if(indexPath.row*3+1<_assetsFetchResults.count)
    {
        asset = _assetsFetchResults[indexPath.row*3+1];
        [_imageManager requestImageForAsset:asset
                                       targetSize:SomeSize
                                      contentMode:PHImageContentModeAspectFill
                                          options:tryOp
                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                        [cell setMiniImageMid:result];
                                }];
        [cell setIntOriImageMid:indexPath.row*3+1];
    }
    
    if(indexPath.row*3+2<_assetsFetchResults.count)
    {
        asset = _assetsFetchResults[indexPath.row*3+2];
        [_imageManager requestImageForAsset:asset
                                       targetSize:SomeSize
                                      contentMode:PHImageContentModeAspectFill
                                          options:tryOp
                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                        [cell setMiniImageRight:result];
                                }];
        [cell setIntOriImageRight:indexPath.row*3+2];
        
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
