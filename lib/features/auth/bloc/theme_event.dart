import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ThemeChanged extends ThemeEvent {
  final Brightness brightness;

  const ThemeChanged(this.brightness);

  @override
  List<Object> get props => [brightness];
}