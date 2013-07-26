//
//  encoder.cpp
//  AVCaptureDemo
//
//  Created by Eason Wang on 7/23/13.
//  Copyright (c) 2013 Eason Wang. All rights reserved.
//

#include "encoder.h"


#define INT_SIZE_32 4


CEncoder::CEncoder(){

}

void CEncoder::UintToData(unsigned int length,std::vector<unsigned char> &data)
{
  unsigned char first[INT_SIZE_32];

  memset(first, 0, INT_SIZE_32);

  memcpy(first, &length, INT_SIZE_32);
  
  int len = (((first[0]<<24)&0xff000000) + ((first[1]<<16)&0xff0000) + ((first[2]<<8)&0xff00) + (first[3]&0xff));
  memset(first, 0, INT_SIZE_32);
  memcpy(first,&len,INT_SIZE_32);
  
  data.insert(data.begin(), first, first +INT_SIZE_32);
  
}
