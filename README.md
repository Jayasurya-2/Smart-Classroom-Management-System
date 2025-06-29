
# 📚 Smart Classroom Management System

A role-based web application built to enhance online education by providing tailored dashboards for Students, Faculty, and Admins. This system empowers faculty to manage courses, students to engage with learning content and assessments, and admins to oversee the platform—all in one place.

## ✨ Features

The Smart Classroom Management System offers a complete suite of features tailored for seamless educational experiences. Each user role—Student, Faculty, and Admin—has distinct functionalities to ensure smooth operation and collaboration.

### 👨‍🏫 Faculty Features
- Faculty registration and authentication
- Create, edit, and manage multiple courses
- Schedule live classes (integrate with platforms like Zoom/Meet)
- Upload and organize course materials (PDFs, docs, videos)
- Approve or reject student enrollment requests
- Conduct and manage online tests (MCQs and written)
- Analyze individual and batch-level student performance
- Chat system for private student-faculty interaction
- Classroom group discussion forums

### 👨‍🎓 Student Features
- Student account creation and login
- Browse available courses and send enrollment requests
- Access course content after faculty approval
- Participate in live classes and download materials
- Attempt time-bound online tests with auto-submit feature
- Track test scores and performance metrics
- Communicate with faculty through chat

### 🛡️ Admin Features
- Full control over the platform
- Monitor total users, courses, and active enrollments
- View test results, performance reports, and analytics
- Access all user dashboards and logs for auditing

## 🚀 Getting Started

Follow these instructions to set up and run the Smart Classroom Management System locally using Eclipse, Apache Tomcat, and Oracle Database.

### 📋 Prerequisites

Make sure the following software is installed on your machine:

* 🔧 Java Development Kit (JDK) 21
* 💻 Eclipse IDE for Enterprise Java Developers
* 🌐 Apache Tomcat Server v11
* 🗃️ Oracle Database (Oracle 11g/12c or above)
* 🔌 Oracle JDBC Driver (already included in the project)
* 🧰 Git (optional, for cloning the repository)

### 📦 Project Setup in Eclipse

* Clone or Download the Repository

```bash
git clone https://github.com/Jayasurya-2/Smart-Classroom-Management-System.git
```

* Open Eclipse
   * Launch Eclipse IDE and switch to the Java EE or Enterprise perspective.

* Import the Project as a Dynamic Web Project
   * Go to: File → Import → Existing Projects into Workspace
   * Browse and select the project root folder (e.g., Smart-Classroom-Management-System)
   * Make sure the project type is recognized as a Dynamic Web Project
   * Click Finish

* Configure Apache Tomcat Server
   * Go to: Window → Preferences → Server → Runtime Environments
   * Click Add, select Apache Tomcat v11, and provide the Tomcat installation directory
   * Right-click the project → Properties → Targeted Runtimes → Check Apache Tomcat v11

* Add JDBC Driver to Build Path (if not already added)
   * Right-click lib folder (or where JDBC driver is located) → Build Path → Add to Build Path

## 🛠️ Tech Stack

🔹 **Frontend**
- HTML5, CSS3, and JavaScript – For creating responsive and interactive user interfaces.
- Bootstrap – A front-end framework for designing mobile-first, responsive layouts.

🔹 **Backend**
- Java – Core business logic implemented using Java.
- Java Servlets & JSP (JavaServer Pages) – For dynamic web content generation and request handling.

🔹 **Database**
- Oracle Database – Robust relational database system used for storing all application data.
- SQL – For schema definitions, queries, triggers, and data manipulation.

🔹 **Server & Runtime**
- Apache Tomcat 11 – Servlet container and web server used to deploy and run the application.
- JDK 21 – Java Development Kit version used for compiling and running Java-based components.

🔹 **Tools & Libraries**
- JDBC – Java Database Connectivity for interacting with Oracle Database.
- SQL Developer – For managing and querying the Oracle database.
- Eclipse IDE – Integrated Development Environment for building and maintaining the application.

## 📸 Screenshots

- 👨‍🎓 Student Dashboard  
  https://i.postimg.cc/LX7kBBM9/SIH-1625-sc-1.png  
  https://i.postimg.cc/ry0NybSK/SIH-1625-sc-2.png

- 👨‍🏫 Faculty Dashboard  
  https://i.postimg.cc/G29JygVg/SIH-1625-sc-3.png  
  https://i.postimg.cc/6qvrH29d/SIH-1625-sc-4.png

- 🛠 Admin Dashboard  
  https://i.postimg.cc/fWfqJ8X4/SIH-1625-sc-5.png

## 📂 Project Structure

    Smart-Classroom-Management-System/
    ├── Deployment Descriptor: Smart Classroom Management
    ├── JAX-WS Web Services
    ├── Java Resources
    │   └── src/
    │       └── main/
    │           └── java/
    │               └── com/
    │                   └── servlet/
    │                       ├── auth/
    │                       │   └── LoginServlet.java
    │                       ├── SignupServlet/
    │                       │   └── RegisterServlet.java
    │                       ├── CreateCourseServlet.java
    │                       ├── CreateMCQTestServlet.java
    │                       ├── DownloadMaterialServlet.java
    │                       ├── DownloadResultsServlet.java
    │                       ├── ErrorResponse.java
    │                       ├── FacultyDownloadResultsServlet.java
    │                       ├── FacultyResultsServlet.java
    │                       ├── FetchMessagesServlet.java
    │                       ├── FetchStudentsServlet.java
    │                       ├── FetchUsersServlet.java
    │                       ├── GetStudentDetailsServlet.java
    │                       ├── GetTasksServlet.java
    │                       ├── LogoutServlet.java
    │                       ├── ManageCourseServlet.java
    │                       ├── ManageEnrollmentServlet.java
    │                       ├── ManageUserServlet.java
    │                       ├── RequestEnrollmentServlet.java
    │                       ├── ResultsServlet.java
    │                       ├── ScheduleLiveClassServlet.java
    │                       ├── SendMessageServlet.java
    │                       ├── SubmitMCQTestServlet.java
    │                       ├── TakeMCQTestServlet.java
    │                       └── UploadMaterialServlet.java
    ├── build/
    ├── webapp/
    │   ├── asserts/
    │   ├── META-INF/
    │   ├── Uploads/
    │   ├── WEB-INF/
    │   │   ├── lib/
    │   │   └── web.xml
    │   ├── about.html
    │   ├── adminDashboard.jsp
    │   ├── courseDetails.jsp
    │   ├── createCourse.jsp
    │   ├── facultyDashboard.jsp
    │   ├── faqs.html
    │   ├── features.html
    │   ├── getClassroomPosts.jsp
    │   ├── getMessages.jsp
    │   ├── getProfile.jsp
    │   ├── index.css
    │   ├── index.jsp
    │   ├── login.css
    │   ├── login.jsp
    │   ├── manageQuestions.jsp
    │   ├── profile.jsp
    │   ├── registerFace.jsp
    │   ├── studentDashboard.jsp
    │   ├── style.css
    │   └── takeTest.jsp

## 📘 Database Setup

This project includes a full database schema to support the Smart Classroom Management System, implemented for Oracle SQL.

The schema defines users, roles, course management, MCQ testing, enrollment, results, and learning materials — all with built-in triggers to automate key logic.

### 📥 Download the SQL File

You can download or view the SQL setup script here:  
[📥 SmartClassroom_Setup.sql](https://raw.githubusercontent.com/Jayasurya-2/Smart-Classroom-Management-System/main/database/SmartClassroom_Setup.sql)

## 🙋‍♂️ Author

**Jaya Surya Puralasetti**  
👨‍💻 Full Stack Developer | Web Application Enthusiast  

📧 Email: [jayasuryapuralasetti@gmail.com](mailto:jayasuryapuralasetti@gmail.com)  
🔗 GitHub: [@Jayasurya-2](https://github.com/Jayasurya-2)  
💼 LinkedIn: [jaya-surya-puralasetti](https://www.linkedin.com/in/jaya-surya-puralasetti/)  
