#import "ImageEditorPlugin.h"
#if __has_include(<image_editor/image_editor-Swift.h>)
#import <image_editor_dove/image_editor_dove-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "image_editor_dove-Swift.h"
#endif

@implementation ImageEditorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftImageEditorPlugin registerWithRegistrar:registrar];
}
@end
