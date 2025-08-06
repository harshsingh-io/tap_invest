// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bond_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BondSummaryImpl _$$BondSummaryImplFromJson(Map<String, dynamic> json) =>
    _$BondSummaryImpl(
      logo: json['logo'] as String,
      isin: json['isin'] as String,
      rating: json['rating'] as String,
      companyName: json['company_name'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$BondSummaryImplToJson(_$BondSummaryImpl instance) =>
    <String, dynamic>{
      'logo': instance.logo,
      'isin': instance.isin,
      'rating': instance.rating,
      'company_name': instance.companyName,
      'tags': instance.tags,
    };
