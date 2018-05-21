//
//  AddressViewController.m
//  Address-Objc
//
//  Created by Liu Chuan on 2018/10/4.
//  Copyright © 2018 LC. All rights reserved.
//

#import "AddressViewController.h"

#pragma mark - 宏定义
#define Province 0
#define City 1
#define Area 2
#define CellID  @"cellID"


@interface AddressViewController ()


#pragma mark - 属性
/**
 表格视图
 */
@property (strong, nonatomic) UITableView *tableView;

/**
 记录显示类型
 */
@property (assign, nonatomic)int displayType;

/**
 省
 */
@property (strong, nonatomic)NSArray *provinces;

/**
 市
 */
@property (strong, nonatomic)NSArray *citys;

/**
 区
 */
@property (strong, nonatomic)NSArray *areas;

/**
 选中的省
 */
@property (strong, nonatomic)NSString *selectedProvince;

/**
 选中的市
 */
@property (strong, nonatomic)NSString *selectedCity;

/**
 选中的区
 */
@property (strong, nonatomic)NSString *selectedArea;

/**
 当前选中的NSIndexPath
 */
@property (strong, nonatomic)NSIndexPath *selectedIndexPath;


@end

@implementation AddressViewController


#pragma mark - 系统回调函数
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTableView];
    [self configData];
}

#pragma mark - custom method

/**
 配置数据
 */
- (void)configData {
    if (self.displayType == Province) {
        //从文件读取地址字典
        NSString *addressPath = [[NSBundle mainBundle] pathForResource:@"address" ofType:@"plist"];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithContentsOfFile:addressPath];
        self.provinces = [dict objectForKey:@"address"];
    }
}

/**
 配置TableView
 */
- (void)configTableView {
    
    if (self.displayType == Province) { //只在选择省份页面显示取消按钮
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    }
    if (self.displayType == Area) {//只在选择区域页面显示确定按钮
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(submit)];
    }
    
    CGRect frame = [self.view bounds];
    self.tableView = [[UITableView alloc]initWithFrame: frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell self] forCellReuseIdentifier:CellID];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource
/// 每个分区有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.displayType == Province) {
        return self.provinces.count;
    }else if (self.displayType == City){
        return self.citys.count;
    }else{
        return self.areas.count;
    }
}
/// 每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID forIndexPath: indexPath];

    if (self.displayType == Province) {
        NSDictionary *province = self.provinces[indexPath.row];
        NSString *provinceName = [province objectForKey:@"name"];
        cell.textLabel.text= provinceName;
    }else if (self.displayType == City){
        NSDictionary *city = self.citys[indexPath.row];
        NSString *cityName = [city objectForKey:@"name"];
        cell.textLabel.text= cityName;
    }else{
        cell.textLabel.text= self.areas[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"unchecked"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.displayType == Province) {
        NSDictionary *province = self.provinces[indexPath.row];
        NSArray *citys = [province objectForKey:@"sub"];
        self.selectedProvince = [province objectForKey:@"name"];
        //构建下一级视图控制器
        AddressViewController *cityVC = [[AddressViewController alloc]init];
        cityVC.displayType = City;//显示模式为城市
        cityVC.citys = citys;
        cityVC.selectedProvince = self.selectedProvince;
        [self.navigationController pushViewController:cityVC animated:YES];
    }else if (self.displayType == City){
        NSDictionary *city = self.citys[indexPath.row];
        self.selectedCity = [city objectForKey:@"name"];
        NSArray *areas = [city objectForKey:@"sub"];
        //构建下一级视图控制器
        AddressViewController *areaVC = [[AddressViewController alloc]init];
        areaVC.displayType = Area;//显示模式为区域
        areaVC.areas = areas;
        areaVC.selectedCity = self.selectedCity;
        areaVC.selectedProvince = self.selectedProvince;
        [self.navigationController pushViewController:areaVC animated:YES];
    }
    else{
        //取消上一次选定状态
        UITableViewCell *oldCell =  [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        oldCell.imageView.image = [UIImage imageNamed:@"unchecked"];
        //勾选当前选定状态
        UITableViewCell *newCell =  [tableView cellForRowAtIndexPath:indexPath];
        newCell.imageView.image = [UIImage imageNamed:@"checked"];
        //保存
        self.selectedArea = self.areas[indexPath.row];
        self.selectedIndexPath = indexPath;
    }
}

-(void)submit{
    NSString *msg = [NSString stringWithFormat:@"%@-%@-%@",self.selectedProvince,self.selectedCity,self.selectedArea];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择地址" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
