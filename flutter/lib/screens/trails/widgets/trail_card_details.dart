// License: This file is part of TrailCatch.
// Copyright (c) 2024 Ihar Petushkou.
//
// This source code is for personal or educational use only.
// Commercial use, redistribution, or modification is prohibited
// without explicit permission. See LICENSE for details.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trailcatch/extensions.dart';
import 'package:trailcatch/getit.dart';
import 'package:trailcatch/models/device_model.dart';
import 'package:trailcatch/models/trail_model.dart';
import 'package:trailcatch/route.dart';
import 'package:trailcatch/screens/trails/widgets/trail_card_graph.dart';
import 'package:trailcatch/theme.dart';
import 'package:trailcatch/utils/core_utils.dart';
import 'package:trailcatch/viewmodels/trail_viewmodel.dart';
import 'package:trailcatch/widgets/buttons/field_button.dart';
import 'package:trailcatch/widgets/buttons/option_button.dart';
import 'package:url_launcher/url_launcher.dart';

class TrailCardDetails extends StatefulWidget {
  const TrailCardDetails({
    super.key,
    required this.trailExt,
    required this.isEditMode,
    required this.onChanged,
  });

  final TrailExtModel trailExt;
  final bool isEditMode;
  final VoidCallback onChanged;

  @override
  State<TrailCardDetails> createState() => _TrailCardDetailsState();
}

class _TrailCardDetailsState extends State<TrailCardDetails> {
  late bool _isEditMode;

  late String _deviceModel;

  late int _msrunit;

  late TrailDeviceData _deviceData;

  late List<LatLng> _deviceGeopoints0;
  late List<LatLng> _deviceGeopoints;

  late Map<String, TrailGraphData> _trailCardGraphsData;

  late Map<String, bool> _withTrailCardGraphsData;

  @override
  void initState() {
    _isEditMode = widget.isEditMode;

    _deviceData = widget.trailExt.trail.deviceData ?? TrailDeviceData.empty();
    _deviceGeopoints0 = List<LatLng>.from(
      widget.trailExt.trail.deviceGeopoints ?? [],
    );
    if (_deviceGeopoints0.length > 3) {
      _deviceGeopoints0.length = 3;
    }

    _deviceGeopoints = List<LatLng>.from(_deviceGeopoints0);

    _msrunit = _deviceData.msrunit;

    _deviceModel = widget.trailExt.trail.deviceData?.deviceModel ?? '';
    _deviceModel = _deviceModel.trim();

    _withTrailCardGraphsData = Map<String, bool>.from({
      if (widget.trailExt.isBike) ...{
        TrailGraphData.kSpeeds: true,
      },
      if (!widget.trailExt.isBike) ...{
        TrailGraphData.kPaces: _deviceData.isPacesOn,
        TrailGraphData.kSpeeds: _deviceData.isSpeedsOn,
      },
      //
      TrailGraphData.kPowers: _deviceData.isPowerOn,
      TrailGraphData.kHeartRates: _deviceData.isHeartRateOn,
      TrailGraphData.kCadences: _deviceData.isCadenceOn,
      TrailGraphData.kRespRates: _deviceData.isRespRateOn,
      TrailGraphData.kAltitudes: _deviceData.isAltitude,
      if (widget.trailExt.trail.deviceId == DeviceId.garmin)
        TrailGraphData.kTrainingEff: _deviceData.isTEOn,
      if (widget.trailExt.trail.deviceId == DeviceId.suunto)
        TrailGraphData.kPeakTrainingEff: _deviceData.isPTEOn,
      TrailGraphData.kCalories: true,
    });

    _buildGraphsData();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    context.watch<TrailViewModel>();

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant TrailCardDetails oldWidget) {
    _isEditMode = widget.isEditMode;

    super.didUpdateWidget(oldWidget);
  }

  void _buildGraphsData() {
    _trailCardGraphsData = TrailGraphData.buildGraphsData(
      deviceData: _deviceData,
      msrunit: _msrunit,
    );
  }

  void _onOffDetailsData(String key, String? value) {
    setState(() {
      bool val = false;

      if (value == 'On') {
        val = true;
      } else if (value == 'Off') {
        val = false;
      }

      _withTrailCardGraphsData[key] = val;

      if (key == TrailGraphData.kPaces) {
        _deviceData.pacesOn = val ? 1 : 0;
      } else if (key == TrailGraphData.kSpeeds) {
        _deviceData.speedsOn = val ? 1 : 0;
      } else if (key == TrailGraphData.kHeartRates) {
        _deviceData.heartRatesOn = val ? 1 : 0;
      } else if (key == TrailGraphData.kCadences) {
        _deviceData.cadencesOn = val ? 1 : 0;
      } else if (key == TrailGraphData.kPowers) {
        _deviceData.powersOn = val ? 1 : 0;
      } else if (key == TrailGraphData.kRespRates) {
        _deviceData.respRatesOn = val ? 1 : 0;
      } else if (key == TrailGraphData.kTrainingEff) {
        _deviceData.teOn = val ? 1 : 0;
      } else if (key == TrailGraphData.kPeakTrainingEff) {
        _deviceData.pteOn = val ? 1 : 0;
      }

      widget.onChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    String dogNamesStr = widget.trailExt.dogsNames.join(', ');
    if (dogNamesStr.isEmpty) dogNamesStr = 'Without dogs';

    String deviceStr = DeviceId.formatToStr(widget.trailExt.trail.deviceId);
    if (_deviceData.deviceModelOn == 2) {
      deviceStr = '$deviceStr $_deviceModel';
    }

    return Column(
      children: [
        0.hrr(height: 3),
        if (_isEditMode || (!_isEditMode)) ...[
          10.h,
          Opacity(
            opacity: _deviceData.deviceModelOn == 0 ? 0.3 : 1.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Device:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.clText08,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.appLR,
                  ),
                  child: Text(
                    deviceStr,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_isEditMode) 0.dl,
        if (!_isEditMode) 0.dl,
        if (_isEditMode) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
            child: SizedBox(
              height: 30,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppOptionButton(
                  value: _deviceData.deviceModelOn == 0
                      ? 'Off'
                      : (_deviceData.deviceModelOn == 1 ? 'Short' : 'Long'),
                  opts: _deviceModel.isEmpty
                      ? const ['Off', 'Short']
                      : const ['Off', 'Short', 'Long'],
                  onValueChanged: (value) async {
                    if (value == 'Short') {
                      setState(() {
                        _deviceData.deviceModelOn = 1;
                      });
                    } else if (value == 'Long' && _deviceModel.isNotEmpty) {
                      setState(() {
                        _deviceData.deviceModelOn = 2;
                      });
                    } else if (value == 'Off') {
                      setState(() {
                        _deviceData.deviceModelOn = 0;
                      });
                    }

                    widget.onChanged();
                  },
                ),
              ),
            ),
          ),
          0.dl,
        ],
        if (_isEditMode) ...[
          0.hrr(height: 2),
          0.dl,
          Builder(builder: (context) {
            String type0 = 'Unknown';
            String? type = TrailType.formatToStr(widget.trailExt.trail.type);
            if (type != null) {
              type0 = type;

              if (widget.trailExt.withDogs) {
                type0 = '$type & Dogs';
              }
            }

            return Container(
              width: context.width,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
              child: AppFieldButton(
                title: 'Trail Type',
                text: type0,
                down: true,
                onTap: () async {
                  AppRoute.showPopup(
                    [
                      AppPopupAction(
                        'Walk ${widget.trailExt.withDogs ? '& Dogs' : ''}',
                        color: widget.trailExt.trail.type == TrailType.walk
                            ? AppTheme.clYellow
                            : AppTheme.clText,
                        () async {
                          widget.trailExt.trail.type = TrailType.walk;
                          widget.onChanged();

                          setState(() {});
                          trailVM.notify();
                        },
                      ),
                      AppPopupAction(
                        'Run ${widget.trailExt.withDogs ? '& Dogs' : ''}',
                        color: widget.trailExt.trail.type == TrailType.run
                            ? AppTheme.clYellow
                            : AppTheme.clText,
                        () async {
                          widget.trailExt.trail.type = TrailType.run;
                          widget.onChanged();

                          setState(() {});
                          trailVM.notify();
                        },
                      ),
                      AppPopupAction(
                        'Bike ${widget.trailExt.withDogs ? '& Dogs' : ''}',
                        color: widget.trailExt.trail.type == TrailType.bike
                            ? AppTheme.clYellow
                            : AppTheme.clText,
                        () async {
                          widget.trailExt.trail.type = TrailType.bike;
                          widget.onChanged();

                          setState(() {});
                          trailVM.notify();
                        },
                      ),
                    ],
                  );
                },
              ),
            );
          }),
          0.dl,
          0.hrr(height: 2),
          0.dl,
          if (appVM.user.withDogs) ...[
            Container(
              width: context.width,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
              child: AppFieldButton(
                title: 'Dogs',
                text: dogNamesStr,
                down: true,
                onTap: () async {
                  final isChanged =
                      await AppRoute.goSheetTo('/trail_with_dogs', args: {
                    'trailExt': widget.trailExt,
                  });

                  trailVM.notify();

                  if (isChanged ?? false) {
                    widget.onChanged();
                  }
                },
              ),
            ),
            0.dl,
            0.hrr(height: 2),
            0.dl,
          ],
          Builder(builder: (context) {
            String geoLocStr0 = 'No GeoPoints';
            if (_deviceGeopoints0.length == 1) {
              geoLocStr0 = 'One GeoPoint';
            } else if (_deviceGeopoints0.length == 3) {
              geoLocStr0 = 'Three GeoPoints';
            }

            String geoLocStr = 'No GeoPoints';
            if (_deviceGeopoints.length == 1) {
              geoLocStr = 'One GeoPoint';
            } else if (_deviceGeopoints0.length == 3) {
              geoLocStr = 'Three GeoPoints';
            }

            return Opacity(
              opacity: _deviceGeopoints0.isEmpty ? 0.3 : 1.0,
              child: Container(
                width: context.width,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.appLR),
                child: AppFieldButton(
                  title: 'GeoLocation',
                  text: _deviceGeopoints.isEmpty ? 'No GeoPoints' : geoLocStr,
                  down: true,
                  onTap: () async {
                    if (_deviceGeopoints0.isEmpty) return;

                    AppRoute.showPopup(
                      [
                        if (_deviceGeopoints.isNotEmpty) ...[
                          AppPopupAction(
                            _deviceGeopoints.length == 1
                                ? 'One GeoPoint'
                                : 'First GeoPoint',
                            () async {
                              launchUrl(Uri.parse(
                                'https://www.google.com/maps/place/${_deviceGeopoints[0].toString()}',
                              ));
                            },
                          ),
                          if (_deviceGeopoints.length > 1)
                            AppPopupAction(
                              'Center GeoPoint',
                              () async {
                                launchUrl(Uri.parse(
                                  'https://www.google.com/maps/place/${_deviceGeopoints[1].toString()}',
                                ));
                              },
                            ),
                          if (_deviceGeopoints.length > 1)
                            AppPopupAction(
                              'Last GeoPoint',
                              () async {
                                launchUrl(Uri.parse(
                                  'https://www.google.com/maps/place/${_deviceGeopoints[2].toString()}',
                                ));
                              },
                            ),
                        ],
                      ],
                      bottoms: [
                        if (_deviceGeopoints.isNotEmpty) ...[
                          if (_deviceGeopoints.length > 1)
                            AppPopupAction(
                              'Set Only One GeoPoint',
                              color: AppTheme.clYellow,
                              () async {
                                AppRoute.showPopup(
                                  [],
                                  bottoms: [
                                    AppPopupAction(
                                      'Set First GeoPoint',
                                      color: AppTheme.clYellow,
                                      () async {
                                        setState(() {
                                          _deviceGeopoints = [
                                            _deviceGeopoints[0]
                                          ];
                                        });

                                        widget.trailExt.trail.deviceGeopoints =
                                            _deviceGeopoints;
                                        widget.onChanged();
                                      },
                                    ),
                                    AppPopupAction(
                                      'Set Center GeoPoint',
                                      color: AppTheme.clYellow,
                                      () async {
                                        setState(() {
                                          _deviceGeopoints = [
                                            _deviceGeopoints[1]
                                          ];
                                        });

                                        widget.trailExt.trail.deviceGeopoints =
                                            _deviceGeopoints;
                                        widget.onChanged();
                                      },
                                    ),
                                    AppPopupAction(
                                      'Set Last GeoPoint',
                                      color: AppTheme.clYellow,
                                      () async {
                                        setState(() {
                                          _deviceGeopoints = [
                                            _deviceGeopoints[2]
                                          ];
                                        });

                                        widget.trailExt.trail.deviceGeopoints =
                                            _deviceGeopoints;
                                        widget.onChanged();
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          AppPopupAction(
                            'Delete GeoPoint${_deviceGeopoints.length == 1 ? '' : 's'}',
                            color: AppTheme.clRed,
                            () async {
                              final String title =
                                  'Are you sure you want to delete this geolocation point${_deviceGeopoints.length == 1 ? '' : 's'}?';

                              AppRoute.showPopup(
                                title: title,
                                [
                                  AppPopupAction(
                                    'Yes, I\'m Sure.',
                                    color: AppTheme.clRed,
                                    () async {
                                      setState(() {
                                        _deviceGeopoints = [];
                                      });

                                      widget.trailExt.trail.deviceGeopoints =
                                          null;
                                      widget.onChanged();
                                    },
                                  ),
                                ],
                              );
                            },
                          )
                        ] else
                          AppPopupAction(
                            'Set $geoLocStr0',
                            color: AppTheme.clYellow,
                            () async {
                              setState(() {
                                _deviceGeopoints = _deviceGeopoints0;
                              });

                              widget.trailExt.trail.deviceGeopoints =
                                  _deviceGeopoints0;
                              widget.onChanged();
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
            );
          }),
          0.dl,
          0.hrr(height: 2),
          0.dl,
        ],
        if (!_isEditMode) 0.dl,
        for (var key in _withTrailCardGraphsData.keys)
          if (_trailCardGraphsData.containsKey(key) &&
              (_isEditMode ||
                  (!_isEditMode && _withTrailCardGraphsData[key] == true))) ...[
            Opacity(
              opacity: _withTrailCardGraphsData[key] == true ? 1.0 : 0.4,
              child: TrailCardGraph(
                trailGraphData: _trailCardGraphsData[key]!,
                active: _withTrailCardGraphsData[key] == true,
                onChangeMsrunit: (value) {
                  setState(() {
                    _msrunit = value;
                    _buildGraphsData();
                  });
                },
                onRebuild: () {
                  setState(() {
                    _buildGraphsData();
                  });
                },
              ),
            ),
            if (_isEditMode) ...[
              Builder(builder: (context) {
                Widget wOn(bool noData) {
                  return Container(
                    width: context.width * AppTheme.appBtnWidth,
                    decoration: const BoxDecoration(
                      color: AppTheme.clBlack,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    margin: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: Text(
                        noData ? 'No Data' : 'Always On',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.clText07,
                        ),
                      ),
                    ),
                  );
                }

                if (widget.trailExt.trail.type == TrailType.bike &&
                    key == TrailGraphData.kSpeeds) {
                  return wOn(false);
                }

                if (widget.trailExt.trail.type != TrailType.bike &&
                    key == TrailGraphData.kPaces) {
                  return wOn(false);
                }

                if (key == TrailGraphData.kHeartRates &&
                    !_deviceData.isHeartRate) {
                  return wOn(true);
                } else if (key == TrailGraphData.kAltitudes &&
                    !_deviceData.isAltitude) {
                  return wOn(true);
                } else if (key == TrailGraphData.kCadences &&
                    !_deviceData.isCadence) {
                  return wOn(true);
                } else if (key == TrailGraphData.kPowers &&
                    !_deviceData.isPower) {
                  return wOn(true);
                } else if (key == TrailGraphData.kRespRates &&
                    !_deviceData.isRespRate) {
                  return wOn(true);
                } else if (key == TrailGraphData.kTrainingEff &&
                    !_deviceData.isTE) {
                  return wOn(true);
                } else if (key == TrailGraphData.kPeakTrainingEff &&
                    !_deviceData.isPTE) {
                  return wOn(true);
                }

                if ([
                  TrailGraphData.kAltitudes,
                  TrailGraphData.kCalories,
                ].contains(key)) {
                  return wOn(false);
                }

                return Column(
                  children: [
                    0.dl,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.appLR),
                      child: SizedBox(
                        height: 30,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AppOptionButton(
                            value: _withTrailCardGraphsData[key] == true
                                ? 'On'
                                : 'Off',
                            opts: const ['Off', 'On'],
                            onValueChanged: (String? value) {
                              return _onOffDetailsData(key, value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
            if (_withTrailCardGraphsData.keys.last != key) 15.hrr(height: 2),
          ],
      ],
    );
  }
}
