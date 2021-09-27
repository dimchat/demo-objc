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

NSString *DIMInviteGroupCommand_BuildText(DIMInviteCommand *cmd, id<MKMID> commander) {
    // get 'added' list
    NSArray<id<MKMID>> *addeds = [MKMID convert:[cmd objectForKey:@"added"]];
    // build message
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:addeds.count];
    for (id<MKMID> item in addeds) {
        [mArr addObject:readable_name(item)];
    }
    NSString *str = [mArr componentsJoinedByString:@", "];
    NSString *format = NSLocalizedString(@"%@ has invited member(s): %@.", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(commander), str];
    [cmd setObject:text forKey:@"text"];
    return text;
}

NSString *DIMExpelGroupCommand_BuildText(DIMExpelCommand *cmd, id<MKMID> commander) {
    // get 'removed' list
    NSArray<id<MKMID>> *removeds = [MKMID convert:[cmd objectForKey:@"removed"]];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:removeds.count];
    for (id<MKMID> item in removeds) {
        [mArr addObject:readable_name(item)];
    }
    NSString *str = [mArr componentsJoinedByString:@", "];
    NSString *format = NSLocalizedString(@"%@ has removed member(s): %@.", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(commander), str];
    [cmd setObject:text forKey:@"text"];
    return text;
}

NSString *DIMQuitGroupCommand_BuildText(DIMQuitCommand *cmd, id<MKMID> commander) {
    NSString *format = NSLocalizedString(@"%@ has quitted group chat.", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(commander)];
    [cmd setObject:text forKey:@"text"];
    return text;
}

NSString *DIMResetGroupCommand_BuildText(DIMResetGroupCommand *cmd, id<MKMID> commander) {
    NSString *format = NSLocalizedString(@"%@ has updated group members", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(commander)];
    
    // get 'added' list
    NSArray<id<MKMID>> *addeds = [MKMID convert:[cmd objectForKey:@"added"]];
    if (addeds.count > 0) {
        NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:addeds.count];
        for (id<MKMID> item in addeds) {
            [mArr addObject:readable_name(item)];
        }
        NSString *str = [mArr componentsJoinedByString:@", "];
        text = [text stringByAppendingFormat:@"; %@ %@", NSLocalizedString(@"invited", nil), str];
    }
    
    // get 'removed' list
    NSArray<id<MKMID>> *removeds = [MKMID convert:[cmd objectForKey:@"removed"]];
    if (removeds.count > 0) {
        NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:removeds.count];
        for (id<MKMID> item in removeds) {
            [mArr addObject:readable_name(item)];
        }
        NSString *str = [mArr componentsJoinedByString:@", "];
        text = [text stringByAppendingFormat:@"; %@ %@", NSLocalizedString(@"removed", nil), str];
    }
    
    [cmd setObject:text forKey:@"text"];
    return text;
}

NSString *DIMQueryGroupCommand_BuildText(DIMQueryGroupCommand *cmd, id<MKMID> commander) {
    NSString *format = NSLocalizedString(@"%@ was querying group info, responding...", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(commander)];
    [cmd setObject:text forKey:@"text"];
    return text;
}

NSString *DIMGroupCommand_BuildText(DIMGroupCommand *cmd, id<MKMID> commander) {
    if ([cmd isKindOfClass:[DIMInviteCommand class]]) {
        return DIMInviteGroupCommand_BuildText((DIMInviteCommand *)cmd, commander);
    }
    if ([cmd isKindOfClass:[DIMExpelCommand class]]) {
        return DIMExpelGroupCommand_BuildText((DIMExpelCommand *)cmd, commander);
    }
    if ([cmd isKindOfClass:[DIMQuitCommand class]]) {
        return DIMQuitGroupCommand_BuildText((DIMQuitCommand *)cmd, commander);
    }
    if ([cmd isKindOfClass:[DIMResetGroupCommand class]]) {
        return DIMResetGroupCommand_BuildText((DIMResetGroupCommand *)cmd, commander);
    }
    if ([cmd isKindOfClass:[DIMQueryGroupCommand class]]) {
        return DIMQueryGroupCommand_BuildText((DIMQueryGroupCommand *)cmd, commander);
    }
    assert(!cmd);
    return nil;
}

#pragma mark System Commands

NSString *DIMLoginCommand_BuildText(DIMLoginCommand *cmd, id<MKMID> commander) {
    id<MKMID> ID = cmd.ID;
    NSDictionary *station = cmd.stationInfo;
    NSString *format = NSLocalizedString(@"%@ login: %@", nil);
    NSString *text = [NSString stringWithFormat:format, readable_name(ID), station];
    [cmd setObject:text forKey:@"text"];
    return text;
}

NSString *DIMCommand_BuildText(DIMCommand *cmd, id<MKMID> commander) {
    if ([cmd isKindOfClass:[DIMGroupCommand class]]) {
        return DIMGroupCommand_BuildText((DIMGroupCommand *)cmd, commander);
    }
    if ([cmd isKindOfClass:[DIMHistoryCommand class]]) {
        // TODO: process history command
    }
    if ([cmd isKindOfClass:[DIMLoginCommand class]]) {
        return DIMLoginCommand_BuildText((DIMLoginCommand *)cmd, commander);
    }
    NSString *format = NSLocalizedString(@"Current version doesn't support this command: %@", nil);
    return [NSString stringWithFormat:format, [cmd command]];
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
    } else if ([content isKindOfClass:[DIMWebpageContent class]]) {
        DIMWebpageContent *page = (DIMWebpageContent *)content;
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
