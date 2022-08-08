// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMCommand+Extension.m
//  Sechat
//
//  Created by Albert Moky on 2019/10/22.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMLoginCommand.h"

#import "DIMFacebook+Extension.h"

#import "DIMCommand+Extension.h"

static inline NSString *readable_name(id<MKMID> ID) {
    id<MKMDocument> doc = DIMDocumentForID(ID, @"*");
    NSString *nickname = doc.name;
    NSString *username = ID.name;
    if (nickname) {
        if (username && MKMIDIsUser(ID)) {
            return [NSString stringWithFormat:@"%@ (%@)", nickname, username];
        }
        return nickname;
    } else if (username) {
        return username;
    } else {
        // BTC Address
        return (NSString *)ID.address;
    }
}

#pragma mark Group Commands

NSString *DIMInviteGroupCommand_BuildText(DIMInviteCommand *command, id<MKMID> commander) {
    // get 'added' list
    NSArray<id<MKMID>> *addeds = MKMIDConvert([command objectForKey:@"added"]);
    // build message
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:addeds.count];
    for (id<MKMID> item in addeds) {
        [mArr addObject:readable_name(item)];
    }
    NSString *str = [mArr componentsJoinedByString:@", "];
    NSString *format = NSLocalizedString(@"%@ has invited member(s): %@.", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(commander), str];
    [command setObject:text forKey:@"text"];
    return text;
}

NSString *DIMExpelGroupCommand_BuildText(DIMExpelCommand *command, id<MKMID> commander) {
    // get 'removed' list
    NSArray<id<MKMID>> *removeds = MKMIDConvert([command objectForKey:@"removed"]);
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:removeds.count];
    for (id<MKMID> item in removeds) {
        [mArr addObject:readable_name(item)];
    }
    NSString *str = [mArr componentsJoinedByString:@", "];
    NSString *format = NSLocalizedString(@"%@ has removed member(s): %@.", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(commander), str];
    [command setObject:text forKey:@"text"];
    return text;
}

NSString *DIMQuitGroupCommand_BuildText(DIMQuitCommand *command, id<MKMID> commander) {
    NSString *format = NSLocalizedString(@"%@ has quitted group chat.", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(commander)];
    [command setObject:text forKey:@"text"];
    return text;
}

NSString *DIMResetGroupCommand_BuildText(DIMResetGroupCommand *command, id<MKMID> commander) {
    NSString *format = NSLocalizedString(@"%@ has updated group members", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(commander)];
    
    // get 'added' list
    NSArray<id<MKMID>> *addeds = MKMIDConvert([command objectForKey:@"added"]);
    if (addeds.count > 0) {
        NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:addeds.count];
        for (id<MKMID> item in addeds) {
            [mArr addObject:readable_name(item)];
        }
        NSString *str = [mArr componentsJoinedByString:@", "];
        text = [text stringByAppendingFormat:@"; %@ %@", NSLocalizedString(@"invited", nil), str];
    }
    
    // get 'removed' list
    NSArray<id<MKMID>> *removeds = MKMIDConvert([command objectForKey:@"removed"]);
    if (removeds.count > 0) {
        NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:removeds.count];
        for (id<MKMID> item in removeds) {
            [mArr addObject:readable_name(item)];
        }
        NSString *str = [mArr componentsJoinedByString:@", "];
        text = [text stringByAppendingFormat:@"; %@ %@", NSLocalizedString(@"removed", nil), str];
    }
    
    [command setObject:text forKey:@"text"];
    return text;
}

NSString *DIMQueryGroupCommand_BuildText(DIMQueryGroupCommand *command, id<MKMID> commander) {
    NSString *format = NSLocalizedString(@"%@ was querying group info, responding...", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(commander)];
    [command setObject:text forKey:@"text"];
    return text;
}

NSString *DIMGroupCommand_BuildText(DIMGroupCommand *command, id<MKMID> commander) {
    if ([command isKindOfClass:[DIMInviteCommand class]]) {
        return DIMInviteGroupCommand_BuildText((DIMInviteCommand *)command, commander);
    }
    if ([command isKindOfClass:[DIMExpelCommand class]]) {
        return DIMExpelGroupCommand_BuildText((DIMExpelCommand *)command, commander);
    }
    if ([command isKindOfClass:[DIMQuitCommand class]]) {
        return DIMQuitGroupCommand_BuildText((DIMQuitCommand *)command, commander);
    }
    if ([command isKindOfClass:[DIMResetGroupCommand class]]) {
        return DIMResetGroupCommand_BuildText((DIMResetGroupCommand *)command, commander);
    }
    if ([command isKindOfClass:[DIMQueryGroupCommand class]]) {
        return DIMQueryGroupCommand_BuildText((DIMQueryGroupCommand *)command, commander);
    }
    assert(!command);
    return nil;
}

#pragma mark System Commands

NSString *DIMLoginCommand_BuildText(DIMLoginCommand *command, id<MKMID> commander) {
    id<MKMID> ID = command.ID;
    NSDictionary *station = command.stationInfo;
    NSString *format = NSLocalizedString(@"%@ login: %@", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(ID), station];
    [command setObject:text forKey:@"text"];
    return text;
}

NSString *DIMCommand_BuildText(DIMCommand *command, id<MKMID> commander) {
    if ([command isKindOfClass:[DIMGroupCommand class]]) {
        return DIMGroupCommand_BuildText((DIMGroupCommand *)command, commander);
    }
    if ([command isKindOfClass:[DIMHistoryCommand class]]) {
        // TODO: process history command
    }
    if ([command isKindOfClass:[DIMLoginCommand class]]) {
        return DIMLoginCommand_BuildText((DIMLoginCommand *)command, commander);
    }
    NSString *format = NSLocalizedString(@"Current version doesn't support this command: %@", nil);
    return [NSString stringWithFormat:format, [command cmd]];
}

NSString *DIMContent_BuildText(id<DKDContent> content) {
    // Text
    if ([content isKindOfClass:[DIMTextContent class]]) {
        return [(DIMTextContent *)content text];
    }
    NSString *text = [content objectForKey:@"text"];
    if ([text length] > 0) {
        return text;
    }
    // File: Image, Audio, Video
    if ([content isKindOfClass:[DIMFileContent class]]) {
        if ([content isKindOfClass:[DIMImageContent class]]) {
            NSString *filename = [(DIMImageContent *)content filename];
            NSString *format = NSLocalizedString(@"[Image:%@]", nil);
            text = [NSString stringWithFormat:format, filename];
        } else if ([content isKindOfClass:[DIMAudioContent class]]) {
            NSString *filename = [(DIMAudioContent *)content filename];
            NSString *format = NSLocalizedString(@"[Voice:%@]", nil);
            text = [NSString stringWithFormat:format, filename];
        } else if ([content isKindOfClass:[DIMVideoContent class]]) {
            NSString *filename = [(DIMVideoContent *)content filename];
            NSString *format = NSLocalizedString(@"[Movie:%@]", nil);
            text = [NSString stringWithFormat:format, filename];
        } else {
            NSString *filename = [(DIMFileContent *)content filename];
            NSString *format = NSLocalizedString(@"[File:%@]", nil);
            text = [NSString stringWithFormat:format, filename];
        }
    } else if ([content isKindOfClass:[DIMPageContent class]]) {
        DIMPageContent *page = (DIMPageContent *)content;
        NSString *text = page.title;
        if ([text length] == 0) {
            text = page.desc;
            if ([text length] == 0) {
                text = [page.URL absoluteString];
            }
        }
        NSString *format = NSLocalizedString(@"[Web:%@]", nil);
        text = [NSString stringWithFormat:format, text];
    } else {
        NSString *format = NSLocalizedString(@"This client doesn't support this message type: %u", nil);
        text = [NSString stringWithFormat:format, content.type];
    }
    
    if ([text length] > 0) {
        [content setObject:text forKey:@"text"];
    }
    return text;
}

#pragma mark -

@implementation DKDContent (Extension)

- (nullable NSString *)messageWithSender:(id<MKMID>)sender {
    NSString *text = [self objectForKey:@"text"];
    if ([text length] > 0) {
        return text;
    }
    return DIMContent_BuildText(self);
}

@end

@implementation DIMCommand (Extension)

- (nullable NSString *)messageWithSender:(id<MKMID>)sender {
    NSString *text = [self objectForKey:@"text"];
    if ([text length] > 0) {
        return text;
    }
    return DIMCommand_BuildText(self, sender);
}

@end
