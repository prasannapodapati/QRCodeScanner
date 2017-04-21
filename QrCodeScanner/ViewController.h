//
//  ViewController.h
//  QrCodeScanner
//
//  Created by Prasanna on 20/04/17.
//  Copyright © 2017 Prasanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UIView *qrScanningView;
@property (weak, nonatomic) IBOutlet UIButton *qrScanningButton;
- (IBAction)startQRScanningSelected:(id)sender;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic,strong)AVAudioPlayer *audioPlayer;
-(BOOL)startReading;
-(void)stopReading;
@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UILabel *scannedQrCode;

@end

