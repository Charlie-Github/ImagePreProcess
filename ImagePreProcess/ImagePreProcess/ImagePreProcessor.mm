//
//  ImagePreProcessor.m
//  TestGray
//
//  Created by CharlieGao on 5/22/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import "ImagePreProcessor.h"

#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"

@implementation ImagePreProcessor


-(cv::Mat)toGrayMat:(UIImage *) inputImage{
    
    cv::Mat matImage = [inputImage CVGrayscaleMat];
    return matImage;
}


-(cv::Mat)threadholdControl:(cv::Mat) inputImage{
    
    cv::Mat output;
    cv::adaptiveThreshold(inputImage, output, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 25, 14);
    return output;

}

-(cv::Mat)gaussianBlur:(cv::Mat)inputImage :(int)h :(int)w{
    
    cv::Mat output;
    cv::Size size;
	size.height = h;
	size.width = w;
    cv::GaussianBlur(inputImage, output, size, 0.8);
    return output;

}

-(cv::Mat)laplacian:(cv::Mat)inputImage{
    
    cv::Mat output;
    cv::Mat kernel = (cv::Mat_<float>(3, 3) << 0, -1, 0, -1, 5, -1, 0, -1, 0); //Laplacian operator
    cv::filter2D(inputImage, output, output.depth(), kernel);
    return output;

}


//========================================= Fang
-(cv::Mat)canny:(cv::Mat)input{
    cv::Mat output;
    cv::Canny(input, output, 0.8,0.5);
    return output;
}

-(cv::Mat)bilateralFilter:(cv::Mat)input
{
    cv::Mat output;
    cv::bilateralFilter (input, output, 15, 80, 80 );
    return output;
    
}

-(cv::Mat)boxFilter:(cv::Mat)input
{
    cv::Mat output;
    cv::Size size;
	size.height = 3;
	size.width = 3;
    cv::boxFilter(input, output, CV_16S, size);
    return output;
}

-(cv::Mat)erode:(cv::Mat)input
{
    int erosion_size = 60;
    cv::Mat element = cv::getStructuringElement(cv::MORPH_CROSS,
                                                cv::Size(2 * erosion_size + 1, 2 * erosion_size + 1),
                                                cv::Point(erosion_size, erosion_size) );
    cv::Mat output;
    cv::erode (input, output, element);
    return output;
    
}

-(cv::Mat)dilate:(cv::Mat)input
{
    int erosion_size = 60;
    cv::Mat element = cv::getStructuringElement(cv::MORPH_CROSS,
                                                cv::Size(2 * erosion_size + 1, 2 * erosion_size + 1),
                                                cv::Point(erosion_size, erosion_size) );
    cv::Mat output;
    cv::dilate (input, output, element);
    return output;
    
}

-(cv::Mat)laplacian2:(cv::Mat)input
{
    cv::Mat output;
    cv::Laplacian(input, output, CV_16S);
    return output;
}


//==========================================/Fang


-(UIImage *)deBlur:(UIImage *)inputimage{
    
    //use Wiener filter
    /*=============================================== implement Wiener Filter==============================================================*/
    
    
    IplImage *img= [self CreateIplImageFromUIImage:inputimage];//原始图图像1
    //得到灰度化图像g1
    IplImage*g=cvCreateImage(cvSize(img->width,img->height),IPL_DEPTH_8U,1);
    cvCvtColor(img,g,CV_RGB2GRAY);
    
    IplImage*gg=cvCreateImage(cvSize(img->width,img->height),IPL_DEPTH_32F,1);//输入用于计算的图像
    cvConvertScale(g,gg);
    
    IplImage*localMean=cvCreateImage(cvSize(img->width,img->height),IPL_DEPTH_32F,1);//“均值”具体解释见程序代码求解公式
    IplImage*localVar=cvCreateImage(cvSize(img->width,img->height),IPL_DEPTH_32F,1);//“方差”
    IplImage*f=cvCreateImage(cvSize(img->width,img->height),IPL_DEPTH_32F,1);//输出用于计算的图像
    
    /*得到滤波模板*/
    CvMat*mat=cvCreateMat(5,5,CV_32FC1);
    cvZero(mat);
    int row,col;
    for(row=0;row<mat->height;row++)
    {
        float*pData=(float*)(mat->data.ptr+row*mat->step);//获取第row行的行首指针，因为数据类型为浮点型，因此，通过data.ptr与step获得的字节指针需要转换为float*这样的指针
        for(col=0;col<mat->width;col++)
        {
            *pData=1;
            pData++;//因为,指针后移一位，也即是指向下一个浮点数
        }
    }
    float prod=25;//滤波模板的数值和
    float sumlocalVar=0;//方差和
    
    /*得到原始图像与模板卷积后的图像*/
    IplImage*dst=cvCreateImage(cvGetSize(g),IPL_DEPTH_32F,1);
    cvFilter2D(g,dst,mat,cvPoint(-1,-1));
    
    /*得到原始图像像素平方与模板卷积后的图像*/
    IplImage*grayImg32F2X=cvCreateImage(cvGetSize(g),IPL_DEPTH_32F,1);
    cvMul(gg,gg,grayImg32F2X);
    
    IplImage*dst2=cvCreateImage(cvGetSize(grayImg32F2X),IPL_DEPTH_32F,1);
    cvFilter2D(grayImg32F2X,dst2,mat,cvPoint(-1,-1));
    
    for(int i=0;i<(g->height);i++)
    {
        //r、p是指向图像数据首地址的指针，类型是无符号字符型
        float*r=(float*)(dst->imageData+i*dst->widthStep);
        float*p=(float*)(localMean->imageData+i*localMean->widthStep);
        float*q=(float*)(dst2->imageData+i*dst2->widthStep);
        float*m=(float*)(localVar->imageData+i*localVar->widthStep);
        float*n=(float*)(f->imageData+i*f->widthStep);
        float*o=(float*)(gg->imageData+i*gg->widthStep);
        for(int j=0;j<(g->width);j++)
        {
            p[j]=r[j]/prod;//为localMean像素赋值wrong;
            m[j]=q[j]/prod-p[j]*p[j];//为localVar像素赋值
            n[j]=o[j]-p[j];//实现公式f=g-localMean;
        }
    }
    
    
    float noise=0;
    int count=0;
    for(int i=0;i<(g->height);i++)
    {
        //r、p是指向图像数据首地址的指针，类型是无符号字符型
        float*m=(float*)(localVar->imageData+i*localVar->widthStep);
        for(int j=0;j<(g->width);j++)
        {
            noise=noise+m[j];
            count++;
        }
    }
    noise=noise/count;//求得噪声isdifferetfromMatlabvalue
    
    for(int i=0;i<(localVar->height);i++)
    {
        float*o=(float*)(gg->imageData+i*gg->widthStep);
        float*m=(float*)(localVar->imageData+i*localVar->widthStep);
        for(int j=0;j<(localVar->width);j++)
        {
            o[j]=m[j]-noise;//实现公式g=localVar-noise;误差很大，不应该！
        }
    }
    
    cvMaxS(gg,0,gg);//gg与0比，去较大值存入gg
    cvMaxS(localVar,noise,localVar);//localVar与noise比，去较大值存入localVar
    cvDiv(f,localVar,f);//f=f-localVa
    cvMul(f,gg,f);//f=f*gg
    cvAdd(f,localMean,f);//f=f+localMean
    
    IplImage*ff=cvCreateImage(cvSize(img->width,img->height),IPL_DEPTH_8U,1);//滤波后图像
    
    
    
    cvConvertScale(f,ff);
    
    
    
    
    /*======================================================== End of implementation ====================================================*/
    
    // make a new UIImage to return
    UIImage *resultUIImage = [self UIImageFromIplImage: ff];
    
    cvReleaseImage(&f);
    cvReleaseImage(&ff);
    cvReleaseImage(&img);
    cvReleaseImage(&localMean);
    cvReleaseImage(&localVar);
    cvReleaseImage(&g);
    cvReleaseMat(&mat);
    cvReleaseImage(&dst);
    cvReleaseImage(&grayImg32F2X);
    cvReleaseImage(&dst2);
    cvReleaseImage(&dst2);
    
    return resultUIImage;
    
}


- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
    CGImageRef      imageRef;
    CGColorSpaceRef colorSpaceRef;
    CGContextRef    context;
    IplImage      * iplImage;
    IplImage      * returnImage;
    
    imageRef      = image.CGImage;
    colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    iplImage      = cvCreateImage( cvSize( image.size.width, image.size.height ), IPL_DEPTH_8U, 4 );
    context       = CGBitmapContextCreate
    (
     iplImage->imageData,
     iplImage->width,
     iplImage->height,
     iplImage->depth,
     iplImage->widthStep,
     colorSpaceRef,
     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault
     );
    
    CGContextDrawImage( context, CGRectMake( 0, 0, image.size.width, image.size.height ), imageRef );
    CGContextRelease( context );
    CGColorSpaceRelease( colorSpaceRef );
    
    returnImage = cvCreateImage( cvGetSize( iplImage ), IPL_DEPTH_8U, 3 );
    
    cvCvtColor( iplImage, returnImage, CV_RGBA2BGR);
    cvReleaseImage( &iplImage );
    
    return returnImage;
}

- (UIImage*)UIImageFromIplImage:(IplImage*)image {
    CGColorSpaceRef colorSpace;
    if (image->nChannels == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    }
	else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        cvCvtColor(image, image, CV_BGR2RGB);
    }
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(image->width,
                                        image->height,
                                        image->depth,
                                        image->depth * image->nChannels,
                                        image->widthStep,
                                        colorSpace,
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return ret;
}


@end
