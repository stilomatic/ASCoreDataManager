//
//  TGPersistentManager.m
//  Theoriegenie
//
//  Created by iOS on 18.06.14.
//  Copyright (c) 2014 prisma-edv. All rights reserved.
//

#import "ASCoreDataManager.h"
#import <PromiseKit.h>

#define DATABASE_NAME @"db.sqlite"

@interface ASCoreDataManager ()

@property (nonatomic,readonly,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,readonly,strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic,strong) dispatch_queue_t dbQueue;

- (Profile *)defaultProfile;

- (NSArray*)fetchAllEntities:(NSString*)entityName withPredicate:(NSPredicate*)predicate;
- (BOOL)saveAll;

@end

@implementation ASCoreDataManager
@synthesize managedObjectContext,persistentStoreCoordinator,dbQueue;

#pragma mark Public Methods

-(void)saveProfileMail:(NSString*)email andPassword:(NSString*)password
{
    dispatch_promise_on(dbQueue, ^{
        
        NSArray *list = [self fetchAllEntities:@"Profile" withPredicate:nil];
        if (list.count == 1) {
            [self.managedObjectContext deleteObject:[list objectAtIndex:0]];
        }
        Profile *profile = [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
        profile.userMail = email;
        profile.userPassword = password;
        [self saveAll];
        
    });
}

-(void)retriveProfile:(retriveObject_t)retrive
{
    dispatch_promise_on(dbQueue, ^{
        
        NSArray *list = [self fetchAllEntities:@"Profile" withPredicate:nil];
        if (!list || list.count == 0) {
            Profile *profile = [self defaultProfile];
            [self saveAll];
            return profile;
        }
        NSLog(@"Profile %@",[list objectAtIndex:0]);
        return (Profile*)[list objectAtIndex:0];
    
    }).then(^(NSObject *obj){
        retrive(obj);
    });

}

#pragma mark Private Methods

- (Profile *)defaultProfile
{
    Profile *dummyProfile = [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
    dummyProfile.userMail = @"";
    dummyProfile.userName = @"";
    dummyProfile.userToken = @"";
    dummyProfile.userPassword = @"";
    
    return dummyProfile;
}


- (NSArray*)fetchAllEntities:(NSString*)entityName withPredicate:(NSPredicate*)predicate
{
        NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        if (predicate) [fetchRequest setPredicate:predicate];
        NSError* error = nil;
        NSArray* result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!result) {
            NSLog(@"PersistenceManager.fetchAllEntities: %@", [error localizedDescription]);
        }
        
        return [result copy];
}

- (BOOL)saveAll {
    NSError* error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"PersistenceManager.saveAll: %@",[error localizedDescription]);
        return NO;
    }
    
    return YES;
}

#pragma mark Singleton Methods

+ (id)sharedManager {
    static ASCoreDataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [self new];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
        dbQueue = dispatch_queue_create("de.prisma-edv.db", NULL);
        
        dispatch_promise_on(dbQueue, ^{
            NSString* dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            
            NSURL* url = [NSURL fileURLWithPath:[dir stringByAppendingPathComponent:DATABASE_NAME]];
            NSError* error = nil;
            persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
            if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
                NSLog(@"PersistenceManager.init: persistent store error: %@", error);
                persistentStoreCoordinator = nil;
            }
            else {
                managedObjectContext = [NSManagedObjectContext new];
                self.managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
                NSUndoManager* undoManager = [NSUndoManager  new];
                self.managedObjectContext.undoManager = undoManager;
            }
        });
    }
    return self;
}

- (void)dealloc
{
    
}

@end
