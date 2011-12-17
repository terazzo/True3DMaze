//
//  ViewPoint.h
//  MazeSample
//
//  Created by Terazzo on 11/12/14.
//

#import <QuartzCore/CoreAnimation.h>
#import "MazeTypes.h"

@interface ViewPoint : NSObject {
    CATransform3D transform;
}
@property CATransform3D transform;
- (void)setPosition:(MazePosition)position;
- (MazePosition)getPosition;
- (MazePosition)getPositionForInvertedTransform:(CATransform3D)inverted;
- (MazePosition)getForwardPosition;
- (void)moveForward;
@end

#ifdef VIEW_POINT_INCLUDE
#define VIEW_POINT_EXTERN
#else
#define VIEW_POINT_EXTERN extern
#endif

// Notification names
VIEW_POINT_EXTERN NSString *ViewPointDidChangeNotification;
VIEW_POINT_EXTERN NSString *ViewPointTransformKey;


