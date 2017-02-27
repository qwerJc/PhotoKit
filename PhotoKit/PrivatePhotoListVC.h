//
//  PrivatePhotoListVC.h
//  PhotoKit
//
//  Created by 贾辰 on 17/1/16.
//  Copyright © 2017年 贾辰. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PrivatePhotoViewCollector <NSObject>
-(void)reFreshPrivateTableView;
@end

@interface PrivatePhotoListVC : UIViewController

-(void)receiveAlbumName:(NSString*)name andArray:(NSArray*)priAlbum;

@property(weak,nonatomic)id<PrivatePhotoViewCollector> delegate;

@end
