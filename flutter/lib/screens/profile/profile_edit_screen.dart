// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trailcatch/constants.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trailcatch/models/dog_model.dart';
import 'package:trailcatch/models/user_model.dart';
import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/widgets/avatar_image.dart';
import 'package:trailcatch/widgets/buttons/field_button.dart';
import 'package:trailcatch/widgets/buttons/gesture_button.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:trailcatch/widgets/buttons/simple_button.dart';
import 'package:trailcatch/widgets/buttons/widget_button.dart';
import 'package:trailcatch/widgets/scaffolds/simple_scaffold.dart';
import 'package:trailcatch/widgets/textfield.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final PageController _ctrl;
  late int _page;

  late bool _loading;
  late bool _isValid;
  late bool _isChanged;

  File? _pickerUserPictureFile;
  final Map<String, File> _pickerDogPictureFiles = {};

  //  --

  late final TextEditingController _usernameCtrl;
  late String _usernameError;

  late final TextEditingController _firstNameCtrl;
  late String _firstNameError;

  late final TextEditingController _lastNameCtrl;
  late String _lastNameError;

  late int _gender;
  DateTime? _birthday;

  late String? _uiso3;
  late Map<String, dynamic> _contacts;

  // --

  late final TextEditingController _dogNameCtrl;
  late String _dogNameError;

  late final TextEditingController _breedNameCtrl;
  late String _breedNameError;

  late final List<DogModel> _dogs;
  void _reDogs() {
    List<DogModel> dogs0 = [];
    for (var dog in _dogs) {
      dogs0.add(DogModel.fromJson(dog.json));
    }
    _dogs.clear();
    _dogs.addAll(dogs0);
  }

  @override
  void initState() {
    _ctrl = PageController(viewportFraction: 0.925);
    _page = 0;

    _loading = false;
    _isValid = true;
    _isChanged = false;

    _usernameCtrl = TextEditingController();
    _usernameError = '';

    _firstNameCtrl = TextEditingController();
    _firstNameError = '';

    _lastNameCtrl = TextEditingController();
    _lastNameError = '';

    _dogNameCtrl = TextEditingController();
    _dogNameError = '';

    _breedNameCtrl = TextEditingController();
    _breedNameError = '';

    if (appVM.isUserExists) {
      _usernameCtrl.text = appVM.user.username;
      _firstNameCtrl.text = appVM.user.firstName;
      _lastNameCtrl.text = appVM.user.lastName;
      _gender = appVM.user.gender;
      _birthday = appVM.settings.birthdate;
      _uiso3 = appVM.user.uiso3;
      _contacts = Map<String, dynamic>.from(appVM.user.contacts);
      _dogs = appVM.user.dogs0;
    } else {
      final (username, firstName, lastName) = fnFullNameFromAuth(appVM.auth);
      _usernameCtrl.text = username;
      _firstNameCtrl.text = firstName;
      _lastNameCtrl.text = lastName;
      _gender = -1;
      _birthday = null;
      _uiso3 = null;
      _contacts = {};
      _dogs = [];
    }

    if (_dogs.isNotEmpty) {
      _dogNameCtrl.text = _dogs.first.name;
      _breedNameCtrl.text = _dogs.first.breedCustomName;
    } else {
      _dogs.add(DogModel.empty(_dogs.length));
    }

    scheduleMicrotask(() {
      _validate();
      fnPreCacheWikiDogImage5th();
    });

    super.initState();
  }

  @override
  void dispose() {
    _ctrl.dispose();

    _usernameCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _dogNameCtrl.dispose();
    _breedNameCtrl.dispose();

    super.dispose();
  }

  DogModel get dog {
    int nInx = _page - 1;
    if (nInx == -1) nInx = 0;

    return _dogs.elementAtOrNull(nInx) ?? _dogs.first;
  }

  Future<void> _createOrUpdateUser() async {
    if (fnIsDemo(silence: false)) return;

    setState(() => _loading = true);

    await _validateUserName();
    if (_usernameError.isNotEmpty) {
      setState(() {
        _loading = false;
      });
      return;
    }

    String? userId0;

    if (appVM.isUserExists) {
      userId0 = appVM.user.userId;

      await userServ.fnUsersUpdate(
        username: _usernameCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        gender: _gender,
        birthdate: _birthday!,
        uiso3: _uiso3,
        contacts: _contacts,
      );
    } else {
      userId0 = await userServ.fnUsersCreate(
        username: _usernameCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        gender: _gender,
        birthdate: _birthday!,
        uiso3: _uiso3,
        contacts: _contacts,
        lang: appVM.lang,
        msrunit: fnKmOrMiles(_uiso3),
        fdayofweek: 1,
        timeformat: 24,
        fcmToken: await fbServ.fcmToken(),
      );

      appVM.showPinDesc = true;
      appVM.showFcmDesc = true;
      appVM.showTtrDesc = true;

      await userServ.fnUsersRelationship(
        userId: '91dc5c15-e858-4b62-a28c-e32ffd78f503',
        rlship: 1,
      );
    }

    if (userId0 != null) {
      if (_pickerUserPictureFile?.path != null) {
        storageServ.deleteLocalPictureUUID(uuid: userId0);

        await storageServ.uploadPictureUUID(
          userId: userId0,
          uuid: userId0,
          filePath: _pickerUserPictureFile!.path,
        );
      }

      for (var dog in _dogs) {
        if (dog.name.isEmpty || dog.gender == 0 || dog.birthdate.year == 1900) {
          continue;
        }

        final String? dogId0 = await userServ.fnUsersDogsUpsert(
          dogId: dog.userId != '0' ? dog.dogId : null,
          name: dog.name.trim(),
          gender: dog.gender,
          birthdate: dog.birthdate,
          breedId: dog.breedId,
          breedCustomName: dog.breedCustomName,
          inOurHeartsDateAt: dog.inOurHeartsDateAt,
        );

        if (dogId0 != null) {
          final File? file = _pickerDogPictureFiles[dog.dogId];
          if (file?.path != null) {
            storageServ.deleteLocalPictureUUID(uuid: dogId0);

            await storageServ.uploadPictureUUID(
              userId: userId0,
              uuid: dogId0,
              filePath: file!.path,
            );
          }
        }
      }
    }

    if (stVM.isError) stVM.clearError();

    // --

    if (appVM.isUserExists) {
      setState(() {
        _loading = false;
        _isChanged = false;
      });

      await appVM.reFetchMyself();
      await appVM.reFetchSettings();
      appVM.notify();
    } else {
      await appVM.init1();

      if (mounted) {
        setState(() {
          _loading = false;
          _isChanged = false;
        });
      }
    }
  }

  Future<void> _validateUserName() async {
    _usernameCtrl.text = fnFilterText(_usernameCtrl.text);

    if (!fnValidateUsername(_usernameCtrl.text)) {
      _usernameError =
          'Username must be at least 5 and no more than 30 characters long, and can contain only letters, numbers, dots and underscores.';
    } else {
      _usernameError = '';
    }

    if (_usernameError.isNotEmpty) {
      setState(() {});
      return;
    }

    final String username = appVM.isUserExists ? appVM.user.username : '';
    if (_usernameCtrl.text != username) {
      setState(() => _loading = true);

      final isExisted = await userServ.fnUsersUsernameExists(
        username: _usernameCtrl.text,
      );
      if (isExisted) {
        _usernameError = 'Username already exists';
      }
    }
  }

  void _validate() {
    _isValid = true;
    _isChanged = false;

    if (_usernameCtrl.text.isEmpty ||
        _firstNameCtrl.text.isEmpty ||
        _lastNameCtrl.text.isEmpty) {
      setState(() {
        _isValid = false;
      });
      return;
    }

    if (_usernameError.isNotEmpty ||
        _firstNameError.isNotEmpty ||
        _lastNameError.isNotEmpty) {
      setState(() {
        _isValid = false;
      });
      return;
    }

    if (_birthday == null) {
      setState(() {
        _isValid = false;
      });
      return;
    }

    if (appVM.isUserExists) {
      if (_lastNameCtrl.text != appVM.user.lastName) {
        _isChanged = true;
      }

      if (_birthday != appVM.settings.birthdate) {
        _isChanged = true;
      }

      if (_usernameCtrl.text != appVM.user.username) {
        _isChanged = true;
      }

      if (_firstNameCtrl.text != appVM.user.firstName) {
        _isChanged = true;
      }

      if (_gender != appVM.user.gender) {
        _isChanged = true;
      }

      if (_birthday != appVM.settings.birthdate) {
        _isChanged = true;
      }

      if (_uiso3 != appVM.user.uiso3) {
        _isChanged = true;
      }

      if (!mapEquals(_contacts, appVM.user.contacts)) {
        _isChanged = true;
      }

      for (var dog1 in _dogs) {
        final dog0 = DogModel.fromJson(dog1.json);

        if (dog0.name != dog1.name) {
          _isChanged = true;
        }

        if (dog0.gender != dog1.gender) {
          _isChanged = true;
        }

        if (dog0.birthdate != dog1.birthdate) {
          _isChanged = true;
        }

        if (dog0.age != dog1.age) {
          _isChanged = true;
        }

        if (dog0.breedId != dog1.breedId) {
          _isChanged = true;
        }

        if (dog0.breedCustomName != dog1.breedCustomName) {
          _isChanged = true;
        }

        if (dog0.inOurHeartsDateAt != dog1.inOurHeartsDateAt) {
          _isChanged = true;
        }
      }
    }

    setState(() {
      _isValid = true;
    });
  }

  Future<void> _changeUserOrDogPhoto({
    required bool camera,
    DogModel? dog,
  }) async {
    if (fnIsDemo(silence: false)) return;

    setState(() => _loading = true);

    try {
      final file = await fnImagePicker(camera: camera);
      if (file == null) {
        setState(() => _loading = false);
        return;
      }

      if (dog != null) {
        _pickerDogPictureFiles[dog.dogId] = File(file.path);
      } else {
        _pickerUserPictureFile = File(file.path);
      }
    } catch (error) {
      setState(() => _loading = false);

      rethrow;
    }

    setState(() {
      _isChanged = true;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String fullName =
        '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim();
    final String username = _usernameCtrl.text.trim();

    File? userPictureFile = _pickerUserPictureFile;
    if (userPictureFile == null && appVM.isUserExists) {
      userPictureFile = appVM.user.cachePictureFile;
    }

    Widget? wBottom;

    if (context.keyboardHeight == 0) {
      if (!appVM.isUserExists) {
        wBottom = Column(
          children: [
            10.hrr(height: 2),
            if (_page >= 1 && dog.userId == '0') ...[
              AppSimpleButton(
                width: context.width * AppTheme.appBtnWidth,
                text: 'Find Dog Shelter',
                onTap: () async {
                  launchUrl(Uri.parse(
                    'https://www.google.com/search?q=dog+shelter+near+me',
                  ));
                },
              ),
              5.h,
            ],
            AppSimpleButton(
              width: context.width * AppTheme.appBtnWidth,
              text: 'Complete Profile',
              textColor: _isValid ? AppTheme.clYellow : null,
              enable: _isValid,
              onTry: _createOrUpdateUser,
            ),
          ],
        );
      }
    }

    return AppSimpleScaffold(
      loading: _loading,
      title: appVM.isUserExists ? 'Edit Profile' : 'Complete Profile',
      onBack: () async {
        if (appVM.isUserExists) {
          if (_isChanged) {
            AppRoute.showPopup(
              title: 'Would you like to save your changes?',
              [
                AppPopupAction(
                  'Yes',
                  color: AppTheme.clYellow,
                  () async {
                    await _createOrUpdateUser();
                    await AppRoute.goBack();
                  },
                ),
                AppPopupAction(
                  'No',
                  () async {
                    _pickerUserPictureFile = null;
                    _pickerDogPictureFiles.remove(appVM.user.userId);

                    _reDogs();

                    await AppRoute.goBack();
                  },
                ),
              ],
            );
          } else {
            await AppRoute.goBack();
          }
        } else {
          AppRoute.showPopup(
            [
              AppPopupAction(
                'Log Out',
                color: AppTheme.clRed,
                () async {
                  setState(() => _loading = true);

                  await appVM.signOut();

                  if (mounted) {
                    setState(() => _loading = false);
                  }
                },
              ),
              AppPopupAction(
                'Delete Account',
                color: AppTheme.clRed,
                () async {
                  setState(() => _loading = true);

                  await appVM.deleteAccount();

                  if (mounted) {
                    setState(() => _loading = false);
                  }

                  await AppRoute.goTo('/init');
                },
              ),
            ],
          );
        }
      },
      actions: [
        AppWidgetButton(
          onTap: () async {
            final ddog = _dogs.elementAtOrNull(_page);
            if (ddog == null) {
              setState(() {
                _dogs.add(DogModel.empty(_dogs.length));
              });
            }

            await _ctrl.animateToPage(
              _page + 1,
              duration: 250.mlsec,
              curve: Curves.linear,
            );
          },
          child: Container(
            color: AppTheme.clBackground,
            width: 35,
            child: const Icon(
              Icons.plus_one_rounded,
              color: AppTheme.clText,
              size: 28,
            ),
          ),
        ),
        if (_page != 0 && !_isChanged)
          AppWidgetButton(
            onTap: () async {
              int nInx = _page - 1;
              if (nInx == -1) nInx = 0;

              final ddog = _dogs.elementAtOrNull(nInx);
              if (ddog != null) {
                if (ddog.userId != '0') {
                  AppRoute.showPopup(
                    [
                      AppPopupAction(
                        'Delete Dog',
                        color: AppTheme.clRed,
                        () async {
                          if (fnIsDemo(silence: false)) return;

                          setState(() {
                            _dogs.remove(ddog);
                            _pickerDogPictureFiles.remove(ddog.dogId);

                            if (_dogs.isEmpty) {
                              _dogs.add(DogModel.empty(_dogs.length));
                            }
                          });

                          if (ddog.userId != '0') {
                            storageServ.deleteLocalPictureUUID(
                                uuid: ddog.dogId);

                            await storageServ.deletePictureUUID(
                              userId: ddog.userId,
                              uuid: ddog.dogId,
                            );

                            await userServ.fnUsersDogsDelete(dogId: ddog.dogId);

                            await appVM.reFetchMyself();
                            appVM.notify();
                          }

                          await _ctrl.animateToPage(
                            nInx,
                            duration: 250.mlsec,
                            curve: Curves.linear,
                          );

                          setState(() {});
                        },
                      ),
                    ],
                  );
                }
              }
            },
            child: Container(
              color: AppTheme.clBackground,
              width: 35,
              child: const Icon(
                Icons.remove_circle_outline,
                color: AppTheme.clRed,
                size: 28,
              ),
            ),
          ),
        if (appVM.isUserExists && _isValid && _isChanged)
          AppWidgetButton(
            onTap: () async {
              await _createOrUpdateUser();
            },
            child: const Icon(
              Icons.done_all,
              color: AppTheme.clYellow,
              size: 28,
            ),
          ),
      ],
      wBottom: wBottom,
      children: [
        Container(
          width: context.width,
          height: AppTheme.appProfileNavHeight,
          color: AppTheme.clBlack,
          child: PageView(
            controller: _ctrl,
            onPageChanged: (page) {
              setState(() {
                _page = page;

                _dogNameCtrl.text = dog.name;
                _breedNameCtrl.text = dog.breedCustomName;
              });
            },
            children: [
              Container(
                color: AppTheme.clBlack,
                child: Row(
                  children: [
                    AppGestureButton(
                      onTry: () async {
                        AppRoute.showPopup(
                          [
                            AppPopupAction(
                              'Take Photo',
                              () => _changeUserOrDogPhoto(camera: true),
                            ),
                            AppPopupAction(
                              'Upload Photo',
                              () => _changeUserOrDogPhoto(camera: false),
                            ),
                            if (_pickerUserPictureFile != null ||
                                (appVM.isUserExists &&
                                    appVM.user.cachePictureFile != null))
                              AppPopupAction(
                                'Delete Photo',
                                () async {
                                  if (fnIsDemo(silence: false)) return;

                                  AppRoute.showPopup(
                                    [
                                      AppPopupAction(
                                        'Delete Photo',
                                        color: AppTheme.clRed,
                                        () async {
                                          _pickerUserPictureFile = null;

                                          if (appVM.isUserExists) {
                                            storageServ.deleteLocalPictureUUID(
                                              uuid: appVM.user.userId,
                                            );

                                            await storageServ.deletePictureUUID(
                                              userId: appVM.user.userId,
                                              uuid: appVM.user.userId,
                                            );
                                          }

                                          setState(() {});
                                          appVM.notify();
                                        },
                                      ),
                                    ],
                                  );
                                },
                                color: AppTheme.clRed,
                              ),
                          ],
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          4.h,
                          AppAvatarImage(
                            pictureFile: userPictureFile,
                          ),
                          4.h,
                          Text(
                            'Edit',
                            style: const TextStyle(
                              fontSize: 12,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    28.w,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          22.h,
                          Text(
                            fullName.isNotEmpty
                                ? fullName
                                : 'First & Last Name',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  fullName.isEmpty ? AppTheme.clText05 : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '@${username.isNotEmpty ? username : 'username'}',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.0,
                              color: username.isEmpty
                                  ? AppTheme.clText05
                                  : AppTheme.clText08,
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.w,
                  ],
                ),
              ),
              for (var dog in _dogs)
                Container(
                  color: AppTheme.clBlack,
                  child: Row(
                    children: [
                      AppGestureButton(
                        onTry: () async {
                          AppRoute.showPopup(
                            // title: 'Dog photo source',
                            [
                              AppPopupAction(
                                'Take Dog Photo',
                                () => _changeUserOrDogPhoto(
                                  camera: true,
                                  dog: dog,
                                ),
                              ),
                              AppPopupAction(
                                'Upload Dog Photo',
                                () => _changeUserOrDogPhoto(
                                  camera: false,
                                  dog: dog,
                                ),
                              ),
                              if (_pickerDogPictureFiles[dog.dogId] != null ||
                                  dog.cachePictureFile != null)
                                AppPopupAction(
                                  'Delete Dog Photo',
                                  () async {
                                    if (fnIsDemo(silence: false)) return;

                                    AppRoute.showPopup(
                                      [
                                        AppPopupAction(
                                          'Delete Dog Photo',
                                          color: AppTheme.clRed,
                                          () async {
                                            _pickerDogPictureFiles.remove(
                                              dog.dogId,
                                            );

                                            if (dog.userId != '0') {
                                              storageServ
                                                  .deleteLocalPictureUUID(
                                                uuid: dog.dogId,
                                              );

                                              await storageServ
                                                  .deletePictureUUID(
                                                userId: dog.dogId,
                                                uuid: dog.dogId,
                                              );
                                            }

                                            setState(() {});
                                            appVM.notify();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                  color: AppTheme.clRed,
                                ),
                            ],
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            10.h,
                            AppAvatarImage(
                              pictureFile: _pickerDogPictureFiles[dog.dogId] ??
                                  dog.cachePictureFile,
                              isInOurHearts: dog.inOurHeartsDateAt != null,
                            ),
                            4.h,
                            const Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      15.w,
                      Expanded(
                        child: Row(
                          children: [
                            12.w,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  30.h,
                                  Text(
                                    dog.name.isNotEmpty ? dog.name : 'Dog Name',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: dog.name.isEmpty
                                          ? AppTheme.clText05
                                          : null,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            20.w,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Container(
          width: context.width,
          height: 12,
          color: AppTheme.clBlack,
          child: Container(
            padding: const EdgeInsets.only(top: 5),
            alignment: Alignment.topCenter,
            child: Container(
              height: 2,
              width: 120,
              decoration: const BoxDecoration(
                color: AppTheme.clYellow,
                borderRadius: BorderRadius.all(Radius.circular(
                  AppTheme.appBtnRadius,
                )),
              ),
            ),
          ),
        ),
        10.h,
        if (_page == 0) ...[
          //+ person profile
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: Column(
              children: [
                5.h,
                AppTextField(
                  title: 'Username',
                  placeholder: 'Username',
                  ctrl: _usernameCtrl,
                  error: _usernameError,
                  onFocusLost: () async {
                    await _validateUserName();
                    if (mounted) {
                      setState(() => _loading = false);
                    }
                  },
                ),
                0.dl,
                AppTextField(
                  title: 'First Name',
                  placeholder: 'First Name',
                  ctrl: _firstNameCtrl,
                  capitalization: true,
                  error: _firstNameError,
                  onFocusLost: () {
                    _firstNameCtrl.text = fnFilterText(_firstNameCtrl.text);

                    if (!fnValidateFullName(_firstNameCtrl.text)) {
                      _firstNameError =
                          'First Name must be at least 2 and no more than 40 characters long, and can contain only letters, numbers and spaces.';
                    } else {
                      _firstNameError = '';
                    }

                    _validate();
                  },
                ),
                0.dl,
                AppTextField(
                  title: 'Last Name',
                  placeholder: 'Last Name',
                  ctrl: _lastNameCtrl,
                  capitalization: true,
                  error: _lastNameError,
                  onFocusLost: () {
                    _lastNameCtrl.text = fnFilterText(_lastNameCtrl.text);

                    if (!fnValidateFullName(_lastNameCtrl.text)) {
                      _lastNameError =
                          'Last Name must be at least 2 and no more than 40 characters long, and can contain only letters, numbers and spaces.';
                    } else {
                      _lastNameError = '';
                    }

                    _validate();
                  },
                ),
                0.dl,
                AppFieldButton.gender(
                  context,
                  gender: _gender,
                  onSelect: (value) {
                    if (_gender != value) {
                      _gender = value;
                      _validate();
                    }
                  },
                ),
                0.dl,
                AppFieldButton.ageGroup(
                  context,
                  gender: _gender,
                  birthday: _birthday,
                  onSelect: (DateTime value) {
                    _birthday = value;
                    _validate();
                  },
                ),
                if (_birthday != null) ...[
                  2.h,
                  SizedBox(
                    width: context.width,
                    child: Container(
                      padding: const EdgeInsets.only(left: 5),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Text(
                            'Birth Date: ',
                            style: TextStyle(
                                fontSize: 14, color: AppTheme.clText05),
                          ),
                          Text(
                            _birthday!.toMonthYear(),
                            style: AppTheme.tsRegular
                                .copyWith(fontSize: 14, color: AppTheme.clText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                0.dl,
                Row(
                  children: [
                    Expanded(
                      child: AppFieldButton(
                        title: 'Nationality',
                        placeholder: 'Nationality',
                        text: fnCountryNameByIso3(_uiso3),
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());

                          final List? countries =
                              await AppRoute.goTo('/profile_countries', args: {
                            'uiso3s': _uiso3 != null
                                ? [_uiso3!]
                                : List<String>.from([]),
                          });

                          if (countries?.isNotEmpty ?? false) {
                            _uiso3 = countries!.first;

                            _validate();
                          }
                        },
                      ),
                    ),
                    if (_uiso3 != null) ...[
                      8.w,
                      Container(
                        color: AppTheme.clBackground,
                        padding: const EdgeInsets.only(top: 20),
                        child: AppGestureButton(
                          child: const Icon(Icons.close, color: AppTheme.clRed),
                          onTap: () async {
                            _uiso3 = null;

                            _validate();
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                if (appVM.isUserExists) ...[
                  0.dl,
                  AppFieldButton(
                    title: 'Contacts',
                    text: UserContact.formatToStr(_contacts),
                    placeholder: 'No contacts',
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());

                      await AppRoute.goTo('/profile_contacts', args: {
                        'contacts': _contacts,
                      });

                      _validate();
                    },
                  ),
                ],
              ],
            ),
          ),
        ] else ...[
          //+ dog profile
          5.h,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: Column(
              children: [
                AppTextField(
                  title: 'Dog Name',
                  placeholder: 'Dog Name',
                  ctrl: _dogNameCtrl,
                  error: _dogNameError,
                  capitalization: true,
                  onFocusLost: () {
                    if (_dogNameCtrl.text.isEmpty) {
                      setState(() {
                        _dogNameError = '';
                      });

                      return;
                    }

                    _dogNameCtrl.text = fnFilterText(_dogNameCtrl.text);

                    if (!fnValidateFullName(_dogNameCtrl.text)) {
                      _dogNameError =
                          'Dog Name must be at least 2 and no more than 40 characters long, and can contain only letters, numbers and spaces.';
                    } else {
                      _dogNameError = '';
                    }

                    if (_dogNameError.isEmpty) {
                      dog.name = _dogNameCtrl.text;
                    }

                    _validate();
                  },
                ),
                15.h,
                AppFieldButton(
                  title: 'Dog Gender',
                  placeholder: 'Dog Gender',
                  text: UserGender.format(dog.gender),
                  down: true,
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());

                    AppRoute.showPopup(
                      title: 'Gender',
                      [
                        AppPopupAction(
                          'Male',
                          selected: UserGender.male == dog.gender,
                          () async {
                            dog.gender = UserGender.male;

                            _validate();
                          },
                        ),
                        AppPopupAction(
                          'Female',
                          selected: UserGender.female == dog.gender,
                          () async {
                            dog.gender = UserGender.female;

                            _validate();
                          },
                        ),
                      ],
                    );
                  },
                ),
                0.dl,
                AppFieldButton(
                  title: 'Dog Age',
                  placeholder: 'Dog Age',
                  text: dog.birthdate.year != 1900 ? fnDogAge(dog) : '',
                  down: true,
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());

                    List<DateTime> birthday = [];
                    if (dog.userId != '0') {
                      birthday.add(dog.birthdate);
                      if (dog.inOurHeartsDateAt != null) {
                        birthday.add(dog.inOurHeartsDateAt!);
                      }
                    }

                    await AppRoute.goSheetTo('/profile_dog_birthday', args: {
                      'birthday': birthday,
                    });

                    if (birthday.isNotEmpty) {
                      dog.birthdate = birthday.first;
                      dog.age = fnAge(
                        dog.birthdate,
                        death: dog.inOurHeartsDateAt,
                      );
                    }

                    _validate();
                  },
                ),
                if (dog.birthdate.year != 1900) ...[
                  2.h,
                  SizedBox(
                    width: context.width,
                    child: Container(
                      padding: const EdgeInsets.only(left: 5),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Text(
                            'Dog Birth Date: ',
                            style: TextStyle(
                                fontSize: 14, color: AppTheme.clText05),
                          ),
                          Text(
                            dog.birthdate.toMonthYear(),
                            style: AppTheme.tsRegular
                                .copyWith(fontSize: 14, color: AppTheme.clText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                0.dl,
                AppFieldButton(
                  title: 'Dog Breed',
                  placeholder: 'Dog Breed',
                  text: fnDogBreedNameById(dog.breedId),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());

                    final List? res = await AppRoute.goTo(
                      '/profile_dogs_breed',
                      args: {
                        'dogsBreed': [dog.breedId],
                      },
                    );
                    if (res != null) {
                      dog.breedId = res.first;
                      dog.breedCustomName = '';

                      _breedNameCtrl.text = '';
                      _breedNameError = '';

                      _validate();
                    }
                  },
                ),
                4.h,
                const Center(
                  child: Text(
                    'or enter custom breed name',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                8.h,
                AppTextField(
                  title: 'Custom Breed Name',
                  placeholder: 'Custom Breed Name',
                  ctrl: _breedNameCtrl,
                  error: _breedNameError,
                  capitalization: true,
                  onFocusLost: () {
                    setState(() {
                      if (_breedNameCtrl.text.isEmpty) {
                        setState(() {
                          _breedNameError = '';
                        });

                        return;
                      }

                      _breedNameCtrl.text = fnFilterText(_breedNameCtrl.text);

                      if (!fnValidateFullName(_breedNameCtrl.text)) {
                        _breedNameError =
                            'Custom Breen Name must be at least 2 and no more than 40 characters long, and can contain only letters, numbers and spaces.';
                      } else {
                        _breedNameError = '';
                      }
                    });

                    if (_breedNameError.isEmpty) {
                      dog.breedId = 0;
                      dog.breedCustomName = _breedNameCtrl.text.trim();
                    }

                    _validate();
                  },
                ),
                if (_page >= 1 && dog.userId != '0')
                  Column(
                    children: [
                      0.dl,
                      10.hrr(height: 3),
                      Opacity(
                        opacity: 1,
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 5,
                            left: 5,
                            right: 5,
                          ),
                          child: AppOptionButton(
                            value: dog.inOurHeartsDateAt == null ? 'Off' : 'On',
                            htitle: 'Always in our Hearts',
                            opts: const ['Off', 'On'],
                            activeColor: dog.inOurHeartsDateAt == null
                                ? AppTheme.clText03
                                : AppTheme.clDeepOrange,
                            onValueChanged: (value) {
                              if (value == 'On') {
                                AppRoute.showPopup(
                                  title:
                                      'When your dog passes away, you can keep a cherished memory to honor and remember the bond you shared.',
                                  [
                                    AppPopupAction(
                                      'Always in our Hearts',
                                      color: AppTheme.clRed,
                                      () async {
                                        final now = DateTime.now();
                                        dog.inOurHeartsDateAt = DateTime(
                                          now.year,
                                          now.month,
                                          01,
                                        );
                                        dog.age = fnAge(
                                          dog.birthdate,
                                          death: dog.inOurHeartsDateAt,
                                        );

                                        _validate();
                                      },
                                    ),
                                  ],
                                );
                              } else if (value == 'Off') {
                                dog.inOurHeartsDateAt = null;
                                dog.age = fnAge(dog.birthdate);

                                _validate();
                              }
                            },
                          ),
                        ),
                      ),
                      if (dog.inOurHeartsDateAt != null) ...[
                        15.h,
                        AppFieldButton(
                          title: 'Dog Death Date',
                          placeholder: 'Dog Death Date',
                          text: dog.inOurHeartsDateAt!.toMonthYear(),
                          down: true,
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());

                            List<DateTime> death = [];
                            death.add(dog.inOurHeartsDateAt!);

                            await AppRoute.goSheetTo(
                              '/profile_dog_death',
                              args: {'death': death},
                            );

                            if (death.isNotEmpty) {
                              dog.inOurHeartsDateAt = death.first;
                              dog.age = fnAge(
                                dog.birthdate,
                                death: dog.inOurHeartsDateAt,
                              );
                            }

                            _validate();
                          },
                        ),
                        20.h,
                      ],
                    ],
                  )
              ],
            ),
          ),
        ],
      ],
    );
  }
}
