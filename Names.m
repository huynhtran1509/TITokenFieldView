//
//  Names.m
//  TokenFieldExample
//
//  Created by Tom on 06/03/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "Names.h"
#import <AddressBook/AddressBook.h>

@implementation Names

+(NSString*)CFStringToString:(CFStringRef)ref
{
  return (NSString*) ABAddressBookCopyLocalizedLabel(ref);
}
+ (NSArray *)listOfNames {
	
    NSMutableArray *contact=[[NSMutableArray alloc]init];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    NSLog(@"start loop");
    for( CFIndex i = 0 ; i < nPeople ; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i );
        ABMultiValueRef email =ABRecordCopyValue(ref, kABPersonEmailProperty);
        CFStringRef firstname = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        CFStringRef middlename = ABRecordCopyValue(ref, kABPersonMiddleNameProperty);
        CFStringRef lastname = ABRecordCopyValue(ref, kABPersonLastNameProperty);
     
      
      if(email) {
        
        NSString *emailID = nil;
        NSString *fullname = @"";
        
        NSMutableArray *arr=[[NSMutableArray alloc]init];
        for(CFIndex i=0;i<ABMultiValueGetCount(email);i++)
        {
          
          
          if (email)
          {
            CFStringRef emailRef = ABMultiValueCopyValueAtIndex(email, i);
            
            if(firstname)
            {
              fullname = [self CFStringToString:firstname];
            }
            if(middlename)
            {
              fullname = [NSString stringWithFormat:@"%@ %@",fullname,[self CFStringToString:middlename]];
            }
            if(lastname)
            {
              fullname = [NSString stringWithFormat:@"%@ %@",fullname,[self CFStringToString:lastname]];
            }
            
            emailID = (NSString*) ABAddressBookCopyLocalizedLabel(emailRef);
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:fullname,@"name",emailID,@"email",nil];
            
            [arr addObject:dict];
            
            [emailID release];
              CFRelease(emailRef);
              
          }

        }
        
        [contact addObjectsFromArray:arr];
        CFRelease(email);
        [arr release];
      }
      


    }
	
  CFRelease(allPeople);
  CFRelease(addressBook);

  
    return [contact autorelease];
	
}

@end
