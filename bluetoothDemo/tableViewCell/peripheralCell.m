//
//  peripheralCell.m
//  CentralTest
//
//  Created by apple on 17/7/18.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "peripheralCell.h"
@interface peripheralCell()

@property (weak, nonatomic) IBOutlet UILabel *CBPeripheralLabel;  //设备地址 0x1276997e0
@property (weak, nonatomic) IBOutlet UILabel *identifierLabel; //编号
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;//名字
@property (weak, nonatomic) IBOutlet UILabel *stateLabel; ///链接状态，是否链接

@end

@implementation peripheralCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

/*
             断开连接
             CBPeripheralStateDisconnected = 0,
             正在连接
             CBPeripheralStateConnecting,
             已经连接
             CBPeripheralStateConnected,
             正在断开连接
             CBPeripheralStateDisconnecting
 */


-(void)setPeripheral:(CBPeripheral *)peripheral
{
    _peripheral = peripheral ;
    //标示
    self.identifierLabel.text = [NSString stringWithFormat:@"identifier:%@",[peripheral.identifier UUIDString]]  ;
    //名称
    self.nameLabel.text = [NSString stringWithFormat:@"name:%@",peripheral.name];
   
    //链接状态
    NSString *state  = [NSString stringWithFormat:@"%ld",peripheral.state];
    
    NSLog(@"state = %@" ,state) ;
    
    if ([state isEqualToString:@"0"]) {
        self.stateLabel.text = @"断开连接";
    }else if([state isEqualToString:@"1"]){
        self.stateLabel.text = @"正在连接";
    }else if([state isEqualToString:@"2"]){
        self.stateLabel.text = @"已经连接";
    }else{
        self.stateLabel.text = @"正在断开连接";
    }

}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
