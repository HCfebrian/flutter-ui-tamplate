import 'package:simple_flutter/feature/auth/domain/contract_repo/user_repo_abs.dart';
import 'package:simple_flutter/feature/auth/domain/entity/user_entity.dart';

class UserUsecase{
 final UserRepoAbs userRepo;

  UserUsecase({required this.userRepo});

 Future<UserEntity> getUserData(){
   return userRepo.getUserData();
 }
}
