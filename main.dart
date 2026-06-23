import 'dart:io';
import 'dart:convert';

Map<String, Map<String, String>> users = {};
Map<String, String>? currentUser = null;
List<Map<String, String>> jobs = [];
List<Map<String, String>> applications = [];

// Pre-load the admin account
void setupAdmin() {
  users['admin@jobportal.com'] = {
    'password': 'admin123',
    'name': 'System Admin',
    'role': 'admin',
  };
}


// ---------- Save Data to file ------------
void saveData(){
  // Put all our data into one big Map
  Map<String, dynamic> allData = {
    'users' : users,
    'jobs' : jobs,
    'applications' : applications,
  };

  // Convert to JSON string

  String jsonString = jsonEncode(allData);

  // Write to file
  File('data.json').writeAsStringSync(jsonString);
}

// ------- LOAD DATA FROM FILE ------
void loadData(){
  File file = File('data.json');

  // Check if file exists
  if (!file.existsSync()) {
    print('[INFO] NO saved data found. Starting fresh.');
    return;
  }

  //Read the file
  String jsonString = file.readAsStringSync();

  //Convert JSON string back to Dart objects
  Map<String, dynamic> allData = jsonDecode(jsonString);

  // Restore users
  if (allData['users']!=null) {
    users = Map<String, Map<String, String>>.from(
      (allData['users'] as Map).map(
        (key, value) => MapEntry(
          key.toString(),
          Map<String, String>.from(value as Map),
        ),
      ),
    );
  }

  //Restore jobs
  if (allData['jobs'] != null){
    jobs = List<Map<String, String>>.from(
      (allData['jobs'] as List).map(
        (item) => Map<String, String>.from(item as Map),
      ),
    );
  }

  // Restore applications
  if (allData['applications'] != null){
    applications = List<Map<String, String>>.from(
      (allData['applications'] as List).map(
        (item) => Map<String, String>.from(item as Map),
      ),
    );
  }

  print('Data loaded successfully!');
}


// ---- MAIN FUNCTION ----

void main(){

  setupAdmin();
  loadData();

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
  saveData();
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
    }else if (role == 'admin') {
      print('\n=== ADMIN MENU ===');
      print('1. Dashboard & Analytics');
      print('2. View All Users');
      print('3. View All Jobs');
      print('4. Logout');
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
        } else if (role == 'admin') {
          adminDashboard();
        } else {
          postJob();
        }
        break;
      case'2':
      if (role == 'candidate'){
        myApplications();
      }else if (role == 'admin') {
        viewAllUsers();
      }else {
        viewApplicants();
      }
      break;
          case '3':
        if (role == 'candidate') {
          print('Logged out. Goodbye, ${currentUser!['name']}!');
          currentUser = null;
          inMenu = false;
        } else if (role == 'admin') {
          viewAllJobs();
        } else {
          print('Logged out. Goodbye, ${currentUser!['name']}!');
          currentUser = null;
          inMenu = false;
        }
        break;
      case '4':
        if (role == 'admin') {
          print('Logged out. Goodbye, ${currentUser!['name']}!');
          currentUser = null;
          inMenu = false;
        }
        break;
      default:
        print('Invalid choice.');
    }

  }while (inMenu);
}

// ---------- BROWSE JOBS (Candidate) ----------
void browseJobs() {
  print('\n=== JOB SEARCH & FILTER ===');

  if (jobs.isEmpty) {
    print('No jobs available yet.');
    return;
  }

  // Step 1: Search keyword
  print('Search keyword (or press Enter for all): ');
  String? keyword = stdin.readLineSync();
  if (keyword != null) {
    keyword = keyword.toLowerCase().trim();
  }

  // Step 2: Filter by category
  print('\nFilter by category (or press Enter for all): ');
  
  // Show available categories
  Set<String> categories = {};
  for (var job in jobs) {
    if (job['postedBy'] != currentUser!['email']) {
      categories.add(job['category']!);
    }
  }
  
  print('Available: ${categories.join(', ')}');
  String? categoryFilter = stdin.readLineSync();
  if (categoryFilter != null) {
    categoryFilter = categoryFilter.trim();
    if (categoryFilter.isEmpty) {
      categoryFilter = 'all';
    }
  } else {
    categoryFilter = 'all';
  }

  // Step 3: Filter by location
  print('\nFilter by location (or press Enter for all): ');
  
  // Show available locations
  Set<String> locations = {};
  for (var job in jobs) {
    if (job['postedBy'] != currentUser!['email']) {
      locations.add(job['location']!);
    }
  }
  
  print('Available: ${locations.join(', ')}');
  String? locationFilter = stdin.readLineSync();
  if (locationFilter != null) {
    locationFilter = locationFilter.trim();
    if (locationFilter.isEmpty) {
      locationFilter = 'all';
    }
  } else {
    locationFilter = 'all';
  }

  // Step 4: Filter and display jobs
  print('\n=== SEARCH RESULTS ===');
  
  List<int> matchingIndexes = [];
  int displayNumber = 1;

  for (int i = 0; i < jobs.length; i++) {
    // Skip own jobs
    if (jobs[i]['postedBy'] == currentUser!['email']) {
      continue;
    }

    // Check search keyword
    bool matchesKeyword = keyword == null || keyword.isEmpty ||
        jobs[i]['title']!.toLowerCase().contains(keyword) ||
        jobs[i]['company']!.toLowerCase().contains(keyword) ||
        jobs[i]['category']!.toLowerCase().contains(keyword);

    // Check category filter
    bool matchesCategory = categoryFilter == 'all' ||
        jobs[i]['category']!.toLowerCase() == categoryFilter.toLowerCase();

    // Check location filter
    bool matchesLocation = locationFilter == 'all' ||
        jobs[i]['location']!.toLowerCase() == locationFilter.toLowerCase();

    // Show if all filters match
    if (matchesKeyword && matchesCategory && matchesLocation) {
      matchingIndexes.add(i);
      print('\n$displayNumber. ${jobs[i]['title']}');
      print('   Company: ${jobs[i]['company']}');
      print('   Location: ${jobs[i]['location']}');
      print('   Salary: ${jobs[i]['salary']}');
      print('   Category: ${jobs[i]['category']}');
      displayNumber++;
    }
  }

  if (matchingIndexes.isEmpty) {
    print('No jobs match your search criteria.');
    return;
  }

  print('\nFound $displayNumber job(s)');

  // Ask if candidate wants to apply
  print('\nEnter job number to apply (or 0 to go back): ');
  String? choice = stdin.readLineSync();

  if (choice == null || choice == '0') {
    return;
  }

  int? selectedIndex = int.tryParse(choice);
  if (selectedIndex == null || selectedIndex < 1 || selectedIndex > matchingIndexes.length) {
    print('Invalid choice!');
    return;
  }

  // Get the actual job
  int actualIndex = matchingIndexes[selectedIndex - 1];
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
  saveData();
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
  saveData();
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
  saveData();
}

// ---------- ADMIN DASHBOARD ----------
void adminDashboard() {
  print('\n========== ADMIN DASHBOARD ==========');

  // Total counts
  int totalUsers = users.length;
  int totalJobs = jobs.length;
  int totalApplications = applications.length;

  print('👥 Total Users:        $totalUsers');
  print('💼 Total Jobs:         $totalJobs');
  print('📝 Total Applications: $totalApplications');

  // Count by role
  int candidateCount = 0;
  int employerCount = 0;

  for (var user in users.values) {
    if (user['role'] == 'candidate') {
      candidateCount++;
    } else if (user['role'] == 'employer') {
      employerCount++;
    }
  }

  print('\n📊 Users by Role:');
  print('   Candidates: $candidateCount');
  print('   Employers:  $employerCount');
  print('   Admins:     1');

  // Most popular job category
  if (jobs.isNotEmpty) {
    Map<String, int> categoryCount = {};

    for (var job in jobs) {
      String category = job['category']!;
      if (categoryCount.containsKey(category)) {
        categoryCount[category] = categoryCount[category]! + 1;
      } else {
        categoryCount[category] = 1;
      }
    }

    // Find the category with the highest count
    String topCategory = '';
    int highestCount = 0;

    categoryCount.forEach((category, count) {
      if (count > highestCount) {
        highestCount = count;
        topCategory = category;
      }
    });

    print('\n🔥 Most Popular Category: $topCategory ($highestCount jobs)');
  }

  // Application status summary
  if (applications.isNotEmpty) {
    Map<String, int> statusCount = {};

    for (var app in applications) {
      String status = app['status']!;
      if (statusCount.containsKey(status)) {
        statusCount[status] = statusCount[status]! + 1;
      } else {
        statusCount[status] = 1;
      }
    }

    print('\n📋 Application Status Summary:');
    statusCount.forEach((status, count) {
      print('   $status: $count');
    });
  }

  print('=====================================');
}


// ---------- VIEW ALL USERS (Admin) ----------
void viewAllUsers() {
  print('\n=== ALL REGISTERED USERS ===');

  int count = 1;
  users.forEach((email, data) {
    print('\n$count. ${data['name']}');
    print('   Email: $email');
    print('   Role: ${data['role']}');
    count++;
  });

  print('\nTotal: ${users.length} users');
}


// ---------- VIEW ALL JOBS (Admin) ----------
void viewAllJobs() {
  print('\n=== ALL JOBS ON PLATFORM ===');

  if (jobs.isEmpty) {
    print('No jobs posted yet.');
    return;
  }

  for (int i = 0; i < jobs.length; i++) {
    print('\n${i + 1}. ${jobs[i]['title']}');
    print('   Company: ${jobs[i]['company']}');
    print('   Location: ${jobs[i]['location']}');
    print('   Category: ${jobs[i]['category']}');
    print('   Posted by: ${jobs[i]['postedBy']}');
  }

  print('\nTotal: ${jobs.length} jobs');
}


