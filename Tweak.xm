#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static NSString * const kAPI = @"https://svkeyvdung.shopaccvt.site/api/verify.php";
static NSString * const kAppID = @"vdungzproject";
static NSString * const kSavedKey = @"VDUNGZKeyGate.SavedKey";
static NSString * const kDeviceID = @"VDUNGZKeyGate.DeviceID";
static BOOL gPromptVisible = NO;
static BOOL gChecking = NO;

static NSString *DeviceID(void) {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *v = [d stringForKey:kDeviceID];
    if (!v.length) {
        v = NSUUID.UUID.UUIDString;
        [d setObject:v forKey:kDeviceID];
        [d synchronize];
    }
    return v;
}

static UIViewController *TopController(void) {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState != UISceneActivationStateForegroundActive) continue;
            if (![scene isKindOfClass:UIWindowScene.class]) continue;
            for (UIWindow *w in ((UIWindowScene *)scene).windows) {
                if (w.isKeyWindow) { window = w; break; }
            }
            if (window) break;
        }
    }
    if (!window) window = UIApplication.sharedApplication.keyWindow;
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) vc = vc.presentedViewController;
    return vc;
}

static void ShowKeyPrompt(void);

static void VerifyKey(NSString *key) {
    if (gChecking) return;
    gChecking = YES;
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kAPI]
                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                   timeoutInterval:20.0];
    req.HTTPMethod = @"POST";
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{
        @"app_id": kAppID,
        @"key": key ?: @"",
        @"device_id": DeviceID()
    } options:0 error:nil];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = nil;
        if (data) json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        BOOL ok = !error && [response isKindOfClass:NSHTTPURLResponse.class] && ((NSHTTPURLResponse *)response).statusCode == 200 && [json[@"ok"] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            gChecking = NO;
            if (ok) {
                [[NSUserDefaults standardUserDefaults] setObject:key forKey:kSavedKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                gPromptVisible = NO;
                return;
            }
            NSString *message = [json[@"message"] isKindOfClass:NSString.class] ? json[@"message"] : @"Không kết nối được máy chủ xác thực.";
            UIViewController *vc = TopController();
            if (vc) {
                UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Key không hợp lệ" message:message preferredStyle:UIAlertControllerStyleAlert];
                [a addAction:[UIAlertAction actionWithTitle:@"Thử lại" style:UIAlertActionStyleDefault handler:^(UIAlertAction *x) { gPromptVisible = NO; ShowKeyPrompt(); }]];
                [vc presentViewController:a animated:YES completion:nil];
            } else {
                gPromptVisible = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ ShowKeyPrompt(); });
            }
        });
    }] resume];
}

static void ShowKeyPrompt(void) {
    if (gPromptVisible || gChecking) return;
    UIViewController *vc = TopController();
    if (!vc || vc.isBeingPresented || vc.isBeingDismissed) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ ShowKeyPrompt(); });
        return;
    }
    gPromptVisible = YES;
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"VDUNGZ — Nhập key" message:@"Nhập key được cấp để xác thực ứng dụng." preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField *f) {
        f.placeholder = @"XXXX-XXXX-XXXX-XXXX";
        f.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        f.autocorrectionType = UITextAutocorrectionTypeNo;
        f.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    UIAlertAction *verify = [UIAlertAction actionWithTitle:@"Xác thực" style:UIAlertActionStyleDefault handler:^(UIAlertAction *x) {
        NSString *key = [a.textFields.firstObject.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        gPromptVisible = NO;
        if (key.length) VerifyKey(key); else ShowKeyPrompt();
    }];
    verify.enabled = YES;
    [a addAction:verify];
    // No cancel action: the app remains behind the required key prompt.
    [vc presentViewController:a animated:YES completion:nil];
}

%ctor {
    @autoreleasepool {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n) {
            if (![[NSUserDefaults standardUserDefaults] stringForKey:kSavedKey]) ShowKeyPrompt();
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (![[NSUserDefaults standardUserDefaults] stringForKey:kSavedKey]) ShowKeyPrompt();
        });
    }
}
