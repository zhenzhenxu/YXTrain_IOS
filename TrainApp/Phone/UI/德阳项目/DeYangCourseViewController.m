//
//  DeYangCourseViewController.m
//  TrainApp
//
//  Created by 郑小龙 on 2017/3/27.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "DeYangCourseViewController.h"
#import "YXCourseFilterView.h"
#import "YXCourseListFetcher.h"
#import "DeYangCourseListCell.h"
#import "YXCourseDetailViewController.h"
#import "DeYangCourseRecordViewController.h"
static  NSString *const trackPageName = @"课程列表页面";
@interface DeYangCourseViewController ()<YXCourseFilterViewDelegate>
@property (nonatomic, strong) YXCourseFilterView *filterView;
@property (nonatomic, strong) YXCourseListFilterModel *filterModel;
@property (nonatomic, strong) YXCourseListRequest *request;
@property (nonatomic, strong) YXErrorView *filterErrorView;
@property (nonatomic, assign) BOOL isNavBarHidden;

@property (nonatomic, assign) CGFloat oldOffsetY;
@property (nonatomic, assign) BOOL isAllowChange;
@property (nonatomic, assign) NSInteger chooseCourseInteger;


@end

@implementation DeYangCourseViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    YXCourseListFetcher *fetcher = [[YXCourseListFetcher alloc]init];
    fetcher.pid = [YXTrainManager sharedInstance].currentProject.pid;
    WEAK_SELF
    fetcher.filterBlock = ^(YXCourseListFilterModel *model){
        STRONG_SELF
        if (self.filterView) {
            return;
        }
        if (!self.filterModel) {
            self.filterModel = model;
        }
        [self dealWithFilterModel:self.filterModel];
    };
    self.dataFetcher = fetcher;
    self.bIsGroupedTableViewStyle = YES;
    [super viewDidLoad];
    
}
- (void)setupUI {
    self.chooseCourseInteger = -1;
    self.isAllowChange = YES;
    // Do any additional setup after loading the view.
    self.emptyView.title = @"没有符合条件的课程";
    self.emptyView.imageName = @"没有符合条件的课程";
    self.title = @"课程列表";
    [self setupRightWithTitle:@"看课记录"];
    [self setupObservers];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"dfe2e6"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[DeYangCourseListCell class] forCellReuseIdentifier:@"DeYangCourseListCell"];
    
    if (self.isWaitingForFilter) {
        self.filterErrorView = [[YXErrorView alloc]initWithFrame:self.view.bounds];
        WEAK_SELF
        self.filterErrorView.retryBlock = ^{
            STRONG_SELF
            [self getFilters];
        };
        [self getFilters];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCourseView:) name:kYXTrainSubmitQuestionAnswer object:nil];
}
- (void)refreshCourseView:(NSNotification *)aNotification {
    if (aNotification.object != nil) {
        [self.dataArray enumerateObjectsUsingBlock:^(YXCourseListRequestItem_body_module_course *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.courses_id isEqualToString:aNotification.object]) {
                NSInteger finish = MIN(obj.quiz.finish.integerValue + 1, obj.quiz.total.integerValue);
                obj.quiz.finish = [NSString stringWithFormat:@"%ld",(long)finish];
                *stop = YES;
            }
        }];
        [self.tableView reloadData];
    }else {
        
    }
    if (self.chooseCourseInteger >= 0) {
        YXCourseListRequestItem_body_module_course *course = self.dataArray[self.chooseCourseInteger];
        NSInteger finish = MIN(course.quiz.finish.integerValue + 1, course.quiz.total.integerValue);
        course.quiz.finish = [NSString stringWithFormat:@"%ld",(long)finish];
        DeYangCourseListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.chooseCourseInteger inSection:0]];
        cell.course = course;
        self.chooseCourseInteger = -1;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [YXDataStatisticsManger trackPage:trackPageName withStatus:YES];
    if (self.isNavBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.chooseCourseInteger = -1;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [YXDataStatisticsManger trackPage:trackPageName withStatus:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)getFilters{
    [self.request stopRequest];
    self.request = [[YXCourseListRequest alloc] init];
    self.request.pid = [YXTrainManager sharedInstance].currentProject.pid;
    self.request.pageindex = @"1";
    self.request.pagesize = @"10";
    [self startLoading];
    WEAK_SELF
    [self.request startRequestWithRetClass:[YXCourseListRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        [self stopLoading];
        if (error) {
            self.filterErrorView.frame = self.view.bounds;
            [self.view addSubview:self.filterErrorView];
            return;
        }
        [self.filterErrorView removeFromSuperview];
        
        YXCourseListRequestItem *item = (YXCourseListRequestItem *)retItem;
        self.filterModel = [item filterModel];
        self.isWaitingForFilter = NO;
        [self startLoading];
        [self firstPageFetch];
    }];
}
- (void)dealWithFilterModel:(YXCourseListFilterModel *)model{
    YXCourseFilterView *filterView = [[YXCourseFilterView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.filterView = filterView;
    for (YXCourseFilterGroup *group in model.groupArray) {
        NSMutableArray *array = [NSMutableArray array];
        for (YXCourseFilter *filter in group.filterArray) {
            [array addObject:filter.name];
        }
        [filterView addFilters:array forKey:group.name];
    }
    filterView.delegate = self;
    [self.view addSubview:filterView];
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(44);
    }];
}
- (void)setupObservers{
    WEAK_SELF
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kRecordReportSuccessNotification object:nil]subscribeNext:^(id x) {
        STRONG_SELF
        NSNotification *noti = (NSNotification *)x;
        NSString *course_id = noti.userInfo.allKeys.firstObject;
        NSString *record = noti.userInfo[course_id];
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YXCourseListRequestItem_body_module_course *course = (YXCourseListRequestItem_body_module_course *)obj;
            if ([course.courses_id isEqualToString:course_id]) {
                course.record = record;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                *stop = YES;
            }
        }];
    }];
}

- (void)naviRightAction{
    DeYangCourseRecordViewController *vc = [[DeYangCourseRecordViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeYangCourseListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeYangCourseListCell"];
    cell.course = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.chooseCourseInteger = indexPath.row;
    YXCourseListRequestItem_body_module_course *course = self.dataArray[indexPath.row];
    if (course.isSupportApp.boolValue) {
        YXCourseDetailViewController *vc = [[YXCourseDetailViewController alloc]init];
        vc.course = course;
        vc.isFromRecord = NO;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - YXCourseFilterViewDelegate
- (void)filterChanged:(NSArray *)filterArray{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.filterView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(44);
    }];
    // 学段
    NSNumber *num0 = filterArray[0];
    YXCourseFilterGroup *group0 = self.filterModel.groupArray[0];
    YXCourseFilter *segmentItem = group0.filterArray[num0.integerValue];
    // 学科
    NSNumber *num1 = filterArray[1];
    YXCourseFilterGroup *group1 = self.filterModel.groupArray[1];
    YXCourseFilter *studyItem = group1.filterArray[num1.integerValue];
    // 阶段
    NSNumber *num2 = filterArray[2];
    YXCourseFilterGroup *group2 = self.filterModel.groupArray[2];
    YXCourseFilter *stageItem = group2.filterArray[num2.integerValue];
    
    DDLogDebug(@"Changed: 学段:%@，学科:%@，阶段:%@",segmentItem.name,studyItem.name,stageItem.name);
    
    YXCourseListFetcher *fetcher = (YXCourseListFetcher *)self.dataFetcher;
    fetcher.studyid = studyItem.filterID;
    fetcher.segid = segmentItem.filterID;
    fetcher.stageid = stageItem.filterID;
    fetcher.type = @"0";//类型不进行筛选 默认全部
    [self startLoading];
    [self firstPageFetch];
}
#pragma mark scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentSize.height >= kScreenHeight -  44 + 10.0f){
        if (scrollView.contentSize.height - self.tableView.bounds.size.height < self.oldOffsetY && self.isAllowChange) {
            self.isNavBarHidden = YES;
            self.isAllowChange = NO;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            self.filterView.frame = CGRectMake(0, 20, self.view.bounds.size.width, 44);
            [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(0);
                make.top.mas_equalTo(64);
            }];
            return;
        }
        
        if (scrollView.contentOffset.y > self.oldOffsetY && self.isAllowChange) {
            self.isNavBarHidden = YES;
            self.isAllowChange = NO;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            self.filterView.frame = CGRectMake(0, 20, self.view.bounds.size.width, 44);
            [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(0);
                make.top.mas_equalTo(64);
            }];
        }
        if (scrollView.contentOffset.y < self.oldOffsetY && self.isAllowChange) {
            self.isNavBarHidden = NO;
            self.isAllowChange = NO;
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            self.filterView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
            [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(0);
                make.top.mas_equalTo(44);
            }];
        }
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.filterView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
        [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.mas_equalTo(44);
        }];
        self.isNavBarHidden = NO;
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.oldOffsetY = MAX(scrollView.contentOffset.y, 0.0f);
    self.isAllowChange = YES;
}
@end
