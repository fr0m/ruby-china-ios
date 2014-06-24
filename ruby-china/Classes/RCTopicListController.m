#import <SDWebImage/UIImageView+WebCache.h>
#import "RCTopicListController.h"
#import "UIClearView.h"

@implementation RCRopicListController

- (void)viewDidLoad
{
    if (!self.title) self.title = @"Ruby China";
    self.topics = [@[] mutableCopy];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(loadData)];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIClearView new];
    [self.view addSubview:self.tableView];
    
    [self loadData];
}

- (void)loadData
{
    NSMutableString *url = [@"https://ruby-china.org/api/topics.json?per_page=30" mutableCopy];
//    [url appendString:[NSString stringWithFormat:@"&page=%i", self.currentPage]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self) return;
//            [self stopRefresh];
            if (connectionError) return;
            NSArray *topics = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            [self.topics addObjectsFromArray:topics];
//            self.productsCount = (int)[ret[@"products_count"] integerValue];
//            self.currentPage ++;
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
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopicListCell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TopicListCell"];
    NSDictionary *topic = self.topics[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = topic[@"title"];
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@] %@ %@", topic[@"node_name"], topic[@"user"][@"login"], [topic[@"replies_count"] intValue] > 0 ? [NSString stringWithFormat:@"· %@ ↵", topic[@"replies_count"]] : @""];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    [cell.imageView setImageWithURL:topic[@"user"][@"avatar_url"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        cell.imageView.transform = CGAffineTransformMakeScale(32 / cell.imageView.image.size.width, 32 / cell.imageView.image.size.height);
        [cell setNeedsLayout];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end