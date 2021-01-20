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
@property (nonatomic, strong, readwrite) NSMutableSet *toolbarButtons;

@end

@implementation ThumbsMainToolbar
{
    UIImage *thumbsImageN;
    UIImage *thumbsImageY;
    UIImage *markImageN;
    UIImage *markImageY;
}
#pragma mark - Constants

#define BUTTON_X READER_TOOLBAR_BUTTON_X
#define BUTTON_Y READER_TOOLBAR_BUTTON_Y

#define BUTTON_SPACE READER_TOOLBAR_BUTTON_SPACE
#define BUTTON_HEIGHT READER_TOOLBAR_BUTTON_HEIGHT

#define BUTTON_FONT_SIZE READER_TOOLBAR_BUTTON_FONT_SIZE
#define TEXT_BUTTON_PADDING READER_TOOLBAR_TEXT_BUTTON_PADDING

#define ICON_BUTTON_WIDTH READER_TOOLBAR_ICON_BUTTON_WIDTH

#define TITLE_FONT_SIZE READER_TOOLBAR_TITLE_FONT_SIZE
#define TITLE_HEIGHT READER_TOOLBAR_TITLE_HEIGHT


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

		CGFloat titleX = BUTTON_X;
        CGFloat titleWidth = (viewWidth - (titleX + titleX));

		CGFloat leftButtonX = BUTTON_X; // Left-side button start X position

#if (READER_ENABLE_HELP_BUTTON == TRUE) // Option
        
        UIGlossyButton *helpButton = [UIGlossyButton glossyButtonWithTitle:nil image:[UIImage imageNamed:@"Reader-iconInfo"] highlighted:NO forTarget:self selector:@selector(helpButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        iconButtonWidth = helpButton.bounds.size.width;
        leftButtonX += (iconButtonWidth + buttonSpacing);  // Add the width of one button to position the help button in line with the help button from the ReaderMainToolbar
        CGRect buttonRect = CGRectMake(leftButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
        helpButton.frame = buttonRect;
        helpButton.autoresizingMask = UIViewAutoresizingNone;
        helpButton.exclusiveTouch = YES;
        helpButton.tag = 5005;
        
        [self addSubview:helpButton];
        [self.toolbarButtons addObject:helpButton];

        leftButtonX += (iconButtonWidth + buttonSpacing);
        
        titleX += (iconButtonWidth + buttonSpacing);
        titleWidth -= (iconButtonWidth + buttonSpacing);
        
#endif // end of READER_ENABLE_HELP_BUTTON Option
        
        UIGlossyButton *singlePageViewButton = [UIGlossyButton glossyButtonWithTitle:nil image:[UIImage imageNamed:@"iconSinglePageViewEnabled"] highlighted:NO forTarget:self selector:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        iconButtonWidth = singlePageViewButton.bounds.size.width;
        CGRect singlePageViewButtonRect = CGRectMake(leftButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
        singlePageViewButton.frame = singlePageViewButtonRect;
        singlePageViewButton.autoresizingMask = UIViewAutoresizingNone;
        singlePageViewButton.exclusiveTouch = YES;
        
        [self addSubview:singlePageViewButton];
        [self.toolbarButtons addObject:singlePageViewButton];

        titleX += (iconButtonWidth + buttonSpacing);
        titleWidth -= (iconButtonWidth + buttonSpacing);
        
        /* This section needs to be reworked if its going to be implemented
         CGFloat rightButtonX = viewWidth; // Right-side buttons start X position
         
#if (READER_BOOKMARKS == TRUE) // Option
        
        markImageN = [UIImage imageNamed:@"iconBookmarkDisabled"]; // N image
        markImageY = [UIImage imageNamed:@"iconBookmarkEnabled"]; // Y image
        UIGlossyButton *flagButton = [UIGlossyButton glossyButtonWithTitle:nil image:markImageN highlighted:NO forTarget:self selector:@selector(viewModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        iconButtonWidth = flagButton.bounds.size.width;
        rightButtonX -= (iconButtonWidth + buttonSpacing); // Position
        CGRect flagButtonFrame = CGRectMake(rightButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
        flagButton.frame = flagButtonFrame;
        flagButton.exclusiveTouch = YES;
        flagButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

        [self addSubview:flagButton];
        titleWidth -= (iconButtonWidth + buttonSpacing);
        
        self.markButton = flagButton;
        self.markButton.tag = 0;

        titleX += (iconButtonWidth + buttonSpacing);
        titleWidth -= (iconButtonWidth + buttonSpacing);

        thumbsImageN = [UIImage imageNamed:@"iconThumbnailViewDisabled"]; // N image
        thumbsImageY = [UIImage imageNamed:@"iconThumbnailView"]; // Y image
        UIGlossyButton *newThumbButton = [UIGlossyButton glossyButtonWithTitle:nil image:thumbsImageY highlighted:NO forTarget:self selector:@selector(viewModeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        iconButtonWidth = newThumbButton.bounds.size.width;
        rightButtonX -= (iconButtonWidth + buttonSpacing); // Position
        
        CGRect buttonRect = CGRectMake(rightButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
        newThumbButton.frame = buttonRect;
        newThumbButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        newThumbButton.exclusiveTouch = YES;
        
        [self addSubview:newThumbButton];
        self.thumbsButton = newThumbButton;
        self.thumbsButton.tag = 1;
#endif
         */
        
		if (largeDevice == YES) // Show document filename in toolbar
		{
			CGRect titleRect = CGRectMake(titleX, BUTTON_Y, titleWidth, TITLE_HEIGHT);

			UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];

			titleLabel.textAlignment = NSTextAlignmentCenter;
			titleLabel.font = [UIFont systemFontOfSize:TITLE_FONT_SIZE];
			titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			titleLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.adjustsFontSizeToFitWidth = YES;
			titleLabel.minimumScaleFactor = 0.25f;
			titleLabel.text = title;
#if (READER_FLAT_UI == FALSE) // Option
			titleLabel.shadowColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
			titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
#endif // end of READER_FLAT_UI Option

			[self addSubview:titleLabel];
		}
	}

	return self;
}

-(NSMutableSet *)toolbarButtons;
{
    if (nil != _toolbarButtons) {
        return _toolbarButtons;
    }
    
    _toolbarButtons = [NSMutableSet new];
    return _toolbarButtons;
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

- (void)helpButtonTapped:(UIButton *)button
{
    if ([delegate respondsToSelector:@selector(tappedInToolbar:helpButton:)]) {
        [delegate tappedInToolbar:self helpButton:button];
    }
}

@end
