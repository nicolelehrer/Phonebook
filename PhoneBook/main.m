//
//  main.m
//  PhoneBook
//
//  Created by Nicole Lehrer on 5/28/15.
//  Copyright (c) 2015 Nicole Lehrer. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * returnFilePath(){
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //directory, domain (user, public, network), doExpandTilde
    NSString * documentDirectory = [paths objectAtIndex:0];
    NSString * filePath = [NSString stringWithFormat:@"%@/phonebook.txt", documentDirectory];
    return filePath;
}

void updatePhonebook(NSString * entry){
   
    NSString * fileContents = [NSString stringWithContentsOfFile:returnFilePath() encoding:NSUTF8StringEncoding error:nil];
    if (fileContents){
        fileContents = [fileContents stringByAppendingString:[@"\n" stringByAppendingString:entry]];
    }
    [fileContents writeToFile:returnFilePath() atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
    
        while (true) {
            
            NSLog(@"Enter some data: ");
            char str[50] = {0};

            fgets (str, 256, stdin);
            
    // removes carriage return
    //        if ((strlen(name)>0) && (name[strlen (name) - 1] == '\n'))
    //            name[strlen (name) - 1] = '\0';
            
            NSString * entry = [NSString stringWithFormat:@"%s", str];
            
            updatePhonebook(entry);
        }
    }
    return 0;
}


