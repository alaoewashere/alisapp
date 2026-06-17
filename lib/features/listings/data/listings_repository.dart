import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/public_profiles_query.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/listing_package_utils.dart';
import '../../../shared/models/filter_model.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/models/report_model.dart';

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  return ListingsRepository(ref.watch(supabaseClientProvider));
});

class ListingsRepository {
  ListingsRepository(this._client);

  final SupabaseClient _client;
  static const _uuid = Uuid();

  static const _listingSelect = '''
    *,
    categories(name_ar),
    listing_images(id, listing_id, storage_path, sort_order, is_primary, url)
  ''';

  static const _listingDetailSelect = '''
    *,
    categories(name_ar, parent_id, parent:categories!categories_parent_id_fkey(name_ar)),
    listing_images(id, listing_id, storage_path, sort_order, is_primary, url)
  ''';

  String _publicUrl(String path) {
    if (path.startsWith('http')) return path;
    return _client.storage.from(AppConstants.storageBucket).getPublicUrl(path);
  }

  Future<List<ListingModel>> getFeaturedListings({
    int limit = 10,
    String? userIdForFavorites,
  }) async {
    final data = await _client
        .from('listings')
        .select(_listingSelect)
        .eq('status', 'approved')
        .eq('availability', 'active')
        .or(
          'is_featured.eq.true,'
          'metadata->>listing_package.eq.premium,'
          'metadata->>listing_package.eq.مميز,'
          'metadata->>listing_package.eq.featured',
        )
        .order('created_at', ascending: false)
        .limit(limit);

    final listings = await _mapListings(data, userIdForFavorites);
    return listings.where((listing) => listing.isPremiumListing).toList();
  }

  Future<List<ListingModel>> getRecentListings({
    int limit = 20,
    String? userIdForFavorites,
  }) async {
    final data = await _client
        .from('listings')
        .select(_listingSelect)
        .eq('status', 'approved')
        .eq('availability', 'active')
        .eq('is_featured', false)
        .or(
          'metadata->>listing_package.is.null,'
          'metadata->>listing_package.eq.standard,'
          'metadata->>listing_package.eq.pro',
        )
        .order('created_at', ascending: false)
        .limit(limit + 10);

    final listings = await _mapListings(data, userIdForFavorites);
    return _sortByPackagePriority(
      listings.where((listing) => !listing.isPremiumListing).take(limit).toList(),
    );
  }

  Future<List<ListingModel>> getListingsByCategory(
    String categoryId, {
    String? listingType,
    FilterModel? filter,
    int page = 0,
    int pageSize = AppConstants.listingsPageSize,
    String? userIdForFavorites,
  }) async {
    final filteredQuery = _filteredListingsQuery(
      categoryId: int.parse(categoryId),
      listingType: listingType,
      filter: filter,
    );

    final data = await filteredQuery
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return _sortByPackagePriority(
      await _mapListings(data, userIdForFavorites),
    );
  }

  Future<List<ListingModel>> searchListings(
    FilterModel filter, {
    int page = 0,
    int pageSize = AppConstants.listingsPageSize,
    String? userIdForFavorites,
  }) async {
    final filteredQuery = _filteredListingsQuery(filter: filter);

    final data = await _applySorting(filteredQuery, filter.sortBy).range(
      page * pageSize,
      (page + 1) * pageSize - 1,
    );

    return _sortByPackagePriority(
      await _mapListings(data, userIdForFavorites),
    );
  }

  Future<int> countSearchResults(FilterModel filter) async {
    final filteredQuery = _filteredListingsQuery(filter: filter, select: 'id');
    final data = await filteredQuery;
    return (data as List).length;
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final data = await _client
        .from('listings')
        .select('title_ar, title')
        .eq('status', 'approved')
        .eq('availability', 'active')
        .or('title_ar.ilike.%$trimmed%,title.ilike.%$trimmed%')
        .limit(20);

    final seen = <String>{};
    final results = <String>[];
    for (final row in data as List) {
      final title =
          (row['title_ar'] as String?) ?? (row['title'] as String?) ?? '';
      final key = title.trim();
      if (key.isNotEmpty && seen.add(key)) {
        results.add(key);
        if (results.length >= 8) break;
      }
    }
    return results;
  }

  Future<List<ListingModel>> searchListingsLegacy(
    String query, {
    FilterModel? filter,
    int page = 0,
    int pageSize = AppConstants.listingsPageSize,
    String? userIdForFavorites,
  }) async {
    final merged = (filter ?? const FilterModel()).copyWith(
      query: query.trim().isEmpty ? filter?.query : query.trim(),
    );
    return searchListings(
      merged,
      page: page,
      pageSize: pageSize,
      userIdForFavorites: userIdForFavorites,
    );
  }

  Future<List<ListingModel>> fetchApproved({
    int page = 0,
    int pageSize = AppConstants.listingsPageSize,
    FilterModel filters = const FilterModel(),
    String? userIdForFavorites,
  }) async {
    final filteredQuery = _filteredListingsQuery(filter: filters);

    final data = await filteredQuery
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return _mapListings(data, userIdForFavorites);
  }

  Future<List<ListingModel>> search({
    required FilterModel filters,
    int page = 0,
    int pageSize = AppConstants.listingsPageSize,
    String? userIdForFavorites,
  }) async {
    return searchListings(
      filters,
      page: page,
      pageSize: pageSize,
      userIdForFavorites: userIdForFavorites,
    );
  }

  Future<ListingModel?> fetchById(String id, {String? userIdForFavorites}) {
    return getListingById(id, userIdForFavorites: userIdForFavorites);
  }

  Future<ListingModel?> getListingById(
    String id, {
    String? userIdForFavorites,
  }) async {
    dynamic data;
    try {
      data = await _client
          .from('listings')
          .select(_listingDetailSelect)
          .eq('id', id)
          .maybeSingle();
    } catch (_) {
      data = await _client
          .from('listings')
          .select(_listingSelect)
          .eq('id', id)
          .maybeSingle();
    }

    if (data == null) return null;

    final listings = await _mapListings([data], userIdForFavorites);
    return listings.isEmpty ? null : listings.first;
  }

  Future<ListingModel?> getListingByReferenceNo(
    int referenceNo, {
    String? userIdForFavorites,
  }) async {
    dynamic data;
    try {
      data = await _client
          .from('listings')
          .select(_listingDetailSelect)
          .eq('reference_no', referenceNo)
          .maybeSingle();
    } catch (_) {
      data = await _client
          .from('listings')
          .select(_listingSelect)
          .eq('reference_no', referenceNo)
          .maybeSingle();
    }

    if (data == null) return null;

    final listings = await _mapListings([data], userIdForFavorites);
    return listings.isEmpty ? null : listings.first;
  }

  Future<List<ListingModel>> getSellerListings(
    String sellerId, {
    String? excludeId,
    int limit = 6,
  }) async {
    dynamic query = _client
        .from('listings')
        .select(_listingSelect)
        .eq('user_id', sellerId)
        .eq('status', 'approved')
        .eq('availability', 'active');

    if (excludeId != null) {
      query = query.neq('id', excludeId);
    }

    final data = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return _mapListings(data, null);
  }

  Future<int> countSellerActiveListings(String sellerId) async {
    final data = await _client
        .from('listings')
        .select('id')
        .eq('user_id', sellerId)
        .eq('status', 'approved')
        .eq('availability', 'active');

    return (data as List).length;
  }

  Future<void> patchListing({
    required String listingId,
    required String userId,
    required Map<String, dynamic> fields,
    required List<Map<String, dynamic>> imageRows,
    required List<String> removedImageIds,
    required bool imagesDirty,
  }) async {
    final sanitized = _sanitizeListingUpdateFields(fields);
    if (sanitized.isNotEmpty) {
      sanitized['updated_at'] = DateTime.now().toIso8601String();
      debugPrint('patchListing fields: $sanitized');
      final data = await _client
          .from('listings')
          .update(sanitized)
          .eq('id', listingId)
          .eq('user_id', userId)
          .select('id');
      if ((data as List).isEmpty) {
        throw StateError(
          'Listing update rejected — not found or not owned by current user',
        );
      }
    }

    if (!imagesDirty) return;

    if (removedImageIds.isNotEmpty) {
      await _client
          .from('listing_images')
          .delete()
          .inFilter('id', removedImageIds);
    }

    if (imageRows.isNotEmpty) {
      final withId = imageRows.where((r) => r.containsKey('id')).toList();
      final withoutId = imageRows.where((r) => !r.containsKey('id')).toList();
      for (final row in withId) {
        await _client.from('listing_images').update({
          'sort_order': row['sort_order'],
          'is_primary': row['is_primary'],
        }).eq('id', row['id']);
      }
      if (withoutId.isNotEmpty) {
        await _client.from('listing_images').insert(withoutId);
      }
    }
  }

  Map<String, dynamic> _sanitizeListingUpdateFields(Map<String, dynamic> raw) {
    const blockedKeys = {'user_id', 'reference_no', 'created_at', 'id'};
    final sanitized = <String, dynamic>{};

    for (final entry in raw.entries) {
      if (blockedKeys.contains(entry.key)) continue;
      final value = entry.value;
      if (value == null) continue;

      if (entry.key == 'price' || entry.key == 'price_iqd') {
        sanitized[entry.key] = (value as num).round();
        continue;
      }

      if (entry.key == 'is_negotiable') {
        sanitized[entry.key] = value == true;
        continue;
      }

      if (value is String && value.trim().isEmpty) {
        if (entry.key == 'title' ||
            entry.key == 'title_ar' ||
            entry.key == 'description' ||
            entry.key == 'description_ar' ||
            entry.key == 'governorate' ||
            entry.key == 'city') {
          continue;
        }
      }

      sanitized[entry.key] = value;
    }

    return sanitized;
  }

  Future<void> updateListing({
    required String listingId,
    required int categoryId,
    required String title,
    required String description,
    required double price,
    required bool isNegotiable,
    required ListingCondition? condition,
    required String city,
    required String governorate,
    double? latitude,
    double? longitude,
    String? locationAddress,
    required List<Map<String, dynamic>> imageRows,
    required List<String> removedImageIds,
    Map<String, dynamic>? metadata,
  }) async {
    await _client.from('listings').update({
      'category_id': categoryId,
      'title': title,
      'title_ar': title,
      'description': description,
      'description_ar': description,
      'price_iqd': price.round(),
      'price': price.round(),
      'is_negotiable': isNegotiable,
      if (condition != null) 'condition': condition.value,
      'city': city,
      'governorate': governorate,
      'latitude': latitude,
      'longitude': longitude,
      if (locationAddress != null && locationAddress.trim().isNotEmpty)
        'location_address': locationAddress.trim(),
      if (metadata != null) 'metadata': metadata,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', listingId);

    if (removedImageIds.isNotEmpty) {
      await _client
          .from('listing_images')
          .delete()
          .inFilter('id', removedImageIds);
    }

    if (imageRows.isNotEmpty) {
      final withId = imageRows.where((r) => r.containsKey('id')).toList();
      final withoutId = imageRows.where((r) => !r.containsKey('id')).toList();
      for (final row in withId) {
        await _client.from('listing_images').update({
          'sort_order': row['sort_order'],
          'is_primary': row['is_primary'],
        }).eq('id', row['id']);
      }
      if (withoutId.isNotEmpty) {
        await _client.from('listing_images').insert(withoutId);
      }
    }
  }

  Future<void> markAsSold(String listingId) async {
    await _client.from('listings').update({
      'availability': 'sold',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', listingId);
  }

  Future<void> softDeleteListing(String listingId) async {
    try {
      await _client.storage.from(AppConstants.listingVideosBucket).remove([
        '$listingId/video.mp4',
        '$listingId/thumb.jpg',
      ]);
    } catch (_) {
      // Video may not exist for this listing.
    }
    await _client.from('listings').update({
      'availability': 'deleted',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', listingId);
  }

  Future<void> updateListingVideo({
    required String listingId,
    required String videoUrl,
    required String thumbnailUrl,
    required int durationSeconds,
  }) async {
    final listing = await getListingById(listingId);
    final metadata = Map<String, dynamic>.from(listing?.metadata ?? {});
    metadata['video_duration_seconds'] = durationSeconds;

    await _client.from('listings').update({
      'video_url': videoUrl,
      'video_thumbnail_url': thumbnailUrl,
      'metadata': metadata,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', listingId);
  }

  Future<void> reportListing(ReportModel report) async {
    await _client.from('reports').insert(report.toInsertJson());
  }

  Future<List<ListingModel>> fetchMyListings(String userId) async {
    final data = await _client
        .from('listings')
        .select(_listingSelect)
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return _mapListings(data, userId);
  }

  Future<List<ListingModel>> fetchMyListingsByStatus(
    String userId,
    String statusKey,
  ) async {
    dynamic query = _client
        .from('listings')
        .select(_listingSelect)
        .eq('user_id', userId);

    query = switch (statusKey) {
      'active' =>
        query.eq('status', 'approved').eq('availability', 'active'),
      'pending' => query.eq('status', 'pending'),
      'sold' => query.eq('availability', 'sold'),
      'deleted' => query.eq('availability', 'deleted'),
      _ => query,
    };

    final data = await query.order('created_at', ascending: false);
    return _mapListings(data, userId);
  }

  Future<Map<String, int>> fetchMyListingsCounts(String userId) async {
    final data = await _client
        .from('listings')
        .select('status, availability')
        .eq('user_id', userId);

    var active = 0;
    var pending = 0;
    var sold = 0;
    var deleted = 0;

    for (final row in data as List) {
      final map = row as Map<String, dynamic>;
      final status = map['status'] as String? ?? 'pending';
      final availability = map['availability'] as String? ?? 'active';
      if (availability == 'deleted') {
        deleted++;
      } else if (availability == 'sold') {
        sold++;
      } else if (status == 'pending') {
        pending++;
      } else if (status == 'approved' && availability == 'active') {
        active++;
      }
    }

    return {
      'active': active,
      'pending': pending,
      'sold': sold,
      'deleted': deleted,
    };
  }

  Future<int> sumViewsForUser(String userId) async {
    final data = await _client
        .from('listings')
        .select('views_count')
        .eq('user_id', userId);

    var total = 0;
    for (final row in data as List) {
      total += (row as Map<String, dynamic>)['views_count'] as int? ?? 0;
    }
    return total;
  }

  Future<void> restoreListing(String listingId) async {
    await _client.from('listings').update({
      'availability': 'active',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', listingId);
  }

  Future<String> cloneListingForRepost(String listingId, String userId) async {
    final listing = await getListingById(listingId);
    if (listing == null) throw Exception('الإعلان غير موجود');

    final newId = _uuid.v4();
    await _client.from('listings').insert({
      'id': newId,
      'user_id': userId,
      'category_id': listing.categoryId,
      'title': listing.titleAr,
      'title_ar': listing.titleAr,
      'description': listing.descriptionAr,
      'description_ar': listing.descriptionAr,
      'price_iqd': listing.priceIqd,
      'price': listing.priceIqd,
      'is_negotiable': listing.isNegotiable,
      if (listing.condition != null) 'condition': listing.condition!.value,
      'city': listing.city,
      'governorate': listing.governorate,
      'latitude': listing.latitude,
      'longitude': listing.longitude,
      'status': 'pending',
      'availability': 'active',
    });

    if (listing.images.isNotEmpty) {
      final rows = listing.images.asMap().entries.map((e) {
        final img = e.value;
        return {
          'listing_id': newId,
          'storage_path': img.storagePath,
          'sort_order': e.key,
          'is_primary': e.key == 0,
        };
      }).toList();
      await _client.from('listing_images').insert(rows);
    }

    return newId;
  }

  Future<ListingModel> createListing({
    required String userId,
    required int categoryId,
    required String title,
    required String description,
    required int priceIqd,
    required String city,
    required String governorate,
    required List<File> photos,
  }) async {
    if (photos.isEmpty) {
      throw ArgumentError('At least one photo is required');
    }
    if (photos.length > AppConstants.maxListingPhotos) {
      throw ArgumentError('Maximum ${AppConstants.maxListingPhotos} photos allowed');
    }

    final listingId = _uuid.v4();

    await _client.from('listings').insert({
      'id': listingId,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'title_ar': title,
      'description': description,
      'description_ar': description,
      'price_iqd': priceIqd,
      'price': priceIqd,
      'city': city,
      'governorate': governorate,
      'status': 'pending',
      'availability': 'active',
    });

    final imageRows = <Map<String, dynamic>>[];
    for (var i = 0; i < photos.length; i++) {
      final ext = photos[i].path.split('.').last;
      final path = '$userId/$listingId/${_uuid.v4()}.$ext';
      await _client.storage.from(AppConstants.storageBucket).upload(
            path,
            photos[i],
            fileOptions: const FileOptions(upsert: false),
          );
      imageRows.add({
        'listing_id': listingId,
        'storage_path': path,
        'sort_order': i,
        'is_primary': i == 0,
      });
    }

    if (imageRows.isNotEmpty) {
      await _client.from('listing_images').insert(imageRows);
    }

    final created = await fetchById(listingId, userIdForFavorites: userId);
    if (created == null) {
      throw StateError('Failed to load created listing');
    }
    return created;
  }

  /// Uploads a single listing image to storage. Returns the storage path.
  Future<String> uploadListingImage({
    required String userId,
    required File image,
    required int index,
    required int batchId,
  }) async {
    final path = '$userId/${batchId}_$index.jpg';
    await _client.storage.from(AppConstants.storageBucket).upload(
          path,
          image,
          fileOptions: const FileOptions(
            upsert: false,
            contentType: 'image/jpeg',
          ),
        );
    return path;
  }

  /// Returns the public URL for a storage path.
  String uploadListingImageUrl(String storagePath) => _publicUrl(storagePath);

  /// Creates a listing with pre-uploaded image paths.
  Future<String> createListingRecord({
    required String userId,
    required int categoryId,
    required String title,
    required String description,
    required double price,
    required bool isNegotiable,
    required ListingCondition? condition,
    required String city,
    required String governorate,
    double? latitude,
    double? longitude,
    String? locationAddress,
    required List<String> imageStoragePaths,
    required bool asDraft,
    String listingType = 'sale',
    Map<String, dynamic>? metadata,
    ListingContactPreference? contactPreference,
    ListingPackage listingPackage = ListingPackage.standard,
  }) async {
    final listingId = _uuid.v4();
    final priceIqd = price.round();
    final row = _listingInsertRow(
      listingId: listingId,
      userId: userId,
      categoryId: categoryId,
      title: title,
      description: description,
      priceIqd: priceIqd,
      isNegotiable: isNegotiable,
      condition: condition,
      city: city,
      governorate: governorate,
      latitude: latitude,
      longitude: longitude,
      locationAddress: locationAddress,
      listingType: listingType,
      metadata: metadata,
      contactPreference: contactPreference,
      listingPackage: listingPackage,
      includeContactColumn: contactPreference != null,
    );

    if (kDebugMode) {
      debugPrint('createListingRecord insert payload: $row');
    }

    try {
      await _insertListingRow(row);
    } on PostgrestException catch (e) {
      debugPrint(
        'createListingRecord insert failed: code=${e.code} message=${e.message} details=${e.details}',
      );
      if (e.code == 'PGRST204') {
        var includeContact = contactPreference != null;
        var includeVerifiedSeller = true;
        if (contactPreference != null &&
            _isMissingColumnError(e, 'contact_preference')) {
          includeContact = false;
        }
        if (_isMissingColumnError(e, 'is_verified_seller')) {
          includeVerifiedSeller = false;
        }
        if (!includeContact || !includeVerifiedSeller) {
          final fallbackRow = _listingInsertRow(
            listingId: listingId,
            userId: userId,
            categoryId: categoryId,
            title: title,
            description: description,
            priceIqd: priceIqd,
            isNegotiable: isNegotiable,
            condition: condition,
            city: city,
            governorate: governorate,
            latitude: latitude,
            longitude: longitude,
            locationAddress: locationAddress,
            listingType: listingType,
            metadata: metadata,
            contactPreference: contactPreference,
            listingPackage: listingPackage,
            includeContactColumn: includeContact,
            includeVerifiedSellerColumn: includeVerifiedSeller,
          );
          if (kDebugMode) {
            debugPrint(
              'createListingRecord retry with reduced columns: $fallbackRow',
            );
          }
          await _insertListingRow(fallbackRow);
        } else {
          rethrow;
        }
      } else {
        rethrow;
      }
    }

    if (imageStoragePaths.isNotEmpty) {
      final imageRows = <Map<String, dynamic>>[];
      for (var i = 0; i < imageStoragePaths.length; i++) {
        imageRows.add({
          'listing_id': listingId,
          'storage_path': imageStoragePaths[i],
          'sort_order': i,
          'is_primary': i == 0,
        });
      }
      await _client.from('listing_images').insert(imageRows);
    }

    return listingId;
  }

  Future<void> recordListingPurchase({
    required String userId,
    required String listingId,
    required String packageType,
    required num price,
    required String userName,
    String? userPhone,
    String? userEmail,
  }) async {
    final response = await _client.functions.invoke(
      'verify-purchase',
      body: {
        'listing_id': listingId,
        'package_type': packageType,
        'price': price,
        'user_name': userName,
        'user_phone': userPhone,
        'user_email': userEmail,
      },
    );

    if (response.status != 200 && response.status != 202) {
      final error = response.data;
      throw Exception(
        'verify-purchase failed (${response.status}): $error',
      );
    }
  }

  Map<String, dynamic> _listingInsertRow({
    required String listingId,
    required String userId,
    required int categoryId,
    required String title,
    required String description,
    required int priceIqd,
    required bool isNegotiable,
    required ListingCondition? condition,
    required String city,
    required String governorate,
    double? latitude,
    double? longitude,
    String? locationAddress,
    required String listingType,
    Map<String, dynamic>? metadata,
    ListingContactPreference? contactPreference,
    ListingPackage listingPackage = ListingPackage.standard,
    required bool includeContactColumn,
    bool includeVerifiedSellerColumn = true,
  }) {
    final metadataWithContact = _metadataWithContactPreference(
      metadata,
      contactPreference,
    );
    final metadataWithPackage = _metadataWithListingPackage(
      metadataWithContact,
      listingPackage,
    );
    final verifiedSeller = listingPackage == ListingPackage.pro ||
        listingPackage == ListingPackage.premium;
    final metadataFinal = _metadataWithVerifiedSeller(
      metadataWithPackage,
      verifiedSeller,
      includeVerifiedSellerColumn: includeVerifiedSellerColumn,
    );

    return {
      'id': listingId,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'title_ar': title,
      'description': description,
      'description_ar': description,
      'price_iqd': priceIqd,
      'price': priceIqd,
      'currency': 'IQD',
      'is_negotiable': isNegotiable,
      if (condition != null) 'condition': condition.value,
      'city': city,
      'governorate': governorate,
      'latitude': latitude,
      'longitude': longitude,
      if (locationAddress != null && locationAddress.trim().isNotEmpty)
        'location_address': locationAddress.trim(),
      'listing_type': listingType,
      'status': 'pending',
      'availability': 'active',
      'is_featured': listingPackage.isFeatured,
      'is_boosted': listingPackage.isBoosted,
      'expires_at': calculateListingExpiry(listingPackage).toIso8601String(),
      if (includeVerifiedSellerColumn) 'is_verified_seller': verifiedSeller,
      if (metadataFinal != null && metadataFinal.isNotEmpty)
        'metadata': metadataFinal,
      if (includeContactColumn && contactPreference != null)
        'contact_preference': contactPreference.value,
    };
  }

  Map<String, dynamic>? _metadataWithContactPreference(
    Map<String, dynamic>? metadata,
    ListingContactPreference? contactPreference,
  ) {
    if (contactPreference == null &&
        (metadata == null || metadata.isEmpty)) {
      return metadata;
    }
    final merged = Map<String, dynamic>.from(metadata ?? {});
    if (contactPreference != null) {
      merged['contact_preference'] = contactPreference.value;
    }
    return merged.isEmpty ? null : merged;
  }

  Map<String, dynamic>? _metadataWithListingPackage(
    Map<String, dynamic>? metadata,
    ListingPackage listingPackage,
  ) {
    final merged = Map<String, dynamic>.from(metadata ?? {});
    merged['listing_package'] = listingPackage.value;
    return merged.isEmpty ? null : merged;
  }

  Map<String, dynamic>? _metadataWithVerifiedSeller(
    Map<String, dynamic>? metadata,
    bool verifiedSeller, {
    required bool includeVerifiedSellerColumn,
  }) {
    if (includeVerifiedSellerColumn || !verifiedSeller) return metadata;
    final merged = Map<String, dynamic>.from(metadata ?? {});
    merged['is_verified_seller'] = true;
    return merged.isEmpty ? null : merged;
  }

  Future<void> _insertListingRow(Map<String, dynamic> row) async {
    await _client.from('listings').insert(row);
  }

  bool _isMissingColumnError(PostgrestException error, String column) {
    final haystack =
        '${error.code} ${error.message} ${error.details}'.toLowerCase();
    return haystack.contains(column.toLowerCase()) &&
        (haystack.contains('column') ||
            haystack.contains('schema cache') ||
            haystack.contains('could not find'));
  }

  /// Saves a listing as draft (status pending, may have partial data).
  Future<String> saveDraft({
    required String userId,
    required int categoryId,
    required String title,
    required String description,
    required double price,
    required bool isNegotiable,
    required ListingCondition? condition,
    required String city,
    required String governorate,
    double? latitude,
    double? longitude,
    required List<String> imageStoragePaths,
  }) {
    return createListingRecord(
      userId: userId,
      categoryId: categoryId,
      title: title,
      description: description,
      price: price,
      isNegotiable: isNegotiable,
      condition: condition,
      city: city,
      governorate: governorate,
      latitude: latitude,
      longitude: longitude,
      imageStoragePaths: imageStoragePaths,
      asDraft: true,
    );
  }

  Future<void> deleteListing(String listingId) async {
    await softDeleteListing(listingId);
  }

  void incrementViews(String listingId) {
    () async {
      try {
        await _client.rpc('increment_listing_views', params: {
          'listing_id': listingId,
        });
      } catch (_) {}
    }();
  }

  Future<void> incrementContacts(String listingId) async {
    try {
      await _client.rpc('increment_listing_contacts', params: {
        'listing_id': listingId,
      });
    } catch (_) {}
  }

  Future<void> updateAutoRenew({
    required String listingId,
    required bool autoRenew,
  }) async {
    await _client.from('listings').update({
      'auto_renew': autoRenew,
    }).eq('id', listingId);
  }

  List<ListingModel> _sortByPackagePriority(List<ListingModel> listings) {
    final sorted = [...listings];
    sortListingsByPackagePriority(sorted);
    return sorted;
  }

  /// Builds filter chain only — never call order/limit/range before this returns.
  dynamic _filteredListingsQuery({
    int? categoryId,
    String? listingType,
    FilterModel? filter,
    String select = _listingSelect,
  }) {
    dynamic query = _client
        .from('listings')
        .select(select)
        .eq('status', 'approved')
        .eq('availability', 'active');

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (listingType != null && listingType.isNotEmpty) {
      query = query.eq('listing_type', listingType);
    }

    return _applyFilters(query, filter);
  }

  dynamic _applyFilters(dynamic query, FilterModel? filters) {
    if (filters == null) return query;

    if (filters.query != null && filters.query!.trim().isNotEmpty) {
      final q = filters.query!.trim();
      query = query.or('title_ar.ilike.%$q%,title.ilike.%$q%');
    }
    if (filters.effectiveCategoryId != null) {
      query = query.eq('category_id', filters.effectiveCategoryId!);
    }
    if (filters.governorate != null) {
      query = query.eq('governorate', filters.governorate!);
    }
    if (filters.city != null && filters.city!.isNotEmpty) {
      query = query.ilike('city', '%${filters.city}%');
    }
    if (filters.minPrice != null) {
      query = query.gte('price', filters.minPrice!.round());
    }
    if (filters.maxPrice != null) {
      query = query.lte('price', filters.maxPrice!.round());
    }
    if (filters.condition != FilterCondition.all) {
      query = query.eq('condition', filters.condition.dbValue!);
    }
    if (filters.isFeaturedOnly) {
      query = query.eq('is_featured', true);
    }
    if (filters.isNegotiableOnly) {
      query = query.eq('is_negotiable', true);
    }
    return query;
  }

  dynamic _applySorting(dynamic query, SearchSortBy sortBy) {
    return switch (sortBy) {
      SearchSortBy.newest => query.order('created_at', ascending: false),
      SearchSortBy.cheapest => query.order('price', ascending: true),
      SearchSortBy.expensive => query.order('price', ascending: false),
      SearchSortBy.mostViewed => query.order('views_count', ascending: false),
    };
  }

  Future<List<ListingModel>> _mapListings(
    List<dynamic> data,
    String? userId,
  ) async {
    final maps = data
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
    await _attachSellerProfiles(maps);

    Set<String> favoriteIds = {};
    if (userId != null && data.isNotEmpty) {
      final ids = data.map((e) => (e as Map)['id'] as String).toList();
      final favs = await _client
          .from('favorites')
          .select('listing_id')
          .eq('user_id', userId)
          .inFilter('listing_id', ids);
      favoriteIds = (favs as List).map((e) => e['listing_id'] as String).toSet();
    }

    return maps.map((map) {
      final images = (map['listing_images'] as List?) ?? [];
      if (images.isNotEmpty) {
        images.sort((a, b) {
          final aPrimary = a['is_primary'] as bool? ?? false;
          final bPrimary = b['is_primary'] as bool? ?? false;
          if (aPrimary != bPrimary) return aPrimary ? -1 : 1;
          return (a['sort_order'] as int).compareTo(b['sort_order'] as int);
        });
        final primaryPath = images.first['storage_path'] as String?;
        if (primaryPath != null) {
          map['cover_image_url'] = _publicUrl(primaryPath);
        }
        map['listing_images'] = images.map((img) {
          final imgMap = Map<String, dynamic>.from(img as Map);
          final path = imgMap['storage_path'] as String?;
          if (path != null) {
            imgMap['storage_path'] = _publicUrl(path);
            imgMap['url'] = _publicUrl(path);
          }
          return imgMap;
        }).toList();
      }
      map['is_favorite'] = favoriteIds.contains(map['id']);
      return ListingModel.fromJson(map);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> enrichListingMaps(
    List<Map<String, dynamic>> maps,
  ) async {
    final copies = maps.map(Map<String, dynamic>.from).toList();
    await _attachSellerProfiles(copies);
    return copies;
  }

  Future<void> _attachSellerProfiles(List<Map<String, dynamic>> maps) async {
    if (maps.isEmpty) return;
    final userIds = maps.map((m) => m['user_id'] as String).toSet().toList();
    final sellers = await fetchPublicProfiles(_client, userIds);
    final byId = <String, Map<String, dynamic>>{
      for (final map in sellers) map['id'] as String: map,
    };
    for (final map in maps) {
      final seller = byId[map['user_id'] as String];
      if (seller != null) {
        map['profiles'] = seller;
      }
    }
  }

  String publicUrlForPath(String path) => _publicUrl(path);

  Future<int> fetchMonthlyFreePostCount(String userId) async {
    final result = await _client.rpc(
      'get_or_reset_monthly_free_count',
      params: {'p_user_id': userId},
    );
    return (result as num?)?.toInt() ?? 0;
  }

  Future<int> incrementMonthlyFreePostCount(String userId) async {
    final result = await _client.rpc(
      'increment_monthly_free_count',
      params: {'p_user_id': userId},
    );
    return (result as num?)?.toInt() ?? 0;
  }
}
