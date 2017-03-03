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
    return (int)_arrayPrivateAlbum.count;
}
-(NSString*)getSysAlbumName{
    return @"相机胶卷";
}
-(NSMutableArray*)getAllAlbumName{
    NSMutableArray *arrayTem=[[NSMutableArray alloc] init];
    for (int i=0; i<_arrayPrivateAlbum.count; i++) {
        [arrayTem addObject:_arrayPrivateAlbum[i]];
    }
    return arrayTem;
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










