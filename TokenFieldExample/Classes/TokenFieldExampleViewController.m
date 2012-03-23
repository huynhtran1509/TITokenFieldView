//
//  TokenFieldExampleViewController.m
//  TokenFieldExample
//
//  Created by Tom Irving on 29/01/2011.
//  Copyright 2011 Tom Irving. All rights reserved.
//

#import "TokenFieldExampleViewController.h"
#import "Names.h"

@interface TokenFieldExampleViewController (Private)
- (void)resizeViews;
@end

@implementation TokenFieldExampleViewController

- (void)viewDidLoad {
	
	[self.view setBackgroundColor:[UIColor whiteColor]];
	[self.navigationItem setTitle:@"TITokenFieldView"];
	
	tokenFieldView = [[TITokenFieldView alloc] initWithFrame:self.view.bounds];
	[tokenFieldView setDelegate:self];
	[tokenFieldView setSourceArray:[Names listOfNames]];
	[tokenFieldView.tokenField setAddButtonAction:@selector(showContactsPicker) target:self];
	
	messageView = [[UITextView alloc] initWithFrame:tokenFieldView.contentView.bounds];
	[messageView setScrollEnabled:NO];
	[messageView setAutoresizingMask:UIViewAutoresizingNone];
	[messageView setDelegate:self];
	[messageView setFont:[UIFont systemFontOfSize:15]];
	[messageView setText:@"Some message. The whole view resizes as you type, not just the text view."];
	[tokenFieldView.contentView addSubview:messageView];
	[messageView release];
	
	[self.view addSubview:tokenFieldView];
	[tokenFieldView release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	// You can call this on either the view on the field.
	// They both do the same thing.
	[tokenFieldView becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration animations:^{[self resizeViews];}]; // Make it pretty.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self resizeViews];
}

- (void)showContactsPicker {
	
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
  picker.peoplePickerDelegate = self;
	// Display only a person's phone, email, and birthdate
	NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], 
                             [NSNumber numberWithInt:kABPersonEmailProperty],
                             nil];
	
	
	picker.displayedProperties = displayedItems;
	// Show the picker 
	[self presentModalViewController:picker animated:YES];
  
}

- (void)keyboardWillShow:(NSNotification *)notification {
	
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	// Wouldn't it be fantastic if, when in landscape mode, width was actually width and not height?
	keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
	
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	keyboardHeight = 0;
	[self resizeViews];
}

- (void)resizeViews {
	
	CGRect newFrame = tokenFieldView.frame;
	newFrame.size.width = self.view.bounds.size.width;
	newFrame.size.height = self.view.bounds.size.height - keyboardHeight;
	[tokenFieldView setFrame:newFrame];
	[messageView setFrame:tokenFieldView.contentView.bounds];
}

- (void)tokenField:(TITokenField *)tokenField didChangeToFrame:(CGRect)frame {
	[self textViewDidChange:messageView];
}

- (void)textViewDidChange:(UITextView *)textView {
	
	CGFloat fontHeight = (textView.font.ascender - textView.font.descender) + 1;
	CGFloat originHeight = tokenFieldView.frame.size.height - tokenFieldView.tokenField.frame.size.height;
	CGFloat newHeight = textView.contentSize.height + fontHeight;
	
	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
	
	CGRect newFrame = tokenFieldView.contentView.frame;
	newFrame.size.height = newHeight;
	
	if (newHeight < originHeight){
		newTextFrame.size.height = originHeight;
		newFrame.size.height = originHeight;
	}
		
	[tokenFieldView.contentView setFrame:newFrame];
	[textView setFrame:newTextFrame];
	[tokenFieldView updateContentSize];
}


#pragma mark - Token
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
                    property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	return YES;
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicke {
  [self dismissModalViewControllerAnimated:YES];
}

// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
                                property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
  ABMultiValueRef emails = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonEmailProperty);
  NSString *emailID;
  
  if(ABMultiValueGetCount(emails)>0)
  {
    CFTypeRef prop = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(prop,  identifier);
    emailID = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, index);
    
    for (NSString* email in tokenFieldView.tokenTitles) {
      [tokenFieldView.tokenField addToken:email];
    }
    
    [tokenFieldView.tokenField addToken:emailID];
    CFRelease(prop);
    [self dismissModalViewControllerAnimated:YES];
    
  }
  else
  {
    CFRelease(emails);
    //Contact don't have email
  }
	return NO;
}

@end
