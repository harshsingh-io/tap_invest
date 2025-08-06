import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/di/injection.dart';
import '../cubit/bond_detail_cubit.dart';
import '../cubit/bond_detail_state.dart';
import '../../data/models/bond_summary_model.dart';
import '../../data/models/bond_detail_model.dart';

class BondDetailScreen extends StatelessWidget {
  final BondSummary bond;

  const BondDetailScreen({super.key, required this.bond});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BondDetailCubit>()..fetchDetail(bond.isin),
      child: _BondDetailContent(bond: bond),
    );
  }
}

class _BondDetailContent extends StatefulWidget {
  final BondSummary bond;

  const _BondDetailContent({required this.bond});

  @override
  State<_BondDetailContent> createState() => _BondDetailContentState();
}

class _BondDetailContentState extends State<_BondDetailContent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (_currentTabIndex != _tabController.index) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () async {
            await HapticFeedback.lightImpact();
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              'assets/back_icon.svg',
              width: 40,
              height: 40,
            ),
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16.0),
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Container(
        //           padding: const EdgeInsets.symmetric(
        //             horizontal: 8,
        //             vertical: 4,
        //           ),
        //           decoration: BoxDecoration(
        //             color: Colors.orange,
        //             borderRadius: BorderRadius.circular(4),
        //           ),
        //           child: const Text(
        //             'INFRA.',
        //             style: TextStyle(
        //               color: Colors.white,
        //               fontSize: 10,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //         ),
        //         const SizedBox(width: 4),
        //         const Text(
        //           'MARKET',
        //           style: TextStyle(
        //             color: Colors.orange,
        //             fontSize: 14,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ],
      ),
      body: BlocBuilder<BondDetailCubit, BondDetailState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Initializing...')),
            loading: () => _buildShimmerLoading(),
            loaded: (detail, chartType) => _buildContent(detail, chartType),
            error:
                (message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $message',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed:
                            () => context.read<BondDetailCubit>().fetchDetail(
                              widget.bond.isin,
                            ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BondDetail detail, FinancialChartType chartType) {
    return Column(
      children: [
        _buildHeader(detail),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildISINAnalysisTab(detail, chartType),
              _buildProsAndConsTab(detail),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BondDetail detail) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo container with fixed sizing
          Container(
            width: 60,
            height: 60,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 0.50, color: Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x07000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                  spreadRadius: -1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.all(6),
                child: CachedNetworkImage(
                  imageUrl: detail.logo,
                  fit: BoxFit.contain,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.business,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.business,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Company name
          Text(
            detail.companyName,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.50,
              letterSpacing: -0.16,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            detail.description,
            style: const TextStyle(
              color: Color(0xFF6A7282),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 12),

          // ISIN and Status badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: const Color(0x1E2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  'ISIN: ${detail.isin}',
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                    letterSpacing: 0.80,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: const Color(0x14059669),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  detail.status,
                  style: const TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                    letterSpacing: 0.80,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.50, color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _currentTabIndex = 0;
              });
              _tabController.animateTo(0);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 2,
                    color:
                        _currentTabIndex == 0
                            ? const Color(0xFF1447E6)
                            : Colors.transparent,
                  ),
                ),
              ),
              child: Text(
                'ISIN Analysis',
                style: TextStyle(
                  color:
                      _currentTabIndex == 0
                          ? const Color(0xFF1447E6)
                          : const Color(0xFF4A5565),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _currentTabIndex = 1;
              });
              _tabController.animateTo(1);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 2,
                    color:
                        _currentTabIndex == 1
                            ? const Color(0xFF1447E6)
                            : Colors.transparent,
                  ),
                ),
              ),
              child: Text(
                'Pros & Cons',
                style: TextStyle(
                  color:
                      _currentTabIndex == 1
                          ? const Color(0xFF1447E6)
                          : const Color(0xFF4A5565),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildISINAnalysisTab(
    BondDetail detail,
    FinancialChartType chartType,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Chart Container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildFinancialChartContainer(detail, chartType),
          ),
          const SizedBox(height: 24),
          // Issuer Details Container
          _buildIssuerDetailsContainer(detail.issuerDetails),
          const SizedBox(height: 120), // Bottom padding for scroll
        ],
      ),
    );
  }

  Widget _buildFinancialChartContainer(
    BondDetail detail,
    FinancialChartType chartType,
  ) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.50, color: Color(0xFFE7E5E4)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'COMPANY FINANCIALS',
                        style: TextStyle(
                          color: Color(0xFFA3A3A3),
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                          letterSpacing: 0.80,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildChartToggleGroup(chartType),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChart(detail, chartType),
                      const SizedBox(height: 16),
                      _buildChartLabels(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 0.60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: double.infinity,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFE5E5E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartToggleGroup(FinancialChartType chartType) {
    return Container(
      padding: const EdgeInsets.all(2),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.40, color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(999),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0F525866),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<BondDetailCubit>().toggleChartType(
                FinancialChartType.ebitda,
              );
            },
            child: Container(
              padding: const EdgeInsets.only(
                top: 3,
                left: 8,
                right: 6,
                bottom: 3,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color:
                    chartType == FinancialChartType.ebitda
                        ? Colors.white
                        : Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(999),
                    bottomLeft: Radius.circular(999),
                  ),
                ),
                shadows:
                    chartType == FinancialChartType.ebitda
                        ? const [
                          BoxShadow(
                            color: Color(0x0F525866),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                            spreadRadius: 0,
                          ),
                        ]
                        : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'EBITDA',
                        style: TextStyle(
                          color:
                              chartType == FinancialChartType.ebitda
                                  ? const Color(0xFF171717)
                                  : const Color(0xFF737373),
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<BondDetailCubit>().toggleChartType(
                FinancialChartType.revenue,
              );
            },
            child: Container(
              padding: const EdgeInsets.only(
                top: 3,
                left: 6,
                right: 8,
                bottom: 3,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color:
                    chartType == FinancialChartType.revenue
                        ? Colors.white
                        : Colors.transparent,
                shape: RoundedRectangleBorder(
                  side:
                      chartType == FinancialChartType.revenue
                          ? const BorderSide(
                            width: 0.40,
                            color: Color(0xFFE5E5E5),
                          )
                          : BorderSide.none,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(999),
                    bottomRight: Radius.circular(999),
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Revenue',
                        style: TextStyle(
                          color:
                              chartType == FinancialChartType.revenue
                                  ? const Color(0xFF171717)
                                  : const Color(0xFF737373),
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BondDetail detail, FinancialChartType chartType) {
    final data =
        chartType == FinancialChartType.ebitda
            ? detail.financials.ebitda
            : detail.financials.revenue;

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final barGroups =
        data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value.toDouble(),
                color: const Color(0xFF155DFC),
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(2),
                ),
              ),
            ],
          );
        }).toList();

    return Container(
      width: double.infinity,
      height: 158,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue.toDouble() * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: maxValue.toDouble() / 7,
                getTitlesWidget: (value, meta) {
                  if (value % (maxValue.toDouble() / 3.5) == 0) {
                    return Text(
                      '₹${(value / 1000000).toStringAsFixed(0)}L',
                      style: const TextStyle(
                        color: Color(0xFFA3A3A3),
                        fontSize: 8,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1.50,
                        letterSpacing: 0.64,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
          gridData: FlGridData(
            show: true,
            horizontalInterval: maxValue.toDouble() / 7,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color:
                    value % (maxValue.toDouble() / 3.5) == 0
                        ? const Color(0xFFD4D4D4)
                        : const Color(0xFFF5F5F5),
                strokeWidth: 0.6,
              );
            },
            drawVerticalLine: false,
          ),
        ),
      ),
    );
  }

  Widget _buildChartLabels() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 27),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D']
                .map(
                  (month) => Text(
                    month,
                    style: const TextStyle(
                      color: Color(0xFFA3A3A3),
                      fontSize: 8,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                      letterSpacing: 0.64,
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildIssuerDetailsContainer(IssuerDetails details) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFE5E7EB),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                        ),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                    bottom: 16,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 2,
                                        color: Color(0xFF020617),
                                      ),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.business,
                                        color: Color(0xFF020617),
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Issuer Details',
                                        style: TextStyle(
                                          color: Color(0xFF020617),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          height: 1.50,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 28,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Issuer Name', details.issuerName),
                            const SizedBox(height: 30),
                            _buildDetailRow(
                              'Type of Issuer',
                              details.typeOfIssuer,
                            ),
                            const SizedBox(height: 30),
                            _buildDetailRow('Sector', details.sector),
                            const SizedBox(height: 30),
                            _buildDetailRow('Industry', details.industry),
                            const SizedBox(height: 30),
                            _buildDetailRow(
                              'Issuer nature',
                              details.issuerNature,
                            ),
                            const SizedBox(height: 30),
                            _buildDetailRow(
                              'Corporate Identity Number (CIN)',
                              details.cin,
                            ),
                            const SizedBox(height: 30),
                            _buildDetailRow(
                              'Name of the Lead Manager',
                              details.leadManager ?? '-',
                            ),
                            const SizedBox(height: 30),
                            _buildDetailRow('Registrar', details.registrar),
                            const SizedBox(height: 30),
                            _buildDetailRow(
                              'Name of Debenture Trustee',
                              details.debentureTrustee,
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1D4ED8),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProsAndConsTab(BondDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFE5E7EB),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1,
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                    bottom: 16,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 2,
                                        color: Color(0xFF020617),
                                      ),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Pros and Cons',
                                        style: TextStyle(
                                          color: Color(0xFF020617),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          height: 1.50,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Content Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 8,
                          left: 16,
                          right: 16,
                          bottom: 28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pros Section
                            Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pros',
                                    style: TextStyle(
                                      color: Color(0xFF15803D),
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      height: 1.50,
                                      letterSpacing: -0.16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...detail.prosAndCons.pros.map(
                                    (pro) => _buildProItem(pro),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Cons Section
                            Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cons',
                                    style: TextStyle(
                                      color: Color(0xFFB45309),
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      height: 1.50,
                                      letterSpacing: -0.16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...detail.prosAndCons.cons.map(
                                    (con) => _buildConItem(con),
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
          const SizedBox(height: 120), // Bottom padding for scroll
        ],
      ),
    );
  }

  Widget _buildProItem(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 2, bottom: 2.59),
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset('assets/pros_icon.svg', width: 18, height: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF364153),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConItem(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 2, bottom: 2.59),
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset('assets/cons_icon.svg', width: 18, height: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for Financial Chart
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: 158,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE7E5E4),
                    width: 0.50,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Shimmer for Issuer Details
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFE5E7EB),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                        ),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                    bottom: 16,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 2,
                                        color: Color(0xFF020617),
                                      ),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.business,
                                        color: Color(0xFF020617),
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Issuer Details',
                                        style: TextStyle(
                                          color: Color(0xFF020617),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          height: 1.50,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 28,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildShimmerDetailRow(),
                            const SizedBox(height: 30),
                            _buildShimmerDetailRow(),
                            const SizedBox(height: 30),
                            _buildShimmerDetailRow(),
                            const SizedBox(height: 30),
                            _buildShimmerDetailRow(),
                            const SizedBox(height: 30),
                            _buildShimmerDetailRow(),
                            const SizedBox(height: 30),
                            _buildShimmerDetailRow(),
                            const SizedBox(height: 30),
                            _buildShimmerDetailRow(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 120), // Bottom padding for scroll
        ],
      ),
    );
  }

  Widget _buildShimmerDetailRow() {
    return Container(
      width: double.infinity,
      height: 16,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
}
