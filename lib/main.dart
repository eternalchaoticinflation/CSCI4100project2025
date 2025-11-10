// lab01 — AI-generated example (ChatGPT)
// Requirements: show a counter, increment with a button, display a snackbar.

import 'package:flutter/material.dart';

void main() {
  runApp(const BookshareApp());
}
//  Main app widget for the Campus Bookshare App
//  This sets up the overall look, theme, and the first screen shown when the app starts
class BookshareApp extends StatelessWidget {
  const BookshareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Bookshare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const HomePage(),
    );
  }
}

//
// ──────────────────────────────────────────────────────────────────────────────
//   Mock Data Models
//   These classes represent the core data structures used throughout the app.
//   They simulate the data you’d expect from a real backend or database.
// ──────────────────────────────────────────────────────────────────────────────
//

// Mock Data Classes
class User {
  String name;                    //  Full name of the user
  String email;                   //  Email address (used for login or identification)
  String? photoUrl;               //  Optional profile photo
  int credits;                    //  The amount of credits a user has for borrowing books
  String? bio;                    //  Optional short biography or description

  //  Constructor that initializes user properties.
  //  'credits' defaults to 1000 if not provided
  User({
    required this.name,
    required this.email,
    this.photoUrl,
    this.credits = 1000,
    this.bio,
  });
}


//  Represents a book that can be shared or borrowed on the platform
class Book {
  String id;          //  Unique identifier for the book (could be UUID or DB ID)
  String isbn;        //  ISBN number for the book (used for identification)
  String title;       //  Title of the book
  String author;      //  Author's name
  String ownerName;   //  The user who owns this book
  String? photoUrl;   //  Optional book cover image
  String condition;   //  Description of book condition (e.g., "New", "Used")
  double? pickupLat;  //  Optional latitude for pickup location
  double? pickupLng;  //  Optional longitude for pickup location
  String? notes;      //  Optional notes about the book (special info or restrictions)

  //  Constructor for creating a Book instance with required and optional fields.
  Book({
    required this.id,
    required this.isbn,
    required this.title,
    required this.author,
    required this.ownerName,
    this.photoUrl,
    required this.condition,
    this.pickupLat,
    this.pickupLng,
    this.notes,
  });
}

class Transaction {
  String id;             // Unique identifier for the transaction
  Book book;             // The book being borrowed/lent
  String borrowerName;   // The person borrowing the book
  String lenderName;     // The person lending the book
  DateTime startDate;    // When the transaction started
  DateTime dueDate;      // When the borrowed book is due
  bool isReturned;       // Whether the book has been returned
  bool isBorrower;       // True if current user is borrower; false if they’re the lender

  // Constructor for creating a Transaction instance
  Transaction({
    required this.id,
    required this.book,
    required this.borrowerName,
    required this.lenderName,
    required this.startDate,
    required this.dueDate,
    this.isReturned = false,
    required this.isBorrower,
  });
}

// Global user state (in real app, use state management)
User? currentUser;

// Mock data for books
List<Book> mockBooks = [
  Book(
    id: '1',
    isbn: '9780134685991',
    title: 'Effective Java',
    author: 'Joshua Bloch',
    ownerName: 'John Smith',
    condition: 'Good',
    notes: 'Slight wear on cover',
  ),
  Book(
    id: '2',
    isbn: '9780132350884',
    title: 'Clean Code',
    author: 'Robert Martin',
    ownerName: 'Sarah Lee',
    condition: 'Like New',
    notes: 'No marks or highlights',
  ),
  Book(
    id: '3',
    isbn: '9780262033848',
    title: 'Introduction to Algorithms',
    author: 'Cormen, Leiserson, Rivest',
    ownerName: 'Mike Johnson',
    condition: 'Fair',
    notes: 'Some highlighting',
  ),
];

List<Transaction> mockTransactions = [];

// HOME PAGE
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

//  The state class that defines the behavior and content of the HomePage
class _HomePageState extends State<HomePage> {
  //  Controller to capture the user's text input in the search field
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //  The Scaffold provides the overall page layout with AppBar, body, and FAB
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Bookshare'),
        actions: [
          //  If a user is currently signed in, show a profile icon in the app bar
          if (currentUser != null)
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                //  Navigate to the user's profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
        ],
      ),
      //  Main content of the homepage
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ──────────────── WELCOME SECTION ────────────────
            Card(
              elevation: 2,   // Adds slight shadow around the card
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Book icon to visually represent the app
                    const Icon(Icons.book, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),

                    // Welcome heading text
                    Text(
                      'Welcome to Campus Bookshare',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Short description of the app's purpose
                    const Text(
                      'Borrow and lend textbooks with fellow students',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),

                    // If user is signed in, display their available credits
                    if (currentUser != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Credits: ${currentUser!.credits}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ──────────────── SEARCH BAR ────────────────
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search books by title, author, or ISBN...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // ──────────────── SEARCH BUTTON ────────────────
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BooksAvailablePage(
                      searchQuery: _searchController.text,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Search Books'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // ──────────────── SIGN IN / PROFILE NAVIGATION ────────────────
            if (currentUser == null)
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              )
            else
            // If a user is logged in, show a button to access their transactions
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.list_alt),
                label: const Text('My Transactions'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),

            const Spacer(),

            // ──────────────── QUICK STATS SECTION ────────────────
            if (currentUser != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //  Column showing number of books currently being lent
                      Column(
                        children: [
                          const Icon(Icons.upload, color: Colors.green),
                          const SizedBox(height: 4),
                          Text(
                            //  Count transactions where current user is the lender
                            '${mockTransactions.where((t) => !t.isBorrower).length}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Lending'),
                        ],
                      ),

                      //  Column showing number of books currently borrowed
                      Column(
                        children: [
                          const Icon(Icons.download, color: Colors.orange),
                          const SizedBox(height: 4),
                          Text(
                            '${mockTransactions.where((t) => t.isBorrower).length}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Borrowed'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      //  ──────────────── FLOATING ACTION BUTTON ────────────────
      //  Only visible when the user is signed in
      floatingActionButton: currentUser != null
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddBookPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('List Book'),
      )
          : null,
    );
  }
}

//  ──────────────── SIGN IN PAGE ────────────────
class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

//  Manages user input, form validation, and account creation logic
class _SignInPageState extends State<SignInPage> {
  //  A global key that uniquely identifies the form and allows validation
  final _formKey = GlobalKey<FormState>();
  //  Controllers to manage and retrieve text input from the form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  //  Stores the path or reference to the user’s profile photo (optional)
  String? _photoUrl;

  // ───────────────────────────────────────────────────────────────
  // Simulates capturing a photo from the camera.
  // In a real app, this would integrate with the camera plugin.
  // ───────────────────────────────────────────────────────────────
  void _takePhoto() {
    // Simulate taking photo
    setState(() {
      _photoUrl = 'captured_photo';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo captured! (Camera integration needed)')),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Handles the form submission and sign-in logic.
  // Validates user input, creates a new User object, and navigates home.
  // ────────────────────────────────────────────────────────────────────
  void _signIn() {
    //  Check if the form fields pass all validation rules
    if (_formKey.currentState!.validate()) {
      //  Create a new user using data from the form fields
      currentUser = User(
        name: _nameController.text,
        email: _emailController.text,
        photoUrl: _photoUrl,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
      );
      //  Display success feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      //  Navigate back and refresh home page
      //  ensures the user cannot go "back" to the sign-in screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
      );
    }
  }
  //  Builds the visual layout for the Sign In / Register page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  App bar with the title at the top of the screen
      appBar: AppBar(title: const Text('Sign In / Register')),
      //  The main content of the page scrolls if needed (important for smaller screens)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,  //  Connects this form to the validator logic defined earlier
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, //  Stretch widgets to full width
            children: [
              //  ─────────────── HEADER TEXTS ───────────────
              const Text(
                'Create Your Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You must be a university student to use this app',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              //  ─────────────── PROFILE PHOTO SECTION ───────────────
              Center(
                child: GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle, //  circular container
                    ),
                    //  If no photo is taken, show a camera icon
                    //  Otherwise, show a generic profile icon
                    child: _photoUrl == null
                        ? const Icon(Icons.add_a_photo, size: 48)
                        : const Icon(Icons.person, size: 48),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              //  Instructional text below the photo circle
              const Center(
                child: Text(
                  'Tap to take profile photo',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              // ─────────────── NAME FIELD ───────────────
              TextFormField(
                controller: _nameController,  //  Connects to the name input controller
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                //  Simple validation: ensures field is not empty
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              //  ─────────────── EMAIL FIELD ───────────────
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'University Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  helperText: 'Must be a .net email',
                ),
                keyboardType: TextInputType.emailAddress,
                //  Validation ensures user enters an Ontario Tech student email address
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') || !value.endsWith('@ontariotechu.net')) {
                    return 'Please use a valid ontariotechu.net email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // ─────────────── BIO FIELD ───────────────
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                  helperText: 'Introduce yourself to other students',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              // ─────────────── CREATE ACCOUNT BUTTON ───────────────
              ElevatedButton(
                onPressed: _signIn, // Calls the function to create a user account
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Create Account', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//  ──────────────── PROFILE PAGE ────────────────
//  Displays the currently logged-in user's information, credits, bio,
//  and navigation shortcuts to other parts of the app
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //  If there is no user logged in, show a message prompting them to sign in first
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Please sign in first')),
      );
    }
    //  If a user is signed in, display their full profile information
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          //  Logout button in the top-right corner of the app bar
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              //  Clear the current user and return to the previous screen
              currentUser = null;
              Navigator.pop(context);
              //  Show a small message at the bottom confirming logout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out')),
              );
            },
          ),
        ],
      ),
      //  The body scrolls in case content is taller than the screen
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //  ─────────────── PROFILE PICTURE ───────────────
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              // For now, both cases use the same placeholder icon
              // In a real app, this could display a user-uploaded photo
              child: currentUser!.photoUrl == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            //  Display the user's name in large bold text
            Text(
              currentUser!.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            //  Display the user's email in a lighter grey color
            Text(
              currentUser!.email,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            //  ─────────────── CREDITS CARD ───────────────
            //  Shows how many credits the user currently has
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 32),
                    const SizedBox(width: 8),
                    Text(
                      '${currentUser!.credits} Credits',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            //  ─────────────── ABOUT ME SECTION ───────────────
            if (currentUser!.bio != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About Me',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(currentUser!.bio!),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            //  ─────────────── ACTION BUTTONS ───────────────
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('My Transactions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionsPage(),
                  ),
                );
              },
            ),
            //  Navigates to page where user can list a new book to lend
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('List a Book'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddBookPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//  ─────────────── BOOKS AVAILABLE PAGE ───────────────
//  Displays a list of books that match the user's search query
//  Users can tap a book to view more details on the Book Details Page
class BooksAvailablePage extends StatelessWidget {
  //  The text entered by the user in the search field on the HomePage
  final String searchQuery;

  //  Constructor requiring the search query as a parameter
  const BooksAvailablePage({Key? key, required this.searchQuery})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ─────────────── FILTER BOOKS BASED ON SEARCH QUERY ───────────────
    // If no search query is entered, show all mock books
    // Otherwise, only include books that match the title, author, or ISBN
    final filteredBooks = searchQuery.isEmpty
        ? mockBooks
        : mockBooks.where((book) {
      return book.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(searchQuery.toLowerCase()) ||
          book.isbn.contains(searchQuery);
    }).toList();
    //  ─────────────── PAGE STRUCTURE ───────────────
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Books'),
      ),
      //  The main body of the page
      //  Shows either a "No books found" message or a scrollable list of books
      body: filteredBooks.isEmpty
          ? const Center(child: Text('No books found')) //  No matches found
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: filteredBooks.length,  // n books to display
        itemBuilder: (context, index) {
          final book = filteredBooks[index];
          //  ─────────────── INDIVIDUAL BOOK CARD ───────────────
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              //  Small box representing a placeholder book cover
              leading: Container(
                width: 50,
                height: 70,
                color: Colors.grey[300],
                child: const Icon(Icons.book),
              ),
              //  main title of the book
              title: Text(
                book.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              //  Subtitle section: author, owner, and book condition
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('by ${book.author}'),
                  Text('Owner: ${book.ownerName}'),
                  Text(
                    'Condition: ${book.condition}',
                    //  Changes text color based on book condition
                    style: TextStyle(
                      color: book.condition == 'Like New'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
              //  Right arrow icon for visual cue of navigation
              trailing: const Icon(Icons.chevron_right),
              //  When tapped, navigate to Book Details Page
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailsPage(book: book),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

//  ─────────────── BOOK DETAILS PAGE ───────────────
//  This page shows detailed information about a selected book
//  and allows users to borrow it if they meet the requirements
class BookDetailsPage extends StatelessWidget {
  //  The book object passed from the previous page (BooksAvailablePage)
  final Book book;

  const BookDetailsPage({Key? key, required this.book}) : super(key: key);

  //  ─────────────── BORROW BOOK FUNCTION ───────────────
  //  Handles the logic for borrowing a book
  //  Checks for sign-in status and credit balance before proceeding
  void _borrowBook(BuildContext context) {
    //  If the user is not signed in, show an alert asking them to log in
    if (currentUser == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Please Sign In'),
          content: const Text('You need to sign in to borrow books.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    //  If the user doesn't have enough credits, show a warning message
    if (currentUser!.credits < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient credits! Lend books to earn more.'),
        ),
      );
      return;
    }
    //  If all conditions are met, go to the Map Pickup Page
    //  This will simulate selecting a pickup location
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickupPage(book: book),
      ),
    );
  }
  //  ─────────────── MAIN UI ───────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  ─────────────── BOOK COVER PLACEHOLDER ───────────────
            Center(
              child: Container(
                width: 150,
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.book, size: 80),
              ),
            ),
            const SizedBox(height: 24),
            //  ─────────────── TITLE AND AUTHOR ───────────────
            Text(
              book.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'by ${book.author}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            //  ─────────────── BOOK DETAILS CARD ───────────────
            //  Displays the book’s ISBN, owner, condition, and optional notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('ISBN', book.isbn),
                    const Divider(),
                    _buildInfoRow('Owner', book.ownerName),
                    const Divider(),
                    _buildInfoRow('Condition', book.condition),
                    if (book.notes != null) ...[
                      const Divider(),
                      _buildInfoRow('Notes', book.notes!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            //  ─────────────── INFO CARD ABOUT BORROWING ───────────────
            Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Borrowing costs 50 credits for a semester-long loan',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //  ─────────────── BORROW BUTTON ───────────────
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _borrowBook(context),
                icon: const Icon(Icons.download),
                label: const Text('Borrow Book (50 Credits)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  //  ─────────────── HELPER FUNCTION ───────────────
  //  Builds a simple labeled row for displaying book information in the card
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

//  ─────────────── MAP PICKUP PAGE ───────────────
//  Allows the borrower to choose a pickup location for the book
//  Once confirmed, it creates a new transaction and deducts credits
class MapPickupPage extends StatefulWidget {
  final Book book;  //  The book that the user is borrowing

  const MapPickupPage({Key? key, required this.book}) : super(key: key);

  @override
  State<MapPickupPage> createState() => _MapPickupPageState();
}

class _MapPickupPageState extends State<MapPickupPage> {
  //  Stores the name of the selected pickup location
  String? selectedLocation;

  //  ─────────────── CONFIRM PICKUP FUNCTION ───────────────
  //  Validates selection and creates a transaction record for borrowing the book
  void _confirmPickup() {
    //  Check if user has selected a pickup location
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pickup location')),
      );
      return;
    }

    // Create transaction for the borrowed book
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(), //  unique ID
      book: widget.book,
      borrowerName: currentUser!.name,
      lenderName: widget.book.ownerName,
      startDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 120)), // ~4 months
      isBorrower: true,
    );

    //  Add the transaction to the mock data and deduct credits
    mockTransactions.add(transaction);
    currentUser!.credits -= 50;
    //  Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pickup set! Check your transactions.')),
    );
    //  Return to the home page (pop all previous routes)
    Navigator.popUntil(context, (route) => route.isFirst);
  }
  //  ─────────────── MAIN UI ───────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Pickup Location')),
      body: Column(
        children: [
          // Mock Map Area
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Stack(
                children: [
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 100, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Map Integration (Google Maps API)',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Tap to select pickup location',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (selectedLocation != null)
                    const Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Icon(
                          Icons.location_on,
                          size: 50,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          //  ─────────────── LOCATION OPTIONS AND CONFIRMATION AREA ───────────────
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select Pickup Point',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                //  ChoiceChips allow user to pick one location visually
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Library Entrance'),
                      selected: selectedLocation == 'Library',
                      onSelected: (selected) {
                        setState(() {
                          selectedLocation = selected ? 'Library' : null;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Student Center'),
                      selected: selectedLocation == 'Student Center',
                      onSelected: (selected) {
                        setState(() {
                          selectedLocation = selected ? 'Student Center' : null;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Cafeteria'),
                      selected: selectedLocation == 'Cafeteria',
                      onSelected: (selected) {
                        setState(() {
                          selectedLocation = selected ? 'Cafeteria' : null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                //  ─────────────── MOCK WEATHER CARD ───────────────
                //  Placeholder for weather integration
                Card(
                  color: Colors.amber[50],
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.wb_sunny, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Weather: Sunny, 22°C (Weather API)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                //  ─────────────── CONFIRM BUTTON ───────────────
                //  When pressed, validates and creates the transaction
                ElevatedButton(
                  onPressed: _confirmPickup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Confirm Pickup'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  ──────────────── TRANSACTIONS PAGE ────────────────
//  Displays all user transactions (both borrowed and lent books)
//  using two tabs: "Borrowed" and "Lending"
class TransactionsPage extends StatelessWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //  Separate all transactions into two lists based on role
    final borrowed = mockTransactions.where((t) => t.isBorrower).toList();
    final lending = mockTransactions.where((t) => !t.isBorrower).toList();
    //  DefaultTabController manages the two-tab interface
    return DefaultTabController(
      length: 2,  //  "Borrowed" and "Lending"
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Transactions'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.download), text: 'Borrowed'),
              Tab(icon: Icon(Icons.upload), text: 'Lending'),
            ],
          ),
        ),
        // TabBarView displays the content of each tab
        body: TabBarView(
          children: [
            //  First tab: Borrowed books
            _buildTransactionList(context, borrowed, true),
            //  Second tab: Books lent out
            _buildTransactionList(context, lending, false),
          ],
        ),
      ),
    );
  }
  //  ──────────────── TRANSACTION LIST BUILDER ────────────────
  //  Reusable method to build each list (borrowed or lending)
  Widget _buildTransactionList(
      BuildContext context, List<Transaction> transactions, bool isBorrower) {
    //  Show an empty state message if there are no transactions
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBorrower ? Icons.download : Icons.upload,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isBorrower
                  ? 'No books borrowed yet'
                  : 'No books lent out yet',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    //  ─────────────── LIST OF TRANSACTIONS ───────────────
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final daysLeft = transaction.dueDate.difference(DateTime.now()).inDays;
        final isOverdue = daysLeft < 0;
        //  ─────────────── INDIVIDUAL TRANSACTION CARD ───────────────
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  Book title and status chip (e.g., "3 days left" or "OVERDUE")
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.book.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    //  Only show chip if book is not yet returned
                    if (!transaction.isReturned)
                      Chip(
                        label: Text(
                          isOverdue
                              ? 'OVERDUE'
                              : '$daysLeft days left',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor:
                        isOverdue ? Colors.red : Colors.green,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('by ${transaction.book.author}'),
                const SizedBox(height: 8),
                //  Show whether the user is the borrower or lender
                Text(
                  isBorrower
                      ? 'Lender: ${transaction.lenderName}'
                      : 'Borrower: ${transaction.borrowerName}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                //  Due date display
                Text(
                  'Due: ${transaction.dueDate.toString().split(' ')[0]}',
                  style: const TextStyle(color: Colors.grey),
                ),
                //  ─────────────── MARK AS RETURNED BUTTON ───────────────
                if (!transaction.isReturned) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        //  Update the transaction state to "returned"
                        transaction.isReturned = true;
                        //  Reward lender with credits for successful return
                        if (!isBorrower) {
                          currentUser!.credits += 100;
                        }
                        //  Show confirmation message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isBorrower
                                  ? 'Book marked as returned'
                                  : 'Book marked as returned. +100 credits!',
                            ),
                          ),
                        );
                        //  Refresh the UI immediately
                        (context as Element).markNeedsBuild();
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark as Returned'),
                    ),
                  ),
                ],
                //  ─────────────── RETURNED STATUS CHIP ───────────────
                if (transaction.isReturned)
                  const Chip(
                    label: Text('Returned'),
                    backgroundColor: Colors.grey,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//  ──────────────── ADD BOOK PAGE ────────────────
//  Allows users to create and post a book listing to share with others.
//  Simulates taking a photo and scanning a barcode for ISBN input
class AddBookPage extends StatefulWidget {
  const AddBookPage({Key? key}) : super(key: key);

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  //  ──────────────── FORM CONTROLLERS ────────────────
  final _formKey = GlobalKey<FormState>();
  final _isbnController = TextEditingController();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _notesController = TextEditingController();
  //  Default book condition and photo placeholder
  String _condition = 'Good';
  String? _photoUrl;
  //  ──────────────── BARCODE SCANNER (SIMULATED) ────────────────
  void _scanBarcode() {
    // Simulate barcode scanning
    setState(() {
      _isbnController.text = '978${DateTime
          .now()
          .millisecondsSinceEpoch % 10000000000}';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barcode scanned! (Barcode scanner integration needed)'),
      ),
    );
  }
  //  ──────────────── TAKE PHOTO (SIMULATED) ────────────────
  void _takePhoto() {
    setState(() {
      _photoUrl = 'book_photo';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo captured!')),
    );
  }
  //  ──────────────── SUBMIT NEW BOOK LISTING ────────────────
  void _submitBook() {
    if (_formKey.currentState!.validate()) {
      //  Create a new Book object using form inputs
      final newBook = Book(
        id: DateTime
            .now()
            .millisecondsSinceEpoch
            .toString(),
        isbn: _isbnController.text,
        title: _titleController.text,
        author: _authorController.text,
        ownerName: currentUser!.name,
        photoUrl: _photoUrl,
        condition: _condition,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      //  Add the new book to mock data list (temporary storage)
      mockBooks.add(newBook);
      //  Confirmation message for user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
            'Listing posted! You earn 100 credits when someone borrows it.')),
      );
      //  Return to previous screen after posting
      Navigator.pop(context);
    }
  }
  //  ──────────────── PAGE UI ────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List a Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //  Photo Section
              Center(
                child: GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: 150,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _photoUrl == null
                        ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 48),
                        SizedBox(height: 8),
                        Text('Add Book Photo'),
                      ],
                    )
                        : const Icon(Icons.book, size: 80),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              //  ISBN with Barcode Scanner
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _isbnController,
                      decoration: const InputDecoration(
                        labelText: 'ISBN',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ISBN';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _scanBarcode,
                    icon: const Icon(Icons.qr_code_scanner),
                    iconSize: 32,
                    tooltip: 'Scan Barcode',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              //  Book title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Book Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter book title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              //  Author Field
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter author name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              //  Condition Dropdown
              DropdownButtonFormField<String>(
                value: _condition,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star),
                ),
                items: ['Like New', 'Good', 'Fair', 'Poor']
                    .map((condition) =>
                    DropdownMenuItem(
                      value: condition,
                      child: Text(condition),
                    ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _condition = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              //  Optional notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                  helperText: 'Any additional information about the book',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              //  Info Card
              Card(
                color: Colors.green[50],
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You earn 100 credits when someone borrows your book!',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              //  Submit button
              ElevatedButton.icon(
                onPressed: _submitBook,
                icon: const Icon(Icons.publish),
                label: const Text('Post Listing'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}