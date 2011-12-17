//
//  MazeSetting.m
//  True3DMaze
//
//  Created by Terazzo on 11/12/17.
//
#define MAZE_SETTING_INCLUDE

#import "MazeSetting.h"

@interface MazeSetting(Private)
- (void)notifyAppearanceChanged;
@end

@implementation MazeSetting

@synthesize mazeSizeX;
@synthesize mazeSizeY;
@synthesize mazeSizeZ;
@synthesize opaque;
@synthesize borderWidth;
@synthesize cornerRadius;
@synthesize wallColor;
@synthesize throughWalls;
@synthesize freeRotation;

static BOOL hasInitialized = NO;
static NSArray *appearanceKeys;
+ (void)initialize
{
    if (!hasInitialized) {
        MazeAppearanceSettingDidChangeNotification = @"MazeAppearanceSettingDidChangeNotification";
        appearanceKeys = [[NSArray arrayWithObjects:
           @"opaque", @"borderWidth", @"cornerRadius", @"wallColor", nil] retain];
        hasInitialized = YES;
    }
}

- (id)init
{
    if (self = [super init]) {
        self.mazeSizeX = 7;
        self.mazeSizeY = 7;
        self.mazeSizeZ = 7;
        self.opaque = 0.7f;
        self.borderWidth = 0.5f;
        self.cornerRadius = 2.0f;
        self.wallColor = [NSColor whiteColor];
        self.throughWalls = NSOffState;
        self.freeRotation = NSOffState;
    }
    return self;
}
- (void)didChangeValueForKey:(NSString *)key
{
    [super didChangeValueForKey:key];
    if ([appearanceKeys containsObject:key]) {
        [self notifyAppearanceChanged];
    }
}
- (void)notifyAppearanceChanged
{
    [[NSNotificationCenter defaultCenter]
        postNotificationName:MazeAppearanceSettingDidChangeNotification
        object:self];
}
- (void)dealloc
{
    self.wallColor = nil;
    [super dealloc];
}
@end
