//
//  MazeLayer.h
//  MazeSample
//
//  Created by Terazzo on 11/12/14.
//

#import <QuartzCore/CoreAnimation.h>
#import "MazeTypes.h"


@interface MazeLayer : CALayer {
    BOOL special;
    CATransform3D originalTransform;
}
@property BOOL special;
@property CATransform3D originalTransform;
+ (id)layerWithPosition:(MazePosition)position for:(Direction)direction;
- (void)updateTransform:(CATransform3D)viewPointTransform;
@end
