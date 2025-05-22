class Food {
  final String name;
  final int calories;
  final String description;

  // Tambahan fields:
  final String portion;               // Contoh: "1 piring (150 g)"
  final List<String> mealTime;        // Contoh: ["Pagi", "Siang"]
  final Map<String, int> macro;       // Persen makro: {'c':50,'p':20,'f':30}
  final int gi;                       // Glycemic Index
  final int fiber;                    // Serat (gram)
  final String imageAsset;            // Path aset gambar
  final String? referenceUrl;         // URL referensi (opsional)

  const Food({
    required this.name,
    required this.calories,
    required this.description,
    this.portion        = '',
    this.mealTime       = const [],
    this.macro          = const {'c': 0, 'p': 0, 'f': 0},
    this.gi             = 0,
    this.fiber          = 0,
    this.imageAsset     = '',
    this.referenceUrl,              // Ditambahkan untuk referensi
  });
}