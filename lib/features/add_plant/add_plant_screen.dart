import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sprig/core/errors/app_exceptions.dart';
import 'package:sprig/core/models/plant.dart';
import 'package:sprig/core/validators.dart';
import 'package:sprig/state/plant_view_model.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_text.dart';
import 'package:sprig/widgets/app_snack.dart';
import 'package:sprig/widgets/app_text_field.dart';
import 'package:sprig/widgets/category_icon.dart';
import 'package:sprig/widgets/choice_chip.dart';
import 'package:sprig/widgets/circle_icon_button.dart';
import 'package:sprig/widgets/mascot.dart';
import 'package:sprig/widgets/pill_button.dart';
import 'package:sprig/widgets/plant_art.dart';

/// Halaman 7: Tambah tanaman sendiri (form dengan validasi).
class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _latin = TextEditingController();
  final _days = TextEditingController(text: '7');
  final _notes = TextEditingController();

  PlantCategory _category = PlantCategory.indoor;
  LightLevel _light = LightLevel.medium;
  String? _formError;
  int _pulse = 0;

  @override
  void dispose() {
    _name.dispose();
    _latin.dispose();
    _days.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final basic = Validators.plantName(value);
    if (basic != null) return basic;
    if (context.read<PlantViewModel>().nameExists(value!.trim())) {
      return 'Nama ini sudah ada di daftar';
    }
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() => _formError = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.lightImpact();
      setState(() => _formError = 'Periksa kembali isian yang ditandai merah.');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final plant = context.read<PlantViewModel>().addCustomPlant(
            name: _name.text,
            latinName: _latin.text,
            notes: _notes.text,
            category: _category,
            light: _light,
            waterEveryDays: int.parse(_days.text.trim()),
          );
      HapticFeedback.mediumImpact();
      navigator.pop();
      showAppSnackOn(messenger, '${plant.name} ditambahkan ke kebun');
    } on AppException catch (e) {
      setState(() => _formError = e.message);
    } catch (_) {
      setState(() => _formError = 'Gagal menyimpan. Silakan coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.close_rounded,
                        semanticLabel: 'Tutup',
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tanaman baru', style: AppText.display),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Catat tanamanmu sendiri dan atur jadwal siramnya.',
                                    style: AppText.bodyMuted,
                                  ),
                                ],
                              ),
                            ),
                            Mascot(
                              size: 84,
                              pulse: _pulse,
                              mood: _formError != null
                                  ? MascotMood.sad
                                  : MascotMood.idle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: 140,
                            height: 140,
                            child: PlantArtPanel(
                              style: _category.art,
                              modelKey: _category.modelKey,
                              tintIndex: _category.index + 1,
                              radius: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          label: 'Nama tanaman',
                          hint: 'Contoh: Monstera kesayangan',
                          controller: _name,
                          validator: _validateName,
                          maxLength: 30,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Nama latin (opsional)',
                          hint: 'Contoh: Monstera deliciosa',
                          controller: _latin,
                          validator: (v) => Validators.optionalMax(v, 40),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        Text('Kategori', style: AppText.label),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final c in PlantCategory.values)
                              AppChoiceChip(
                                label: c.label,
                                leading: CategoryIcon(
                                  category: c,
                                  active: c == _category,
                                ),
                                selected: c == _category,
                                onTap: () => setState(() {
                                  _category = c;
                                  _pulse++;
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text('Kebutuhan cahaya', style: AppText.label),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final l in LightLevel.values)
                              AppChoiceChip(
                                label: l.label,
                                selected: l == _light,
                                onTap: () => setState(() => _light = l),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Siram setiap berapa hari?',
                          controller: _days,
                          validator: Validators.waterDays,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          suffixText: 'hari',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final d in const [3, 7, 14, 30])
                              AppChoiceChip(
                                label: '$d hari',
                                selected: _days.text.trim() == '$d',
                                onTap: () => setState(
                                  () => _days.text = '$d',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Catatan (opsional)',
                          hint: 'Mis. diletakkan dekat jendela',
                          controller: _notes,
                          validator: (v) => Validators.optionalMax(v, 140),
                          maxLines: 3,
                          minLines: 2,
                          maxLength: 140,
                        ),
                        if (_formError != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.dangerSoft,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 20,
                                  color: AppColors.danger,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _formError!,
                                    style: AppText.caption.copyWith(
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        PillButton(
                          label: 'Simpan ke kebun',
                          icon: Icons.check_rounded,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
