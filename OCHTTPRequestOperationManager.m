//
//  OCHTTPRequestOperationManager.m
//
//  Created by Aseem Sandhu on 7/5/15.
//

#import "OCHTTPRequestOperationManager.h"

#define PARAMS_KEY @"params"
#define BLOCK_KEY @"completionBlock"

@interface OCHTTPRequestOperationManager ()

@property (nonatomic) BOOL connectionFlag;

@property (nonatomic, strong) NSMutableArray *operationArray;

@end

@implementation OCHTTPRequestOperationManager

- (void)addOperationForType:(OCOperationType)operationType withParams:(NSMutableDictionary *)params completion:(void (^)(BOOL success, BOOL noMoreOperations, AFHTTPRequestOperation *operation, void (^nextOperationBlock)(void)))completionBlock {
    
    NSDictionary *operationDict = @{PARAMS_KEY: params, BLOCK_KEY: completionBlock};
    [self.operationArray addObject:operationDict];
    
    if (!self.connectionFlag) {
        [self startNextOperation:operationType];
    }
}

- (NSMutableArray *)operationArray
{
    if (!_operationArray) {
        _operationArray = [[NSMutableArray alloc] init];
    }
    return _operationArray;
}

- (void)startNextOperation:(OCOperationType)operationType {
        
    if (self.connectionFlag) {
        return;
    }

    if (self.operationArray.count > 0) {
        
        self.connectionFlag = YES;
        
        if (operationType == OCOperationTypeComment) {
            [self executeOperationForKey:OCOperationTypeComment];
        } else {
            [self executeOperationForKey:OCOperationTypeMessage];
        }
    }
}

- (void)executeOperationForKey:(OCOperationType)operationType {
    
    NSLog(@"STARTING NEXT POST COMMENT OPERATION");
    
    NSDictionary *operationDict = [self.operationArray objectAtIndex:0];
    
    NSMutableDictionary *params = [operationDict valueForKey:PARAMS_KEY];
    
    NSString *urlString;
    
    if (operationType == OCOperationTypeComment) {
        urlString = POSTCOMMENT;
        NSString *newestCommentId;
        if (self.newestId) {
            newestCommentId = self.newestId;
        } else {
            newestCommentId = @"0";
        }
        [params setObject:newestCommentId forKey:@"fromCommentId"];
    } else if (operationType == OCOperationTypeMessage) {
        urlString = CREATEMESSAGE;
    } else {
        return;
    }
    
    void (^completionBlock)(BOOL success, BOOL noMoreOperations, AFHTTPRequestOperation *operation, void (^nextOperationBlock)(void)) = [operationDict valueForKey:BLOCK_KEY];
    
    void (^nextOperationBlock)(void) = ^{
        
        if (operationType == OCOperationTypeComment) {
            [self startNextOperation:OCOperationTypeComment];
        } else if (operationType == OCOperationTypeMessage) {
            
            [self startNextOperation:OCOperationTypeMessage];
        }
    };
    
    [self POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"the response object when posting a comment: %@", responseObject);
            
        [self.operationArray removeObject:operationDict];
        self.connectionFlag = NO;
        
        BOOL isLastOperation = NO;
        
        if (self.operationArray.count == 0) {
            isLastOperation = YES;
        }
        
        completionBlock(YES, isLastOperation, operation, nextOperationBlock);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"the error when posting a comment:%@", error);
        
        [self.operationArray removeObject:operationDict];
        self.connectionFlag = NO;
        
        BOOL isLastOperation = NO;
        
        if (self.operationArray.count == 0) {
            isLastOperation = YES;
        }
        
        completionBlock(NO, isLastOperation, operation, nextOperationBlock);
        
    }];
}

- (NSUInteger)OC_operationQueueCount {
    return self.operationArray.count;
}

@end








