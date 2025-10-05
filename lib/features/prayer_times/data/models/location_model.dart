class LocationModel {
  LocationModel({
    this.ip,
    this.countryCode,
    this.countryName,
    this.regionName,
    this.cityName,
    this.latitude,
    this.longitude,
    this.zipCode,
    this.timeZone,
    this.asn,
    this.as,
    this.isProxy,});

  LocationModel.fromJson(dynamic json) {
    ip = json['ip'];
    countryCode = json['country_code'];
    countryName = json['country_name'];
    regionName = json['region_name'];
    cityName = json['city_name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    zipCode = json['zip_code'];
    timeZone = json['time_zone'];
    asn = json['asn'];
    as = json['as'];
    isProxy = json['is_proxy'];
  }

  String? ip;
  String? countryCode;
  String? countryName;
  String? regionName;
  String? cityName;
  num? latitude;
  num? longitude;
  String? zipCode;
  String? timeZone;
  String? asn;
  String? as;
  bool? isProxy;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ip'] = ip;
    map['country_code'] = countryCode;
    map['country_name'] = countryName;
    map['region_name'] = regionName;
    map['city_name'] = cityName;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['zip_code'] = zipCode;
    map['time_zone'] = timeZone;
    map['asn'] = asn;
    map['as'] = as;
    map['is_proxy'] = isProxy;
    return map;
  }

}