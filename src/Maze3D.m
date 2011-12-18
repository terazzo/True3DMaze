//
//  Maze3D.m
//  True3DMaze
//
//  Created by Terazzo on 11/12/14.
//

#define MAZE_3D_INCLUDE

#import "Maze3D.h"
#import "MazeTypes.h"

@interface Maze3D (Private)
- (unsigned)checkAround:(int)x :(int)y :(int)z :(CellType)value;
- (void)allocateMap:(int)x :(int)y :(int)z;
- (void)freeMap;
@end


@implementation Maze3D
@synthesize sizeX;
@synthesize sizeY;
@synthesize sizeZ;
@synthesize start;
@synthesize goal;

static BOOL hasInitialized = NO;
+ (void)initialize
{
    if (!hasInitialized) {
        Maze3DDidInitializeNotification = @"Maze3DDidInitializeNotification";
        hasInitialized = YES;
    }
}

// 周りの状況を表したbit列を戻す
// 00ZYXzyx
// x: x方向に-2した所がtypeと等しいなら1、等しくなければ0
// y: y方向に-2した所がtypeと等しいなら1、等しくなければ0
// z: z方向に-2した所がtypeと等しいなら1、等しくなければ0
// X: x方向に+2した所がtypeと等しいなら1、等しくなければ0
// Y: y方向に+2した所がtypeと等しいなら1、等しくなければ0
// Z: z方向に+2した所がtypeと等しいなら1、等しくなければ0
- (unsigned)checkAround:(int)x :(int)y :(int)z :(CellType)type
{
    return 
    (((x >= 2 && map[x -2][y][z] == type) ? 1 :0) << XMINUS) |
    (((y >= 2 && map[x][y - 2][z] == type) ? 1 :0) << YMINUS) |
    (((z >= 2 && map[x][y][z - 2] == type) ? 1 :0) << ZMINUS) |
    (((x < sizeX - 2 && map[x + 2][y][z] == type) ? 1 :0) << XPLUS) |
    (((y < sizeY - 2 && map[x][y + 2][z] == type) ? 1 :0) << YPLUS) |
    (((y < sizeZ - 2 && map[x][y][z + 2] == type) ? 1 :0) << ZPLUS);
}

// 選択可能な方向からランダムに選択する
Direction
selectDirection(unsigned around)
{
    if (DIR_EMPTY(around)) return NODIR;

    for(;;) {
        int dir  = rand() % (MAX_DIRECTION + 1);
        if (DIR_HIT(around, dir)) {
            return dir;
        }
    }
}

// 地図を初期化して迷路を作成する。
- (void)constructMaze:(int)x :(int)y :(int)z
{
    // メモリ確保
    [self allocateMap:x :y :z];

    // 全部壁で埋める
    int i, j, k;
    for (i = 0; i < sizeX; i++) {
        for (j = 0; j < sizeY; j++) {
            for (k = 0; k < sizeZ; k++) {
                map[i][j][k] = WALL;
            }
        }
    }
    srand(time(NULL));
    
    for (i = 0; i < sizeX; i += 2) {
        for (j = 0; j < sizeY; j += 2) {
            for (k = 0; k < sizeZ; k += 2) {
                if (map[i][j][k] == PATH) {
                    continue; // 既に通路なら何もしない
                }
                // 現在地点を通路に
                map[i][j][k] = PATH;
                // 周りに通路があれば繋ぐ
                unsigned aroundPath = [self checkAround:i :j :k :PATH];
                if (!DIR_EMPTY(aroundPath)) {
                    Direction dir = selectDirection(aroundPath);
                    map[i + DIR2X(dir)][j + DIR2Y(dir)][k + DIR2Z(dir)] = 0;
                }
                // 可能ならば穴堀り
                int tx = i;
                int ty = j;
                int tz = k;
                while(TRUE) {
                    unsigned aroundWall = [self checkAround:tx :ty :tz :WALL];
                    if (DIR_EMPTY(aroundWall)) { // 進める方向がない
                        break;
                    }
                    int dir = selectDirection(aroundWall);
                    map[tx + DIR2X(dir)][ty + DIR2Y(dir)][tz + DIR2Z(dir)] = 0;
                    map[tx + DIR2X(dir) * 2][ty + DIR2Y(dir) * 2][tz + DIR2Z(dir) * 2] = 0;
                    tx += DIR2X(dir) * 2;
                    ty += DIR2Y(dir) * 2;
                    tz += DIR2Z(dir) * 2;
                }
            }
        }
    }
    start = makePosition(0, 0, 0);
    goal = makePosition(2 * (int)((x - 1) / 2), 2 * (int)((y - 1) / 2), 2 * (int)((z - 1) / 2));        

    // 変更を通知する
    [[NSNotificationCenter defaultCenter]
        postNotificationName:Maze3DDidInitializeNotification object:self];
}
// Map上での壁の有無を戻す
// d=DIRXでx=3, y=4, z=5の壁とは、(3,4,5)と(2,4,5)の間の壁のこと
- (BOOL)hasWallAt:(MazePosition)p for:(WallDirection)d ;
{
    // 外壁は必ずある
    if (d == DIR_X && (p.x == 0 || p.x == sizeX) && p.y < sizeY && p.z < sizeZ) {
        return YES;
    }
    if (d == DIR_Y && (p.y == 0 || p.y == sizeY) && p.x < sizeX && p.z < sizeZ) {
        return YES;
    }
    if (d == DIR_Z && (p.z == 0 || p.z == sizeZ) && p.x < sizeX && p.y < sizeY) {
        return YES;
    }
    // 外壁より外には壁無し
    if (p.x < 0 || p.y < 0 || p.z < 0 || p.x >= sizeX || p.y >= sizeY || p.z >= sizeZ) {
        return NO;
    }
    // NONE
    if (d == DIR_NONE) {
        return map[p.x][p.y][p.z] == PATH;
    }
    // X壁の場合、X方向の隣同士の値が異なる=壁有り
    if (d == DIR_X) {
        return map[p.x][p.y][p.z] != map[p.x - 1][p.y][p.z];
    }
    // Y壁の場合、Y方向の隣同士の値が異なる=壁有り
    if (d == DIR_Y) {
        return map[p.x][p.y][p.z] != map[p.x][p.y - 1][p.z];
    }
    // Z壁の場合、Z方向の隣同士の値が異なる=壁有り
    if (d == DIR_Z) {
        return map[p.x][p.y][p.z] != map[p.x][p.y][p.z - 1];
    }
    return NO;
}
- (BOOL)isAtGoal:(MazePosition)p
{
    return goal.x == p.x && goal.y == p.y && goal.z == p.z;
}
- (BOOL)position:(MazePosition)p isAround:(MazePosition)target for:(WallDirection)d
{
    // X壁の場合、
    if (d == DIR_X) {
        return (target.x == p.x || target.x == p.x - 1) && target.y == p.y && target.z == p.z;
    }
    // Y壁の場合
    if (d == DIR_Y) {
        return target.x == p.x && (target.y == p.y || target.y == p.y - 1) && target.z == p.z;
    }
    // Z壁の場合
    if (d == DIR_Z) {
        return target.x == p.x && target.y == p.y && (target.z == p.z || target.z == p.z - 1);
    }
    return NO;
}
- (BOOL)position:(MazePosition)p isAroundStartFor:(WallDirection)d 
{
    return [self position:p isAround:start for:d];
}
- (BOOL)position:(MazePosition)p isAroundGoalFor:(WallDirection)d
{
    return [self position:p isAround:goal for:d];
}

/* Memory Management */
- (void)dealloc
{
    [self freeMap];
    [super dealloc];
}

- (void)allocateMap:(int)x :(int)y :(int)z
{
    if (map != NULL) {
        [self freeMap];
    }
    map = (char ***) malloc((sizeof (char **)) * x);
    int i;
    for (i = 0; i < x; i++) {
        map[i] = (char **) malloc((sizeof (char*)) * y);
        int j;
        for (j = 0; j < y; j++) {
            map[i][j] = (char *) malloc((sizeof (char)) * z);
        }
    }
    sizeX = x;
    sizeY = y;
    sizeZ = z;
}
- (void)freeMap
{
    if (map) {
        int i;
        for (i = 0; i < sizeX; i++) {
            int j;
            for (j = 0; j < sizeY; j++) {
                free(map[i][j]);
            }
            free(map[i]);
        }
        free(map);
    }
    map = NULL;
}

@end
