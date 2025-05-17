import 'package:apk_gizi/data/models/food.dart';

/// Daftar makanan (const) berdasarkan tujuan berat badan
const List<Food> kFoods = [
  // Menurunkan BB
  Food(name: 'Nasi Merah', calories: 165, description: 'Karbohidrat kompleks tinggi serat'),
  Food(name: 'Ubi Jalar Rebus', calories: 120, description: 'Karbo kompleks, rendah GI'),
  Food(name: 'Bayam Tumis', calories: 40, description: 'Sayuran hijau, kaya zat besi'),
  Food(name: 'Pepaya', calories: 55, description: 'Buah rendah kalori, kaya vitamin C'),
  Food(name: 'Ikan Tenggiri Pepes', calories: 200, description: 'Protein tanpa lemak'),
  Food(name: 'Tahu Kukus', calories: 80, description: 'Protein nabati rendah lemak'),

  // Menjaga BB
  Food(name: 'Beras Merah', calories: 170, description: 'Karbo kompleks, serat sedang'),
  Food(name: 'Roti Gandum', calories: 90, description: 'Karbo serat tinggi'),
  Food(name: 'Kentang Rebus', calories: 150, description: 'Sumber karbo medium GI'),
  Food(name: 'Ayam Tanpa Kulit', calories: 190, description: 'Protein rendah lemak'),
  Food(name: 'Alpukat', calories: 160, description: 'Lemak sehat tak jenuh'),
  Food(name: 'Tempe Goreng Ringan', calories: 180, description: 'Protein nabati, lemak sehat'),

  // Meningkatkan BB
  Food(name: 'Nasi Putih Porsi Besar', calories: 300, description: 'Karbohidrat padat energi'),
  Food(name: 'Ayam Goreng', calories: 280, description: 'Protein & lemak meningkat'),
  Food(name: 'Pisang Goreng', calories: 200, description: 'Camilan padat energi'),
  Food(name: 'Roti Isi Selai', calories: 220, description: 'Karbo + lemak + gula'),
  Food(name: 'Bolu Kukus', calories: 180, description: 'Camilan karbohidrat tinggi'),
  Food(name: 'Sayur Lodeh Bersantan', calories: 250, description: 'Sayur + lemak sehat'),

  // Tambahan – Menurunkan BB
  Food(name: 'Jagung Rebus', calories: 99, description: 'Sumber karbo dan serat. Satu tongkol sedang ≈ 99 kkal'),  
  Food(name: 'Kacang Hijau Rebus', calories: 105, description: 'Protein & serat nabati — 100 g'),  

  // Tambahan – Menjaga BB
  Food(name: 'Oatmeal', calories: 68, description: 'Serat larut, 100 g diseduh'),  
  Food(name: 'Telur Rebus', calories: 78, description: 'Protein tinggi, satu butir sedang'),  

  // Tambahan – Meningkatkan BB
  Food(name: 'Kacang Tanah Rebus', calories: 567, description: 'Lemak sehat & protein, 100 g'),  
  Food(name: 'Cokelat Hitam (70%)', calories: 546, description: 'Lemak & gula — 100 g' ),  
];
