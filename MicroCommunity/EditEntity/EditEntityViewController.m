//
//  EditEntityViewController.m
//  MicroCommunity
//
//  Created by IOS－001 on 14/12/22.
//  Copyright (c) 2014年 E-Techco Information Technologies Co., LTD. All rights reserved.
//

#import "EditEntityViewController.h"
#import "GCPlaceholderTextView.h"
#import "EditCategoryTableViewController.h"
#import "UIViewController+TopBarMessage.h"
#import "NSString+Color.h"

@interface EditEntityViewController ()

@property (nonatomic , weak) IBOutlet UIButton *categoryNameButton;
@property (nonatomic , weak) IBOutlet GCPlaceholderTextView *contentTextView;

@end

@implementation EditEntityViewController

- (InfoEntityModel *)editingEntityModel
{
    if (!_editingEntityModel) {
        _editingEntityModel = [[InfoEntityModel alloc] init];
    }
    return _editingEntityModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新增";
    // Do any additional setup after loading the view.
}

- (void)awakeFromNib
{
    self.categoryNameButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.categoryNameButton.titleLabel.minimumScaleFactor = 0.5;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.editingEntityModel.categoryModel.categoryName.length != 0) {
        //有类别了
        [self.categoryNameButton setTitle:self.editingEntityModel.categoryModel.categoryName forState:UIControlStateNormal];
        [self.categoryNameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.categoryNameButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.categoryNameButton.backgroundColor = [self.editingEntityModel.categoryModel.categoryBackHEXColor RGBStringToColor];
    } else {
        //暂无类别选择
        [self.categoryNameButton setTitle:@"请选择类别" forState:UIControlStateNormal];
        [self.categoryNameButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.categoryNameButton.backgroundColor = [UIColor whiteColor];
        self.categoryNameButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    
    if (self.editingEntityModel.contentText.length != 0 && self.contentTextView.text.length == 0) {
        self.contentTextView.text = self.editingEntityModel.contentText;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.view endEditing:YES]) {
        NSLog(@"键盘管不了");
    }
}

- (NSString *)fetchRightNowTimeStringWithFormatyyyyMMddHHmmss
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

- (IBAction)saveInfoEntityAction:(id)sender
{
    if (self.editingEntityModel.categoryModel.categoryId.length == 0) {
        [self showTopMessage:@"请选择类别"];
        return;
    }

    self.editingEntityModel.contentText = [self.contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.editingEntityModel.lastestCopyTimeStamp.length == 0) {
        self.editingEntityModel.lastestCopyTimeStamp = @"从未复制";
        self.editingEntityModel.copiedTimes = @"0";
    } else {
        //说明被复制过，就不去改动那个复制时间
        //当前是编辑模式
    }
    
    self.editingEntityModel.addedTimeStamp = [self fetchRightNowTimeStringWithFormatyyyyMMddHHmmss];
    
    if ([self.editingEntityModel insertIntoDatabase]) {
        NSLog(@"保存成功");
        [self showTopMessage:@"保存成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ChoseCategorySegue"]) {
        EditCategoryTableViewController *editCategoryVC = segue.destinationViewController;
        editCategoryVC.currentCategroyModel = self.editingEntityModel.categoryModel;
        editCategoryVC.parentVC = self;
    }
    [super prepareForSegue:segue sender:sender];
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
