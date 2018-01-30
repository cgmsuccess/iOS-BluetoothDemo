//
//  peripheralCell.h
//  CentralTest
//
//  Created by apple on 17/7/18.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface peripheralCell : UITableViewCell


/**
 外设信息
 */
@property (nonatomic,strong)CBPeripheral *peripheral;

@end
