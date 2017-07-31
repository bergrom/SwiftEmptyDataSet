Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "SwiftEmptyDataSet"
s.summary = "SwiftEmptyDataSet is swift version of the DZNEmptyDataSet.A drop-in UITableView/UICollectionView superclass category for showing empty datasets whenever the view has no content to display."
s.requires_arc = true

# 2
s.version = "0.1.0"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Guo Luo" => "bergrom@iCloud.com" }

# 5 - Replace this URL with your own Github page's URL (from the address bar)
# s.homepage = "https://github.com/bergrom/SwiftEmptyDataSet"


# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/bergrom/SwiftEmptyDataSet.git", :tag => "#{s.version}"}


# 7
s.framework = "UIKit"

# 8
s.source_files = "SwiftEmptyDataSet/**/*.{swift}"

# 9
s.resources = "SwiftEmptyDataSet/**/*.{png,jpeg,jpg,storyboard,xib}"
end
