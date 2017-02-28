//
//  JCModel.h
//  PhotoKit
//
//  Created by 贾辰 on 17/2/27.
//  Copyright © 2017年 贾辰. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Photos/Photos.h>

@interface JCModel : NSObject
@property(strong,nonatomic)NSString *strSysAlbum;
@property(strong,nonatomic)NSArray *arrayPrivateAlbum;
@property(strong,nonatomic)PHFetchResult *fetchResSysSelfAlbum;
@property(assign,nonatomic)BOOL isSysAlbum;
@property(assign,nonatomic)int selectWhichAlbum;
-(void)show;
-(int)getAllAmount;
-(NSMutableArray*)getAllAlbumName;
-(int)getSelWhich:(NSString*)name;
-(int)getSelSelfAlbumOrd:(NSString*)name;
@end
