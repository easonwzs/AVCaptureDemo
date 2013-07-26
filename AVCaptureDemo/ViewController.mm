//
//  ViewController.m
//  AVCaptureDemo
//
//  Created by Eason Wang on 7/22/13.
//  Copyright (c) 2013 Eason Wang. All rights reserved.
//

#import "ViewController.h"
#import "QServer.h"
#import "PPUtil.h"
#import <iostream>
static NSString * domain = @"local.";
static NSString * kWiTapBonjourType = @"_witap2._udp.";


@interface ViewController ()

-(AVCaptureDevice *)getCamera;

@end

@implementation ViewController
@synthesize deviceName = _deviceName;
@synthesize showView = _showView;
@synthesize CDevice = _CDevice;
@synthesize device = _device;
@synthesize avCaptureDevice = _avCaptureDevice;
@synthesize avCaptureSession = _avCaptureSession;
@synthesize server = _server;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize streamOpenCount = _streamOpenCount;
@synthesize localService = _localService;
@synthesize services = _services;
@synthesize browser = _browser;
//@synthesize bytesLen = _bytesLen;
//s
@synthesize name = _name;
@synthesize videoData = _videoData;
//@synthesize dataLen = _dataLen;
@synthesize dataBuffer = _dataBuffer;
@synthesize startButton = _startButton;
@synthesize stopButton = _stopButton;
@synthesize status = _status;
@synthesize theNews = _theNews;
//@synthesize imageView = _imageView;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  
  self.services = [[NSMutableArray alloc]init];
  isFirstFourBytes = YES;
  // 初始化 startButton、stopButton 不可操作
  [self.startButton setUserInteractionEnabled:NO];
  [self.stopButton setUserInteractionEnabled:NO];
  //为状态设置圆角
  [[self.status layer]setCornerRadius:17.0];//圆角
  [self redStatus];
  
  //初始化服务
  self.server = [[QServer alloc]initWithDomain:domain type:kWiTapBonjourType name:nil preferredPort:0];
  self.server.delegate = self;
  [self.server start];
  
  //如果服务撤销注册则重新注册
  if (self.server.isDeregistered) {
    [self.server reregister];
  }
  
  if (self.server.registeredName != nil) {
    [self startServer];
  }
  
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


#pragma Status open & close
// 绿色代表传输
- (void)greenStatus
{
  [self.status setBackgroundColor:[UIColor greenColor]];
}
// 红色代表停止传输
- (void)redStatus
{
  [self.status setBackgroundColor:[UIColor redColor]];
}


- (void)setChoosDevice
{
    uint8_t *dd = [PPUtil dataPackage:nil];
    [self send:dd length:4];
}

-(IBAction)chooseDevice:(id)sender
{
  UISwitch *switchButton = (UISwitch *)sender;
  BOOL isButtonOn = [switchButton isOn];
  if (isButtonOn) {
    NSLog(@"是");
    //为保证
    [self.DSwitch setUserInteractionEnabled:NO];
    // 开启 startButton 可操作
    [self.startButton setUserInteractionEnabled:YES];
    NSNetService *service = [self.services objectAtIndex:0];
    [self connectToService:service];
    
//    [self performSelector:@selector(setChoosDevice) withObject:nil afterDelay:1.5f];
  }else{
    NSLog(@"否");
  }
}


// 打开影音捕获设备
- (IBAction)startTransportData:(id)sender
{
  // 状态为绿色，开启视频
  [self greenStatus];
  
  //开启 stopButton 可操作
  [self.stopButton setUserInteractionEnabled:YES];
  // switch 不可操作
  [self.DSwitch setUserInteractionEnabled:NO];
  
  
  if (self.avCaptureSession || self.avCaptureDevice) {
    return;
  }
  //获取摄像头
  if ((self.avCaptureDevice = [self getCamera]) == nil) {
    return;
  }
  
  NSError *error;
  AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.avCaptureDevice error:&error];
  if (!videoInput) {
    NSLog(@"%@",error);
    self.avCaptureDevice = nil;
    return;
  }

  
  
  AVCaptureVideoDataOutput * output = [[AVCaptureVideoDataOutput alloc]init];
  NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                            
                            [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                            [NSNumber numberWithInt:240], (id)kCVPixelBufferWidthKey,
                            [NSNumber numberWithInt:320], (id)kCVPixelBufferHeightKey,
                            nil];
  output.videoSettings = settings;
  
  dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
  [output setSampleBufferDelegate:self queue:queue];
  
  self.avCaptureSession = [[AVCaptureSession alloc]init];
  self.avCaptureSession.sessionPreset = AVCaptureSessionPresetLow;
  [self.avCaptureSession addInput:videoInput];
  [self.avCaptureSession addOutput:output];
  
  
  AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.avCaptureSession];
  previewLayer.frame = self.showView.bounds;
  previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  [self.showView.layer addSublayer:previewLayer];
  
  [self.avCaptureSession startRunning];
}

// 关闭视频设备
- (IBAction)stopTransportData:(id)sender
{
  [self redStatus];
  // 开启 switch 可操作
  [self.DSwitch setUserInteractionEnabled:YES];
  
  
  if (self.avCaptureSession) {
    [self.avCaptureSession stopRunning];
    self.avCaptureSession = nil;
  }
  
  self.avCaptureDevice = nil;
  // 移除 showView 里的内容
  for (UIView *view in self.showView.subviews) {
    [view removeFromSuperview];
  }

  uint8_t *dd = [PPUtil dataPackage:nil ];
  [self send:dd length:4];
}

#pragma AVCapture Camera
-(AVCaptureDevice *)getCamera
{
  /*获取摄像头设备
   * AVMediaTypeVideo 为视频摄像类型
   */
  NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  
  for (AVCaptureDevice *cap in cameras) {
    //后置摄像头
    if (cap.position == AVCaptureDevicePositionBack) {
      return cap;
    }
  }
  return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}
#pragma AVCaptureVideoDataOutputSampleBufferDelegate
//捕获数据(一帧一帧的图片)
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{

  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  
  // lock the buffer
  if (CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    uint8_t *baseAddress = (uint8_t*)CVPixelBufferGetBaseAddress(imageBuffer);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
    
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    // 为了给监视端一定的解析数据的时间 进程等待
//    [NSThread sleepForTimeInterval:0.1f];
    
    uint8_t *dd = [PPUtil dataPackage:data];
    [self send:dd length:([data length] +4)];
  }
}

- (void)dataToImage:(NSMutableData *)data
{
  [self greenStatus];
  UIImage *img = [UIImage imageWithData:data];
  UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(0 , 0, 229, 282)];
  [imageV setImage:img];
  if (self.showView.subviews) {
    for (UIImageView *imageView in self.showView.subviews) {
      [imageView removeFromSuperview];
    }
  }
  [self.showView addSubview:imageV];
  NSLog(@"subViews == %d",self.showView.subviews.count);
}

#pragma QServer delegate
-(void)serverDidStart:(QServer *)server
{
  [self startServer];
}
- (id)server:(QServer *)server connectionForInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
  id  result;
  
  assert(server == self.server);
#pragma unused(server)
  assert(inputStream != nil);
  assert(outputStream != nil);
  
  assert( (self.inputStream != nil) == (self.outputStream != nil) );      // should either have both or neither
  
  if (self.inputStream != nil) {
    
    result = nil;
  } else {
    
    [self.server deregister];
    
    
    self.inputStream  = inputStream;
    self.outputStream = outputStream;
    
    [self openStreams];
    
    result = self;
  }

  return result;
}
#pragma Server
// 开启服务，并在网络上搜索服务
- (void)startServer
{
  self.localService = [[NSNetService alloc]initWithDomain:domain type:kWiTapBonjourType name:self.server.registeredName];
  assert(self.services.count ==0);
  assert(self.browser == nil);
  
  // 配置浏览
  self.browser = [[NSNetServiceBrowser alloc]init];
  [self.browser setDelegate:self];
  //在局域网查找设备
  [self.browser searchForServicesOfType:kWiTapBonjourType inDomain:domain];
  
}

// 与获取到的地址进行联接
- (void)connectToService:(NSNetService *)service
{
  BOOL success;
  NSInputStream *inStream;
  NSOutputStream *outStream;
  
  assert(service != nil);
  assert(self.inputStream == nil);
  assert(self.outputStream == nil);
  
  success = [service getInputStream:&inStream outputStream:&outStream];
  if (!success) {
    NSLog(@"打开 I/O 流失败");
  }else{
    self.inputStream = inStream;
    self.outputStream = outStream;
    
    [self openStreams];
  }
}
//发送数据
- (void)send:(const uint8_t *)data length:(NSUInteger)len
{
  assert(self.streamOpenCount == 2);
  
  if ( [self.outputStream hasSpaceAvailable] ) {
    NSInteger   bytesWritten;
    
    bytesWritten = [self.outputStream write:data maxLength:len];
    NSLog(@"实际发送的数据长度==%d",bytesWritten);
    if (bytesWritten != len) {
      NSLog(@"发送数据失败！");
    }
  }
}

// 打开 I/O 流
- (void)openStreams
{
  assert(self.inputStream != nil);
  assert(self.outputStream != nil);
  assert(self.streamOpenCount ==0);
  
  [self.inputStream setDelegate:self];
  [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [self.inputStream open];
  
  [self.outputStream setDelegate:self];
  [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [self.outputStream open];
}
// 关闭 I/O 流
- (void)closeStreams
{
  assert( (self.inputStream != nil) == (self.outputStream != nil) );
  if (self.inputStream != nil) {
    [self.server closeOneConnection:self];
    
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream close];
    self.inputStream = nil;
    
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream close];
    self.outputStream = nil;
  }
  self.streamOpenCount = 0;
}
#pragma Stream delegate
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
  switch (eventCode) {
    case NSStreamEventOpenCompleted:
      self.streamOpenCount += 1;
      assert(self.streamOpenCount <= 2);
      if (self.streamOpenCount == 2) {
        //打开输入输出流后注销当前服务
        [self.server deregister];
      }
      break;
      
    case NSStreamEventHasSpaceAvailable:
      assert(aStream == self.outputStream);
      break;
      
    case NSStreamEventHasBytesAvailable:
      //读取前四个字节取得参数长度
      if (isFirstFourBytes) {
        
        [self greenStatus];
        
        uint8_t bufferLen[4];
        assert(aStream == self.inputStream);
        if ([self.inputStream read:bufferLen maxLength:4]==4) {
          [self redStatus];
          //取得参数长度
          remainingToRead = ((bufferLen[0]<<24)&0xff000000)+((bufferLen[1]<<16)&0xff0000)+((bufferLen[2]<<8)&0xff00)+(bufferLen[3] & 0xff);
          NSLog(@"总参数长度==%d",remainingToRead);
          isFirstFourBytes = NO;
        }else{
          [self closeStreams];
        }
        
      }else{//根据数据包的大小读取数据
        int actuallyRead;
        uint8_t buffer[51200];//50KB的缓冲区，缓冲区太小的话会明显影响真机上的通信速度
        if (!self.dataBuffer) {
          self.dataBuffer = [[NSMutableData alloc]init];
        }
        actuallyRead = [self.inputStream read:buffer maxLength:sizeof(buffer)];
        NSLog(@"实际取得长度==%d",actuallyRead);
        if (actuallyRead == -1) {
          [self closeStreams];
        }else if (actuallyRead == 0){
          
        }else if (actuallyRead == 4){
          // 如果为 4 说明采集端已关闭
          remainingToRead = 0;
          isFirstFourBytes = YES;
          self.dataBuffer = nil;
          [self redStatus];
          break;
        }else{
          // 将得到的数据附加一起
          [self.dataBuffer appendBytes:buffer length:actuallyRead];
          remainingToRead -= actuallyRead;
          NSLog(@"剩余长度==%d",remainingToRead);
        }
        if (remainingToRead == 0) {
          isFirstFourBytes = YES;
          // 数据接受完毕，处理数据
          [self dataToImage:self.dataBuffer];
          self.dataBuffer = nil;
        }
        
      }
      
      break;
    default:
      assert(NO);
      
      //无法连接或断开连接
    case NSStreamEventErrorOccurred:
      //连接断开或结束
    case NSStreamEventEndEncountered: {
      
    } break;
  }
}


#pragma NSNetServiceBrowserDelegate
-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
  assert(self.browser == aNetServiceBrowser);
  assert(aNetService != nil);
  
  if ((self.localService == nil) || ![self.localService isEqual:aNetService]) {
    self.deviceName.text = aNetService.name;
    [self.services addObject:aNetService];
  }
}
-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
  
  
}

@end
