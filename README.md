# CTPanoramaView

[![CI Status](http://img.shields.io/travis/scihant/CTPanoramaView.svg?style=flat)](https://travis-ci.org/scihant/CTPanoramaView)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/CTPanoramaView.svg)](https://img.shields.io/cocoapods/v/CTPanoramaView.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Issues](https://img.shields.io/github/issues/scihant/CTPanoramaView.svg?style=flat)](http://www.github.com/scihant/CTPanoramaView/issues?state=open)

CTPanoramaView is a library that displays complete spherical or cylindrical panoramas with touch or orientation based controls.

![Panorama Demo](http://s3.amazonaws.com/tek-files/panorama_demo.gif)

## Requirements

* iOS 8.0+ 
* Xcode 8.0+
* Swift 3.0+

CTPanoramaView can also be used both from Objective-C and Swift code.

## Installation

### Using Carthage

To install CTPanoramaView using [Carthage](https://github.com/Carthage/Carthage), add the folowing line into your Cartfile:

	github "CTPanoramaView/CTPanoramaView" ~> 1.0

Then run the `carthage update` command to build the framework and drag the built `CTPanoramaView.framework` into your XCode project.

### Using CocoaPods

To install CTPanoramaView using [CocoaPods](http://cocoapods.org), add the following line into your Podfile:

    pod "CTPanoramaView", "~> 1.0"

Then run the `pod install` command and use the created workspace to open your project from now on.  

#### Manual Install

Just add the file `CTPanoramaView.swift` (and `CTPieSliceView.swift` if you want to use it as the radar view) to your project.

#### Running the Example project

The example project is located in the Example directory. The framework target is already added as a dependency to it therefore you can run it directly. 

## Usage

Create an instance of `CTPanoramaView` either in code or using a Storyboard/nib.

Then load a panoramic image and set it as the image of the CTPanoramaView instance:

```swift
	// Create an instance of CTPanoramaView called "panoramaView" somewhere
    let image = UIImage(named: "panoramicImage.png")
    panaromaView.image = image
```

![Example](https://s3.amazonaws.com/tek-files/dynamic_rect.gif)

## Configuration

### Panorama Types

CTPanoramaView supports two types of panoramic images:

* Spherical panoramas, which are also called 360 photos. 
* Cylindrical panoramas.

All panoramas should be full. Partial panoramas (panoramas with a field of view of less than 360º) are not supported. For a spherical panorama, the image should use [equirectangular projections](https://en.wikipedia.org/wiki/Equirectangular_projection). Cubic format is not supported.

CTPanoramaView will automatically determine whether the given image is a spherical or cylindircal panorama by looking at the aspect ratio of the image. If it is 2:1, then it will assume a spherical panorama. If you want to override this default value, change the value of the `panoramaType` property after the image is set.

```swift
panaromaView.panoramaType = .spherical  // or .cylindrical
```

### Control Modes

CTPanoramaView allows the user to navigate the panorama two different ways. To change the control method, use the `controlMethod` property.

```swift
panaromaView.controlMethod = .Touch  // Touch based control
panaromaView.controlMethod = .Motion // Accelerometer&gyroscope based control
```

The default control method is touch based control. You can change the control method on the fly, while the panorama is being displayed on the screen. The visible section will get automatically reset during a control method change.

### Orientation Support

All orientations are supported. Orientation changes are automatically handled. Therefore you don't have to worry about things getting messed up after an orientation change.

### Radar

If you want to display a radar that shows where the user is currently looking at, use the `radar` property.
When you set this property to a custom `UIView` subclass conforming to the `CTPanoramaRadar` protocol, the view will automatically supplied with rotation and field of view angles whenever one of them changes.

```swift
// radarView is a custom view that conforms to the `CTPanoramaRadar` protocol.
panaromaView.radar =  radarView 
```
The protocol contaions only a single method `updateUI(rotationAngle:fieldOfViewAngle:)`. Here, the `rotationAngle` represents the amount of rotation around the vertical axis, and the `fieldOfViewAngle` respresents the horizontal FoV angle of the camera. Both values are in radians.

You can see an example implementation of a radar in the supplied `CTPieSliceView` class. Add it into your view hierarchy somewhere above the `CTPanoramaView` instance, and then set it as the radar. You'll see that it correctly shows where the user is currently looking at accurately.

![CTPieSliceView](https://s3.amazonaws.com/tek-files/dynamic_rect.gif)

`CTPieSliceView` has several customizable properties such as `sliceColor`, `outerRingColor` and `bgColor`, all of which can also be modified from the interface builder thanks to its live-rendering support.

### Overlay Views

There is also a convenience property named `overlayView` that can be used to add a custom view that covers the entire panorama view on top. When using touch based controls, it's up to you to make sure that the overlay view does not "consume" the touches it receives so that the `CTPanoramaView` instance can receive the touch events properly.


