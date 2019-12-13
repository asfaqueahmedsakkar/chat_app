import 'package:caht_app/bloc/base_bloc.dart';
import 'package:caht_app/model/user.dart';

class AppBloc extends BaseBloc {
  User user;

  @override
  void dispose() {}

  void uploadUser({User user}) {
    this.user = user;
  }
}
