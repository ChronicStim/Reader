//
//	ReaderConstants.h
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

#if !__has_feature(objc_arc)
	#error ARC (-fobjc-arc) is required to build this code.
#endif

#import <Foundation/Foundation.h>

#define READER_FLAT_UI TRUE
#define READER_SHOW_SHADOWS TRUE
#define READER_ENABLE_THUMBS TRUE
#define READER_DISABLE_RETINA FALSE
#define READER_ENABLE_PREVIEW TRUE
#define READER_DISABLE_IDLE FALSE
#define READER_STANDALONE FALSE
#define READER_BOOKMARKS FALSE
#define READER_ENABLE_HELP_BUTTON TRUE

#define READER_TOOLBAR_PRIMARY_TINT [UIColor cptToolbarTintColor]
#define READER_TOOLBAR_SECONDARY_TINT [UIColor cptPrimaryColorLightTint]

#define READER_TOOLBAR_BUTTON_X 4.0f
#define READER_TOOLBAR_BUTTON_Y 4.0f
#define READER_TOOLBAR_BUTTON_SPACE 5.0f
#define READER_TOOLBAR_BUTTON_HEIGHT 38.0f
#define READER_TOOLBAR_BUTTON_FONT_SIZE 14.0f
#define READER_TOOLBAR_TEXT_BUTTON_PADDING 20.0f
#define READER_TOOLBAR_ICON_BUTTON_WIDTH 40.0f
#define READER_TOOLBAR_TITLE_FONT_SIZE 19.0f
#define READER_TOOLBAR_TITLE_HEIGHT 28.0f

