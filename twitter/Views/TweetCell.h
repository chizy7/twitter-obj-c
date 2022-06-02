//
//  TweetCell.h
//  twitter
//
//  Created by Chizaram Chibueze on 6/1/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

NS_ASSUME_NONNULL_BEGIN

@interface TweetCell : UITableViewCell

//property
@property (strong, nonatomic) Tweet *tweet;

//outlets
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *tweetContent;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UILabel *numOfReplies;
@property (weak, nonatomic) IBOutlet UILabel *numOfRetweets;
@property (weak, nonatomic) IBOutlet UILabel *numOfFavorites;



@end

NS_ASSUME_NONNULL_END
