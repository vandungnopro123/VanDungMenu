#import <UIKit/UIKit.h>

@interface VDMenuController : NSObject
@property(nonatomic,strong) UIButton *bubble;
@property(nonatomic,strong) UIView *panel;
@end

@implementation VDMenuController
- (void)install {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) continue;
            for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {
                if (candidate.isKeyWindow) { window = candidate; break; }
            }
            if (window) break;
        }
        if (!window || self.bubble) return;

        self.bubble = [UIButton buttonWithType:UIButtonTypeSystem];
        self.bubble.frame = CGRectMake(18, 180, 54, 54);
        self.bubble.layer.cornerRadius = 27;
        self.bubble.backgroundColor = [UIColor colorWithRed:0.12 green:0.45 blue:0.95 alpha:0.95];
        [self.bubble setTitle:@"VD" forState:UIControlStateNormal];
        [self.bubble setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        self.bubble.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [self.bubble addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:self.bubble];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragBubble:)];
        [self.bubble addGestureRecognizer:pan];
    });
}
- (void)togglePanel {
    if (self.panel) { [self.panel removeFromSuperview]; self.panel = nil; return; }
    UIWindow *window = self.bubble.window;
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(82, 180, 220, 190)];
    self.panel.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.96];
    self.panel.layer.cornerRadius = 14;
    self.panel.layer.borderWidth = 1;
    self.panel.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;

    UILabel *heading = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, 192, 28)];
    heading.text = @"VAN DUNG MENU";
    heading.textColor = UIColor.whiteColor;
    heading.font = [UIFont boldSystemFontOfSize:16];
    [self.panel addSubview:heading];

    NSArray *items = @[@"Floating menu is active", @"UI demo only", @"Tap VD to close"];
    for (NSInteger i = 0; i < items.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 52 + i*38, 192, 28)];
        label.text = items[i];
        label.textColor = [UIColor colorWithWhite:0.9 alpha:1];
        label.font = [UIFont systemFontOfSize:13];
        [self.panel addSubview:label];
    }
    [window addSubview:self.panel];
}
- (void)dragBubble:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    CGPoint delta = [gesture translationInView:view.superview];
    view.center = CGPointMake(view.center.x + delta.x, view.center.y + delta.y);
    [gesture setTranslation:CGPointZero inView:view.superview];
}
@end

static VDMenuController *vdController;
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        vdController = [VDMenuController new];
        [vdController install];
    });
}
