// Copyright 2017-present, Facebook, Inc.
// All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Platform Policy
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import <MediaPlayer/MediaPlayer.h>

#import <FBSDKShareKit/FBSDKShareKit.h>

#import "ViewController.h"

@interface ViewController () <MPMediaPickerControllerDelegate, FBSDKSharingDelegate> {
  IBOutlet UIButton *_playPauseButton;
  IBOutlet UIImageView *_albumImageView;
  IBOutlet UILabel *_titleLabel;
  IBOutlet UILabel *_artistLabel;

  MPMusicPlayerController *_mediaPlayer;
}

- (IBAction)_chooseSong:(id)sender;
- (IBAction)_playPause:(id)sender;
- (IBAction)_shareToCameraEffect:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
  _albumImageView.backgroundColor = [UIColor whiteColor];
  _mediaPlayer = [MPMusicPlayerController systemMusicPlayer];
  [_playPauseButton.titleLabel setText:@"Play"];
}

#pragma mark - IBActions

- (IBAction)_chooseSong:(id)sender
{
  MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
  mediaPicker.prompt = @"Choose a Song";
  mediaPicker.delegate = self;

  [self presentViewController:mediaPicker animated:YES completion:^{}];
}

- (IBAction)_playPause:(id)sender
{
  if (_mediaPlayer.playbackState == MPMusicPlaybackStatePlaying) {
    [_mediaPlayer pause];
  } else {
    [_mediaPlayer play];
  }
}

/**
 * Share the song information to the camera effect.
 */
- (IBAction)_shareToCameraEffect:(id)sender
{
  FBSDKCameraEffectTextures *textures = [FBSDKCameraEffectTextures new];
  [textures setImage:_albumImageView.image forKey:@"albumArtTexture"];

  FBSDKCameraEffectArguments *arguments = [FBSDKCameraEffectArguments new];
  [arguments setString:_titleLabel.text forKey:@"title"];
  [arguments setString:_artistLabel.text forKey:@"artist"];

  FBSDKShareCameraEffectContent *shareContent = [FBSDKShareCameraEffectContent new];
  shareContent.effectArguments = arguments;
  shareContent.effectTextures = textures;
    shareContent.effectID = @"405837659846580"; // Fill in your effect ID once it is uploaded

  FBSDKShareDialog *shareDialog = [FBSDKShareDialog new];
  shareDialog.shareContent = shareContent;
  shareDialog.fromViewController = self;
  shareDialog.delegate = self;
  if ([shareDialog canShow]) {
    [shareDialog show];
  } else {
    NSLog(@"Facebook app is not installed!");
  }
}

#pragma mark - MPMediaPickerControllerDelegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker
   didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
  if (mediaItemCollection) {
    [_mediaPlayer setQueueWithItemCollection:mediaItemCollection];
    [_mediaPlayer play];

    MPMediaItem *song = [[mediaItemCollection items] firstObject];
    _titleLabel.text = [song valueForProperty:MPMediaItemPropertyTitle];
    _artistLabel.text = [song valueForProperty:MPMediaItemPropertyArtist];

    MPMediaItemArtwork *artwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    if (artwork) {
      _albumImageView.image = [artwork imageWithSize:_albumImageView.frame.size];
    }
  } else {
    _titleLabel.text = @"Title";
    _artistLabel.text = @"Artist";
    _albumImageView.image = nil;
  }
  [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
  [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - FBSDKSharingDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
  NSLog(@"Share Success: %@", results);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
  NSLog(@"Share Error: %@", error);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
  NSLog(@"Share Cancelled");
}

@end
