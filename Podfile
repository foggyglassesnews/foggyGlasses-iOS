# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def import_public_pods
    
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'Firebase/Firestore'
    
    pod 'SwiftLinkPreview', '~> 3.0.0'
end

target 'Foggy Glasses' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Foggy Glasses
  
#  pod 'PopupDialog', '~> 0.9'
  pod 'PopupDialog'
  pod 'SideMenu'
  pod 'Pastel'
  import_public_pods
#  pod 'Firebase/Core'
#  pod 'Firebase/Auth'
#  pod 'Firebase/Database'
#  pod 'Firebase/Firestore'
  pod 'Firebase/Messaging'
  pod 'Firebase/DynamicLinks'
  pod 'Floaty', '~> 4.1.0'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  
  pod 'SDWebImage'

  pod 'Fabric', '~> 1.9.0'
  pod 'Crashlytics', '~> 3.12.0'

  target 'Foggy GlassesTests' do
    inherit! :search_paths
    # Pods for testing
  end
  

  target 'Foggy GlassesUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'Post To Groups' do
    use_frameworks!
    import_public_pods
end
