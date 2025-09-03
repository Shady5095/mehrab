import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/utilities/validator.dart';
import '../../../../core/widgets/my_text_field.dart';
import '../../manager/login_screen_cubit/login_screen_cubit.dart';

class PasswordSuffixIconWidget extends StatelessWidget {
  const PasswordSuffixIconWidget({
    super.key,
    required this.onTap,
    required this.isShowPassword,
  });

  final VoidCallback onTap;
  final bool isShowPassword;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        !isShowPassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
        color: Colors.grey,
        size: 25.sp,
      ),
    );
  }
}

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({super.key});

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool isShowPassword = false;

  late final cubit = LoginCubit.instance(context);

  void togglePassword() {
    setState(() {
      isShowPassword = !isShowPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyTextField(
      autofillHints: const [AutofillHints.password],
      onFieldSubmitted: (_) => cubit.buttonFunction(context),
      focusNode: cubit.secondFocusNode,
      validator: (value) => AppValidator.passwordValidator(value, context),
      controller: cubit.passwordController,
      obsceure: !isShowPassword,
      suffixIcon: PasswordSuffixIconWidget(
        onTap: togglePassword,
        isShowPassword: isShowPassword,
      ),
      hint: AppStrings.password.tr(context),
    );
  }
}
