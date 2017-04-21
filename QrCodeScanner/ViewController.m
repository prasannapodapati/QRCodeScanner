//
//  ViewController.m
//  QrCodeScanner
//
//  Created by Prasanna on 20/04/17.
//  Copyright © 2017 Prasanna. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,assign)BOOL readindStarted;
@property (nonatomic,strong)NSString *strScannedQRCode;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.scannedQrCode setHidden:YES];
    [self.qrScanningView setHidden:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-QR scanner
- (IBAction)startQRScanningSelected:(id)sender {
    
    if (!self.readindStarted) {
        if ([self startReading]) {
            [self.qrScanningView setHidden:NO];
            [self.qrScanningButton setTitle:@"Stop Scanning" forState:UIControlStateNormal];
        }
    }
    else{
        [self.captureSession stopRunning];
        self.captureSession = nil;
        [self.videoPreviewLayer removeFromSuperlayer];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopReading) object:nil];
        
        [self.qrScanningButton setTitle:@"Start Scanning" forState:UIControlStateNormal];
    }
    
    self.readindStarted = !self.readindStarted;
}

//- (IBAction)startStopReading:(id)sender
//{
//    if (!self.readindStarted) {
//        if ([self startReading]) {
//            [self.qrScanningButton setTitle:@"Stop Scanning" forState:UIControlStateNormal];
//        }
//    }
//    else{
//        [self.captureSession stopRunning];
//        self.captureSession = nil;
//        [self.videoPreviewLayer removeFromSuperlayer];
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopReading) object:nil];
//        
//        [self.qrScanningButton setTitle:@"Start Scanning" forState:UIControlStateNormal];
//    }
//    
//    self.readindStarted = !self.readindStarted;
//}

- (BOOL)startReading {
    self.strScannedQRCode = nil;
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            [self.videoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [self.videoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [self.videoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [self.videoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            break;
        default:break;
    }
    
    
    [self.videoPreviewLayer setFrame:self.viewPreview.layer.bounds];
    [self.viewPreview.layer addSublayer:self.videoPreviewLayer];
    
    [self.captureSession startRunning];
    //[self performSelector:@selector(stopReading) withObject:nil afterDelay:15.0f];
    
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (self.videoPreviewLayer)
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        switch (orientation) {
            case UIInterfaceOrientationPortrait:
                [self.videoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                [self.videoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
                break;
            case UIInterfaceOrientationLandscapeLeft:
                [self.videoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
                break;
            case UIInterfaceOrientationLandscapeRight:
                [self.videoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
                break;
            default:break;
        }
    }
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            self.readindStarted = NO;
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            
            [self performSelectorOnMainThread:@selector(checkScannedQRCodeWith:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopReading) object:nil];
        }
    }
    else
    {
        
    }
}


-(void)stopReading{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopReading) object:nil];
    
    if ( self.readindStarted == YES) {
        
        float iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
        
        if (iOSVersion < 8.0f)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message: @"Failed to scan QR Code" delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            
            UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"Failed" message:@"Failed to scan QR Code" preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction  *action)
                                       {
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                           
                                       }];
            
            [alert addAction:noButton];
            [self presentViewController:alert animated:YES completion:nil];
            
    }
    [self.videoPreviewLayer removeFromSuperlayer];
    [self.qrScanningButton setTitle:@"Start Scanning" forState:UIControlStateNormal];
    [self.captureSession stopRunning];
    self.captureSession = nil;
    [self.qrScanningView setHidden:YES];
   
    }
}

-(void)checkScannedQRCodeWith:(NSString*)qrcode
{
    [self.qrScanningView setHidden:YES];
    [self.scannedQrCode setHidden:NO];
    self.scannedQrCode.text = qrcode;
    
}
@end
