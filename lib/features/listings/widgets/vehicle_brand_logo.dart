import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../core/utils/vehicle_brand_style.dart';
import '../../../shared/models/category_model.dart';

/// Circular car brand logo with letter fallback (Sahibinden-style).
class VehicleBrandLogo extends StatelessWidget {
  const VehicleBrandLogo({
    super.key,
    required this.category,
    this.size = 44,
  });

  final CategoryModel category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final accent = vehicleBrandColor(category);
    final initial = vehicleBrandInitial(category);
    final logoUrl = vehicleBrandLogoUrl(category);

    Widget fallback() {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: GoogleFonts.cairo(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w800,
            color: accent,
          ),
        ),
      );
    }

    if (logoUrl == null) return fallback();

    final pngFallback = isSvgLogoUrl(logoUrl)
        ? vehicleBrandLogoUrl(
            CategoryModel(
              id: category.id,
              slug: category.slug,
              nameAr: category.nameAr,
              icon: category.icon,
              logoUrl: null,
            ),
          )
        : null;

    final padded = ClipOval(
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        padding: EdgeInsets.all(size * 0.12),
        child: isSvgLogoUrl(logoUrl)
            ? _SvgBrandLogo(
                url: logoUrl,
                pngFallbackUrl: pngFallback,
                fallback: fallback(),
              )
            : CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.contain,
                placeholder: (_, _) => fallback(),
                errorWidget: (_, _, _) => fallback(),
              ),
      ),
    );

    return padded;
  }
}

/// Loads SVG from network with letter fallback on failure.
class _SvgBrandLogo extends StatefulWidget {
  const _SvgBrandLogo({
    required this.url,
    required this.fallback,
    this.pngFallbackUrl,
  });

  final String url;
  final String? pngFallbackUrl;
  final Widget fallback;

  @override
  State<_SvgBrandLogo> createState() => _SvgBrandLogoState();
}

class _SvgBrandLogoState extends State<_SvgBrandLogo> {
  late Future<Uint8List?> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchSvg(widget.url);
  }

  @override
  void didUpdateWidget(covariant _SvgBrandLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _future = _fetchSvg(widget.url);
    }
  }

  Future<Uint8List?> _fetchSvg(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: const {
          'Accept': 'image/svg+xml,*/*',
          'User-Agent': 'SouqIQ/1.0',
        },
      );
      if (response.statusCode != 200) return null;
      return response.bodyBytes;
    } catch (_) {
      return null;
    }
  }

  Widget _pngFallback() {
    final pngUrl = widget.pngFallbackUrl;
    if (pngUrl == null || isSvgLogoUrl(pngUrl)) {
      return widget.fallback;
    }
    return CachedNetworkImage(
      imageUrl: pngUrl,
      fit: BoxFit.contain,
      placeholder: (_, _) => widget.fallback,
      errorWidget: (_, _, _) => widget.fallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.fallback;
        }
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return _pngFallback();
        }
        return SvgPicture.memory(
          bytes,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => widget.fallback,
          errorBuilder: (_, _, _) => _pngFallback(),
        );
      },
    );
  }
}
