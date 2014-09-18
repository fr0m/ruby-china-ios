#import "RCNodeListController.h"
#import "RCTopicListController.h"
#import "RCClearView.h"

@implementation RCNodeListController

- (void)viewDidLoad
{
    self.title = @"分类";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [[UIApplication sharedApplication].delegate window].backgroundColor;
    self.tableView.tableFooterView = [RCClearView new];
    [self.view addSubview:self.tableView];
    
    [self loadData];
}

- (void)loadData
{
    NSString *url = @"https://ruby-china.org/api/nodes.json";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self) return;
            if (connectionError) return;
            NSArray *nodes = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            self.sections = [@[] mutableCopy];
            [self.sections addObject:@{ @"nodes": [@[ @{ @"name": @"全部", @"sort": @0 } ] mutableCopy] }];
            for (int i = 0; i < nodes.count; i ++) {
                NSMutableDictionary *section;
                for (int j = 0; j < self.sections.count; j++) {
                    if (self.sections[j][@"id"] == nodes[i][@"section_id"]) {
                        section = self.sections[j];
                        break;
                    }
                }
                if (!section) {
                    section = [@{ @"id": nodes[i][@"section_id"], @"name": nodes[i][@"section_name"], @"nodes": [@[] mutableCopy] } mutableCopy];
                    [self.sections addObject:section];
                }
                [section[@"nodes"] addObject:nodes[i]];
            }
            for (int i = 0; i < self.sections.count; i ++) {
                [self.sections[i][@"nodes"] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [obj1[@"sort"] intValue] > [obj2[@"sort"] intValue];
                }];
            }
            [self.tableView reloadData];
        });
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.sections) return 0;
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section][@"nodes"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sections[section][@"name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NodeListCell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NodeListCell"];
    cell.textLabel.text = self.sections[indexPath.section][@"nodes"][indexPath.row][@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    RCTopicListController *topicListController = ((UINavigationController *)self.presentingViewController).childViewControllers[0];
    NSDictionary *node = self.sections[indexPath.section][@"nodes"][indexPath.row];
    topicListController.title = [node[@"name"] isEqualToString:@"全部"] ? @"Ruby China" : node[@"name"];
    topicListController.nodeId = node[@"id"];
//    [topicListController.tableView setContentOffset:CGPointZero animated:NO];
    [topicListController topRefresh];
    [self cancel];
    
}

- (void)cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end