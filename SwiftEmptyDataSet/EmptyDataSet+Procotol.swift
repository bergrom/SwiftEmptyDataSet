//
//  EmptyDataSet+Procotol.swift
//  SwiftEmptyDataSet
//
//  Created by 罗国 on 2017/7/29.
//  Copyright © 2017年 berg. All rights reserved.
//  Licence: MIT-Licence
//

import UIKit

/**
 The object that acts as the data source of the empty datasets.
 @discussion The data source must adopt the SwiftEmptyDataSetDataSource protocol. The data source is not retained. All data source methods are optional.
 */
@objc public protocol SwiftEmptyDataSetDataSource: NSObjectProtocol {
    
    
    /// Asks the data source for the image of the dataset.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the data source.
    /// - Returns: An image for the dataset.
    @objc optional func imageForEmptyDataSet(_ scrollView: UIScrollView) -> UIImage
    
    /// Asks the data source for the title of the dataset.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the data source.
    /// - Returns: An attributed string for the dataset title, combining font, text color, text pararaph style, etc.
    @objc optional func titleForEmptyDataSet(_ scrollView: UIScrollView) -> NSAttributedString
    
    /// Asks the data source for the description of the dataset.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the data source.
    /// - Returns: An attributed string for the dataset description text, combining font, text color, text pararaph style, etc.
    @objc optional func descriptionForEmptyDataSet(_ scrollView: UIScrollView) -> NSAttributedString
    
    /// Asks the data source for a tint color of the image dataset. Default is nil.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: A color to tint the image of the dataset.
    @objc optional func imageTintColorForEmptyDataSet(_ scrollView: UIScrollView) -> UIColor
    
    /// Asks the data source for the image animation of the dataset.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: image animation
    @objc optional func imageAnimationForEmptyDataSet(_ scrollView: UIScrollView) -> CAAnimation
    
    /// Asks the data source for the title to be used for the specified button state.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass object informing the data source.
    ///   - state: The state that uses the specified title. The possible values are described in UIControlState.
    /// - Returns: An attributed string for the dataset button title, combining font, text color, text pararaph style, etc.
    @objc optional func buttonTitleForEmptyDataSet(_ scrollView: UIScrollView, forState state: UIControlState) -> NSAttributedString
    
    /// Asks the data source for the image to be used for the specified button state.
    /// This method will override buttonTitleForEmptyDataSet:forState: and present the image only without any text.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass object informing the data source.
    ///   - state: The state that uses the specified title. The possible values are described in UIControlState.
    /// - Returns: An image for the dataset button imageview.
    @objc optional func buttonImageForEmptyDataSet(_ scrollView: UIScrollView, forState state: UIControlState) -> UIImage
    
    /// Asks the data source for a background image to be used for the specified button state.
    /// There is no default style for this call.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass informing the data source.
    ///   - state: The state that uses the specified image. The values are described in UIControlState.
    /// - Returns: An attributed string for the dataset button title, combining font, text color, text pararaph style, etc.
    @objc optional func buttonBackgroundImageForEmptyDataSet(_ scrollView: UIScrollView, forState state: UIControlState) -> UIImage
    
    /// Asks the data source for the background color of the dataset. Default is clear color.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: A color to be applied to the dataset background view.
    @objc optional func backgroundColorForEmptyDataSet(_ scrollView: UIScrollView) -> UIColor
    
    /// Asks the data source for a custom view to be displayed instead of the default views such as labels, imageview and button. Default is nil.
    /// Use this method to show an activity view indicator for loading feedback, or for complete custom empty data set.
    /// Returning a custom view will ignore -spaceHeightForEmptyDataSet configurations.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: The custom view.
    @objc optional func customViewForEmptyDataSet(_ scrollView: UIScrollView) -> UIView
    
    /// Aaks the data source for the button's insets. Default is zero.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: button's insets.
    @objc optional func buttonInsetsForEmptyDataSet(_ scrollView: UIScrollView) -> UIEdgeInsets
    
    /// Asks the data source for space between image and title label. Default is 8.0.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: space between image and title label.
    @objc optional func spaceBetweenImageTitleForEmptyDataSet(_ scrollView: UIScrollView) -> CGFloat
    
    /// Asks the data source for space between title label and description label. Default is 4.0.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: space between title label and description label.
    @objc optional func spaceBetweenTitleDetailForEmptyDataSet(_ scrollView: UIScrollView) -> CGFloat
    
    /// Asks the data source for space between description label and button. Default is 8.0.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: space between description label and button.
    @objc optional func spaceBetweenDetailButtonForEmptyDataSet(_ scrollView: UIScrollView) -> CGFloat
    
    /// Asks the data source for a offset for vertical alignment of the default content, or a offset for vertical and horizontal alignment of the custom view. Default is CGPointZero.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: a offset for vertical and horizontal alignment of the content.
    @objc optional func verticalOffsetForEmptyDataSet(_ scrollView: UIScrollView) -> CGPoint
}

/**
 The object that acts as the delegate of the empty datasets.
 @discussion The delegate can adopt the DZNEmptyDataSetDelegate protocol. The delegate is not retained. All delegate methods are optional.
 
 @discussion All delegate methods are optional. Use this delegate for receiving action callbacks.
 */
@objc public protocol SwiftEmptyDataSetDelegate: NSObjectProtocol {
    
    /// Asks the delegate to know if the empty dataset should fade in when displayed. Default is YES.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: YES if the empty dataset should fade in.
    @objc optional func emptyDataSetShouldFadeIn(_ scrollView: UIScrollView) -> Bool
    
    /// Asks the delegate to know if the empty dataset should still be displayed when the amount of items is more than 0. Default is NO
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: YES if empty dataset should be forced to display.
    @objc optional func emptyDataSetShouldBeForcedToDisplay(_ scrollView: UIScrollView) -> Bool
    
    /// Asks the delegate to know if the empty dataset should be rendered and displayed. Default is YES.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: YES if the empty dataset should show.
    @objc optional func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool
    
    /// Asks the delegate for touch permission. Default is YES.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: YES if the empty dataset receives touch gestures.
    @objc optional func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool
    
    /// Asks the delegate for scroll permission. Default is NO.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: YES if the empty dataset is allowed to be scrollable.
    @objc optional func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool
    
    /// Asks the delegate for image view animation permission. Default is NO.
    /// Make sure to return a valid CAAnimation object from imageAnimationForEmptyDataSet:
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: YES if the empty dataset is allowed to animate
    @objc optional func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView) -> Bool
    
    /// Tells the delegate that the empty dataset view was tapped.
    /// Use this method either to resignFirstResponder of a textfield or searchBar.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass object informing the delegate.
    ///   - view: empty view
    @objc optional func emptyDataSet(_ scrollView: UIScrollView, didTapView view: UIView)
    
    /// Tells the delegate that the action button was tapped.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass object informing the delegate.
    ///   - button: the button in empty view.
    @objc optional func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton)
    
    /// Tells the delegate that the empty data set will appear.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    @objc optional func emptyDataSetWillAppear(_ scrollView: UIScrollView)
    
    /// Tells the delegate that the empty data set did appear.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    @objc optional func emptyDataSetDidAppear(_ scrollView: UIScrollView)
    
    /// Tells the delegate that the empty data set will disappear.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    @objc optional func emptyDataSetWillDisappear(_ scrollView: UIScrollView)
    
    /// Tells the delegate that the empty data set did disappear.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    @objc optional func emptyDataSetDidDisappear(_ scrollView: UIScrollView)
    
    
}
