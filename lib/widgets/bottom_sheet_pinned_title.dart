import 'package:flutter/material.dart';

Color modalBottomSheetSurfaceColor(BuildContext context) {
  final theme = Theme.of(context);
  final sheet = theme.bottomSheetTheme;
  return sheet.modalBackgroundColor ??
      sheet.backgroundColor ??
      (theme.useMaterial3
          ? theme.colorScheme.surfaceContainerLow
          : theme.colorScheme.surface);
}

class BottomSheetPinnedTitleScrollView extends StatelessWidget {
  const BottomSheetPinnedTitleScrollView({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 0, 24, 24),
  });

  final String title;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheetBg = modalBottomSheetSurfaceColor(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: true,
            automaticallyImplyLeading: false,
            elevation: 0,
            scrolledUnderElevation: 4,
            backgroundColor: sheetBg,
            shadowColor: theme.colorScheme.shadow,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.maybePop(context),
            ),
            title: Text(title, style: theme.textTheme.titleLarge),
          ),
          SliverPadding(
            padding: padding,
            sliver: SliverToBoxAdapter(child: child),
          ),
        ],
      ),
    );
  }
}
