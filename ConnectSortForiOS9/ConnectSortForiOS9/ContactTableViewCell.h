//
//  ContactTableViewCell.h
//  ContactsDemo
//
//  Created by even if on 16/7/26.
//  Copyright © 2016年 sz1card1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactModel.h"

@interface ContactTableViewCell : UITableViewCell

@property (nonatomic,strong) UIImageView * contactIcon;

@property (nonatomic,strong) UILabel * contactName;

@property (nonatomic,strong) UILabel * contactPhoneNum;

@property (nonatomic,assign)BOOL isSelected;

@property (nonatomic,strong)ContactModel *model;

@end
