import 'dart:io';

Map<String, Map<String, String>> users = {};
Map<String, String>? currentUser = null;
List<Map<String, String>> jobs = [];
List<Map<String, String>> applications = [];

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


// ------- Show User Menu------------

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
        myApplications();
      } else {
        viewApplicants();
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

// ---------- BROWSE JOBS (Candidate) ----------
void browseJobs() {
  print('\n=== AVAILABLE JOBS ===');

  if (jobs.isEmpty) {
    print('No jobs available yet.');
    return;
  }

  // Show only jobs NOT posted by current user
  List<int> availableIndexes = [];
  int displayNumber = 1;

  for (int i = 0; i < jobs.length; i++) {
    if (jobs[i]['postedBy'] != currentUser!['email']) {
      availableIndexes.add(i);
      print('\n$displayNumber. ${jobs[i]['title']}');
      print('   Company: ${jobs[i]['company']}');
      print('   Location: ${jobs[i]['location']}');
      print('   Salary: ${jobs[i]['salary']}');
      print('   Category: ${jobs[i]['category']}');
      displayNumber++;
    }
  }

  if (availableIndexes.isEmpty) {
    print('\nAll jobs are posted by you!');
    return;
  }

  // Ask if candidate wants to apply
  print('\nEnter job number to apply (or 0 to go back): ');
  String? choice = stdin.readLineSync();

  if (choice == null || choice == '0') {
    return;
  }

  int? selectedIndex = int.tryParse(choice);
  if (selectedIndex == null || selectedIndex < 1 || selectedIndex > availableIndexes.length) {
    print('Invalid choice!');
    return;
  }

  // Get the actual job
  int actualIndex = availableIndexes[selectedIndex - 1];
  Map<String, String> selectedJob = jobs[actualIndex];

  // Check if already applied
  for (var app in applications) {
    if (app['applicantEmail'] == currentUser!['email'] &&
        app['jobTitle'] == selectedJob['title'] &&
        app['jobCompany'] == selectedJob['company']) {
      print('You have already applied for this job!');
      return;
    }
  }

  // Apply
  applications.add({
    'applicantEmail': currentUser!['email']!,
    'applicantName': currentUser!['name']!,
    'jobTitle': selectedJob['title']!,
    'jobCompany': selectedJob['company']!,
    'status': 'Applied',
    'employerEmail': selectedJob['postedBy']!,
  });

  print('✅ Applied successfully for ${selectedJob['title']}!');
}

// ---------- MY APPLICATIONS (Candidate) ----------
void myApplications() {
  print('\n=== MY APPLICATIONS ===');

  bool found = false;

  for (int i = 0; i < applications.length; i++) {
    if (applications[i]['applicantEmail'] == currentUser!['email']) {
      found = true;
      print('\n${i + 1}. ${applications[i]['jobTitle']}');
      print('   Company: ${applications[i]['jobCompany']}');
      print('   Status: ${applications[i]['status']}');
    }
  }

  if (!found) {
    print('No applications yet.');
  }
}

// ---------- VIEW APPLICANTS (Employer) ----------
void viewApplicants() {
  print('\n=== APPLICANTS FOR YOUR JOBS ===');

  bool found = false;

  for (int i = 0; i < applications.length; i++) {
    if (applications[i]['employerEmail'] == currentUser!['email']) {
      found = true;
      print('\n${i + 1}. ${applications[i]['applicantName']}');
      print('   Applied for: ${applications[i]['jobTitle']}');
      print('   Status: ${applications[i]['status']}');
    }
  }

  if (!found) {
    print('No applicants yet.');
    return;
  }

  // Option to change status
  print('\nEnter application number to change status (or 0 to go back): ');
  String? choice = stdin.readLineSync();

  if (choice == null || choice == '0') {
    return;
  }

  int? appIndex = int.tryParse(choice);
  if (appIndex == null || appIndex < 1 || appIndex > applications.length) {
    print('Invalid choice!');
    return;
  }

  int actualIndex = appIndex - 1;

  // Check if this application belongs to this employer
  if (applications[actualIndex]['employerEmail'] != currentUser!['email']) {
    print('Invalid choice!');
    return;
  }

  print('\n--- Change Status ---');
  print('1. Under Review');
  print('2. Shortlisted');
  print('3. Rejected');
  print('4. Hired');
  print('Choose new status: ');

  String? statusChoice = stdin.readLineSync();

  switch (statusChoice) {
    case '1':
      applications[actualIndex]['status'] = 'Under Review';
      break;
    case '2':
      applications[actualIndex]['status'] = 'Shortlisted';
      break;
    case '3':
      applications[actualIndex]['status'] = 'Rejected';
      break;
    case '4':
      applications[actualIndex]['status'] = 'Hired';
      break;
    default:
      print('Invalid status!');
      return;
  }

  print('✅ Status updated to: ${applications[actualIndex]['status']}');
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