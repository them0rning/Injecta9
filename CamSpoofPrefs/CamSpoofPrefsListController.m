#import "CamSpoofPrefsListController.h"

#define kPrefDomain    @"com.yourname.camspoof"
#define kFakePhotoPath @"/var/mobile/Library/Application Support/CamSpoof/fake_photo.jpg"
#define kThumbPath     @"/var/mobile/Library/Application Support/CamSpoof/thumb.jpg"
#define kStorageDir    @"/var/mobile/Library/Application Support/CamSpoof"

@implementation CamSpoofPrefsListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

// ── "Choose Photo" button ─────────────────────────────────────────────────────

- (void)choosePhoto {
    if (@available(iOS 14, *)) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite
                                                  handler:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{ [self _presentPicker]; });
        }];
    } else {
        [self _presentPicker];
    }
}

- (void)_presentPicker {
    if (@available(iOS 14, *)) {
        PHPickerConfiguration *cfg = [[PHPickerConfiguration alloc] init];
        cfg.filter = [PHPickerFilter imagesFilter];
        cfg.selectionLimit = 1;
        PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:cfg];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate   = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

// ── "Clear Photo" button ──────────────────────────────────────────────────────

- (void)clearPhoto {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Clear Fake Photo"
                         message:@"Remove the current fake photo?"
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Remove"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction *a) {
        [[NSFileManager defaultManager] removeItemAtPath:kFakePhotoPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:kThumbPath     error:nil];
        [self reloadSpecifiers];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

// ── PHPickerViewControllerDelegate (iOS 14+) ──────────────────────────────────

- (void)picker:(PHPickerViewController *)picker
    didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14)) {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (!results.count) return;

    [results.firstObject.itemProvider
        loadObjectOfClass:[UIImage class]
        completionHandler:^(id<NSItemProviderReading> obj, NSError *err) {
            UIImage *img = (UIImage *)obj;
            if (!img) return;
            dispatch_async(dispatch_get_main_queue(), ^{ [self _savePhoto:img]; });
        }];
}

// ── UIImagePickerControllerDelegate (iOS < 14 fallback) ───────────────────────

- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    if (img) [self _savePhoto:img];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// ── Save helper ───────────────────────────────────────────────────────────────

- (void)_savePhoto:(UIImage *)image {
    [[NSFileManager defaultManager] createDirectoryAtPath:kStorageDir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];

    // Full-res JPEG for the tweak hooks to return
    NSData *jpeg = UIImageJPEGRepresentation(image, 0.95f);
    [jpeg writeToFile:kFakePhotoPath atomically:YES];

    // Small 120×120 thumbnail for the settings preview
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(120, 120), NO, 0);
    [image drawInRect:CGRectMake(0, 0, 120, 120)];
    UIImage *thumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [UIImageJPEGRepresentation(thumb, 0.8f) writeToFile:kThumbPath atomically:YES];

    [self reloadSpecifiers];
}

@end
