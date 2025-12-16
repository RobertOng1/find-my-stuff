/// Cloudinary configuration for image uploads.
/// 
/// To get these values:
/// 1. Go to cloudinary.com and log in
/// 2. Cloud Name is on your Dashboard
/// 3. Upload Preset must be created in Settings → Upload → Upload presets
///    Make sure it's set to "Unsigned" signing mode
class CloudinaryConfig {
  /// Your Cloudinary cloud name (found on Dashboard)
  static const String cloudName = 'denbiq9cp';
  
  /// The unsigned upload preset name (created in Settings → Upload)
  static const String uploadPreset = 'find_my_stuff';
  
  /// Cloudinary upload URL
  static String get uploadUrl => 
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
}
