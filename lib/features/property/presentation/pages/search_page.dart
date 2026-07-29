import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../cubit/search_cubit.dart';
import '../../domain/entities/property.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

/// Stateful only for the TextEditingController; results/recents live in
/// [SearchCubit].
class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(BuildContext context, Property property) {
    context.read<SearchCubit>().select(property);
    Navigator.of(context).pushNamed(AppRoutes.details, arguments: property);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: context.read<SearchCubit>().search,
                onSubmitted: context.read<SearchCubit>().search,
                decoration: InputDecoration(
                  hintText: 'Search area, city or property',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _controller.clear();
                      context.read<SearchCubit>().clear();
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  switch (state.status) {
                    case SearchStatus.loading:
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    case SearchStatus.empty:
                      return const EmptyState(
                        icon: Icons.location_off_outlined,
                        title: 'Search not found',
                        subtitle: Text(
                          'Please enable your location services for\nmore optimal result',
                        ),
                      );
                    case SearchStatus.failure:
                      return const EmptyState(
                        icon: Icons.wifi_off_rounded,
                        title: 'Something went wrong',
                        subtitle: Text('Check your connection and retry.'),
                      );
                    case SearchStatus.idle:
                      if (state.recent.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Search verified student listings across Kigali',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        );
                      }
                      return _ResultsList(
                        header: 'Recent',
                        icon: Icons.schedule,
                        properties: state.recent,
                        onSelect: (p) => _open(context, p),
                      );
                    case SearchStatus.results:
                      return ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        children: [
                          if (state.recent.isNotEmpty) ...[
                            _SectionHeader(title: 'Recent'),
                            for (final property in state.recent.take(2))
                              _ResultTile(
                                icon: Icons.schedule,
                                property: property,
                                onTap: () => _open(context, property),
                              ),
                            const SizedBox(height: 12),
                          ],
                          _SectionHeader(title: 'Result'),
                          for (final property in state.results)
                            _ResultTile(
                              icon: Icons.location_on_outlined,
                              property: property,
                              onTap: () => _open(context, property),
                            ),
                        ],
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final String header;
  final IconData icon;
  final List<Property> properties;
  final ValueChanged<Property> onSelect;

  const _ResultsList({
    required this.header,
    required this.icon,
    required this.properties,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        _SectionHeader(title: header),
        for (final property in properties)
          _ResultTile(
            icon: icon,
            property: property,
            onTap: () => onSelect(property),
          ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  final IconData icon;
  final Property property;
  final VoidCallback onTap;

  const _ResultTile({
    required this.icon,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
          leading: Icon(icon, color: AppColors.dark),
          title: Text(
            property.name,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            property.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(color: AppColors.grey),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
