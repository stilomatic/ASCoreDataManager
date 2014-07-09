//
//  Profile.h
//  Theoriegenie
//
//  Created by iOS on 18.06.14.
//  Copyright (c) 2014 prisma-edv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Profile : NSManagedObject

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userMail;
@property (nonatomic, retain) NSString * userPassword;
@property (nonatomic, retain) NSString * userToken;

@end
