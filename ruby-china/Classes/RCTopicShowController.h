@interface RCTopicShowController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property int topicId;
@property UITableView *tableView;
@property NSDictionary *topic;

@end