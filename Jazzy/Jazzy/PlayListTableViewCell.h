//
//  PlayListTableViewCell.h
//  Jazzy
//
//  Created by Oszkó Tamás on 02/11/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@end
