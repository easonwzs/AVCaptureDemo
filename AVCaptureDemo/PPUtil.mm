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
  unsigned int length = [data length];
  
 std::vector<unsigned char>V ;
  
  CEncoder *e = new CEncoder();
  e->UintToData(length, V);
  NSMutableData  *newData = [[NSMutableData alloc]init];
  for (int i = 0; i< V.size();  i++) {
    [newData appendBytes:&V[i] length:1];
  }
  [newData appendData:data];
  
  uint8_t *dd = (uint8_t *)[newData bytes];
  return dd;
}


@end
