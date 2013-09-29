//
//  com_symViewController.m
//  SYM
//
//  Created by HsiuYi on 13/9/17.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "com_symViewController.h"
#import "HTTPDownloader.h"

#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>

@interface com_symViewController ()
- (NSString *)getMacAddress;
@end

@implementation com_symViewController
@synthesize itemTableView = _itemTableView;

#pragma mark - Private method
- (NSString *)getMacAddress {
    //MARKS:取得MAC Address
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

#pragma mark - Public method
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if(nil == items) {
        items =[[NSMutableArray alloc] init];
    } // if
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell =nil;
    cell =[tableView dequeueReusableCellWithIdentifier:@"itemCell"];
    
    NSDictionary* dic =nil;
    dic =items[indexPath.row];
    
    cell.textLabel.text =dic[@"archivePath"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(nil != items) {
        NSLog(@"items count : %d", [items count]);
        return [items count];
    } // if
    else {
        return 0;
    } // else
}


#pragma mark - UI Event Handler
- (IBAction)btnTouched:(id)sender {
    NSString* url =@"http://localhost:8080/symBack/json.txt";
    
    HTTPDownloader* downloader =nil;
    downloader =[[HTTPDownloader alloc] init];
    
    items =[downloader getList:url];
    NSLog(@"items count : %d", [items count]);
    [self.itemTableView reloadData];
}

- (IBAction)testMac_touched:(id)sender {
    NSLog(@"%@", self.getMacAddress);
}

@end
