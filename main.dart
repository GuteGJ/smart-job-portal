import 'dart:io';

Map<String, Map<String, String>> users = {};

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
      register();
      break;
    case '2':
      login();
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

//........Register Function...........

void register(){
  print('\n--- Register ---');

  //step 1: Get email
  print('Email: ');
  String? email = stdin.readLineSync();

  //Check if email is empty
  if (email == null || email.isEmpty){
    print('Email cannot be empty');
    return;
  }

  //Step 2: Check if email already exists
  if (users.containsKey(email)){
    print('Email already Registered!');
    return;
  }

  //Step 3: Get password
  print('Password: ');
  String? password = stdin.readLineSync();

  if (password == null || password.isEmpty){
    print('Password cannot be empty!');
    return;
  }

  //Step 4: Get name
  print('Name: ');
  String? name = stdin.readLineSync();

  if (name == null || name.isEmpty){
    print('Name cannot be empty!');
    return;
  }

  //Step 5: Get role
  print('Role (candidate/employer):');
  String? role = stdin.readLineSync();

  if (role == null || role.isEmpty){
    print('Role cannot be empty');
    return;
  }

  //Step 6: Add user to the map
  users[email] = {
    'password': password,
    'name': name,
    'role': role,
  };
  print('✅ Registration successful!');
}

//----------Login Function--------
void login(){
  print('\n--- Login ---');

  //Step 1: Get email
  String? email = stdin.readLineSync();

  if(email == null || email.isEmpty){
    print('Email cannot be empty!');
    return;
  }

  //Step 2: check if email exists
  if (!users.containsKey(email)){
    print('Email not found! Please register first.');
    return;
  }

  //Step 3: Get password
  print('Password: ');
  String? password = stdin.readLineSync();

  if (password == null || password.isEmpty){
    print('Password cannot be empty!');
    return;
  }

  //Step 4: Check if password matches
  if (users[email]!['password'] == password){
    String name = users[email]!['name']!;
    String role = users[email]!['role']!;

    print('✅ Welcome back, $name!');
    print('  Role: $role');
  }else {
    print('❌ Incorrect password!');
  }
}