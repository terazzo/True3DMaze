//
//  MazeView.m
//  True3DMaze
//
//  Created by Terazzo on 11/12/14.
//
#import <QuartzCore/CoreAnimation.h>

#import "MazeView.h"
#import "ViewPoint.h"
#import "MazeLayer.h"

@interface MazeView(Private)
- (void)updatePerspective;
- (void)updateViewPoint:(CATransform3D)transform;
- (void)updateAppearanceSetting:(MazeSetting *)setting;
- (void)mazeDidInitialize:(NSNotification *)notification;
- (void)viewPointDidChange:(NSNotification *)notification;
@end

@implementation MazeView
@synthesize controller;

// retainedなCGColorRefを生成する
CGColorRef
createGCColorWithNSColor(NSColor *color, CGFloat alpha)
{
    NSColor *rgbColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    CGFloat red, green,blue;
    [rgbColor getRed:&red green:&green blue:&blue alpha:NULL];
    return CGColorCreateGenericRGB(red, green, blue, alpha);
}


- (void)mazeDidInitialize:(NSNotification *)notification
{
    Maze3D *maze = (Maze3D *) [notification object];

    // 透視変換用のレイヤ
    CALayer *perspectiveLayer = [CALayer layer];
    perspectiveLayer.frame = NSRectToCGRect(self.bounds);
    perspectiveLayer.autoresizingMask = kCALayerNotSizable;
    
    [self setLayer:perspectiveLayer];
    [self setWantsLayer:YES];

    // 壁
    CGColorRef startColor = createGCColorWithNSColor([NSColor greenColor], 1.0f);
    CGColorRef goalColor = createGCColorWithNSColor([NSColor redColor], 1.0f);
    void (^addLayerIfHavingWall)(MazePosition, WallDirection) =
    ^(MazePosition p, WallDirection d) {
        if ([maze hasWallAt:p for:d]) {
            MazeLayer *layer = [MazeLayer layerWithPosition:p for:d];
            [perspectiveLayer addSublayer:layer];
            if ([maze position:p isAroundStartFor:d]) {
                layer.backgroundColor = startColor;
                layer.special = YES;
            }
            if ([maze position:p isAroundGoalFor:d]) {
                layer.backgroundColor = goalColor;
                layer.special = YES;
            }
        }
    };
    int i, j, k;
    for (i = 0; i <= maze.sizeX; i++) {
        for (j = 0; j <= maze.sizeY; j++) {
            for (k = 0; k <= maze.sizeZ; k++) {
                MazePosition position = makePosition(i, j, k);
                addLayerIfHavingWall(position, DIR_X);
                addLayerIfHavingWall(position, DIR_Y);
                addLayerIfHavingWall(position, DIR_Z);
            }
        }
    }
    CGColorRelease(startColor);
    CGColorRelease(goalColor);
    [self updatePerspective];
}

// リサイズメソッドをオーバーライドし、リサイズ後の透視変換の設定をおこなう
- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize
{
    [super resizeWithOldSuperviewSize:oldBoundsSize];

    [self updatePerspective];
}

// レイヤの透視変換を初期化する
- (void)updatePerspective
{
    NSRect bounds = self.bounds;

    CGFloat screenDept = MIN(bounds.size.width, bounds.size.height);
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    CALayer *perspectiveLayer = self.layer;
    perspectiveLayer.frame = NSRectToCGRect(bounds);

    CATransform3D perspectiveTransform = CATransform3DIdentity;
    perspectiveTransform.m34 = 1.0f / -screenDept;
    perspectiveLayer.sublayerTransform = perspectiveTransform;

    [perspectiveLayer.sublayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MazeLayer *layer = (MazeLayer *)obj;
        
        layer.zPosition = screenDept - PIECE_SIZE;
        layer.position = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    }];

    [CATransaction commit];
}

// 視点の更新通知を受ける
- (void)viewPointDidChange:(NSNotification *)notification
{
    [self updateViewPoint:
     [[[notification userInfo] objectForKey:ViewPointTransformKey] CATransform3DValue]];
}
// レイヤの視点を更新する
- (void)updateViewPoint:(CATransform3D)transform
{
    [self.layer.sublayers enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) {
         MazeLayer *layer = (MazeLayer *)obj;
         [layer updateTransform:transform];
     }];

}

//外観設定変更通知を受ける
- (void)appearanceSettingDidChange:(NSNotification *)notification
{
    MazeSetting *setting = [notification object];
    [self updateAppearanceSetting:setting];
}

//外観設定変更を反映する
- (void)updateAppearanceSetting:(MazeSetting *)setting
{
    CGColorRef bgColor = createGCColorWithNSColor(setting.wallColor, setting.opaque);
    CGColorRef borderColor = createGCColorWithNSColor([NSColor darkGrayColor], 1.0f);
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    [self.layer.sublayers enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) {
         MazeLayer *layer = (MazeLayer *)obj;

         layer.borderWidth = setting.borderWidth;
         layer.cornerRadius = setting.cornerRadius;
         if (layer.special) {
             CGColorRef color = CGColorCreateCopyWithAlpha(layer.backgroundColor, setting.opaque);
             layer.backgroundColor = color;
             CGColorRelease(color);
         } else {
             layer.backgroundColor = bgColor;
         }
         layer.borderColor = borderColor;         
     }];
    
    [CATransaction commit];

    CGColorRelease(borderColor);
    CGColorRelease(bgColor);
}

- (void)mouseDown:(NSEvent *)theEvent
{
    mouseDownPoint = theEvent.locationInWindow;
}

- (void)mouseDragged:(NSEvent*)theEvent
{
    NSSize viewSize = self.bounds.size;
    NSPoint currentPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    float dx = currentPoint.x - mouseDownPoint.x;
    float dy = currentPoint.y - mouseDownPoint.y;
    float rotateX = dx / viewSize.width;
    float rotateY = dy / viewSize.height;

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    [controller temporaryRotateViewPoint:M_PI * rotateX :M_PI * rotateY];

    [CATransaction commit];

    dragging = YES;
}
- (void)mouseUp:(NSEvent *)theEvent
{
    if (dragging) {
        NSSize viewSize = self.bounds.size;
        NSPoint mouseUpPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
        float dx = mouseUpPoint.x - mouseDownPoint.x;
        float dy = mouseUpPoint.y - mouseDownPoint.y;
        float rotateX = dx / viewSize.width;
        float rotateY = dy / viewSize.height;
        // 90度単位で丸める
        rotateX = floor(rotateX * 2 + 0.5f) / 2;
        rotateY = floor(rotateY * 2 + 0.5f) / 2;
        
        [controller rotateViewPoint:M_PI * rotateX :M_PI * rotateY];
    } else {
        // 可能なら一歩進む。可能でないなら視点を戻す。
        [controller moveForwardOrStay];
    }

    dragging = NO;
}
- (void)dealloc
{
    self.controller = nil;
    [super dealloc];
}
@end


