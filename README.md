# CTPanoramaView

[![CI Status](http://img.shields.io/travis/scihant/CTPanoramaView.svg?style=flat)](https://travis-ci.org/scihant/CTPanoramaView)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/CTPanoramaView.svg)](https://img.shields.io/cocoapods/v/CTPanoramaView.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Issues](https://img.shields.io/github/issues/scihant/CTPanoramaView.svg?style=flat)](http://www.github.com/scihant/CTPanoramaView/issues?state=open)

CTPanoramaView is a high-performance library that uses SceneKit to display complete spherical or cylindrical panoramas with touch or motion based controls.

![panorama_demo](https://cloud.githubusercontent.com/assets/3991481/23154113/ce5aa6b8-f814-11e6-9c97-4d91629733f8.gif)

## Requirements

* iOS 8.0+ 
* v1.0 requires Xcode 8.0 and Swift 3.0
* v1.1 requires XCode 9.0 and Swift 4.0
* v1.2 requires XCode 10.0 and Swift 4.2
* v1.3 requires XCode 10.0 and Swift 5.0

CTPanoramaView can be used both from Objective-C and Swift code.

## Installation

### Using Carthage

To install CTPanoramaView using [Carthage](https://github.com/Carthage/Carthage), add the folowing line into your Cartfile:

    github "scihant/CTPanoramaView" ~> 1.3

Then run the `carthage update` command to build the framework and drag the built `CTPanoramaView.framework` into your XCode project.

### Using CocoaPods

To install CTPanoramaView using [CocoaPods](http://cocoapods.org), add the following line into your Podfile:

    pod "CTPanoramaView", "~> 1.3"

Then run the `pod install` command and use the created workspace to open your project from now on.  

#### Manual Install

Just add the file `CTPanoramaView.swift` (and `CTPieSliceView.swift` if you want to use it as the compass view) to your project.

#### Running the Example project

The example project is located in the Example directory. The framework target is already added as a dependency to it therefore you can run it directly. 

## Usage

Create an instance of `CTPanoramaView` either in code or using a Storyboard/Nib.

Then load a panoramic image and set it as the image of the CTPanoramaView instance:

```swift
// Create an instance of CTPanoramaView called "panoramaView" somewhere
// ...
let image = UIImage(named: "panoramicImage.png")
panaromaView.image = image
```

![panorama_screenshot](https://cloud.githubusercontent.com/assets/3991481/23154919/d5f98476-f818-11e6-8c71-22011a027d96.jpg)

## Configuration

### Panorama Types

CTPanoramaView supports two types of panoramic images:

* Spherical panoramas (also called 360 photos) 
* Cylindrical panoramas

All panoramas should be full. Partial panoramas (panoramas with a field of view of less than 360º) are not supported. For a spherical panorama, the image should use [equirectangular projection](https://en.wikipedia.org/wiki/Equirectangular_projection). Cubic format is not supported.

CTPanoramaView will automatically determine whether the given image is a spherical or cylindircal panorama by looking at the aspect ratio of the image. If it is 2:1, then it will assume a spherical panorama. If you want to override this default value, change the value of the `panoramaType` property after the image is set.

```swift
panaromaView.panoramaType = .spherical  // or .cylindrical
```

### Control Methods

CTPanoramaView allows the user to navigate the panorama two different ways. To change the control method, use the `controlMethod` property.

```swift
panaromaView.controlMethod = .touch  // Touch based control
panaromaView.controlMethod = .motion // Accelerometer & gyroscope based control
```

The default control method is touch based control. You can change the control method on the fly, while the panorama is being displayed on the screen. The visible section will get automatically reset during a control method change.

When using touch based control, you can set the starting angle of the viewer in radians using the `startAngle` property of CTPanoramaView. This property is ignored in motion based control mode.

### Orientation Support

All orientations are supported. Orientation changes are automatically handled. Therefore you don't have to worry about things getting messed up after an orientation change.

### Compass

If you want to display a compass that shows the users current field of view, use the `compass` property.
When you set this property to a custom `UIView` subclass conforming to the `CTPanoramaCompass` protocol, the view will automatically supplied with rotation and field of view angles whenever one of them changes.

```swift
// compassView is a custom view that conforms to the `CTPanoramaCompass` protocol.
panaromaView.compass =  compassView 
```
The protocol contains only a single method, which is `updateUI(rotationAngle:fieldOfViewAngle:)`. Here, `rotationAngle` is the amount of rotation around the vertical axis, and `fieldOfViewAngle` is the horizontal FoV angle of the camera. Both values are in radians.

You can see an example implementation of a compass in the supplied `CTPieSliceView` class. Add it into your view hierarchy somewhere above your `CTPanoramaView` instance, and then set it as its compass. You'll see that it shows the current FoV accurately. Here's how `CTPieSliceView` looks in its default configuration:

![compassview](https://cloud.githubusercontent.com/assets/3991481/23154086/a83d1542-f814-11e6-9580-40ec925137e9.jpg)

`CTPieSliceView` has several customizable properties such as `sliceColor`, `outerRingColor` and `bgColor`, all of which can also be modified from the interface builder thanks to its live-rendering support.

### Overlay Views

There is also a convenience property named `overlayView` that can be used to add a custom view that covers the entire panorama view on top. When using touch based controls, it's up to you to make sure that the overlay view does not "consume" the touches it receives so that the `CTPanoramaView` instance can receive the touch events properly.

### How to Contribute

Create a feature branch off the dev branch and then send me a pull request. I don't merge PR's directly to master so please don't make your changes there.



