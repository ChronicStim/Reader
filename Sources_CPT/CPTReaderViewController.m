//
//  CPTReaderViewController.m
//  PainTracker
//
//  Created by Wendy Kutschke on 4/21/16.
//  Copyright © 2016 Chronic Stimulation, LLC. All rights reserved.
//

#import "CPTReaderViewController.h"
#import "CPTThumbsViewController.h"
#import "ReaderMainToolbar.h"
#import "ReaderDocument.h"
#import "ReaderConstants.h"
#import "ReaderMainPagebar.h"
#import "PopupDisplayController.h"
#import "HelpFirstView.h"
#import "MailMeObject.h"
#import "MailGeneratorViewController.h"
#import "PainTrackerAppDelegate.h"
#import "DropBoxSyncController.h"
#import "MBProgressHUD+Custom.h"

@interface CPTReaderViewController ()
< ReaderMainToolbarDelegate, ReaderMainPagebarDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, ThumbsViewControllerDelegate, PopupDisplayControllerDelegate, MBProgressHUDDelegate >
{
}

@property (nonatomic, readwrite, strong) UIPrintInteractionController *printInteraction;
@property (nonatomic, readwrite, strong) UIDocumentInteractionController *documentInteraction;
@property (nonatomic, readwrite, strong) ReaderDocument *document;
@property (nonatomic, readwrite, assign) UIUserInterfaceIdiom userInterfaceIdiom;
@property (nonatomic, readwrite, strong) ReaderMainToolbar *mainToolbar;
@property (nonatomic, readwrite, strong) ReaderMainPagebar *mainPagebar;
@property (nonatomic, readwrite, assign) NSInteger currentPage;
@property (nonatomic, readwrite, assign) NSInteger minimumPage;
@property (nonatomic, readwrite, assign) NSInteger maximumPage;
@property (nonatomic, strong) PopupDisplayController *popupDisplayController;
@property (nonatomic, strong) NSTimer *popupDelayTimer;
@property (nonatomic, assign) BOOL deviceShaking;

@end

@implementation CPTReaderViewController

-(void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
    
    
    [self checkIfHelpFirstViewShouldDisplayForViewKey:kHelpFirstViewKey usingForce:NO];
}

-(BOOL)prefersStatusBarHidden;
{
    return NO;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation;
{
    return UIStatusBarAnimationFade;
}

#pragma mark - Help Button System Methods

-(PopupDisplayController *)popupDisplayController;
{
    if (nil != _popupDisplayController) {
        return _popupDisplayController;
    }
    
    _popupDisplayController = [[PopupDisplayController alloc] init];
    [_popupDisplayController setDelegate:self];
    return _popupDisplayController;
}

-(void)startPopupDelayTimer;
{
    //NSLog(@"Starting Delay Timer");
    NSDate *fireDate = [[NSDate date] dateByAddingTimeInterval:5];
    self.popupDelayTimer = [[NSTimer alloc] initWithFireDate:fireDate interval:5 target:self selector:@selector(beginPopupDisplay) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.popupDelayTimer forMode:NSDefaultRunLoopMode];
}

-(void)beginPopupDisplay;
{
    if (nil != _popupDisplayController) {
        [self performSelectorOnMainThread:@selector(beginPopupDisplayOnMainThread) withObject:nil waitUntilDone:NO];
    }
    [self.popupDelayTimer invalidate];
    self.popupDelayTimer = nil;
}

-(void)beginPopupDisplayOnMainThread;
{
    //NSLog(@"Beginning popup display");
    [self.popupDisplayController displayUsingTimerInterval:3];
}

-(void)killPopupDisplayProcesses;
{
    // If the delay timer is not NIL, then invalidate it to cancel the popups
    //NSLog(@"Check if PopupDisplay processes need to be killed.");
    
    if (nil != _popupDelayTimer) {
        //NSLog(@"Killing popupDelayTimer");
        [self.popupDelayTimer invalidate];
        _popupDelayTimer = nil;
    }
    
    // If popups are actively being displayed, then terminate the display
    if (nil != [self.popupDisplayController popupTimer]) {
        //NSLog(@"Killing popups");
        [self.popupDisplayController stopDisplayingPopups];
    }
}

-(CGRect)locationOfCustomHelpButton;
{
    CGRect locationRect = CGRectZero;
    for (UIGlossyButton *glossyButton in [self.mainToolbar.toolbarButtons allObjects]) {
        if (glossyButton.tag == 5005) {
            locationRect = [glossyButton convertRect:glossyButton.bounds toView:self.view];
            break;
        }
    }
    return locationRect;
}

-(void)checkIfHelpFirstViewShouldDisplayForViewKey:(NSString *)viewKey usingForce:(BOOL)useForce;
{
    // Display Help for view
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (nil == [defaults objectForKey:kHelpFirstViewKeyDisplayHelpOnShake]) {
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:kHelpFirstViewKeyDisplayHelpOnShake];
        [defaults synchronize];
    }
    BOOL showHelpOnShake = [[defaults objectForKey:kHelpFirstViewKeyDisplayHelpOnShake] boolValue];
    if (showHelpOnShake) {
        CGRect helpInitiationPoint = [self locationOfCustomHelpButton];
        if (CGRectEqualToRect(helpInitiationPoint, CGRectZero)) {
            helpInitiationPoint = CGRectMake(CGRectGetMidX(self.view.bounds), 0, 1, 1);
        }
        HelpFirstView *helpFirstView = [HelpFirstView sharedHelpFirstView];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [helpFirstView displayHelpPopoverForViewKey:viewKey forceDisplay:useForce fromRect:helpInitiationPoint inView:self.view];
        } else {
            [helpFirstView displayHelpPopoverForViewKey:viewKey forceDisplay:useForce fromController:self];
        }
    }
}

#pragma mark - ReaderMainToolbarDelegate methods

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button
{
#if (READER_STANDALONE == FALSE) // Option
    
    [self closeDocument]; // Close ReaderViewController
    
#endif // end of READER_STANDALONE Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar thumbsButton:(UIButton *)button
{
#if (READER_ENABLE_THUMBS == TRUE) // Option
    
    if (self.printInteraction != nil) [self.printInteraction dismissAnimated:NO];
    
    CPTThumbsViewController *thumbsViewController = [[CPTThumbsViewController alloc] initWithReaderDocument:self.document];
    
    thumbsViewController.title = self.title;
    thumbsViewController.delegate = self; // ThumbsViewControllerDelegate
    
    thumbsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    thumbsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:thumbsViewController animated:NO completion:NULL];
    
#endif // end of READER_ENABLE_THUMBS Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar exportToDropboxButton:(UIButton *)button
{
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __typeof__(self) strongSelf = weakSelf;
        
        if (strongSelf.printInteraction != nil) [strongSelf.printInteraction dismissAnimated:YES];
        
        NSURL *fileURL = strongSelf.document.fileURL; // Document file URL
        
        if ([[DropBoxSyncController sharedDropBoxSyncController] dropboxIsLinkedOrGiveOptionToLink:YES fromViewController:strongSelf]) {
            
            [[DropBoxSyncController sharedDropBoxSyncController] syncFileAtFilePath:fileURL.path];
            
            [Flurry logEvent:@"Report Syncd to Dropbox"];
        }
    });
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar exportButton:(UIButton *)button
{
    if (self.printInteraction != nil) [self.printInteraction dismissAnimated:YES];
    
    NSURL *fileURL = self.document.fileURL; // Document file URL
    
    self.documentInteraction = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    
    self.documentInteraction.delegate = self; // UIDocumentInteractionControllerDelegate
    
    if (![self.documentInteraction presentOpenInMenuFromRect:button.bounds inView:button animated:YES]) {
        NSString *title = NSLocalizedStringFromTable(@"No Compatible Apps", @"PainTracker", @"No Compatible Apps");
        NSString *message = NSLocalizedStringFromTable(@"You do not have any apps on your device that have registered for opening this type of file.", @"PainTracker", @"You do not have any apps on your device that have registered for opening this type of file.");
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:title message:message];
        [alertView bk_setCancelButtonWithTitle:NSLocalizedStringFromTable(@"OK", @"PainTracker", @"OK") handler:nil];
        [alertView show];
    }
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar printButton:(UIButton *)button
{
    if ([UIPrintInteractionController isPrintingAvailable] == YES)
    {
        NSURL *fileURL = self.document.fileURL; // Document file URL
        
        if ([UIPrintInteractionController canPrintURL:fileURL] == YES)
        {
            self.printInteraction = [UIPrintInteractionController sharedPrintController];
            
            UIPrintInfo *printInfo = [UIPrintInfo printInfo];
            printInfo.duplex = UIPrintInfoDuplexLongEdge;
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.jobName = self.document.fileName;
            
            self.printInteraction.printInfo = printInfo;
            self.printInteraction.printingItem = fileURL;
            self.printInteraction.showsPageRange = YES;
            
            if (self.userInterfaceIdiom == UIUserInterfaceIdiomPad) // Large device printing
            {
                [self.printInteraction presentFromRect:button.bounds inView:button animated:YES completionHandler:
                 ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
                 {
#ifdef DEBUG
                     if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
#endif
                 }
                 ];
            }
            else // Handle printing on small device
            {
                [self.printInteraction presentAnimated:YES completionHandler:
                 ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
                 {
#ifdef DEBUG
                     if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
#endif
                 }
                 ];
            }
        }
    }
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar emailButton:(UIButton *)button
{
    if ([MFMailComposeViewController canSendMail] == NO) return;
    
    if (self.printInteraction != nil) [self.printInteraction dismissAnimated:YES];

    // App Version
    BOOL isLiteVersion = [[GlobalDefaults sharedGlobalDefaults] checkIfLiteVersion];
    NSString *appVersion = isLiteVersion ? @"LITE" : @"PRO";
    
    // Get the file size.
    double fileSize = [self.document.fileSize doubleValue];
    NSString *fileSizeDisplay = [NSString string];
    if ((fileSize / (double)1024) > 1) {
        fileSizeDisplay = [NSString stringWithFormat:@"%.1f MB", (fileSize / ((double)1024 * (double)1024))];
    }
    else {
        fileSizeDisplay = [NSString stringWithFormat:@"%.1f kb", (fileSize / (double)1024)];
    }
    
    // Filename
    NSString *reportFilename = [self.document fileName];
    
    // File type
    NSString *pathExtension = [reportFilename pathExtension];
    NSString *exportedFileTypeDisplay;
    if (nil == pathExtension || 0 == [pathExtension length]) {
        exportedFileTypeDisplay = @"";
    }
    else {
        exportedFileTypeDisplay = [NSString stringWithFormat:@" as a %@",[pathExtension uppercaseString]];
    }
    
    // Create subject line
    NSString *subject = [NSString stringWithFormat:@"CPT Report: %@",[reportFilename stringByDeletingPathExtension]];
    
    // Create message body
    NSString *messageBody = [NSString stringWithFormat:@"<body><p>Your data from Chronic Pain Tracker %@ has just been exported%@. It is now attached to this email.</p><p>File Info:<ul><li>File Name:  %@</li><li>File Size:  %@</li><li>File Type:  %@</li></ul></p></body>", appVersion, exportedFileTypeDisplay, reportFilename,fileSizeDisplay, [pathExtension uppercaseString]];
    
    // Create MailMeObject
    MailMeObject *newMailObject = [[MailMeObject alloc] initWithSubject:subject andMessageBody:messageBody usingHTML:YES inController:self];
    
    // Add the attachment
    [newMailObject addAttachmentAtURL:self.document.fileURL mimeType:@"application/pdf" filename:reportFilename];
    
    // Create the email
    [self createMailWithMailMeObject:newMailObject];
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar markButton:(UIButton *)button
{
#if (READER_BOOKMARKS == TRUE) // Option
    
    if (self.printInteraction != nil) [self.printInteraction dismissAnimated:YES];
    
    if ([self.document.bookmarks containsIndex:self.currentPage]) // Remove bookmark
    {
        [self.document.bookmarks removeIndex:self.currentPage];
        [self.mainToolbar setBookmarkState:NO];
    }
    else // Add the bookmarked page number to the bookmark index set
    {
        [self.document.bookmarks addIndex:self.currentPage];
        [self.mainToolbar setBookmarkState:YES];
    }
    
#endif // end of READER_BOOKMARKS Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar helpButton:(UIButton *)button;
{
#if (READER_ENABLE_HELP_BUTTON == TRUE) // Option
    // Display Help for view
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (nil == [defaults objectForKey:kHelpFirstViewKeyDisplayHelpOnShake]) {
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:kHelpFirstViewKeyDisplayHelpOnShake];
        [defaults synchronize];
    }
    BOOL showHelpOnShake = [[defaults objectForKey:kHelpFirstViewKeyDisplayHelpOnShake] boolValue];
    if (showHelpOnShake) {
        CGRect helpInitiationPoint = [(UIButton *)button convertRect:[button bounds] toView:self.view];
        HelpFirstView *helpFirstView = [HelpFirstView sharedHelpFirstView];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [helpFirstView displayHelpPopoverForViewKey:kHelpFirstViewKey forceDisplay:YES fromRect:helpInitiationPoint inView:self.view];
        } else {
            [helpFirstView displayHelpPopoverForViewKey:kHelpFirstViewKey forceDisplay:YES fromController:self];
        }
    }
#endif // end of READER_ENABLE_HELP_BUTTON Option
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#ifdef DEBUG
    if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIDocumentInteractionControllerDelegate methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}

- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller;
{
    
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    self.documentInteraction = nil;
}

#pragma mark - ThumbsViewControllerDelegate methods

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
#if (READER_ENABLE_THUMBS == TRUE) // Option
    
    [self showDocumentPage:page];
    
#endif // end of READER_ENABLE_THUMBS Option
}

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
#if (READER_ENABLE_THUMBS == TRUE) // Option
    
    [self dismissViewControllerAnimated:NO completion:NULL];
    
#endif // end of READER_ENABLE_THUMBS Option
}

#pragma mark - ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
    [self showDocumentPage:page];
}

#pragma mark - UIApplication notification methods

- (void)applicationWillResign:(NSNotification *)notification
{
    [self.document archiveDocumentProperties]; // Save any ReaderDocument changes
    
    if (self.userInterfaceIdiom == UIUserInterfaceIdiomPad) if (self.printInteraction != nil) [self.printInteraction dismissAnimated:NO];
}

#pragma mark - Motion Methods

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ([event subtype] == UIEventSubtypeMotionShake) {
        self.deviceShaking = YES;
        DDLogVerbose(@"Shaking has started. %@",[event description]);
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ([event subtype] == UIEventSubtypeMotionShake) {
        self.deviceShaking = NO;
        DDLogVerbose(@"Shaking has ended. %@",[event description]);
        
        // Display Help for view
        [self checkIfHelpFirstViewShouldDisplayForViewKey:kHelpFirstViewKey usingForce:YES];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ([event subtype] == UIEventSubtypeMotionShake) {
        self.deviceShaking = NO;
        DDLogVerbose(@"Shaking has cancelled. %@",[event description]);
        
    }
}

#pragma mark -
#pragma mark MailComposer Methods

-(void)createMailWithMailMeObject:(MailMeObject *)aMailMeObject {
    
    MailGeneratorViewController *newMailGenerator = [[MailGeneratorViewController alloc] initWithMailMeObject:aMailMeObject];
    [newMailGenerator setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:newMailGenerator animated:NO completion:^{
        
    }];
}

@end
