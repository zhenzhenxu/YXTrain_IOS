//
//  YXMyDatumViewController.m
//  TrainApp
//
//  Created by 李五民 on 16/6/20.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//

#import "YXMyDatumViewController.h"
#import "YXMyDatumFetcher.h"
#import "YXMyDatumCell.h"
#import "PersistentUrlDownloader.h"
#import "YXResourceCollectionRequest.h"
#import "YXDatumDelSourseRequest.h"
#import "YXAttachmentTypeHelper.h"

@interface YXMyDatumViewController ()<YXMyDatumCellDelegate>

@property (nonatomic, strong) YXMyDatumFetcher *myDatumFetcher;
@property (nonatomic, strong) PersistentUrlDownloader *downloader;
@property (nonatomic, strong) YXResourceCollectionRequest *collectionRequest;
@property (nonatomic, strong) YXDatumCellModel *currentDownloadingModel;
@property (nonatomic, strong) YXDatumDelSourseRequest *delSourceRequest;

@end

@implementation YXMyDatumViewController

- (void)viewDidLoad {
    [self setupDataFetcher];
    [super viewDidLoad];
    [self.tableView registerClass:[YXMyDatumCell class] forCellReuseIdentifier:@"YXMyDatumCell"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupDataFetcher{
    self.myDatumFetcher = [[YXMyDatumFetcher alloc]init];
    self.myDatumFetcher.pagesize = 20;
    self.dataFetcher = self.myDatumFetcher;
}

- (void)cancelDownload{
    // 如果是第一页则不取消，否则取消下载
    BOOL firstPageDownloading = FALSE;
    NSInteger count = [self.dataArray count];
    if (count > 20) {
        count = 20;
    }
    for (int i=0; i<count; i++) {
        YXDatumCellModel *model = self.dataArray[i];
        if (model.downloadState == DownloadStatusDownloading) {
            firstPageDownloading = TRUE;
            break;
        }
    }
    if (!firstPageDownloading && self.downloader.state == DownloadStatusDownloading) {
        [self.downloader stop];
        [self.downloader clear];
    }
}

- (void)tableViewWillRefresh{
    [self cancelDownload];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YXMyDatumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YXMyDatumCell" forIndexPath:indexPath];
    cell.cellModel = self.dataArray[indexPath.row];
    cell.delegate = self;
    // 对于第一页数据记录下载状态
    if (indexPath.row < 20) {
        if ([cell.cellModel.aid isEqualToString:self.currentDownloadingModel.aid]
            &&cell.cellModel.downloadState != DownloadStatusDownloading
            &&self.currentDownloadingModel.downloadState == DownloadStatusDownloading) {
            cell.cellModel.downloadState = DownloadStatusDownloading;
            cell.cellModel.downloadedSize = [BaseDownloader sizeStringForBytes:self.downloader.downloadedSizeByte];
            [self setupObserversWithCellModel:cell.cellModel];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView fd_heightForCellWithIdentifier:@"YXMyDatumCell" configuration:^(YXMyDatumCell *cell) {
        cell.cellModel = self.dataArray[indexPath.row];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YXDatumCellModel *data = self.dataArray[indexPath.row];
    if (data.downloadState == DownloadStatusDownloading) {
        return;
    }
    if (data.downloadState != DownloadStatusFinished) { // 没下载的在线预览
        YXFileVideoItem *item = [[YXFileVideoItem alloc]init];
        item.name = data.title;
        item.url = data.url;
        item.type = [YXAttachmentTypeHelper fileTypeWithTypeName:data.type];
        [YXFileBrowseManager sharedManager].fileItem = item;
        [YXFileBrowseManager sharedManager].baseViewController = self;
        [[YXFileBrowseManager sharedManager] browseFile];
        
    }else{
        YXFileVideoItem *item = [[YXFileVideoItem alloc]init];
        item.name = data.title;
        item.url = [PersistentUrlDownloader localPathForUrl:data.url];
        item.type = [YXAttachmentTypeHelper fileTypeWithTypeName:data.type];
        item.isLocal = YES;
        [YXFileBrowseManager sharedManager].fileItem = item;
        [YXFileBrowseManager sharedManager].baseViewController = self;
        [[YXFileBrowseManager sharedManager] browseFile];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    YXDatumCellModel *model = self.datumVC.dataArray[indexPath.row];
//    if ([model.uid isEqualToString:[YXUserManager sharedManager].userModel.uid]) {  // 我的上传
//        if (self.delSourceRequest) {
//            [self.delSourceRequest stopRequest];
//        }
//        self.delSourceRequest = [[YXDatumDelSourseRequest alloc] init];
//        self.delSourceRequest.resid = model.aid;
//        @weakify(self);
//        [self.datumVC startLoading];
//        [self.delSourceRequest startRequestWithDecodeClass:[YXRequestBaseItem class] completion:^(id responseObject, NSError *error) {
//            @strongify(self);
//            [self.datumVC stopLoading];
//            [self tableView:tableView handleDeleteDatumforIndexPath:indexPath withResponseItem:responseObject];
//        }];
//    }else{  // 我的收藏
//        if (self.collectionRequest) {
//            [self.collectionRequest stopRequest];
//        }
//        self.collectionRequest = [[YXResourceCollectionRequest alloc] init];
//        self.collectionRequest.aid = model.aid;
//        self.collectionRequest.type = model.type;
//        self.collectionRequest.iscollection = @"1";
//        @weakify(self);
//        [self.datumVC startLoading];
//        [self.collectionRequest startRequestWithDecodeClass:[YXRequestBaseItem class] completion:^(id responseObject, NSError *error) {
//            @strongify(self);
//            [self.datumVC stopLoading];
//            if (error) {
//                [self.datumVC yx_showToast:error.localizedDescription];
//            }
//            [self tableView:tableView handleDeleteDatumforIndexPath:indexPath withResponseItem:responseObject];
//        }];
//    }
}

- (void)tableView:(UITableView *)tableView handleDeleteDatumforIndexPath:(NSIndexPath *)indexPath withResponseItem:(HttpBaseRequestItem *)retItem{
//    YXDatumCellModel *model = self.datumVC.dataArray[indexPath.row];
//    if (retItem) {
//        // 如果当前项正在下载则需要先停止
//        if (model.downloadState == DownloadStatusDownloading) {
//            [self.downloader stop];
//        }
//        [PersistentUrlDownloader removeFile:model.url];
//        
//        model.isFavor = FALSE;
//        [self.datumVC.dataArray removeObjectAtIndex:indexPath.row];
//        [tableView beginUpdates];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [tableView endUpdates];
//        if ([self.datumVC.dataArray count] == 0) {
//            self.datumVC.emptyView.hidden = NO;
//        }
//    } else {
//        [tableView beginUpdates];
//        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        [tableView endUpdates];
//        //[self.datumVC yx_showToast:@"删除失败"];
//    }
}

#pragma mark - YXMyDatumCellDelegate
- (void)myDatumCellDownloadButtonClicked:(YXMyDatumCell *)myDatumCell{
    YXDatumCellModel *model = myDatumCell.cellModel;
    if (model.downloadState != DownloadStatusDownloading) { // 当前点击是未下载
        if (self.downloader.state == DownloadStatusDownloading) { // 当有任务下载时不能下载
            //[self.datumVC yx_showToast:@"已有任务正在下载中哦"];
            return;
        }else{
            // 先检查网络
            Reachability *r = [Reachability reachabilityForInternetConnection];
            if (![r isReachable]) {
                //[self.datumVC yx_showToast:@"网络异常，请稍候尝试"];
                return;
            }
            self.downloader = [[PersistentUrlDownloader alloc]init];
            [self.downloader setModel:model.url];
            [self setupObserversWithCellModel:model];
            [self.downloader start];
            self.currentDownloadingModel = model;
        }
    }else{
        [self.downloader stop];
        [self.downloader clear];
    }
}
- (void)setupObserversWithCellModel:(YXDatumCellModel *)model{
    @weakify(self);
    [RACObserve(self.downloader, state) subscribeNext:^(id x) {
        @strongify(self);
        if (!self) {
            return;
        }
        model.downloadState = self.downloader.state;
    }];
    [RACObserve(self.downloader, downloadedSizeByte) subscribeNext:^(id x) {
        @strongify(self);
        if (!self) {
            return;
        }
        model.downloadedSize = [BaseDownloader sizeStringForBytes:self.downloader.downloadedSizeByte];
    }];
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
