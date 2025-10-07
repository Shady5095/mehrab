import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/assets.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/features/authentication/manager/login_screen_cubit/login_screen_cubit.dart';
import 'package:mehrab/features/authentication/manager/login_screen_cubit/login_screen_state.dart';
import '../../../../core/widgets/height_sized_box.dart';
import 'login_text_form_and_button.dart';

class LoginViewBody extends StatelessWidget {
  const LoginViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeightSizedBox(height: 2),
                  Center(
                    child: Image(
                      image: AssetImage(AppAssets.appLogo),
                      width: 40.wR,
                      height: 40.wR,
                    ),
                  ),
                  HeightSizedBox(height: 2),
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      AppStrings.welcomeText.tr(context),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: Text(
                      AppStrings.welcomeTextDescription.tr(context),
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  HeightSizedBox(height: 2),
                  LoginTextFormAndButton(),
                ],
              ),
            ),
            BlocBuilder<LoginCubit, LoginStates>(
              builder: (context, state) {
                if(state is!BiometricsLoginLoadingState) {
                  return SizedBox.shrink();
                }
                return Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: CircularProgressIndicator(),),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
