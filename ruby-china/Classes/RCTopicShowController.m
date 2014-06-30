#import <Bypass/Bypass.h>
#import <DateTools/NSDate+DateTools.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCTopicShowController.h"
#import "UIClearView.h"

@implementation RCTopicShowController

- (void)viewDidLoad
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(reply)];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIClearView new];
    [self.view addSubview:self.tableView];
    
    [self loadData];
}

- (void)loadData
{
    NSString *url = [NSString stringWithFormat:@"https://ruby-china.org/api/topics/%i.json", self.topicId];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self) return;
            if (connectionError) return;
            self.topic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            [self.tableView reloadData];
        });
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.topic) return 0;
    if ([self.topic[@"replies"] count] == 0) return 1;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
        case 1:
            return [self.topic[@"replies"] count];
        default:
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 1 ? [NSString stringWithFormat:@"%lu 个回复", [self.topic[@"replies"] count]] : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"TopicShowTitleCell"];
                    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TopicShowTitleCell"];
                    cell.textLabel.text = self.topic[@"title"];
                    cell.textLabel.textColor = [UIColor blackColor];
                    NSDateFormatter *dateFormatter = [NSDateFormatter new];
                    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";
                    NSString *created_at = [dateFormatter dateFromString:self.topic[@"created_at"]].timeAgoSinceNow;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ · %@", self.topic[@"user"][@"login"], created_at];
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                    [cell.imageView setImageWithURL:self.topic[@"user"][@"avatar_url"] placeholderImage:[UIImage imageNamed:@"transparent_64x64.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                        if (error) return;
                        cell.imageView.transform = CGAffineTransformMakeScale(32 / cell.imageView.image.size.width, 32 / cell.imageView.image.size.height);
                        [cell setNeedsLayout];
                    }];
                    break;
                }
                case 1: {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"TopicShowBodyCell"];
                    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TopicShowBodyCell"];
                    cell.textLabel.text = self.topic[@"body"];
//                    BPMarkdownView *markdownView = [[BPMarkdownView alloc] initWithFrame:CGRectMake(0, 0, 320, 160) markdown:self.topic[@"body"]];
//                    [cell addSubview:markdownView];
                }
                default:
                    break;
            }
            break;
        }
        case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TopicShowReplyCell"];
            if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TopicShowReplyCell"];
            NSDictionary *reply = self.topic[@"replies"][indexPath.row];
            cell.textLabel.text = reply[@"body"];
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";
            NSString *created_at = [dateFormatter dateFromString:reply[@"created_at"]].timeAgoSinceNow;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ · %@", reply[@"user"][@"login"], created_at];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            [cell.imageView setImageWithURL:reply[@"user"][@"avatar_url"] placeholderImage:[UIImage imageNamed:@"transparent_64x64.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                if (error) return;
                cell.imageView.transform = CGAffineTransformMakeScale(32 / cell.imageView.image.size.width, 32 / cell.imageView.image.size.height);
                [cell setNeedsLayout];
            }];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)reply
{
    
}

@end