//
//  PrivatePhotoListVC.m
//  PhotoKit
//
//  Created by 贾辰 on 17/1/16.
//  Copyright © 2017年 贾辰. All rights reserved.
//
#import "PhotoDetailTabCell.h"
#import "SinglePhotoVC.h"
#import "PrivatePhotoListVC.h"
#import <AVFoundation/AVFoundation.h>


@interface PrivatePhotoListVC ()<CellPhoto,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(assign,nonatomic)CGRect rect;
@property(strong,nonatomic)NSString* nameOfAlbum;
@property(strong,nonatomic)NSArray* arrayOfAlbum;
@property(strong,nonatomic)UITableView* tableview;
@property(strong,nonatomic)NSString* photoPath;
@property(strong,nonatomic)NSString* fullPath;
@property(strong,nonatomic)UIImagePickerController *imgPicker;
@end

@implementation PrivatePhotoListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    _rect=[[UIScreen mainScreen] bounds];
    // Do any additional setup after loading the view.
    
    UIView *viewTopBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _rect.size.width, 70)];
    viewTopBar.backgroundColor=[UIColor orangeColor];
    [self.view addSubview:viewTopBar];
    
    UIButton *btnCamera = [[UIButton alloc] initWithFrame:CGRectMake(_rect.size.width-180, 30, 50, 30)];
    [btnCamera setTitle:@"相机" forState:UIControlStateNormal];
    [btnCamera addTarget:self action:@selector(btnCameraClick) forControlEvents:UIControlEventTouchUpInside];
    [btnCamera setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCamera setBackgroundColor:[UIColor redColor]];
    [viewTopBar addSubview:btnCamera];

    //rect.size.height-70
    _tableview=[[UITableView alloc] initWithFrame:CGRectMake(0, 70, _rect.size.width,_rect.size.height-70) style:UITableViewStyleGrouped];
    _tableview.dataSource = self;
    _tableview.delegate = self;
    _tableview.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:_tableview];
    
    //监听拍照事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraNotification:) name:AVCaptureSessionDidStartRunningNotification object:nil];
}

-(void)receiveAlbumName:(NSString*)name andArray:(NSArray*)priAlbum{
    //befor viewDidLoad
    _nameOfAlbum=name;
    _arrayOfAlbum=priAlbum;
    NSLog(@"name:%@  and %@",name,priAlbum);
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
- (void)btnTakePhoto{
    [_imgPicker takePicture];         //确认拍照
    _imgPicker.sourceType =    UIImagePickerControllerSourceTypeCamera;
}
- (void)btnCancelCamera{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [_tableview reloadData];
}
//拍照后跳转到下面 imagePickerController
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    image=[self fixPhotoOrientation:image];
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd-hh-mm-ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* nowAlbumPath =[NSString stringWithFormat:@"%@/%@/%@",docPath,_nameOfAlbum,dateString];
    
    [UIImagePNGRepresentation(image)writeToFile:nowAlbumPath    atomically:YES];
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

-(void)showPhoto:(NSInteger)order{
    if(order<0){
        return;
    }
    
    SinglePhotoVC *sPhotoVC=[[SinglePhotoVC alloc] init];
    [self.navigationController pushViewController:sPhotoVC animated:YES];
    
    _photoPath=[NSString stringWithFormat:@"/%@/%@",_nameOfAlbum,[_arrayOfAlbum objectAtIndex:order]];
    _fullPath=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:_photoPath];
    UIImage* temImage= [[UIImage alloc] initWithContentsOfFile:_fullPath];
    [sPhotoVC calSize:temImage];
}

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
        
        [cell setMiniImageLeft:[self getThumbnail:temImage targetSize:CGSizeMake(8, 10)]];
        [cell setIntOriImageLeft:indexPath.row*3];
    }
    
    if(indexPath.row*3+1<_arrayOfAlbum.count)
    {
        _photoPath=[NSString stringWithFormat:@"/%@/%@",_nameOfAlbum,[_arrayOfAlbum objectAtIndex:(indexPath.row*3+1)]];
        _fullPath=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:_photoPath];
        UIImage* temImage= [[UIImage alloc] initWithContentsOfFile:_fullPath];
        [cell setMiniImageMid:[self getThumbnail:temImage targetSize:CGSizeMake(8, 10)]];
        [cell setIntOriImageMid:indexPath.row*3+1];
    }
    
    if(indexPath.row*3+2<_arrayOfAlbum.count)
    {
        _photoPath=[NSString stringWithFormat:@"/%@/%@",_nameOfAlbum,[_arrayOfAlbum objectAtIndex:(indexPath.row*3+2)]];
        _fullPath=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:_photoPath];
        UIImage* temImage= [[UIImage alloc] initWithContentsOfFile:_fullPath];
        [cell setMiniImageRight:[self getThumbnail:temImage targetSize:CGSizeMake(8, 10)]];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
