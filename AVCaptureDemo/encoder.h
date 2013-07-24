//
//  encoder.h
//  AVCaptureDemo
//
//  Created by Eason Wang on 7/23/13.
//  Copyright (c) 2013 Eason Wang. All rights reserved.
//

#ifndef __AVCaptureDemo__encoder__
#define __AVCaptureDemo__encoder__

#include <iostream>
#include <string>
#include <vector>
#endif /* defined(__AVCaptureDemo__encoder__) */

class CEncoder
{
public:
  CEncoder();
  /*
   *将数据的长度转换为4字节
   */
  void UintToData(int length,std::vector<unsigned char> &data);
  void ChangeOrder( int loop,unsigned char *change);

};