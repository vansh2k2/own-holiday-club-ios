class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? gender;
  final String? dob;
  final String? maritalStatus;
  final String? anniversary;
  final String? occupation;
  final String? profileImage;
  final String? membershipId;
  final bool? isActive;
  final UserMembershipModel? membership;
  final SpouseModel? spouse;
  final UserDocuments? documents;
  final List<BookingModel>? holidayBookings;
  final List<PaymentModel>? payments;
  final AddressModel? residenceAddress;
  final AddressModel? officeAddress;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.gender,
    this.dob,
    this.maritalStatus,
    this.anniversary,
    this.occupation,
    this.profileImage,
    this.membershipId,
    this.isActive,
    this.membership,
    this.spouse,
    this.documents,
    this.holidayBookings,
    this.payments,
    this.residenceAddress,
    this.officeAddress,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      gender: json['gender'],
      dob: json['dob'],
      maritalStatus: json['maritalStatus'],
      anniversary: json['anniversary'],
      occupation: json['occupation'],
      profileImage: json['documents']?['profileImage']?['url'],
      membershipId: json['membershipId'],
      isActive: json['membership']?['status'] == 'Active',
      membership: json['membership'] != null ? UserMembershipModel.fromJson(json['membership']) : null,
      spouse: json['spouse'] != null ? SpouseModel.fromJson(json['spouse']) : null,
      documents: json['documents'] != null ? UserDocuments.fromJson(json['documents']) : null,
      holidayBookings: json['holidayBookings'] != null 
          ? (json['holidayBookings'] as List).map((i) => BookingModel.fromJson(i)).toList() 
          : null,
      payments: json['payments'] != null 
          ? (json['payments'] as List).map((i) => PaymentModel.fromJson(i)).toList() 
          : null,
      residenceAddress: json['residenceAddress'] != null ? AddressModel.fromJson(json['residenceAddress']) : null,
      officeAddress: json['officeAddress'] != null ? AddressModel.fromJson(json['officeAddress']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'mobile': mobile,
    'gender': gender,
    'dob': dob,
    'maritalStatus': maritalStatus,
    'anniversary': anniversary,
    'occupation': occupation,
    'membershipId': membershipId,
    'membership': membership?.toJson(),
    'spouse': spouse?.toJson(),
    'documents': documents?.toJson(),
    'holidayBookings': holidayBookings?.map((i) => i.toJson()).toList(),
    'payments': payments?.map((i) => i.toJson()).toList(),
    'residenceAddress': residenceAddress?.toJson(),
    'officeAddress': officeAddress?.toJson(),
  };
}

class UserMembershipModel {
  final String? name;
  final String? tierId;
  final String? status;
  final String? validUntil;
  final String? purchasedAt;
  final String? duration;
  final String? period;
  final int? baseDurationYears;
  final int? bonusYears;
  final int? totalDurationYears;
  final String? nightsPerYear;
  final String? price;

  UserMembershipModel({
    this.name,
    this.tierId,
    this.status,
    this.validUntil,
    this.purchasedAt,
    this.duration,
    this.period,
    this.baseDurationYears,
    this.bonusYears,
    this.totalDurationYears,
    this.nightsPerYear,
    this.price,
  });

  factory UserMembershipModel.fromJson(Map<String, dynamic> json) {
    return UserMembershipModel(
      name: json['name'],
      tierId: json['tierId'],
      status: json['status'],
      validUntil: json['validUntil'],
      purchasedAt: json['purchasedAt'],
      duration: json['duration'],
      period: json['period'],
      baseDurationYears: json['baseDurationYears'],
      bonusYears: json['bonusYears'],
      totalDurationYears: json['totalDurationYears'],
      nightsPerYear: json['nightsPerYear'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'tierId': tierId,
    'status': status,
    'validUntil': validUntil,
    'purchasedAt': purchasedAt,
    'duration': duration,
    'period': period,
    'baseDurationYears': baseDurationYears,
    'bonusYears': bonusYears,
    'totalDurationYears': totalDurationYears,
    'nightsPerYear': nightsPerYear,
    'price': price,
  };
}

class SpouseModel {
  final String? name;
  final String? dob;
  final String? email;
  final String? mobile;

  SpouseModel({this.name, this.dob, this.email, this.mobile});

  factory SpouseModel.fromJson(Map<String, dynamic> json) {
    return SpouseModel(
      name: json['name'],
      dob: json['dob'],
      email: json['email'],
      mobile: json['mobile'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'dob': dob,
    'email': email,
    'mobile': mobile,
  };
}

class UserDocuments {
  final String? idProofType;
  final String? idProofUrl;
  final String? addressProofType;
  final String? addressProofUrl;

  UserDocuments({this.idProofType, this.idProofUrl, this.addressProofType, this.addressProofUrl});

  factory UserDocuments.fromJson(Map<String, dynamic> json) {
    return UserDocuments(
      idProofType: json['idProof']?['proofType'],
      idProofUrl: json['idProof']?['url'],
      addressProofType: json['addressProof']?['proofType'],
      addressProofUrl: json['addressProof']?['url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'idProof': {'proofType': idProofType, 'url': idProofUrl},
    'addressProof': {'proofType': addressProofType, 'url': addressProofUrl},
  };
}

class BookingModel {
  final String? id;
  final int? slotNumber;
  final String? place;
  final String? checkIn;
  final String? checkOut;
  final String? status;
  final String? requestedAt;
  final String? confirmedAt;
  final int? adults;
  final int? kids;

  BookingModel({
    this.id,
    this.slotNumber,
    this.place,
    this.checkIn,
    this.checkOut,
    this.status,
    this.requestedAt,
    this.confirmedAt,
    this.adults,
    this.kids,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'],
      slotNumber: json['slotNumber'],
      place: json['place'],
      checkIn: json['checkIn'],
      checkOut: json['checkOut'],
      status: json['status'],
      requestedAt: json['requestedAt'],
      confirmedAt: json['confirmedAt'],
      adults: json['adults'],
      kids: json['kids'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'slotNumber': slotNumber,
    'place': place,
    'checkIn': checkIn,
    'checkOut': checkOut,
    'status': status,
    'requestedAt': requestedAt,
    'confirmedAt': confirmedAt,
    'adults': adults,
    'kids': kids,
  };
}

class PaymentModel {
  final String? id;
  final String? orderId;
  final String? paymentId;
  final String? amount;
  final String? currency;
  final String? status;
  final String? method;
  final String? paidAt;
  final String? membershipTierName;
  final String? period;
  final String? email;
  final String? contact;
  final String? wallet;
  final String? bank;
  final InvoiceModel? invoice;

  PaymentModel({
    this.id,
    this.orderId,
    this.paymentId,
    this.amount,
    this.currency,
    this.status,
    this.method,
    this.paidAt,
    this.membershipTierName,
    this.period,
    this.email,
    this.contact,
    this.wallet,
    this.bank,
    this.invoice,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'],
      orderId: json['orderId'],
      paymentId: json['paymentId'],
      amount: json['amount']?.toString(),
      currency: json['currency'],
      status: json['status'],
      method: json['method'],
      paidAt: json['paidAt'],
      membershipTierName: json['membershipTierName'],
      period: json['period'],
      email: json['email'],
      contact: json['contact'],
      wallet: json['wallet'],
      bank: json['bank'],
      invoice: json['invoice'] != null ? InvoiceModel.fromJson(json['invoice']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'orderId': orderId,
    'paymentId': paymentId,
    'amount': amount,
    'currency': currency,
    'status': status,
    'method': method,
    'paidAt': paidAt,
    'membershipTierName': membershipTierName,
    'period': period,
    'email': email,
    'contact': contact,
    'wallet': wallet,
    'bank': bank,
    'invoice': invoice?.toJson(),
  };
}

class InvoiceModel {
  final String? url;
  final String? name;
  final String? format;

  InvoiceModel({this.url, this.name, this.format});

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      url: json['url'],
      name: json['name'],
      format: json['format'],
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'name': name,
    'format': format,
  };
}

class AddressModel {
  final String? houseNo;
  final String? addressLine;
  final String? city;
  final String? state;
  final String? country;
  final String? pin;
  final String? phone;

  AddressModel({
    this.houseNo,
    this.addressLine,
    this.city,
    this.state,
    this.country,
    this.pin,
    this.phone,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      houseNo: json['houseNo'],
      addressLine: json['addressLine'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pin: json['pin'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() => {
    'houseNo': houseNo,
    'addressLine': addressLine,
    'city': city,
    'state': state,
    'country': country,
    'pin': pin,
    'phone': phone,
  };
}
