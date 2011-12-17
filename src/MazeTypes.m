//
//  MazeTypes.m
//  True3DMaze
//
//  Created by Terazzo on 11/12/14.
//

#import "MazeTypes.h"


MazePosition
makePosition(int x, int y, int z)
{
    MazePosition position;
    position.x = x;
    position.y = y;
    position.z = z;
    return position;
}
