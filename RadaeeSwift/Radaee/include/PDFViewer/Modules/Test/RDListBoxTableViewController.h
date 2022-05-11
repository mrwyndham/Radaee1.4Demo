//
//  RDListBoxTableViewController.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 14/11/17.
//

#import <UIKit/UIKit.h>

@protocol RDListBoxDelegate <NSObject>

- (void)didSelectListBoxItems:(NSArray *)items;
- (void)willEndListBoxEdit:(NSArray *)items;

@end

@interface RDListBoxTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *items;
@property (weak, nonatomic) id <RDListBoxDelegate> delegate;

@end
