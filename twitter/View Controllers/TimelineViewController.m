//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "APIManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "Tweet.h"
#import "User.h"
#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeViewController.h"

@interface TimelineViewController () <ComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tweetsArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self getTimeline];
}
    
- (void)getTimeline {
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            for (Tweet *tweet in tweets) {
                NSString *text = tweet.text;
                NSLog(@"%@", text);
            }
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
        
        [self.tableView reloadData];
        
       // [self.refreshControl endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapLogout:(id)sender {

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    
    // Clear out the access token
    [[APIManager shared] logout];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetsArray.count;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    Tweet *tweet = self.tweetsArray[indexPath.row];
    
    cell.tweet = tweet;
    cell.username.text = tweet.user.name;
    cell.tweetContent.text = tweet.text;
    cell.numOfRetweets.text = [NSString stringWithFormat: @"%d", tweet.retweetCount];
    cell.numOfFavorites.text = [NSString stringWithFormat: @"%d", tweet.favoriteCount];
    
    NSString *URLString = [tweet.user.profilePicture stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];

    cell.profileImage.image = [UIImage imageWithData:urlData];
    

    if ([cell.tweet.userMentions count] > 0) {
        NSLog(@"%@", cell.tweet.userMentions[0]);
        
        NSString *userMentioned = cell.tweet.userMentions[0][@"screen_name"];
        
        NSRange range = [cell.tweet.text rangeOfString:userMentioned];
        
        NSMutableAttributedString * mention = [[NSMutableAttributedString alloc] initWithString: cell.tweet.text];
        
        NSURL *myUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", userMentioned]];
        
        [mention addAttribute: NSLinkAttributeName value:myUrl range: NSMakeRange(range.location-1, range.length+1)];
        cell.tweetContent.attributedText = mention;
    }
    
    //gets media object and sets photoMediaImage unless media is nill
//    if([cell.tweet.media count] > 0) {
//        cell.photoMediaImage.hidden = NO;
//
//        NSString *URLPhotoMediaString = cell.tweet.media[0][@"media_url_https"];
//        NSURL *photoMediaURL = [NSURL URLWithString: [URLPhotoMediaString  stringByAppendingString:@":thumb"]];
//        NSData *photoMediaURLData = [NSData dataWithContentsOfURL:photoMediaURL];
//
//        NSLog(@"%@", photoMediaURL);
//
//        cell.photoMediaImage.image = [UIImage imageWithData:photoMediaURLData];
//
//        cell.photoMediaBottomConstraint.constant = 8;
//
//    }
//    else{
//        cell.photoMediaImage.image = nil;
//        cell.photoMediaBottomConstraint.constant = 0;
//    }

    if(tweet.favorited) {
        [cell.favButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
    } else {
        [cell.favButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];

    }

    if(tweet.retweeted) {
        [cell.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
    } else {
        [cell.retweetButton setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
    }

    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didTweet:(Tweet *)tweet {
    [self.tweetsArray insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}

/* use for profile pics
 
 NSString *URLString = tweet.user.profilePicture;
 NSURL *url = [NSURL URLWithString:URLString];
 NSData *urlData = [NSData dataWithContentsOfURL:url];
 */

/*
#pragma mark - Navigation
 
 */

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([[segue identifier] isEqualToString:@"composeSegue"]){
        UINavigationController *navigationController = [segue destinationViewController];
        ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
        composeController.delegate = self;
    }
//    if([[segue identifier] isEqualToString:@"detailsSegue"]){
//        UINavigationController *navigationController = [segue destinationViewController];
//        DetailsViewController *detailsViewController = (DetailsViewController*)navigationController.topViewController;
//        UITableViewCell *tappedCell = sender;
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
//        Tweet *tweet = self.tweetsArray[indexPath.row];
//        detailsViewController.tweet = tweet;
//    }

}



//
//- (void)encodeWithCoder:(nonnull NSCoder *)coder {
//    <#code#>
//}
//
//- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
//    <#code#>
//}
//
//- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
//    <#code#>
//}
//
//- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
//    <#code#>
//}
//
//- (void)setNeedsFocusUpdate {
//    <#code#>
//}
//
//- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
//    <#code#>
//}
//
//- (void)updateFocusIfNeeded {
//    <#code#>
//}

@end
