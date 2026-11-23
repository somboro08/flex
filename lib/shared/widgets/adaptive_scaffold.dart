import 'package:flutter/material.dart';
import '../../core/responsive/breakpoints.dart';
import '../../theme/flex_theme.dart';

class AdaptiveNavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final int index;

  const AdaptiveNavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
    required this.index,
  });
}

class AdaptiveScaffold extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveNavigationItem> destinations;
  final Widget body;
  final Widget? title;
  final List<Widget>? actions;

  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.title,
    this.actions,
  });

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (context.isMobile) {
      return Scaffold(
        body: widget.body,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? FlexColors.neutral900 : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: widget.selectedIndex,
            onTap: widget.onDestinationSelected,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: FlexColors.primary500,
            unselectedItemColor: isDark ? FlexColors.neutral400 : FlexColors.neutral500,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: widget.destinations.map((item) {
              return BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.selectedIcon),
                label: item.label,
              );
            }).toList(),
          ),
        ),
      );
    }

    if (context.isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: widget.selectedIndex,
              onDestinationSelected: widget.onDestinationSelected,
              labelType: NavigationRailLabelType.selected,
              backgroundColor: isDark ? FlexColors.neutral900 : Colors.white,
              selectedIconTheme: const IconThemeData(color: FlexColors.primary500),
              selectedLabelTextStyle: const TextStyle(
                color: FlexColors.primary500,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedIconTheme: IconThemeData(
                color: isDark ? FlexColors.neutral400 : FlexColors.neutral500,
              ),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: FlexColors.primary500,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'F',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
              destinations: widget.destinations.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: Text(item.label),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.body),
          ],
        ),
      );
    }

    // Desktop Layout
    return Scaffold(
      body: Row(
        children: [
          // Desktop Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isSidebarCollapsed ? 80 : 250,
            color: isDark ? FlexColors.neutral900 : Colors.white,
            child: Column(
              children: [
                // Header
                Container(
                  height: 70,
                  padding: EdgeInsets.symmetric(
                    horizontal: _isSidebarCollapsed ? 14 : 16,
                  ),
                  child: _isSidebarCollapsed
                      ? Center(
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            color: isDark ? FlexColors.neutral300 : FlexColors.neutral600,
                            onPressed: () {
                              setState(() => _isSidebarCollapsed = false);
                            },
                          ),
                        )
                      : Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: FlexColors.primary500,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  'F',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Flex',
                              style: FlexTextStyles.h3.copyWith(
                                color: isDark ? Colors.white : FlexColors.neutral900,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.chevron_left_rounded),
                              color: isDark ? FlexColors.neutral300 : FlexColors.neutral600,
                              onPressed: () {
                                setState(() => _isSidebarCollapsed = true);
                              },
                            ),
                          ],
                        ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 16),
                // Destinations
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.destinations.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final item = widget.destinations[index];
                      final isSelected = widget.selectedIndex == item.index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: () => widget.onDestinationSelected(item.index),
                          borderRadius: BorderRadius.circular(12),
                          hoverColor: FlexColors.primary500.withOpacity(0.08),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? FlexColors.primary500.withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  color: isSelected
                                      ? FlexColors.primary500
                                      : (isDark ? FlexColors.neutral400 : FlexColors.neutral600),
                                  size: 22,
                                ),
                                if (!_isSidebarCollapsed) ...[
                                  const SizedBox(width: 14),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected
                                          ? FlexColors.primary500
                                          : (isDark ? FlexColors.neutral200 : FlexColors.neutral800),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Body
          Expanded(child: widget.body),
        ],
      ),
    );
  }
}
