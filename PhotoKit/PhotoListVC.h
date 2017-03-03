//
//  PhotoListVC.h
//  PhotoKit
//
//  Created by 贾辰 on 17/1/4.
//  Copyright © 2017年 贾辰. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <Photos/Photos.h>
#import "JCModel.h"
@protocol PublicPhotoViewCollector <NSObject>
-(void)reFreshPublicTableView;
@end

@interface PhotoListVC : UIViewController
@property(strong,nonatomic)PHAssetCollection *nowAssetCollection;
-(void)updateFetchRes:(PHAssetCollection *)assetCollection;
-(void)updateFetchRes;
-(void)receiveJCModel:(JCModel *)jcModel;

@property(weak,nonatomic)id<PublicPhotoViewCollector> delegate;
@end
