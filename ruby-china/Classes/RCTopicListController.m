#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>
#import <DateTools/NSDate+DateTools.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCNodeListController.h"
#import "RCTopicListController.h"
#import "RCTopicShowController.h"
#import "RCClearView.h"

@implementation RCTopicListController

- (void)viewDidLoad
{
    if (!self.title) self.title = @"Ruby China";
    self.topics = [@[] mutableCopy];
    
    self.navigationItem.leftBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"分类" style:UIBarButtonItemStylePlain target:self action:@selector(showNodeList)],
//        [[UIBarButtonItem alloc] initWithTitle:@"关于" style:UIBarButtonItemStylePlain target:self action:@selector(showAbout)]
    ];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(loadData)];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [[UIApplication sharedApplication].delegate window].backgroundColor;
    self.tableView.tableFooterView = [RCClearView new];
    [self.view addSubview:self.tableView];
    
    self.topRefreshControl = [UIRefreshControl new];
    self.topRefreshControl.tintColor = [[UIApplication sharedApplication].delegate window].tintColor;
    [self.topRefreshControl addTarget:self action:@selector(topRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.topRefreshControl];
    
    UIRefreshControl *bottomRefreshControl = [UIRefreshControl new];
    bottomRefreshControl.tintColor = [[UIApplication sharedApplication].delegate window].tintColor;
    [bottomRefreshControl endRefreshing];
    [bottomRefreshControl addTarget:self action:@selector(bottomRefresh) forControlEvents:UIControlEventValueChanged];
    self.tableView.bottomRefreshControl = self.bottomRefreshControl = bottomRefreshControl;

    [self topRefresh];
}

- (void)topRefresh
{
    self.topics = [@[] mutableCopy];
    self.currentPage = 1;
    [self loadData];
}

- (void)bottomRefresh
{
    [self loadData];
}

- (void)stopRefresh
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.refreshing = NO;
        [self.topRefreshControl endRefreshing];
        [self.tableView.bottomRefreshControl endRefreshing];
    });
}

- (void)loadData
{
    if (self.refreshing) return; else self.refreshing = YES;
    NSString *url = [NSString stringWithFormat:@"https://ruby-china.org/api/topics%@.json?per_page=30&page=%i", self.nodeId ? [NSString stringWithFormat:@"/node/%@", self.nodeId] : @"", self.currentPage];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self) return;
            [self stopRefresh];
            if (connectionError) return;
            NSArray *topics = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            [self.topics addObjectsFromArray:topics];
            self.currentPage ++;
            [self.tableView reloadData];
        });
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topics.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopicListCell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TopicListCell"];
    if (indexPath.row > self.topics.count) return cell;
    NSDictionary *topic = self.topics[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = topic[@"title"];
    cell.textLabel.numberOfLines = 2;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";
    NSString *replied_at = [dateFormatter dateFromString:topic[@"replied_at"] != [NSNull null] ? topic[@"replied_at"] : topic[@"created_at"]].timeAgoSinceNow;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@%@%@", self.nodeId ? @"" : [NSString stringWithFormat:@"[%@] · ", topic[@"node_name"]], topic[@"user"][@"login"], [NSString stringWithFormat:@" · %@", replied_at], [topic[@"replies_count"] intValue] > 0 ? [NSString stringWithFormat:@" · %@ ↵", topic[@"replies_count"]] : @""];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    [cell.imageView sd_setImageWithURL:topic[@"user"][@"avatar_url"] placeholderImage:[UIImage imageNamed:@"transparent_64x64.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) return;
        cell.imageView.transform = CGAffineTransformMakeScale(32 / cell.imageView.image.size.width, 32 / cell.imageView.image.size.height);
        [cell setNeedsLayout];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    RCTopicShowController *topicShowController = [RCTopicShowController new];
    topicShowController.title = self.topics[indexPath.row][@"title"];
    topicShowController.topicId = [self.topics[indexPath.row][@"id"] intValue];
    [self.navigationController pushViewController:topicShowController animated:YES];
}

- (void)showNodeList
{
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:[RCNodeListController new]] animated:YES completion:nil];
}

@end