enum UserStates { Offline, Online, Waiting }

class StateUtil {
  static int stateToNum(UserStates userStae) {
    switch (userStae) {
      case UserStates.Offline:
        return 0;
      case UserStates.Online:
        return 1;
      default:
        return 2;
    }
  }

  static UserStates numToState(int number) {
    switch (number) {
      case 0:
        return UserStates.Offline;
      case 1:
        return UserStates.Online;
      default:
        return UserStates.Waiting;
    }
  }
}
