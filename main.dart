import 'dart:io';

Map<String, Map<String, String>> users = {};
Map<String, String>? currentUser = null;
List<Map<String, String>> jobs = [];

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
      bool success = login();
      if (success){
        showUserMenu(); // Go to role-based menu

      }
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

  if (role != 'candidate' && role != 'employer'){
    print('Role must be "candidate" or "employer"!');
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

bool login(){
  print('\n--- Login ---');


  print('Email: ');
  String? email = stdin.readLineSync();

  if(email == null || email.isEmpty){
    print('Email cannot be empty!');

    return false;
  }


  if (!users.containsKey(email)){
    print('Email not found! Please register first.');

    return false;
  }


  print('Password: ');
  String? password = stdin.readLineSync();

  if (password == null || password.isEmpty){
    print('Password cannot be empty!');

    return false;
  }



  if (users[email]!['password'] == password){
    // ✅ SET THE CURRENT USER HERE!
    currentUser = {
      'email': email,
      'name': users[email]!['name']!,
      'role': users[email]!['role']!,


    };

    print('✅ Welcome back, ${currentUser!['name']}!');
    print('  Role: ${currentUser!['role']}');


    return true;
  }else {
    print('❌ Incorrect password!');

    return false;
  }
}

void showUserMenu(){
  bool inMenu = true;

  do{
    String role = currentUser!['role']!;

    if(role == 'candidate'){
      print('\n=== CANDIDATE MANU ===');
      print('1. Browse Jobs');
      print('2. My Applications');
      print('3. Logout');
    }else if (role == 'employer'){
      print('\n=== EMPLOYER MENU ===');
      print('1. Post a Job');
      print('2. View Applications');
      print('3. Logout');
    }

    print('Choose an option: ');
    String? input = stdin.readLineSync();

    switch (input){
      case '1':
        if (role == 'candidate'){
          browseJobs();
        } else {
          postJob();
        }
        break;
      case'2':
      if (role == 'candidate'){
        print('My Applications - Coming soon!');
      } else {
        print('View Applicants - Coming soon!');
      }
      break;
    case '3':
      print('Logged out. Goodbye, ${currentUser!['name']}');
      currentUser = null;
      inMenu = false;
      break;
    default:
      print('Invalid choice.');
    }

  }while (inMenu);
}

void browseJobs(){
  print('\n=== AVAILABLE JOBS ===');

  if (jobs.isEmpty){
    print('No jobs available.');
    return;
  }

  for (int i = 0; i < jobs.length; i++) {
    print('\n${i + 1}. ${jobs[i]['title']}');
    print('  Company: ${jobs[i]['company']}');
    print('  Location: ${jobs[i]['location']}');
    print('  Salary: ${jobs[i]['salary']}');
    print('  Category: ${jobs[i]['category']}');
    print('  Posted by: ${jobs[i]['postedBy']}');
  }
}

//----------- Post A job (Employer) ----------

void postJob() {
  print('\n--- Post a New Job ---');

  print('Job Title: ');
  String? title = stdin.readLineSync();
  if (title == null || title.isEmpty) {
    print('Title cannot be empty!');
    return;
  }

  print('Company: ');
  String? company = stdin.readLineSync();
  if (company == null || company.isEmpty) {
    print('Company cannot be empty!');
    return;
  }

  print('Location: ');
  String? location = stdin.readLineSync();
  if (location == null || location.isEmpty) {
    print('Location cannot be empty!');
    return;
  }

  print('Salary: ');
  String? salary = stdin.readLineSync();
  if (salary == null || salary.isEmpty) {
    print('Salary cannot be empty!');
    return;
  }

  print('Category: ');
  String? category = stdin.readLineSync();
  if (category == null || category.isEmpty) {
    print('Category cannot be empty!');
    return;
  }

  // Add job to the list
  jobs.add({
    'title': title,
    'company': company,
    'location': location,
    'salary': salary,
    'category': category,
    'postedBy': currentUser!['email']!,
  });

  print('✅ Job posted successfully!');
}