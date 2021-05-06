#import <UIKit/UIKit.h>
#import "UnityAppController.h"
#import "UnityInterface.h"
#import "UI/UnityView.h"
#import "UI/OrientationSupport.h"
#import "GVROverlayView.h"

enum {
	BTN_ESCAPE = 27
};

struct GVRPlugin;
bool LoadGVRPlugin(GVRPlugin* plugin, const char* pluginName);

@interface UnityGoogleVRCardboardIntegration : NSObject<GVROverlayViewDelegate>
{
}
@end

@implementation UnityGoogleVRCardboardIntegration
{
	GVROverlayView* overlayView;
}

+ (instancetype) singleton
{
	static id instance = nil;
	static dispatch_once_t onceTag;
	dispatch_once(&onceTag, ^{ instance = [self new]; });
	return instance;
}

+ (void) onVRChangedEnableStatus:(NSNumber*) enabled
{
	if ([enabled integerValue])
		[[UnityGoogleVRCardboardIntegration singleton] onVREnabled];
	else
		[[UnityGoogleVRCardboardIntegration singleton] onVRDisabled];
}

+ (NSNumber*) loadPlugin:(NSValue*) plugin withName:(NSValue*) pluginName
{
	bool res = LoadGVRPlugin((GVRPlugin*)[plugin pointerValue], (const char*)[pluginName pointerValue]);
	return [NSNumber numberWithBool:res];
}

- (void) onVREnabled
{
	if (overlayView == nil)
	{
		overlayView = [[GVROverlayView alloc] initWithFrame:UnityGetGLView().bounds];
		overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		overlayView.delegate = self;
	}
	[UnityGetGLView() addSubview:overlayView];
}

- (void) onVRDisabled
{
	[overlayView removeFromSuperview];
}

- (void)didTapBackButton
{
	UnitySetKeyState(BTN_ESCAPE, 1);
	UnitySetKeyState(BTN_ESCAPE, 0);
}

- (UIViewController *)presentingViewControllerForSettingsDialog
{
	return UnityGetGLViewController();
}

- (void)didPresentSettingsDialog:(BOOL)presented
{
	// The overlay view is presenting the settings dialog. Pause our rendering while presented.
	UnityPause(presented ? 1 : 0);
}

- (void)didChangeViewerProfile
{
}

- (void)shouldDisableIdleTimer:(BOOL)shouldDisable
{
	[UIApplication sharedApplication].idleTimerDisabled = shouldDisable;
}

@end
