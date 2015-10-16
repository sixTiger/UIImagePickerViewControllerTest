//
//  ViewController.m
//  UIImagePickerViewControllrtTest
//
//  Created by xiaobing on 15/10/16.
//  Copyright © 2015年 xiaobing. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong,nonatomic) UIImagePickerController    *imagePicker;

/**
 *  用于展示照片的
 */
@property(nonatomic , weak) UIImageView                 *photo;

/**
 *  播放器，用于录制完视频后播放视频
 */
@property (strong ,nonatomic) AVPlayer *player;

- (IBAction)openPhotos:(id)sender;

@end

@implementation ViewController

- (IBAction)openPhotos:(id)sender
{
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}
- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil)
    {
        _imagePicker=[[UIImagePickerController alloc]init];
        //设置image picker的来源，这里设置为摄像头
        _imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        //设置使用哪个摄像头，这里设置为后置摄像头
        _imagePicker.cameraDevice=UIImagePickerControllerCameraDeviceRear;
        _imagePicker.mediaTypes=@[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
        _imagePicker.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;
        //设置摄像头模式（拍照，录制视频）
        _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;
        //允许编辑
        _imagePicker.allowsEditing=YES;
        _imagePicker.delegate=self;
    }
    return _imagePicker;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        //如果是拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (self.imagePicker.allowsEditing)
        {
            image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }
        else
        {
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        [self.photo.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.photo setImage:image];//显示照片
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
    }
    else
    {
        
        if([mediaType isEqualToString:(NSString *)kUTTypeMovie])
        {//如果是录制视频
            NSLog(@"video...");
            NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
            NSString *urlStr=[url path];
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr))
            {
                //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
                UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
            }
            
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error)
    {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }
    else
    {
        NSLog(@"视频保存成功.");
        //录制完之后自动播放
        NSURL *url=[NSURL fileURLWithPath:videoPath];
        _player=[AVPlayer playerWithURL:url];
        AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.frame=self.photo.frame;
        playerLayer.repeatDuration = CGFLOAT_MAX;
        [self.photo.layer addSublayer:playerLayer];
        [_player play];
        
    }
}
#pragma mark - UI
- (UIImageView *)photo
{
    if (_photo == nil)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:imageView atIndex:0];
        imageView.autoresizingMask = (1 << 6) - 1;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        _photo = imageView;
    }
    return _photo;
}
@end
