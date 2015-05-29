//
//  main.m
//  PhoneBook
//
//  Created by Nicole Lehrer on 5/28/15.
//  Copyright (c) 2015 Nicole Lehrer. All rights reserved.
//

/*
 
 $ python phonebook.py create ex_phonebook
 Created phonebook 'ex_phonebook.pb' in the current directory.
 
 $ python phonebook.py add 'Jane Doe' '432 123 4321' ex_phonebook
 Added an entry to ex_phonebook.pb:
 Jane Doe    432 123 4321
 $ python phonebook.py add 'Jane Lin' '509 123 4567' ex_phonebook
 Added an entry to ex_phonebook.pb:
 Jane Lin    509 123 4567
 $ python phonebook.py add 'Jane Lin' '643 357 9876' ex_phonebook
 Error: Jane Lin already exists in ex_phonebook. Use the 'update' command to change this entry.
 
 $ python phonebook.py update 'Jane Lin' '643 357 9876' ex_phonebook
 Updated an entry in ex_phonebook.pb.
 Previous entry:
 Jane Lin    509 123 4567
 New entry:
 Jane Lin    643 357 9876
 
 $ python phonebook.py lookup 'Jane' ex_phonebook
 Jane Doe    432 123 4321
 Jane Lin    643 357 9876
 
 $ python phonebook.py reverse-lookup '643 357 9876' ex_phonebook
 Jane Lin    643 357 9876
 
 $ python phonebook.py remove 'Jane Doe' ex_phonebook
 Removed an entry from ex_phonebook.pb:
 Jane Doe    432 123 4321
 $ python phonebook.py remove 'John Doe' ex_phonebook
 Error: 'John Doe' does not exist in ex_phonebook.pb
 
*/


//create takes one input
//add/update takes 'name' 'number' file
//lookup/reverselook 'name' file
//remove 'name' file



#import <Foundation/Foundation.h>

NSString * returnFilePathWithName(NSString * fileName){
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //directory, domain (user, public, network), doExpandTilde
    NSString * documentDirectory = [paths objectAtIndex:0];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@.txt", documentDirectory, fileName];
    return filePath;
}

void createPhonebookWithName(NSString * name){
    
    NSString * filePath = returnFilePathWithName(name);
    NSString * fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    if((unsigned long)fileContents.length > 0){
        NSLog(@"this file exists");
    }
    else{
        fileContents = @"Name    Number";
        [fileContents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

void updatePhonebookWithEntry(NSString * entry, NSString * phoneBookName){
    
    NSString * filePath = returnFilePathWithName(phoneBookName);
    NSString * fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [[fileContents stringByAppendingString:[@"\n" stringByAppendingString:entry]]
                               writeToFile:filePath
                                atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

NSString * parseAndReturnInputForEntryAndCommand(NSString * entry, NSString * commandString){
    
//    create ex_phonebook - takes one input
//    add 'Jane Doe' '432 123 4321' ex_phonebook - takes 3 inputs
//    update 'Jane Lin' '643 357 9876' ex_phonebook
    
    if ([entry rangeOfString:commandString].location != NSNotFound){  //learn regular expressions
        
        NSString * sub1 = commandString;
        
        int sub1Start = (int)[entry rangeOfString:sub1].location;
        int sub2Start = sub1Start + (int)sub1.length;
        
        NSRange sub2Range = NSMakeRange(sub2Start+1, entry.length-(sub2Start+1)-1); //+1 assumes preceded by space, could do check here
                                                                                    //-1 assumes carriage return
        return[entry substringWithRange:sub2Range];
    }
    else{
        return nil;
    }
}

void scanEntry(NSString * input){                       //
    
//    NSString *str = input;
    
//    split function for nstring
//    nsprocess info
    
    NSMutableArray * results = [NSMutableArray array];
    NSScanner * scanner = [NSScanner scannerWithString:input];
    NSString * tmp;
    
    while ([scanner isAtEnd]==NO)
    {
        [scanner scanUpToString:@"'" intoString:NULL]; //move the scanner up to the point you want
        [scanner scanString:@"'" intoString:NULL];     //scan the the '
        
        [scanner scanUpToString:@"'" intoString:&tmp];
        
        if ([scanner isAtEnd] == NO)
            [results addObject:tmp];
        [scanner scanString:@"'" intoString:NULL];
    }
    
    for (NSString *item in results)
    {
        NSLog(@"%@", item);
    }
}


void segmentStringBy(NSString * input, NSString * separator){
    
    NSArray * subStrings = [input componentsSeparatedByString:separator];
    for (NSString * aString in subStrings){
        //checks if a subString is only made up of space
        if ([aString stringByReplacingOccurrencesOfString:@" " withString:@""].length != 0){
            NSLog(@"%@", aString);
        }
    }
}



int main(int argc, const char * argv[]) {
    @autoreleasepool {
    
        while (true) {
            
            NSLog(@"Enter some data: ");
            char str[50] = {0};

            fgets (str, 256, stdin);
            
            NSString * entry = [NSString stringWithFormat:@"%s", str];
            
            NSString * parsedInput = parseAndReturnInputForEntryAndCommand(entry, @"create");
            if (parsedInput){
                createPhonebookWithName(parsedInput);
            }
            
           parsedInput = parseAndReturnInputForEntryAndCommand(entry, @"update");
            if (parsedInput){
                segmentStringBy(parsedInput, @"'");
            }
            
            
           

        }
    }
    return 0;
}


