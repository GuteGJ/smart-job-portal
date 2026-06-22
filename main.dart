import 'dart:io';

void main(){

  bool isRunning = true;
  while (isRunning){
    print ('=== SMART JOB PORTAL');
    print ('1, Register');
    print ('2, Login');
    print ('3, Exit');
    print ('Choose an option: ');
  
  String? input = stdin.readLineSync();

  switch (input){
    case '1':
      print('Register chosen');
      break;
    case '2':
      print('Login chosen');
      break;
    case '3':
      print('Goddbye!');
      isRunning =false;
      break;
    default:
      print('Invalid choice. Please try again');
  }

  }

}