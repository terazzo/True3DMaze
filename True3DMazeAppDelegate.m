//
//  True3DMazeAppDelegate.m
//  True3DMaze
//
//  Created by Terazzo on 11/12/13.
//

#import "True3DMazeAppDelegate.h"
#import "MazeController.h"

@implementation True3DMazeAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self newMaze:self];
}

- (IBAction)newMaze:(id)sender
{
    [NSBundle loadNibNamed:@"Maze" owner:[[MazeController alloc]init]];
}

@end
