@interface RCNodeListController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property UITableView *tableView;
@property NSMutableArray *sections;

@end