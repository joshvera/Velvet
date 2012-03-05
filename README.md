# License

Velvet is released under the 3-clause BSD license. See the LICENSE file for more information.

**Velvet should remain private for the foreseeable future. Please do not publicly discuss or share it.**

# Features

 - Defines a modern API for layer-backed views (`VELView`), and provides some basic view classes, including:
   - `VELControl`, a control class supporting block-based actions
   - `VELImageView`, a simple image view with an easy-to-use API for stretchable images
   - `VELLabel`, a text label supporting formatting and sub-pixel antialiasing
 - Support for creating an AppKit view hierarchy within any Velvet hierarchy, using `VELNSView`
 - A view controller class usable with any `VELView` instance, including `VELNSView`
 - Automatic alignment of Velvet views to integral pixels (with an option to disable it), avoiding blurriness from landing on half-pixels
 - Automatic HiDPI support
 - Event recognizers (similar to `UIGestureRecognizer`) for any bridged view
 - Miscellaneous conveniences for bridging Core Animation and Core Graphics functionality with that of AppKit
