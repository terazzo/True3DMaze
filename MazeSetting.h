//
//  MazeSetting.h
//  True3DMaze
//
//  Created by Terazzo on 11/12/17.
//

#import <Cocoa/Cocoa.h>


@interface MazeSetting : NSObject {
    int mazeSizeX;
    int mazeSizeY;
    int mazeSizeZ;
    CGFloat opaque;
    CGFloat borderWidth;
    CGFloat cornerRadius;
    NSColor *wallColor;
    int cheat;
    
}
@property int mazeSizeX;
@property int mazeSizeY;
@property int mazeSizeZ;
@property CGFloat opaque;
@property CGFloat borderWidth;
@property CGFloat cornerRadius;
@property(retain) NSColor *wallColor;
@property int cheat;
- (void)notifyAppearanceChanged;
@end


#ifdef MAZE_SETTING_INCLUDE
#define MAZE_SETTING_EXTERN
#else
#define MAZE_SETTING_EXTERN extern
#endif

// Notification names
MAZE_SETTING_EXTERN NSString *MazeAppearanceSettingDidChangeNotification;





