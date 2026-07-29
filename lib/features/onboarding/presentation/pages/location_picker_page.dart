import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../settings/presentation/cubit/preferences_cubit.dart';

/// Neighbourhood chooser behind "Select it manually".
///
/// The Figma shows an interactive map here. Rendering real tiles needs the
/// Google Maps SDK and a billable API key, which this milestone does not
/// carry — so this is a searchable list of the Kigali neighbourhoods students
/// actually named in interviews. Picking one saves the district as the
/// student's preferred area, which ranks matching listings higher.
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

/// One searchable place.
class _Place {
  final String name;
  final String district;

  const _Place(this.name, this.district);
}

const _places = <_Place>[
  _Place('Kimihurura', 'Gasabo'),
  _Place('Remera', 'Gasabo'),
  _Place('Kacyiru', 'Gasabo'),
  _Place('Kimironko', 'Gasabo'),
  _Place('Kibagabaga', 'Gasabo'),
  _Place('Nyarutarama', 'Gasabo'),
  _Place('Gisozi', 'Gasabo'),
  _Place('Kicukiro Centre', 'Kicukiro'),
  _Place('Kanombe', 'Kicukiro'),
  _Place('Niboye', 'Kicukiro'),
  _Place('Gatenga', 'Kicukiro'),
  _Place('Kagarama', 'Kicukiro'),
  _Place('Nyamirambo', 'Nyarugenge'),
  _Place('Kiyovu', 'Nyarugenge'),
  _Place('Muhima', 'Nyarugenge'),
  _Place('Gitega', 'Nyarugenge'),
  _Place('Nyakabanda', 'Nyarugenge'),
];

/// Stateful only to own the search controller.
class _LocationPickerPageState extends State<LocationPickerPage> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<_Place> get _results {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _places;
    return _places
        .where(
          (p) =>
              p.name.toLowerCase().contains(query) ||
              p.district.toLowerCase().contains(query),
        )
        .toList();
  }

  void _choose(BuildContext context, _Place place) {
    context.read<PreferencesCubit>().setPreferredCity(place.district);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Showing listings around ${place.name} first')),
      );
    Navigator.of(context).pop(place.district);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final results = _results;

    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, state) {
        final selected = state.preferences.preferredCity;

        return Scaffold(
          appBar: AppBar(title: const Text('Choose location')),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Search a neighbourhood or district',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                      ),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: _search.clear,
                              icon: const Icon(Icons.close),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 15,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Currently showing $selected first',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: results.isEmpty
                      ? const EmptyState(
                          icon: Icons.location_off_outlined,
                          title: 'No matching area',
                          subtitle: Text(
                            'Try a district name like Gasabo or Kicukiro',
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: results.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final place = results[index];
                            final isSelected = place.district == selected;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              onTap: () => _choose(context, place),
                              leading: Icon(
                                Icons.location_on_outlined,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.grey,
                              ),
                              title: Text(
                                place.name,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text('${place.district}, Kigali'),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primary,
                                    )
                                  : const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.grey,
                                    ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
