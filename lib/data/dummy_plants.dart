import 'package:sprig/core/models/plant.dart';

/// Data dummy katalog tanaman. Tanggal siram dibuat relatif terhadap [now]
/// supaya demo selalu menampilkan campuran status: terlambat, hari ini, besok.
List<Plant> buildDummyPlants(DateTime now) {
  DateTime ago(int days) => now.subtract(Duration(days: days));

  return <Plant>[
    Plant(
      id: 'p01',
      name: 'Monstera',
      latinName: 'Monstera deliciosa',
      description:
          'Tanaman hias berdaun lebar dengan belahan khas. Tumbuh cepat dan cocok untuk memberi kesan tropis di ruang tamu.',
      category: PlantCategory.indoor,
      light: LightLevel.medium,
      waterEveryDays: 7,
      art: PlantArtStyle.leafy,
      tintIndex: 0,
      tips: const <String>[
        'Siram saat 3 cm tanah bagian atas sudah kering.',
        'Lap daun dengan kain lembap agar bebas debu.',
        'Beri tiang penyangga agar tumbuh tegak.',
      ],
      isFavorite: true,
      inGarden: true,
      lastWatered: ago(6),
    ),
    Plant(
      id: 'p02',
      name: 'Lidah Mertua',
      latinName: 'Sansevieria trifasciata',
      description:
          'Sangat tangguh dan jarang rewel. Pilihan tepat untuk pemula dan ruangan dengan cahaya terbatas.',
      category: PlantCategory.indoor,
      light: LightLevel.low,
      waterEveryDays: 14,
      art: PlantArtStyle.snake,
      tintIndex: 1,
      tips: const <String>[
        'Jangan terlalu sering disiram, akar mudah busuk.',
        'Tahan di ruangan dengan cahaya rendah.',
      ],
      inGarden: true,
      lastWatered: ago(14),
    ),
    Plant(
      id: 'p03',
      name: 'Kaktus Mini',
      latinName: 'Mammillaria elongata',
      description:
          'Kaktus kecil yang lucu untuk meja kerja. Menyimpan air di batangnya sehingga tahan kering.',
      category: PlantCategory.succulent,
      light: LightLevel.bright,
      waterEveryDays: 14,
      art: PlantArtStyle.cactus,
      tintIndex: 2,
      tips: const <String>[
        'Letakkan di dekat jendela yang terkena matahari.',
        'Gunakan media tanam berpasir yang cepat kering.',
      ],
    ),
    Plant(
      id: 'p04',
      name: 'Echeveria',
      latinName: 'Echeveria elegans',
      description:
          'Sukulen berbentuk mawar dengan daun tebal kebiruan. Cantik dipadukan dalam pot kecil.',
      category: PlantCategory.succulent,
      light: LightLevel.bright,
      waterEveryDays: 10,
      art: PlantArtStyle.rosette,
      tintIndex: 3,
      tips: const <String>[
        'Siram ke tanah, hindari menyiram langsung ke rosetnya.',
        'Butuh banyak cahaya agar warnanya tetap kompak.',
        'Pot wajib memiliki lubang drainase.',
      ],
      inGarden: true,
      lastWatered: ago(11),
    ),
    Plant(
      id: 'p05',
      name: 'Paku Boston',
      latinName: 'Nephrolepis exaltata',
      description:
          'Daun menjuntai yang rimbun dan menyegarkan. Menyukai udara lembap dan tanah yang selalu sedikit basah.',
      category: PlantCategory.indoor,
      light: LightLevel.medium,
      waterEveryDays: 3,
      art: PlantArtStyle.fern,
      tintIndex: 0,
      tips: const <String>[
        'Jaga tanah tetap lembap, tetapi tidak becek.',
        'Semprot daun dengan air untuk menambah kelembapan.',
      ],
    ),
    Plant(
      id: 'p06',
      name: 'Kemangi',
      latinName: 'Ocimum basilicum',
      description:
          'Tanaman herbal beraroma segar untuk bumbu masakan. Rajin dipanen justru membuatnya makin lebat.',
      category: PlantCategory.herb,
      light: LightLevel.bright,
      waterEveryDays: 2,
      art: PlantArtStyle.herb,
      tintIndex: 1,
      tips: const <String>[
        'Petik pucuknya secara rutin agar bercabang.',
        'Butuh sinar matahari langsung beberapa jam sehari.',
      ],
      isFavorite: true,
      inGarden: true,
      lastWatered: ago(1),
    ),
    Plant(
      id: 'p07',
      name: 'Lavender',
      latinName: 'Lavandula angustifolia',
      description:
          'Bunga ungu harum yang menenangkan. Cocok di tempat terang dengan sirkulasi udara baik.',
      category: PlantCategory.herb,
      light: LightLevel.bright,
      waterEveryDays: 5,
      art: PlantArtStyle.herb,
      tintIndex: 4,
      tips: const <String>[
        'Beri pot besar dengan drainase yang baik.',
        'Pangkas bunga yang layu agar tumbuh bunga baru.',
      ],
    ),
    Plant(
      id: 'p08',
      name: 'Aloe Vera',
      latinName: 'Aloe vera',
      description:
          'Lidah buaya yang bermanfaat untuk perawatan kulit. Tumbuh subur dengan perawatan yang sederhana.',
      category: PlantCategory.succulent,
      light: LightLevel.bright,
      waterEveryDays: 12,
      art: PlantArtStyle.rosette,
      tintIndex: 1,
      tips: const <String>[
        'Biarkan tanah kering total di antara dua penyiraman.',
        'Pindahkan ke pot lebih besar saat anakannya banyak.',
      ],
      isFavorite: true,
    ),
    Plant(
      id: 'p09',
      name: 'Sirih Gading',
      latinName: 'Epipremnum aureum',
      description:
          'Tanaman rambat berdaun belang kuning. Bisa digantung maupun dirambatkan, dan mudah diperbanyak lewat stek.',
      category: PlantCategory.indoor,
      light: LightLevel.low,
      waterEveryDays: 7,
      art: PlantArtStyle.leafy,
      tintIndex: 2,
      tips: const <String>[
        'Stek batang di air untuk mendapat tanaman baru.',
        'Daun menguning tanda terlalu sering disiram.',
      ],
    ),
    Plant(
      id: 'p10',
      name: 'Mint',
      latinName: 'Mentha spicata',
      description:
          'Herbal beraroma sejuk untuk teh dan minuman. Tumbuh menyebar, sebaiknya ditanam di pot sendiri.',
      category: PlantCategory.herb,
      light: LightLevel.medium,
      waterEveryDays: 3,
      art: PlantArtStyle.herb,
      tintIndex: 3,
      tips: const <String>[
        'Suka tanah lembap, jangan sampai kering kerontang.',
        'Pangkas rutin agar tidak terlalu panjang.',
      ],
    ),
    Plant(
      id: 'p11',
      name: 'ZZ Plant',
      latinName: 'Zamioculcas zamiifolia',
      description:
          'Berdaun mengilap dan sangat tahan banting. Akarnya menyimpan air sehingga toleran terhadap lupa menyiram.',
      category: PlantCategory.indoor,
      light: LightLevel.low,
      waterEveryDays: 14,
      art: PlantArtStyle.snake,
      tintIndex: 4,
      tips: const <String>[
        'Siram sedikit, lebih baik kurang daripada berlebih.',
        'Cocok untuk ruang kerja dengan cahaya redup.',
      ],
    ),
    Plant(
      id: 'p12',
      name: 'Calathea',
      latinName: 'Calathea orbifolia',
      description:
          'Daun bulat bergaris perak yang bergerak mengikuti cahaya. Menyukai kelembapan tinggi dan air yang bersih.',
      category: PlantCategory.indoor,
      light: LightLevel.medium,
      waterEveryDays: 4,
      art: PlantArtStyle.leafy,
      tintIndex: 3,
      tips: const <String>[
        'Gunakan air bebas kaporit atau diamkan semalam.',
        'Hindari sinar matahari langsung agar daun tidak terbakar.',
      ],
    ),
    Plant(
      id: 'p13',
      name: 'Bougenville',
      latinName: 'Bougainvillea glabra',
      description:
          'Semak berbunga warna-warni yang betah di panas terik. Cantik untuk pagar dan teras.',
      category: PlantCategory.outdoor,
      light: LightLevel.bright,
      waterEveryDays: 3,
      art: PlantArtStyle.herb,
      tintIndex: 4,
      tips: const <String>[
        'Kurangi air sedikit menjelang masa berbunga.',
        'Pangkas setelah musim berbunga selesai.',
      ],
    ),
    Plant(
      id: 'p14',
      name: 'Palem Kuning',
      latinName: 'Dypsis lutescens',
      description:
          'Palem berdaun melengkung yang rimbun untuk taman dan teras. Memberi kesan teduh dan tropis.',
      category: PlantCategory.outdoor,
      light: LightLevel.bright,
      waterEveryDays: 4,
      art: PlantArtStyle.fern,
      tintIndex: 2,
      tips: const <String>[
        'Siram hingga air keluar dari lubang pot.',
        'Buang pelepah yang menguning agar tampil rapi.',
      ],
    ),
  ];
}
