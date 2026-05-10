/// Data model for entry slide content
class SlideData {
  final String imagePath;
  final String title;
  final String subtitle;
  final String description;
  final bool isFirstSlide;

  const SlideData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.description,
    this.isFirstSlide = false,
  });
}
