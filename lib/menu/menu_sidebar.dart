import 'package:flutter/material.dart';

typedef MenuSidebarItem = ({
  String label,
  IconData icon,
  bool selected,
  bool selectable,
  void Function() onSelected,
});

/// A [Widget] containing the menu entries for the sidebar menu.
class MenuSidebar extends StatelessWidget {
  final List<MenuSidebarItem> topItems;
  final List<MenuSidebarItem> bottomItems;

  const MenuSidebar({
    super.key,
    required this.topItems,
    required this.bottomItems,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: Column(
                children: topItems
                    .map(
                      (item) => GestureDetector(
                        onTap: item.onSelected,
                        child: _MenuSidebarItemWidget(item, constraints),
                      ),
                    )
                    .toList(),
              ),
            ),
            Column(
              children: bottomItems
                  .map(
                    (item) => GestureDetector(
                      onTap: item.onSelected,
                      child: _MenuSidebarItemWidget(item, constraints),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

/// The [Widget] which represents an item in the menu.
class _MenuSidebarItemWidget extends StatelessWidget {
  final MenuSidebarItem item;
  final BoxConstraints constraints;

  const _MenuSidebarItemWidget(this.item, this.constraints);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = item.selected
        ? theme.colorScheme.inversePrimary
        : (item.selectable
              ? theme.primaryColor
              : theme.colorScheme.primaryContainer);

    return Container(
      color: item.selected
          ? theme.primaryColor
          : theme.colorScheme.inversePrimary,
      width: constraints.maxWidth,
      height: 50.0,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Icon(item.icon, color: textColor),
          ),
          Text(
            item.label,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontStyle: item.selectable ? .normal : .italic,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
