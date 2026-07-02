import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StockPieChart extends StatefulWidget {
  const StockPieChart({super.key});

  @override
  State<StockPieChart> createState() => _StockPieChartState();
}

class _StockPieChartState extends State<StockPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(isDark ? 50 : 100),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock by Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: showingSections(colorScheme),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Indicator(
                        color: colorScheme.primary,
                        text: 'Electronics',
                        isSquare: false,
                      ),
                      const SizedBox(height: 8),
                      Indicator(
                        color: colorScheme.tertiary,
                        text: 'Clothing',
                        isSquare: false,
                      ),
                      const SizedBox(height: 8),
                      Indicator(
                        color: colorScheme.secondary,
                        text: 'Groceries',
                        isSquare: false,
                      ),
                      const SizedBox(height: 8),
                      Indicator(
                        color: colorScheme.error,
                        text: 'Other',
                        isSquare: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(ColorScheme colorScheme) {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 50.0 : 40.0;
      const shadows = [Shadow(color: Colors.black26, blurRadius: 2)];

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: colorScheme.primary,
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: colorScheme.tertiary,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: colorScheme.onTertiary,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: colorScheme.secondary,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondary,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: colorScheme.error,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: colorScheme.onError,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 12,
    this.textColor,
  });

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        )
      ],
    );
  }
}
