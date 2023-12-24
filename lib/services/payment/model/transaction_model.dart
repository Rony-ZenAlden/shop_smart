class Amount {
  String? total;
  String? currency;
  Details? details;

  Amount({this.total, this.currency, this.details});

  Amount.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    currency = json['currency'];
    details =
    json['details'] != null ? Details.fromJson(json['details']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['total'] = total;
    data['currency'] = currency;
    if (details != null) {
      data['details'] = details!.toJson();
    }
    return data;
  }
}

class Details {
  String? subtotal;
  String? shipping;
  int? shippingDiscount;

  Details({this.subtotal, this.shipping, this.shippingDiscount});

  Details.fromJson(Map<String, dynamic> json) {
    subtotal = json['subtotal'];
    shipping = json['shipping'];
    shippingDiscount = json['shipping_discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['subtotal'] = subtotal;
    data['shipping'] = shipping;
    data['shipping_discount'] = shippingDiscount;
    return data;
  }
}