//
//  UIScrollView+EmptyDataSet.swift
//  SwiftEmptyDataSet
//
//  Created by 罗国 on 2017/7/28.
//  Copyright © 2017年 berg. All rights reserved.
//  Licence: MIT-Licence
//

import UIKit

/**
 A drop-in UITableView/UICollectionView superclass category for showing empty datasets whenever the view has no content to display.
 @discussion It will work automatically, by just conforming to SwiftEmptyDataSetSource, and returning the data you want to show.
 */
extension UIScrollView {
    
    private struct associatedKey {
        static var emptyViewKey: String = "associatedKey_emptyView"
        static var emptyDataSourceKey: String = "associatedKey_emptyDataSource"
        static var emptyDelegateKey: String = "associatedKey_emptyDelegate"
        
        static let kEmptyImageViewAnimationKey = "com.swift.emptyDataSet.imageViewAnimation"
    }
    
    private var emptyView: SwiftEmptyDataSetView? {
        get {
            var view: SwiftEmptyDataSetView? = objc_getAssociatedObject(self, &associatedKey.emptyViewKey) as? SwiftEmptyDataSetView
            if view == nil {
                view = SwiftEmptyDataSetView(frame: self.bounds)
                view?.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
                view?.isHidden = true
                view?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(empty_didTapContentView(sender:))))
                self.emptyView = view
            }
            return view!
        }
        set {
            //            if let newValue = newValue {
            objc_setAssociatedObject(self, &associatedKey.emptyViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            //            }
        }
    }
    
    /// The empty datasets data source.
    @IBOutlet weak var emptyDataSource: SwiftEmptyDataSetDataSource? {
        get {
            return objc_getAssociatedObject(self, &associatedKey.emptyDataSourceKey) as? SwiftEmptyDataSetDataSource
        }
        set {
            
            if newValue == nil && !self.empty_canDisplay() {
                self.empty_invalidate()
            }
            
            objc_setAssociatedObject(self, &associatedKey.emptyDataSourceKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // We add method sizzling for injecting -empty_reloadData implementation to the native -reloadData implementation
            if self.isKind(of: UITableView.self) {
                self.swizzleIfPossible(selector: #selector(UITableView.reloadData))
                self.swizzleIfPossible(selector: #selector(UITableView.endUpdates))
            } else if self.isKind(of: UICollectionView.self) {
                self.swizzleIfPossible(selector: #selector(UICollectionView.reloadData))
            }
        }
    }
    
    /// The empty datasets delegate.
    @IBOutlet weak var emptyDelegate: SwiftEmptyDataSetDelegate? {
        get {
            return objc_getAssociatedObject(self, &associatedKey.emptyDelegateKey) as? SwiftEmptyDataSetDelegate
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &associatedKey.emptyDelegateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    private func isEmptyDataSetVisible() -> Bool {
        let view: SwiftEmptyDataSetView? = objc_getAssociatedObject(self, &associatedKey.emptyViewKey) as? SwiftEmptyDataSetView
        return view != nil ? !view!.isHidden : false
    }
    
    private func empty_reloadEmptyDataSet() {
        if !self.empty_canDisplay() {
            return
        }
        if (self.empty_shouldDisplay() && self.empty_itemsCount() == 0) || self.empty_shouldBeForcedToDisplay() {
            // Notifies that the empty dataset view will appear
            self.empty_willAppear()
            
            let view: SwiftEmptyDataSetView = self.emptyView!
            
            if view.superview == nil {
                if self.isKind(of: UITableView.self) && self.subviews.count > 1 {
                    self.insertSubview(view, at: 0)
                    self.bringSubview(toFront: view)
                } else {
                    self.addSubview(view)
                }
            }
            
            // Removing view resetting the view and its constraints it very important to guarantee a good state
            view.prepareForReuse()
            
            if let customView = empty_customView() {
                
                view.customView = customView
                
            } else {
                
                let imageTintColor: UIColor? = self.emptyDataSource?.imageTintColorForEmptyDataSet?(self)
                let renderingMode: UIImageRenderingMode = imageTintColor == nil ? UIImageRenderingMode.alwaysOriginal : UIImageRenderingMode.alwaysTemplate
                if let image = self.emptyDataSource?.imageForEmptyDataSet?(self) {
                    if image.responds(to: #selector(UIImage.withRenderingMode(_:))) {
                        view.imageView.image = image.withRenderingMode(renderingMode)
                        view.imageView.tintColor = imageTintColor
                    } else {
                        view.imageView.image = image
                    }
                }
                
                view.titleLabel.attributedText = self.emptyDataSource?.titleForEmptyDataSet?(self)
                view.detailLabel.attributedText = self.emptyDataSource?.descriptionForEmptyDataSet?(self)
                
                let buttonImage = self.emptyDataSource?.buttonImageForEmptyDataSet?(self, forState: .normal)
                let buttonTitle = self.emptyDataSource?.buttonTitleForEmptyDataSet?(self, forState: .normal)
                
                if let buttonImage = buttonImage {
                    view.button.setImage(buttonImage, for: .normal)
                    view.button.setImage(self.emptyDataSource?.buttonImageForEmptyDataSet?(self, forState: .highlighted), for: .highlighted)
                    
                } else if let buttonTitle = buttonTitle {
                    view.button.setAttributedTitle(buttonTitle, for: .normal)
                    view.button.setAttributedTitle(self.emptyDataSource?.buttonTitleForEmptyDataSet?(self, forState: .highlighted), for: .highlighted)
                    view.button.setBackgroundImage(self.emptyDataSource?.buttonBackgroundImageForEmptyDataSet?(self, forState: .normal), for: .normal)
                    view.button.setBackgroundImage(self.emptyDataSource?.buttonBackgroundImageForEmptyDataSet?(self, forState: .highlighted), for: .highlighted)
                }
                
                view.button.contentEdgeInsets = self.emptyDataSource?.buttonInsetsForEmptyDataSet?(self) ?? UIEdgeInsets.zero
                view.verticalSpaceBetweenImageTitle = self.empty_verticalSpaceImageTitle()
                view.verticalSpaceBetweenTitleDetail = self.empty_verticalSpaceTitleDetail()
                view.verticalSpaceBetweenDetailButton = self.empty_verticalSpaceDetailButton()
            }
            
            view.verticalOffset = self.emptyDataSource?.verticalOffsetForEmptyDataSet?(self) ?? CGPoint.zero
            view.backgroundColor = self.emptyDataSource?.backgroundColorForEmptyDataSet?(self)
            view.fadeInOnDisplay = self.emptyDelegate?.emptyDataSetShouldFadeIn?(self) ?? false
            view.isHidden = false
            view.isUserInteractionEnabled = self.empty_isTouchAllowed()
            
            view.layoutSubviews()
            UIView.performWithoutAnimation {
                view.layoutIfNeeded()
            }
            
            self.isScrollEnabled = self.emptyDelegate?.emptyDataSetShouldAllowScroll?(self) ?? false
            if self.empty_isImageViewAnimateAllowed() {
                if let animation = self.empty_imageAnimation() {
                    self.emptyView?.imageView.layer.add(animation, forKey: associatedKey.kEmptyImageViewAnimationKey)
                }
            } else if let _ = self.emptyView?.imageView.layer.animation(forKey: associatedKey.kEmptyImageViewAnimationKey) {
                self.emptyView?.imageView.layer.removeAnimation(forKey: associatedKey.kEmptyImageViewAnimationKey)
            }
            
            // Notifies that the empty dataset view did appear
            self.empty_didAppear()
            
        } else if self.isEmptyDataSetVisible() {
            self.empty_invalidate()
        }
    }
    
    private func empty_itemsCount() -> Int {
        var count: Int = 0
        
        // UIScollView doesn't respond to 'dataSource' so let's exit
//        if !self.responds(to: #selector(getter: dataSource)) {
//            return count
//        }

        if !self.responds(to: #selector(getter: UITableView.dataSource)) || !self.responds(to: #selector(getter: UICollectionView.dataSource)) {
            return count
        }
        
        // UITableView support
        if self.isKind(of: UITableView.self) {
            let tableView: UITableView = self as! UITableView
            var sectionCount: Int = 1
            if let dataSource = tableView.dataSource, dataSource.responds(to: #selector(UITableViewDataSource.numberOfSections(in:))) {
                sectionCount = dataSource.numberOfSections?(in: tableView) ?? 1
            }
            if let dataSource = tableView.dataSource, dataSource.responds(to: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))) {
                for index in 0 ..< sectionCount {
                    count += dataSource.tableView(tableView, numberOfRowsInSection: index)
                }
            }
        } else if self.isKind(of: UICollectionView.self) {
            let collectionView: UICollectionView = self as! UICollectionView
            var sectionCount: Int = 1
            if let dataSource = collectionView.dataSource, dataSource.responds(to: #selector(UICollectionViewDataSource.numberOfSections(in:))) {
                sectionCount = dataSource.numberOfSections?(in: collectionView) ?? 1
            }
            if let dataSource = collectionView.dataSource, dataSource.responds(to: #selector(UICollectionViewDataSource.numberOfSections(in:))) {
                for index in 0 ..< sectionCount {
                    count += dataSource.collectionView(collectionView, numberOfItemsInSection: index)
                }
            }
        }
        
        return count
    }
    
    // MARK - Method Swizzling
    struct SwizzleKey {
        static var impLookupTable: NSMutableDictionary?
        static let EmptySwizzleInfoPointerKey: String = "pointer"
        static let EmptySwizzleInfoOwnerKey: String = "owner"
        static let EmptySwizzleInfoSelectorKey: String = "selector"
    }
    
    func empty_original_implementation() {
        
        let baseClass: AnyClass? = empty_baseClassToSwizzleForTarget(target: self)
        var key: NSString? = nil
        
        var selector: Selector?
        if self.isKind(of: UITableView.self) {
            selector = #selector(UITableView.reloadData)
        } else if self.isKind(of: UICollectionView.self) {
            selector = #selector(UICollectionView.reloadData)
        }
        
        if let keyString = empty_implementationKey(clazz: baseClass, selector: selector) {
            key = NSString(string: keyString)
        }
        
        let swizzledInfo = SwizzleKey.impLookupTable?.object(forKey: key ?? "") as? [String: Any]
        let imp: IMP? = swizzledInfo?[SwizzleKey.EmptySwizzleInfoPointerKey] as? IMP
        
        // We then inject the additional implementation for reloading the empty dataset
        // Doing it before calling the original implementation does update the 'isEmptyDataSetVisible' flag on time.
        self.empty_reloadEmptyDataSet()
        
        // If found, call original implementation
        if let imp = imp, let selector = selector {
            typealias ClosureType = @convention(c) (AnyObject, Selector) -> Void
            let systemReloadData : ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            systemReloadData(self, selector)
        }
    }
    
    private func swizzleIfPossible(selector: Selector) {
        // Check if the target responds to selector
        if !self.responds(to: selector) {
            return
        }
        
        // Create the lookup table
        if SwizzleKey.impLookupTable == nil {
            SwizzleKey.impLookupTable = NSMutableDictionary(capacity: 3)  // 3 represent the supported base classes
        }
        
        // We make sure that setImplementation is called once per class kind, UITableView or UICollectionView.
        for info in SwizzleKey.impLookupTable!.allValues as! [NSDictionary] {
            let clazz: AnyClass = info.object(forKey: SwizzleKey.EmptySwizzleInfoOwnerKey) as! AnyClass
            let selectorName: String = info.object(forKey: SwizzleKey.EmptySwizzleInfoSelectorKey) as! String
            if selectorName == NSStringFromSelector(selector) {
                if self.isKind(of: clazz) {
                    return
                }
            }
        }
        
        let baseClass: AnyClass? = empty_baseClassToSwizzleForTarget(target: self)
        var key: NSString? = nil
        if let keyString = empty_implementationKey(clazz: baseClass, selector: selector) {
            key = NSString(string: keyString)
        }
        let imp: IMP? = (SwizzleKey.impLookupTable?.object(forKey: key ?? "") as? NSDictionary)?.value(forKey: SwizzleKey.EmptySwizzleInfoPointerKey) as? IMP
        
        // If the implementation for this class already exist, skip!
        if imp != nil || key == nil || baseClass == nil {
            return
        }
        
        // Swizzle by injecting additional implementation
        let method: Method = class_getInstanceMethod(baseClass, selector)
        let empty_method: Method = class_getInstanceMethod(baseClass, #selector(empty_original_implementation))
        let system_Implementation: IMP = method_setImplementation(method, method_getImplementation(empty_method))
        let swizzledInfo: [String: Any] = [SwizzleKey.EmptySwizzleInfoOwnerKey: baseClass!, SwizzleKey.EmptySwizzleInfoSelectorKey: NSStringFromSelector(selector), SwizzleKey.EmptySwizzleInfoPointerKey: system_Implementation]
        
        SwizzleKey.impLookupTable?.setObject(swizzledInfo, forKey: key!)
    }
    
    private func empty_baseClassToSwizzleForTarget(target: AnyObject) -> AnyClass? {
        if target.isKind(of: UITableView.self) {
            return UITableView.self
        } else if target.isKind(of: UICollectionView.self) {
            return UICollectionView.self
        } else if target.isKind(of: UIScrollView.self) {
            return UIScrollView.self
        }
        return nil
    }
    
    private func empty_implementationKey(clazz: AnyClass?, selector: Selector?) -> String? {
        if clazz == nil || selector == nil {
            return nil
        }
        let className: String = NSStringFromClass(clazz!)
        let selectorName: String = NSStringFromSelector(selector!)
        return String(format: "%@_%@", className, selectorName)
    }
    
    private func empty_canDisplay() -> Bool {
        if let _ = self.emptyDataSource {
            if self.isKind(of: UITableView.self) || self.isKind(of: UICollectionView.self) || self.isKind(of: UIScrollView.self) {
                return true
            }
        }
        return false
    }
    
    private func empty_invalidate() {
        // Notifies that the empty dataset view will disappear
        self.empty_willDisappear()
        
        if let emptyView = self.emptyView {
            emptyView.prepareForReuse()
            emptyView.removeFromSuperview()
            self.emptyView = nil
        }
        
        self.isScrollEnabled = true
        
        // Notifies that the empty dataset view did disappear
        self.empty_didDisappear()
    }
    
    private func empty_shouldDisplay() -> Bool {
        if let emptyDelegate = self.emptyDelegate, emptyDelegate.responds(to: #selector(SwiftEmptyDataSetDelegate.emptyDataSetShouldDisplay(_:))) {
            return emptyDelegate.emptyDataSetShouldDisplay?(self) ?? true
        }
        return true
    }
    
    private func empty_shouldBeForcedToDisplay() -> Bool {
        if let emptyDelegate = self.emptyDelegate, emptyDelegate.responds(to: #selector(SwiftEmptyDataSetDelegate.emptyDataSetShouldBeForcedToDisplay(_:))) {
            return emptyDelegate.emptyDataSetShouldBeForcedToDisplay?(self) ?? false
        }
        return false
    }
    
    private func empty_isTouchAllowed() -> Bool {
        if let emptyDelegate = self.emptyDelegate, emptyDelegate.responds(to: #selector(SwiftEmptyDataSetDelegate.emptyDataSetShouldAllowTouch(_:))) {
            return emptyDelegate.emptyDataSetShouldAllowTouch?(self) ?? true
        }
        return true
    }
    
    private func empty_isImageViewAnimateAllowed() -> Bool {
        if let emptyDelegate = self.emptyDelegate, emptyDelegate.responds(to: #selector(SwiftEmptyDataSetDelegate.emptyDataSetShouldAnimateImageView(_:))) {
            return emptyDelegate.emptyDataSetShouldAnimateImageView?(self) ?? false
        }
        return false
    }
    
    private func empty_imageAnimation() -> CAAnimation? {
        if let emptyDataSource = self.emptyDataSource, emptyDataSource.responds(to: #selector(SwiftEmptyDataSetDataSource.imageAnimationForEmptyDataSet(_:))) {
            return emptyDataSource.imageAnimationForEmptyDataSet?(self)
        }
        return nil
    }
    
    private func empty_willAppear() {
        if let emptyDelegate = self.emptyDelegate, emptyDelegate.responds(to: #selector(SwiftEmptyDataSetDelegate.emptyDataSetWillAppear(_:))) {
            emptyDelegate.emptyDataSetWillAppear?(self)
        }
    }
    
    private func empty_didAppear() {
        if let emptyDelegate = self.emptyDelegate, emptyDelegate.responds(to: #selector(SwiftEmptyDataSetDelegate.emptyDataSetDidAppear(_:))) {
            emptyDelegate.emptyDataSetDidAppear?(self)
        }
    }
    
    private func empty_willDisappear() {
        if let emptyDelegate = self.emptyDelegate, emptyDelegate.responds(to: #selector(SwiftEmptyDataSetDelegate.emptyDataSetWillDisappear(_:))) {
            emptyDelegate.emptyDataSetWillDisappear?(self)
        }
    }
    
    private func empty_didDisappear() {
        if let emptyDelegate = self.emptyDelegate, emptyDelegate.responds(to: #selector(SwiftEmptyDataSetDelegate.emptyDataSetDidDisappear(_:))) {
            emptyDelegate.emptyDataSetDidDisappear?(self)
        }
    }
    
    private func empty_shouldFadeIn() -> Bool {
        if let emptyDelegate = self.emptyDelegate, emptyDelegate.responds(to: #selector(SwiftEmptyDataSetDelegate.emptyDataSetShouldFadeIn(_:))) {
            return emptyDelegate.emptyDataSetShouldFadeIn?(self) ?? true
        }
        return true
    }
    
    private func empty_verticalSpaceImageTitle() -> CGFloat {
        if let emptyDataSource = self.emptyDataSource, emptyDataSource.responds(to: #selector(SwiftEmptyDataSetDataSource.spaceBetweenImageTitleForEmptyDataSet(_:))) {
            return emptyDataSource.spaceBetweenImageTitleForEmptyDataSet?(self) ?? 8.0
        }
        return 8.0
    }
    
    private func empty_verticalSpaceTitleDetail() -> CGFloat {
        if let emptyDataSource = self.emptyDataSource, emptyDataSource.responds(to: #selector(SwiftEmptyDataSetDataSource.spaceBetweenTitleDetailForEmptyDataSet(_:))) {
            return emptyDataSource.spaceBetweenTitleDetailForEmptyDataSet?(self) ?? 4.0
        }
        return 4.0
    }
    
    private func empty_verticalSpaceDetailButton() -> CGFloat {
        if let emptyDataSource = self.emptyDataSource, emptyDataSource.responds(to: #selector(SwiftEmptyDataSetDataSource.spaceBetweenDetailButtonForEmptyDataSet(_:))) {
            return emptyDataSource.spaceBetweenDetailButtonForEmptyDataSet?(self) ?? 8.0
        }
        return 8.0
    }
    
    private func empty_customView() -> UIView? {
        if let emptyDataSource = self.emptyDataSource, emptyDataSource.responds(to: #selector(SwiftEmptyDataSetDataSource.customViewForEmptyDataSet(_:))) {
            return emptyDataSource.customViewForEmptyDataSet?(self)
        }
        return nil
    }
    
    func empty_didTapContentView(sender: UIView) {
        if let emptyDelegate = self.emptyDelegate, emptyDelegate.responds(to: #selector(SwiftEmptyDataSetDelegate.emptyDataSet(_:didTapView:))) {
            emptyDelegate.emptyDataSet?(self, didTapView: sender)
        }
    }
    
    @objc func empty_didTapDataButton(sender: UIButton) {
        if let emptyDelegate = self.emptyDelegate, emptyDelegate.responds(to: #selector(SwiftEmptyDataSetDelegate.emptyDataSet(_:didTapButton:))) {
            emptyDelegate.emptyDataSet?(self, didTapButton: sender)
        }
    }
}

fileprivate class SwiftEmptyDataSetView: UIView {
    
    var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = true
        view.alpha = 0.0
        return view
    }()
    
    var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .center
        imageView.accessibilityIdentifier = "empty set background image"
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        
        label.font = UIFont.systemFont(ofSize: 27.0)
        label.textColor = UIColor(white: 0.6, alpha: 1.0)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.accessibilityIdentifier = "empty set title"
        return label
    }()
    
    var detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        
        label.font = UIFont.systemFont(ofSize: 27.0)
        label.textColor = UIColor(white: 0.6, alpha: 1.0)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.accessibilityIdentifier = "empty set detail"
        return label
    }()
    
    var button: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.backgroundColor = UIColor.clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
        button.accessibilityIdentifier = "empty set button"
        return button
    }()
    
    var customView: UIView?
    
    var verticalOffset: CGPoint = CGPoint.zero
    var verticalSpaceBetweenImageTitle: CGFloat = 0.0
    var verticalSpaceBetweenTitleDetail: CGFloat = 0.0
    var verticalSpaceBetweenDetailButton: CGFloat = 0.0
    
    var fadeInOnDisplay: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        let superBounds = self.superview?.bounds
        self.frame = CGRect(x: 0.0, y: 0.0, width: superBounds?.width ?? 0.0, height: superBounds?.height ?? 0.0)
        let fadeInBlock = {
            self.contentView.alpha = 1.0
        }
        if self.fadeInOnDisplay {
            UIView.animate(withDuration: 0.25, animations: fadeInBlock)
        } else {
            fadeInBlock()
        }
    }
    
    override func layoutSubviews() {
        // MARK: - content view contriants
        let contentLeadingContraint = NSLayoutConstraint(item: self.contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let contentTrailingContraint = NSLayoutConstraint(item: self.contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        let contentTopContraint = NSLayoutConstraint(item: self.contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let contentBottomContraint = NSLayoutConstraint(item: self.contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.addConstraints([contentLeadingContraint, contentTrailingContraint, contentTopContraint, contentBottomContraint])
        
        if let customView = self.customView {
            
            customView.translatesAutoresizingMaskIntoConstraints = false
            let customCenterX = NSLayoutConstraint(item: customView, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: verticalOffset.x)
            let customCenterY = NSLayoutConstraint(item: customView, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1.0, constant: verticalOffset.y)
            self.contentView.addSubview(customView)
            self.contentView.addConstraints([customCenterX, customCenterY])
            customView.widthAnchor.constraint(equalToConstant: customView.frame.size.width).isActive = true
            customView.heightAnchor.constraint(equalToConstant: customView.frame.size.height).isActive = true
            
        } else {
            
            // MARK: - content stack view contraints
            
            self.textStackView.addArrangedSubview(titleLabel)
            self.textStackView.addArrangedSubview(detailLabel)
            self.contentStackView.addArrangedSubview(imageView)
            self.contentStackView.addArrangedSubview(textStackView)
            
            let contentStackCenterX = NSLayoutConstraint(item: contentStackView, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            let contentStackCenterY = NSLayoutConstraint(item: contentStackView, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1.0, constant: verticalOffset.y)
            let contentStackLeading = NSLayoutConstraint(item: contentStackView, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1.0, constant: 15.0)
            let contentStackTrailing = NSLayoutConstraint(item: contentStackView, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: -15.0)
            contentStackView.spacing = self.verticalSpaceBetweenImageTitle
            textStackView.spacing = self.verticalSpaceBetweenTitleDetail
            self.contentView.addSubview(contentStackView)
            self.contentView.addConstraints([contentStackCenterX, contentStackCenterY, contentStackLeading, contentStackTrailing])
            
            let buttonCenterX = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            let buttonTop = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.contentStackView, attribute: .bottom, multiplier: 1.0, constant: verticalSpaceBetweenDetailButton)
            self.contentView.addSubview(button)
            self.contentView.addConstraints([buttonCenterX, buttonTop])
            
            if !canShowImage() {
                self.imageView.removeFromSuperview()
            }
            if !canShowTitle() {
                self.titleLabel.removeFromSuperview()
            }
            if !canShowDetail() {
                self.detailLabel.removeFromSuperview()
            }
            if !canShowButton() {
                self.button.removeFromSuperview()
            }
        }
    }
    
    private func removeAllConstraints() {
        self.removeConstraints(self.constraints)
        self.contentView.removeConstraints(self.contentView.constraints)
    }
    
    func prepareForReuse() {
        for subview in self.contentView.subviews {
            subview.removeFromSuperview()
        }
        self.removeAllConstraints()
    }
    
    private func canShowImage() -> Bool {
        return imageView.image != nil && imageView.superview != nil
    }
    
    private func canShowTitle() -> Bool {
        if let title = titleLabel.attributedText?.string, !title.isEmpty {
            return titleLabel.superview != nil
        }
        return false
    }
    
    private func canShowDetail() -> Bool {
        if let detail = detailLabel.attributedText?.string, !detail.isEmpty  {
            return detailLabel.superview != nil
        }
        return false
    }
    
    private func canShowButton() -> Bool {
        if let title = button.attributedTitle(for: .normal)?.string, !title.isEmpty {
            return button.superview != nil
        }
        return false
    }
    
    func didTapButton(sender: UIButton) {
        let stringFromSelector = NSStringFromSelector(#selector(UITableView.empty_didTapDataButton(sender:)))
        let selector = NSSelectorFromString(stringFromSelector)
        if let scrollview = self.superview {
            if scrollview.responds(to: selector) {
                scrollview.perform(selector, with: sender, afterDelay: 0.0)
            }
        }
    }
}
