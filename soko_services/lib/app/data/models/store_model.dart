class Company {
  String? companyId;
  String? companyName;
  String? companyPhone;
  String? companyEmail;
  String? ownerName;
  Null companyStatus;
  String? gstNumber;
  String? logo;
  String? banner;
  String? companyCoupon;
  String? ownerEmail;
  String? ownerPhone;
  String? companyAddress;
  String? companyCity;
  String? companyState;
  String? companyPinCode;
  String? companyFssAi;
  String? companyProductCategory;
  String? deliveryBetween;
  String? companyEstDate;
  double? averageRating;
  int? totalRating;
  int? noOfRatings;
  String? companyRegisteredAt;
  String? updatedAt;
  String? freeDeliveryCost;
  String? minimumOrderCost;
  String? socialMediaLink;
  String? about;

  Company({
    this.companyId,
    this.companyName,
    this.companyPhone,
    this.companyEmail,
    this.ownerName,
    this.companyStatus,
    this.gstNumber,
    this.logo,
    this.banner,
    this.companyCoupon,
    this.ownerEmail,
    this.ownerPhone,
    this.companyAddress,
    this.companyCity,
    this.companyState,
    this.companyPinCode,
    this.companyFssAi,
    this.companyProductCategory,
    this.deliveryBetween,
    this.companyEstDate,
    this.averageRating,
    this.totalRating,
    this.noOfRatings,
    this.companyRegisteredAt,
    this.updatedAt,
    this.freeDeliveryCost,
    this.minimumOrderCost,
    this.socialMediaLink,
    this.about,
  });

  Company.fromJson(Map<String, dynamic> json) {
    companyId = json['companyId'];
    companyName = json['companyName'];
    companyPhone = json['companyPhone'];
    companyEmail = json['companyEmail'];
    ownerName = json['ownerName'];
    companyStatus = json['companyStatus'];
    gstNumber = json['gstNumber'];
    logo = json['logo'];
    banner = json['banner'];
    companyCoupon = json['companyCoupon'];
    ownerEmail = json['ownerEmail'];
    ownerPhone = json['ownerPhone'];
    companyAddress = json['companyAddress'];
    companyCity = json['companyCity'];
    companyState = json['companyState'];
    companyPinCode = json['companyPinCode'];
    companyFssAi = json['companyFssAi'];
    companyProductCategory = json['companyProductCategory'];
    deliveryBetween = json['deliveryBetween'];
    companyEstDate = json['companyEstDate'];
    averageRating = json['averageRating'];
    totalRating = json['totalRating'];
    noOfRatings = json['noOfRatings'];
    companyRegisteredAt = json['companyRegisteredAt'];
    updatedAt = json['updatedAt'];
    freeDeliveryCost = json['freeDeliveryCost'];
    minimumOrderCost = json['minimumOrderCost'];
    socialMediaLink = json['socialMediaLink'];
    about = json['about'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['companyId'] = this.companyId;
    data['companyName'] = this.companyName;
    data['companyPhone'] = this.companyPhone;
    data['companyEmail'] = this.companyEmail;
    data['ownerName'] = this.ownerName;
    data['companyStatus'] = this.companyStatus;
    data['gstNumber'] = this.gstNumber;
    data['logo'] = this.logo;
    data['banner'] = this.banner;
    data['companyCoupon'] = this.companyCoupon;
    data['ownerEmail'] = this.ownerEmail;
    data['ownerPhone'] = this.ownerPhone;
    data['companyAddress'] = this.companyAddress;
    data['companyCity'] = this.companyCity;
    data['companyState'] = this.companyState;
    data['companyPinCode'] = this.companyPinCode;
    data['companyFssAi'] = this.companyFssAi;
    data['companyProductCategory'] = this.companyProductCategory;
    data['deliveryBetween'] = this.deliveryBetween;
    data['companyEstDate'] = this.companyEstDate;
    data['averageRating'] = this.averageRating;
    data['totalRating'] = this.totalRating;
    data['noOfRatings'] = this.noOfRatings;
    data['companyRegisteredAt'] = this.companyRegisteredAt;
    data['updatedAt'] = this.updatedAt;
    data['freeDeliveryCost'] = this.freeDeliveryCost;
    data['minimumOrderCost'] = this.minimumOrderCost;
    data['socialMediaLink'] = this.socialMediaLink;
    data['about'] = this.about;
    return data;
  }
}
