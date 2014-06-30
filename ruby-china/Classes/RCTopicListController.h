@interface RCTopicListController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property UITableView *tableView;
@property NSMutableArray *topics;
@property UIRefreshControl *topRefreshControl;
@property UIRefreshControl *bottomRefreshControl;
@property BOOL refreshing;
@property int currentPage;
@property NSNumber *nodeId;

- (void)topRefresh;

@end