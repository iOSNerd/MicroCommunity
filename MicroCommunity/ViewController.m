//
//  ViewController.m
//  MicroCommunity
//
//  Created by IOS－001 on 14/12/20.
//  Copyright (c) 2014年 E-Techco Information Technologies Co., LTD. All rights reserved.
//

#import "ViewController.h"
#import "ContentTableViewCell.h"
#import "EditEntityViewController.h"
#import "InfoEntityModel.h"
#import "EntityCategoryModel.h"
#import "UIViewController+TopBarMessage.h"
#import "MBProgressHUD.h"

@interface ViewController () <SWTableViewCellDelegate>
{
    NSIndexPath *editingIndexPath;
}
@property (nonatomic , strong) NSArray *rightButtons;
@property (nonatomic , strong) InfoEntityModel *listControlModel;

@end

@implementation ViewController

- (InfoEntityModel *)listControlModel
{
    if (!_listControlModel) {
        _listControlModel = [[InfoEntityModel alloc] init];
    }
    return _listControlModel;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"编辑"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"删除"];
    
    return rightUtilityButtons;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.title = @"微社区";
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.estimatedRowHeight = 136;
//    self.tableView.rowHeight = 136;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView reloadData];
    /*
    NSString *textPath = [[NSBundle mainBundle] pathForResource:@"Data2" ofType:@"txt"];
    NSError *error = nil;
    NSString *text = [NSString stringWithContentsOfFile:textPath encoding:NSUTF8StringEncoding error:&error];
    NSArray *texts = [text componentsSeparatedByString:@"\n"];
    
    NSLog(@"texts = %@",texts);
    NSDate *startDate = [[NSDate date] dateByAddingTimeInterval:-500];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    __block NSInteger i = 0;
    EntityCategoryModel *model = [[EntityCategoryModel alloc] init];
    __weak __typeof(self)weakSelf = self;
    [model fetchAllCategoriesWithCompletionHandler:^(NSArray *allCategories) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
    
        for (NSString *text in texts) {
            ++i;
            EntityCategoryModel *randomCategory = [strongSelf randomCategoryForCategories:allCategories];
            InfoEntityModel *model = [[InfoEntityModel alloc] init];
            model.contentText = text;
            model.copiedTimes = @"0";
            model.lastestCopyTimeStamp = @"从未复制";
            model.categoryModel = randomCategory;
            model.addedTimeStamp = [dateFormatter stringFromDate:[startDate dateByAddingTimeInterval:i]];
            NSLog(@"ID = %@",model.contentId);
            if (![model insertIntoDatabase]) {
                NSLog(@"texts =保存不成功！");
            } else {
//                sleep(1);
            }
        }
    }];
     */
}

- (EntityCategoryModel *)randomCategoryForCategories:(NSArray *)all
{
    NSInteger from = 0,to = all.count - 1;
    NSInteger target = arc4random() % (to - from + 1) + from;//target包括to和from
    return all[target];
}

- (NSString *)randomCopyTimesForEntities
{
    NSInteger from = 1,to = self.listControlModel.allInfoEntityModels.count;
    NSInteger target = arc4random() % (to - from + 1) + from;//target包括to和from
    return [NSString stringWithFormat:@"%@",@(target)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
    [self reloadDataSourceAndReloadTableView:YES];
//    });
    
}

- (IBAction)randomBarButtonAction:(UIBarButtonItem *)sender
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSLog(@"开始随机打乱");
        for (InfoEntityModel *tempModel in self.listControlModel.allInfoEntityModels) {
            tempModel.copiedTimes = [self randomCopyTimesForEntities];
            NSLog(@"新的复制cishu :%@",tempModel.copiedTimes);
            if (![tempModel updateInDatabase]) {
                NSLog(@"更新失败 - 打乱失败:%@",tempModel);
            }
        }
        [self reloadDataSourceAndReloadTableView:YES];
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        NSLog(@"Job's done");
    });
}


- (void)reloadDataSourceAndReloadTableView:(BOOL)shouldReload
{
    [self.listControlModel fetchAllEntitiesForAppFirstLoadingWithCompletionHandler:^(NSArray *allEntities) {
        if (!shouldReload) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.tableView reloadData];
        });
    }];
}

- (NSString *)fetchRightNowTimeStringWithFormatyyyyMMddHHmmss
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

- (void)copyActionForModel:(InfoEntityModel *)copiedModel
{
    //复制次数加一。上次复制时间更新
    copiedModel.copiedTimes = [NSString stringWithFormat:@"%ld",(copiedModel.copiedTimes.integerValue + 1)];
    copiedModel.lastestCopyTimeStamp = [self fetchRightNowTimeStringWithFormatyyyyMMddHHmmss];
    if (![copiedModel updateInDatabase]) {
        NSLog(@"复制后更新失败");
    } else {
        NSLog(@"更新tableview");
        [self reloadDataSourceAndReloadTableView:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listControlModel.allInfoEntityModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContentTableViewCellReuseKey" forIndexPath:indexPath];
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:70.0];
    cell.delegate = self;
    InfoEntityModel *tempModel = self.listControlModel.allInfoEntityModels[indexPath.row];
    cell.infoModel = tempModel;

    __weak __typeof(self)weakSelf = self;
    cell.copyButtonAction = ^(){
        [self.parentViewController showTopMessage:@"已经复制到粘贴板上！" ];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            UIPasteboard *pp = [UIPasteboard generalPasteboard];
            pp.string = tempModel.contentText;
            NSLog(@"一复制");
            
            //复制按钮动作
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf copyActionForModel:tempModel];
        });
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditEntitySegue"]) {
//        NSLog(@"传参");
        if (editingIndexPath) {
            EditEntityViewController *editEntityVC = segue.destinationViewController;
            InfoEntityModel *tempModel = self.listControlModel.allInfoEntityModels[editingIndexPath.row];
            editEntityVC.editingEntityModel = tempModel;
            editingIndexPath = nil;
        }
    }
    [super prepareForSegue:segue sender:sender];
}

#pragma mark -
#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (index) {
        case 0: {
            editingIndexPath = indexPath;
            [self performSegueWithIdentifier:@"EditEntitySegue" sender:self];
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1: {
            InfoEntityModel *tempModel = self.listControlModel.allInfoEntityModels[indexPath.row];
            if (![tempModel deleteInDatabase]) {
                NSLog(@"不知道为什么删除失败");
            } else {
                [self reloadDataSourceAndReloadTableView:NO];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            }
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

@end
