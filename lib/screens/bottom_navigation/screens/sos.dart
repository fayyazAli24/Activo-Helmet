import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

import '../../../app/app_keys.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/widgets/app_button.dart';

class SOS extends StatefulWidget {
  SOS({Key? key}) : super(key: key);

  @override
  State<SOS> createState() => _SOSState();
}

class _SOSState extends State<SOS> {
  final _formKey = GlobalKey<FormState>();

  String? value;
  TextEditingController statusDescController = TextEditingController();
  bool check = false;

  Future<void> init() async {
    check = await checkStorage();
  }

  //
  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 10.h,
            ),
            Text(
              "Comming Soon",
              style: TextStyle(color: Colors.redAccent, fontSize: 18),
            ),
            SizedBox(
              height: 10.h,
            ),
            const CircleAvatar(
              backgroundColor: Colors.redAccent,
              radius: 50,
              child: Center(child: Text(style: TextStyle(fontSize: 20, color: Colors.white), "SOS")),
            ),
            SizedBox(
              height: 3.h,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                width: 100.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4), // Shadow color with opacity
                      spreadRadius: 2, // How far the shadow spreads
                      blurRadius: 5, // Blur effect of the shadow
                      offset: const Offset(0, 4), // Position of the shadow (horizontal and vertical)
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 2.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Add a Contact for SOS signal",
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          onTap: () {
                            Get.defaultDialog(
                              content: Form(
                                key: _formKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      StatusDescTextField(),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                AppButton(
                                    child: const AppText(
                                      text: 'Cancel',
                                    ),
                                    onPressed: () async {
                                      pop();
                                    }),
                                AppButton(
                                    child: const AppText(
                                      text: 'Add',
                                    ),
                                    onPressed: () async {
                                      if (!(_formKey.currentState?.validate() ?? false)) {
                                        return invalidDialog();
                                      } else {
                                        await StorageService().write(sos, statusDescController.text);
                                        await init();
                                        pop();
                                      }
                                    }),
                              ],
                            );
                          },
                          child: const CircleAvatar(
                            backgroundColor: AppColors.test4,
                            child: Icon(Icons.add),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 1.3.h,
                    ),
                    const Divider(),
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      width: 55.w,
                      height: 7.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                            spreadRadius: 2, // How far the shadow spreads
                            blurRadius: 5, // Blur effect of the shadow
                            offset: const Offset(0, 4), // Position of the shadow (horizontal and vertical)
                          ),
                        ],
                      ),
                      child: Center(
                        child: value != null
                            ? Text(
                                "$value",
                                style: TextStyle(color: Colors.black38, fontSize: 16),
                              )
                            : Text(
                                "No contact added",
                                style: TextStyle(color: Colors.black38, fontSize: 16),
                              ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  TextFormField StatusDescTextField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Description',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners when focused
          borderSide: const BorderSide(color: Colors.blue, width: 2.0), // Border color when focused
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners when not focused
          borderSide: const BorderSide(color: Colors.grey, width: 1.5), // Border color when enabled
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners when there's an error
          borderSide: const BorderSide(color: Colors.red, width: 1.5), // Border color for error
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners when focused with error
          borderSide: const BorderSide(color: Colors.red, width: 2.0), // Border color for focused error
        ),
      ),
      controller: statusDescController,
      validator: (value) {
        // Regular expression for a valid Pakistani phone number (starting with '03' and 11 digits long)
        final phoneRegex = RegExp(r'^(03[0-9]{9})$');

        if (value == null || value.isEmpty) {
          return "Field can't be empty";
        } else if (!phoneRegex.hasMatch(value)) {
          return "Enter a valid Pakistani phone number";
        }

        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onTapOutside: (event) {
        final focus = FocusScope.of(context);
        focus.unfocus();
      },
    );
  }

  Future<bool> checkStorage() async {
    var checkNumber = await StorageService().read(sos);
    if (checkNumber != null) {
      setState(() {
        value = checkNumber;
      });
      return true;
    }
    return false;
  }

  Future<dynamic> invalidDialog() {
    return showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Center(
            child: AppText(
              text: 'Please add a number',
              weight: FontWeight.w500,
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  pop();
                },
                child: const Center(child: AppText(text: 'Close')),
              ),
            ),
          ],
        );
      },
    );
  }
}
