//
//  OCHTTPRequestOperationManager.h
//
//  Created by Aseem Sandhu on 7/5/15.
//

#import "AFHTTPRequestOperationManager.h"

typedef enum {
    OCOperationTypeMessage,
    OCOperationTypeComment
} OCOperationType;

@interface OCHTTPRequestOperationManager : AFHTTPRequestOperationManager

@property (nonatomic, strong) NSString *newestId;

- (void)addOperationForType:(OCOperationType)operationType withParams:(NSMutableDictionary *)params completion:(void (^)(BOOL success, BOOL noMoreOperations, AFHTTPRequestOperation *operation, void (^nextOperationBlock)(void)))completionBlock;

- (NSUInteger)OC_operationQueueCount;

@end










