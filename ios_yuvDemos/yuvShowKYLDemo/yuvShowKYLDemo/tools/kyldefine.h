//
//  kyldefine.h
//  yuvShowKYLDemo
//
//  Created by yulu kong on 2019/7/27.
//  Copyright © 2019 yulu kong. All rights reserved.
//

#ifndef kyldefine_h
#define kyldefine_h

#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

typedef enum : NSUInteger {
    KYLPixelBufferTypeNone = 0,
    KYLPixelBufferTypeNV12,
    KYLPixelBufferTypeRGB,
} KYLPixelBufferType;



#endif /* kyldefine_h */
