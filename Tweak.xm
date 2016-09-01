#import <Springboard/SBIconListView.h>
#import <Springboard/SBDockView.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIViewController.h>
#import <AppList/AppList.h>

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface UIApplication ()
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface SBHomeScreenViewController : UIViewController <UITextFieldDelegate>
-(void)updateAppLists;
@end

@interface SBDockIconListView : SBIconListView
@end


float oldY;
BOOL dragging;
UIView *appDrawerView;
UIView *appsLabelView;
UIView *favoritesLabelView;
UIScrollView *applicationsView;
UIScrollView *favoritesView;
UIScrollView *searchView;
UITextField *searchField;
NSMutableArray* appNames;
NSMutableDictionary* appList;
NSMutableArray* favoriteNames;
NSMutableDictionary* favoritesList;
NSMutableArray* searchNames;
NSMutableDictionary* searchList;
const CGFloat kScrollObjHeight  = 60.0;
const CGFloat kScrollObjWidth   = 60.0;
NSArray* excludedApps = [[NSArray alloc] initWithObjects:
			@"AACredentialRecoveryDialog",
			@"AccountAuthenticationDialog",
			@"CompassCalibrationViewService",
			@"DDActionsService",
			@"DataActivation",
			@"DemoApp",
			@"FacebookAccountMigrationDialog",
			@"FieldTest",
			@"MailCompositionService",
			@"MessagesViewService",
			@"MusicUIService",
			@"Print Center",
			@"Setup",
			@"Siri",
			@"SocialUIService",
			@"TencentWeiboAccountMigrationDialog",
			@"TrustMe",
			@"WebContentAnalysisUI",
			@"WebSheet",
			@"WebViewService",
			@"iAd",
			@"iAdOptOut",
			@"iOS Diagnostics",
			@"iTunes",
			@"quicklookd",
			@"SafariViewService",
			@"Feedback",
			@"PassbookUIService",
			@"CallBar Contacts Service",
			@"SLGoogleAuth",
			@"ShareBear",
			@"Game Center UI Service",
			@"Server Drive",
			@"MessagesNotificationViewService",
			@"MDMRemoteAlertService",
			@"User Authentication",
			@"SLYahooAuth",
			@"AskPermissionUI",
			@"InCallService",
			@"Game Controller",
			@"SharedWebCredentialViewService",
			@"PreBoard",
			@"Diagnostics",
			@"StoreDemoViewService",
			@"Family",
			@"HealthPrivacyService",
			@"HomeUIService",
			@"PhotosViewService",
      nil];

%hook SBHomeScreenViewController
- (void)viewDidLoad {
  %orig;

  appDrawerView=[[UIView alloc] initWithFrame:CGRectMake(0,103,SCREEN_WIDTH,SCREEN_HEIGHT - (20 + 96))];
  appDrawerView.backgroundColor=[UIColor clearColor];

  applicationsView=[[UIScrollView alloc] initWithFrame:CGRectMake(0,70,SCREEN_WIDTH,SCREEN_HEIGHT - (20 + 96 + 70))];
  applicationsView.backgroundColor=[UIColor clearColor];
  [applicationsView setCanCancelContentTouches:NO];
  applicationsView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
  applicationsView.clipsToBounds = YES;
  applicationsView.scrollEnabled = YES;

  favoritesView=[[UIScrollView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH,70,SCREEN_WIDTH,SCREEN_HEIGHT - (20 + 96 + 70))];
  favoritesView.backgroundColor=[UIColor clearColor];
  [favoritesView setCanCancelContentTouches:NO];
  favoritesView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
  favoritesView.clipsToBounds = YES;
  favoritesView.scrollEnabled = YES;

  searchView=[[UIScrollView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH,70,SCREEN_WIDTH,SCREEN_HEIGHT - (20 + 96 + 70))];
  searchView.backgroundColor=[UIColor clearColor];
  [searchView setCanCancelContentTouches:NO];
  searchView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
  searchView.clipsToBounds = YES;
  searchView.scrollEnabled = YES;

  appsLabelView=[[UIView alloc] initWithFrame:CGRectMake(10, 35, SCREEN_WIDTH / 4, 35)];
  CGRect appsLabelRect = CGRectMake(0, 0, SCREEN_WIDTH / 4, 35);
  NSString *appsLabelText = @"Applications";
  UILabel *appsLabel = [[UILabel alloc] initWithFrame:appsLabelRect];
  appsLabel.text = appsLabelText;
  appsLabel.textColor = [UIColor whiteColor];
  appsLabel.font = [appsLabel.font fontWithSize:17];
  appsLabel.textAlignment = NSTextAlignmentCenter;
  UITapGestureRecognizer* tapApplications = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showApplicationsTab:)];
  tapApplications.numberOfTapsRequired = 1;
  tapApplications.numberOfTouchesRequired = 1;
  [appsLabelView addGestureRecognizer:tapApplications];
  [tapApplications release];
  [appsLabelView addSubview:appsLabel];

  favoritesLabelView=[[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 4 + 10, 35, SCREEN_WIDTH / 4, 35)];
  CGRect favoritesLabelRect = CGRectMake(0, 0, SCREEN_WIDTH / 4, 35);
  NSString *favoritesLabelText = @"Favorites";
  UILabel *favoritesLabel = [[UILabel alloc] initWithFrame:favoritesLabelRect];
  favoritesLabel.text = favoritesLabelText;
  favoritesLabel.textColor = [UIColor whiteColor];
  favoritesLabel.font = [favoritesLabel.font fontWithSize:17];
  favoritesLabel.textAlignment = NSTextAlignmentCenter;
  UITapGestureRecognizer* tapFavorites = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFavoritesTab:)];
  tapFavorites.numberOfTapsRequired = 1;
  tapFavorites.numberOfTouchesRequired = 1;
  [favoritesLabelView addGestureRecognizer:tapFavorites];
  [tapFavorites release];
  [favoritesLabelView addSubview:favoritesLabel];

  searchField = [[UITextField alloc] initWithFrame:CGRectMake(25, 0, SCREEN_WIDTH - 50, 30)];
  searchField.textColor = [UIColor whiteColor];
  searchField.font = [searchField.font fontWithSize:17];
  searchField.backgroundColor = [UIColor colorWithRed: 175/255.0 green:175/255.0 blue:175/255.0 alpha:0.4];
  searchField.placeholder = @"Search Applications";
  searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
  searchField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
  searchField.layer.cornerRadius = 5;
  searchField.layer.masksToBounds = YES;
  searchField.autocorrectionType = UITextAutocorrectionTypeNo;
  searchField.keyboardType = UIKeyboardTypeDefault;
  searchField.returnKeyType = UIReturnKeyDone;
  searchField.clearsOnBeginEditing = YES;
  searchField.delegate = self;
  [searchField addTarget:self action:@selector(searchApplications:) forControlEvents:UIControlEventEditingChanged];

  [self updateAppLists];
}

%new
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
%new
-(void)searchApplications:(UITextField *) textField{
  NSString* searchText = textField.text;
  if ([searchText length] == 0){
    CGRect searchFrame = searchView.frame;
    searchFrame.origin.x = SCREEN_WIDTH;
    searchView.frame = searchFrame;

    CGRect scrollFrame1 = applicationsView.frame;
    scrollFrame1.origin.x = 0;
    applicationsView.frame = scrollFrame1;

    CGRect scrollFrame2 = favoritesView.frame;
    scrollFrame2.origin.x = SCREEN_WIDTH;
    favoritesView.frame = scrollFrame2;
  }
  else {
    CGRect searchFrame = searchView.frame;
    searchFrame.origin.x = 0;
    searchView.frame = searchFrame;

    CGRect scrollFrame1 = applicationsView.frame;
    scrollFrame1.origin.x = SCREEN_WIDTH;
    applicationsView.frame = scrollFrame1;

    CGRect scrollFrame2 = favoritesView.frame;
    scrollFrame2.origin.x = SCREEN_WIDTH;
    favoritesView.frame = scrollFrame2;
  }
  [searchView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
  ALApplicationList* al = [ALApplicationList sharedApplicationList];
  searchNames = [[NSMutableArray alloc] init];
  searchList = [[NSMutableDictionary alloc] init];
  for(int i = 0; i < [al.applications allKeys].count; i++) {
    NSString* name = [[al.applications allValues] objectAtIndex:i];
    if([excludedApps containsObject:name]) {
      continue;
    }
    if ([name localizedStandardContainsString:searchText]) {
      searchList[[[al.applications allKeys] objectAtIndex:i]] = name;
    }
  }
  for (NSString* i in [searchList allValues]) {
      [searchNames addObject:i];
  }
  searchNames = [[searchNames sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
  for (int i = 1; i <= searchNames.count; i++)
  {
    CGRect  appRect = CGRectMake(0, 0, kScrollObjWidth, kScrollObjHeight + 20);
    UIView *appView = [[UIView alloc] initWithFrame:appRect];
    appView.tag = i;

    UIImageView *iconView = [[UIImageView alloc] initWithImage:[[ALApplicationList sharedApplicationList] iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:[searchList allKeysForObject:[searchNames objectAtIndex:i - 1]][0]]];
    CGRect iconRect = iconView.frame;
    iconRect.size.height = kScrollObjHeight;
    iconRect.size.width = kScrollObjWidth;
    iconView.frame = iconRect;

    CGRect labelRect = CGRectMake(0, kScrollObjHeight, kScrollObjWidth, 20);
    NSString *appName = [searchNames objectAtIndex:i - 1];
    UILabel *appLabel = [[UILabel alloc] initWithFrame:labelRect];
    appLabel.text = appName;
    appLabel.textColor = [UIColor whiteColor];
    appLabel.font = [appLabel.font fontWithSize:12];
    appLabel.textAlignment = NSTextAlignmentCenter;

    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openSearch:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;

    [appView addGestureRecognizer:tapGesture];
    [tapGesture release];

    [searchView addSubview:appView];
    [appView addSubview:iconView];
    [appView addSubview:appLabel];
    [appView release];
    [iconView release];
    [appLabel release];
  }
  UIView *view = nil;
  NSArray *subviews = [searchView subviews];
  float spacing = (SCREEN_WIDTH - (kScrollObjWidth * 4)) / 5;
  CGFloat curYLoc = 0;
  CGFloat curXLoc = spacing;
  int j = 0;
  for (view in subviews)
  {
    if ([view isKindOfClass:[UIView class]] && view.tag > 0)
    {
      if (j == 4)
      {
        j = 0;
        curYLoc += (kScrollObjHeight + spacing);
        curXLoc = spacing;
      }
      CGRect frame = view.frame;
      frame.origin = CGPointMake(curXLoc, curYLoc);
      view.frame = frame;
      curXLoc += (kScrollObjWidth + spacing);
      j++;

    }

  }
  [searchView setContentSize:CGSizeMake([searchView bounds].size.width, (((searchNames.count + 4 - 1) / 4) * (kScrollObjHeight + 27)))];
}

%new
- (void)updateAppLists{
	[applicationsView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
  [favoritesView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
  ALApplicationList* al = [ALApplicationList sharedApplicationList];

  appList = [[NSMutableDictionary alloc] init];
  favoritesList = [[NSMutableDictionary alloc] init];
  for(int i = 0; i < [al.applications allKeys].count; i++) {
    NSString* name = [[al.applications allValues] objectAtIndex:i];
    NSString* bundleID = [[al.applications allKeys] objectAtIndex:i];
    if([excludedApps containsObject:name]) {
      continue;
    }
    NSString *favoritesPrefix = @"udcFavorites-";
    NSString *plistpath = @"/User/Library/Preferences/com.lebirava.undercut.plist";
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistpath];
    if ([[plistDict objectForKey:[favoritesPrefix stringByAppendingString:bundleID]] boolValue]) {
      favoritesList[[[al.applications allKeys] objectAtIndex:i]] = name;
    }
    NSString *blacklistPrefix = @"udcBlacklist-";
    if (![[plistDict objectForKey:[blacklistPrefix stringByAppendingString:bundleID]] boolValue]) {
      appList[[[al.applications allKeys] objectAtIndex:i]] = name;
    }
    continue;
  }

  appNames = [[NSMutableArray alloc] init];
  for(NSString* i in [appList allValues]) {
      [appNames addObject:i];
  }
  appNames = [[appNames sortedArrayUsingSelector:@selector(compare:)] mutableCopy];

  favoriteNames = [[NSMutableArray alloc] init];
  for(NSString* i in [favoritesList allValues]) {
    [favoriteNames addObject:i];
  }
  favoriteNames = [[favoriteNames sortedArrayUsingSelector:@selector(compare:)] mutableCopy];

  for (int i = 1; i <= appNames.count; i++)
  {
    CGRect  appRect = CGRectMake(0, 0, kScrollObjWidth, kScrollObjHeight + 20);
    UIView *appView = [[UIView alloc] initWithFrame:appRect];
    appView.tag = i;

    UIImageView *iconView = [[UIImageView alloc] initWithImage:[[ALApplicationList sharedApplicationList] iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:[appList allKeysForObject:[appNames objectAtIndex:i - 1]][0]]];
    CGRect iconRect = iconView.frame;
    iconRect.size.height = kScrollObjHeight;
    iconRect.size.width = kScrollObjWidth;
    iconView.frame = iconRect;

    CGRect labelRect = CGRectMake(0, kScrollObjHeight, kScrollObjWidth, 20);
    NSString *appName = [appNames objectAtIndex:i - 1];
    UILabel *appLabel = [[UILabel alloc] initWithFrame:labelRect];
    appLabel.text = appName;
    appLabel.textColor = [UIColor whiteColor];
    appLabel.font = [appLabel.font fontWithSize:12];
    appLabel.textAlignment = NSTextAlignmentCenter;

    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openApp:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;

    [appView addGestureRecognizer:tapGesture];
    [tapGesture release];

    [applicationsView addSubview:appView];
    [appView addSubview:iconView];
    [appView addSubview:appLabel];
    [appView release];
    [iconView release];
    [appLabel release];
  }
  for (int i = 1; i <= favoriteNames.count; i++)
  {
    CGRect  appRect = CGRectMake(0, 0, kScrollObjWidth, kScrollObjHeight + 20);
    UIView *appView = [[UIView alloc] initWithFrame:appRect];
    appView.tag = i;

    UIImageView *iconView = [[UIImageView alloc] initWithImage:[[ALApplicationList sharedApplicationList] iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:[favoritesList allKeysForObject:[favoriteNames objectAtIndex:i - 1]][0]]];
    CGRect iconRect = iconView.frame;
    iconRect.size.height = kScrollObjHeight;
    iconRect.size.width = kScrollObjWidth;
    iconView.frame = iconRect;

    CGRect labelRect = CGRectMake(0, kScrollObjHeight, kScrollObjWidth, 20);
    NSString *appName = [favoriteNames objectAtIndex:i - 1];
    UILabel *appLabel = [[UILabel alloc] initWithFrame:labelRect];
    appLabel.text = appName;
    appLabel.textColor = [UIColor whiteColor];
    appLabel.font = [appLabel.font fontWithSize:12];
    appLabel.textAlignment = NSTextAlignmentCenter;

    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openFavorite:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;

    [appView addGestureRecognizer:tapGesture];
    [tapGesture release];

    [favoritesView addSubview:appView];
    [appView addSubview:iconView];
    [appView addSubview:appLabel];
    [appView release];
    [iconView release];
    [appLabel release];
  }
  UIView *view = nil;
  NSArray *subviews1 = [applicationsView subviews];
  NSArray *subviews2 = [favoritesView subviews];
  float spacing = (SCREEN_WIDTH - (kScrollObjWidth * 4)) / 5;
  CGFloat curYLoc = 0;
  CGFloat curXLoc = spacing;
  int j = 0;
  for (view in subviews1)
  {
    if ([view isKindOfClass:[UIView class]] && view.tag > 0)
    {
      if (j == 4)
      {
        j = 0;
        curYLoc += (kScrollObjHeight + spacing);
        curXLoc = spacing;
      }
      CGRect frame = view.frame;
      frame.origin = CGPointMake(curXLoc, curYLoc);
      view.frame = frame;
      curXLoc += (kScrollObjWidth + spacing);
      j++;

    }

  }
  j = 0;
  curYLoc = 0;
  curXLoc = spacing;
  for (view in subviews2)
  {
    if ([view isKindOfClass:[UIView class]] && view.tag > 0)
    {
      if (j == 4)
      {
        j = 0;
        curYLoc += (kScrollObjHeight + spacing);
        curXLoc = spacing;
      }
      CGRect frame = view.frame;
      frame.origin = CGPointMake(curXLoc, curYLoc);
      view.frame = frame;
      curXLoc += (kScrollObjWidth + spacing);
      j++;

    }

  }



  [applicationsView setContentSize:CGSizeMake([applicationsView bounds].size.width, (((appNames.count + 4 - 1) / 4) * (kScrollObjHeight + 27)))];
  [favoritesView setContentSize:CGSizeMake([favoritesView bounds].size.width, (((favoriteNames.count + 4 - 1) / 4) * (kScrollObjHeight + 27)))];
}
%new
- (void) openApp: (UITapGestureRecognizer *)recognizer
{
  UIView *view = recognizer.view;
  int i = view.tag;
  NSString *bundleID = [appList allKeysForObject:[appNames objectAtIndex:i - 1]][0];
  [[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:NO];
}
%new
- (void) openFavorite: (UITapGestureRecognizer *)recognizer
{
  UIView *view = recognizer.view;
  int i = view.tag;
  NSString *bundleID = [favoritesList allKeysForObject:[favoriteNames objectAtIndex:i - 1]][0];
  [[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:NO];
}
%new
- (void) openSearch: (UITapGestureRecognizer *)recognizer
{
  CGRect searchFrame = searchView.frame;
  searchFrame.origin.x = SCREEN_WIDTH;
  searchView.frame = searchFrame;
  CGRect applicationFrame = applicationsView.frame;
  applicationFrame.origin.x = 0;
  applicationsView.frame = applicationFrame;
  UIView *view = recognizer.view;
  int i = view.tag;
  searchField.text = @"";
  [searchField resignFirstResponder];
  NSString *bundleID = [searchList allKeysForObject:[searchNames objectAtIndex:i - 1]][0];
  [searchView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
  [[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:NO];
}
%new
- (void) showApplicationsTab: (UITapGestureRecognizer *)recognizer
{
	[self updateAppLists];

  CGRect applicationsFrame = applicationsView.frame;
  applicationsFrame.origin.x = 0;
  applicationsView.frame = applicationsFrame;

  CGRect favoritesFrame = favoritesView.frame;
  favoritesFrame.origin.x = SCREEN_WIDTH;
  favoritesView.frame = favoritesFrame;

  CGRect searchFrame = searchView.frame;
  searchFrame.origin.x = SCREEN_WIDTH;
  searchView.frame = searchFrame;
  searchField.text = @"";
  [searchField resignFirstResponder];
}
%new
- (void) showFavoritesTab: (UITapGestureRecognizer *)recognizer
{
  CGRect applicationsFrame = applicationsView.frame;
  applicationsFrame.origin.x = SCREEN_WIDTH;
  applicationsView.frame = applicationsFrame;

  CGRect favoritesFrame = favoritesView.frame;
  favoritesFrame.origin.x = 0;
  favoritesView.frame = favoritesFrame;

  CGRect searchFrame = searchView.frame;
  searchFrame.origin.x = SCREEN_WIDTH;
  searchView.frame = searchFrame;
  searchField.text = @"";
  [searchField resignFirstResponder];
}
%end

%hook SBDockIconListView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];

    if (CGRectContainsPoint(self.frame, touchLocation)) {

        dragging = YES;
        oldY = touchLocation.y;
        if (self.superview.frame.size.height == 96){
            [self.superview addSubview:appDrawerView];
            [appDrawerView addSubview:applicationsView];
            [appDrawerView addSubview:favoritesView];
            [appDrawerView addSubview:searchView];
            [appDrawerView addSubview:appsLabelView];
            [appDrawerView addSubview:favoritesLabelView];
            [appDrawerView addSubview:searchField];
        }
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];

    if (dragging && touchLocation.y < 96 && self.superview.frame.origin.y <= SCREEN_HEIGHT - 96 && self.superview.frame.origin.y >= 20) {
        CGRect frame = self.superview.frame;
        frame.origin.y = (self.superview.frame.origin.y + touchLocation.y - oldY <= 20)? 20 : (self.superview.frame.origin.y + touchLocation.y - oldY >= SCREEN_HEIGHT - 96)? SCREEN_HEIGHT - 96 : self.superview.frame.origin.y + touchLocation.y - oldY;
        frame.size.height = (self.superview.frame.origin.y >= 20)? SCREEN_HEIGHT - 20 : (self.superview.frame.origin.y <= SCREEN_HEIGHT - 96)? 96 : SCREEN_HEIGHT - self.superview.frame.origin.y + touchLocation.y;
        self.superview.frame = frame;

        CGRect appDrawerFrame = appDrawerView.frame;
        appDrawerFrame.size.height = (self.superview.frame.origin.y >= 20)? SCREEN_HEIGHT - 116 : (self.superview.frame.origin.y <= SCREEN_HEIGHT - 96)? 0 : SCREEN_HEIGHT - self.superview.frame.origin.y + touchLocation.y;
        appDrawerView.frame = appDrawerFrame;
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    dragging = NO;
    CGRect frame = self.superview.frame;
    if (frame.origin.y > (SCREEN_HEIGHT - 96) / 2) {
      frame.origin.y = SCREEN_HEIGHT - 96;
      frame.size.height = 96;
      self.superview.frame = frame;
      [appDrawerView removeFromSuperview];
    }
    else if (frame.origin.y < (SCREEN_HEIGHT - 96) / 2) {
      frame.origin.y = 20;
      frame.size.height = SCREEN_HEIGHT - 20;
      self.superview.frame = frame;
    }
}
%end
%hook SBDockView

- (void)dealloc {
  %orig;
  [appDrawerView removeFromSuperview];
}
%end
