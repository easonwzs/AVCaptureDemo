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

void CEncoder::UintToData(int length,std::vector<unsigned char> &data)
{
  unsigned char first[INT_SIZE_32];
  unsigned char second[INT_SIZE_32];
  memset(first, 0, INT_SIZE_32);
  memset(second, 0, INT_SIZE_32);
  
  memcpy(first, &length, INT_SIZE_32);
 
  ChangeOrder(4, first);
  
  data.insert(data.begin(), first, first +INT_SIZE_32);
  
}
void CEncoder::ChangeOrder( int loop,unsigned char *change)
{
  unsigned char first[INT_SIZE_32];
  memset(first, 0, INT_SIZE_32);
  
  memcpy(first, change, INT_SIZE_32);
  
  while (loop>0) {
    loop --;
    *change = first[loop];
    if (loop != 0) {
      change ++;
    }
  }
  
}