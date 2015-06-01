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


NSString * returnDirectory(){
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //directory, domain (user, public, network), doExpandTilde
    NSString * documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}

//NSString * returnPlistPathWithName(NSString * fileName){
//    
//    NSString * fileNameWithExt = [NSString stringWithFormat:@"%@.plist", fileName];
//    NSString * filePath = [returnDirectory() stringByAppendingPathComponent:fileNameWithExt];
//
//    NSFileManager * fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:filePath]){
////            NSLog(@"file exists");
//        return filePath;
//    }
//    return nil;
//}

void updatePlistWithFileNamePersonNumber(NSString * fileName, NSString * personName, NSString * phoneNumber, NSString * commandName){

    NSString * fileNameWithExt = [NSString stringWithFormat:@"%@.plist", fileName];
    NSString * filePath = [returnDirectory() stringByAppendingPathComponent:fileNameWithExt];
    NSFileManager * fileManager = [NSFileManager defaultManager];

    NSMutableDictionary * data;
    
    if ([fileManager fileExistsAtPath: filePath]) {
        
        if ([commandName isEqualToString:@"create"]) { //first check for 'create'
            NSLog(@"file already exists");
            return;
        }
        
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: filePath];
        
        for (NSString * key in [data allKeys]) {
            if ([key isEqualToString:personName] && [commandName isEqualToString:@"add"]) { //checks for intentional change
                NSLog(@"Person already exists - use change command to change phone number");
                return;
            }
            if ([key isEqualToString:personName] && [commandName isEqualToString:@"remove"]) { //checks for intentional change
                [data removeObjectForKey:personName];
                [data writeToFile:filePath atomically:YES];
                return;
            }
        }
        [data setObject:phoneNumber forKey:personName];
    }
    else {
        data = [[NSMutableDictionary alloc] init];
    }
    [data writeToFile:filePath atomically:YES];
}

NSString * parseAndReturnInputForEntryAndCommand(NSString * entry, NSString * commandString){
    
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



NSString * returnInputWithLastCharRemoved(NSString * input){
    if ([input length] > 0) {
        input = [input substringToIndex:[input length] - 1];
        return input;
    }
    return nil;
}

NSArray * segmentEntryByStringCharSet(NSString * userInput, NSString * separator){  //method currently can take character set

    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:separator];
    NSArray * subStrings = [userInput componentsSeparatedByCharactersInSet:set];
    NSMutableArray * usableComponents = [[NSMutableArray alloc] init];

    for (NSString * aString in subStrings){
        if ([aString stringByReplacingOccurrencesOfString:@" " withString:@""].length != 0){  //make sure substring is not only spaces
            NSString *trim = [aString stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//             NSLog(@"trimmed %@.txt", trim);
            [usableComponents addObject:trim];
        }
    }
    
    /*
    int i;
    for (i=0; i<[usableComponents count]; i++){  //need to explicitly use index to avoid enumerating while mutable array is being mutated
        NSLog(@"saved element %@", [usableComponents objectAtIndex:i]);
    }
     */
    
    
    
    
    return usableComponents;
}


void handleInput(NSString * input){
    
    NSArray * parsedBySpace = segmentEntryByStringCharSet(input, @" ");//right now segmenting for create
    NSString * commandName = [parsedBySpace objectAtIndex:0];
    NSString * fileName = [parsedBySpace lastObject];
    NSString * personName = nil;
    NSString * phoneNumber = nil;
    
    if ([commandName isEqualToString:@"create"] && [parsedBySpace count] == 2) { //check for args count
        updatePlistWithFileNamePersonNumber(fileName, nil, nil, commandName);
        return;
    }
    
    NSArray * parsedByQuote = segmentEntryByStringCharSet(input, @"'");
    
    if (([commandName isEqualToString:@"add"] ||
         [commandName isEqualToString:@"change"]) && [parsedByQuote count] == 4) {
        
        personName = [parsedByQuote objectAtIndex:1];
        phoneNumber = [parsedByQuote objectAtIndex:2];
    }
    
    if ([commandName isEqualToString:@"remove"] && [parsedByQuote count] == 3) {
        
        personName = [parsedByQuote objectAtIndex:1];
    }
    
    updatePlistWithFileNamePersonNumber(fileName, personName, phoneNumber, commandName);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
    
        while (true) {
            
            NSLog(@"Enter some data: ");
            
            char str[100] = {0}; // static allocation of string
            fgets (str, sizeof(str), stdin); //input buffer, bufferlength, stin

            NSString * entry = [NSString stringWithFormat:@"%s", str]; //convert c string to NSString
            handleInput(entry);

        }
    }
    return 0;
}


