//
//  DetailViewController.m
//  URLInspector
//
//  Created by Michael Nguyen on 1/25/15.
// Basic ViewController that uses a TextView to display content from the previous page.
//
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescription.text = [[self.detailItem valueForKey:@"responseString"] description];
        self.title =[[self.detailItem valueForKey:@"url"] description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
