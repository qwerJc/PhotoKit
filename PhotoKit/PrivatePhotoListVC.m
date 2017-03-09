//
//  PrivatePhotoListVC.m
//  PhotoKit
//
//  Created by 贾辰 on 17/1/16.
//  Copyright © 2017年 贾辰. All rights reserved.
//
#import "PhotoDetailTabCell.h"
#import "SinglePhoController.h"
#import "PrivatePhotoListVC.h"
#import <AVFoundation/AVFoundation.h>
#import "AFNetworking.h"
#import "CompressImg.h"

#define LAN @"192.168.253.21"

@interface PrivatePhotoListVC ()<CellPhoto,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(assign,nonatomic)CGRect rect;
@property(strong,nonatomic)UIView *viewTabBar;
@property(strong,nonatomic)NSString* nameOfAlbum;
@property(strong,nonatomic)NSArray* arrayOfAlbum;
@property(strong,nonatomic)UITableView* tableview;

@property(strong,nonatomic)NSString* photoPath;
@property(strong,nonatomic)NSString* fullPath;
@property(strong,nonatomic)UIImagePickerController *imgPicker;
@property(strong,nonatomic)NSString *docPath;
@property(assign,nonatomic)BOOL canDel;

@property(strong,nonatomic)NSMutableDictionary *delPath;


@property(strong,nonatomic)NSMutableArray* cellSelectState;

@property(strong,nonatomic)UIActivityIndicatorView *activityIndicatorView;

@property(strong,nonatomic)AFHTTPSessionManager *manager;

@end

@implementation PrivatePhotoListVC

-(id)init{
    self=[super init];
    
    [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
    _rect=[[UIScreen mainScreen] bounds];
    
    _docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    _delPath=[[NSMutableDictionary alloc] init];
    _cellSelectState=[[NSMutableArray alloc] init];
    
    self.tabBarController.tabBar.hidden=YES;
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    
    // Do any additional setup after loading the view.
    
    UIView *viewTopBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _rect.size.width, 70)];
    viewTopBar.backgroundColor=[UIColor orangeColor];
    [self.view addSubview:viewTopBar];
    
    UIButton *btnDel = [[UIButton alloc] initWithFrame:CGRectMake(_rect.size.width-290, 30, 70, 30)];
    [btnDel setTitle:@"Choose" forState:UIControlStateNormal];
    [btnDel addTarget:self action:@selector(btnDelClick) forControlEvents:UIControlEventTouchUpInside];
    [btnDel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDel setBackgroundColor:[UIColor redColor]];
    [viewTopBar addSubview:btnDel];
    
    UIButton *btnCamera = [[UIButton alloc] initWithFrame:CGRectMake(_rect.size.width-200, 30, 50, 30)];
    [btnCamera setTitle:@"相机" forState:UIControlStateNormal];
    [btnCamera addTarget:self action:@selector(btnCameraClick) forControlEvents:UIControlEventTouchUpInside];
    [btnCamera setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCamera setBackgroundColor:[UIColor redColor]];
    [viewTopBar addSubview:btnCamera];
    
    UIButton *btnPost=[[UIButton alloc] initWithFrame:CGRectMake(btnCamera.frame.origin.x+70, 30, 50, 30)];
    [btnPost setTitle:@"Post" forState:UIControlStateNormal];
    [btnPost addTarget:self action:@selector(btnPostClick) forControlEvents:UIControlEventTouchUpInside];
    [btnPost setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPost setBackgroundColor:[UIColor redColor]];
    [viewTopBar addSubview:btnPost];
    
    UIButton *btnGet=[[UIButton alloc] initWithFrame:CGRectMake(btnPost.frame.origin.x+70, 30, 50, 30)];
    [btnGet setTitle:@"get" forState:UIControlStateNormal];
    [btnGet addTarget:self action:@selector(btnGetClick) forControlEvents:UIControlEventTouchUpInside];
    [btnGet setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnGet setBackgroundColor:[UIColor redColor]];
    [viewTopBar addSubview:btnGet];
    
    //rect.size.height-70
    _tableview=[[UITableView alloc] initWithFrame:CGRectMake(0, 70, _rect.size.width,_rect.size.height-70) style:UITableViewStyleGrouped];
    _tableview.dataSource = self;
    _tableview.delegate = self;
    _tableview.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:_tableview];
    
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
    
    //监听拍照事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraNotification:) name:AVCaptureSessionDidStartRunningNotification object:nil];
    
    _activityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0,30,_rect.size.width,_rect.size.height)];
    _activityIndicatorView.center=self.view.center;
    [_activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_activityIndicatorView setBackgroundColor:[UIColor blackColor]];
    [_activityIndicatorView setAlpha:0.4];
    [self.view addSubview:_activityIndicatorView];
}

-(void)receiveAlbumName:(NSString*)name andArray:(NSArray*)priAlbum{
    //befor viewDidLoad
    _nameOfAlbum=name;
    _arrayOfAlbum=priAlbum;
    [_tableview reloadData];
//    NSLog(@"name:%@  and %@",name,priAlbum);    //是最新的数量，没错
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.view sendSubviewToBack:self.navigationController.navigationBar];
    for (int i=0; i<[_arrayOfAlbum count]; i++) {
        [_cellSelectState addObject:@"0"];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
    [_cellSelectState removeAllObjects];
    
    [[_manager operationQueue] cancelAllOperations];
    [_activityIndicatorView stopAnimating];
    
    [self clearAllState];
}
#pragma mark - Btn Methods
-(void)btnDelClick{
    if(_canDel){
        _canDel=false;
        [_viewTabBar setHidden:YES];
    }else{
        _canDel=true;
        [_viewTabBar setHidden:NO];
    }
}


//click btn of 'camera'
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
-(void)btnPostClick{
    [self clearAllState];
    [_tableview reloadData];
    [_activityIndicatorView startAnimating];
////////////////////////////////////////////////////////////////////////
    _manager = [AFHTTPSessionManager manager];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 设置请求参数

    NSDictionary *params = @{@"name" :_nameOfAlbum};
    
    int numOfTime = 0;
    
    for (int i =0; i<_arrayOfAlbum.count; i++) {
        numOfTime++;
        
    [_manager POST:[NSString stringWithFormat:@"http://%@/recImage2.php",LAN] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        

            _photoPath=[NSString stringWithFormat:@"/%@/%@",_nameOfAlbum,[_arrayOfAlbum objectAtIndex:i]];
            _fullPath=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:_photoPath];
            UIImage* temImage= [[UIImage alloc] initWithContentsOfFile:_fullPath];
            
            //-----------------------------------------------------//
            // 获取图片数据
            NSData *fileData = UIImageJPEGRepresentation(temImage, 1.0);

            NSString *fileName = [NSString stringWithFormat:@"%@", [_arrayOfAlbum objectAtIndex:i]];
            
            [formData appendPartWithFileData:fileData name:@"image" fileName:fileName mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
//        NSLog(@"%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSData *data = (NSData *)responseObject;
//        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"str = %@", str);
//          NSLog(@"this : %d",i);
        [_activityIndicatorView stopAnimating];
        
        if(numOfTime==_arrayOfAlbum.count){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"同步上传成功"
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

            }];

            [alertController addAction:OKAction];
            
            [self presentViewController:alertController animated:YES completion:nil];

        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [_activityIndicatorView stopAnimating];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"连接失败"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

        }];

        [alertController addAction:OKAction];
        }];
    }
}

////////////////btn3
-(void)btnGetClick{
    [self reFreshTableView];
    [self clearAllState];
    [_activityIndicatorView startAnimating];
    
    NSDictionary *params = @{@"name" :_nameOfAlbum};
    _manager = [AFHTTPSessionManager manager];
    
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
         [_manager POST:[NSString stringWithFormat:@"http://%@/showAllFile.php",LAN] parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable  responseObject) {
        [_activityIndicatorView stopAnimating];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        //        NSData - dictory
        NSDictionary *listDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
        NSArray *nameOfPhoto=[listDic objectForKey:@"name"];
        
        for (int i=0; i<[nameOfPhoto count]; i++) {
            NSString* nowAlbumPath =[NSString stringWithFormat:@"%@/%@/%@",_docPath,_nameOfAlbum,nameOfPhoto[i]];
            if(![self isFileExist:nowAlbumPath]){
                NSString *str = [NSString stringWithFormat:@"http://%@/%@/%@",LAN,_nameOfAlbum,nameOfPhoto[i]];
                NSURL *url = [NSURL URLWithString:str];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                
                
                [UIImagePNGRepresentation(image) writeToFile:nowAlbumPath atomically:YES];
            }
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"同步下载成功"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self reFreshTableView];
            [self clearAllState];
        }];

        [alertController addAction:OKAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 请求失败(500-相册不存在)
        [_activityIndicatorView stopAnimating];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"同步失败"
                                                                                     message:[error localizedDescription]
                                                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self clearAllState];
            [_tableview reloadData];
        }];

        [alertController addAction:OKAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }];
    

}
-(BOOL)isFileExist:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:path];
    return result;
}
#pragma mark - Take Photo Btn
-(void)btnTabBarDelClick{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    
    for (id key in _delPath) {
        id obj = [_delPath objectForKey:key];
        [fileManager removeItemAtPath:obj error:nil];
    }
    [self reFreshTableView];
    [self clearAllState];
    
}
- (void)btnTakePhoto{
    [_imgPicker takePicture];         //确认拍照
    _imgPicker.sourceType =    UIImagePickerControllerSourceTypeCamera;
}
- (void)btnCancelCamera{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self clearAllState];
    [self reFreshTableView];
}
//拍照后跳转到下面 imagePickerController
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    image=[self fixPhotoOrientation:image];
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    
    NSString* nowAlbumPath =[NSString stringWithFormat:@"%@/%@/%@.jpg",_docPath,_nameOfAlbum,dateString];
    
    
    [UIImagePNGRepresentation([CompressImg getThumbnail:image targetSize:CGSizeMake(80, 100)])writeToFile:nowAlbumPath atomically:YES];
    //应该用下面的存原图，上面的存缩略图
//    [UIImagePNGRepresentation(image)writeToFile:nowAlbumPath    atomically:YES];
    [_tableview reloadData];
}

//调整摄像照片的方向
-(UIImage*)fixPhotoOrientation:(UIImage*)originImg{
    // No-op if the orientation is already correct
    if (originImg.imageOrientation == UIImageOrientationUp) return originImg;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (originImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, originImg.size.width, originImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, originImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, originImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (originImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, originImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, originImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, originImg.size.width, originImg.size.height,
                                             CGImageGetBitsPerComponent(originImg.CGImage), 0,
                                             CGImageGetColorSpace(originImg.CGImage),
                                             CGImageGetBitmapInfo(originImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (originImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,originImg.size.height,originImg.size.width), originImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,originImg.size.width,originImg.size.height), originImg.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


//点击图片时调用
-(void)showPhoto:(NSInteger)order{
    if(order<0){
        return;
    }
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:order/3 inSection:0];
    _photoPath=[NSString stringWithFormat:@"/%@/%@",_nameOfAlbum,[_arrayOfAlbum objectAtIndex:order]];
    _fullPath=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:_photoPath];
    
    if(_canDel){
        //选择图片时若已存在则证明是第二次点击，删除
        if ([_delPath objectForKey:[NSString stringWithFormat:@"%ld",(long)order]]) {
            [_delPath removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)order]];
        }else{
            [_delPath setValue:_fullPath forKey:[NSString stringWithFormat:@"%ld",(long)order]];
        }
        
        //1代表选中，0未选，在cell渲染时根据此数组加载不同样式
        if([_cellSelectState[order] isEqual:@"0"]){
            [_cellSelectState replaceObjectAtIndex:order withObject:@"1"];
        }else{
            [_cellSelectState replaceObjectAtIndex:order withObject:@"0"];

        }
        
        [_tableview reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }else{
        NSLog(@"qwerewr");
        
        SinglePhoController *viewControllerSinglePho=[[SinglePhoController alloc] init];
        [self.navigationController pushViewController:viewControllerSinglePho animated:YES];

        UIImage* temImage= [[UIImage alloc] initWithContentsOfFile:_fullPath];
        [viewControllerSinglePho show:temImage];
        
        
    }
}
#pragma mark - UITableview Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int res=_arrayOfAlbum.count%3;
    if(res==0){
        return _arrayOfAlbum.count/3;
    }else{
        return _arrayOfAlbum.count/3+1;
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
//监听滑动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSIndexPath *path =  [_tableview indexPathForRowAtPoint:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y)];
//    NSLog(@"这是第%li行",(long)path.row);
}

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

//给每个cell赋图片
-(void)addPhoto:(PhotoDetailTabCell *)cell andIndxPath:(NSIndexPath *)indexPath{

    [cell setIntOriImageLeft:-1];
    [cell setIntOriImageMid:-1];
    [cell setIntOriImageRight:-1];
    
    [cell setMiniImageLeft:nil];
    [cell setMiniImageMid:nil];
    [cell setMiniImageRight:nil];
    
    if(indexPath.row*3<_arrayOfAlbum.count){

        _photoPath=[NSString stringWithFormat:@"/%@/%@",_nameOfAlbum,[_arrayOfAlbum objectAtIndex:indexPath.row*3]];
        _fullPath=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:_photoPath];
        UIImage* temImage= [[UIImage alloc] initWithContentsOfFile:_fullPath];
        

//        [cell setMiniImageLeft:[self getThumbnail:temImage targetSize:CGSizeMake(4, 5)]];
        //此处也应该用上面，注释下面的，下面两个同样
        [cell setMiniImageLeft:temImage];
        [cell setIntOriImageLeft:indexPath.row*3];
        
        if([_cellSelectState[indexPath.row*3] isEqual:@"1"]){
            [cell setSelectL];
        }else{
            [cell cancelSelectL];
        }
    }
    
    if(indexPath.row*3+1<_arrayOfAlbum.count)
    {
        _photoPath=[NSString stringWithFormat:@"/%@/%@",_nameOfAlbum,[_arrayOfAlbum objectAtIndex:(indexPath.row*3+1)]];
        _fullPath=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:_photoPath];
        UIImage* temImage= [[UIImage alloc] initWithContentsOfFile:_fullPath];

//        [cell setMiniImageMid:[self getThumbnail:temImage targetSize:CGSizeMake(4, 5)]];
        [cell setMiniImageMid:temImage];
        [cell setIntOriImageMid:indexPath.row*3+1];
        
        if([_cellSelectState[indexPath.row*3+1] isEqual:@"1"]){
            [cell setSelectM];
        }else{
            [cell cancelSelectM];
        }
    }
    
    if(indexPath.row*3+2<_arrayOfAlbum.count)
{
        _photoPath=[NSString stringWithFormat:@"/%@/%@",_nameOfAlbum,[_arrayOfAlbum objectAtIndex:(indexPath.row*3+2)]];
        _fullPath=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:_photoPath];
        UIImage* temImage= [[UIImage alloc] initWithContentsOfFile:_fullPath];

//        [cell setMiniImageRight:[self getThumbnail:temImage targetSize:CGSizeMake(4, 5)]];
        [cell setMiniImageRight:temImage];
        [cell setIntOriImageRight:indexPath.row*3+2];
        
        if([_cellSelectState[indexPath.row*3+2] isEqual:@"1"]){
            [cell setSelectR];
        }else{
            [cell cancelSelectR];
        }
    }
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

-(void)reFreshTableView{
    if([_delegate respondsToSelector:@selector(reFreshPrivateTableView)]){
        [_delegate reFreshPrivateTableView]; //在listVC中第一次初始化view时赋值
    }
    
    [_tableview reloadData];
}
-(void)clearAllState{
    _canDel=false;
    [_viewTabBar setHidden:YES];
    [_cellSelectState removeAllObjects];
    for (int i=0; i<[_arrayOfAlbum count]; i++) {
        [_cellSelectState addObject:@"0"];
    }
    [_delPath removeAllObjects];
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
