//
//  ViewController.m
//  PhotoKit
//
//  Created by 贾辰 on 16/12/23.
//  Copyright © 2016年 贾辰. All rights reserved.
//

#import "ViewController.h"
#include <Photos/Photos.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)PHFetchResult *smartAlbums;
@property(strong,nonatomic)PHFetchResult *userAlbums;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getAlbumsInfo];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width ,[UIScreen mainScreen].bounds.size.height)];
    tableView.dataSource=self;
    tableView.delegate=self;
    [self.view addSubview:tableView];
    
//    NSIndexPath *start = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self tableView:tableView didSelectRowAtIndexPath:start];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"%lu,%lu",(unsigned long)_smartAlbums.count,(unsigned long)_userAlbums.count);
    if(section==0){
        return _smartAlbums.count;
    }else{
        return _userAlbums.count;
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CIdentifier];
    
    NSUInteger section = indexPath.section;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle   reuseIdentifier:CIdentifier];
    }
    
    
    if(section==0){
        PHCollection *temCollection = _smartAlbums[indexPath.row];
        PHAssetCollection *temAssetCollection = (PHAssetCollection *)temCollection;
        PHFetchResult *temFetchResult = [PHAsset fetchAssetsInAssetCollection:temAssetCollection options:nil];
        NSString *str = [NSString stringWithFormat:@"%lu",(unsigned long)temFetchResult.count];
        
        cell.detailTextLabel.text=str;
        cell.textLabel.text=temCollection.localizedTitle;
        
    }else{
        PHCollection *temCollection = _userAlbums[indexPath.row];
        PHAssetCollection *temAssetCollection = (PHAssetCollection *)temCollection;
        PHFetchResult *temFetchResult = [PHAsset fetchAssetsInAssetCollection:temAssetCollection options:nil];
        NSString *str = [NSString stringWithFormat:@"%lu",(unsigned long)temFetchResult.count];
        
        cell.detailTextLabel.text=str;
        cell.textLabel.text=temCollection.localizedTitle;
    }
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;                //设置四个分区
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 60;                 //其余分区宽度为20
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)getAlbumsInfo{
    //相机胶卷
    _smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //PHAssetCollectionType-SmartAlbum : 经由相机得来的相册
    //自定义
    _userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    

}

@end
