//
//  JCModel.m
//  PhotoKit
//
//  Created by 贾辰 on 17/2/27.
//  Copyright © 2017年 贾辰. All rights reserved.
//

#import "JCModel.h"

@interface JCModel()

@end

@implementation JCModel
-(void)setStrSysAlbum:(NSString *)strSysAlbum{
    _strSysAlbum=strSysAlbum;
}
-(void)setFetchResSysSelfAlbum:(PHFetchResult *)fetchResSysSelfAlbum{
    _fetchResSysSelfAlbum=fetchResSysSelfAlbum;
}
-(void)setArrayPrivateAlbum:(NSArray *)arrayPrivateAlbum{
    _arrayPrivateAlbum=arrayPrivateAlbum;
}
-(void)setIsSysAlbum:(BOOL)isSysAlbum{
    _isSysAlbum=isSysAlbum;
}
-(void)show{
    if (_isSysAlbum) {
        NSLog(@"当前选择的是相机胶卷，可选择数量为%d",[self getAllAmount]);
    }else{
       NSLog(@"当前选择的是自定义相册，可选择数量为%d",[self getAllAmount]);
    }
    NSLog(@"%@",[self getAllAlbumName]);
    
}
-(int)getAllAmount{
    int temAmount=0;
    temAmount=temAmount+(int)_arrayPrivateAlbum.count+(int)_fetchResSysSelfAlbum.count;
    return temAmount;
}
-(NSString*)getSysAlbumName{
    return @"相机胶卷";
}
-(NSMutableArray*)getAllAlbumName{
    NSMutableArray *arrayTem=[[NSMutableArray alloc] init];
    if(!_isSysAlbum){
        [arrayTem addObject:[self getSysAlbumName]];
    }
    int i=0;
    for(PHAssetCollection *assetCollection in _fetchResSysSelfAlbum) {
        if(!_isSysAlbum){
            if (i!=[self getSelectWhichAlbum]) {
                [arrayTem addObject:assetCollection.localizedTitle];
            }
        }else{
            [arrayTem addObject:assetCollection.localizedTitle];
        }
        i++;
    }
    for (int i=0; i<_arrayPrivateAlbum.count; i++) {
        [arrayTem addObject:_arrayPrivateAlbum[i]];
    }
    return arrayTem;
}

-(int)getSelWhich:(NSString*)name{
    if([_strSysAlbum isEqualToString:name]){
        return 1;
    }else if([self isBelongSelfAlbum:name]){
        return 2;
    }else if ([self isBelongPrivateAlbum:name]){
        return 3;
    }else{
        return -1;
    }
}
-(int)getSelSelfAlbumOrd:(NSString*)name{
    int i=0;
    for(PHAssetCollection *assetCollection in _fetchResSysSelfAlbum) {
        if ([name isEqualToString:assetCollection.localizedTitle]) {
            return i;
        }
        i++;
    }
    return -1;
}
-(BOOL)isBelongSelfAlbum:(NSString*)name{
    for(PHAssetCollection *assetCollection in _fetchResSysSelfAlbum) {
        if ([name isEqualToString:assetCollection.localizedTitle]) {
            return true;
        }
    }
    return false;
}
-(BOOL)isBelongPrivateAlbum:(NSString*)name{
    for (int i=0; i<_arrayPrivateAlbum.count; i++) {
        if ([name isEqualToString:_arrayPrivateAlbum[i]]) {
            return true;
        }
    }
    return  false;
}
-(int)getSelectWhichAlbum{
    return _selectWhichAlbum;
}
@end










