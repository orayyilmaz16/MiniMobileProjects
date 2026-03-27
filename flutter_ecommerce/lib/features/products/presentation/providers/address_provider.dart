import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressModel {
  final String id;
  final String title; // Ev, İş vb.
  final String fullName;
  final String city;
  final String district;
  final String fullAddress;

  AddressModel({
    required this.id,
    required this.title,
    required this.fullName,
    required this.city,
    required this.district,
    required this.fullAddress,
  });

  AddressModel copyWith({
    String? title,
    String? fullName,
    String? city,
    String? district,
    String? fullAddress,
  }) {
    return AddressModel(
      id: id,
      title: title ?? this.title,
      fullName: fullName ?? this.fullName,
      city: city ?? this.city,
      district: district ?? this.district,
      fullAddress: fullAddress ?? this.fullAddress,
    );
  }
}

class AddressNotifier extends StateNotifier<List<AddressModel>> {
  AddressNotifier()
    : super([
        AddressModel(
          id: '1',
          title: 'Ev Adresim',
          fullName: 'Oray Yılmaz',
          city: 'Bursa',
          district: 'Nilüfer',
          fullAddress: 'Özlüce Mah. 212. Sokak No:5',
        ),
      ]);

  void addAddress(AddressModel address) => state = [...state, address];

  void deleteAddress(String id) =>
      state = state.where((a) => a.id != id).toList();

  void updateAddress(AddressModel updated) {
    state = [
      for (final a in state)
        if (a.id == updated.id) updated else a,
    ];
  }
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, List<AddressModel>>(
      (ref) => AddressNotifier(),
    );
