//
//  Project_RootViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Project_RootViewController.h"
#import "Coding_NetAPIManager.h"
#import "LoginViewController.h"
#import "ProjectListView.h"
#import "ProjectViewController.h"
#import "HtmlMedia.h"
#import "UnReadManager.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "NProjectViewController.h"
#import "ProjectListCell.h"

#import "TweetSendViewController.h"
#import "EditTaskViewController.h"
#import "AddUserViewController.h"
#import "UsersViewController.h"
#import "Ease_2FA.h"
#import "PopMenu.h"
#import "PopFliterMenu.h"
#import "ProjectSquareViewController.h"
#import "SearchViewController.h"
#import "pop.h"
#import "FRDLivelyButton.h"

@interface Project_RootViewController ()<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSMutableDictionary *myProjectsDict;
@property (strong, nonatomic) UISearchDisplayController *mySearchDisplayController;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSString *searchString;
@property (nonatomic, strong) PopMenu *myPopMenu;
@property (nonatomic, strong) PopFliterMenu *myFliterMenu;
@property (nonatomic,assign) NSInteger selectNum;  //筛选状态
@property (nonatomic,strong)UIButton *leftNavBtn;
@property (nonatomic,strong)FRDLivelyButton *rightNavBtn;
@property (nonatomic,strong)UIView *searchView;

@end

@implementation Project_RootViewController

#pragma mark TabBar
- (void)tabBarItemClicked{
    [super tabBarItemClicked];
    if (_myCarousel.currentItemView && [_myCarousel.currentItemView isKindOfClass:[ProjectListView class]]) {
        ProjectListView *listView = (ProjectListView *)_myCarousel.currentItemView;
        [listView tabBarItemClicked];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSegmentItems];
    
    _useNewStyle=TRUE;
    
    _oldSelectedIndex = 0;
    _selectNum=0;
//    self.title = @"项目";
    _myProjectsDict = [[NSMutableDictionary alloc] initWithCapacity:_segmentItems.count];
    
    //添加myCarousel
    _myCarousel = ({
        iCarousel *icarousel = [[iCarousel alloc] init];
        icarousel.dataSource = self;
        icarousel.delegate = self;
        icarousel.decelerationRate = 1.0;
        icarousel.scrollSpeed = 1.0;
        icarousel.type = iCarouselTypeLinear;
        icarousel.pagingEnabled = YES;
        icarousel.clipsToBounds = YES;
        icarousel.bounceDistance = 0.2;
        [self.view addSubview:icarousel];
        [icarousel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.bottom.equalTo(self.view);
//            make.top.equalTo(self.view).offset(kMySegmentControl_Height);
            make.edges.equalTo(self.view);
        }];
        icarousel;
    });
    
//    //添加搜索框
//    _mySearchBar = ({
//            UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0, kScreen_Width-110, 31)];
//            searchBar.layer.cornerRadius=15;
//            searchBar.layer.masksToBounds=TRUE;
//            [searchBar.layer setBorderWidth:8];
//            [searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];  //设置边框为白色
//            [searchBar sizeToFit];
//            searchBar.delegate = self;
//            [searchBar setPlaceholder:@"项目/任务/讨论/冒泡等"];
//            UITextField *searchField= [[[[searchBar subviews] firstObject] subviews] lastObject];
////            [searchField setHeight:22];
////            searchField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
////            [searchField setBackgroundColor:[UIColor blueColor]];
//            [(UIImageView*)[searchField leftView] setFrame:CGRectMake(0, 0, 13, 13)];
//            [(UIImageView*)[searchField leftView] setImage:[UIImage imageNamed:@"icon_search_searchbar"]];
//            [searchBar setImage:[UIImage imageNamed:@"icon_search_searchbar"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
//            [searchBar setTintColor:[UIColor whiteColor]];
//            [searchBar insertBGColor:[UIColor colorWithHexString:@"0x28303b"]];
//            [searchBar setHeight:31];
//            searchBar;
//        });
    
    //添加搜索框
    _mySearchBar = ({
        MainSearchBar *searchBar = [[MainSearchBar alloc] initWithFrame:CGRectMake(60,7, kScreen_Width-115, 31)];
        [searchBar setPlaceholder:@"项目/任务/讨论/冒泡等"];
        searchBar.delegate = self;
        searchBar.layer.cornerRadius=15;
        searchBar.layer.masksToBounds=TRUE;
        [searchBar.layer setBorderWidth:8];
        [searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];//设置边框为白色
        [searchBar sizeToFit];
        [searchBar setTintColor:[UIColor whiteColor]];
        [searchBar insertBGColor:[UIColor colorWithHexString:@"0xffffff"]];
        //        [searchBar setImage:nil forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        //        [searchBar setPositionAdjustment:UIOffsetMake(10,0) forSearchBarIcon:UISearchBarIconClear];
        //        searchBar.searchTextPositionAdjustment=UIOffsetMake(10,0);
        [searchBar setHeight:30];
        searchBar;
    });


//    _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width-110, 31)];//allocate titleView
//    UIColor *color = [UIColor colorWithHexString:[NSObject baseURLStrIsTest]? @"0x3bbd79" : @"0x28303b"];
//    [_searchView setBackgroundColor:color];
    
    
    
    __weak typeof(_myCarousel) weakCarousel = _myCarousel;
    
    //初始化过滤目录
    _myFliterMenu = [[PopFliterMenu alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height-64) items:nil];
//    _myFliterMenu = [[PopFliterMenu alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) items:nil];

    __weak typeof(self) weakSelf = self;
    _myFliterMenu.clickBlock = ^(NSInteger pageIndex){
        if (pageIndex==1000) {
            [weakSelf goToProjectSquareVC];
        }else
        {
            [weakSelf fliterBtnClose:TRUE];
            [weakCarousel scrollToItemAtIndex:pageIndex animated:NO];
            weakSelf.selectNum=pageIndex;
        }
    };
    
    _myFliterMenu.closeBlock=^(){
        [weakSelf closeFliter];
    };
    
    //初始化弹出菜单
    NSArray *menuItems = @[
                           [MenuItem itemWithTitle:@"项目" iconName:@"pop_Project" index:0],
                           [MenuItem itemWithTitle:@"任务" iconName:@"pop_Task" index:1],
                           [MenuItem itemWithTitle:@"冒泡" iconName:@"pop_Tweet" index:2],
                           [MenuItem itemWithTitle:@"添加好友" iconName:@"pop_User" index:3],
                           [MenuItem itemWithTitle:@"私信" iconName:@"pop_Message" index:4],
                           [MenuItem itemWithTitle:@"两步验证" iconName:@"pop_2FA" index:5],
                           ];
    if (!_myPopMenu) {
        _myPopMenu = [[PopMenu alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height-64) items:menuItems];
        _myPopMenu.perRowItemCount = 3;
        _myPopMenu.menuAnimationType = kPopMenuAnimationTypeSina;
    }
    @weakify(self);
    _myPopMenu.didSelectedItemCompletion = ^(MenuItem *selectedItem){
        [weakSelf.myPopMenu.realTimeBlurFooter disMiss];
        [MobClick event:kUmeng_Event_Request_ActionOfLocal label:[NSString stringWithFormat:@"快捷创建_%@", selectedItem.title]];
        @strongify(self);
        //改下显示style
        [self.rightNavBtn setStyle:kFRDLivelyButtonStylePlus animated:YES];
        if (!selectedItem) return;
        switch (selectedItem.index) {
            case 0:
                [self goToNewProjectVC];
                break;
            case 1:
                [self goToNewTaskVC];
                break;
            case 2:
                [self goToNewTweetVC];
                break;
            case 3:
                [self goToAddUserVC];
                break;
            case 4:
                [self goToMessageVC];
                break;
            case 5:
                [self goTo2FA];
                break;
            default:
                NSLog(@"%@",selectedItem.title);
                break;
        }
    };
    
    [self setupNavBtn];
    self.icarouselScrollEnabled = NO;
}

- (void)setIcarouselScrollEnabled:(BOOL)icarouselScrollEnabled{
    _myCarousel.scrollEnabled = icarouselScrollEnabled;
}

- (void)setupNavBtn{
    
    _leftNavBtn=[UIButton new];
    [self addImageBarButtonWithImageName:@"filtertBtn_normal_Nav" button:_leftNavBtn action:@selector(fliterClicked:) isRight:NO];
    
    //变化按钮
    _rightNavBtn = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(0,0,18.5,18.5)];
    [_rightNavBtn setOptions:@{ kFRDLivelyButtonLineWidth: @(1.0f),
                          kFRDLivelyButtonColor: [UIColor whiteColor]
                          }];
    [_rightNavBtn setStyle:kFRDLivelyButtonStylePlus animated:NO];
    [_rightNavBtn addTarget:self action:@selector(addItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightNavBtn];
    self.navigationItem.rightBarButtonItem = buttonItem;

//    __weak typeof(_myCarousel) weakCarousel = _myCarousel;

    //添加滑块
//    _mySegmentControl = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height) Items:_segmentItems selectedBlock:^(NSInteger index) {
//        if (index == _oldSelectedIndex) {
//            return;
//        }
//        [weakCarousel scrollToItemAtIndex:index animated:NO];
//    }];
//    [self.view addSubview:_mySegmentControl];


//    [self addImageBarButtonWithImageName:@"addBtn_Nav" button:_rightNavBtn action:@selector(addItemClicked:) isRight:YES];

}

- (void)configSegmentItems{
    _segmentItems = @[@"全部项目",@"我创建的", @"我参与的",@"我关注的",@"我收藏的"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.navigationItem.titleView sizeToFit];
//    [_searchView addSubview:_mySearchBar];
//    self.navigationItem.titleView = _searchView;

    [self.navigationController.navigationBar addSubview:_mySearchBar];

    
    if (_myCarousel) {
        ProjectListView *listView = (ProjectListView *)_myCarousel.currentItemView;
        if (listView) {
            [listView refreshToQueryData];
        }
    }
    [_myFliterMenu refreshMenuDate];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mySearchBar removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UnReadManager shareManager] updateUnRead];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return _segmentItems.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    Projects *curPros = [_myProjectsDict objectForKey:[NSNumber numberWithUnsignedInteger:index]];
    if (!curPros) {
        curPros = [self projectsWithIndex:index];
        [_myProjectsDict setObject:curPros forKey:[NSNumber numberWithUnsignedInteger:index]];
    }
    ProjectListView *listView = (ProjectListView *)view;
    if (listView) {
        [listView setProjects:curPros];
    }else{
        __weak Project_RootViewController *weakSelf = self;
        listView = [[ProjectListView alloc] initWithFrame:carousel.bounds projects:curPros block:^(Project *project) {
            [weakSelf goToProject:project];

            DebugLog(@"\n=====%@", project.name);
        } tabBarHeight:CGRectGetHeight(self.rdv_tabBarController.tabBar.frame)];
        
        listView.clickButtonBlock=^(EaseBlankPageType curType) {
            switch (curType) {
                case EaseBlankPageTypeProject_ALL:
                case EaseBlankPageTypeProject_CREATE:
                case EaseBlankPageTypeProject_JOIN:
                    [weakSelf goToNewProjectVC];
                    break;
                case EaseBlankPageTypeProject_WATCHED:
                case EaseBlankPageTypeProject_STARED:
                    [weakSelf goToProjectSquareVC];
                    break;
                default:
                    break;
            }
        };

        //使用新系列Cell样式
        listView.useNewStyle=_useNewStyle;

    }
    [listView setSubScrollsToTop:(index == carousel.currentItemIndex)];
    return listView;
}

- (Projects *)projectsWithIndex:(NSUInteger)index{
    return [Projects projectsWithType:index andUser:nil];
}

- (void)carouselDidScroll:(iCarousel *)carousel{
    [self.view endEditing:YES];
    if (_mySegmentControl) {
        float offset = carousel.scrollOffset;
        if (offset > 0) {
            [_mySegmentControl moveIndexWithProgress:offset];
        }
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    if (_mySegmentControl) {
        _mySegmentControl.currentIndex = carousel.currentItemIndex;
    }
    if (_oldSelectedIndex != carousel.currentItemIndex) {
        _oldSelectedIndex = carousel.currentItemIndex;
        ProjectListView *curView = (ProjectListView *)carousel.currentItemView;
        [curView refreshToQueryData];
    }
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj setSubScrollsToTop:(obj == carousel.currentItemView)];
    }];
}

#pragma mark VC
-(void)addItemClicked:(id)sender{
    [self closeFliter];
    if (_rightNavBtn.buttonStyle == kFRDLivelyButtonStylePlus) {
        [_rightNavBtn setStyle:kFRDLivelyButtonStyleClose animated:YES];
        UIView *presentView=[[[UIApplication sharedApplication].keyWindow rootViewController] view];
//        [presentView bringSubviewToFront:[presentView.subviews firstObject]];
//        [_myPopMenu showMenuAtView:self.view startPoint:CGPointMake(0, -100) endPoint:CGPointMake(0, -100) withTabFooterView:presentView];
//        [_myPopMenu showMenuAtView:self.view startPoint:CGPointMake(0, -100) endPoint:CGPointMake(0, -100)];
        [_myPopMenu showMenuAtView:presentView startPoint:CGPointMake(0, -100) endPoint:CGPointMake(0, -100)];


    } else{
        [_rightNavBtn setStyle:kFRDLivelyButtonStylePlus animated:YES];
        [_myPopMenu dismissMenu];
    }
}

- (void)goToNewProjectVC{
    UIStoryboard *newProjectStoryboard = [UIStoryboard storyboardWithName:@"NewProject" bundle:nil];
    UIViewController *newProjectVC = [newProjectStoryboard instantiateViewControllerWithIdentifier:@"NewProjectVC"];
    [self.navigationController pushViewController:newProjectVC animated:YES];
}

- (void)goToNewTaskVC{
    EditTaskViewController *vc = [[EditTaskViewController alloc] init];
    vc.myTask = [Task taskWithProject:nil andUser:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToNewTweetVC{
    TweetSendViewController *vc = [[TweetSendViewController alloc] init];
    vc.sendNextTweet = ^(Tweet *nextTweet){
        [nextTweet saveSendData];//发送前保存草稿
        [[Coding_NetAPIManager sharedManager] request_Tweet_DoTweet_WithObj:nextTweet andBlock:^(id data, NSError *error) {
            if (data) {
                [Tweet deleteSendData];//发送成功后删除草稿
            }
        }];
    };
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self.parentViewController presentViewController:nav animated:YES completion:nil];
}

- (void)goTo2FA{
    OTPListViewController *vc = [OTPListViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToProject:(Project *)project{
    NProjectViewController *vc = [[NProjectViewController alloc] init];
    vc.myProject = project;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToAddUserVC{
    AddUserViewController *vc = [[AddUserViewController alloc] init];
    vc.type = AddUserTypeFollow;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToMessageVC{
    UsersViewController *vc = [[UsersViewController alloc] init];
    vc.curUsers = [Users usersWithOwner:[Login curLoginUser] Type:UsersTypeFriends_Message];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToProjectSquareVC{
    ProjectSquareViewController *vc=[ProjectSquareViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)closeFliter{
    if ([_myFliterMenu showStatus]) {
        [_myFliterMenu dismissMenu];
        [self fliterBtnClose:TRUE];
    }
}

-(void)closeMenu{
    if ([_myPopMenu isShowed]) {
        [_rightNavBtn setStyle:kFRDLivelyButtonStylePlus animated:YES];
        [_myPopMenu dismissMenu];
    }
}

-(void)fliterBtnClose:(BOOL)status{
    [_leftNavBtn setImage:status?[UIImage imageNamed:@"filtertBtn_normal_Nav"]:[UIImage imageNamed:@"filterBtn_selected_Nav"] forState:UIControlStateNormal];
}

//弹出事件
-(void)rotateView:(UIView*)aView
{
    POPBasicAnimation* rotateAnimation = ({
        POPBasicAnimation* basicAnimation=[POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
        basicAnimation.toValue = @(22.5 * (M_PI / 180.0f));
        basicAnimation.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        basicAnimation.duration = 0.2f;
        [basicAnimation setCompletionBlock:^(POPAnimation * ani, BOOL fin) {
            if (fin) {
            }
        }];
        basicAnimation;
    });
    [aView.layer pop_addAnimation:rotateAnimation forKey:@"rotateAnimation"];
    

    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.2];
//    [UIView setAnimationDelegate:self];
//    aView.transform = CGAffineTransformMakeRotation(22.5 * (M_PI / 180.0f));
//    [UIView commitAnimations];

}

-(void)addImageBarButtonWithImageName:(NSString*)imageName button:(UIButton*)aBtn action:(SEL)action isRight:(BOOL)isR
{
    UIImage *image = [UIImage imageNamed:imageName];
    CGRect frame = CGRectMake(0,0, image.size.width, image.size.height);
    
    aBtn.frame=frame;
    [aBtn setImage:image forState:UIControlStateNormal];
    [aBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aBtn];
    
    if (isR)
    {
        [self.navigationItem setRightBarButtonItem:barButtonItem];
    }else
    {
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
    }
}




#pragma mark fliter
-(void)fliterClicked:(id)sender{
    [self closeMenu];
    if (_myFliterMenu.showStatus) {
        [self fliterBtnClose:TRUE];
//        UIView *presentView=[[[UIApplication sharedApplication].keyWindow rootViewController] view];
//        if ([[presentView.subviews firstObject] isMemberOfClass:NSClassFromString(@"RDVTabBar")]) {
//            [presentView bringSubviewToFront:[presentView.subviews firstObject]];
//        }
        [_myFliterMenu dismissMenu];
    }else
    {
        [self fliterBtnClose:FALSE];
        _myFliterMenu.selectNum=_selectNum>=3?_selectNum+1:_selectNum;
//        UIView *presentView=[[[UIApplication sharedApplication].keyWindow rootViewController] view];
//        [presentView bringSubviewToFront:[presentView.subviews firstObject]];
        UIView *presentView=[[[UIApplication sharedApplication].keyWindow rootViewController] view];
        [_myFliterMenu showMenuAtView:presentView];
//        [_myFliterMenu showMenuAtView:self.view];
    }
}


#pragma mark Search
- (void)searchItemClicked:(id)sender{
    [_mySearchBar setX:20];
    if (!_mySearchDisplayController) {
        _mySearchDisplayController = ({
            UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_mySearchBar contentsController:self];
            searchVC.searchResultsTableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.mySearchBar.frame), 0, CGRectGetHeight(self.rdv_tabBarController.tabBar.frame), 0);
            searchVC.searchResultsTableView.tableFooterView = [[UIView alloc] init];
            [searchVC.searchResultsTableView registerClass:[ProjectListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectList];
            searchVC.searchResultsDataSource = self;
            searchVC.searchResultsDelegate = self;
            if (kHigher_iOS_6_1) {
                searchVC.displaysSearchBarInNavigationBar = NO;
            }
            searchVC;
        });
    }
    
    [_mySearchBar becomeFirstResponder];
}

-(void)searchAction
{
    if (!_mySearchDisplayController) {
        _mySearchDisplayController = ({
            UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_mySearchBar contentsController:self];
            searchVC.searchResultsTableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.mySearchBar.frame), 0, CGRectGetHeight(self.rdv_tabBarController.tabBar.frame), 0);
            searchVC.searchResultsTableView.tableFooterView = [[UIView alloc] init];
            [searchVC.searchResultsTableView registerClass:[ProjectListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectList];
            searchVC.searchResultsDataSource = self;
            searchVC.searchResultsDelegate = self;
            if (kHigher_iOS_6_1) {
                searchVC.displaysSearchBarInNavigationBar = NO;
            }
            searchVC;
        });
    }
}


-(void)goToSearchVC
{
    [self closeFliter];
    [self closeMenu];
    SearchViewController *vc=[SearchViewController new];
//    [self.navigationController pushViewController:vc animated:NO];
    
    BaseNavigationController *searchNav=[[BaseNavigationController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:searchNav animated:NO completion:nil];
}



#pragma mark Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchResults) {
        return [self.searchResults count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectList forIndexPath:indexPath];
    [cell setProject:[self.searchResults objectAtIndex:indexPath.row] hasSWButtons:NO hasBadgeTip:YES hasIndicator:YES];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ProjectListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.mySearchBar resignFirstResponder];
    [self goToProject:[self.searchResults objectAtIndex:indexPath.row]];
}

#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
//    [self searchAction];
//    [searchBar setShowsCancelButton:YES animated:YES];
    [self goToSearchVC];
    return NO;
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchProjectWithStr:searchText];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchProjectWithStr:searchBar.text];
}

- (void)searchProjectWithStr:(NSString *)string{
    self.searchString = string;
    [self updateFilteredContentForSearchString:string];
    [self.mySearchDisplayController.searchResultsTableView reloadData];
}

- (void)updateFilteredContentForSearchString:(NSString *)searchString{
    // start out with the entire list
    Projects *curPros = [_myProjectsDict objectForKey:@0];
    if (curPros) {
        self.searchResults = [curPros.list mutableCopy];
    }else{
        self.searchResults = nil;
    }
    
    // strip out all the leading and trailing spaces
    NSString *strippedStr = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedStr.length > 0)
    {
        searchItems = [strippedStr componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems)
    {
        // each searchString creates an OR predicate for: name, global_key
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        //        owner_user_name field matching
        lhs = [NSExpression expressionForKeyPath:@"owner_user_name"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        // at this OR predicate to ourr master AND predicate
        NSCompoundPredicate *orMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    NSCompoundPredicate *finalCompoundPredicate = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    
    self.searchResults = [[self.searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
}



@end
