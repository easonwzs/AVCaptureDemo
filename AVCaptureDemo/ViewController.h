//
//  ViewController.h
//  AVCaptureDemo
//
//  Created by Eason Wang on 7/22/13.
//  Copyright (c) 2013 Eason Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CFNetwork/CFNetwork.h>
#import "QServer.h"
@interface ViewController : UIViewController<
    AVCaptureVideoDataOutputSampleBufferDelegate,
    QServerDelegate,
    NSNetServiceBrowserDelegate,
    NSStreamDelegate
>
{
  UILabel *_deviceName;
  
  //视频流
  UIView *_showView;
  UISwitch *_CDevice;
  UILabel *_device;
  AVCaptureDevice *_avCaptureDevice;
  AVCaptureSession *_avCaptureSession;
  NSUInteger _bytesLen;
  NSString *_name;
  NSData *_videoData;
  NSUInteger _dataLen;
  
  
  //网络连接
  BOOL isFirstFourBytes;
  QServer *_server;
  NSMutableArray *_services;
  NSNetService *_localService;
  NSNetServiceBrowser *_browser;
  NSInputStream *_inputStream;
  NSOutputStream *_outputStream;
  NSUInteger _streamOpenCount;
  NSMutableData *_dataBuffer;
  int remainingToRead ;
}
@property (nonatomic, strong, readwrite) IBOutlet UILabel *deviceName;

@property (nonatomic, assign, readwrite) NSUInteger bytesLen;
@property (nonatomic, strong, readwrite) AVCaptureSession *avCaptureSession;
@property (nonatomic, strong, readwrite) AVCaptureDevice *avCaptureDevice;
@property (nonatomic, strong, readwrite) IBOutlet UIView *showView;
@property (nonatomic, strong, readwrite) IBOutlet UISwitch *CDevice;
@property (nonatomic, strong, readwrite) IBOutlet UILabel *device;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSData *videoData;
@property (nonatomic, assign, readwrite) NSUInteger dataLen;

@property (nonatomic, strong, readwrite) QServer *server;
@property (nonatomic, strong, readwrite) NSMutableArray *services;
@property (nonatomic, strong, readwrite) NSNetService *localService;
@property (nonatomic, strong, readwrite) NSNetServiceBrowser *browser;
@property (nonatomic, strong, readwrite) NSInputStream *inputStream;
@property (nonatomic, strong, readwrite) NSOutputStream *outputStream;
@property (nonatomic, assign, readwrite) NSUInteger streamOpenCount;
@property (nonatomic, strong, readwrite) NSMutableData *dataBuffer;

- (IBAction)startTransportData:(id)sender;
- (IBAction)stopTransportData:(id)sender;
- (IBAction)chooseDevice:(id)sender;
@end
