class AppTransaction {
    final String? id;
    final String? amount;
    final String? type;
    final String? description;
    final DateTime? date;
    final String? userId;
    final String? categoryId;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final Category? category;

    AppTransaction({
        this.id,
        this.amount,
        this.type,
        this.description,
        this.date,
        this.userId,
        this.categoryId,
        this.createdAt,
        this.updatedAt,
        this.category,
    });

    factory AppTransaction.fromJson(Map<String, dynamic> json) => AppTransaction(
        id: json["id"],
        amount: json["amount"],
        type: json["type"],
        description: json["description"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        userId: json["user_id"],
        categoryId: json["category_id"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        category: json["Category"] == null ? null : Category.fromJson(json["Category"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "type": type,
        "description": description,
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "user_id": userId,
        "category_id": categoryId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "Category": category?.toJson(),
    };
}

class Category {
    final String? name;
    final String? icon;
    final String? type;

    Category({
        this.name,
        this.icon,
        this.type,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json["name"],
        icon: json["icon"],
        type: json["type"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "icon": icon,
        "type": type,
    };
}