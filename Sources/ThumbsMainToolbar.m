//
//	ThumbsMainToolbar.m
//	Reader v2.8.6
//
//	Created by Julius Oklamcak on 2011-09-01.
//	Copyright © 2011-2015 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderConstants.h"
#import "ThumbsMainToolbar.h"
#import "UIGlossyButton.h"

@interface ThumbsMainToolbar ()

@property (nonatomic, readwrite, strong) UIGlossyButton *thumbsButton;
@property (nonatomic, readwrite, strong) UIGlossyButton *markButton;

@end

@implementation ThumbsMainToolbar
{
    UIImage *thumbsImageN;
    UIImage *thumbsImageY;
    UIImage *markImageN;
    UIImage *markImageY;
}
#pragma mark - Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f

#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 34.0f

#define BUTTON_FONT_SIZE 15.0f
#define TEXT_BUTTON_PADDING 24.0f

#define SHOW_CONTROL_WIDTH 78.0f
#define ICON_BUTTON_WIDTH 40.0f

#define TITLE_FONT_SIZE 19.0f
#define TITLE_HEIGHT 28.0f

#pragma mark - Properties

@synthesize delegate;

#pragma mark - ThumbsMainToolbar instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame title:nil];
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title
{
	if ((self = [super initWithFrame:frame]))
	{
		CGFloat viewWidth = self.bounds.size.width; // Toolbar view width
        CGFloat iconButtonWidth = ICON_BUTTON_WIDTH; // To start with, but will update to actual width of UIGlossyButtons
        
#if (READER_FLAT_UI == TRUE) // Option
        self.backgroundColor = READER_TOOLBAR_PRIMARY_TINT;
#else
		UIImage *buttonH = [[UIImage imageNamed:@"Reader-Button-H"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
		UIImage *buttonN = [[UIImage imageNamed:@"Reader-Button-N"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        {
            self.backgroundColor = READER_TOOLBAR_PRIMARY_TINT;
            CAGradientLayer *layer = (CAGradientLayer *)self.layer;
            UIColor *liteColor = READER_TOOLBAR_SECONDARY_TINT;
            UIColor *darkColor = READER_TOOLBAR_PRIMARY_TINT;
            layer.colors = [NSArray arrayWithObjects:(id)liteColor.CGColor, (id)darkColor.CGColor, nil];
        }

#endif // end of READER_FLAT_UI Option

		BOOL largeDevice = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);

		const CGFloat buttonSpacing = BUTTON_SPACE; //const CGFloat iconButtonWidth = ICON_BUTTON_WIDTH;

		CGFloat titleX = BUTTON_X; CGFloat titleWidth = (viewWidth - (titleX + titleX));

		CGFloat leftButtonX = BUTTON_X; // Left-side button start X position

        UIGlossyButton *doneButton = [UIGlossyButton glossyButtonWithTitle:nil image:[UIImage imageNamed:@"iconDone"] highlighted:NO forTarget:self selector:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        iconButtonWidth = doneButton.bounds.size.width;
        CGRect doneButtonRect = CGRectMake(leftButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
        doneButton.frame = doneButtonRect;
        doneButton.autoresizingMask = UIViewAutoresizingNone;
        doneButton.exclusiveTouch = YES;
        
        [self addSubview:doneButton];
        
        CGFloat rightButtonX = viewWidth; // Right-side buttons start X position

#if (READER_BOOKMARKS == TRUE) // Option
        
        titleX += (iconButtonWidth + buttonSpacing);
        titleWidth -= (iconButtonWidth + buttonSpacing);
        
        markImageN = [UIImage imageNamed:@"iconBookmarkDisabled"]; // N image
        markImageY = [UIImage imageNamed:@"iconBookmarkEnabled"]; // Y image
        UIGlossyButton *flagButton = [UIGlossyButton glossyButtonWithTitle:nil image:markImageN highlighted:NO forTarget:self selector:@selector(viewModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        iconButtonWidth = flagButton.bounds.size.width;
        rightButtonX -= (iconButtonWidth + buttonSpacing); // Position
        CGRect flagButtonFrame = CGRectMake(rightButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
        flagButton.frame = flagButtonFrame;
        flagButton.exclusiveTouch = YES;
        
        [self addSubview:flagButton];
        titleWidth -= (iconButtonWidth + buttonSpacing);
        
        self.markButton = flagButton;
        self.markButton.tag = 0;
#endif

        titleX += (iconButtonWidth + buttonSpacing);
        titleWidth -= (iconButtonWidth + buttonSpacing);

        thumbsImageN = [UIImage imageNamed:@"iconThumbnailViewDisabled"]; // N image
        thumbsImageY = [UIImage imageNamed:@"iconThumbnailView"]; // Y image
        UIGlossyButton *newThumbButton = [UIGlossyButton glossyButtonWithTitle:nil image:thumbsImageY highlighted:NO forTarget:self selector:@selector(viewModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        iconButtonWidth = newThumbButton.bounds.size.width;
        rightButtonX -= (iconButtonWidth + buttonSpacing); // Position
        
        CGRect buttonRect = CGRectMake(rightButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
        newThumbButton.frame = buttonRect;
        newThumbButton.autoresizingMask = UIViewAutoresizingNone;
        newThumbButton.exclusiveTouch = YES;
        
        [self addSubview:newThumbButton];
        self.thumbsButton = newThumbButton;
        self.thumbsButton.tag = 1;

		if (largeDevice == YES) // Show document filename in toolbar
		{
			CGRect titleRect = CGRectMake(titleX, BUTTON_Y, titleWidth, TITLE_HEIGHT);

			UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];

			titleLabel.textAlignment = NSTextAlignmentCenter;
			titleLabel.font = [UIFont systemFontOfSize:TITLE_FONT_SIZE];
			titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			titleLabel.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.adjustsFontSizeToFitWidth = YES;
			titleLabel.minimumScaleFactor = 0.75f;
			titleLabel.text = title;
#if (READER_FLAT_UI == FALSE) // Option
			titleLabel.shadowColor = [UIColor colorWithWhite:0.65f alpha:1.0f];
			titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
#endif // end of READER_FLAT_UI Option

			[self addSubview:titleLabel];
		}
	}

	return self;
}

-(UIImage *)imageForViewModeButton:(UIGlossyButton *)viewModeButton state:(BOOL)state;
{
    UIImage *buttonImage = nil;
    if ([viewModeButton isEqual:self.thumbsButton]) {
        if (state) {
            buttonImage = thumbsImageY;
        } else {
            buttonImage = thumbsImageN;
        }
    } else if ([viewModeButton isEqual:self.markButton]){
        if (state) {
            buttonImage = markImageY;
        } else {
            buttonImage = markImageN;
        }
    }
    return buttonImage;
}

- (void)setViewModeButton:(UIGlossyButton *)viewModeButton state:(BOOL)state;
{
    if (state != viewModeButton.tag) {
        if (self.hidden == NO) // Only if toolbar is visible
        {
            UIImage *image = [self imageForViewModeButton:viewModeButton state:state];
            
            [viewModeButton replaceExistingImageWith:image animate:YES duration:0.25];
        }

        viewModeButton.tag = state; // Update bookmarked state tag
    }
    
    if (viewModeButton.enabled == NO) viewModeButton.enabled = YES;
}

- (void)updateImageForViewModeButton:(UIGlossyButton *)viewModeButton;
{
    if (viewModeButton.tag != NSIntegerMin) // Valid tag
    {
        BOOL state = viewModeButton.tag; // Bookmarked state
        
        UIImage *image = [self imageForViewModeButton:viewModeButton state:state];
        
        [viewModeButton replaceExistingImageWith:image animate:YES duration:0.25];
    }
    
    if (viewModeButton.enabled == NO) viewModeButton.enabled = YES;
}

#pragma mark - UIGlossyButton action methods

- (void)viewModeButtonTapped:(UIGlossyButton *)button;
{
	[delegate tappedInToolbar:self viewModeButton:button];
}

- (void)doneButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self doneButton:button];
}

@end