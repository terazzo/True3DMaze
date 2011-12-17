//
//  Maze3D.h
//  True3DMaze
//
//  Created by Terazzo on 11/12/14.
//

#import <QuartzCore/CoreAnimation.h>
#import "MazeTypes.h"

@interface Maze3D : NSObject {
    int sizeX;
    int sizeY;
    int sizeZ;
    MazePosition start;
    MazePosition goal;
    char ***map;
}
@property(readonly) int sizeX;
@property(readonly) int sizeY;
@property(readonly) int sizeZ;
@property(readonly) MazePosition start;
@property(readonly) MazePosition goal;
- (void)constructMaze:(int)x :(int)y :(int)z;
- (BOOL)hasWallAt:(MazePosition)position for:(WallDirection)direction;
- (BOOL)isAtGoal:(MazePosition)position;
- (BOOL)position:(MazePosition)position isAroundStartFor:(WallDirection)direction;
- (BOOL)position:(MazePosition)position isAroundGoalFor:(WallDirection)direction;
@end

#ifdef MAZE_3D_INCLUDE
#define MAZE_3D_EXTERN
#else
#define MAZE_3D_EXTERN extern
#endif


// Notification names
MAZE_3D_EXTERN NSString *Maze3DDidInitializeNotification;
