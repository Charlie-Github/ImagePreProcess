//
//  ViewController.m
//  ImagePreProcess
//
//  Created by CharlieGao on 5/22/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import "ViewController.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"


@interface ViewController ()


@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    
    // Test Cases
    NSString *image_0 = @"lena.png";
    NSString *image_1 = @"image_book.jpg";
    NSString *image_2 = @"image_blue_poster.jpg";
    NSString *image_3 = @"image_bubble_poster.jpg";
    NSString *image_4 = @"image_blur.jpg";
    NSString *image_5 = @"image_gauss_blur.png";
    
    // Load image
    UIImage *img = [UIImage imageNamed: image_1];
    
    
    cv::Mat tempMat = [img CVGrayscaleMat];
	
	cv::Mat output;
	cv::Size size;
	size.height = 3;
	size.width = 3;
    
    //fang -new line
    
    
    img = [UIImage imageWithCVMat:output]; //putting the image in an UIImage format
    
    // show image
    [self.imageView setImage:img];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
