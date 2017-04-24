#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "DebugKit.h"
#import "HexDump.h"
#import "NSData+HexDump.h"
#import "NSString+HexDump.h"

FOUNDATION_EXPORT double DebugKitVersionNumber;
FOUNDATION_EXPORT const unsigned char DebugKitVersionString[];

