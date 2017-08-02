//
//  BriefListViewController_17.m
//  TrainApp
//
//  Created by 郑小龙 on 2017/7/14.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "BriefListViewController_17.h"
#import "YXBriefListFetch.h"
#import "NoticeBriefCell_17.h"
#import "YXBroseWebView.h"
#import "NoticeAndBriefDetailViewController.h"
@interface BriefListViewController_17 ()

@end

@implementation BriefListViewController_17

- (void)viewDidLoad {
    self.bIsGroupedTableViewStyle = YES;
    YXBriefListFetch *fetcher = [[YXBriefListFetch alloc] init];
    self.dataFetcher = fetcher;
    [super viewDidLoad];
    [self startLoading];
    [self setupUI];
    [self setupLayout];
    [self firstPageFetch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - setup
- (void)setupUI {
    self.emptyView.imageName = @"暂无简报";
    self.emptyView.title = @"暂无简报";
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"dfe2e6"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[NoticeBriefCell_17 class] forCellReuseIdentifier:@"NoticeBriefCell_17"];
    [self.tableView registerClass:[YXSectionHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"YXSectionHeaderFooterView"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10.0f)];
    self.tableView.tableFooterView.backgroundColor = [UIColor colorWithHexString:@"dfe2e6"];
    
}
- (void)setupLayout {
    
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NoticeBriefCell_17 *cell = [tableView dequeueReusableCellWithIdentifier:@"NoticeBriefCell_17" forIndexPath:indexPath];
    cell.item = self.dataArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YXNoticeAndBulletinItem *item = self.dataArray[indexPath.row];
    if (item.isExtendUrl.boolValue) {
        YXNoticeAndBulletinItem *item = self.dataArray[indexPath.row];
        YXBroseWebView *webView = [[YXBroseWebView alloc] init];
        webView.urlString = item.url;
        webView.titleString = item.title;
        webView.sourceControllerTitile = self.title;
        [self.navigationController pushViewController:webView animated:YES];
    }else {
        NoticeAndBriefDetailViewController *VC = [[NoticeAndBriefDetailViewController alloc] init];
        VC.nbIdString = item.nbID;
        VC.titleString = item.title;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView fd_heightForCellWithIdentifier:@"NoticeBriefCell_17" configuration:^(NoticeBriefCell_17  *cell) {
        cell.item = self.dataArray[indexPath.row];
    }];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    YXSectionHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"YXSectionHeaderFooterView"];
    return headerView;
}
@end
