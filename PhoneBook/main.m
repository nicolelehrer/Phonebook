//
//  main.m
//  PhoneBook
//
//  Created by Nicole Lehrer on 5/28/15.
//  Copyright (c) 2015 Nicole Lehrer. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * returnFilePathWithName(NSString * fileName){
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //directory, domain (user, public, network), doExpandTilde
    NSString * documentDirectory = [paths objectAtIndex:0];
    NSString * filePath = [NSString stringWithFormat:@"%@/phonebook.txt", documentDirectory];
    return filePath;
}

void updatePhonebook(NSString * entry){
   
//    NSString * fileContents = [NSString stringWithContentsOfFile:returnFilePath() encoding:NSUTF8StringEncoding error:nil];
//    if (fileContents){
//        fileContents = [fileContents stringByAppendingString:[@"\n" stringByAppendingString:entry]];
//    }
//    [fileContents writeToFile:returnFilePath() atomically:YES encoding:NSUTF8StringEncoding error:nil];
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
            
//            learn how to do regular expressions
            
            NSString * commandString = @"create";
            
            if ([entry rangeOfString:commandString].location != NSNotFound){
                
                NSString * sub1 = commandString;
                
                int sub1Start = (int)[entry rangeOfString:sub1].location;
                int sub2Start = sub1Start + (int)sub1.length;
              
                NSRange sub2Range = NSMakeRange(sub2Start+1, entry.length-(sub2Start+1)); //+1 assumes user enter's a space, could do check here
                
                NSString * newFileName = [entry substringWithRange:sub2Range];
                
//                returnFilePathWithName(newFileName);
                
            }
            
            updatePhonebook(entry);
        }
    }
    return 0;
}


