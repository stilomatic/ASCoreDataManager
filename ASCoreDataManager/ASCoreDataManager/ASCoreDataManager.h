//
//  TGPersistentManager.h
//  Theoriegenie
//
//  Created by iOS on 18.06.14.
//  Copyright (c) 2014 prisma-edv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Profile.h"

typedef void (^retriveObject_t)(NSObject *obj);
typedef void (^retriveCollection_t)(NSArray *list);

@interface ASCoreDataManager : NSObject


+(id)sharedManager;

-(void)saveProfileMail:(NSString*)email andPassword:(NSString*)password;
-(void)retriveProfile:(retriveObject_t)retrive;


@end
