class ReviewModel {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final String date;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      userName: json['userName'] ?? 'Anonim Kullanıcı',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
    );
  }
}

class ProductModel {
  final String id;
  final String title;
  final String category; // Yeni Alan
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final List<ReviewModel> reviews;

  ProductModel({
    required this.id,
    required this.title,
    required this.category, // Zorunlu hale getirildi
    required this.description,
    required this.price,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.reviews = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'Genel', // API'den gelmezse 'Genel' ata
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
                .map((i) => ReviewModel.fromJson(i))
                .toList()
          : [],
    );
  }

  String? get name => null;

  String? get image => null;
}

final List<ProductModel> mockProducts = [
  ProductModel(
    id: "1",
    title: "Sony A7 IV Aynasız Kamera",
    category: "Makine",
    description:
        "33 MP full-frame sensör ve 4K 60p video kaydı ile mükemmel hibrit çözüm.",
    price: 84999.00,
    imageUrl: "https://images.unsplash.com/photo-1516035069371-29a1b244cc32",
    rating: 4.9,
    reviewCount: 156,
    reviews: [
      ReviewModel(
        id: "r1",
        userName: "Oray Y.",
        rating: 5.0,
        comment: "Otomatik odaklama hızı inanılmaz.",
        date: "12 Mart 2026",
      ),
      ReviewModel(
        id: "r2",
        userName: "Elif S.",
        rating: 4.5,
        comment: "Gövde kalitesi çok iyi.",
        date: "05 Mart 2026",
      ),
    ],
  ),
  ProductModel(
    id: "2",
    title: "Canon RF 50mm f/1.2L USM",
    category: "Lens",
    description:
        "Portre fotoğrafçılığının zirvesi. f/1.2 diyafram ile eşsiz bokeh etkisi.",
    price: 92450.00,
    imageUrl: "https://images.unsplash.com/photo-1616423640778-28d1b53229bd",
    rating: 5.0,
    reviewCount: 42,
    reviews: [
      ReviewModel(
        id: "r3",
        userName: "Mert K.",
        rating: 5.0,
        comment: "Hayatımda kullandığım en keskin lens.",
        date: "22 Şubat 2026",
      ),
    ],
  ),
  ProductModel(
    id: "3",
    title: "DJI Mavic 3 Pro Drone",
    category: "Drone",
    description:
        "Hasselblad kamera sistemi ve üçlü lens düzeneği ile profesyonel çekim.",
    price: 74900.00,
    imageUrl: "https://images.unsplash.com/photo-1579829366248-204fe8413f31",
    rating: 4.8,
    reviewCount: 28,
    reviews: [
      ReviewModel(
        id: "r4",
        userName: "Arda T.",
        rating: 4.5,
        comment: "Görüntü kalitesi sinematik.",
        date: "10 Ocak 2026",
      ),
    ],
  ),
  ProductModel(
    id: "4",
    title: "GoPro HERO12 Black",
    category: "Makine",
    description:
        "HDR video ve HyperSmooth 6.0 stabilizasyon ile macera tutkunları için.",
    price: 15499.00,
    imageUrl: "https://images.unsplash.com/photo-1565967511849-76a60a516170",
    rating: 4.7,
    reviewCount: 210,
    reviews: [
      ReviewModel(
        id: "r5",
        userName: "Can B.",
        rating: 5.0,
        comment: "Sarsıntı engelleme sihir gibi.",
        date: "02 Mart 2026",
      ),
    ],
  ),
  ProductModel(
    id: "5",
    title: "Rode Wireless PRO Mikrofon",
    category: "Aksesuar",
    description:
        "32-bit float dahili kayıt yeteneğine sahip kompakt kablosuz mikrofon.",
    price: 18750.00,
    imageUrl: "https://images.unsplash.com/photo-1590602847861-f357a9332bbc",
    rating: 4.9,
    reviewCount: 64,
    reviews: [
      ReviewModel(
        id: "r6",
        userName: "Deniz H.",
        rating: 5.0,
        comment: "Ses kalitesi stüdyo seviyesinde.",
        date: "15 Şubat 2026",
      ),
    ],
  ),

  ProductModel(
    id: "7",
    title: "Manfrotto Befree Karbon",
    category: "Aksesuar",
    description:
        "Seyahat eden fotoğrafçılar için ultra hafif karbon fiber gövde.",
    price: 12400.00,
    imageUrl: "https://images.unsplash.com/photo-1517232115160-ff93364542dd",
    rating: 4.8,
    reviewCount: 34,
    reviews: [],
  ),
  ProductModel(
    id: "8",
    title: "Samsung T7 Shield 2TB SSD",
    category: "Düzenleme",
    description:
        "Darbeye dayanıklı, 1050MB/s okuma hızı ile hızlı kurgu imkanı.",
    price: 5999.00,
    imageUrl: "https://images.unsplash.com/photo-1597740985671-2a8a3b80502e",
    rating: 4.9,
    reviewCount: 112,
    reviews: [
      ReviewModel(
        id: "r8",
        userName: "Emre A.",
        rating: 5.0,
        comment: "Hızı muazzam.",
        date: "01 Mart 2026",
      ),
    ],
  ),

  ProductModel(
    id: "10",
    title: "Zhiyun Crane 4 Gimbal",
    category: "Aksesuar",
    description: "Büyük kamera kurulumları için profesyonel sabitleyici.",
    price: 22800.00,
    imageUrl: "https://images.unsplash.com/photo-1533310266094-8898a03807dd",
    rating: 4.7,
    reviewCount: 22,
    reviews: [
      ReviewModel(
        id: "r10",
        userName: "Kaan V.",
        rating: 4.5,
        comment: "Dengelemesi çok kolaylaşmış.",
        date: "05 Şubat 2026",
      ),
    ],
  ),
];
