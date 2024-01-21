class StripeModel {
  String? paymentIntent;
  String? ephemeralKey;
  String? customer;
  String? publishableKey;

  StripeModel(
      {this.paymentIntent,
      this.ephemeralKey,
      this.customer,
      this.publishableKey});

  StripeModel.fromJson(Map<String, dynamic> json) {
    paymentIntent = json['paymentIntent'];
    ephemeralKey = json['ephemeralKey'];
    customer = json['customer'];
    publishableKey = json['publishableKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['paymentIntent'] = this.paymentIntent;
    data['ephemeralKey'] = this.ephemeralKey;
    data['customer'] = this.customer;
    data['publishableKey'] = this.publishableKey;
    return data;
  }
}
