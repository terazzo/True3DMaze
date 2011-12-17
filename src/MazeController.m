//
//  MazeController.m
//  True3DMaze
//
//  Created by Terazzo on 11/12/13.
//
#import <QuartzCore/CoreAnimation.h>

#import "MazeController.h"
#import "ViewPoint.h"
#import "MazeView.h"
#import "MazeLayer.h"
#import "MazeSetting.h"

@interface MazeController(Private)
- (void)coodinateObjects;
- (void)constructMaze;
- (void)notifyViewPointChanged:(CATransform3D)transform;
@end


@implementation MazeController
@synthesize window;
@synthesize mazeView;
@synthesize viewPoint;
@synthesize maze;
@synthesize setting;
@synthesize settingPanel;
- (id)init
{
    if (self = [super init]) {
        self.viewPoint = [[[ViewPoint alloc] init] autorelease];
        self.maze = [[[Maze3D alloc] init] autorelease];
        self.setting = [[[MazeSetting alloc] init] autorelease];
    }
    return self;
}

- (void)awakeFromNib;
{
    [self coodinateObjects];
    [window makeKeyAndOrderFront:self];
}

- (void)coodinateObjects
{
    // wires models/views
    [[NSNotificationCenter defaultCenter]
         addObserver:mazeView selector:@selector(mazeDidInitialize:)
             name:Maze3DDidInitializeNotification object:maze];
    [[NSNotificationCenter defaultCenter]
         addObserver:viewPoint selector:@selector(mazeDidInitialize:)
            name:Maze3DDidInitializeNotification object:maze];
    [[NSNotificationCenter defaultCenter]
         addObserver:mazeView selector:@selector(viewPointDidChange:)
             name:ViewPointDidChangeNotification object:viewPoint];
    [[NSNotificationCenter defaultCenter]
         addObserver:mazeView selector:@selector(appearanceSettingDidChange:)
             name:MazeAppearanceSettingDidChangeNotification object:setting];
    // initialize
    [self constructMaze];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self autorelease];
}

// 迷路を再作成
- (IBAction)reconstructMaze:(id)sender
{
    [self constructMaze];
}
- (void)constructMaze
{
    [maze constructMaze:setting.mazeSizeX :setting.mazeSizeY :setting.mazeSizeZ];
    [setting notifyAppearanceChanged];
}

// 設定シートを表示
- (IBAction)runForSettingSheet:(id)sender
{
    [[NSApplication sharedApplication]
         beginSheet:settingPanel
         modalForWindow:window
         modalDelegate:self 
         didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
     contextInfo:nil];
}
// 設定シートを隠す
- (IBAction)endSettingSheet:(id)sender
{
    [[NSApplication sharedApplication] 
        endSheet:settingPanel returnCode:NSAlertDefaultReturn];
}
- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
    [settingPanel orderOut:self];
}

// 可能なら前進
- (void)moveForwardOrStay
{
    MazePosition position = [viewPoint getForwardPosition];
    if ([maze hasWallAt:position for:DIR_NONE] || setting.cheat == NSOnState) {
        [viewPoint moveForward];
    }
    [self notifyViewPointChanged:viewPoint.transform];

    if ([maze isAtGoal:[viewPoint getPosition]]) {
        NSRunAlertPanel(@"Clear", @"Congrats!!", @"Try the next.", nil, nil);
        [self constructMaze];
    }
}

- (void)rotateViewPoint:(CGFloat)angleX :(CGFloat)angleY
{
    CATransform3D transform = viewPoint.transform;
    transform = CATransform3DConcat(transform, 
                                    CATransform3DMakeRotation(angleX, 0.0f, -1.0f, 0.0f));
    transform = CATransform3DConcat(transform, 
                                    CATransform3DMakeRotation(angleY, 1.0f, 0.0f, 0.0f));
    
    viewPoint.transform = transform;
    [self notifyViewPointChanged:transform];
}
- (void)temporaryRotateViewPoint:(CGFloat)angleX :(CGFloat)angleY
{
    CATransform3D transform = viewPoint.transform;
    transform = CATransform3DConcat(transform, 
                        CATransform3DMakeRotation(angleX, 0.0f, -1.0f, 0.0f));
    transform = CATransform3DConcat(transform, 
                        CATransform3DMakeRotation(angleY, 1.0f, 0.0f, 0.0f));
    [self notifyViewPointChanged:transform];
}




- (void)notifyViewPointChanged:(CATransform3D)transform
{
    NSValue *transformValue = [NSValue valueWithCATransform3D:transform];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:transformValue forKey:ViewPointTransformKey];
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:ViewPointDidChangeNotification object:viewPoint userInfo:userInfo];
}

- (void)dealloc
{
    self.window = nil;
    self.settingPanel = nil;
    self.mazeView = nil;
    self.viewPoint = nil;
    self.maze = nil;
    self.setting = nil;
    [super dealloc];
}
@end
