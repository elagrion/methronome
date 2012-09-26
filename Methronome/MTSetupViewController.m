//
//  MTSetupViewController.m
//  Methronome
//
//  Created by Serge Rykovski on 8/18/12.
//
//

#import "MTSetupViewController.h"
#import "MTMethronomeViewController.h"
#import "MTTimeIntervalView.h"
#import "MTConstants.h"

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>

@interface MTSetupViewController ()

@property (strong, nonatomic) NSDate* startDate;
@property (assign, nonatomic) BOOL stopWhenTimesUp;
- (void)updatePickerView:(UIPickerView *)pickerView animated:(BOOL)animated;
@end

@implementation MTSetupViewController
@synthesize startButton = _startButton;
@synthesize startDate = _startDate;
@synthesize stopWhenTimesUp = _stopWhenTimesUp;
@synthesize picker = _picker;
@synthesize timeIntervalView = _timeIntervalView;
@synthesize stopWhenTimesUpCheckbox = _stopWhenTimesUpCheckbox;

- (void)viewDidLoad
{
    // picker view
    NSUInteger fromBPM = [[NSUserDefaults standardUserDefaults] integerForKey:kMTFromBPMDefaultsKey];
	self.fromBPM = (0 == fromBPM) ? kMTDefaultFromBPM : fromBPM;
    NSUInteger toBPM = [[NSUserDefaults standardUserDefaults] integerForKey:kMTToBPMDefaultsKey];
	self.toBPM = (0 == toBPM) ? kMTDefaultToBPM : toBPM;
    [self updatePickerView:self.picker animated:YES];
    
    // time interval view
    NSUInteger timeInterval = [[NSUserDefaults standardUserDefaults] integerForKey:kMTTimeIntervalDefaultsKey];
    self.timeIntervalView.currentValue = (0 == timeInterval) ? kMTDefaultTimeInterval : timeInterval;
#ifdef DEBUG
#warning TODO: find cool images for checkbox
#endif
    // stop when time's up checkbox
    self.stopWhenTimesUp = [[NSUserDefaults standardUserDefaults] boolForKey:kMTStopWhenTimesUpKey];
    [self.stopWhenTimesUpCheckbox setBackgroundImage:[UIImage imageNamed:@"two.png"] forState:UIControlStateNormal];
    [self.stopWhenTimesUpCheckbox setBackgroundImage:[UIImage imageNamed:@"one.png"] forState:UIControlStateSelected];
    [self.stopWhenTimesUpCheckbox setSelected:self.stopWhenTimesUp];
    
    [super viewDidLoad];
}

- (void)setFromBPM:(NSUInteger)fromBPM
{
    if (fromBPM != super.fromBPM)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:fromBPM forKey:kMTFromBPMDefaultsKey];
        [super setFromBPM:fromBPM];
    }
}

- (void)setToBPM:(NSUInteger)toBPM
{
    if (toBPM != super.toBPM)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:toBPM forKey:kMTToBPMDefaultsKey];
        [super setToBPM:toBPM];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kMTStartMethronomeSegueKey])
    {
        MTMethronomeViewController *methronomeViewController = segue.destinationViewController;
        [methronomeViewController setFromBPM:self.fromBPM];
        [methronomeViewController setToBPM:self.toBPM];
        [methronomeViewController setTimeInterval:self.timeIntervalView.currentValue];
        [methronomeViewController setStrongMesure:self.strongMesure];
    }
}

- (IBAction)onExchangeButton:(id)sender
{
    NSUInteger newFromBPM = self.toBPM;
    [self setToBPM:self.fromBPM];
    [self setFromBPM:newFromBPM];
    
    [self updatePickerView:self.picker animated:YES];
}

- (IBAction)onMesureSegmentedControl:(UISegmentedControl *)sender
{
	switch ([sender selectedSegmentIndex])
	{
		case 0:
			self.strongMesure = 0;
			break;
		case 1:
			self.strongMesure = 2;
			break;
		case 2:
			self.strongMesure = 3;
			break;
		case 3:
			self.strongMesure = 4;
			break;
		case 4:
			self.strongMesure = 5;
			break;
		case 5:
			self.strongMesure = 7;
			break;
	}
}

- (IBAction)onTimesUpCheckbox:(id)sender
{
    UIButton *aButton = (UIButton *)sender;
    self.stopWhenTimesUp = !self.stopWhenTimesUp;
    [[NSUserDefaults standardUserDefaults] setBool:self.stopWhenTimesUp forKey:kMTStopWhenTimesUpKey];
    [aButton setSelected:self.stopWhenTimesUp];
    NSLog((self.stopWhenTimesUp ? @"stop when time's up" : @"continue when time's up"));
}

- (void)updatePickerView:(UIPickerView *)pickerView animated:(BOOL)animated
{
	[pickerView selectRow: self.fromBPM - kMTPickerViewMinimumValue inComponent: 0 animated: animated];
	[pickerView selectRow: self.toBPM - kMTPickerViewMinimumValue inComponent: 1 animated: animated];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 300 - kMTPickerViewMinimumValue;
}

#pragma mark UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	CGSize size = [pickerView rowSizeForComponent: component];
	UILabel* label = nil;
	if (nil != view && [view isKindOfClass:[UIView class]])
	{
		label = (UILabel*)view;
	}
	else
	{
		label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
		[label setTextAlignment:UITextAlignmentCenter];
		[label setFont: [UIFont boldSystemFontOfSize:18]];
	}
	[label setText: [NSString stringWithFormat: @"%d", row + kMTPickerViewMinimumValue]];
	return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == 0)
	{
		self.fromBPM = row + kMTPickerViewMinimumValue;
		NSLog(@"from: %u", self.fromBPM);
	}
	else if (component == 1)
	{
		self.toBPM = row + kMTPickerViewMinimumValue;
		NSLog(@"to: %u", self.toBPM);
	}
}

@end
