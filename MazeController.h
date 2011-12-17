//
//  MazeController.h
//  True3DMaze
//
//  Created by Terazzo on 11/12/13.
//

#import <Cocoa/Cocoa.h>
#import "MazeView.h"
#import "ViewPoint.h"
#import "Maze3D.h"
#import "MazeSetting.h"

@class MazeView;
@interface MazeController : NSObject {
    IBOutlet NSWindow *window;
    IBOutlet MazeView *mazeView;
    IBOutlet NSPanel *settingPanel;
    MazeSetting *setting;
    ViewPoint *viewPoint;
    Maze3D *maze;
}
@property(assign) IBOutlet NSWindow *window;
@property(assign) IBOutlet MazeView *mazeView;
@property(assign) IBOutlet NSPanel *settingPanel;
@property(retain) MazeSetting *setting;
@property(retain) ViewPoint *viewPoint;
@property(retain) Maze3D *maze;

- (IBAction)reconstructMaze:(id)sender;
- (IBAction)runForSettingSheet:(id)sender;
- (IBAction)endSettingSheet:(id)sender;

- (void)moveForwardOrStay;
- (void)rotateViewPoint:(CGFloat)angleX :(CGFloat)angleY;
- (void)temporaryRotateViewPoint:(CGFloat)angleX :(CGFloat)angleY;
@end
