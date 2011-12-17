//
//  MazeView.h
//  True3DMaze
//
//  Created by Terazzo on 11/12/14.
//

#import <Cocoa/Cocoa.h>
#import "MazeController.h"

@class MazeController;
@interface MazeView : NSView {
    IBOutlet MazeController *controller;
    NSPoint mouseDownPoint; // マウスダウン位置
    BOOL dragging;          // ドラッグ有無
}
@property(assign) IBOutlet MazeController *controller;
@end
