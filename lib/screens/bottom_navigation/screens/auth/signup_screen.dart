import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:unilever_activo/domain/services/auth/signup_service.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';
import 'package:unilever_activo/utils/widgets/global_method.dart';

import '../../../../navigations/app_routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/FractionallyElevatedButton.dart';
import '../../../../utils/widgets/custom_text_field.dart';
import '../../../../utils/widgets/heading_text.dart';
import '../../../../utils/widgets/title_text.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool passFilled = false;
  bool userFilled = false;
  bool nameFilled = false;

  @override
  void dispose() {
    // TODO: implement dispose
    userNameController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Curved Container with Logo
                  ClipPath(
                    clipper: BottomCurveClipper(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: double.infinity,
                      color: AppColors.primaryColor, // Replace with AppColors.appBlue
                      child: Center(
                        child: Image.asset(
                          'assets/app_icon/R.png',
                          width: MediaQuery.of(context).size.height * 0.25,
                        ),
                      ),
                    ),
                  ),

                  // Form Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),

                          headingText('User Name'),

                          nameTextField(nameFilled),
                          const SizedBox(
                            height: 5,
                          ),
                          headingText('Login ID'),
                          const SizedBox(
                            height: 5,
                          ),
                          userTextField(userFilled),
                          const SizedBox(
                            height: 15,
                          ),

                          headingText('Password'),
                          const SizedBox(
                            height: 5,
                          ),

                          passTextField(passFilled),
                          const SizedBox(
                            height: 15,
                          ),

                          InkWell(
                            onTap: () {
                              // Navigate to the register screen
                              Navigator.pushNamed(context, AppRoutes.register);
                            },
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.black, // Customize the default text color
                                ),
                                children: <TextSpan>[
                                  const TextSpan(
                                      text: 'Already have an account? ', style: TextStyle(color: Colors.white)),
                                  TextSpan(
                                    text: 'Click to login',
                                    style: const TextStyle(
                                      color: AppColors.primaryColor, // Customize the link color
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Navigate to the register screen
                                        Navigator.pushNamed(context, AppRoutes.login);
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          loginButton(),
                          // AppSize.vrtSpace(10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget registerText() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: GestureDetector(
        onTap: () {
          // Get.toNamed(RouteNames.signupScreen);
        },
        child: Row(
          children: [
            TitleText(
                title: 'Already have an account? ',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                )),
            TitleText(
                title: 'Register',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }

  Padding forgotPasswordText() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: GestureDetector(
        onTap: () {
          // Get.toNamed(RouteNames.forgetPassword);
        },
        child: TitleText(
            title: 'Forgot Password?',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }

  CustomTextFormField passTextField(bool passFilled) {
    return CustomTextFormField(
      hint: 'Password',
      filled: passFilled,
      controller: passwordController,
      validator: validator,
      onSuffixTap: () {},
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: false,
    );
  }

  CustomTextFormField userTextField(bool userFilled) {
    return CustomTextFormField(
      controller: userNameController,
      hint: 'Email',
      obscureText: false,
      validator: validator,
      filled: userFilled,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {
        if (value?.isNotEmpty ?? false) {
        } else {}
      },
    );
  }

  CustomTextFormField nameTextField(bool userFilled) {
    return CustomTextFormField(
      controller: nameController,
      hint: 'Name',
      obscureText: false,
      validator: validator,
      filled: userFilled,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {
        if (value?.isNotEmpty ?? false) {
        } else {}
      },
    );
  }

  Image buildIcons(String path) {
    return Image.asset(
      path,
      color: AppColors.white,
      height: 20,
      width: 20,
    );
  }

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field can\'t be empty';
    }
    return null;
  }

  Widget headingText(String text) {
    return HeadingText(
      text: text,
    );
  }

  Widget tagHeading(String text) {
    return HeadingText(
      text: text,
      fontSize: 20.sp,
      color: Colors.redAccent,
    );
  }

  Widget biometricText(String text) {
    return HeadingText(
      text: text,
      fontSize: 17.sp,
    );
  }

  Widget loginButton() {
    return Center(
      child: FractionallyElevatedButton(
          onTap: () async {
            if (_formKey.currentState!.validate()) {
              var response = await SignupServce()
                  .signup(name: nameController.text, email: userNameController.text, password: passwordController.text);

              // print('the runtime type is ${response.runtimeType}');
              // if (response != null && response.contains('User registered successfully.')) {
              //   var newUser = {
              //     'username': nameController.text,
              //     'email': userNameController.text,
              //     'password': passwordController.text
              //   };
              //   var users = await StorageService().read(userRegister);
              //   var list = [];
              //   if (users != null) {
              //     list.add(users);
              //   }
              //   list.add(newUser);
              //
              //   await StorageService().write(userRegister, list.toString());
              snackBar('Registered Successfully', context, color: Colors.green);

              pushNamed(AppRoutes.login);
            } else {
              snackBar('Something Went Wrong', context, color: Colors.redAccent);
            }
          },
          child: TitleText(
            title: 'SIGN UP',
            color: Colors.white,
            fontSize: 20,
            weight: FontWeight.w700,
          )),
    );
  }

  Future loading() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> errorDialog(String msg) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: TitleText(
              title: msg,
              fontSize: 20,
              weight: FontWeight.w500,
            ),
          ),
          actions: [
            Center(
              child: FractionallyElevatedButton(
                onTap: () {},
                child: TitleText(
                  title: 'OK',
                  color: AppColors.white,
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50); // Start slightly above the bottom-left corner
    path.quadraticBezierTo(
      size.width / 2, size.height, // Control point at the bottom center
      size.width, size.height - 50, // Slightly above the bottom-right corner
    );
    path.lineTo(size.width, 0); // Top-right corner
    path.lineTo(0, 0); // Top-left corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
