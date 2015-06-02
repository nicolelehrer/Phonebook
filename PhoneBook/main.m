//
//  main.m
//  PhoneBook
//
//  Created by Nicole Lehrer on 5/28/15.
//  Copyright (c) 2015 Nicole Lehrer. All rights reserved.
//


#import <Foundation/Foundation.h>


NSString * returnDirectory(){
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //directory, domain (user, public, network), doExpandTilde
    NSString * documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}

NSArray * segmentUserInputByStringCharSet(NSString * userInput, NSString * separator){
    
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:separator];
    NSArray * subStrings = [userInput componentsSeparatedByCharactersInSet:set];
    NSMutableArray * usableStrings = [[NSMutableArray alloc] init];
    
    for (NSString * aString in subStrings){
        if ([aString stringByReplacingOccurrencesOfString:@" " withString:@""].length != 0){  //make sure substring is not only spaces
            NSString *trim = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            // NSLog(@"trimmed %@.txt", trim);
            [usableStrings addObject:trim];
        }
    }
    
    
     //need to explicitly use index to avoid enumerating while mutable array is being mutated
//     int i;
//     for (i=0; i<[usableStrings count]; i++){
//     NSLog(@"saved element %@", [usableStrings objectAtIndex:i]);
//     }
//    NSLog(@"useablestrings count is %lu", [usableStrings count]);
    return usableStrings;
}


void updatePlistWithFileNamePersonNumber(NSString * fileName, NSString * personName, NSString * phoneNumber, NSString * commandName){

    NSString * fileNameWithExt = [NSString stringWithFormat:@"%@.plist", fileName];
    NSString * filePath = [returnDirectory() stringByAppendingPathComponent:fileNameWithExt];
    NSFileManager * fileManager = [NSFileManager defaultManager];

    NSMutableDictionary * data;
    
    if ([fileManager fileExistsAtPath: filePath]) {
        if ([commandName isEqualToString:@"create"]) { //first check for 'create'
            NSLog(@"Phonebook named %@ already exists", fileName);
            return;
        }
        
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: filePath];
        NSMutableArray * matches = [[NSMutableArray alloc] init];
        
        //cases in which an existing key in dictionary is important
        //add:error, change:execute, remove:execute, ^lookup:execute, ^reverse-lookup:execute
        for (NSString * key in [data allKeys]) {
            if ([key isEqualToString:personName] && [commandName isEqualToString:@"add"]) {
                NSLog(@"Person already exists - use change command to change phone number");
                return;
            }
            if ([key isEqualToString:personName] && [commandName isEqualToString:@"change"]) {
                [data setObject:phoneNumber forKey:personName];
                [data writeToFile:filePath atomically:YES];
                NSLog(@"%@ : %@ in Phonebook called %@", personName, phoneNumber, fileName);
                return;
            }
            
            if ([key isEqualToString:personName] && [commandName isEqualToString:@"remove"]) {
                [data removeObjectForKey:personName];
                [data writeToFile:filePath atomically:YES];
                NSLog(@"Removed %@ : %@ in Phonebook called %@", personName, phoneNumber, fileName);
                return;
            }
            
            NSArray * splitNames = segmentUserInputByStringCharSet(key, @" ");
            if ([splitNames containsObject:personName] && [commandName isEqualToString:@"lookup"]) {
                [matches addObject:key];
            }
            if ([commandName isEqualToString:@"reverse-lookup"]) {
                if ([[data objectForKey:key] isEqualToString:phoneNumber]) {
                    [matches addObject:key];
                }
            }

        }
        
        if ([commandName isEqualToString:@"lookup"] || [commandName isEqualToString:@"reverse-lookup"]) {
            if ([matches count]>0) {
                for (NSString * match in matches){
                    NSLog(@"%@ : %@", match, [data objectForKey:match]);
                }
            }
            else{
                NSLog(@"No person found");
            }
            return;
        }
        
        //cases in which key is new
        //add:execute, change:execute, remove:error, ^lookup:execute, ^reverse-lookup:execute
        if (![commandName isEqualToString:@"remove"]) {
            [data setObject:phoneNumber forKey:personName];
            [data writeToFile:filePath atomically:YES];
            NSLog(@"%@ : %@ in Phonebook called %@", personName, phoneNumber, fileName);
        }
        else{
            NSLog(@"No person found to remove");
        }
    }
    else {
        
        if (![commandName isEqualToString:@"create"]) {
            NSLog(@"Phonebook named %@ not found. You need to first create it", fileName);
        }
        else{
            data = [[NSMutableDictionary alloc] init];
            NSLog(@"New phonebook named %@ created", fileName);
            [data writeToFile:filePath atomically:YES];
        }
    }
}

NSString * returnInputWithLastCharRemoved(NSString * input){
    if ([input length] > 0) {
        input = [input substringToIndex:[input length] - 1];
        return input;
    }
    return nil;
}


void handleInput(NSString * input){
    
    NSArray * parsedBySpace = segmentUserInputByStringCharSet(input, @" ");
    NSString * commandName = [parsedBySpace objectAtIndex:0];
    NSString * fileName = [parsedBySpace lastObject];
    NSString * personName = nil;
    NSString * phoneNumber = nil;
    NSString * numArgErrorMessage = @"wrong number of arguments";
    NSString * numSingQuoteErrorMessage = @"please put single quotes around name and phone number - e.g. 'John Smith', '123 456 789'";

    
    //create is special case can parse by space only
    if ([commandName isEqualToString:@"create"]) { //check for args count
        if ([parsedBySpace count] == 2) {
            updatePlistWithFileNamePersonNumber(fileName, nil, nil, commandName);
        }
        else{
            NSLog(@"Error: %@", numArgErrorMessage);
        }
        return;
    }
    
    //others require parse by quote
    int numSingleQuotesFound = (int)[[input componentsSeparatedByString:@"'"] count] - 1;
    NSArray * parsedByQuote = segmentUserInputByStringCharSet(input, @"'");
    int numArgs = (int)[parsedByQuote count];
    NSLog(@"number of args is %i", numArgs);
    
    if (([commandName isEqualToString:@"add"] ||
         [commandName isEqualToString:@"change"])) {
        
        if (numSingleQuotesFound == 4 && numArgs == 4) {
            personName = [parsedByQuote objectAtIndex:1];
            phoneNumber = [parsedByQuote objectAtIndex:2];
            updatePlistWithFileNamePersonNumber(fileName, personName, phoneNumber, commandName);
            return;
        }
        else if(numArgs != 4){
            NSLog(@"Error: %@", numArgErrorMessage);
        }
        else{
            NSLog(@"Error: %@", numSingQuoteErrorMessage);
        }
        return;
    }
    
    if ([commandName isEqualToString:@"remove"] || [commandName isEqualToString:@"lookup"]) {
        if (numSingleQuotesFound == 2 && numArgs == 3) {
            personName = [parsedByQuote objectAtIndex:1];
            updatePlistWithFileNamePersonNumber(fileName, personName, phoneNumber, commandName);
            return;
        }
        else if(numArgs != 3){
            NSLog(@"Error: %@", numArgErrorMessage);
        }
        else{
            NSLog(@"Error: %@", numSingQuoteErrorMessage);
        }
        return;
    }
    
    if ([commandName isEqualToString:@"reverse-lookup"]) {
        if (numSingleQuotesFound == 2 && numArgs == 3) {
            phoneNumber = [parsedByQuote objectAtIndex:1];
            updatePlistWithFileNamePersonNumber(fileName, nil, phoneNumber, commandName);
        }
        else if(numArgs != 3){
            NSLog(@"Error: %@", numArgErrorMessage);
        }
        else{
            NSLog(@"Error: %@", numSingQuoteErrorMessage);
        }
        return;
    }
    
    NSLog(@"Error: Command not found");
    
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
//below is if you are taking user input from xCode command line
//        NSLog(@"Enter some data: ");
//        char str[100] = {0}; // static allocation of string
//        fgets (str, sizeof(str), stdin); //input buffer, bufferlength, stin
//        NSString * userInput = [NSString stringWithFormat:@"%s", str]; //convert c string to NSString
        
        NSString * arg1 = [NSString stringWithFormat:@"%s", argv[1]]; //command
        NSString * arg2 = [NSString stringWithFormat:@"%s", argv[2]];
        NSString * arg3 = [NSString stringWithFormat:@"%s", argv[3]];
        NSString * arg4 = [NSString stringWithFormat:@"%s", argv[4]];

        NSString * userInput;
        if ([arg1 isEqualToString:@"create"]) {
            userInput = [NSString stringWithFormat:@"%@ %@", arg1, arg2];
        }
        else if ([arg1 isEqualToString:@"add"] || [arg1 isEqualToString:@"change"]) {
            userInput = [NSString stringWithFormat:@"%@ %@ %@ %@", arg1, arg2, arg3, arg4];
        }
        else {
            userInput = [NSString stringWithFormat:@"%@ %@ %@", arg1, arg2, arg3];
        }

        handleInput(userInput);

    }
    return 0;
}


