import 'dart:io';
import 'dart:convert';


Map<String, User> users = {};
User? currentUser = null;
List<Job> jobs = [];
List<Application> applications = [];
List<Map<String, String>> bookmarks = [];
List<String> jobCategories = [];
Map<String, Map<String, String>> companyProfiles = {};
List<AppNotification> notifications = [];
List<Message> messages = [];
Map<String, Resume> resumes = {};






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
// CLASS: Message
// ============================================
class Message {
  String fromEmail;
  String toEmail;
  String content;
  DateTime sentAt;
  bool isRead;

  Message({
    required this.fromEmail,
    required this.toEmail,
    required this.content,
  })  : sentAt = DateTime.now(),
        isRead = false;

  Map<String, dynamic> toMap() {
    return {
      'fromEmail': fromEmail,
      'toEmail': toEmail,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead.toString(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      fromEmail: map['fromEmail']!,
      toEmail: map['toEmail']!,
      content: map['content']!,
    )
      ..sentAt = DateTime.parse(map['sentAt']!)
      ..isRead = map['isRead'] == 'true';
  }

  String get timeAgo {
    Duration diff = DateTime.now().difference(sentAt);
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
  List<String> requiredSkills;

  Job({
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.category,
    required this.postedBy,
    this.deadline = 'No deadline',
    this.status = 'Open',
    this.requiredSkills = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'salary': salary,
      'category': category,
      'postedBy': postedBy,
      'deadline': deadline,
      'status': status,
      'requiredSkills': requiredSkills.join(','),
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      title: map['title']!,
      company: map['company']!,
      location: map['location']!,
      salary: map['salary']!,
      category: map['category']!,
      postedBy: map['postedBy']!,
      deadline: map['deadline'] ?? 'No deadline',
      status: map['status'] ?? 'Open',
      requiredSkills: map['requiredSkills'] != null && map['requiredSkills']!.isNotEmpty
        ? (map['requiredSkills'] as String).split(',')
        : [],
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






// ============================================
// CLASS: User
// ============================================
class User {
  String email;
  String password;
  String name;
  String role;
  String securityQuestion;
  String securityAnswer;
  List<String> skills;

  User({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    required this.securityQuestion,
    required this.securityAnswer,
    this.skills = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'role': role,
      'securityQuestion': securityQuestion,
      'securityAnswer': securityAnswer,
      'skills': skills.join(','),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email']!,
      password: map['password']!,
      name: map['name']!,
      role: map['role']!,
      securityQuestion: map['securityQuestion'] ?? '',
      securityAnswer: map['securityAnswer'] ?? '',
      skills: map['skills'] != null && map['skills']!.isNotEmpty
          ? (map['skills'] as String).split(',')
          : [],
    );
  }

  // Getters
  bool get isCandidate => role == 'candidate';
  bool get isEmployer => role == 'employer';
  bool get isAdmin => role == 'admin';

  @override
  String toString() => 'User($name, $email, $role)';
}






// ============================================
// CLASS: Resume
// ============================================
class Resume {
  String email;
  String fullName;
  String phone;
  String address;
  String summary;
  List<String> education;
  List<String> experience;
  List<String> skills;
  List<String> languages;
  DateTime lastUpdated;

  Resume({
    required this.email,
    this.fullName = '',
    this.phone = '',
    this.address = '',
    this.summary = '',
    this.education = const [],
    this.experience = const [],
    this.skills = const [],
    this.languages = const [],
  }) : lastUpdated = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'summary': summary,
      'education': education.join('|||'),
      'experience': experience.join('|||'),
      'skills': skills.join('|||'),
      'languages': languages.join('|||'),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Resume.fromMap(Map<String, dynamic> map) {
    return Resume(
      email: map['email']!,
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      summary: map['summary'] ?? '',
      education: map['education'] != null && map['education']!.isNotEmpty
          ? (map['education'] as String).split('|||')
          : [],
      experience: map['experience'] != null && map['experience']!.isNotEmpty
          ? (map['experience'] as String).split('|||')
          : [],
      skills: map['skills'] != null && map['skills']!.isNotEmpty
          ? (map['skills'] as String).split('|||')
          : [],
      languages: map['languages'] != null && map['languages']!.isNotEmpty
          ? (map['languages'] as String).split('|||')
          : [],
    )..lastUpdated = DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String());
  }
}






// Pre-load the admin account
void setupAdmin() {
  if (!users.containsKey('admin@jobportal.com')) {
    users['admin@jobportal.com'] = User(
      email: 'admin@jobportal.com',
      password: 'admin123',
      name: 'System Admin',
      role: 'admin',
      securityQuestion: 'What is the admin password?',
      securityAnswer: 'admin123',
    );
  }
}




// ---------- Save Data to file ------------
void saveData(){
  // Put all our data into one big Map
  Map<String, dynamic> allData = {
    'users': users.map((key, u) => MapEntry(key, u.toMap())),
    'jobs' : jobs.map((j) => j.toMap()).toList(),
    'applications': applications.map((a) => a.toMap()).toList(),
    'bookmarks': bookmarks,
    'jobCategories': jobCategories,
    'companyProfiles': companyProfiles,
    'notifications': notifications.map((n) => n.toMap()).toList(),
    'messages': messages.map((m) => m.toMap()).toList(),
    'resumes': resumes.map((key, r) => MapEntry(key, r.toMap())),
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
  if (allData['users'] != null) {
    users = Map<String, User>.from(
      (allData['users'] as Map).map(
        (key, value) => MapEntry(
          key.toString(),
          User.fromMap(Map<String, dynamic>.from(value as Map)),
        ),
      ),
    );
  }

  //Restore jobs
  if (allData['jobs'] != null) {
    jobs = List<Job>.from(
      (allData['jobs'] as List).map(
        (item) => Job.fromMap(Map<String, dynamic>.from(item as Map)),
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

  // Restore notifications
  if (allData['notifications'] != null) {
    notifications = List<AppNotification>.from(
      (allData['notifications'] as List).map(
        (item) => AppNotification.fromMap(Map<String, dynamic>.from(item as Map)),
      ),
    );
  }


  // Messaging
  if (allData['messages'] != null) {
    messages = List<Message>.from(
      (allData['messages'] as List).map(
        (item) => Message.fromMap(Map<String, dynamic>.from(item as Map)),
      ),
    );
  }


  // Profile/Resume
    if (allData['resumes'] != null) {
    resumes = Map<String, Resume>.from(
      (allData['resumes'] as Map).map(
        (key, value) => MapEntry(
          key.toString(),
          Resume.fromMap(Map<String, dynamic>.from(value as Map)),
        ),
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
    users[email] = User(
    email: email,
    password: password,
    name: name,
    role: role,
    securityQuestion: securityQuestion,
    securityAnswer: securityAnswer.toLowerCase(),
  );
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



  if (users[email]!.password == password){
    // ✅ SET THE CURRENT USER HERE!
        currentUser = User(
      email: email,
      password: password,
      name: users[email]!.name,
      role: users[email]!.role,
      securityQuestion: users[email]!.securityQuestion,
      securityAnswer: users[email]!.securityAnswer,
    );

    print('✅ Welcome back, ${currentUser!.name}!');
    print('  Role: ${currentUser!.role}');


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
  print('\nSecurity Question: ${users[email]!.securityQuestion}');
  print('Your answer: ');
  String? answer = stdin.readLineSync();

  if (answer == null || answer.isEmpty) {
    print('Answer cannot be empty!');
    return;
  }

  // Check answer (case-insensitive)
  if (answer.toLowerCase() != users[email]!.securityAnswer) {
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
  users[email]!.password = newPassword;
  print('✅ Password reset successful!');
  saveData();
}







// ------- Show User Menu------------

void showUserMenu(){
  bool inMenu = true;

  do{
    String role = currentUser!.role;

    if(currentUser!.isCandidate){
      print('\n=== CANDIDATE MENU ===');
      showDeadlineAlerts();
      print('1. Browse Jobs');
      print('2. Recommended Jobs');
      print('3. Messages');
      print('4. My Applications');
      print('5. Withdraw Application');
      print('6. My Bookmarks');
      print('7. My Skills');
      print('8. My Resume');
      print('9. Notifications');
      print('10. Profile');
      print('11. Logout');
    }else if (currentUser!.isAdmin) {
      print('\n=== ADMIN MENU ===');
      print('1. Dashboard & Analytics');
      print('2. View All Users');
      print('3. View All Jobs');
      print('4. Manage Categories');
      print('5. Reports & Export');
      print('6. Logout');
    }else if (currentUser!.isEmployer) {
      print('\n=== EMPLOYER MENU ===');
      print('1. Post a Job');
      print('2. View Applicants');
      print('3. Messages');
      print('4. My Posted Jobs');
      print('5. Company Profile');
      print('6. Notification');
      print('7. Profile');
      print('8. Logout');
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
          recommendedJobs();
        } else if (role == 'admin') {
          viewAllUsers();
        } else {
          viewApplicants();
        }
        break;

      case '3':
        if (role == 'candidate') {
          viewMessages();
        } else if (role == 'admin') {
          viewAllJobs();
        } else {
          viewMessages();
        }
        break;

      case '4':
        if (role == 'candidate') {
          myApplications();
        } else if (role == 'admin') {
          manageCategories();
        } else {
          myPostedJobs();
        }
        break;

      case '5':
        if (role == 'candidate') {
          withdrawApplication();
        } else if (role == 'admin') {
          adminReports();
        } else if (role == 'employer') {
          companyProfile();
        }
        break;

      case '6':
        if (role == 'candidate') {
          myBookmarks();
        } else if (role == 'admin') {
          print('Logged out. Goodbye, ${currentUser!.name}!');
          currentUser = null;
          inMenu = false;
        } else if (role == 'employer') {
          viewNotifications();
        }
        break;

      case '7':
        if (role == 'candidate') {
          manageSkills();
        } else if (role == 'employer') {
          editProfile();
        }
        break;

      case '8':
        if (role == 'candidate') {
          myResume();
        } else if (role == 'employer') {
          editProfile();
        }
        break;

      case '9':
        if (role == 'candidate') {
          viewNotifications();
        } else if (role == 'employer') {
          print('Logged out. Goodbye, ${currentUser!.name}!');
          currentUser = null;
          inMenu = false;
        }
        break;

      case '10':
        if (role == 'candidate') {
          editProfile();
        }
        break;

      case '11':
        if (role == 'candidate') {
          print('Logged out. Goodbye, ${currentUser!.name}!');
          currentUser = null;
          inMenu = false;
        }
        break;

      default:
        print('Invalid choice.');
    }

  }while (inMenu);
}






// ---------- MANAGE SKILLS (Candidate) ----------
void manageSkills() {
  print('\n=== MY SKILLS ===');

  if (currentUser!.skills.isEmpty) {
    print('No skills added yet.');
  } else {
    print('Current skills: ${currentUser!.skills.join(", ")}');
  }

  print('\n--- Options ---');
  print('1. Add Skills');
  print('2. Clear All Skills');
  print('3. Go Back');
  print('Choose: ');

  String? option = stdin.readLineSync();

  switch (option) {
    case '1':
      print('Enter skills (comma-separated, e.g., Dart,Flutter,Python): ');
      String? input = stdin.readLineSync();
      if (input != null && input.isNotEmpty) {
        List<String> newSkills = input.split(',').map((s) => s.trim()).toList();
        for (var skill in newSkills) {
          if (!currentUser!.skills.contains(skill)) {
            currentUser!.skills.add(skill);
          }
        }
        users[currentUser!.email]!.skills = currentUser!.skills;
        print('✅ Skills updated!');
        saveData();
      }
      break;
    case '2':
      currentUser!.skills.clear();
      users[currentUser!.email]!.skills = [];
      print('✅ Skills cleared!');
      saveData();
      break;
    case '3':
      return;
  }
}







// ---------- MY RESUME (Candidate) ----------
void myResume() {
  String email = currentUser!.email;
  
  if (!resumes.containsKey(email)) {
    resumes[email] = Resume(email: email);
  }
  
  Resume resume = resumes[email]!;
  
  print('\n╔══════════════════════════════════╗');
  print('║        📄 MY RESUME              ║');
  print('╚══════════════════════════════════╝');
  
  print('\n👤 Personal Information');
  print('   Name: ${resume.fullName.isNotEmpty ? resume.fullName : "(not set)"}');
  print('   Phone: ${resume.phone.isNotEmpty ? resume.phone : "(not set)"}');
  print('   Address: ${resume.address.isNotEmpty ? resume.address : "(not set)"}');
  
  print('\n📝 Summary');
  print('   ${resume.summary.isNotEmpty ? resume.summary : "(not set)"}');
  
  print('\n🎓 Education');
  if (resume.education.isEmpty) {
    print('   (none added)');
  } else {
    for (var edu in resume.education) {
      print('   • $edu');
    }
  }
  
  print('\n💼 Experience');
  if (resume.experience.isEmpty) {
    print('   (none added)');
  } else {
    for (var exp in resume.experience) {
      print('   • $exp');
    }
  }
  
  print('\n🛠️ Skills');
  if (resume.skills.isEmpty) {
    print('   (none added)');
  } else {
    print('   ${resume.skills.join(", ")}');
  }
  
  print('\n🗣️ Languages');
  if (resume.languages.isEmpty) {
    print('   (none added)');
  } else {
    print('   ${resume.languages.join(", ")}');
  }
  
  print('\n--- Options ---');
  print('1. Edit Personal Info');
  print('2. Edit Summary');
  print('3. Add Education');
  print('4. Add Experience');
  print('5. Add Skills');
  print('6. Add Languages');
  print('7. Export Resume (Text File)');
  print('8. Go Back');
  print('Choose: ');
  
  String? option = stdin.readLineSync();
  
  switch (option) {
    case '1': editPersonalInfo(resume); break;
    case '2': editSummary(resume); break;
    case '3': addEducation(resume); break;
    case '4': addExperience(resume); break;
    case '5': addSkillsToResume(resume); break;
    case '6': addLanguages(resume); break;
    case '7': exportResume(resume); break;
    case '8': return;
    default: print('Invalid option!');
  }
}

// ---------- EDIT PERSONAL INFO ----------
void editPersonalInfo(Resume resume) {
  print('\n--- Edit Personal Info ---');
  print('Leave blank to keep current.\n');
  
  print('Full Name [${resume.fullName}]: ');
  String? name = stdin.readLineSync();
  if (name != null && name.isNotEmpty) resume.fullName = name;
  
  print('Phone [${resume.phone}]: ');
  String? phone = stdin.readLineSync();
  if (phone != null && phone.isNotEmpty) resume.phone = phone;
  
  print('Address [${resume.address}]: ');
  String? address = stdin.readLineSync();
  if (address != null && address.isNotEmpty) resume.address = address;
  
  resume.lastUpdated = DateTime.now();
  saveData();
  print('✅ Personal info updated!');
}

// ---------- EDIT SUMMARY ----------
void editSummary(Resume resume) {
  print('\n--- Edit Summary ---');
  print('Current: ${resume.summary.isNotEmpty ? resume.summary : "(none)"}');
  print('Enter new summary: ');
  String? summary = stdin.readLineSync();
  if (summary != null && summary.isNotEmpty) {
    resume.summary = summary;
    resume.lastUpdated = DateTime.now();
    saveData();
    print('✅ Summary updated!');
  }
}

// ---------- ADD EDUCATION ----------
void addEducation(Resume resume) {
  print('\n--- Education ---');
  if (resume.education.isNotEmpty) {
    print('Current:');
    for (int i = 0; i < resume.education.length; i++) {
      print('  ${i + 1}. ${resume.education[i]}');
    }
  }
  
  print('\nOptions: 1. Add  2. Remove  3. Back');
  String? option = stdin.readLineSync();
  
  switch (option) {
    case '1':
      print('Enter education (e.g., BSc Computer Science, AAU, 2023): ');
      String? edu = stdin.readLineSync();
      if (edu != null && edu.isNotEmpty) {
        resume.education.add(edu);
        resume.lastUpdated = DateTime.now();
        saveData();
        print('✅ Education added!');
      }
      break;
    case '2':
      if (resume.education.isEmpty) {
        print('Nothing to remove.');
        return;
      }
      print('Enter number to remove: ');
      String? num = stdin.readLineSync();
      int? index = int.tryParse(num ?? '');
      if (index != null && index >= 1 && index <= resume.education.length) {
        resume.education.removeAt(index - 1);
        resume.lastUpdated = DateTime.now();
        saveData();
        print('✅ Removed!');
      }
      break;
    case '3':
      return;
  }
}

// ---------- ADD EXPERIENCE ----------
void addExperience(Resume resume) {
  print('\n--- Experience ---');
  if (resume.experience.isNotEmpty) {
    print('Current:');
    for (int i = 0; i < resume.experience.length; i++) {
      print('  ${i + 1}. ${resume.experience[i]}');
    }
  }
  
  print('\nOptions: 1. Add  2. Remove  3. Back');
  String? option = stdin.readLineSync();
  
  switch (option) {
    case '1':
      print('Enter experience (e.g., Flutter Developer, TechCo, 2023-Present): ');
      String? exp = stdin.readLineSync();
      if (exp != null && exp.isNotEmpty) {
        resume.experience.add(exp);
        resume.lastUpdated = DateTime.now();
        saveData();
        print('✅ Experience added!');
      }
      break;
    case '2':
      if (resume.experience.isEmpty) {
        print('Nothing to remove.');
        return;
      }
      print('Enter number to remove: ');
      String? num = stdin.readLineSync();
      int? index = int.tryParse(num ?? '');
      if (index != null && index >= 1 && index <= resume.experience.length) {
        resume.experience.removeAt(index - 1);
        resume.lastUpdated = DateTime.now();
        saveData();
        print('✅ Removed!');
      }
      break;
    case '3':
      return;
  }
}

// ---------- ADD SKILLS TO RESUME ----------
void addSkillsToResume(Resume resume) {
  print('\n--- Resume Skills ---');
  if (resume.skills.isNotEmpty) {
    print('Current: ${resume.skills.join(", ")}');
  }
  
  print('\nOptions: 1. Add  2. Remove All  3. Back');
  String? option = stdin.readLineSync();
  
  switch (option) {
    case '1':
      print('Enter skills (comma-separated): ');
      String? input = stdin.readLineSync();
      if (input != null && input.isNotEmpty) {
        List<String> newSkills = input.split(',').map((s) => s.trim()).toList();
        for (var skill in newSkills) {
          if (!resume.skills.contains(skill)) {
            resume.skills.add(skill);
          }
        }
        resume.lastUpdated = DateTime.now();
        saveData();
        print('✅ Skills updated!');
      }
      break;
    case '2':
      resume.skills.clear();
      resume.lastUpdated = DateTime.now();
      saveData();
      print('✅ Skills cleared!');
      break;
    case '3':
      return;
  }
}

// ---------- ADD LANGUAGES ----------
void addLanguages(Resume resume) {
  print('\n--- Languages ---');
  if (resume.languages.isNotEmpty) {
    print('Current: ${resume.languages.join(", ")}');
  }
  
  print('\nOptions: 1. Add  2. Remove All  3. Back');
  String? option = stdin.readLineSync();
  
  switch (option) {
    case '1':
      print('Enter languages (comma-separated, e.g., English, Amharic): ');
      String? input = stdin.readLineSync();
      if (input != null && input.isNotEmpty) {
        List<String> newLangs = input.split(',').map((s) => s.trim()).toList();
        for (var lang in newLangs) {
          if (!resume.languages.contains(lang)) {
            resume.languages.add(lang);
          }
        }
        resume.lastUpdated = DateTime.now();
        saveData();
        print('✅ Languages updated!');
      }
      break;
    case '2':
      resume.languages.clear();
      resume.lastUpdated = DateTime.now();
      saveData();
      print('✅ Languages cleared!');
      break;
    case '3':
      return;
  }
}

// ---------- EXPORT RESUME ----------
void exportResume(Resume resume) {
  String text = '''
========================================
           PROFESSIONAL RESUME
========================================

👤 PERSONAL INFORMATION
   Name: ${resume.fullName}
   Email: ${resume.email}
   Phone: ${resume.phone}
   Address: ${resume.address}

📝 PROFESSIONAL SUMMARY
   ${resume.summary}

🎓 EDUCATION
${resume.education.map((e) => '   • $e').join('\n')}

💼 WORK EXPERIENCE
${resume.experience.map((e) => '   • $e').join('\n')}

🛠️ SKILLS
   ${resume.skills.join(', ')}

🗣️ LANGUAGES
   ${resume.languages.join(', ')}

========================================
Last Updated: ${resume.lastUpdated.toString().substring(0, 10)}
========================================
''';

  File('${resume.fullName}_Resume.txt'.replaceAll(' ', '_')).writeAsStringSync(text);
  print('✅ Resume exported to file!');
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
    if (job.postedBy != currentUser!.email) {
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
    if (job.postedBy!= currentUser!.email) {
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
    if (jobs[i].postedBy == currentUser!.email) {
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
          if (remaining.inDays <= 3 && remaining.inDays > 0) {
            print('   ⚡ URGENT: ${remaining.inDays} days left!');
          } else {
            print('   ⏰ Deadline: ${remaining.inDays} days left');
          }
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
      if (bm['candidateEmail'] == currentUser!.email &&
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
        'candidateEmail': currentUser!.email,
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
    if (app.applicantEmail == currentUser!.email &&
        app.jobTitle == selectedJob.title &&
        app.jobCompany == selectedJob.company) {
      print('You have already applied for this job!');
      return;
    }
  }

  // Apply
  applications.add(Application(
    applicantEmail: currentUser!.email,
    applicantName: currentUser!.name,
    jobTitle: selectedJob.title,
    jobCompany: selectedJob.company,
    status: 'Applied',
    employerEmail: selectedJob.postedBy,
  ));

  print('✅ Applied successfully for ${selectedJob.title}!');

  //Notify employer
  addNotification(
    selectedJob.postedBy,
    '${currentUser!.name} applied for "${selectedJob.title}',
    'application',
    );

  saveData();
}




// ---------- MY BOOKMARKS (Candidate) ----------
void myBookmarks() {
  print('\n=== MY BOOKMARKED JOBS ===');

  bool found = false;

  for (int i = 0; i < bookmarks.length; i++) {
    if (bookmarks[i]['candidateEmail'] == currentUser!.email) {
      found = true;
      print('\n${i + 1}. ${bookmarks[i]['jobTitle']}');
      print('   Company: ${bookmarks[i]['jobCompany']}');
      print('   Location: ${bookmarks[i]['location']}');
      print('   Category: ${bookmarks[i]['category']}');

      // NEW: Show deadline if found
      for (var job in jobs) {
        if (job.title == bookmarks[i]['jobTitle'] && 
            job.company == bookmarks[i]['jobCompany'] &&
            job.hasDeadline && !job.isExpired) {
          DateTime deadline = job.deadlineDate!;
          Duration remaining = deadline.difference(DateTime.now());
          if (remaining.inDays <= 3) {
            print('   ⚡ ${remaining.inDays} day(s) left!');
          }
        }
      }
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






// ---------- RECOMMENDED JOBS (Candidate) ----------
void recommendedJobs() {
  print('\n=== RECOMMENDED JOBS FOR YOU ===');

  if (jobs.isEmpty) {
    print('No jobs available yet.');
    return;
  }

  if (currentUser!.skills.isEmpty) {
    print('⚠️ Add skills to get personalized recommendations!');
    print('   Go to: My Skills in the menu.');
    return;
  }

  List<Map<String, dynamic>> scoredJobs = [];

  for (var job in jobs) {
    if (job.postedBy == currentUser!.email) continue;
    if (job.isClosed || job.isExpired) continue;

    // Calculate match score
    int score = 0;
    List<String> matchedSkills = [];

    for (var userSkill in currentUser!.skills) {
      for (var jobSkill in job.requiredSkills) {
        if (userSkill.toLowerCase() == jobSkill.toLowerCase()) {
          score += 10;
          matchedSkills.add(jobSkill);
        }
      }
    }

    // Bonus for same category
    List<String> preferredCategories = getPreferredCategories();
    if (preferredCategories.contains(job.category)) {
      score += 5;
    }

    if (score > 0) {
      scoredJobs.add({
        'job': job,
        'score': score,
        'matchedSkills': matchedSkills,
      });
    }
  }

  if (scoredJobs.isEmpty) {
    print('No matching jobs found. Try adding more skills!');
    return;
  }

  // Sort by score (highest first)
  scoredJobs.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

  // Display top 10
  int limit = scoredJobs.length > 10 ? 10 : scoredJobs.length;
  print('Top $limit matches:\n');

  for (int i = 0; i < limit; i++) {
    Job job = scoredJobs[i]['job'] as Job;
    int score = scoredJobs[i]['score'] as int;
    List<String> matched = scoredJobs[i]['matchedSkills'] as List<String>;

    print('${i + 1}. 🔥 ${job.title} (Match: $score%)');
    print('   Company: ${job.company}');
    print('   Location: ${job.location}');
    print('   Category: ${job.category}');
    print('   Matched Skills: ${matched.join(", ")}');
    print('');
  }

  print('Add more skills to improve recommendations!');
}

// Helper: Get categories candidate has applied to
List<String> getPreferredCategories() {
  Set<String> categories = {};
  for (var app in applications) {
    if (app.applicantEmail == currentUser!.email) {
      for (var job in jobs) {
        if (job.title == app.jobTitle && job.company == app.jobCompany) {
          categories.add(job.category);
        }
      }
    }
  }
  return categories.toList();
}





// ---------- MY APPLICATIONS (Candidate) ----------
void myApplications() {
  print('\n=== MY APPLICATIONS ===');

  bool found = false;

  for (int i = 0; i < applications.length; i++) {
    if (applications[i].applicantEmail == currentUser!.email) {
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
    if (applications[i].applicantEmail == currentUser!.email) {
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
    if (applications[i].employerEmail == currentUser!.email) {
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
  if (applications[actualIndex].employerEmail != currentUser!.email) {
    print('Invalid choice!');
    return;
  }

  print('\n--- Change Status ---');
  print('1. Under Review');
  print('2. Shortlisted');
  print('3. Rejected');
  print('4. Hired');
  print('5. Send Message');
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
    case '5':
      sendMessageTo(applications[actualIndex].applicantEmail);
      return;
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


    print('Required Skills (comma-separated, e.g., Dart,Flutter,Python): ');
  String? skillsInput = stdin.readLineSync();
  List<String> requiredSkills = [];
  if (skillsInput != null && skillsInput.isNotEmpty) {
    requiredSkills = skillsInput.split(',').map((s) => s.trim()).toList();
  }



    // Add job to the list
  jobs.add(Job(
    title: title,
    company: company,
    location: location,
    salary: salary,
    category: category,
    postedBy: currentUser!.email,
    deadline: deadline?.toIso8601String() ?? 'No deadline',
    status: 'Open',
    requiredSkills: requiredSkills,
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
    if (jobs[i].postedBy == currentUser!.email) {
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
  String email = currentUser!.email;

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
    if (user.role == 'candidate') {
      candidateCount++;
    } else if (user.role == 'employer') {
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
  users.forEach((email, user) {
    print('\n$count. ${user.name}');
    print('   Email: $email');
    print('   Role: ${user.role}');
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






// ---------- ADMIN REPORTS ----------
void adminReports() {
  print('\n=== REPORTS & EXPORT ===');
  print('1. Export All Jobs (CSV)');
  print('2. Export All Applications (CSV)');
  print('3. Export All Users (CSV)');
  print('4. Application Status Report');
  print('5. Employer Performance Report');
  print('6. Go Back');
  print('Choose: ');

  String? option = stdin.readLineSync();

  switch (option) {
    case '1':
      exportJobsCSV();
      break;
    case '2':
      exportApplicationsCSV();
      break;
    case '3':
      exportUsersCSV();
      break;
    case '4':
      applicationStatusReport();
      break;
    case '5':
      employerPerformanceReport();
      break;
    case '6':
      return;
  }
}






// ---------- EXPORT JOBS CSV ----------
void exportJobsCSV() {
  String csv = 'Title,Company,Location,Salary,Category,Status,Deadline,Posted By\n';
  
  for (var job in jobs) {
    csv += '${job.title},${job.company},${job.location},${job.salary},${job.category},${job.status},${job.deadline},${job.postedBy}\n';
  }

  File('jobs_export.csv').writeAsStringSync(csv);
  print('✅ Jobs exported to jobs_export.csv');
  print('   ${jobs.length} jobs exported!');
}




// ---------- EXPORT APPLICATIONS CSV ----------
void exportApplicationsCSV() {
  String csv = 'Applicant Name,Applicant Email,Job Title,Company,Status,Employer Email\n';
  
  for (var app in applications) {
    csv += '${app.applicantName},${app.applicantEmail},${app.jobTitle},${app.jobCompany},${app.status},${app.employerEmail}\n';
  }

  File('applications_export.csv').writeAsStringSync(csv);
  print('✅ Applications exported to applications_export.csv');
  print('   ${applications.length} applications exported!');
}





// ---------- EXPORT USERS CSV ----------
void exportUsersCSV() {
  String csv = 'Name,Email,Role\n';
  
  users.forEach((email, user) {
    csv += '${user.name},$email,${user.role}\n';
  });

  File('users_export.csv').writeAsStringSync(csv);
  print('✅ Users exported to users_export.csv');
  print('   ${users.length} users exported!');
}





// ---------- APPLICATION STATUS REPORT ----------
void applicationStatusReport() {
  print('\n=== APPLICATION STATUS REPORT ===\n');

  if (applications.isEmpty) {
    print('No applications yet.');
    return;
  }

  // Count by status
  Map<String, int> statusCount = {};
  Map<String, List<String>> statusJobs = {};

  for (var app in applications) {
    statusCount[app.status] = (statusCount[app.status] ?? 0) + 1;
    statusJobs.putIfAbsent(app.status, () => []);
    statusJobs[app.status]!.add('  - ${app.jobTitle} (${app.applicantName})');
  }

  // Display
  List<String> statusOrder = ['Applied', 'Under Review', 'Shortlisted', 'Hired', 'Rejected', 'Withdrawn'];
  
  for (var status in statusOrder) {
    if (statusCount.containsKey(status)) {
      print('${getStatusIcon(status)} $status: ${statusCount[status]}');
      for (var detail in statusJobs[status]!) {
        print(detail);
      }
      print('');
    }
  }

  print('Total Applications: ${applications.length}');
}

String getStatusIcon(String status) {
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





// ---------- EMPLOYER PERFORMANCE REPORT ----------
void employerPerformanceReport() {
  print('\n=== EMPLOYER PERFORMANCE REPORT ===\n');

  // Count jobs per employer
  Map<String, int> employerJobCount = {};
  Map<String, int> employerAppCount = {};
  Map<String, String> employerName = {};

  for (var job in jobs) {
    employerJobCount[job.postedBy] = (employerJobCount[job.postedBy] ?? 0) + 1;
  }

  for (var app in applications) {
    employerAppCount[app.employerEmail] = (employerAppCount[app.employerEmail] ?? 0) + 1;
  }

  // Get employer names
  for (var job in jobs) {
    if (users.containsKey(job.postedBy)) {
      employerName[job.postedBy] = users[job.postedBy]!.name;
    }
  }

  if (employerJobCount.isEmpty) {
    print('No employer data yet.');
    return;
  }

  employerJobCount.forEach((email, jobCount) {
    int appCount = employerAppCount[email] ?? 0;
    String name = employerName[email] ?? email;
    double hireRate = appCount > 0 ? (statusCountForEmployer(email, 'Hired') / appCount * 100) : 0;
    
    print('🏢 $name ($email)');
    print('   Jobs Posted: $jobCount');
    print('   Applications Received: $appCount');
    print('   Hire Rate: ${hireRate.toStringAsFixed(1)}%');
    print('');
  });
}

int statusCountForEmployer(String email, String status) {
  int count = 0;
  for (var app in applications) {
    if (app.employerEmail == email && app.status == status) {
      count++;
    }
  }
  return count;
}






// ---------- EDIT PROFILE ----------
void editProfile() {
  print('\n=== EDIT PROFILE ===');
  print('Leave field blank to keep current value.\n');

  String email = currentUser!.email;

  // Edit name
  print('New Name [${currentUser!.name}]: ');
  String? newName = stdin.readLineSync();
  if (newName != null && newName.isNotEmpty) {
    users[email]!.name = newName;
    currentUser!.name = newName;
  }

  // Edit password
  print('New Password (or press Enter to skip): ');
  String? newPassword = stdin.readLineSync();
  if (newPassword != null && newPassword.isNotEmpty) {
    print('Confirm new password: ');
    String? confirm = stdin.readLineSync();
    if (newPassword == confirm) {
      users[email]!.password = newPassword;
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







// ---------- SHOW DEADLINE ALERTS ----------
void showDeadlineAlerts() {
  if (currentUser == null || !currentUser!.isCandidate) return;
  
  List<String> alerts = [];
  
  for (var job in jobs) {
    if (job.isClosed || job.isExpired) continue;
    if (!job.hasDeadline) continue;
    
    // Check if candidate applied to this job
    bool hasApplied = false;
    for (var app in applications) {
      if (app.applicantEmail == currentUser!.email &&
          app.jobTitle == job.title &&
          app.jobCompany == job.company) {
        hasApplied = true;
        break;
      }
    }
    
    // Check if bookmarked
    bool isBookmarked = false;
    for (var bm in bookmarks) {
      if (bm['candidateEmail'] == currentUser!.email &&
          bm['jobTitle'] == job.title &&
          bm['jobCompany'] == job.company) {
        isBookmarked = true;
        break;
      }
    }
    
    // Alert for applied or bookmarked jobs
    if (hasApplied || isBookmarked) {
      DateTime deadline = job.deadlineDate!;
      Duration remaining = deadline.difference(DateTime.now());
      
      if (remaining.inDays <= 3 && remaining.inDays > 0) {
        alerts.add('⏰ ${job.title} at ${job.company}: ${remaining.inDays} day(s) left!');
      } else if (remaining.inDays == 0 && remaining.inHours > 0) {
        alerts.add('⚠️ ${job.title} at ${job.company}: Deadline TODAY!');
      }
    }
  }
  
  if (alerts.isNotEmpty) {
    print('\n═══════════════════════════════════');
    print('📅 DEADLINE ALERTS');
    for (var alert in alerts) {
      print('   $alert');
    }
    print('═══════════════════════════════════');
  }
}








// ---------- VIEW NOTIFICATIONS ----------
void viewNotifications() {
  String email = currentUser!.email;
  
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




// ---------- VIEW MESSAGES ----------
void viewMessages() {
  String email = currentUser!.email;
  
  print('\n=== MESSAGES ===');
  
  // Find unique contacts
  Set<String> contacts = {};
  for (var msg in messages) {
    if (msg.fromEmail == email) contacts.add(msg.toEmail);
    if (msg.toEmail == email) contacts.add(msg.fromEmail);
  }
  
  if (contacts.isEmpty) {
    print('No messages yet.');
    print('\nSend a message to:');
    print('1. An employer (from applicant list)');
    print('2. A candidate (from applicants list)');
    return;
  }
  
  // Show conversations
  List<String> contactList = contacts.toList();
  for (int i = 0; i < contactList.length; i++) {
    String contactEmail = contactList[i];
    String contactName = users.containsKey(contactEmail) 
        ? users[contactEmail]!.name 
        : contactEmail;
    
    // Count unread
    int unread = 0;
    for (var msg in messages) {
      if (msg.fromEmail == contactEmail && msg.toEmail == email && !msg.isRead) {
        unread++;
      }
    }
    
    String unreadBadge = unread > 0 ? ' ($unread new)' : '';
    print('${i + 1}. $contactName$unreadBadge');
  }
  
  print('\nEnter number to open conversation (or 0 to go back): ');
  String? choice = stdin.readLineSync();
  if (choice == null || choice == '0') return;
  
  int? index = int.tryParse(choice);
  if (index == null || index < 1 || index > contactList.length) {
    print('Invalid choice!');
    return;
  }
  
  openConversation(contactList[index - 1]);
}

// ---------- OPEN CONVERSATION ----------
void openConversation(String contactEmail) {
  String myEmail = currentUser!.email;
  String contactName = users.containsKey(contactEmail) 
      ? users[contactEmail]!.name 
      : contactEmail;
  
  while (true) {
    print('\n=== Chat with $contactName ===');
    
    // Show messages
    List<Message> conversation = [];
    for (var msg in messages) {
      if ((msg.fromEmail == myEmail && msg.toEmail == contactEmail) ||
          (msg.fromEmail == contactEmail && msg.toEmail == myEmail)) {
        conversation.add(msg);
        msg.isRead = true;
      }
    }
    
    if (conversation.isEmpty) {
      print('No messages yet. Start the conversation!');
    } else {
      for (var msg in conversation) {
        String sender = msg.fromEmail == myEmail ? 'You' : contactName;
        print('[$sender] ${msg.content}');
        print('  ${msg.timeAgo}');
      }
    }
    
    print('\nType your message (or 0 to go back): ');
    String? content = stdin.readLineSync();
    if (content == null || content == '0') {
      saveData();
      return;
    }
    
    if (content.isNotEmpty) {
      messages.add(Message(
        fromEmail: myEmail,
        toEmail: contactEmail,
        content: content,
      ));
      saveData();
    }
  }
}

// ---------- SEND MESSAGE TO USER ----------
void sendMessageTo(String recipientEmail) {
  String recipientName = users.containsKey(recipientEmail) 
      ? users[recipientEmail]!.name 
      : recipientEmail;
  
  print('\nSend message to $recipientName: ');
  String? content = stdin.readLineSync();
  
  if (content != null && content.isNotEmpty) {
    messages.add(Message(
      fromEmail: currentUser!.email,
      toEmail: recipientEmail,
      content: content,
    ));
    print('✅ Message sent!');
    saveData();
  }
}