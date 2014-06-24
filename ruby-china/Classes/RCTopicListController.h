@interface RCRopicListController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property UITableView *tableView;
@property NSMutableArray *topics;

@end