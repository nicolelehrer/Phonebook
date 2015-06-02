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
    
    /*
     //need to explicitly use index to avoid enumerating while mutable array is being mutated
     int i;
     for (i=0; i<[usableComponents count]; i++){
     NSLog(@"saved element %@", [usableComponents objectAtIndex:i]);
     }
     */
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
        
        for (NSString * key in [data allKeys]) {
            if ([key isEqualToString:personName] && [commandName isEqualToString:@"add"]) { //checks for intentional change
                NSLog(@"Person already exists - use change command to change phone number");
                return;
            }
            if ([key isEqualToString:personName] && [commandName isEqualToString:@"remove"]) {
                [data removeObjectForKey:personName];
                [data writeToFile:filePath atomically:YES];
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
        }
        else{
            [data setObject:phoneNumber forKey:personName];
        }
    }
    else {
        
        if (![commandName isEqualToString:@"create"]) {
            NSLog(@"You created a new PhoneBook called %@", fileName);
        }
        else{
            //don't want to lose data just added in previous case
            //in this case making a new phonebook using a create
            data = [[NSMutableDictionary alloc] init];
        }
    }
    [data writeToFile:filePath atomically:YES];
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
            NSLog(@"New phonebook named %@ created", fileName);
        }
        else{
            NSLog(@"Error: %@", numArgErrorMessage);
        }
        return;
    }
    
    //others require parse by quote
    int numSingleQuotesFound = (int)[[input componentsSeparatedByString:@"'"] count] - 1;
    NSArray * parsedByQuote = segmentUserInputByStringCharSet(input, @"'");
    
    if (([commandName isEqualToString:@"add"] ||
         [commandName isEqualToString:@"change"])) {
        
        if (numSingleQuotesFound == 4 && [parsedByQuote count] == 4) {
            personName = [parsedByQuote objectAtIndex:1];
            phoneNumber = [parsedByQuote objectAtIndex:2];
            updatePlistWithFileNamePersonNumber(fileName, personName, phoneNumber, commandName);
            NSLog(@"%@ : %@ in Phonebook called %@", personName, phoneNumber, fileName);
            return;
        }
        else if(numSingleQuotesFound != 4){
            NSLog(@"Error: %@", numSingQuoteErrorMessage);
        }
        else{
            NSLog(@"Error: %@", numArgErrorMessage);
        }
        return;
    }
    
    if (([commandName isEqualToString:@"remove"] || [commandName isEqualToString:@"lookup"] || [commandName isEqualToString:@"reverse-lookup"])) {
        if (numSingleQuotesFound == 2 && [parsedByQuote count] == 3) {
            phoneNumber = [parsedByQuote objectAtIndex:1];
            updatePlistWithFileNamePersonNumber(fileName, nil, nil, commandName);
        }
        else if(numSingleQuotesFound != 2){
            NSLog(@"Error: %@", numSingQuoteErrorMessage);
        }
        else{
            NSLog(@"Error: %@", numArgErrorMessage);
        }
        return;
    }
    
    NSLog(@"Error: Command not found");
    
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
    
        while (true) {
            
            NSLog(@"Enter some data: ");
            
            char str[100] = {0}; // static allocation of string
            fgets (str, sizeof(str), stdin); //input buffer, bufferlength, stin

            NSString * userInput = [NSString stringWithFormat:@"%s", str]; //convert c string to NSString
            handleInput(userInput);
        }
    }
    return 0;
}


