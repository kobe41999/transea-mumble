//
//  AppDelegate.m
//  Mumble
//
//  Created by HanChien Chun on 2016/7/26.
//
//

#import "AppDelegate.h"

#import "MUDatabase.h"
#import "MUPublicServerList.h"
#import "MUConnectionController.h"
#import "MUNotificationController.h"
#import "MURemoteControlServer.h"
#import "MUImage.h"
#import "MUOperatingSystem.h"
#import "MUBackgroundView.h"

#import <MumbleKit/MKAudio.h>
#import <MumbleKit/MKVersion.h>
#import <Parse/Parse.h>
#import "DeviceUtil.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "IQKeyboardManager.h"


@interface AppDelegate ()


@end


@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIStoryboard *mainstoryBoard = [UIStoryboard storyboardWithName:@"NCCU-Glotter" bundle:nil];
    UIViewController *mainViewController = [mainstoryBoard instantiateInitialViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    _window.rootViewController = nav;
    
    [_window makeKeyAndVisible];

    [self setupmumble];
    
    // Setup Parse
    [self initParse];
    
    [self saveDeviceStats];
    
    // Init Facebook Utils
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];

    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

-(void) initParse
{
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"891f490e5d7bdb06d90d56f8d7db405f";
        configuration.server = @"http://162.243.49.105:1337/parse";
        configuration.clientKey=@"9cdfb439c7876e703e307864c9167a15";
    }]];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}


-(void) setupmumble
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionOpened:) name:MUConnectionOpenedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionClosed:) name:MUConnectionClosedNotification object:nil];
    
    // Reset application badge, in case something brought it into an inconsistent state.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // Initialize the notification controller
    [MUNotificationController sharedController];
    
    // Set MumbleKit release string
    [[MKVersion sharedVersion] setOverrideReleaseString:
     [NSString stringWithFormat:@"Mumble for iOS %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]];
    
    // Enable Opus unconditionally
    [[MKVersion sharedVersion] setOpusEnabled:YES];
    
    // Register default settings
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             // Audio
                                                             [NSNumber numberWithFloat:1.0f],   @"AudioOutputVolume",
                                                             [NSNumber numberWithFloat:0.6f],   @"AudioVADAbove",
                                                             [NSNumber numberWithFloat:0.3f],   @"AudioVADBelow",
                                                             @"amplitude",                      @"AudioVADKind",
                                                             @"vad",                            @"AudioTransmitMethod",
                                                             [NSNumber numberWithBool:YES],     @"AudioPreprocessor",
                                                             [NSNumber numberWithBool:YES],     @"AudioEchoCancel",
                                                             [NSNumber numberWithFloat:1.0f],   @"AudioMicBoost",
                                                             @"balanced",                       @"AudioQualityKind",
                                                             [NSNumber numberWithBool:NO],      @"AudioSidetone",
                                                             [NSNumber numberWithFloat:0.2f],   @"AudioSidetoneVolume",
                                                             [NSNumber numberWithBool:YES],     @"AudioSpeakerPhoneMode",
                                                             [NSNumber numberWithBool:YES],     @"AudioOpusCodecForceCELTMode",
                                                             // Network
                                                             [NSNumber numberWithBool:NO],      @"NetworkForceTCP",
                                                             @"MumbleUser",                     @"DefaultUserName",
                                                             nil]];
    
    // Disable mixer debugging for all builds.
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"AudioMixerDebug"];
    
    [self reloadPreferences];
    [MUDatabase initializeDatabase];
    
#ifdef ENABLE_REMOTE_CONTROL
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"RemoteControlServerEnabled"]) {
        [[MURemoteControlServer sharedRemoteControlServer] start];
    }
#endif
    
    // Try to use a dark keyboard throughout the app's text fields.
    if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
        [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
    }
    
    //_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
        // XXX: don't do it system-wide just yet
        //    _window.tintColor = [UIColor whiteColor];
    }
    
    // Put a background view in here, to have prettier transitions.
    //[_window addSubview:[MUBackgroundView backgroundView]];
        
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    
    
    //[_window setRootViewController:_navigationController];
    //[_window makeKeyAndVisible];
    
}


- (void) setupAudio {
    // Set up a good set of default audio settings.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    MKAudioSettings settings;
    
    if ([[defaults stringForKey:@"AudioTransmitMethod"] isEqualToString:@"vad"])
        settings.transmitType = MKTransmitTypeVAD;
    else if ([[defaults stringForKey:@"AudioTransmitMethod"] isEqualToString:@"continuous"])
        settings.transmitType = MKTransmitTypeContinuous;
    else if ([[defaults stringForKey:@"AudioTransmitMethod"] isEqualToString:@"ptt"])
        settings.transmitType = MKTransmitTypeToggle;
    else
        settings.transmitType = MKTransmitTypeVAD;
    
    settings.vadKind = MKVADKindAmplitude;
    if ([[defaults stringForKey:@"AudioVADKind"] isEqualToString:@"snr"]) {
        settings.vadKind = MKVADKindSignalToNoise;
    } else if ([[defaults stringForKey:@"AudioVADKind"] isEqualToString:@"amplitude"]) {
        settings.vadKind = MKVADKindAmplitude;
    }
    
    settings.vadMin = [defaults floatForKey:@"AudioVADBelow"];
    settings.vadMax = [defaults floatForKey:@"AudioVADAbove"];
    
    NSString *quality = [defaults stringForKey:@"AudioQualityKind"];
    if ([quality isEqualToString:@"low"]) {
        // Will fall back to CELT if the
        // server requires it for inter-op.
        settings.codec = MKCodecFormatOpus;
        settings.quality = 16000;
        settings.audioPerPacket = 6;
    } else if ([quality isEqualToString:@"balanced"]) {
        // Will fall back to CELT if the
        // server requires it for inter-op.
        settings.codec = MKCodecFormatOpus;
        settings.quality = 40000;
        settings.audioPerPacket = 2;
    } else if ([quality isEqualToString:@"high"] || [quality isEqualToString:@"opus"]) {
        // Will fall back to CELT if the
        // server requires it for inter-op.
        settings.codec = MKCodecFormatOpus;
        settings.quality = 72000;
        settings.audioPerPacket = 1;
    } else {
        settings.codec = MKCodecFormatCELT;
        if ([[defaults stringForKey:@"AudioCodec"] isEqualToString:@"opus"])
            settings.codec = MKCodecFormatOpus;
        if ([[defaults stringForKey:@"AudioCodec"] isEqualToString:@"celt"])
            settings.codec = MKCodecFormatCELT;
        if ([[defaults stringForKey:@"AudioCodec"] isEqualToString:@"speex"])
            settings.codec = MKCodecFormatSpeex;
        settings.quality = (int) [defaults integerForKey:@"AudioQualityBitrate"];
        settings.audioPerPacket = (int) [defaults integerForKey:@"AudioQualityFrames"];
    }
    
    settings.codec = MKCodecFormatOpus;
    settings.quality = 72000;
    settings.audioPerPacket = 1;
    settings.codec = MKCodecFormatOpus;
    
    settings.noiseSuppression = -42; /* -42 dB */
    settings.amplification = 20.0f;
    settings.jitterBufferSize = 0; /* 10 ms */
    settings.volume = [defaults floatForKey:@"AudioOutputVolume"];
    settings.outputDelay = 0; /* 10 ms */
    settings.micBoost = [defaults floatForKey:@"AudioMicBoost"];
    settings.enablePreprocessor = [defaults boolForKey:@"AudioPreprocessor"];
    if (settings.enablePreprocessor) {
        settings.enableEchoCancellation = [defaults boolForKey:@"AudioEchoCancel"];
    } else {
        settings.enableEchoCancellation = NO;
    }
    settings.enableEchoCancellation=YES;
    
    
    settings.enableSideTone = [defaults boolForKey:@"AudioSidetone"];
    settings.sidetoneVolume = [defaults floatForKey:@"AudioSidetoneVolume"];
    
    if ([defaults boolForKey:@"AudioSpeakerPhoneMode"]) {
        settings.preferReceiverOverSpeaker = NO;
    } else {
        settings.preferReceiverOverSpeaker = YES;
    }
    
    settings.opusForceCELTMode = [defaults boolForKey:@"AudioOpusCodecForceCELTMode"];
    settings.audioMixerDebug = [defaults boolForKey:@"AudioMixerDebug"];
    
    MKAudio *audio = [MKAudio sharedAudio];
    [audio updateAudioSettings:&settings];
    [audio restart];
}

// Reload application preferences...
- (void) reloadPreferences {
    [self setupAudio];
}

- (void) connectionOpened:(NSNotification *)notification {
    _connectionActive = YES;
}

- (void) connectionClosed:(NSNotification *)notification {
    _connectionActive = NO;
}

-(void) saveDeviceStats{
    NSString * deviceUID=[self appleIFV];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setValue:deviceUID forKey:@"deviceID"];
    [currentInstallation setValue:[DeviceUtil hardwareDescription] forKey:@"hardwareDescription"];
    [currentInstallation setValue:[[UIDevice currentDevice] systemVersion]forKey:@"systemVersion"];
    [currentInstallation saveInBackground];
}

- (NSString *)appleIFV {
    if(NSClassFromString(@"UIDevice") && [UIDevice instancesRespondToSelector:@selector(identifierForVendor)]) {
        // only available in iOS >= 6.0
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return nil;
}


@end
