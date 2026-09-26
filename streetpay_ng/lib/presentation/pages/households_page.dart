import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../models/household.dart';
import '../cubits/app_data_cubit.dart';

class HouseholdsPage extends StatelessWidget {
  const HouseholdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Households')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showEditSheet(context),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: BlocBuilder<AppDataCubit, AppDataState>(
        builder: (context, state) {
          if (state.households.isEmpty) {
            return Center(
              child: Text('No households yet. Tap + to register one.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            );
          }
          final sorted = [...state.households]
            ..sort((a, b) => a.houseNumber.compareTo(b.houseNumber));
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const Gap(10),
            itemBuilder: (context, i) {
              final h = sorted[i];
              return Dismissible(
                key: Key(h.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(context, h),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                ),
                onDismissed: (_) => context.read<AppDataCubit>().deleteHousehold(h.id),
                child: InkWell(
                  onTap: () => _showEditSheet(context, household: h),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(h.houseNumber,
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.occupantName,
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                            Text('${h.type.label} · ${FormatUtils.currency(h.monthlyDue)}/mo',
                                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
                    ]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Household h) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Remove household?'),
            content: Text('This removes ${h.occupantName} and their payment history.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
            ],
          ),
        ) ??
        false;
  }

  void _showEditSheet(BuildContext context, {Household? household}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(
        value: context.read<AppDataCubit>(),
        child: _HouseholdForm(household: household),
      ),
    );
  }
}

class _HouseholdForm extends StatefulWidget {
  final Household? household;
  const _HouseholdForm({this.household});

  @override
  State<_HouseholdForm> createState() => _HouseholdFormState();
}

class _HouseholdFormState extends State<_HouseholdForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _houseCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _dueCtrl;
  late ResidentType _type;

  @override
  void initState() {
    super.initState();
    final h = widget.household;
    _nameCtrl = TextEditingController(text: h?.occupantName ?? '');
    _houseCtrl = TextEditingController(text: h?.houseNumber ?? '');
    _phoneCtrl = TextEditingController(text: h?.phone ?? '');
    _type = h?.type ?? ResidentType.landlord;
    _dueCtrl = TextEditingController(
      text: (h?.monthlyDue ?? Household.defaultDueFor(_type)).toString(),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _houseCtrl.dispose();
    _phoneCtrl.dispose();
    _dueCtrl.dispose();
    super.dispose();
  }

  void _applyDefaultDue() {
    _dueCtrl.text = Household.defaultDueFor(_type).toString();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.household != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(editing ? 'Edit household' : 'Register household',
              style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
          const Gap(20),
          TextField(
            controller: _nameCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Occupant name'),
          ),
          const Gap(12),
          TextField(
            controller: _houseCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'House number'),
          ),
          const Gap(12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Phone (optional)'),
          ),
          const Gap(12),
          Row(children: [
            Expanded(
              child: _TypeToggle(
                label: 'Landlord',
                selected: _type == ResidentType.landlord,
                onTap: () => setState(() {
                  _type = ResidentType.landlord;
                  _applyDefaultDue();
                }),
              ),
            ),
            const Gap(10),
            Expanded(
              child: _TypeToggle(
                label: 'Tenant',
                selected: _type == ResidentType.tenant,
                onTap: () => setState(() {
                  _type = ResidentType.tenant;
                  _applyDefaultDue();
                }),
              ),
            ),
          ]),
          const Gap(12),
          TextField(
            controller: _dueCtrl,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Monthly due (₦)'),
          ),
          const Gap(20),
          ElevatedButton(
            onPressed: () {
              final name = _nameCtrl.text.trim();
              final houseNo = _houseCtrl.text.trim();
              if (name.isEmpty || houseNo.isEmpty) return;
              final due = int.tryParse(_dueCtrl.text.trim()) ?? Household.defaultDueFor(_type);
              final cubit = context.read<AppDataCubit>();
              if (editing) {
                cubit.updateHousehold(widget.household!.copyWith(
                  occupantName: name,
                  houseNumber: houseNo,
                  phone: _phoneCtrl.text.trim(),
                  type: _type,
                  monthlyDue: due,
                ));
              } else {
                cubit.addHousehold(
                  occupantName: name,
                  houseNumber: houseNo,
                  type: _type,
                  phone: _phoneCtrl.text.trim(),
                  monthlyDue: due,
                );
              }
              Navigator.pop(context);
            },
            child: Text(editing ? 'Save changes' : 'Register household'),
          ),
        ],
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeToggle({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(label,
              style: AppTextStyles.labelLarge
                  .copyWith(color: selected ? AppColors.primary : AppColors.textSecondary)),
        ),
      );
}
