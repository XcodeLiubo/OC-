//
//  NSObject+LBKVO.h
//  Runtime
//
//  Created by 刘泊 on 2019/5/14.
//  Copyright © 2019 LB. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LBKVO_Callback) (id old, id modified, NSString* keyName);

@interface NSObject (LBKVO)
/** self表示被监听者, obj是观察者 */
- (void)kvoRegiesterName:(NSString* _Nonnull)pName
                observer:(id _Nonnull)obj
              callback:(LBKVO_Callback _Nullable)callback;

- (void)kvoRemoveWith:(id)ob name:(NSString*)name;
@end

NS_ASSUME_NONNULL_END
