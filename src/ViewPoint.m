//
//  ViewPoint.m
//  MazeSample
//
//  Created by Terazzo on 11/12/14.
//
#define VIEW_POINT_INCLUDE

#import "ViewPoint.h"
#import "Maze3D.h"
#import "MazeTypes.h"

@interface ViewPoint(Private)
- (void)notifyChanging;
@end

@implementation ViewPoint
@synthesize transform;

static BOOL hasInitialized = NO;
+ (void)initialize
{
    if (!hasInitialized) {
        ViewPointDidChangeNotification = @"ViewPointDidChangeNotification";
        ViewPointTransformKey = @"ViewPointTransformKey";
        hasInitialized = YES;
    }
}
        
- (id)init
{
    if (self = [super init]) {
    }
    return self;
}
- (void)mazeDidInitialize:(NSNotification *)notification
{
    Maze3D *maze = [notification object];

    self.transform = CATransform3DIdentity;
    // 全体を傾かせる
    CGFloat angle = 0.5f * M_PI;
    self.transform = CATransform3DMakeRotation(-angle , 1.0f, 0.0f , 0.0f);
    [self setPosition:maze.start];
}

- (void)setPosition:(MazePosition)position
{
    CATransform3D inverted = CATransform3DInvert(transform);
    inverted.m41 = PIECE_SIZE / 2 + position.x * PIECE_SIZE;
    inverted.m42 = PIECE_SIZE / 2 + position.y * PIECE_SIZE;
    inverted.m43 = PIECE_SIZE / 2 + position.z * PIECE_SIZE;
    self.transform = CATransform3DInvert(inverted);
    
    [self notifyChanging];
}
- (MazePosition)getPosition
{
    return [self getPositionForInvertedTransform:CATransform3DInvert(transform)];
}
- (MazePosition)getPositionForInvertedTransform:(CATransform3D)inverted
{
    return makePosition((int) floor((inverted.m41 - PIECE_SIZE / 2 + EPS) / PIECE_SIZE),
                        (int) floor((inverted.m42 - PIECE_SIZE / 2 + EPS) / PIECE_SIZE),
                        (int) floor((inverted.m43 - PIECE_SIZE / 2 + EPS) / PIECE_SIZE));
}
- (void)moveForward
{
    NSLog(@"moveForward");
    self.transform =
    CATransform3DConcat(self.transform, CATransform3DMakeTranslation(0.0f, 0.0f, PIECE_SIZE));
}
- (MazePosition)getForwardPosition
{
    CATransform3D inverted =
    CATransform3DInvert(
                        CATransform3DConcat(self.transform,
                                            CATransform3DMakeTranslation(0.0f, 0.0f, PIECE_SIZE)));
    return [self getPositionForInvertedTransform:inverted];
}

- (void)notifyChanging
{
    NSValue *transformValue = [NSValue valueWithCATransform3D:transform];
    NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:transformValue forKey:ViewPointTransformKey];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:ViewPointDidChangeNotification object:self userInfo:userInfo];
}
@end
