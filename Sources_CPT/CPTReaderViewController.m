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

@interface CPTReaderViewController ()
< ReaderMainToolbarDelegate, ReaderMainPagebarDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, ThumbsViewControllerDelegate >

@property (nonatomic, readwrite, strong) UIPrintInteractionController *printInteraction;
@property (nonatomic, readwrite, strong) UIDocumentInteractionController *documentInteraction;
@property (nonatomic, readwrite, strong) ReaderDocument *document;
@property (nonatomic, readwrite, assign) UIUserInterfaceIdiom userInterfaceIdiom;
@property (nonatomic, readwrite, strong) ReaderMainToolbar *mainToolbar;
@property (nonatomic, readwrite, strong) ReaderMainPagebar *mainPagebar;
@property (nonatomic, readwrite, assign) NSInteger currentPage;
@property (nonatomic, readwrite, assign) NSInteger minimumPage;
@property (nonatomic, readwrite, assign) NSInteger maximumPage;

@end

@implementation CPTReaderViewController

- (BOOL)prefersStatusBarHidden
{
    return NO;
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

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar exportButton:(UIButton *)button
{
    if (self.printInteraction != nil) [self.printInteraction dismissAnimated:YES];
    
    NSURL *fileURL = self.document.fileURL; // Document file URL
    
    self.documentInteraction = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    
    self.documentInteraction.delegate = self; // UIDocumentInteractionControllerDelegate
    
    [self.documentInteraction presentOpenInMenuFromRect:button.bounds inView:button animated:YES];
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
    
    unsigned long long fileSize = [self.document.fileSize unsignedLongLongValue];
    
    if (fileSize < 15728640ull) // Check attachment size limit (15MB)
    {
        NSURL *fileURL = self.document.fileURL; NSString *fileName = self.document.fileName;
        
        NSData *attachment = [NSData dataWithContentsOfURL:fileURL options:(NSDataReadingMapped|NSDataReadingUncached) error:nil];
        
        if (attachment != nil) // Ensure that we have valid document file attachment data available
        {
            MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];
            
            [mailComposer addAttachmentData:attachment mimeType:@"application/pdf" fileName:fileName];
            
            [mailComposer setSubject:fileName]; // Use the document file name for the subject
            
            mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
            
            mailComposer.mailComposeDelegate = self; // MFMailComposeViewControllerDelegate
            
            [self presentViewController:mailComposer animated:YES completion:NULL];
        }
    }
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

@end
