//
//  DetailViewController.h
//  URLInspector
//
//  Created by Michael Nguyen on 1/25/15.
//
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UITextView *detailDescription;

@end

