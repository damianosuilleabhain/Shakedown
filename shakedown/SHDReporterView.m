//
//  SHDReporterView.m
//  Shakedown
//
//  Created by Max Goedjen on 4/17/13.
//  Copyright (c) 2013 Max Goedjen. All rights reserved.
//

#import "SHDReporterView.h"
#import "SHDBugReport.h"
#import "SHDConstants.h"
#import "SHDTextViewCell.h"
#import "SHDTextFieldCell.h"
#import "SHDMultipleSelectionCell.h"
#import "SHDScreenshotsCell.h"
#import "SHDDescriptiveInfoCell.h"
#import "SHDListCell.h"
#import "SHDRedmineSpecificDatasource.h"

#define IS_IPHONE UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
#define IS_WIDESCREEN UIScreen.mainScreen.bounds.size.height == 568
#define IS_WIDESCREEN_IPHONE (IS_IPHONE && IS_WIDESCREEN)

@interface SHDReporterView ()
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) NSMutableArray * cells;
@end


@implementation SHDReporterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.scrollView addSubview:self.contentView];
        [self addSubview:self.scrollView];
        self.backgroundColor = kSHDBackgroundColor;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat offset = 0;

    for (UIView * cell in self.cells) {
        NSInteger cellHeight = 0;
        if (cell == self.deviceInfoCell)
            cellHeight = self.deviceInfoCell.height;
        else
            cellHeight = cell.frame.size.height;
        cell.frame  = (CGRect){cell.frame.origin.x, offset, cell.frame.size.width, cellHeight};
        
        offset += cell.frame.size.height;
    }
    
    self.contentView.frame = (CGRect) {self.contentView.frame.origin, self.frame.size.width, offset};
    self.scrollView.contentSize = self.contentView.frame.size;
}

#pragma mark - Getters

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _scrollView;
}

- (NSMutableArray *)cells
{
    if (!_cells) {
        _cells = [NSMutableArray array];
    }
    return _cells;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        
        UIColor * color = kSHDBackgroundAlternateColor;
        self.trackerCell = [self cellForClass:SHDMultipleSelectionCell.class height:50 backgroundColor:color];
        self.titleCell = [self cellForClass:SHDTextFieldCell.class height:50 backgroundColor:nil];
        self.descriptionCell = [self cellForClass:SHDTextViewCell.class height:(IS_WIDESCREEN_IPHONE ? 120:70) backgroundColor:color];
        self.reproducabilityCell = [self cellForClass:SHDMultipleSelectionCell.class height:50 backgroundColor:nil];
        self.stepsCell = [self cellForClass:SHDListCell.class height:50 backgroundColor:color];
        self.screenshotsCell =[self cellForClass:SHDScreenshotsCell.class height:100 backgroundColor:nil];
        self.deviceInfoCell = [self cellForClass:SHDDescriptiveInfoCell.class height:100 backgroundColor:color];
    }
    return _contentView;
}

- (id)cellForClass:(Class)class height:(NSInteger)height backgroundColor:(UIColor *)backgroundColor {
    CGRect cellFrame = (CGRect){CGPointZero, self.bounds.size.width, height};
    UIView * cell = [[class alloc] initWithFrame:cellFrame];
    if (backgroundColor != nil) cell.backgroundColor = backgroundColor;
    [self.contentView addSubview:cell];
    [self.cells addObject:cell];
    return cell;
}

@end
