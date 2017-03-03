//
//  ViewController.m
//  PhotoKit
//
//  Created by 贾辰 on 16/12/23.
//  Copyright © 2016年 贾辰. All rights reserved.
//
//  改进1:私密相册图片质量:存储的为压缩后的，，130行和289行，应该存两套
//  改进2:首页改为半模态视图&
        //    NSIndexPath *start = [NSIndexPath indexPathForRow:0 inSection:0];
        //    [self tableView:tableView didSelectRowAtIndexPath:start];
//  qbimagepicker 批量管理照片
//  改3 : 设置sel状态时，不刷新cell

//  移动照片时有的会移动不过去

//  php相册路径 ：／home／wwwroot／default
//  删除相册 rm －r 私1

//  同步所有
//  增删改查 － 类似版本管理的策略

//  改进1:能不能把低质量的换为缩略图，高质量的换为高清图
//  改进2:首页改为半模态视图&
        //    NSIndexPath *start = [NSIndexPath indexPathForRow:0 inSection:0];
        //    [self tableView:tableView didSelectRowAtIndexPath:start];
//  改进3：目前创建完相册cell并不能刷新，要重进才可以

//  进度：准备添加：新建私密相册的功能（弹出半模态视图），以及每个相册加个照相按钮（先显示该相册路径）


#import "ViewController.h"
#import "PhotoListVC.h"
#import "PrivatePhotoListVC.h"
#include <Photos/Photos.h>
#import "JCModel.h"

@interface ViewController ()<PrivatePhotoViewCollector,PublicPhotoViewCollector,UITableViewDelegate,UITableViewDataSource>

@property(strong,nonatomic)UIViewController *vcPhotoDetail;
@property(strong,nonatomic)PHFetchResult *selfDefineAssets;
@property(strong,nonatomic)PHFetchResult *cameraRollAssets;
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)PhotoListVC* vcPhotoList;
@property(strong,nonatomic)PrivatePhotoListVC *vcPriPhotoList;
@property(strong,nonatomic)NSString *pathDocuments;
@property(strong,nonatomic)NSArray *docList;
@property(strong,nonatomic)NSArray *privatePhoList;

@property(assign,nonatomic)NSInteger lastIndexPathRow;
@property(assign,nonatomic)NSInteger lastIndexPathSection;

@property(strong,nonatomic)JCModel *jcModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    
    _vcPhotoList=[[PhotoListVC alloc] init];
    _vcPriPhotoList=[[PrivatePhotoListVC alloc] init];
    _vcPhotoList.delegate=self;
    _vcPriPhotoList.delegate=self;
    
    
    
    //自定义相册
    _selfDefineAssets = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    _cameraRollAssets = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:nil];

    _pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _docList= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_pathDocuments error:nil];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,150, [UIScreen mainScreen].bounds.size.width ,[UIScreen mainScreen].bounds.size.height-300) style:UITableViewStyleGrouped];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
    
    UIButton *btnCreSysAlbum =[[UIButton alloc] initWithFrame:CGRectMake(40,_tableView.frame.size.height+_tableView.frame.origin.y+10, 120, 60)];
    [btnCreSysAlbum addTarget:self action:@selector(creSysAlbum) forControlEvents:UIControlEventTouchUpInside];
    [btnCreSysAlbum setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnCreSysAlbum setTitle:@"创建系统相册" forState:UIControlStateNormal];
    [btnCreSysAlbum setBackgroundColor:[UIColor orangeColor]];
    [self.view addSubview:btnCreSysAlbum];
    
    UIButton *btnCreSelfAlbum =[[UIButton alloc] initWithFrame:CGRectMake(180,_tableView.frame.size.height+_tableView.frame.origin.y+10, 120, 60)];
    [btnCreSelfAlbum addTarget:self action:@selector(creSelfAlbum) forControlEvents:UIControlEventTouchUpInside];
    [btnCreSelfAlbum setTitle:@"创建私密相册" forState:UIControlStateNormal];
    [btnCreSelfAlbum setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnCreSelfAlbum setBackgroundColor:[UIColor orangeColor]];
    [self.view addSubview:btnCreSelfAlbum];
    
}
#pragma mark - tableView
//添加编辑模式
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return NO;
    }else{
    return YES;
    }
}

//左滑动出现的文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

//删除所做的动作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d,%d",indexPath.section,indexPath.row);
    
    if (indexPath.section==1) {
        int temCount=0;
        for (PHAssetCollection *assetCollection in _selfDefineAssets) {
            if(temCount==indexPath.row)
            {
                
                NSArray *delAssetCollection=[[NSArray alloc] initWithObjects:assetCollection, nil];
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [PHAssetCollectionChangeRequest deleteAssetCollections:delAssetCollection];
                } completionHandler:^(BOOL success, NSError *error) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除成功"
                                                                                                 message:nil
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                            [self reloadAlbumInfo];
                        }];
                        
                        [alertController addAction:OKAction];

                        [self presentViewController:alertController animated:YES completion:nil];
                    
                    
                }];
                return;
            }
            temCount++;
        }

    }else{
        NSString *str=[_docList objectAtIndex:indexPath.row];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *createPath = [NSString stringWithFormat:@"%@/%@", pathDocuments,str];
        
        NSLog(@"%@",createPath);
        
        [fileManager removeItemAtPath:createPath error:nil];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除成功"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            _docList= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_pathDocuments error:nil];
            [_tableView reloadData];
        }];
        
        [alertController addAction:OKAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   //每个节点有几行
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return _selfDefineAssets.count;
            break;
        case 2:
            return _docList.count;
            break;
        default:
            return 0;
            break;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    //每个节点的名称
    switch (section) {
        case 0:
            return @"系统相册";
        case 1:
            return @"自定义相册";
        case 2:
            return @"私密相册";
        default:
            return @"Unknown";
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_jcModel==nil){
        _jcModel=[[JCModel alloc] init];
    }
    
    static NSString *CIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CIdentifier];
    
    NSUInteger section = indexPath.section;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle   reuseIdentifier:CIdentifier];
    }
    [_jcModel setStrSysAlbum:@"相机胶卷"];
    [_jcModel setFetchResSysSelfAlbum:_selfDefineAssets];
    [_jcModel setArrayPrivateAlbum:_docList];
    
    NSString *str;
    NSString *pathPrivateAlbum;
    PHCollection *temCollection;
    PHAssetCollection *temAssetCollection;
    switch (section) {
        case 0:
        {
            str = [NSString stringWithFormat:@"%lu",(unsigned long)_cameraRollAssets.count];
            cell.detailTextLabel.text=str;
            cell.textLabel.text=@"相机胶卷";
            break;
        }
        case 1:
        {
            temCollection = _selfDefineAssets[indexPath.row];
            temAssetCollection = (PHAssetCollection *)temCollection;
            PHFetchResult *temFetchResult = [PHAsset fetchAssetsInAssetCollection:temAssetCollection options:nil];
            str = [NSString stringWithFormat:@"%lu",(unsigned long)temFetchResult.count];
            cell.detailTextLabel.text=str;
            cell.textLabel.text=temCollection.localizedTitle;
            break;
        }
        case 2:
            cell.textLabel.text=[_docList objectAtIndex:indexPath.row];
            
            pathPrivateAlbum=[NSString stringWithFormat:@"%@/%@", _pathDocuments,cell.textLabel.text];
            _privatePhoList=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathPrivateAlbum error:nil];
             str = [NSString stringWithFormat:@"%lu",(unsigned long)_privatePhoList.count];
            cell.detailTextLabel.text=str;
            break;
        default:
            break;
    }
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;                //设置四个分区
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;                 //其余分区宽度为20
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{//选择相册
    int temCount;
    NSString *pathPrivateAlbum;
    switch (indexPath.section) {
        case 0:
            NSLog(@"选择的是：相机胶卷");
            [_vcPhotoList updateFetchRes];
            [self.navigationController pushViewController:_vcPhotoList animated:YES];

//            [_vcPhotoList setNowAssetCollection:nil];
            _lastIndexPathRow=indexPath.row;
            _lastIndexPathSection=indexPath.section;
            [_jcModel setIsSysAlbum:true];
            [_vcPhotoList receiveJCModel:_jcModel];

            break;
        case 1:
            temCount=0;
            for (PHAssetCollection *assetCollection in _selfDefineAssets) {
                if(temCount==indexPath.row)
                {
                    NSLog(@"选择的是: %@",assetCollection.localizedTitle);
                    [_jcModel setSelectWhichAlbum:temCount];
                    [_vcPhotoList updateFetchRes:assetCollection];
                }
                temCount++;
            }
            _lastIndexPathRow=indexPath.row;
            _lastIndexPathSection=indexPath.section;
            [_jcModel setIsSysAlbum:false];
            [_vcPhotoList receiveJCModel:_jcModel];
            [self.navigationController pushViewController:_vcPhotoList animated:YES];
            break;
        case 2:
            pathPrivateAlbum=[NSString stringWithFormat:@"%@/%@", _pathDocuments,[_docList objectAtIndex:indexPath.row]];
            _privatePhoList=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathPrivateAlbum error:nil];
            [_vcPriPhotoList receiveAlbumName:[_docList objectAtIndex:indexPath.row] andArray:_privatePhoList];
            _lastIndexPathRow=indexPath.row;
            [self.navigationController pushViewController:_vcPriPhotoList animated:YES];
        default:
            break;
    }
}

-(void)creSysAlbum{     //创建用户相册
    NSLog(@"creSysAlbum");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"新建系统相册"
                                                                             message:@"请输入相册名称"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder=@"新相册名称";
    }];
    
    //添加取消到UIAlertController中
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    //添加确定到UIAlertController中
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *str=alertController.textFields.firstObject.text;
//        NSLog(@"%@",str);
        
        if (![self isExistFolder:str]) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                //添加HUD文件夹
                [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:str];
                
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    UIAlertController *alertSuc = [UIAlertController alertControllerWithTitle:@"相册创建成功"
                                                                                      message:nil
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                    
                    [self presentViewController:alertSuc animated:YES completion:nil];
                    
                    //添加确定到UIAlertController中
                    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [self reloadAlbumInfo];
                    }];
                    [alertSuc addAction:OKAction];
                } else {
                    UIAlertController *alertSuc = [UIAlertController alertControllerWithTitle:@"相册创建失败"
                                                                                      message:nil
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                    
                    [self presentViewController:alertSuc animated:YES completion:nil];
                    
                    //添加确定到UIAlertController中
                    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                    [alertSuc addAction:OKAction];
                }
            }];
        }else{
            UIAlertController *alertSuc = [UIAlertController alertControllerWithTitle:@"相册已存在"
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:alertSuc animated:YES completion:nil];
            
            //添加确定到UIAlertController中
            UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertSuc addAction:OKAction];
            
        }
        
    }];
    [alertController addAction:OKAction];
    
    [self presentViewController:alertController animated:YES completion:nil];   //加入alert
    
}
- (BOOL)isExistFolder:(NSString *)folderName {      //判断当前相册是否存在
    //首先获取用户手动创建相册的集合
    PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    __block BOOL isExisted = NO;
    //对获取到集合进行遍历
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        //folderName是我们写入照片的相册
        if ([assetCollection.localizedTitle isEqualToString:folderName])  {
            isExisted = YES;
        }
    }];
    return isExisted;
}
-(void)reloadAlbumInfo{
    _selfDefineAssets = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];  //再获取一次，以便更新selDefineAssets的数量
    
    [_tableView reloadData];        //刷新tableview
}
-(void)creSelfAlbum{        //创建私密相册
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"新建私密相册"
                                                                             message:@"请输入相册名称"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder=@"新相册名称";
    }];
    
    //添加取消到UIAlertController中
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    
    //    添加确定到UIAlertController中
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *str=alertController.textFields.firstObject.text;
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *createPath = [NSString stringWithFormat:@"%@/%@", pathDocuments,str];
        
        if([str isEqualToString:@""]){
            UIAlertController *alertSuc = [UIAlertController alertControllerWithTitle:@"相册名不能为空"
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:alertSuc animated:YES completion:nil];
            
            //添加确定到UIAlertController中
            UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertSuc addAction:OKAction];
            return;
        }
        
        // 判断文件夹是否存在，如果不存在，则创建
        if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
            [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
            
            UIAlertController *alertSuc = [UIAlertController alertControllerWithTitle:@"私密相册创建成功"
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alertSuc animated:YES completion:nil];
            //添加确定到UIAlertController中
            UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                _docList= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_pathDocuments error:nil];
                [_tableView reloadData];
            }];
            [alertSuc addAction:OKAction];
            
        } else {
            UIAlertController *alertSuc = [UIAlertController alertControllerWithTitle:@"私密相册已存在"
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:alertSuc animated:YES completion:nil];
            
            //添加确定到UIAlertController中
            UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertSuc addAction:OKAction];
        }
    }
                               ];
    [alertController addAction:OKAction];
    
    
    
    [self presentViewController:alertController animated:YES completion:nil];

}
#pragma mark - refresh
-(void)reFreshPrivateTableView{
    NSString *pathPrivateAlbum=[NSString stringWithFormat:@"%@/%@", _pathDocuments,[_docList objectAtIndex:_lastIndexPathRow]];
    _privatePhoList=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathPrivateAlbum error:nil];
    [_vcPriPhotoList receiveAlbumName:[_docList objectAtIndex:_lastIndexPathRow] andArray:_privatePhoList];
}
-(void)reFreshPublicTableView{
    if (_lastIndexPathSection==0) {
        [_vcPhotoList updateFetchRes];
//        [_vcPhotoList setNowAssetCollection:nil];
    }else{
        int temCount=0;
        for (PHAssetCollection *assetCollection in _selfDefineAssets) {
            if(temCount==_lastIndexPathRow)
            {
                [_vcPhotoList updateFetchRes:assetCollection];
//                [_vcPhotoList setNowAssetCollection:assetCollection];
            }
            temCount++;
        }
    }
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
