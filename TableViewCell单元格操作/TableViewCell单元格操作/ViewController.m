//
//  ViewController.m
//  TableViewCell单元格操作
//
//  Created by xrh on 2017/10/23.
//  Copyright © 2017年 xrh. All rights reserved.
//

/**
 设计思路：（1）可以通过继承和组合相结合的方式进行设计，对ViewController做一个父控制器的封装，把控制器上的一些共有的东西封装出来。再把tableView作为一个组合件拼接上来，tableView可以进行编辑
         （2）也可以直接用继承方式，在父控件中，有控制器和（可编辑）tableView的封装
 */

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)UITableView *gameTableView;
/** 底部删除按钮 */
@property (nonatomic ,strong)UIButton *deleteButton;
/** 数据源 */
@property (nonatomic ,copy)NSMutableArray *gameArrs;
/** 标记是否全选 */
@property (nonatomic ,assign)BOOL isAllSelected;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"单元格全选/多选操作";
    [self.view addSubview:self.gameTableView];
    [self setupBarButtonItem];
    [self.view addSubview:_deleteButton];
}

- (UITableView *)gameTableView {
    if (!_gameTableView) {
        _gameTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _gameTableView.delegate = self;
        _gameTableView.dataSource = self;
        _gameTableView.tableFooterView = [[UIView alloc] init];
        _gameTableView.backgroundColor = [UIColor whiteColor];
        _gameTableView.showsVerticalScrollIndicator = NO;
        /**
         设置可以编辑
         */
        self.gameTableView.allowsMultipleSelectionDuringEditing = YES;
    }
    return _gameTableView;
}

#pragma mark -- 导航栏点击按钮
- (void)setupBarButtonItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(edit:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
}

/**
 底部删除按钮
 */
- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_deleteButton setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.7f]];
        [_deleteButton setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 40)];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_deleteButton addTarget:self action:@selector(deleteArr) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

/**
 数据源
 */
- (NSMutableArray *)gameArrs {
    if (!_gameArrs) {
        _gameArrs = [NSMutableArray arrayWithArray:@[@"列表1",@"列表2",@"列表3",@"列表4",@"列表5",@"列表6",@"列表7",@"列表8",@"列表9",@"列表10",@"列表11",@"列表12",@"列表13",@"列表14",@"列表15",@"列表16",@"列表17",@"列表18",@"列表19",@"列表20",@"列表21",@"列表22",@"列表23",@"列表24"]];
    }
    return _gameArrs;
}

#pragma mark -- 编辑事件
- (void)edit:(UIBarButtonItem *)barButtonItem {
    
    /**
     每次点击，都把上次的点击记录给清除掉
     */
    self.isAllSelected = NO;
    
    NSString *string = !self.gameTableView.editing ? @"取消":@"编辑";
    barButtonItem.title = string;
    
    if (self.gameArrs.count) {
        self.navigationItem.leftBarButtonItem = !self.gameTableView.editing?[[UIBarButtonItem alloc]initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(selectAll:)] : nil;
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
        CGFloat height = !self.gameTableView.editing?40:0;
        [UIView animateWithDuration:0.25 animations:^{
            self.deleteButton.frame = CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height);
        }];
    } else {
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        
        
        [UIView animateWithDuration:0.25 animations:^{
           
            self.deleteButton.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 40);
        }];
    }
    
    self.gameTableView.editing = !self.gameTableView.editing;
}

#pragma mark -- 删除事件
- (void)deleteArr {
    
    NSMutableArray *deleteArrays = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in self.gameTableView.indexPathsForSelectedRows) {
        [deleteArrays addObject:self.gameArrs[indexPath.row]];
    }
    
    [UIView animateWithDuration:0 animations:^{
        [self.gameArrs removeObjectsInArray:deleteArrays];
        [self.gameTableView reloadData];
    } completion:^(BOOL finished) {
        if (!self.gameArrs.count) {
            [UIView animateWithDuration:0.25 animations:^{
                self.navigationItem.leftBarButtonItem = nil;
                self.navigationItem.rightBarButtonItem = nil;
                self.deleteButton.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 40);
            } completion:^(BOOL finished) {
                /** 考虑到全选之后 ，反选几个 再删除  需要将全选置为NO, */
                self.isAllSelected = NO;
            }];
        }
    }];
}

#pragma makr -- 全选事件
- (void)selectAll:(UIBarButtonItem *)barButtonItem {
    
    self.isAllSelected = !self.isAllSelected;
    NSString *string = !self.isAllSelected? @"全选" : @"取消全选";
    barButtonItem.title = string;
    for (int i = 0; i < self.gameArrs.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        
        if (self.isAllSelected) {
            [self.gameTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            
        } else { //反选
            [self.gameTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.gameArrs.count;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifi = @"gameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifi];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifi];
    }
    
    /**
     *  单元格的选中类型一定不能设置为 UITableViewCellSelectionStyleNone，如果加上这一句，全选勾选不出来
     */
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.text = self.gameArrs[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - 左滑删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.gameArrs removeObjectAtIndex:indexPath.row];
        [self.gameTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50.0f;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

@end
