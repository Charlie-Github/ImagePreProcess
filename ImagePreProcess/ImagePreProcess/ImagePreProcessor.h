//
//  ImagePreProcessor.h
//  TestGray
//
//  Created by CharlieGao on 5/22/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagePreProcessor : UIImage

-(cv::Mat)toGrayMat:(UIImage *) inputImage;

-(cv::Mat)threadholdControl:(cv::Mat) inputImage;

-(cv::Mat)gaussianBlur:(cv::Mat)inputImage :(int)h :(int)w; // size.height size.weight

-(cv::Mat)laplacian:(cv::Mat) inputImage;

-(UIImage *)deBlur:(UIImage *) inputimage;

-(IplImage *)CreateIplImageFromUIImage:(UIImage *)image;

-(UIImage *)UIImageFromIplImage:(IplImage *)image;



//Fang
-(cv::Mat)canny:(cv::Mat)input;

-(cv::Mat)bilateralFilter:(cv::Mat)input;

-(cv::Mat)boxFilter:(cv::Mat)input;

-(cv::Mat)erode:(cv::Mat)input;

-(cv::Mat)dilate:(cv::Mat)input;

-(cv::Mat)laplacian2:(cv::Mat)input;

@end
