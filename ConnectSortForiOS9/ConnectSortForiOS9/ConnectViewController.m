//
//  ConnectViewController.m
//  ConnectSortForiOS9
//
//  Created by anyongxue on 16/8/26.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "ConnectViewController.h"
#import <Contacts/Contacts.h>
#import "ContactModel.h"
#import "ContactTableViewCell.h"
#import "Common.h"

@interface ConnectViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating,UISearchBarDelegate>

@property (nonatomic,strong) UITableView * contactListTableView;  //展示表

@property (nonatomic,strong) NSMutableArray * contactArray;//原始数据

@property (nonatomic,strong) UISearchController * contactSearchController;//搜索视图，创建这个控制器只是为了使用它的searchbar
@property (nonatomic,strong) NSMutableArray * contactListDataArray;  //联系人数据源

@property (nonatomic,strong) NSMutableArray * contactSearchResultArray; //搜索结果数组

@property (nonatomic,strong)  UILabel * showContactCount;  //显示联系人数量

@property (nonatomic,strong) NSMutableArray * gropTitleArray; //索引数组

@property (nonatomic,strong) NSMutableArray * searchGropTitleArray; //搜索索引数组

@end

@implementation ConnectViewController

#pragma mark- 此demo是不弹出视图控制器获取的通讯录信息,iOS弹出视图控制器的方法网上有很多

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fanhui"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    [self.navigationItem setTitle:@"通讯录"];
    

    //----不弹出系统通讯录VC方法
    //1.AppDelegate里面导入<Contacts/Contacts.h>框架,授权
    
    //2.VC中新的方法,自建model,赋值数据
    
    //获取联系人列表信息
    [self getConnectList];
    
    //视图
    [self layout];
}

#pragma mark - 初始化数据
- (void)getConnectList{
    
    _contactListDataArray = [NSMutableArray array];
    
    _contactSearchResultArray = [NSMutableArray array];
    
    _searchGropTitleArray = [NSMutableArray array];
    
    _gropTitleArray = [NSMutableArray array];
    
    _contactArray = [NSMutableArray array];
    
    //ios9 新的方法
    if ([CNContactStore authorizationStatusForEntityType:0] == CNAuthorizationStatusAuthorized) {
        
        //如果被授权访问通讯录,进行访问相关操作
        CNContactStore *contactStore = [CNContactStore new];
        
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc]initWithKeysToFetch:@[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey,CNContactPhoneticFamilyNameKey]];
        
        NSError *error = nil;
        
        BOOL result = [contactStore enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            
            //赋值model
            //1.获取联系人的姓名
            ContactModel * model = [[ContactModel alloc]init];
            
            model.firstName = contact.givenName;
            
            model.lastName = contact.familyName;
            
            //对有无姓和名进行判断
            if (model.firstName && model.lastName) {
                
                model.name = [NSString stringWithFormat:@"%@%@",model.lastName, model.firstName];
                
                model.pinyinName = [self transform:model.name];
                
            }else if(!model.firstName){
                
                model.name = model.lastName;
                
                model.pinyinName = [self transform:model.name];
                
            }else{
                
                model.name = model.firstName;
                
                model.pinyinName = [self transform:model.name];
            }
            
            NSLog(@"%@",model.name);
            
            
            // 2.获取联系人的电话号码
            NSArray *phoneNums = contact.phoneNumbers;
            
            for (CNLabeledValue *labeledValue in phoneNums) {
                // 2.1.获取电话号码的KEY
                NSString *phoneLabel = labeledValue.label;
                
                // 2.2.获取电话号码
                CNPhoneNumber *phoneNumer = labeledValue.value;
                
                NSString *phoneValue = phoneNumer.stringValue;
                
                model.phoneNum = phoneValue;
                
                //去除数字以外的所有字符
                NSCharacterSet *setToRemove = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]
                                               invertedSet ];
                
                if (contact.phoneNumbers.count>0) {
                    
                    model.phoneNum  = [[phoneValue componentsSeparatedByCharactersInSet:setToRemove] componentsJoinedByString:@""];
                }
            }
            
            NSLog(@"%@",model.phoneNum);
            
            
            [_contactArray addObject:model];
            
            //名字为空,删除,可自行更改
            if ([model.name isEqualToString:@""]||[model.phoneNum length]== 0) {
                
                [_contactArray removeObject:model];
            }

        }];
        
        //分组
        NSDictionary * contactDic = [self makeGropWithDataArray:_contactArray];
        //排序
        NSArray * resultArray = [self sortDataWithDic:contactDic];
        
        _gropTitleArray = [NSMutableArray arrayWithArray:resultArray];
        
        for (NSString * str in resultArray)
        {
            NSArray * gropArr = contactDic[str];
            
            [_contactListDataArray addObject:gropArr];
        }
        
        
        [_contactListTableView reloadData];
        
        
        if (!result) {
            
            NSLog(@"读取失败,error:%@",error);
           
            return;
        }
        NSLog(@"读取成功");
        
    }

}

#pragma mark - 布局
-(void)layout
{
    //tableView
    _contactListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    
    _contactListTableView.backgroundColor = VIEWCONTROLLERBACKGROUNDCOLOR;
    
    [_contactListTableView setSeparatorColor:LINECOLOR];
    
    _contactListTableView.scrollsToTop = YES;
    
    _contactListTableView.delegate = self;
    
    _contactListTableView.dataSource = self;
    
    _contactListTableView.sectionIndexColor = [UIColor grayColor]; // 索引字体颜色
    
    [self.view addSubview:_contactListTableView];
    
    //搜索
    _contactSearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    _contactSearchController.searchBar.delegate = self;
    
    _contactSearchController.searchResultsUpdater = self;
    
    _contactSearchController.definesPresentationContext = YES;
    
    _contactSearchController.dimsBackgroundDuringPresentation = NO;
    
    _contactSearchController.hidesNavigationBarDuringPresentation = NO;
    
    [_contactSearchController.searchBar.layer setBorderColor:[UIColor colorWithRed:53 / 255.0 green:114 / 255.0 blue:214 / 255.0 alpha:1.0f].CGColor];
    
    for (UIView * searchBarSubview in _contactSearchController.searchBar.subviews)
    {
        if ([searchBarSubview isKindOfClass:NSClassFromString(@"UIView")] && searchBarSubview.subviews.count > 0) {
           
            [[searchBarSubview.subviews objectAtIndex:0] removeFromSuperview];
            
            for (UIView * view in searchBarSubview.subviews)
            {
                view.layer.cornerRadius = 5.0f;
                view.layer.borderWidth = 1.0;
                view.layer.borderColor = LINECOLOR.CGColor;
            }
            break;
        }
    }
    _contactSearchController.searchBar.placeholder=@"搜索";
   
    [_contactSearchController.searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
    
    [_contactSearchController.searchBar sizeToFit];
    
    _contactListTableView.tableHeaderView = _contactSearchController.searchBar;
    
    //底部联系人数据label
    _showContactCount = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    _showContactCount.textAlignment = NSTextAlignmentCenter;
   
    _showContactCount.backgroundColor = VIEWCONTROLLERBACKGROUNDCOLOR;
    
    _showContactCount.textColor = TEXTCOLOR153;
    
    _showContactCount.font = [UIFont systemFontOfSize:14];
    
    _showContactCount.text = [NSString stringWithFormat:@"共%ld位联系人",_contactArray.count];
    _contactListTableView.tableFooterView = _showContactCount;
}

#pragma mark - 分组
-(NSMutableDictionary *)makeGropWithDataArray:(NSArray *)array
{
    NSMutableDictionary * contactDic = [NSMutableDictionary dictionary];
    
    for (ContactModel * model in array)
    {
        if (model.pinyinName.length > 0) {
            
            char key = [model.pinyinName characterAtIndex:0];
            
            if (key >= 97 && key <= 122)
            {
                key = key - 32;
            }
            else if (key >= 65 && key <= 90)
            {
                key = key;
            }
            else
            {
                key = '#';
            }
            
            NSString * sortKey = [NSString stringWithFormat:@"%c",key];
            
            if ([contactDic objectForKey:sortKey] == nil)
            {
                NSMutableArray * arr = [NSMutableArray array];
                [arr addObject:model];
                [contactDic setObject:arr forKey:sortKey];
            }
            else
            {
                NSMutableArray * arr = [contactDic objectForKey:sortKey];
                [arr addObject:model];
            }
        }else{
            
            char key = '#';
            
            NSString * sortKey = [NSString stringWithFormat:@"%c",key];
            
            if ([contactDic objectForKey:sortKey] == nil)
            {
                NSMutableArray * arr = [NSMutableArray array];
                [arr addObject:model];
                [contactDic setObject:arr forKey:sortKey];
            }
            else
            {
                NSMutableArray * arr = [contactDic objectForKey:sortKey];
                [arr addObject:model];
            }
            
        }
    }
    
    return contactDic;
}

#pragma mark - 排序
-(NSArray *)sortDataWithDic:(NSDictionary *)contactDic
{
    NSArray * sortKeyArr = contactDic.allKeys;
    
    NSSortDescriptor * descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray * descriptors = [NSArray arrayWithObject:descriptor];
    
    NSArray * resultArray = [sortKeyArr sortedArrayUsingDescriptors:descriptors];
    
    NSMutableArray * resultArrM = [NSMutableArray arrayWithArray:resultArray];
    
    NSString * lastStr = resultArrM.firstObject;
    
    if ([lastStr isEqualToString:@"#"])
    {
        [resultArrM removeObjectAtIndex:0];
        
        [resultArrM addObject:lastStr];
    }
    
    return resultArrM;
}


#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_searchGropTitleArray.count > 0)
    {
        return _searchGropTitleArray.count;
    }
    return _gropTitleArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_searchGropTitleArray.count > 0)
    {
        return [_contactSearchResultArray[section] count];
    }
    return [_contactListDataArray[section] count];
}

#pragma mark - UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"contactListCell";
    
    ContactTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[ContactTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    ContactModel * model = [[ContactModel alloc]init];
    
    if (_searchGropTitleArray.count > 0)
    {
        model = _contactSearchResultArray[indexPath.section][indexPath.row];
        
        cell.model = model;
    }
    else
    {
        model = _contactListDataArray[indexPath.section][indexPath.row];
        
        cell.model = model;
    }
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

//组的头视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    
    headView.backgroundColor = LINECOLOR;
    
    
    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, kScreenWidth - 40, 20)];
    title.textColor = TEXTCOLOR58;
   
    title.font = [UIFont systemFontOfSize:14];
    
    if (_searchGropTitleArray.count > 0){
        
        title.text = _searchGropTitleArray[section];
        
    }else{
        
        title.text = _gropTitleArray[section];
    }
    
    [headView addSubview:title];
    
    return headView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (_searchGropTitleArray.count > 0)
    {
        return _searchGropTitleArray;
    }
    return _gropTitleArray;
}

//选中
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ContactTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [_contactSearchController.searchBar resignFirstResponder];
    
    NSLog(@"-------%@",cell.model.phoneNum);
    
    //更改选中/未选中的图标状态   更改为使用model.属性 ,不直接使用cell的属性
    if (cell.model.isSelected == NO) {
        
        cell.model.isSelected = YES;
        
    }else{
        
        cell.model.isSelected = NO;
    }

    [self.contactListTableView reloadData];

}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController;
{
    [_searchGropTitleArray removeAllObjects];
    
    [_contactSearchResultArray removeAllObjects];
    
    NSString * str = [NSMutableString stringWithString:searchController.searchBar.text];
    
    [str stringByReplacingOccurrencesOfString:@"   " withString:@""];
    
    NSMutableArray * searchDataArray = [NSMutableArray array];
    
    
    for (ContactModel * model in _contactArray)
    {
        if ([model.name rangeOfString:str].location != NSNotFound || [model.phoneNum rangeOfString:str].location != NSNotFound || [model.pinyinName rangeOfString:str].location != NSNotFound)
        {
            [searchDataArray addObject:model];
            
        }
    }
    
    NSDictionary * contactDic = [self makeGropWithDataArray:searchDataArray];
    
    NSArray * resultArray = [self sortDataWithDic:contactDic];
    
    _searchGropTitleArray = [NSMutableArray arrayWithArray:resultArray];
    
    for (NSString * str in resultArray)
    {
        NSArray * gropArr = contactDic[str];
        
        [_contactSearchResultArray addObject:gropArr];
    }
    
    _showContactCount.text = [NSString stringWithFormat:@"共%ld位联系人",searchDataArray.count];
    
    [_contactListTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [_searchGropTitleArray removeAllObjects];
    
    [_contactSearchResultArray removeAllObjects];
    
    [_contactListTableView reloadData];
    
    _showContactCount.text = [NSString stringWithFormat:@"共%ld位联系人",_contactArray.count];
}


//中文转换为拼音
- (NSString *)transform:(NSString *)chinese
{
    NSMutableString *pinyin = [chinese mutableCopy];
    
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    NSLog(@"%@", pinyin);
    
    return [pinyin uppercaseString];
}

- (void)backAction{
    
    [_contactSearchController.searchBar resignFirstResponder];
    
    _contactSearchController.searchBar.hidden = YES;
    
    [self.contactSearchController dismissViewControllerAnimated:YES completion:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
