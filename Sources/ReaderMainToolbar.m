//
//	ReaderMainToolbar.m
//	Reader v2.8.6
//
//	Created by Julius Oklamcak on 2011-07-01.
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
#import "ReaderMainToolbar.h"
#import "ReaderDocument.h"
#import "UIGlossyButton.h"

#import <MessageUI/MessageUI.h>

@interface ReaderMainToolbar ()

@property (nonatomic, strong, readwrite) NSMutableSet *toolbarButtons;

@end

@implementation ReaderMainToolbar
{
    UIGlossyButton *gbBookmark;
    
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

#pragma mark - ReaderMainToolbar instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame document:nil];
}

- (instancetype)initWithFrame:(CGRect)frame document:(ReaderDocument *)document
{
    assert(document != nil); // Must have a valid ReaderDocument
    
    if ((self = [super initWithFrame:frame]))
    {
        CGFloat viewWidth = self.bounds.size.width; // Toolbar view width
        
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
        
        const CGFloat buttonSpacing = BUTTON_SPACE;
        CGFloat iconButtonWidth = ICON_BUTTON_WIDTH; // Starts with default value, but will be based on UIGlossButton actual width values
        
        CGFloat titleX = BUTTON_X; CGFloat titleWidth = (viewWidth - (titleX + titleX));
        
        CGFloat leftButtonX = BUTTON_X; // Left-side button start X position
        
#if (READER_STANDALONE == FALSE) // Option
        
        UIGlossyButton *doneButton = [UIGlossyButton glossyButtonWithTitle:nil image:[UIImage imageNamed:@"iconDone"] highlighted:NO forTarget:self selector:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        iconButtonWidth = doneButton.bounds.size.width;
        CGRect doneButtonRect = CGRectMake(leftButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
        doneButton.frame = doneButtonRect;
        doneButton.autoresizingMask = UIViewAutoresizingNone;
        doneButton.exclusiveTouch = YES;
        
        [self addSubview:doneButton];
        [self.toolbarButtons addObject:doneButton];
        
        leftButtonX += (iconButtonWidth + buttonSpacing);
        
        titleX += (iconButtonWidth + buttonSpacing);
        titleWidth -= (iconButtonWidth + buttonSpacing);
        
#endif // end of READER_STANDALONE Option
        
#if (READER_ENABLE_HELP_BUTTON == TRUE) // Option
        
        UIGlossyButton *helpButton = [UIGlossyButton glossyButtonWithTitle:nil image:[UIImage imageNamed:@"Reader-iconInfo"] highlighted:NO forTarget:self selector:@selector(helpButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        iconButtonWidth = helpButton.bounds.size.width;
        CGRect helpButtonRect = CGRectMake(leftButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
        helpButton.frame = helpButtonRect;
        helpButton.autoresizingMask = UIViewAutoresizingNone;
        helpButton.exclusiveTouch = YES;
        helpButton.tag = 5005;
        
        [self addSubview:helpButton];
        [self.toolbarButtons addObject:helpButton];
        
        leftButtonX += (iconButtonWidth + buttonSpacing);
        
        titleX += (iconButtonWidth + buttonSpacing);
        titleWidth -= (iconButtonWidth + buttonSpacing);
        
#endif // end of READER_ENABLE_HELP_BUTTON Option
        
#if (READER_ENABLE_THUMBS == TRUE) // Option
        
        UIGlossyButton *thumbsButton = [UIGlossyButton glossyButtonWithTitle:nil image:[UIImage imageNamed:@"iconThumbnailView"] highlighted:NO forTarget:self selector:@selector(thumbsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        iconButtonWidth = thumbsButton.bounds.size.width;
        CGRect thumbButtonRect = CGRectMake(leftButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
        thumbsButton.frame = thumbButtonRect;
        thumbsButton.autoresizingMask = UIViewAutoresizingNone;
        thumbsButton.exclusiveTouch = YES;
        
        [self addSubview:thumbsButton];
        [self.toolbarButtons addObject:thumbsButton];

        leftButtonX += (iconButtonWidth + buttonSpacing);
        
        titleX += (iconButtonWidth + buttonSpacing);
        titleWidth -= (iconButtonWidth + buttonSpacing);
        
#endif // end of READER_ENABLE_THUMBS Option
        
        CGFloat rightButtonX = viewWidth; // Right-side buttons start X position
        
#if (READER_BOOKMARKS == TRUE) // Option
        
        UIGlossyButton *flagButton = [UIGlossyButton glossyButtonWithTitle:nil image:[UIImage imageNamed:@"iconBookmarkDisabled"] highlighted:NO forTarget:self selector:@selector(markButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        iconButtonWidth = flagButton.bounds.size.width;
        rightButtonX -= (iconButtonWidth + buttonSpacing); // Position
        CGRect flagButtonFrame = CGRectMake(rightButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
        flagButton.frame = flagButtonFrame;
        flagButton.exclusiveTouch = YES;
        flagButton.enabled = NO;
        flagButton.tag = NSIntegerMin;
        
        [self addSubview:flagButton];
        gbBookmark = flagButton;
        [self.toolbarButtons addObject:flagButton];
        
        titleWidth -= (iconButtonWidth + buttonSpacing);
        
        markImageN = [UIImage imageNamed:@"iconBookmarkDisabled"]; // N image
        markImageY = [UIImage imageNamed:@"iconBookmarkEnabled"]; // Y image
        
#endif // end of READER_BOOKMARKS Option
        
        if (document.canEmail == YES) // Document email enabled
        {
            if ([MFMailComposeViewController canSendMail] == YES) // Can email
            {
                unsigned long long fileSize = [document.fileSize unsignedLongLongValue];
                
                if (fileSize < 15728640ull) // Check attachment size limit (15MB)
                {
                    rightButtonX -= (iconButtonWidth + buttonSpacing); // Next position
                    
                    UIGlossyButton *emailButton = [UIGlossyButton glossyButtonWithTitle:nil image:[UIImage imageNamed:@"iconEmail"] highlighted:NO forTarget:self selector:@selector(emailButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    iconButtonWidth = emailButton.bounds.size.width;
                    CGRect emailButtonFrame = CGRectMake(rightButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
                    emailButton.frame = emailButtonFrame;
                    emailButton.exclusiveTouch = YES;
                    
                    [self addSubview:emailButton];
                    [self.toolbarButtons addObject:emailButton];

                    titleWidth -= (iconButtonWidth + buttonSpacing);
                }
            }
        }
        
        if ((document.canPrint == YES) && (document.password == nil)) // Document print enabled
        {
            Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");
            
            if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
            {
                rightButtonX -= (iconButtonWidth + buttonSpacing); // Next position
                
                UIGlossyButton *printButton = [UIGlossyButton glossyButtonWithTitle:nil image:[UIImage imageNamed:@"iconPrint"] highlighted:NO forTarget:self selector:@selector(printButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                iconButtonWidth = printButton.bounds.size.width;
                CGRect printButtonFrame = CGRectMake(rightButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
                printButton.frame = printButtonFrame;
                printButton.exclusiveTouch = YES;
                
                [self addSubview:printButton];
                [self.toolbarButtons addObject:printButton];

                titleWidth -= (iconButtonWidth + buttonSpacing);
            }
        }
        
        if (document.canExport == YES) // Document export enabled
        {
            rightButtonX -= (iconButtonWidth + buttonSpacing); // Next position
            
            UIGlossyButton *exportButton = [UIGlossyButton glossyButtonWithTitle:nil image:[UIImage imageNamed:@"iconExport"] highlighted:NO forTarget:self selector:@selector(exportButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            iconButtonWidth = exportButton.bounds.size.width;
            CGRect exportButtonFrame = CGRectMake(rightButtonX, BUTTON_Y, iconButtonWidth, BUTTON_HEIGHT);
            exportButton.frame = exportButtonFrame;
            exportButton.exclusiveTouch = YES;
            
            [self addSubview:exportButton];
            [self.toolbarButtons addObject:exportButton];

            titleWidth -= (iconButtonWidth + buttonSpacing);
        }
        
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
            titleLabel.text = [document.fileName stringByDeletingPathExtension];
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

- (void)setBookmarkState:(BOOL)state
{
#if (READER_BOOKMARKS == TRUE) // Option
    
    if (state != self.gbBookmark.tag) // Only if different state
    {
        if (self.hidden == NO) // Only if toolbar is visible
        {
            UIImage *image = (state ? markImageY : markImageN);
            
            [self.gbBookmark replaceExistingImageWith:image animate:YES duration:0.25];
        }
        
        self.gbBookmark.tag = state; // Update bookmarked state tag
    }
    
    if (self.gbBookmark.enabled == NO) self.gbBookmark.enabled = YES;
    
#endif // end of READER_BOOKMARKS Option
}

- (void)updateBookmarkImage
{
#if (READER_BOOKMARKS == TRUE) // Option
    
    if (self.gbBookmark.tag != NSIntegerMin) // Valid tag
    {
        BOOL state = self.gbBookmark.tag; // Bookmarked state
        
        UIImage *image = (state ? markImageY : markImageN);
        
        [self.gbBookmark replaceExistingImageWith:image animate:YES duration:0.25];
    }
    
    if (self.gbBookmark.enabled == NO) self.gbBookmark.enabled = YES;
    
#endif // end of READER_BOOKMARKS Option
}

- (void)hideToolbar
{
	if (self.hidden == NO)
	{
		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.alpha = 0.0f;
			}
			completion:^(BOOL finished)
			{
				self.hidden = YES;
			}
		];
	}
}

- (void)showToolbar
{
	if (self.hidden == YES)
	{
		[self updateBookmarkImage]; // First

		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.hidden = NO;
				self.alpha = 1.0f;
			}
			completion:NULL
		];
	}
}

#pragma mark - UIButton action methods

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

- (void)thumbsButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self thumbsButton:button];
}

- (void)exportButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self exportButton:button];
}

- (void)printButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self printButton:button];
}

- (void)emailButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self emailButton:button];
}

- (void)markButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self markButton:button];
}

@end
