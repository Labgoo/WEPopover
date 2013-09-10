WEPopover
====================

WEPopover is an customizable popover controller which mimics and extends UIPopoverController's APIs.


Installation
--------------------

The library's source code can be found in the WEPopover folder of the root directory. It also can images for default
look & feel of the popup.

Alternatively, you can use CocoaPods and add this project's podspec file to your project's podfile.


Dependencies & Compatibility
--------------------

This library has been significantly improved from its original to use ARC and ObjC's features which are only recently available on iOS 5.0+. Hence, iOS 5.0 is the minimum requirement.

You also need to add QuartzCore framework to your project. If you use CocoaPods, the dependency is automatically
handled for you! :)


Features
--------------------

Please refer to [Apple UIPopoverController documentation](https://developer.apple.com/library/ios/documentation/uikit/reference/UIPopoverController_class/Reference/Reference.html) for the standard APIs to create and display a popover.

Additional features include:
- Support for custom background views: specify the WEPopoverContainerViewProperties for the view to use as background. The properties specify the images to use for the stretchable background and the arrows (four directions). It also specifies the margins and the cap sizes for resizing the background. A default image with corresponding arrows are supplied with the project.
- Support for limiting the area to display the popover: implement the protocol WEPopoverParentView for the view you supply to the presentPopover method and implement the - (CGRect)displayAreaForPopover.
- Support for repositioning an existing popover (by passing the need to dismiss it and present a new one). See the 'repositionPopoverFromRect' method in WEPopoverController.

