//
//  PPUtil.m
//  AVCaptureDemo
//
//  Created by Eason Wang on 7/23/13.
//  Copyright (c) 2013 Eason Wang. All rights reserved.
//

#import "PPUtil.h"
#import "encoder.h"
@implementation PPUtil


+(uint8_t *)dataPackage:(NSData *)data
{
  unsigned int len = 0;
  if ((data != nil) && ([data length] != 0)) {
    len = [data length];
  }
   
 std::vector<unsigned char>V;
  
  CEncoder *e = new CEncoder();
  e->UintToData(len, V);
  NSMutableData  *newData = [[NSMutableData alloc]init];
  for (int i = 0; i< V.size();  i++) {
    [newData appendBytes:&V[i] length:1];
  }
  if (([data length]!=0) && (data != nil)) {
    [newData appendData:data];
  }
  
//  NSLog(@"%@",newData);
  uint8_t *dd = (uint8_t *)[newData bytes];
  return dd;
}


@end
