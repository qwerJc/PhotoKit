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
#import "JCModel.h"

@interface PhotoListVC ()<CellPhoto,UITableViewDelegate,UITableViewDataSource>
{
    PHAsset *asset;                         //照片库中的一个资源
    CGSize SomeSize;

}
@property(strong,nonatomic)UIImageView *img1;
@property(assign,nonatomic)CGRect rect;
@property(strong,nonatomic)UITableView *tableViewPhoto;

@property(strong,nonatomic)PHCachingImageManager *imageManager;
@property(strong,nonatomic)PHFetchResult *assetsFetchResults;
@property(strong,nonatomic)PHFetchOptions *options;
@property(assign,nonatomic)id blockLID;
@property(assign,nonatomic)id blockMID;
@property(assign,nonatomic)id blockRID;

@property(assign,nonatomic)BOOL canDel;
@property(strong,nonatomic)UIView *viewTabBar;
@property(strong,nonatomic)NSMutableArray* cellSelectState;
@property(strong,nonatomic)JCModel* jcModel;
@property(strong,nonatomic)UIView *viewAlbumList;

@property(strong,nonatomic)UIImagePickerController *imgPicker;


@end

@implementation PhotoListVC
-(id)init{
    self=[super init];
    _rect=[[UIScreen mainScreen] bounds];
    
    SomeSize=CGSizeMake(240, 300);

    self.tabBarController.tabBar.hidden=YES;
    
    _cellSelectState=[[NSMutableArray alloc] init];
    

    
    return self;
}
- (void)viewDidLoad {
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    _options = [[PHFetchOptions alloc] init];
    _options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    _imageManager = [[PHCachingImageManager alloc] init];
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UIView *viewTopBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _rect.size.width, 70)];
    viewTopBar.backgroundColor=[UIColor orangeColor];
    [self.view addSubview:viewTopBar];
    
    UIButton *btnCamera = [[UIButton alloc] initWithFrame:CGRectMake(_rect.size.width-180, 30, 50, 30)];
    [btnCamera setTitle:@"相机" forState:UIControlStateNormal];
    [btnCamera addTarget:self action:@selector(btnCameraClick) forControlEvents:UIControlEventTouchUpInside];
    [btnCamera setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCamera setBackgroundColor:[UIColor redColor]];
    [viewTopBar addSubview:btnCamera];
    
    UIButton *btnChoose = [[UIButton alloc] initWithFrame:CGRectMake(_rect.size.width-290, 30, 70, 30)];
    [btnChoose setTitle:@"Choose" forState:UIControlStateNormal];
    [btnChoose addTarget:self action:@selector(btnChooseClick) forControlEvents:UIControlEventTouchUpInside];
    [btnChoose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnChoose setBackgroundColor:[UIColor redColor]];
    [viewTopBar addSubview:btnChoose];
    
    //height_start:65

    _tableViewPhoto=[[UITableView alloc] initWithFrame:CGRectMake(0,70, _rect.size.width, _rect.size.height-70) style:UITableViewStyleGrouped];
    _tableViewPhoto.dataSource = self;
    _tableViewPhoto.delegate = self;
    _tableViewPhoto.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableViewPhoto];
    
    _viewTabBar = [[UIView alloc] initWithFrame:CGRectMake(0, _rect.size.height-60, _rect.size.width, 60)];
    [_viewTabBar setHidden:YES];
    [_viewTabBar setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:_viewTabBar];
    
    UIButton *btnTabBarDel = [[UIButton alloc] initWithFrame:CGRectMake(_viewTabBar.frame.size.width-90,10, 80, 40)];
    [btnTabBarDel setTitle:@"del" forState:UIControlStateNormal];
    [btnTabBarDel addTarget:self action:@selector(btnTabBarDelClick) forControlEvents:UIControlEventTouchUpInside];
    [btnTabBarDel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnTabBarDel setBackgroundColor:[UIColor redColor]];
    [_viewTabBar addSubview:btnTabBarDel];
    
    UIButton *btnTabBarMove = [[UIButton alloc] initWithFrame:CGRectMake(10,10, 80, 40)];
    [btnTabBarMove setTitle:@"AddTo" forState:UIControlStateNormal];
    [btnTabBarMove addTarget:self action:@selector(btnTabBarAddToClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnTabBarMove setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnTabBarMove setBackgroundColor:[UIColor redColor]];
    [_viewTabBar addSubview:btnTabBarMove];
    
    _viewAlbumList = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 10, 10)];
    [_viewAlbumList setBackgroundColor:[UIColor grayColor]];
    [_viewAlbumList.layer setCornerRadius:5];
    [_viewAlbumList setAlpha:0.7];
    [self.view addSubview:_viewAlbumList];
    [_viewAlbumList setHidden:YES];
    
    //监听拍照事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraNotification:) name:AVCaptureSessionDidStartRunningNotification object:nil];
}
-(void)updateFetchRes:(PHAssetCollection *)assetCollection{
    _assetsFetchResults=[PHAsset fetchAssetsInAssetCollection:assetCollection options:_options];
    [_tableViewPhoto reloadData];
}
-(void)updateFetchRes{
    _assetsFetchResults= [PHAsset fetchAssetsWithOptions:_options];
    [_tableViewPhoto reloadData];
}

#pragma mark - Btn Methods
-(void)btnTabBarAddToClick:(UIButton*)btn{
    [_viewAlbumList setHidden:NO];
    [_viewAlbumList setFrame:CGRectMake(btn.frame.origin.x-5, _viewTabBar.frame.origin.y+btn.frame.origin.y-[_jcModel getAllAmount]*33-6, btn.frame.size.width*2+10, [_jcModel getAllAmount]*33+6)];
    CGFloat btnItemW=_viewAlbumList.frame.size.width-10;
    CGFloat btnItemH=30;

    for (int i=0; i<[_jcModel getAllAmount]; i++) {
        CGFloat btnOriginX =5;
        CGFloat btnOriginY =3+i*33;
        UIButton *btnItem = [[UIButton alloc] initWithFrame:CGRectMake(btnOriginX, btnOriginY, btnItemW, btnItemH)];
        btnItem.tag=i;
        [btnItem setBackgroundColor:[UIColor lightGrayColor]];
        [btnItem setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btnItem setTitle:[_jcModel getAllAlbumName][i] forState:UIControlStateNormal];
        [btnItem.layer setCornerRadius:5];
        [btnItem addTarget:self action:@selector(handleAddToAlbum:) forControlEvents:UIControlEventTouchUpInside];
        [_viewAlbumList addSubview:btnItem];
    }
}
-(void)handleAddToAlbum:(UIButton*)btn{
    NSString *strBtnName = btn.titleLabel.text;
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];

    PHImageRequestOptions *tryOp=[[PHImageRequestOptions alloc] init];
    tryOp.deliveryMode=PHImageRequestOptionsDeliveryModeHighQualityFormat;
    tryOp.resizeMode=PHImageRequestOptionsResizeModeExact;
    
    for (int i=0; i<_assetsFetchResults.count; i++) {
        if ([_cellSelectState[i] isEqual:@"1"]) {
            NSLog(@"选中了：%d",i);

            PHAsset *temAsset= _assetsFetchResults[i];
            [_imageManager requestImageForAsset:temAsset
                                     targetSize:SomeSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:tryOp
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      int intTime=[dateString intValue];
                                      intTime=intTime+i;;
                                      NSString *resTime=[NSString stringWithFormat:@"%d",intTime];
                                      
                                    NSString* nowAlbumPath =[NSString stringWithFormat:@"%@/%@/%@.jpg",docPath,strBtnName,resTime];
                                      
                                      [UIImagePNGRepresentation(result)writeToFile:nowAlbumPath    atomically:YES];
                                  }];
        }
    }
    [self clearAllState];
    [_tableViewPhoto reloadData];
}

-(void)btnChooseClick{
    if(_canDel){
        _canDel=false;
        [_viewTabBar setHidden:YES];
    }else{
        _canDel=true;
        [_viewTabBar setHidden:NO];
    }
}
-(void)btnTabBarDelClick{
    NSMutableArray *delAssets = [[NSMutableArray alloc] init];
    for (int i=0;i<_cellSelectState.count;i++) {
        if ([_cellSelectState[i] isEqual:@"1"]){
            PHAsset *temAsset = [_assetsFetchResults objectAtIndex:i];
            [delAssets addObject:temAsset];
        }
    }

    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:delAssets];

    } completionHandler:^(BOOL success, NSError *error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除成功"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self clearAllState];
            [self reFreshTableView];
        }];
        [alertController addAction:OKAction];
        
        [self presentViewController:alertController animated:YES completion:nil];

    }];

    
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
    
    [_tableViewPhoto reloadData];
}
//拍照后跳转到下面 imagePickerController
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
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
-(void)savePhoToSelectAlbum:(PHFetchResult<PHAsset *> *)temAsset andAlbumCollection:(PHAssetCollection*)collection{
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //--告诉系统，要操作哪个相册
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
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
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:order/3 inSection:0];

    if(_canDel){
        if([_cellSelectState[order] isEqual:@"0"]){
            [_cellSelectState replaceObjectAtIndex:order withObject:@"1"];
        }else{
            [_cellSelectState replaceObjectAtIndex:order withObject:@"0"];
        }
        [_tableViewPhoto reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }else{
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

        [cell setIntOriImageLeft:indexPath.row*3];
        
        if([_cellSelectState[indexPath.row*3] isEqual:@"1"]){
            [cell setSelectL];
        }else{
            [cell cancelSelectL];
        }
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

        [cell setIntOriImageMid:indexPath.row*3+1];
        
        if([_cellSelectState[indexPath.row*3+1] isEqual:@"1"]){
            [cell setSelectM];
        }else{
            [cell cancelSelectM];
        }

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

        [cell setIntOriImageRight:indexPath.row*3+2];
        
        if([_cellSelectState[indexPath.row*3+2] isEqual:@"1"]){
            [cell setSelectR];
        }else{
            [cell cancelSelectR];
        }
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
-(void)reFreshTableView{
    if([_delegate respondsToSelector:@selector(reFreshPublicTableView)]){
        [_delegate reFreshPublicTableView]; //在listVC中第一次初始化view时赋值
    }
    
    [_tableViewPhoto reloadData];
}
-(void)clearAllState{
    _canDel=false;
    [_viewTabBar setHidden:YES];
    [_cellSelectState removeAllObjects];
    [_viewAlbumList setHidden:YES];
    [_viewAlbumList.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];//清除子view
    for (int i=0; i<[_assetsFetchResults count]; i++) {
        [_cellSelectState addObject:@"0"];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.view sendSubviewToBack:self.navigationController.navigationBar];
    for (int i=0; i<[_assetsFetchResults count]; i++) {
        [_cellSelectState addObject:@"0"];
    }

}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
    [_cellSelectState removeAllObjects];
    
    [self clearAllState];
}
-(void)receiveJCModel:(JCModel *)jcModel{
    _jcModel=jcModel;
    [_jcModel show];
}
@end
