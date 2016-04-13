//
//  ViewController.m
//  HGSocket
//
//  Created by gjh on 16/4/13.
//  Copyright © 2016年 gjh. All rights reserved.
//

#import "ViewController.h"
#import <zlib.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSData  *callBackData1 =  [self pack:@"HiroGuo" data:@"7"];
    NSData  *callBackData2 =  [self pack:@"HiroGuo_JP" data:@"10"];
    NSLog(@"callBack1:%@",callBackData1);
    NSLog(@"callBack2:%@",callBackData2);
//
//    2016-04-13 13:56:05.231 HGSocket[3522:243588] callBack1:<08000000 00000500 480037>
//    2016-04-13 13:56:05.232 HGSocket[3522:243588] callBack2:<0a004887 99000500 48003100 30>
}


- (NSData *)pack:(NSString *)cmd data:(NSString *)data {
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(NSUTF16BigEndianStringEncoding);
    Byte ver[1] = {0x05};
    NSData *verData = [NSData dataWithBytes:ver length:1];
    
    Byte cmdBytes[2];
    NSData *cmdDataTemp = [cmd dataUsingEncoding:encoding];
    if (cmdDataTemp.length >= 2) {
        for (int i = 0; i < 2; i++) {
            cmdBytes[i] = ((Byte *)[cmdDataTemp bytes])[i];
        }
    } else {
        cmdBytes[0] = ((Byte *)[cmdDataTemp bytes])[0];
    }
    NSData *cmdData = [NSData dataWithBytes:cmdBytes length:2];
    
    NSData *inputData = [data dataUsingEncoding:encoding];
    int datalength = (int)inputData.length;
    NSMutableData *crcData = [NSMutableData data];
    [crcData appendData:verData];
    [crcData appendData:cmdData];
    [crcData appendData:inputData];
    
    int crc;
    crc32(crc, [crcData bytes], (unsigned int)crcData.length);
    unsigned char *pCrc = (unsigned char *)&crc;
    Byte crcBytes[4];
    for (int i = 0; i < 4; i++) {
        crcBytes[i] = *pCrc;
        pCrc++;
    }
    NSData *crc32Data = [NSData dataWithBytes:crcBytes length:4];
    
    int messageLength = datalength + 6;
    Byte lengthBytes[2];
    unsigned char *pLength = (unsigned char *)&messageLength;
    for (int i = 0; i < 2; i++) {
        lengthBytes[i] = *pLength;
        pLength++;
    }
    NSData *lengthData = [NSData dataWithBytes:lengthBytes length:2];
    
    NSMutableData *messageData = [NSMutableData data];
    [messageData appendData:lengthData];
    [messageData appendData:crc32Data];
    [messageData appendData:verData];
    [messageData appendData:cmdData];
    [messageData appendData:inputData];
    
    return [messageData copy];
}



//crc32实现函数
unsigned int CRC32( unsigned char *buf, int len) {
    uint32_t *table = malloc(sizeof(uint32_t) * 256);
    uint32_t crc = 0xffffffff;
    
    for (uint32_t i=0; i<256; i++) {
        table[i] = i;
        for (int j=0; j<8; j++) {
            if (table[i] & 1) {
                table[i] = (table[i] >>= 1) ^ 0xedb88320;
            } else {
                table[i] >>= 1;
            }
        }
    }
    
    for (int i=0; i<len; i++) {
        crc = (crc >> 8) ^ table[crc & 0xff ^ buf[i]];
    }
    crc ^= 0xffffffff;
    
    free(table);
    return crc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
