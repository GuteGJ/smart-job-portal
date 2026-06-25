import 'dart:io';
import 'dart:convert';


Map<String, Map<String, String>> users = {};
Map<String, String>? currentUser = null;
List<Job> jobs = [];
List<Application> applications = [];
List<Map<String, String>> bookmarks = [];
List<String> jobCategories = [];
Map<String, Map<String, String>> companyProfiles = {};
List<AppNotification> notifications = [];






// ============================================
// CLASS: AppNotification
// ============================================

class AppNotification {
  String recipientEmail;
  String message;
  String type;
  DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.recipientEmail,
    required this.message,
    required this.type,
  })  : createdAt = DateTime.now(),
        isRead = false;

  Map<String, dynamic> toMap() {
    return {
      'recipientEmail': recipientEmail,
      'message': message,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead.toString(),
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      recipientEmail: map['recipientEmail']!,
      message: map['message']!,
      type: map['type']!,
    )
      ..createdAt = DateTime.parse(map['createdAt']!)
      ..isRead = map['isRead'] == 'true';
  }

  String get icon {
    switch (type) {
      case 'application': return '📝';
      case 'status': return '📊';
      case 'deadline': return '⏰';
      case 'system': return '🔔';
      default: return '📌';
    }
  }

  String get timeAgo {
    Duration diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}





// ============================================
// CLASS: Job
// ============================================
class Job {
  String title;
  String company;
  String location;
  String salary;
  String category;
  String postedBy;
  String deadline;
  String status;

  Job({
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.category,
    required this.postedBy,
    this.deadline = 'No deadline',
    this.status = 'Open',
  });

  Map<String, String> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'salary': salary,
      'category': category,
      'postedBy': postedBy,
      'deadline': deadline,
      'status': status,
    };
  }

  factory Job.fromMap(Map<String, String> map) {
    return Job(
      title: map['title']!,
      company: map['company']!,
      location: map['location']!,
      salary: map['salary']!,
      category: map['category']!,
      postedBy: map['postedBy']!,
      deadline: map['deadline'] ?? 'No deadline',
      status: map['status'] ?? 'Open',
    );
  }

  // Helper getters
  bool get isOpen => status == 'Open';
  bool get isClosed => status == 'Closed';
  
  bool get hasDeadline => deadline != 'No deadline';
  
  DateTime? get deadlineDate {
    if (!hasDeadline) return null;
    return DateTime.parse(deadline);
  }
  
  bool get isExpired {
    if (!hasDeadline) return false;
    return deadlineDate!.isBefore(DateTime.now());
  }

  @override
  String toString() => 'Job($title at $company)';
}





// ============================================
// CLASS: Application
// ============================================
class Application {
  String applicantEmail;
  String applicantName;
  String jobTitle;
  String jobCompany;
  String status;
  String employerEmail;
  DateTime appliedAt;

  Application({
    required this.applicantEmail,
    required this.applicantName,
    required this.jobTitle,
    required this.jobCompany,
    this.status = 'Applied',
    required this.employerEmail,
  }) : appliedAt = DateTime.now();

  // For loading from file (preserves original date)
  Application.withDate({
    required this.applicantEmail,
    required this.applicantName,
    required this.jobTitle,
    required this.jobCompany,
    required this.status,
    required this.employerEmail,
    required this.appliedAt,
  });

  Map<String, String> toMap() {
    return {
      'applicantEmail': applicantEmail,
      'applicantName': applicantName,
      'jobTitle': jobTitle,
      'jobCompany': jobCompany,
      'status': status,
      'employerEmail': employerEmail,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }

  factory Application.fromMap(Map<String, String> map) {
    return Application.withDate(
      applicantEmail: map['applicantEmail']!,
      applicantName: map['applicantName']!,
      jobTitle: map['jobTitle']!,
      jobCompany: map['jobCompany']!,
      status: map['status']!,
      employerEmail: map['employerEmail']!,
      appliedAt: DateTime.parse(map['appliedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Getters
  bool get canWithdraw => status == 'Applied' || status == 'Under Review';
  bool get isActive => status != 'Withdrawn' && status != 'Rejected';

  String get statusIcon {
    switch (status) {
      case 'Applied': return '📝';
      case 'Under Review': return '🔍';
      case 'Shortlisted': return '⭐';
      case 'Rejected': return '❌';
      case 'Hired': return '🎉';
      case 'Withdrawn': return '↩️';
      default: return '📌';
    }
  }

  @override
  String toString() => 'Application($applicantName -> $jobTitle: $status)';
}







// Pre-load the admin account
void setupAdmin() {
  if (!users.containsKey('admin@jobportal.com')){
    users['admin@jobportal.com'] = {
      'password': 'admin123',
      'name': 'System Admin',
      'role': 'admin',
      'securityQuestion': 'What is the admin password?',
      'securityAnswer': 'admin123',
    };

  }
}




// ---------- Save Data to file ------------
void saveData(){
  // Put all our data into one big Map
  Map<String, dynamic> allData = {
    'users' : users,
    'jobs' : jobs.map((j) => j.toMap()).toList(),
    'applications': applications.map((a) => a.toMap()).toList(),
    'bookmarks': bookmarks,
    'jobCategories': jobCategories,
    'companyProfiles': companyProfiles,
    'notifications': notifications.map((n) => n.toMap()).toList(),
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
    jobs = List<Job>.from(
      (allData['jobs'] as List).map(
        (item) => Job.fromMap(Map<String, String>.from(item as Map)),
      ),
    );
  }

  // Restore applications
    if (allData['applications'] != null) {
    applications = List<Application>.from(
      (allData['applications'] as List).map(
        (item) => Application.fromMap(Map<String, String>.from(item as Map)),
      ),
    );
  }

  // Restore bookmarks
  if (allData['bookmarks'] != null) {
    bookmarks = List<Map<String, String>>.from(
      (allData['bookmarks'] as List).map(
        (item) => Map<String, String>.from(item as Map),
      ),
    );
  }

    // Restore categories
  if (allData['jobCategories'] != null) {
    jobCategories = List<String>.from(allData['jobCategories'] as List);
  }

  // Restore company profiles
  if (allData['companyProfiles'] != null) {
    companyProfiles = Map<String, Map<String, String>>.from(
      (allData['companyProfiles'] as Map).map(
        (key, value) => MapEntry(
          key.toString(),
          Map<String, String>.from(value as Map),
        ),
      ),
    );
  }


  // Notification
  if (allData['notifications'] != null) {
    notifications = List<AppNotification>.from(
      (allData['notifications'] as List).map(
        (item) => AppNotification.fromMap(Map<String, dynamic>.from(item as Map)),
      ),
    );
  }

  print('Data loaded successfully!');
}




// ---------- SEED DEFAULT CATEGORIES ----------
void seedCategories() {
  if (jobCategories.isEmpty) {
    jobCategories.addAll([
      'Information Technology',
      'Design & Creative',
      'Marketing & Sales',
      'Finance & Accounting',
      'Education & Training',
      'Healthcare',
      'Engineering',
      'Customer Service',
    ]);
  }
}





// ---- MAIN FUNCTION ----

void main(){

  setupAdmin();
  seedCategories();
  loadData();

  bool isRunning = true;

  while (isRunning){
    print ('=== SMART JOB PORTAL');
    print ('1, Register');
    print ('2, Login');
    print ('3, Forgot Password');
    print ('4, Exit');
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
      forgotPassword();
      break;
    case '4':
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

  if (email == null || email.isEmpty){
    print('Email cannot be empty');
    return;
  }

  if (users.containsKey(email)){
    print('Email already Registered!');
    return;
  }

  //step 2: Get password
  print('Password: ');
  String? password = stdin.readLineSync();

  if (password == null || password.isEmpty){
    print('Password cannot be empty!');
    return;
  }

  //step 3: Get name
  print('Name: ');
  String? name = stdin.readLineSync();

  if (name == null || name.isEmpty){
    print('Name cannot be empty!');
    return;
  }

  //step 4: Get role
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

  // ===== NEW: Security Question =====
  print('Security Question (for password reset): ');
  String? securityQuestion = stdin.readLineSync();

  if (securityQuestion == null || securityQuestion.isEmpty){
    print('Security question cannot be empty!');
    return;
  }

  print('Answer: ');
  String? securityAnswer = stdin.readLineSync();

  if (securityAnswer == null || securityAnswer.isEmpty){
    print('Answer cannot be empty!');
    return;
  }
  // ===== END NEW =====

  // Add user to the map
  users[email] = {
    'password': password,
    'name': name,
    'role': role,
    'securityQuestion': securityQuestion,   // NEW
    'securityAnswer': securityAnswer.toLowerCase(), // NEW
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





// ---------- FORGOT PASSWORD ----------
void forgotPassword() {
  print('\n--- Forgot Password ---');

  print('Enter your registered email: ');
  String? email = stdin.readLineSync();

  if (email == null || email.isEmpty) {
    print('Email cannot be empty!');
    return;
  }

  if (!users.containsKey(email)) {
    print('Email not found!');
    return;
  }

  // Show security question
  print('\nSecurity Question: ${users[email]!['securityQuestion']}');
  print('Your answer: ');
  String? answer = stdin.readLineSync();

  if (answer == null || answer.isEmpty) {
    print('Answer cannot be empty!');
    return;
  }

  // Check answer (case-insensitive)
  if (answer.toLowerCase() != users[email]!['securityAnswer']) {
    print('❌ Incorrect answer!');
    return;
  }

  // Allow password reset
  print('\n✅ Answer correct!');
  print('Enter new password: ');
  String? newPassword = stdin.readLineSync();

  if (newPassword == null || newPassword.isEmpty) {
    print('Password cannot be empty!');
    return;
  }

  print('Confirm new password: ');
  String? confirmPassword = stdin.readLineSync();

  if (newPassword != confirmPassword) {
    print('Passwords do not match!');
    return;
  }

  // Update password
  users[email]!['password'] = newPassword;
  print('✅ Password reset successful!');
  saveData();
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
      print('3. Withdraw Application');
      print('4. My Bookmarks');
      print('5. Notifications');
      print('6. Profile');
      print('7. Logout');
    }else if (role == 'admin') {
      print('\n=== ADMIN MENU ===');
      print('1. Dashboard & Analytics');
      print('2. View All Users');
      print('3. View All Jobs');
      print('4. Manage Categories');
      print('5. Logout');
    }else if (role == 'employer'){
      print('\n=== EMPLOYER MENU ===');
      print('1. Post a Job');
      print('2. View Applications');
      print('3. My Posted Jobs');
      print('4. Company Profile');
      print('5. Notification');
      print('6. Profile');
      print('7. Logout');
    }

    print('Choose an option: ');
    String? input = stdin.readLineSync();

      switch (input) {
      case '1':
        if (role == 'candidate') {
          browseJobs();
        } else if (role == 'admin') {
          adminDashboard();
        } else {
          postJob();
        }
        break;

      case '2':
        if (role == 'candidate') {
          myApplications();
        } else if (role == 'admin') {
          viewAllUsers();
        } else {
          viewApplicants();
        }
        break;

      case '3':
        if (role == 'candidate') {
          withdrawApplication();
        } else if (role == 'admin') {
          viewAllJobs();
        } else {
          myPostedJobs();
        }
        break;

      case '4':
        if (role == 'candidate') {
          myBookmarks();
        } else if (role == 'admin') {
          manageCategories();
        } else {
          companyProfile();
        }
        break;

      case '5':
        if (role == 'candidate') {
          viewNotifications();
        } else if (role == 'admin') {
          print('Logged out. Goodbye, ${currentUser!['name']}!');
          currentUser = null;
          inMenu = false;
        } else if (role == 'employer') {
          viewNotifications();
        }
        break;

      case '6':
        if (role == 'candidate') {
          editProfile();
        } else if (role == 'employer') {
          editProfile();
        }
        break;

      case '7':
        if (role == 'candidate') {
          print('Logged out. Goodbye, ${currentUser!['name']}!');
          currentUser = null;
          inMenu = false;
        } else if (role == 'employer') {
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
    if (job.postedBy != currentUser!['email']) {
      categories.add(job.category);
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
    if (job.postedBy!= currentUser!['email']) {
      locations.add(job.location);
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
    if (jobs[i].postedBy == currentUser!['email']) {
      continue;
    }

    // Check search keyword
    bool matchesKeyword = keyword == null || keyword.isEmpty ||
        jobs[i].title.toLowerCase().contains(keyword) ||
        jobs[i].company.toLowerCase().contains(keyword) ||
        jobs[i].category.toLowerCase().contains(keyword);

    // Check category filter
    bool matchesCategory = categoryFilter == 'all' ||
        jobs[i].category.toLowerCase() == categoryFilter.toLowerCase();

    // Check location filter
    bool matchesLocation = locationFilter == 'all' ||
        jobs[i].location.toLowerCase() == locationFilter.toLowerCase();

    // Show if all filters match
    if (matchesKeyword && matchesCategory && matchesLocation) {

      // Skip closed jobs
      if (jobs[i].status == 'Closed') {
        continue;
      }

      // Get deadline ONCE
      if (jobs[i].isExpired) {
        continue;
      }

      matchingIndexes.add(i);
      print('\n$displayNumber. ${jobs[i].title}');
      print('   Company: ${jobs[i].company}');
      print('   Location: ${jobs[i].location}');
      print('   Salary: ${jobs[i].salary}');
      print('   Category: ${jobs[i].category}');

      // Display deadli
      if (jobs[i].hasDeadline) {
        DateTime deadline = jobs[i].deadlineDate!;
        Duration remaining = deadline.difference(DateTime.now());
        if (remaining.inDays > 0) {
          print('   ⏰ Deadline: ${remaining.inDays} days left');
        } else if (remaining.inDays == 0) {
          print('   ⚠️ Deadline: TODAY!');
        } else {
          print('   ❌ Deadline: EXPIRED');
        }
      }
      
      displayNumber++;
    }
  }

  if (matchingIndexes.isEmpty) {
    print('No jobs match your search criteria.');
    return;
  }

  print('\nFound $displayNumber job(s)');

  // ===== NEW: 'Options =====

  print('\n--- Options ---');
  print('Enter job number to APPLY');
  print('Or type B<number> to BOOKMARK (e.g., B1)');
  print('Or type 0 to go back');
  print('Choose: ');
  String? choice = stdin.readLineSync();

  if (choice == null || choice == '0') {
    return;
  }

    // Check if user wants to bookmark
  if (choice.startsWith('B') || choice.startsWith('b')) {
    String numPart = choice.substring(1);
    int? bookmarkIndex = int.tryParse(numPart);
    
    if (bookmarkIndex == null || bookmarkIndex < 1 || bookmarkIndex > matchingIndexes.length) {
      print('Invalid choice!');
      return;
    }

    int actualIndex = matchingIndexes[bookmarkIndex - 1];
    Job selectedJob = jobs[actualIndex];

    // Check if already bookmarked
    bool alreadyBookmarked = false;
    for (var bm in bookmarks) {
      if (bm['candidateEmail'] == currentUser!['email'] &&
          bm['jobTitle'] == selectedJob.title &&
          bm['jobCompany'] == selectedJob.company) {
        alreadyBookmarked = true;
        break;
      }
    }

    if (alreadyBookmarked) {
      print('Already bookmarked!');
    } else {
      bookmarks.add({
        'candidateEmail': currentUser!['email']!,
        'jobTitle': selectedJob.title,
        'jobCompany': selectedJob.company,
        'location': selectedJob.location,
        'category': selectedJob.category,
      });
      print('🔖 Bookmarked "${selectedJob.title}"!');
      saveData();
    }
    return;
  }

    // ===== APPLY LOGIC (if not bookmark) =====
  int? selectedIndex = int.tryParse(choice);
  if (selectedIndex == null || selectedIndex < 1 || selectedIndex > matchingIndexes.length) {
    print('Invalid choice!');
    return;
  }

  // Get the actual job
  int actualIndex = matchingIndexes[selectedIndex - 1];
  Job selectedJob = jobs[actualIndex];

  // Check if already applied
  for (var app in applications) {
    if (app.applicantEmail == currentUser!['email'] &&
        app.jobTitle == selectedJob.title &&
        app.jobCompany == selectedJob.company) {
      print('You have already applied for this job!');
      return;
    }
  }

  // Apply
  applications.add(Application(
    applicantEmail: currentUser!['email']!,
    applicantName: currentUser!['name']!,
    jobTitle: selectedJob.title,
    jobCompany: selectedJob.company,
    status: 'Applied',
    employerEmail: selectedJob.postedBy,
  ));

  print('✅ Applied successfully for ${selectedJob.title}!');

  //Notify employer
  addNotification(
    selectedJob.postedBy,
    '${currentUser!['name']} applied for "${selectedJob.title}',
    'application',
    );

  saveData();
}




// ---------- MY BOOKMARKS (Candidate) ----------
void myBookmarks() {
  print('\n=== MY BOOKMARKED JOBS ===');

  bool found = false;

  for (int i = 0; i < bookmarks.length; i++) {
    if (bookmarks[i]['candidateEmail'] == currentUser!['email']) {
      found = true;
      print('\n${i + 1}. ${bookmarks[i]['jobTitle']}');
      print('   Company: ${bookmarks[i]['jobCompany']}');
      print('   Location: ${bookmarks[i]['location']}');
      print('   Category: ${bookmarks[i]['category']}');
    }
  }

  if (!found) {
    print('No bookmarked jobs yet.');
    return;
  }

  print('\n--- Options ---');
  print('1. Remove a Bookmark');
  print('2. Go Back');
  print('Choose: ');

  String? option = stdin.readLineSync();

  if (option == '1') {
    print('Enter bookmark number to remove (or 0 to cancel): ');
    String? choice = stdin.readLineSync();
    if (choice == null || choice == '0') return;

    int? index = int.tryParse(choice);
    if (index == null || index < 1 || index > bookmarks.length) {
      print('Invalid choice!');
      return;
    }

    bookmarks.removeAt(index - 1);
    print('🔖 Bookmark removed!');
    saveData();
  }
}





// ---------- MY APPLICATIONS (Candidate) ----------
void myApplications() {
  print('\n=== MY APPLICATIONS ===');

  bool found = false;

  for (int i = 0; i < applications.length; i++) {
    if (applications[i].applicantEmail == currentUser!['email']) {
      found = true;
      print('\n${i + 1}. ${applications[i].statusIcon} ${applications[i].jobTitle}');
      print('   Company: ${applications[i].jobCompany}');
      print('   Status: ${applications[i].status}');
    }
  }

  if (!found) {
    print('No applications yet.');
  }
}





// ---------- WITHDRAW APPLICATION (Candidate) ----------
void withdrawApplication() {
  print('\n--- Withdraw Application ---');

  // Find candidate's applications
  List<int> myAppIndexes = [];

  for (int i = 0; i < applications.length; i++) {
    if (applications[i].applicantEmail == currentUser!['email']) {
      myAppIndexes.add(i);
      print('\n${myAppIndexes.length}. ${applications[i].jobTitle}');
      print('   Company: ${applications[i].jobCompany}');
      print('   Status: ${applications[i].status}');
    }
  }

  if (myAppIndexes.isEmpty) {
    print('No applications to withdraw.');
    return;
  }

  print('\nEnter number to withdraw (or 0 to cancel): ');
  String? choice = stdin.readLineSync();
  if (choice == null || choice == '0') return;

  int? selected = int.tryParse(choice);
  if (selected == null || selected < 1 || selected > myAppIndexes.length) {
    print('Invalid choice!');
    return;
  }

  int actualIndex = myAppIndexes[selected - 1];

  // Can only withdraw if status is 'Applied' or 'Under Review'
    if (!applications[actualIndex].canWithdraw) {
    print('Cannot withdraw! Status is: ${applications[actualIndex].status}');
    return;
  }

  print('Withdraw application for "${applications[actualIndex].jobTitle}"? (yes/no): ');
  String? confirm = stdin.readLineSync();

  if (confirm != null && confirm.toLowerCase() == 'yes') {
    applications[actualIndex].status = 'Withdrawn';
    print('✅ Application withdrawn!');
    saveData();
  } else {
    print('Cancelled.');
  }
}





// ---------- VIEW APPLICANTS (Employer) ----------
void viewApplicants() {
  print('\n=== APPLICANTS FOR YOUR JOBS ===');

  bool found = false;

  for (int i = 0; i < applications.length; i++) {
    if (applications[i].employerEmail == currentUser!['email']) {
      found = true;
      print('\n${i + 1}. ${applications[i].applicantName}');
      print('   Applied for: ${applications[i].jobTitle}');
      print('   Status: ${applications[i].status}');
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
  if (applications[actualIndex].employerEmail != currentUser!['email']) {
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
      applications[actualIndex].status = 'Under Review';
      break;
    case '2':
      applications[actualIndex].status = 'Shortlisted';
      break;
    case '3':
      applications[actualIndex].status = 'Rejected';
      break;
    case '4':
      applications[actualIndex].status = 'Hired';
      break;
    default:
      print('Invalid status!');
      return;
  }

  print('✅ Status updated to: ${applications[actualIndex].status}');

  // Notify candidate
  addNotification(
    applications[actualIndex].applicantEmail,
    'Your application for "${applications[actualIndex].jobTitle}" is now ${applications[actualIndex].status}',
    'status',
    );

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

  // Show available categories
  print('\nAvailable Categories:');
  for (int i = 0; i < jobCategories.length; i++) {
    print('  ${i + 1}. ${jobCategories[i]}');
  }
  print('Choose category number (or type custom): ');
  String? categoryInput = stdin.readLineSync();

  String category;
  if (categoryInput == null || categoryInput.isEmpty) {
    print('Category cannot be empty!');
    return;
  }

  int? catIndex = int.tryParse(categoryInput);
  if (catIndex != null && catIndex >= 1 && catIndex <= jobCategories.length) {
    category = jobCategories[catIndex - 1];
  } else {
    category = categoryInput; // Custom category
    if (!jobCategories.contains(category)) {
      jobCategories.add(category);
      print('🆕 New category added: $category');
    }
  }

  print('Application Deadline (YYY-MM-DD): ');
  String? deadlineInput = stdin.readLineSync();

  DateTime? deadline;
  if (deadlineInput != null && deadlineInput.isNotEmpty) {
    try {
      List<String> parts = deadlineInput.split('-');
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int day = int.parse(parts[2]);
      deadline = DateTime(year, month, day);

      if (deadline.isBefore(DateTime.now())) {
        print('⚠️ Warning: Deadline is in the past!');
      }
    }catch (e) {
      print('Invalid date format! Using no deadline.');
      deadline = null;
    }
  }



    // Add job to the list
  jobs.add(Job(
    title: title,
    company: company,
    location: location,
    salary: salary,
    category: category,
    postedBy: currentUser!['email']!,
    deadline: deadline?.toIso8601String() ?? 'No deadline',
    status: 'Open',
  ));

  print('✅ Job posted successfully!');
  saveData();
}




// ---------- DELETE JOB (Employer) ----------
void deleteJob(List<int> myJobIndexes) {
  print('\n--- Delete Job ---');
  print('Enter job number to delete (or 0 to cancel): ');

  String? choice = stdin.readLineSync();
  if (choice == null || choice == '0') return;

  int? selected = int.tryParse(choice);
  if (selected == null || selected < 1 || selected > myJobIndexes.length) {
    print('Invalid choice!');
    return;
  }

  int actualIndex = myJobIndexes[selected - 1];

  // Confirm deletion
  print('Are you sure you want to delete "${jobs[actualIndex].title}"? (yes/no): ');
  String? confirm = stdin.readLineSync();

  if (confirm != null && confirm.toLowerCase() == 'yes') {
    // Also remove related applications
    String jobTitle = jobs[actualIndex].title;
    String jobCompany = jobs[actualIndex].company;

    applications.removeWhere((app) =>
        app.jobTitle == jobTitle && app.jobCompany == jobCompany);

    // Remove the job
    jobs.removeAt(actualIndex);

    print('✅ Job deleted successfully!');
    saveData();
  } else {
    print('Deletion cancelled.');
  }
}




// ---------- MY POSTED JOBS (Employer) ----------
void myPostedJobs() {
  print('\n=== MY POSTED JOBS ===');

  // Find jobs posted by current employer
  List<int> myJobIndexes = [];

  for (int i = 0; i < jobs.length; i++) {
    if (jobs[i].postedBy == currentUser!['email']) {
      myJobIndexes.add(i);
            print('\n${myJobIndexes.length}. ${jobs[i].title}');
      print('   Company: ${jobs[i].company}');
      print('   Location: ${jobs[i].location}');
      print('   Salary: ${jobs[i].salary}');
      print('   Category: ${jobs[i].category}');
      print('   Status: ${jobs[i].status}');
    }
  }

  if (myJobIndexes.isEmpty) {
    print('You haven\'t posted any jobs yet.');
    return;
  }

  print('\n--- Options ---');
  print('1. Edit a Job');
  print('2. Delete a Job');
  print('3. Close a Job');
  print('4. Go Back');
  print('Choose: ');

  String? option = stdin.readLineSync();

  switch (option) {
    case '1':
      editJob(myJobIndexes);
      break;
    case '2':
      deleteJob(myJobIndexes);
      break;
    case '3' :
      closeJob(myJobIndexes);
      break;
    case '4':
      return;
    default:
      print('Invalid option!');
  }
}



// ---------- EDIT JOB (Employer) ----------
void editJob(List<int> myJobIndexes) {
  print('\n--- Edit Job ---');
  print('Enter job number to edit (or 0 to cancel): ');

  String? choice = stdin.readLineSync();
  if (choice == null || choice == '0') return;

  int? selected = int.tryParse(choice);
  if (selected == null || selected < 1 || selected > myJobIndexes.length) {
    print('Invalid choice!');
    return;
  }

  int actualIndex = myJobIndexes[selected - 1];

  print('\nLeave field blank to keep current value.\n');

  // Title
  print('New Title [${jobs[actualIndex].title}]: ');
  String? newTitle = stdin.readLineSync();
  if (newTitle != null && newTitle.isNotEmpty) {
    jobs[actualIndex].title = newTitle;
  }

  // Company
  print('New Company [${jobs[actualIndex].company}]: ');
  String? newCompany = stdin.readLineSync();
  if (newCompany != null && newCompany.isNotEmpty) {
    jobs[actualIndex].company = newCompany;
  }

  // Location
  print('New Location [${jobs[actualIndex].location}]: ');
  String? newLocation = stdin.readLineSync();
  if (newLocation != null && newLocation.isNotEmpty) {
    jobs[actualIndex].location = newLocation;
  }

  // Salary
  print('New Salary [${jobs[actualIndex].salary}]: ');
  String? newSalary = stdin.readLineSync();
  if (newSalary != null && newSalary.isNotEmpty) {
    jobs[actualIndex].salary = newSalary;
  }

  // Category
  print('New Category [${jobs[actualIndex].category}]: ');
  String? newCategory = stdin.readLineSync();
  if (newCategory != null && newCategory.isNotEmpty) {
    jobs[actualIndex].category = newCategory;
  }

  print('✅ Job updated successfully!');
  saveData();
}





// ---------- CLOSE JOB (Employer) ----------
void closeJob(List<int> myJobIndexes) {
  print('\n--- Close a Job ---');
  print('Enter job number to close (or 0 to cancel): ');

  String? choice = stdin.readLineSync();
  if (choice == null || choice == '0') return;

  int? selected = int.tryParse(choice);
  if (selected == null || selected < 1 || selected > myJobIndexes.length) {
    print('Invalid choice!');
    return;
  }

  int actualIndex = myJobIndexes[selected - 1];

  if (jobs[actualIndex].status == 'Closed') {
    print('Job is already closed!');
    return;
  }

  print('Close "${jobs[actualIndex].title}"? (yes/no): ');
  String? confirm = stdin.readLineSync();

  if (confirm != null && confirm.toLowerCase() == 'yes') {
    jobs[actualIndex].status = 'Closed';
    print('🔒 Job closed! No more applications accepted.');

    // Notif all aaplicants
    for (var app in applications) {
      if (app.jobTitle == jobs[actualIndex].title && app.jobCompany == jobs[actualIndex].company) {
        addNotification(
          app.applicantEmail,
          'Job "${jobs[actualIndex].title}" has been closed',
          'system',
        );
      }
    }

    saveData();
  } else {
    print('Cancelled.');
  }
}





// ---------- COMPANY PROFILE (Employer) ----------
void companyProfile() {
  String email = currentUser!['email']!;

  print('\n=== COMPANY PROFILE ===');

  if (companyProfiles.containsKey(email)) {
    // Show existing profile
    var profile = companyProfiles[email]!;
    print('Company Name: ${profile['companyName']}');
    print('Industry: ${profile['industry']}');
    print('Website: ${profile['website']}');
    print('Description: ${profile['description']}');
    print('Employees: ${profile['employees']}');
  } else {
    print('No company profile yet.');
  }

  print('\n--- Options ---');
  print('1. Create/Edit Profile');
  print('2. Go Back');
  print('Choose: ');

  String? option = stdin.readLineSync();

  if (option == '1') {
    editCompanyProfile(email);
  }
}

void editCompanyProfile(String email) {
  print('\n--- Edit Company Profile ---');
  print('Leave blank to keep current value.\n');

  String currentName = companyProfiles[email]?['companyName'] ?? '';
  String currentIndustry = companyProfiles[email]?['industry'] ?? '';
  String currentWebsite = companyProfiles[email]?['website'] ?? '';
  String currentDesc = companyProfiles[email]?['description'] ?? '';
  String currentEmployees = companyProfiles[email]?['employees'] ?? '';

  print('Company Name [$currentName]: ');
  String? name = stdin.readLineSync();

  print('Industry [$currentIndustry]: ');
  String? industry = stdin.readLineSync();

  print('Website [$currentWebsite]: ');
  String? website = stdin.readLineSync();

  print('Description [$currentDesc]: ');
  String? description = stdin.readLineSync();

  print('Number of Employees [$currentEmployees]: ');
  String? employees = stdin.readLineSync();

  companyProfiles[email] = {
    'companyName': name != null && name.isNotEmpty ? name : currentName,
    'industry': industry != null && industry.isNotEmpty ? industry : currentIndustry,
    'website': website != null && website.isNotEmpty ? website : currentWebsite,
    'description': description != null && description.isNotEmpty ? description : currentDesc,
    'employees': employees != null && employees.isNotEmpty ? employees : currentEmployees,
  };

  print('✅ Company profile updated!');
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
      String category = job.category;
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
      String status = app.status;
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
    print('\n${i + 1}. ${jobs[i].title}');
    print('   Company: ${jobs[i].company}');
    print('   Location: ${jobs[i].location}');
    print('   Category: ${jobs[i].category}');
    print('   Posted by: ${jobs[i].postedBy}');
  }

  print('\nTotal: ${jobs.length} jobs');

  // ===== NEW: Admin can delete jobs =====
  print('\n--- Admin Options ---');
  print('1. Delete a Job');
  print('2. Go Back');
  print('Choose: ');

  String? option = stdin.readLineSync();

  if (option == '1') {
    print('Enter job number to delete (or 0 to cancel): ');
    String? choice = stdin.readLineSync();
    if (choice == null || choice == '0') return;

    int? selected = int.tryParse(choice);
    if (selected == null || selected < 1 || selected > jobs.length) {
      print('Invalid choice!');
      return;
    }

    int actualIndex = selected - 1;

    print('Delete "${jobs[actualIndex].title}"? (yes/no): ');
    String? confirm = stdin.readLineSync();

    if (confirm != null && confirm.toLowerCase() == 'yes') {
      // Remove related applications
      String jobTitle = jobs[actualIndex].title;
      String jobCompany = jobs[actualIndex].company;

      applications.removeWhere((app) =>
          app.jobTitle == jobTitle && app.jobCompany == jobCompany);

      jobs.removeAt(actualIndex);
      print('✅ Job deleted by admin!');
      saveData();
    } else {
      print('Deletion cancelled.');
    }
  }
}






// ---------- MANAGE CATEGORIES (Admin) ----------
void manageCategories() {
  print('\n=== MANAGE JOB CATEGORIES ===');

  for (int i = 0; i < jobCategories.length; i++) {
    print('${i + 1}. ${jobCategories[i]}');
  }

  print('\n--- Options ---');
  print('1. Add Category');
  print('2. Remove Category');
  print('3. Go Back');
  print('Choose: ');

  String? option = stdin.readLineSync();

  switch (option) {
    case '1':
      print('Enter new category name: ');
      String? newCat = stdin.readLineSync();
      if (newCat != null && newCat.isNotEmpty) {
        if (jobCategories.contains(newCat)) {
          print('Category already exists!');
        } else {
          jobCategories.add(newCat);
          print('✅ Category added: $newCat');
          saveData();
        }
      }
      break;
    case '2':
      print('Enter category number to remove: ');
      String? numStr = stdin.readLineSync();
      int? index = int.tryParse(numStr ?? '');
      if (index != null && index >= 1 && index <= jobCategories.length) {
        String removed = jobCategories.removeAt(index - 1);
        print('✅ Category removed: $removed');
        saveData();
      } else {
        print('Invalid number!');
      }
      break;
    case '3':
      return;
  }
}









// ---------- EDIT PROFILE ----------
void editProfile() {
  print('\n=== EDIT PROFILE ===');
  print('Leave field blank to keep current value.\n');

  String email = currentUser!['email']!;

  // Edit name
  print('New Name [${currentUser!['name']}]: ');
  String? newName = stdin.readLineSync();
  if (newName != null && newName.isNotEmpty) {
    users[email]!['name'] = newName;
    currentUser!['name'] = newName;
  }

  // Edit password
  print('New Password (or press Enter to skip): ');
  String? newPassword = stdin.readLineSync();
  if (newPassword != null && newPassword.isNotEmpty) {
    print('Confirm new password: ');
    String? confirm = stdin.readLineSync();
    if (newPassword == confirm) {
      users[email]!['password'] = newPassword;
      print('✅ Password updated!');
    } else {
      print('❌ Passwords do not match!');
    }
  }

  print('✅ Profile updated successfully!');
  saveData();
}




// ---------- ADD NOTIFICATION ----------
void addNotification(String email, String message, String type) {
  notifications.insert(0, AppNotification(
    recipientEmail: email,
    message: message,
    type: type,
  ));
  saveData();
}





// ---------- VIEW NOTIFICATIONS ----------
void viewNotifications() {
  String email = currentUser!['email']!;
  
  print('\n=== NOTIFICATIONS ===');
  
  int unreadCount = 0;
  int totalCount = 0;
  
  for (var notif in notifications) {
    if (notif.recipientEmail == email) {
      totalCount++;
      if (!notif.isRead) unreadCount++;
      
      String readMark = notif.isRead ? '  ' : '🔵';
      print('\n$readMark ${notif.icon} ${notif.message}');
      print('   ${notif.timeAgo}');
    }
  }
  
  if (totalCount == 0) {
    print('No notifications yet.');
    return;
  }
  
  print('\n$unreadCount unread | $totalCount total');
  
  print('\n--- Options ---');
  print('1. Mark All as Read');
  print('2. Clear All Notifications');
  print('3. Go Back');
  print('Choose: ');
  
  String? option = stdin.readLineSync();
  
  switch (option) {
    case '1':
      for (var notif in notifications) {
        if (notif.recipientEmail == email) {
          notif.isRead = true;
        }
      }
      print('✅ All marked as read!');
      saveData();
      break;
    case '2':
      notifications.removeWhere((n) => n.recipientEmail == email);
      print('✅ Notifications cleared!');
      saveData();
      break;
    case '3':
      return;
  }
}