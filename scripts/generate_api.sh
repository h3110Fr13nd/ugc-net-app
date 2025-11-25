#!/bin/bash
# Generate Dart API client from running backend

# Ensure backend is running
echo "Checking if backend is running..."
if ! curl -s http://localhost:8000/openapi.json > /dev/null; then
    echo "Backend is not running at http://localhost:8000. Please start it first."
    exit 1
fi

echo "Downloading OpenAPI spec..."
curl -s http://localhost:8000/openapi.json -o openapi.json

echo "Running OpenAPI Generator..."
# Using a stable version of openapi-generator-cli
docker run --rm -u "$(id -u):$(id -g)" -v "${PWD}:/local" openapitools/openapi-generator-cli:v7.8.0 generate \
    -i /local/openapi.json \
    -g dart \
    -o /local/lib/generated_api \
    --additional-properties=pubName=net_api,pubVersion=1.0.0,pubDescription="OpenAPI API client"

echo "Cleaning up..."
rm openapi.json

echo "Getting dependencies..."
cd lib/generated_api

# Fix ValidationErrorLocInner (empty class issue)
echo "Fixing ValidationErrorLocInner..."
cat > lib/model/validation_error_loc_inner.dart <<EOF
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ValidationErrorLocInner {
  final dynamic value;
  ValidationErrorLocInner(this.value);

  static ValidationErrorLocInner? fromJson(dynamic value) {
    return ValidationErrorLocInner(value);
  }

  dynamic toJson() => value;

  @override
  String toString() => value.toString();
  
  @override
  bool operator ==(Object other) => 
    identical(this, other) || 
    other is ValidationErrorLocInner && value == other.value;

  @override
  int get hashCode => value.hashCode;

  static List<ValidationErrorLocInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ValidationErrorLocInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ValidationErrorLocInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}
EOF

# Remove redundant files generated due to schema titles
echo "Removing redundant files..."
rm lib/model/numeric_response.dart || true
rm lib/model/weight.dart || true

flutter pub get
cd ../..

echo "Done!"
