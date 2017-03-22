// Copyright 2009-2010 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

@interface MUCountryServerListController : UIViewController 
- (id) initWithName:(NSString *)country serverList:(NSArray *)servers;
- (void) dealloc;
- (void) presentAddAsFavouriteDialogForServer:(NSDictionary *)serverItem;
@end
