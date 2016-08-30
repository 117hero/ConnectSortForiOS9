//
//  ContactTableViewCell.m
//  ContactsDemo
//
//  Created by even if on 16/7/26.
//  Copyright © 2016年 sz1card1. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "Common.h"

@implementation ContactTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        //头像
        _contactIcon = [[UIImageView alloc]initWithFrame:CGRectMake(16, (50 - 19) / 2.0 , 23, 23)];
        //_contactIcon.layer.cornerRadius = 40 / 2.0;
    
        _contactIcon.image = [UIImage imageNamed:@"未选中.png"];
        
        _contactIcon.clipsToBounds = YES;
        
        [self addSubview:_contactIcon];
        
        //名字label
        _contactName = [[UILabel alloc]initWithFrame:CGRectMake(_contactIcon.frame.origin.x + _contactIcon.frame.size.width + 13, 12, kScreenWidth - _contactIcon.frame.origin.x * 2 - _contactIcon.frame.size.width - 13, 18)];
        _contactName.textColor = TEXTCOLOR58;
        _contactName.font = [UIFont systemFontOfSize:16]
        ;
        [self addSubview:_contactName];
        //电话
        _contactPhoneNum = [[UILabel alloc]initWithFrame:CGRectMake(_contactName.frame.origin.x, _contactName.frame.size.height + _contactName.frame.origin.y + 2, _contactName.frame.size.width, 16)];
        _contactPhoneNum.textColor = TEXTCOLOR153;
        _contactPhoneNum.font = [UIFont systemFontOfSize:15];
        [self addSubview:_contactPhoneNum];
    }
    return self;
}


- (void)setModel:(ContactModel *)model{
    
    _model = model;
    
    //名字
    self.contactName.text = model.name;
    
    //电话
    self.contactPhoneNum.text = model.phoneNum;
    
    //头像
    if (model.isSelected==NO) {
        
        _contactIcon.image = [UIImage imageNamed:@"未选中.png"];
        
    }else{
        
        _contactIcon.image = [UIImage imageNamed:@"选中.png"];
        
    }
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
