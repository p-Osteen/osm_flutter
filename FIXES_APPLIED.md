# OSM Flutter Plugin - GitHub Issues Fixes

This document summarizes all the fixes applied to resolve the Android and iOS related GitHub issues in the OSM Flutter plugin.

## Issues Fixed

### iOS Issues

#### 1. Issue #587 & #594: iOS Build Errors - Missing Protocol Implementations
**Problem**: Swift compilation errors due to missing protocol method implementations for `MapMarkerHandler`, `OnMapGesture`, `OnMapMoved`, `OSMUserLocationHandler`, and `PoylineHandler`.

**Fix Applied**: 
- Added comprehensive protocol method implementations in `ios/flutter_osm_plugin/Sources/flutter_osm_plugin/map_view/osm_map.swift`
- Implemented missing methods:
  - `onSingleTapMarker()` and `onLongClickMarker()` for MapMarkerHandler
  - `onSingleTap()` and `onLongClick()` for OnMapGesture 
  - `mapMoved()` for OnMapMoved
  - `onUserLocationReceived()` and `onUserLocationError()` for OSMUserLocationHandler
  - `onRoadTapped()` for PoylineHandler
- Updated podspec to specify OSMFlutterFramework version `~> 0.8.3`

### Flutter/Dart Issues

#### 8. Navigation Disposal Error - Null Check Operator Exception
**Problem**: `Null check operator used on a null value` error when navigating away from OSM widget during marker rendering operations.

**Error Stack**:
```
Unhandled Exception: Null check operator used on a null value
#0  RenderRepaintBoundary.toImage (package:flutter/src/rendering/proxy_box.dart:3479)
#1  MethodChannelOSM._capturePng (package:flutter_osm_interface/src/channel/osm_method_channel.dart:324)
#2  MethodChannelOSM.addMarker (package:flutter_osm_interface/src/channel/osm_method_channel.dart:458)
```

**Fix Applied**:
- Enhanced `_capturePng()` method with comprehensive null checks and widget mounting validation
- Added proper error handling for disposed widgets during image capture
- Implemented fallback behavior to continue without custom icons when widgets are disposed
- Added mounted state checks in OSM controller's delayed marker operations
- Fixed all methods using `_capturePng`: `addMarker`, `customUserLocationMarker`, `customMarkerStaticPosition`, `setIconMarker`, `changeMarker`

#### 2. Issue #590: iOS Zoom Level Type Mismatch 
**Problem**: `getZoom()` method returning `int` directly instead of `Future<double>`, causing type mismatch errors.

**Fix Applied**:
- Modified the zoom level handling in `osm_map.swift` to properly dispatch on main queue and return `Double`
- Changed from `result(self.mapOSM.zoom())` to proper async dispatch with type conversion

#### 3. Issue #591: iOS Marker Deletion Crash (EXC_BAD_ACCESS)
**Problem**: `deleteMarker()` method causing crashes due to improper memory access.

**Fix Applied**:
- Added comprehensive safety checks and null guards
- Implemented proper main thread dispatching
- Added map initialization checks before attempting marker operations
- Used weak self references to prevent retain cycles

#### 4. Issue #554: Markers Not Displayed on iOS
**Problem**: Markers not appearing on iOS despite proper setup code.

**Fix Applied**:
- Enhanced map initialization sequence with proper timing
- Added 0.5 second delay before triggering map ready callback to ensure full rendering
- Improved `initPosition()` method with proper async handling

#### 5. Issue #599: iOS Road Width Not Visible 
**Problem**: `roadWidth` and `roadBorderWidth` parameters having no visible effect on iOS polylines.

**Fix Applied**:
- Enhanced `RoadData.toRoadConfiguration()` extension in `Extension.swift`
- Added proper scaling factor (2x) for iOS to match Android behavior
- Implemented minimum width guarantees to ensure visibility

### Android Issues

#### 6. Issue #582: Shape Color Inconsistency Between Platforms
**Problem**: Draw shapes showing different colors on Android vs iOS (Orange appearing as Pink).

**Fix Applied**:
- Fixed RGB color mapping bug in `utilities/ExtensionOSM.kt`
- Changed `Color.rgb(first(), last(), this[1])` to `Color.rgb(first(), this[1], last())`
- This corrects the Green/Blue channel swap that was causing color inconsistencies

#### 7. Issue #592: Android Build Dependency Issues (Maven Central Rate Limiting)
**Problem**: Build failures due to Maven Central rate limiting in CI environments.

**Fix Applied**:
- Added multiple fallback repositories in `android/build.gradle`
- Configured repository priorities with primary and backup sources
- Used more stable dependency versions to reduce conflicts:
  - Kotlinx Coroutines: 1.8.1 (from 1.10.1)
  - Retrofit: 2.9.0 (from 2.11.0) 
  - Picasso: 2.8 (from 3.0.0-alpha06)
- Added explicit dependency versions for OkHttp and Moshi
- Configured resolution strategy for better caching

#### 9. Picasso API Compatibility Issue
**Problem**: After downgrading Picasso from 3.x to 2.8 for stability, import statements and API calls in FlutterMaker.kt were still using the Picasso 3.x API, causing compilation errors.

**Fix Applied**:
- Updated import statements from `com.squareup.picasso3.*` to `com.squareup.picasso.*`
- Changed `BitmapTarget` to `Target` interface
- Updated API calls from `Picasso.Builder(context).build()` to `Picasso.get()`
- Fixed callback method signatures to match Picasso 2.x API

## Files Modified

### iOS Files:
1. `ios/flutter_osm_plugin/Sources/flutter_osm_plugin/map_view/osm_map.swift`
   - Added protocol implementations
   - Fixed zoom level handling
   - Enhanced marker deletion safety
   - Improved initialization sequence

2. `ios/flutter_osm_plugin/Sources/flutter_osm_plugin/Extension.swift`
   - Enhanced road width scaling for better visibility

3. `ios/flutter_osm_plugin.podspec`
   - Updated OSMFlutterFramework version specification

### Android Files:
1. `android/src/main/kotlin/hamza/dali/flutter_osm_plugin/utilities/ExtensionOSM.kt`
   - Fixed RGB color channel mapping

2. `android/build.gradle`
   - Added multiple repository configurations
   - Updated dependency versions for better stability
   - Added resolution strategies

### Flutter/Dart Files:
1. `flutter_osm_interface/lib/src/channel/osm_method_channel.dart`
   - Enhanced `_capturePng()` with comprehensive null checks and widget mounting validation
   - Added try-catch blocks around all `_capturePng()` calls
   - Implemented graceful fallback behavior for disposed widgets
   - Fixed methods: `addMarker`, `customUserLocationMarker`, `customMarkerStaticPosition`, `setIconMarker`, `changeMarker`

2. `lib/src/controller/osm/osm_controller.dart`
   - Added widget mounting checks before and after delayed operations
   - Added fallback marker addition without custom icons on errors
   - Added proper import for `debugPrint` from `flutter/foundation.dart`

3. `android/src/main/kotlin/hamza/dali/flutter_osm_plugin/models/FlutterMaker.kt`
   - Updated Picasso imports from picasso3 to picasso package
   - Changed BitmapTarget to Target interface
   - Updated Picasso API calls for 2.x compatibility

## Testing Recommendations

After applying these fixes, the following should be tested:

### iOS Testing:
1. Verify Swift compilation succeeds without protocol conformance errors
2. Test marker addition/removal without crashes
3. Confirm zoom level operations work consistently  
4. Validate road width visibility matches Android behavior
5. Ensure map initialization triggers callbacks properly

### Android Testing:
1. Verify build succeeds in CI environments without rate limiting
2. Test shape color consistency with iOS
3. Confirm dependency resolution works reliably

### Navigation/Disposal Testing:
1. Test rapid navigation away from OSM widget during marker operations
2. Verify no null check operator exceptions occur when disposing widgets
3. Test marker addition with custom icons during quick navigation transitions
4. Validate graceful fallback to default markers when custom icons fail
5. Ensure user location markers work correctly even with disposal scenarios

## Version Compatibility

These fixes are designed to work with:
- Flutter 3.19.6+
- iOS 13.0+
- Android API 21+
- OSMFlutterFramework 0.8.3+

## Additional Notes

- All fixes maintain backward compatibility
- Error handling has been enhanced throughout
- Memory management improved on iOS side
- Dependency management optimized on Android side

## Future Maintenance

To prevent similar issues:
1. Keep OSMFlutterFramework version pinned and updated regularly
2. Monitor Maven Central availability and maintain repository fallbacks
3. Test protocol implementations when updating iOS framework
4. Validate color consistency when making rendering changes