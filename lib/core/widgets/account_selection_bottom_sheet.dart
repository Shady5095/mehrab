import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/teacher_bottom_sheet_design.dart';
import '../utilities/services/account_storage_service.dart';

class AccountSelectionBottomSheet extends StatefulWidget {
  final Map<String, String> accounts;
  final ValueChanged<String> onSelect; // استدعاء عند اختيار حساب
  final ValueChanged<String> onDelete; // استدعاء عند حذف حساب

  const AccountSelectionBottomSheet({
    super.key,
    required this.accounts,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  State<AccountSelectionBottomSheet> createState() =>
      _AccountSelectionBottomSheetState();
}

class _AccountSelectionBottomSheetState
    extends State<AccountSelectionBottomSheet> {
  late Map<String, String> accounts;

  @override
  void initState() {
    super.initState();
    accounts = {...widget.accounts};
  }

  Future<void> _deleteAccount(String email) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppStrings.deleteAccount.tr(context)),
            content: Text(
              "${AppStrings.areYouSureDeleteAccount.tr(context)} $email؟",
              style: TextStyle(color: Colors.black, fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  AppStrings.cancel.tr(context),
                  style: TextStyle(color: Colors.black, fontSize: 14.sp),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  AppStrings.delete.tr(context),
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await AccountStorage.removeAccount(email);
      accounts = await AccountStorage.getAccounts();
      widget.onDelete(email);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountKeys = accounts.keys.toList();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MyBottomSheetDesign(
        children: [
          const SizedBox(height: 10),
          Text(
            AppStrings.chooseAccountToSignIn.tr(context),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                itemCount: accountKeys.length,
                shrinkWrap: true,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final email = accountKeys[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.account_circle, size: 30.sp),
                    title: Text(email, style: TextStyle(fontSize: 14.sp)),
                    onTap: () => widget.onSelect(email),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red,size: 25.sp,),
                      onPressed: () => _deleteAccount(email),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
