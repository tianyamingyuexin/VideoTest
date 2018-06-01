//
//  ViewController.m
//  VideoTest
//
//  Created by guangshu01 on 2018/5/28.
//  Copyright © 2018年 guangshu01. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoMessageLabel;
@property (nonatomic,assign)BOOL isImagePicker;
@property (nonatomic,strong)NSString *filePath;
@property (nonatomic,strong)NSString *imagePath;
@property (nonatomic,strong)NSString *pingUploadUrlString;
@property (nonatomic,assign)NSInteger timeSecond;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%@",NSHomeDirectory());
}
- (IBAction)getVideo:(UIButton *)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *ipc=[[UIImagePickerController alloc] init];
        ipc=[[UIImagePickerController alloc] init];
        ipc.delegate=self;
        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        ipc.videoQuality = UIImagePickerControllerQualityTypeMedium;
        ipc.mediaTypes = [NSArray arrayWithObjects:@"public.movie", nil];
        [self presentViewController:ipc animated:YES completion:nil];
        _isImagePicker = YES;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.movie"])
    {
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        AVURLAsset *asset = [AVURLAsset assetWithURL:videoUrl];
        NSString  *videoPath =  info[UIImagePickerControllerMediaURL];
        
        NSLog(@"相册视频路径是：%@",videoPath);
        
        
        //第一中方法，通过路径直接copy
        
//        //删除原来的 防止重复选
//                [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
//                [[NSFileManager defaultManager] removeItemAtPath:_imagePath error:nil];
//                NSDateFormatter *formater = [[NSDateFormatter alloc] init];
//                [formater setDateFormat:@"yy-MM-dd-HH:mm:ss"];
//
//                _filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", [[formater stringFromDate:[NSDate date]] stringByAppendingString:@".mp4"]];
//
//
//                NSString  *videoPath =  info[UIImagePickerControllerMediaURL];
//
//                NSFileManager *fileManager = [NSFileManager defaultManager];
//
//                NSError *error;
//                [fileManager copyItemAtPath:videoPath toPath:_filePath error:&error];
//                if (error)
//                {
//
//                    NSLog(@"文件保存到缓存失败");
//                }
//
//                [self getSomeMessageWithFilePath:_filePath];
        
        
        //第二种方法，进行视频导出
                [self startExportVideoWithVideoAsset:asset completion:^(NSString *outputPath) {
        
                    [self getSomeMessageWithFilePath:_filePath];
        
                }];;
        
        
        
    }
    _isImagePicker = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}
//获取视频第一帧
- (void)getSomeMessageWithFilePath:(NSString *)filePath
{
    
    
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:fileUrl];
    
    
    NSString *duration = [NSString stringWithFormat:@"%0.0f", ceil(CMTimeGetSeconds(asset.duration))];
    _videoImageView.image = [self getImageWithAsset:asset];
//    _image = _imageView.image;
    _timeSecond = duration.integerValue;
    _videoMessageLabel.text = [NSString stringWithFormat:@"时长是:%ld",(long)_timeSecond];
    NSLog(@"时长是：%@",duration);
}

- (UIImage *)getImageWithAsset:(AVAsset *)asset
{
    AVURLAsset *assetUrl = (AVURLAsset *)asset;
    NSParameterAssert(assetUrl);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:assetUrl];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = 0;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

- (void)startExportVideoWithVideoAsset:(AVURLAsset *)videoAsset completion:(void (^)(NSString *outputPath))completion
{
    // Find compatible presets by video asset.
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    
    NSString *pre = nil;
    
    if ([presets containsObject:AVAssetExportPreset3840x2160])
    {
        pre = AVAssetExportPreset3840x2160;
    }
    else if([presets containsObject:AVAssetExportPreset1920x1080])
    {
        pre = AVAssetExportPreset1920x1080;
    }
    else if([presets containsObject:AVAssetExportPreset1280x720])
    {
        pre = AVAssetExportPreset1280x720;
    }
    else if([presets containsObject:AVAssetExportPreset960x540])
    {
        pre = AVAssetExportPreset1280x720;
    }
    else
    {
        pre = AVAssetExportPreset640x480;
    }
    
    // Begin to compress video
    // Now we just compress to low resolution if it supports
    // If you need to upload to the server, but server does't support to upload by streaming,
    // You can compress the resolution to lower. Or you can support more higher resolution.
    if ([presets containsObject:AVAssetExportPreset640x480]) {
        //        AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:videoAsset presetName:AVAssetExportPreset640x480];
        AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:videoAsset presetName:AVAssetExportPreset640x480];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yy-MM-dd-HH:mm:ss"];
        
        NSString *outputPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", [[formater stringFromDate:[NSDate date]] stringByAppendingString:@".mov"]];
        NSLog(@"video outputPath = %@",outputPath);
        //删除原来的 防止重复选
        _timeSecond = 0;
        [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:_imagePath error:nil];
        
        _filePath = outputPath;
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        
        // Optimize for network use.
        session.shouldOptimizeForNetworkUse = true;
        
        NSArray *supportedTypeArray = session.supportedFileTypes;
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
            session.outputFileType = AVFileTypeMPEG4;
        } else if (supportedTypeArray.count == 0) {
            NSLog(@"No supported file types 视频类型暂不支持导出");
            return;
        } else {
            session.outputFileType = [supportedTypeArray objectAtIndex:0];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents"]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
        }
        
        // Begin to export video to the output path asynchronously.
        [session exportAsynchronouslyWithCompletionHandler:^(void) {
            switch (session.status) {
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"AVAssetExportSessionStatusUnknown"); break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"AVAssetExportSessionStatusWaiting"); break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"AVAssetExportSessionStatusExporting"); break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(outputPath);
                        }
                        //                        _videoArray = [VRVideoTool getAllFileNameFormDoucuments];
                        //                        [_tableView reloadData];
                        
                    });
                }  break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"AVAssetExportSessionStatusFailed"); break;
                default: break;
            }
        }];
    }
}


@end
