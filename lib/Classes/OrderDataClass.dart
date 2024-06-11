class OrderData {
  final String quantity;
  final String totalPrice;

  OrderData.fromMap(Map<String, dynamic> data)
      : quantity = data['Quantity'] as String,
        totalPrice = data['Total'] as String;
}
