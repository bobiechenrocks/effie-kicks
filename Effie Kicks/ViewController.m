//
//  ViewController.m
//  Effie Kicks
//
//  Created by Bobie Chen on 3/2/23.
//

#import "ViewController.h"

NSString * const kEffieKicksHistory = @"EffieKicksHistory";
NSString * const kEffieKicksTodayDate = @"EffieKicksTodayDate";
NSString * const kEffieKicksTodayKickCount = @"EffieKicksTodayKickCount";
NSString * const kEffieKicksTodayKicks = @"EffieKicksTodayKicks";

@interface ViewController ()

@property (nonatomic, strong) NSArray *kicksHistory;
@property (nonatomic, assign) NSUInteger kickCount;
@property (nonatomic, strong) NSDictionary *kicksToday;

@property (nonatomic, strong) NSTimer *elapsedTimer;
@property (nonatomic, strong) NSDate *startTime;

@property (weak, nonatomic) IBOutlet UIButton *kickButton;
@property (weak, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *kick1;
@property (weak, nonatomic) IBOutlet UIButton *kick2;
@property (weak, nonatomic) IBOutlet UIButton *kick3;
@property (weak, nonatomic) IBOutlet UIButton *kick4;
@property (weak, nonatomic) IBOutlet UIButton *kick5;
@property (weak, nonatomic) IBOutlet UIButton *kick6;
@property (weak, nonatomic) IBOutlet UIButton *kick7;
@property (weak, nonatomic) IBOutlet UIButton *kick8;
@property (weak, nonatomic) IBOutlet UIButton *kick9;
@property (weak, nonatomic) IBOutlet UIButton *kick10;
@property (weak, nonatomic) IBOutlet UIButton *kick11;
@property (weak, nonatomic) IBOutlet UIButton *kick12;
@property (weak, nonatomic) IBOutlet UIButton *kick13;
@property (weak, nonatomic) IBOutlet UIButton *kick14;
@property (weak, nonatomic) IBOutlet UIButton *kick15;
@property (weak, nonatomic) IBOutlet UIButton *kick16;
@property (weak, nonatomic) IBOutlet UIButton *kick17;
@property (weak, nonatomic) IBOutlet UIButton *kick18;
@property (weak, nonatomic) IBOutlet UIButton *kick19;
@property (weak, nonatomic) IBOutlet UIButton *kick20;

@end

/** [todo]
 - table view with kicks history
   - tap cell: show history of kicks that day
 */

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.kickCount = 0;
    
    [self loadKicksHistory];
    [self updateKickEmojis];
}

- (void)loadKicksHistory {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kEffieKicksHistory]) {
        /**
         * {
         *  kick-history: [
         *      {
         *          date:
         *          kick-count:
         *          kicks: [
         *              date-time,
         *              date-time,
         *          ...
         *          ]
         *      },
         *      ...
         *  ]
         * }
         */
        NSArray *kicksHistory = [NSArray array];
        [[NSUserDefaults standardUserDefaults] setObject:kicksHistory forKey:kEffieKicksHistory];
    }
    
    self.kicksHistory = [[NSUserDefaults standardUserDefaults] objectForKey:kEffieKicksHistory];
    NSAssert([self.kicksHistory isKindOfClass:[NSArray class]], @"Invalid kicks-history data type");
}

- (void)startCountingKicks {
    self.kickCount = 1;

    self.startTime = [NSDate date];
    [self updateElapsedTime];
    self.elapsedTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *timer) {
        [self updateElapsedTime];
    }];
    
    [self initializeKicksToday];
    [self updateKicksHistory];
    [self updateKickEmojis];
}

- (void)oneMoreKick {
    self.kickCount++;

    [self oneMoreKickToday];
    [self updateKicksHistory];
    [self updateKickEmojis];
}

- (void)initializeKicksToday {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC-8"]];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    
    NSArray *kicks = @[@([[NSDate date] timeIntervalSince1970])];

    self.kicksToday = @{kEffieKicksTodayDate: date,
                        kEffieKicksTodayKickCount: @(self.kickCount),
                        kEffieKicksTodayKicks: kicks};
}

- (void)oneMoreKickToday {
    NSMutableDictionary *kicksToday = [self.kicksToday mutableCopy];
    
    NSMutableArray *kicks = [kicksToday[kEffieKicksTodayKicks] mutableCopy];
    NSAssert(kicks, @"kicks of today might be corrupted");
    
    [kicks addObject:@([[NSDate date] timeIntervalSince1970])];
    kicksToday[kEffieKicksTodayKickCount] = @(self.kickCount);
    kicksToday[kEffieKicksTodayKicks] = kicks;
    
    self.kicksToday = kicksToday;
}

- (void)updateElapsedTime {
    self.elapsedTimeLabel.hidden = NO;
    self.elapsedTimeLabel.text = [self elapsedTimeString];
}

- (NSString *)elapsedTimeString {
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:self.startTime];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (elapsedTime > 3600) {
        [dateFormatter setDateFormat:@"hh:mm:ss"];
    } else {
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC-8"]];
    
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:elapsedTime]];
}

- (void)updateKicksHistory {
    NSMutableArray *kicksHistory = [self.kicksHistory mutableCopy];
    
    NSString *dateString = self.kicksToday[kEffieKicksTodayDate];   // yyyyMMdd
    
    NSUInteger index = NSUIntegerMax;
    for (NSUInteger i = 0; i < [kicksHistory count]; ++i) {
        NSDictionary *day = [kicksHistory objectAtIndex:i];
        if ([day[kEffieKicksTodayDate] isEqualToString:dateString]) {
            index = i;
            break;
        }
    }
    
    if (index != NSUIntegerMax) {
        [kicksHistory removeObjectAtIndex:index];
        [kicksHistory insertObject:self.kicksToday atIndex:index];
    } else {
        [kicksHistory addObject:self.kicksToday];
    }

    self.kicksHistory = kicksHistory;
    [[NSUserDefaults standardUserDefaults] setObject:kicksHistory forKey:kEffieKicksHistory];
    
    NSLog(@"kicks update:\n%@", kicksHistory);
}

- (void)resetKicksToday {
    if (self.kicksToday) {
        self.kickCount = 0;
        NSMutableDictionary *kicksToday = [self.kicksToday mutableCopy];
        kicksToday[kEffieKicksTodayKickCount] = @(self.kickCount);
        kicksToday[kEffieKicksTodayKicks] = @[];
        self.kicksToday = kicksToday;

        [self updateKicksHistory];
    }
    
    [self.elapsedTimer invalidate];
    self.elapsedTimeLabel.hidden = YES;

    [self.kickButton setTitle:@"Start" forState:UIControlStateNormal];
    [self updateKickEmojis];
}

- (void)updateKickEmojis {
    self.kick1.hidden = (self.kickCount > 0)? NO : YES;
    self.kick2.hidden = (self.kickCount > 1)? NO : YES;
    self.kick3.hidden = (self.kickCount > 2)? NO : YES;
    self.kick4.hidden = (self.kickCount > 3)? NO : YES;
    self.kick5.hidden = (self.kickCount > 4)? NO : YES;
    self.kick6.hidden = (self.kickCount > 5)? NO : YES;
    self.kick7.hidden = (self.kickCount > 6)? NO : YES;
    self.kick8.hidden = (self.kickCount > 7)? NO : YES;
    self.kick9.hidden = (self.kickCount > 8)? NO : YES;
    self.kick10.hidden = (self.kickCount > 9)? NO : YES;
    self.kick11.hidden = (self.kickCount > 10)? NO : YES;
    self.kick12.hidden = (self.kickCount > 11)? NO : YES;
    self.kick13.hidden = (self.kickCount > 12)? NO : YES;
    self.kick14.hidden = (self.kickCount > 13)? NO : YES;
    self.kick15.hidden = (self.kickCount > 14)? NO : YES;
    self.kick16.hidden = (self.kickCount > 15)? NO : YES;
    self.kick17.hidden = (self.kickCount > 16)? NO : YES;
    self.kick18.hidden = (self.kickCount > 17)? NO : YES;
    self.kick19.hidden = (self.kickCount > 18)? NO : YES;
    self.kick20.hidden = (self.kickCount > 19)? NO : YES;
}

- (void)thatsToday {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Done?"
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *finishAction = [UIAlertAction actionWithTitle:@"Finish" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showSummaryAlert];
    }];
    [alertController addAction:finishAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showSummaryAlert {
    NSString *kicksSummary = [self summaryMessage];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Summary"
                                                                             message:kicksSummary
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = kicksSummary;
        
        [self resetKicksToday];
    }];
    [alertController addAction:copyAction];
    
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:@[kicksSummary]
                                                                                      applicationActivities:nil];
        shareController.excludedActivityTypes = @[UIActivityTypePostToFacebook,
                                                  UIActivityTypePostToTwitter,
                                                  UIActivityTypePostToWeibo,
                                                  UIActivityTypeMail,
                                                  UIActivityTypePrint,
                                                  UIActivityTypeAssignToContact,
                                                  UIActivityTypeSaveToCameraRoll,
                                                  UIActivityTypeAddToReadingList,
                                                  UIActivityTypePostToTencentWeibo,
                                                  UIActivityTypeOpenInIBooks,
                                                  UIActivityTypeMarkupAsPDF,
                                                  UIActivityTypeSharePlay,
                                                  UIActivityTypeCollaborationInviteWithLink,
                                                  UIActivityTypeCollaborationCopyLink];
        [self presentViewController:shareController animated:YES completion:nil];
        
        [self resetKicksToday];
    }];
    [alertController addAction:shareAction];
    
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self resetKicksToday];
    }];
    [alertController addAction:doneAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSString *)summaryMessage {
    if (!self.kicksToday || [self.kicksToday count] == 0) {
        return @"";
    }
    
    NSString *summary = [NSString stringWithFormat:@"%ld kicks. Well done!\nElapsed time: %@\n", self.kickCount, [self elapsedTimeString]];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC-8"]];

    for (NSNumber *time in self.kicksToday[kEffieKicksTodayKicks]) {
        NSTimeInterval timestamp = [time doubleValue];
        NSString *date = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
        summary = [summary stringByAppendingFormat:@"🦶🏼 %@\n", date];
    }
    
    summary = [summary stringByReplacingCharactersInRange:NSMakeRange([summary length] - 1, 1) withString:@""];
    
    return summary;
}

#pragma mark - IBActions

- (IBAction)kickButtonTapped:(id)sender {
    if (self.kickCount == 0) {
        [self startCountingKicks];
        [self.kickButton setTitle:@"+1" forState:UIControlStateNormal];
    } else {
        [self oneMoreKick];
    }
}

- (IBAction)resetButtonTapped:(id)sender {
    [self resetKicksToday];
}

- (IBAction)finishButtonTapped:(id)sender {
    [self thatsToday];
}

@end
