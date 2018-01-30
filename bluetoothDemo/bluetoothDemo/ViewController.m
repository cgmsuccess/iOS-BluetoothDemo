//
//  ViewController.m
//  bluetoothDemo
//
//  Created by gao bin on 2018/1/29.
//  Copyright © 2018年 gao bin. All rights reserved.
//


/********************如果我写的这个demo 不好用，建议使用下面推荐的这个开源demo********************************/
/********************如果我写的这个demo 不好用，建议使用下面推荐的这个开源demo********************************/
/********************如果我写的这个demo 不好用，建议使用下面推荐的这个开源demo********************************/
/********************如果我写的这个demo 不好用，建议使用下面推荐的这个开源demo********************************/

//**********github地址  https://github.com/coolnameismy/BabyBluetooth.git************************//
//**********github地址  https://github.com/coolnameismy/BabyBluetooth.git************************//
//**********github地址  https://github.com/coolnameismy/BabyBluetooth.git************************//
//**********github地址  https://github.com/coolnameismy/BabyBluetooth.git************************//

/***********打印*************/
#ifdef DEBUG
#define BabyLog(format, ...) printf("\n[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define BabyLog(format, ...)
#endif


#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "peripheralCell.h"

// 服务的UUID
#define kServiceUUID @"8001a1d3-3c15-4ffc-bb9c-ba0256c46543"

// 用于 中心读取数据 的特性的UUID
#define kReadCharacteristicUUID @"d82af98b-a121-4dfa-b67a-dabb6fe859ac"

// 用于 中心写数据 的特性的UUID
#define kWriteCharacteristicUUID @"4d7627a6-f72a-43b9-a2cc-ce79ebddac45"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate,CBPeripheralDelegate>

/*  选择的设备   **/
@property (nonatomic,strong) CBPeripheral *selectedPeripheral ;;

/*   选择的服务的特征  **/
@property (nonatomic,strong)  CBCharacteristic *writeCharacteristic;

/*   搜索设备管理类  **/
@property (nonatomic,strong)CBCentralManager *centralManager;

/*   UI相关，tableview 相当于android  listView  **/
@property (strong, nonatomic)  UITableView *tableview;

/*   找到的所有的外设 ---->数组  **/
@property (nonatomic,strong)NSMutableArray *foundPeripheralsArr;

@end

@implementation ViewController

#pragma makr 懒加载
-(UITableView *)tableview
{
    if (!_tableview) {
        _tableview  = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableview.delegate = self;
        _tableview.dataSource = self;
    }
    return _tableview;
}

-(NSMutableArray *)foundPeripheralsArr{
    if (!_foundPeripheralsArr) {
        _foundPeripheralsArr = [NSMutableArray new];
    }
    return _foundPeripheralsArr;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI]; //设置UI

#pragma mark 1. 创建之后会马上检查蓝牙的状态
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
 

    
}



-(void)setUI
{
    [self.tableview registerNib:[UINib nibWithNibName:@"peripheralCell" bundle:nil] forCellReuseIdentifier:@"cell"];

    [self.view addSubview:self.tableview];
}


#pragma mark  2. 这个代理必须实现  检查蓝牙状态 ，是否开启，权限等
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //蓝牙是打开状态
    if (central.state == CBCentralManagerStatePoweredOn) {
        //        搜索外设，这里不允许搜索到重名的。调用该方法的中心就不断的搜索周围的蓝牙设备，需要传入两个参数：
        //        第一个参数是对应设备的UUID，如果出入nil就搜索周围的所有设备,如果出入了指定的UUID就只搜索出入的设备;
        //        第二个参数是一个搜索的配置参数，该参数的具体配置，自己了解还不是很清楚，平时一般出入nil就可以了
        
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        self.title = @"正在扫描外设...";
    }
    else {
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"蓝牙状态异常，请稍后重试" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [aler show];
    }
}

#pragma mark  3. 搜索到的外部设备 发现外设的回调方法
/**
 3. 搜索到的外部设备 发现外设的回调方法
 @param central            第一个参数是当前的中心
 @param peripheral         第二个参数是对应的设备
 @param advertisementData  第三个参数是对应设备蓝牙广播出来的信息
 @param RSSI               第四个参数是设备的蓝牙信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BabyLog(@"central = %@",central);
    BabyLog(@"CBPeripheral = %@",peripheral);
    BabyLog(@"xx-x-x NSDictionary = %@",advertisementData[@"kCBAdvDataLocalName"]);
    BabyLog(@"RSSI = %@",RSSI.description);
    
    int i = 0;
    for (i=0; i<self.foundPeripheralsArr.count; i++) {
        CBPeripheral *foundPeripheral = self.foundPeripheralsArr[i];
        if ([foundPeripheral.identifier isEqual:peripheral.identifier]) {  //避免从复添加
            break;
        }
    }
    
    if (i >= self.foundPeripheralsArr.count) {
        [self.foundPeripheralsArr addObject:peripheral];
    }
    
    [self.tableview reloadData];
    
}

#pragma mark 链接设备成功 5.
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    BabyLog(@"%@", [NSString stringWithFormat:@"成功连接 peripheral: %@ with UUID: %@",peripheral,peripheral.identifier]);
    
    [self.tableview reloadData ];
    
    //链接设备成功后 6。读取设备的服务和 特征 ，注：一个设备可多个服务 一个服务 可 多个 特征,这个时候我们要设置设备的代理因为检索设备的服务和服务下面对应的特征的时候都是通过代理的方式实现的
    self.selectedPeripheral.delegate = self;
    
#pragma mark 6.通过连接成功的设备调用以下方法发现该设备下面的所有服务，返回的蓝牙服务通知通过代理实现
    // *  @see    peripheral:didDiscoverIncludedServicesForService:error:
    //扫描服务 。在代理方法中查看
    [self.selectedPeripheral discoverServices:nil];
    self.title = @"正在连接外设...成功";
}

#pragma mark   断开链接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    KWMLog(@"%@",[NSString stringWithFormat:@"已断开与设备:[%@]的连接", peripheral.name]);
    
    _kiwyModel.peripheral = _selectedPeripheral;
    //没有允许安全带打开时。安全带打开，我们报警
    if ([self.cannectdelegate respondsToSelector:@selector(kwdiscannected:AndModel:)]) {
        [self.cannectdelegate kwdiscannected:_selectedPeripheral AndModel:_kiwyModel];
        
        [KWNotificatioCenter postNotificationName:_kiwyModel.kiwyIndex object:_kiwyModel];
        
    }
    
    _selectedPeripheral.SeatbeltsIsOpen = @"0"; //默认闭合
    _selectedPeripheral.isAgreedOpen = @"1" ;//默认安全带不可打开
    //重新连接
    [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES),CBConnectPeripheralOptionNotifyOnNotificationKey:@(YES)}];
    
    [self.tableview reloadData];
}


#pragma mark 7. 返回的蓝牙服务通知通过代理实现
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    if (error == nil) {
        // 发现外设所有服务里的所有特性
        for (CBService *service in peripheral.services) {
            
            BabyLog(@"service = ---=   %@",service);  //所有的服务打印
           
            //得到对应服务之后通过设备调用以下方法发现服务下面对应的特征,
            //第一个参数指定对应特征的UUID，如果传入则只搜索对应UUID的特征
            // 第二个参数传入需要搜索特征的服务
            [peripheral discoverCharacteristics:nil forService:service]; //查询服务所带的特征值,返回的蓝牙特征值通知通过代理实现 .didDiscoverCharacteristicsForService
        }
    }
    else {
        [self alertMessage:@"发现服务失败"];
        BabyLog(@"发现服务失败%@", error);
    }
}


#pragma mark 8. 调用发现特征方法的时候还需要实现  发现服务里的 特征

//8. 调用发现特征方法的时候还需要实现  发现服务里的 特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{
    
    //获取到自己想要服务下所以得特征。进行读写和订阅操作
    BabyLog(@"severce.characteristics = %@" ,service.characteristics) ;
    BabyLog(@"service.UUID = %@" ,service.UUID) ;//服务uuid
       
    
    ///////////限制自己需要的服务，和 特征。进行订阅和读写
    if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) { //查找此服务
        for (CBCharacteristic *characteristic in service.characteristics) {
          
            // 通知外设，已经准备好接收数据，也就是订阅了这个特性
            [self.selectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
            
          
            //中心写数据
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID]]) {
                // 把写数据的特性保存起来，为了方便给外设发送数据
                self.writeCharacteristic = characteristic;
            }
        }
        self.title = @"开始畅享蓝牙吧";
    }
}

#pragma mark 9.特性里的数据更新了，外设传给我们的数据
// 9.特性里的数据更新了，也就是读取外设里的数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    BabyLog(@"xxxxxxxxxxxxxxxxxxx %@ " , characteristic.value);

    NSString *string = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // 字符串转成CGPoint
    // CGPoint point = CGPointFromString(pointString);
    // 处理外设传过来的数据
    
    
}


#pragma mark 蓝牙代理
//外设断开链接
-(void)centralManager:(nonnull CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error{
    
    BabyLog(@"error 断开链接啦 =%@",error);
    
    [self alertMessage:[NSString stringWithFormat:@"%@",error]];
    [self.tableview reloadData ];
}

// 连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self alertMessage:[NSString stringWithFormat:@"%@",peripheral]];
    [self.tableview reloadData ];
}


-(void)alertMessage:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}



#pragma mark UItableViewDelegate UItableViewDataSorce 代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.foundPeripheralsArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    peripheralCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    CBPeripheral *peripheral = self.foundPeripheralsArr[indexPath.row];
    
     BabyLog(@"peripheral = %@" ,peripheral) ;
    
    cell.peripheral = peripheral ;
    
    return cell ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83 ;
}

#pragma mark  4. 得到了设备后开始链接设备
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *peripheral = self.foundPeripheralsArr[indexPath.row];
    self.selectedPeripheral = peripheral ; //选择链接的设备
    
    // 连接外设
    [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES),CBConnectPeripheralOptionNotifyOnNotificationKey:@(YES)}];
    
    self.title = @"正在连接外设...";
    
}

@end
