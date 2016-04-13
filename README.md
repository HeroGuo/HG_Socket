# HG_Socket


现在有如下通信协议，请实现相关函数模块。
此协议是一个二进制协议，每个协议报文由如下数据流构成，数值都以Big-endian大端方式存储：
{ TotalSize[2], Crc32[4], Ver[1], Cmd[1], Data[len] }

方括号中是占用的字节数。具体解释：
TotalSize: 2字节，表示整个报文的长度，这个值应该等于： 2 + 4 + 1 + 1 + len
Crc32: 4字节，表示对 {Ver, Cmd, Data} 内容的 crc32 的校验值
Ver: 1字节，协议版本，目前约定为 0x05
Cmd: 1字节，用户指定的操作命令，0x00 ~ 0xff
Data: len个字节，具体的数据内容

要求：实现一个函数 pack(cmd, data, len)
输入：cmd: 用户指定的操作命令;  data: 用户指定的数据;  len: 数据长度
输出：打包好的协议报文