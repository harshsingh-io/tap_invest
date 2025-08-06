import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/di/injection.dart';
import '../cubit/bond_list_cubit.dart';
import '../cubit/bond_list_state.dart';
import '../../data/models/bond_summary_model.dart';
import 'bond_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BondListCubit>()..fetchBonds(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              color: const Color(0xFFF3F4F6),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                      letterSpacing: -0.78,
                    ),
                  ),
                ],
              ),
            ),

            // Search Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildSearchBar()],
              ),
            ),

            const SizedBox(height: 20),

            // Content Section
            Expanded(
              child: BlocBuilder<BondListCubit, BondListState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => const Center(child: Text('Initializing...')),
                    loading: () => _buildShimmerLoading(),
                    loaded:
                        (allBonds, filteredBonds, searchQuery) =>
                            _buildBondsList(filteredBonds, searchQuery),
                    error:
                        (message) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error: $message',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed:
                                    () =>
                                        context
                                            .read<BondListCubit>()
                                            .fetchBonds(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      height: 42,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.50, color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: SvgPicture.asset(
              'assets/search_icon.svg',
              width: 14,
              height: 14,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => context.read<BondListCubit>().search(value),
              style: const TextStyle(
                color: Color(0xFF1E2939),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
              decoration: const InputDecoration(
                hintText: 'Search by Issuer Name or ISIN',
                hintStyle: TextStyle(
                  color: Color(0xFF99A1AF),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(right: 12, top: 11, bottom: 11),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBondsList(List<BondSummary> bonds, String searchQuery) {
    final title = searchQuery.isEmpty ? 'SUGGESTED RESULTS' : 'SEARCH RESULTS';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 4,
            left: 20,
            right: 20,
            bottom: 8,
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF99A1AF),
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.50,
              letterSpacing: 0.80,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimationLimiter(
              child: ListView.builder(
                itemCount: bonds.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: _buildBondItem(bonds[index], searchQuery),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBondItem(BondSummary bond, String searchQuery) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.50, color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            await HapticFeedback.lightImpact();
            if (mounted) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          BondDetailScreen(bond: bond),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildCompanyLogo(bond.logo),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ISIN Row
                            Container(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildHighlightedISIN(
                                      bond.isin,
                                      searchQuery,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Company Details Row
                            Container(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          bond.rating,
                                          style: const TextStyle(
                                            color: Color(0xFF99A1AF),
                                            fontSize: 10,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                          ),
                                        ),
                                        const Text(
                                          ' · ',
                                          style: TextStyle(
                                            color: Color(0xFF99A1AF),
                                            fontSize: 10,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildHighlightedText(
                                            bond.companyName,
                                            searchQuery,
                                            const TextStyle(
                                              color: Color(0xFF99A1AF),
                                              fontSize: 10,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.50,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF99A1AF),
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyLogo(String logoUrl) {
    return Container(
      width: 40,
      height: 40,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.40, color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: CachedNetworkImage(
            imageUrl: logoUrl,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.business,
                    color: Colors.grey,
                    size: 16,
                  ),
                ),
            errorWidget:
                (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.business,
                    color: Colors.grey,
                    size: 16,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedISIN(String isin, String searchQuery) {
    if (searchQuery.isEmpty ||
        !isin.toLowerCase().contains(searchQuery.toLowerCase())) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: isin.substring(0, 7),
              style: const TextStyle(
                color: Color(0xFF6A7282),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.50,
                letterSpacing: 0.60,
              ),
            ),
            TextSpan(
              text: isin.substring(7),
              style: const TextStyle(
                color: Color(0xFF1E2939),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.50,
                letterSpacing: 0.70,
              ),
            ),
          ],
        ),
      );
    }

    // Handle highlighted ISIN
    final lowerIsin = isin.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();
    final startIndex = lowerIsin.indexOf(lowerQuery);
    final endIndex = startIndex + searchQuery.length;

    List<TextSpan> spans = [];

    // Before highlight
    if (startIndex > 0) {
      final beforeText = isin.substring(0, startIndex);
      if (startIndex <= 7) {
        spans.add(
          TextSpan(
            text: beforeText,
            style: const TextStyle(
              color: Color(0xFF6A7282),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.50,
              letterSpacing: 0.60,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: beforeText.substring(0, 7),
            style: const TextStyle(
              color: Color(0xFF6A7282),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.50,
              letterSpacing: 0.60,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: beforeText.substring(7),
            style: const TextStyle(
              color: Color(0xFF1E2939),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.50,
              letterSpacing: 0.70,
            ),
          ),
        );
      }
    }

    // Highlighted part
    spans.add(
      TextSpan(
        text: isin.substring(startIndex, endIndex),
        style: TextStyle(
          color:
              startIndex < 7
                  ? const Color(0xFF6A7282)
                  : const Color(0xFF1E2939),
          fontSize: startIndex < 7 ? 12 : 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          height: 1.50,
          letterSpacing: startIndex < 7 ? 0.60 : 0.70,
          backgroundColor: Colors.yellow.withValues(alpha: 0.3),
        ),
      ),
    );

    // After highlight
    if (endIndex < isin.length) {
      final afterText = isin.substring(endIndex);
      if (endIndex <= 7) {
        spans.add(
          TextSpan(
            text: afterText.substring(0, 7 - endIndex),
            style: const TextStyle(
              color: Color(0xFF6A7282),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.50,
              letterSpacing: 0.60,
            ),
          ),
        );
        if (afterText.length > (7 - endIndex)) {
          spans.add(
            TextSpan(
              text: afterText.substring(7 - endIndex),
              style: const TextStyle(
                color: Color(0xFF1E2939),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.50,
                letterSpacing: 0.70,
              ),
            ),
          );
        }
      } else {
        spans.add(
          TextSpan(
            text: afterText,
            style: const TextStyle(
              color: Color(0xFF1E2939),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.50,
              letterSpacing: 0.70,
            ),
          ),
        );
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildHighlightedText(
    String text,
    String searchQuery,
    TextStyle baseStyle,
  ) {
    if (searchQuery.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      return Text(text, style: baseStyle);
    }

    final startIndex = lowerText.indexOf(lowerQuery);
    final endIndex = startIndex + searchQuery.length;

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          if (startIndex > 0) TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: baseStyle.copyWith(
              backgroundColor: Colors.yellow.withValues(alpha: 0.3),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (endIndex < text.length) TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        height: 10,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
