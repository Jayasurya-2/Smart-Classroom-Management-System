<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - JAAS Institute</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300..700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css" rel="stylesheet">
    <style>
        body { font-family: "Space Grotesk", sans-serif; background-color: #f0faff; color: #333; }
        .dashboard-header { background-color: #4070f4; color: #fff; padding: 30px; text-align: center; }
        .sidebar { width: 280px; background-color: #f8f9fa; transition: transform 0.3s ease; position: fixed; top: 0; left: 0; height: 100%; z-index: 1000; overflow-y: auto; }
        .sidebar.collapsed { transform: translateX(-280px); }
        .hamburger { font-size: 24px; cursor: pointer; position: fixed; top: 20px; left: 20px; z-index: 1100; color: #4070f4; background: none; border: none; }
        .hamburger:hover { color: #3050d0; }
        .content-wrapper { margin-left: 280px; transition: margin-left 0.3s ease; padding: 20px; min-height: 100vh; width: calc(100% - 280px); box-sizing: border-box; }
        .content-wrapper.expanded { margin-left: 0; width: 100%; }
        .profile-icon { width: 40px; height: 40px; border-radius: 50%; cursor: pointer; transition: transform 0.2s ease; }
        .profile-icon:hover { transform: scale(1.1); }
        .dropdown-menu { display: none; position: absolute; right: 0; background-color: #fff; min-width: 180px; box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.15); border-radius: 8px; z-index: 100; padding: 10px 0; text-align: left; }
        .dropdown-menu.show { display: block; }
        .dropdown-menu span, .dropdown-menu a { display: block; padding: 10px 15px; text-decoration: none; color: #333; font-size: 16px; font-family: "Space Grotesk", sans-serif; transition: background-color 0.3s ease, color 0.3s ease; }
        .dropdown-menu span { font-weight: 500; color: #4070f4; border-bottom: 1px solid #f0f0f0; }
        .dropdown-menu a { color: #555; }
        .dropdown-menu a:hover { background-color: #4070f4; color: #fff; }
        .form-section { background-color: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); margin-bottom: 20px; display: none; width: 100%; }
        .form-section.active { display: block; }
        .btn-custom { background-color: #4070f4; color: #fff; padding: 8px 16px; border-radius: 5px; text-decoration: none; }
        .btn-custom:hover { background-color: #3050d0; }
        .table { margin-top: 20px; width: 100%; table-layout: auto; }
        .table th, .table td { padding: 12px; text-align: left; white-space: nowrap; vertical-align: middle; }
        .table th { background-color: #f8f9fa; font-weight: 500; }
        #calendar-container { position: fixed; bottom: 20px; right: 20px; z-index: 1000; }
        #calendar { width: 400px; max-height: 400px; background-color: #fff; border-radius: 10px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); padding: 10px; overflow-y: auto; transition: max-height 0.3s ease; }
        #calendar.collapsed { max-height: 40px; overflow: hidden; }
        #calendar-toggle { background-color: #4070f4; color: #fff; border: none; padding: 5px 10px; border-radius: 5px; cursor: pointer; margin-bottom: 5px; }
        #calendar-toggle:hover { background-color: #3050d0; }
        .fc-event { font-size: 12px; padding: 2px 5px; }
        .fc-daygrid-day { height: 50px; }
        .modal-content { font-family: "Space Grotesk", sans-serif; }
        .filter-form { margin-bottom: 20px; }
        .button-group { display: flex; align-items: center; gap: 10px; }
        .filter-info { margin-bottom: 15px; padding: 10px; background-color: #f8f9fa; border-radius: 5px; }
        .me-2 { margin-right: 10px; }
        .chat-container { display: none; height: 80vh; width: 100%; max-width: 1200px; margin: 0 auto; }
        .chat-container.show { display: flex; }
        .chat-sidebar { width: 30%; background-color: #f8f9fa; border-right: 1px solid #ddd; overflow-y: auto; height: 100%; }
        .chat-content { width: 70%; padding: 20px; background-color: #e5ddd5; height: 100%; position: relative; }
        .chat-messages { height: calc(100% - 60px); overflow-y: auto; padding: 10px; }
        .message { margin-bottom: 10px; padding: 10px; border-radius: 5px; max-width: 70%; }
        .sent { background-color: #dcf8c6; margin-left: auto; }
        .received { background-color: #fff; }
        .timestamp { font-size: 12px; color: #666; }
        .no-messages { text-align: center; color: #666; }
        .chat-input { position: absolute; bottom: 0; width: 100%; padding: 10px; background-color: #f0faff; display: flex; }
        .chat-input input { flex: 1; border: none; background: transparent; outline: none; font-family: "Space Grotesk", sans-serif; color: #333; }
        .chat-input button { background-color: #075e54; color: #fff; border: none; padding: 5px 15px; border-radius: 5px; cursor: pointer; }
        .chat-input button:hover { background-color: #054d44; }
        .course-item { padding: 10px; cursor: pointer; }
        .course-item:hover { background-color: #e0e0e0; }
        .user-item { padding: 10px; cursor: pointer; border-bottom: 1px solid #ddd; }
        .user-item:hover { background-color: #e0e0e0; }
        @media (max-width: 768px) {
            .sidebar { transform: translateX(-280px); }
            .sidebar.collapsed { transform: translateX(0); }
            .content-wrapper { margin-left: 0; width: 100%; padding: 10px; }
            #calendar-container { width: 100%; right: 0; bottom: 0; }
            #calendar { width: 100%; max-height: 300px; }
            #calendar.collapsed { max-height: 40px; }
            .table { font-size: 14px; }
            .table th, .table td { padding: 8px; }
            .button-group { flex-direction: column; gap: 8px; }
            .btn-custom { width: 100%; text-align: center; }
            .chat-container { flex-direction: column; height: 80vh; }
            .chat-sidebar { width: 100%; height: 30%; }
            .chat-content { width: 100%; height: 70%; }
        }
    </style>
</head>
<body>
    <header class="d-flex flex-wrap align-items-center justify-content-between py-3 mb-4 border-bottom">
        <div class="col-md-3 mb-2 mb-md-0">
            <a href="adminDashboard.jsp" class="d-inline-flex link-body-emphasis text-decoration-none">
                <span class="fs-4 fw-bold">JAAS Institute</span>
            </a>
        </div>
        <div class="col-md-3 text-end">
            <div class="dropdown">
                <img src="<%= request.getContextPath() %>/asserts/default-profile.png" id="profileIcon" alt="Profile" class="profile-icon" onclick="toggleDropdown()">
                <div class="dropdown-menu" id="dropdownMenu">
                    <span>Welcome, <%= session.getAttribute("name") != null ? session.getAttribute("name") : "Admin" %></span>
                    <a href="profile.jsp">My Profile</a>
                    <a href="#" onclick="logout()">Logout</a>
                </div>
            </div>
        </div>
    </header>

    <button class="hamburger" onclick="toggleSidebar()">☰</button>

    <div class="d-flex min-vh-100">
        <div class="sidebar d-flex flex-column flex-shrink-0 p-3 bg-light" id="sidebar">
            <a href="adminDashboard.jsp" class="d-flex align-items-center mb-3 mb-md-0 me-md-auto link-body-emphasis text-decoration-none">
                <span class="fs-4">Admin Menu</span>
            </a>
            <hr>
            <ul class="nav nav-pills flex-column mb-auto">
                <li class="nav-item"><a href="#overview" class="nav-link" onclick="showSection('overview')">Overview</a></li>
                <li class="nav-item"><a href="#totalStudents" class="nav-link" onclick="showSection('totalStudents')">Total Students</a></li>
                <li class="nav-item"><a href="#totalFaculty" class="nav-link" onclick="showSection('totalFaculty')">Total Faculty</a></li>
                <li class="nav-item"><a href="#totalCourses" class="nav-link" onclick="showSection('totalCourses')">Total Courses</a></li>
                <li class="nav-item"><a href="#totalTests" class="nav-link" onclick="showSection('totalTests')">Total Tests</a></li>
                <li class="nav-item"><a href="#results" class="nav-link" onclick="showSection('results')">Results</a></li>
                <li class="nav-item"><a href="#queries" class="nav-link" onclick="showSection('queries')">Queries</a></li>
            </ul>
        </div>

        <div class="content-wrapper" id="contentWrapper">
            <div class="dashboard-header">
                <h1>Welcome, <%= session.getAttribute("name") != null ? session.getAttribute("name") : "Admin" %>!</h1>
                <p>Your Admin Dashboard</p>
            </div>

            <!-- Feedback Message -->
            <% 
                String message = (String) request.getAttribute("message");
                String messageType = (String) request.getAttribute("messageType");
                if (message != null) {
            %>
                <div class="alert <%= messageType.equals("success") ? "alert-success" : messageType.equals("info") ? "alert-info" : "alert-danger" %>" role="alert">
                    <%= message %>
                </div>
            <% } %>

            <div id="overview" class="form-section active">
                <h2>Overview</h2>
                <div class="row">
                    <%
                        try (Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123")) {
                            Class.forName("oracle.jdbc.driver.OracleDriver");
                            try (PreparedStatement psStudents = con.prepareStatement("SELECT COUNT(*) FROM Users WHERE LOWER(ROLE) = 'student'");
                                 ResultSet rsStudents = psStudents.executeQuery()) {
                                rsStudents.next();
                                int totalStudents = rsStudents.getInt(1);
                    %>
                    <div class="col-md-3">
                        <div class="card text-center">
                            <div class="card-body">
                                <h5 class="card-title">Total Students</h5>
                                <p class="card-text"><%= totalStudents %></p>
                                <button class="btn btn-custom" onclick="showSection('totalStudents')">View Details</button>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                            try (PreparedStatement psFaculty = con.prepareStatement("SELECT COUNT(*) FROM Users WHERE LOWER(ROLE) = 'faculty'");
                                 ResultSet rsFaculty = psFaculty.executeQuery()) {
                                rsFaculty.next();
                                int totalFaculty = rsFaculty.getInt(1);
                    %>
                    <div class="col-md-3">
                        <div class="card text-center">
                            <div class="card-body">
                                <h5 class="card-title">Total Faculty</h5>
                                <p class="card-text"><%= totalFaculty %></p>
                                <button class="btn btn-custom" onclick="showSection('totalFaculty')">View Details</button>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                            try (PreparedStatement psCourses = con.prepareStatement("SELECT COUNT(*) FROM Courses");
                                 ResultSet rsCourses = psCourses.executeQuery()) {
                                rsCourses.next();
                                int totalCourses = rsCourses.getInt(1);
                    %>
                    <div class="col-md-3">
                        <div class="card text-center">
                            <div class="card-body">
                                <h5 class="card-title">Total Courses</h5>
                                <p class="card-text"><%= totalCourses %></p>
                                <button class="btn btn-custom" onclick="showSection('totalCourses')">View Details</button>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                            try (PreparedStatement psTests = con.prepareStatement("SELECT COUNT(*) FROM Mcq_Tests");
                                 ResultSet rsTests = psTests.executeQuery()) {
                                rsTests.next();
                                int totalTests = rsTests.getInt(1);
                    %>
                    <div class="col-md-3">
                        <div class="card text-center">
                            <div class="card-body">
                                <h5 class="card-title">Total Tests</h5>
                                <p class="card-text"><%= totalTests %></p>
                                <button class="btn btn-custom" onclick="showSection('totalTests')">View Details</button>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                    %>
                    <div class="col-12"><p class="text-danger">Error fetching overview data: <%= e.getMessage() %></p></div>
                    <%
                        }
                    %>
                </div>
            </div>

            <div id="totalStudents" class="form-section">
                <h2>Total Students</h2>
                <table class="table table-striped table-bordered">
                    <thead><tr><th>Name</th><th>Email</th><th>Role</th></tr></thead>
                    <tbody>
                        <%
                            try (Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                                 PreparedStatement ps = con.prepareStatement("SELECT NAME, EMAIL, ROLE FROM Users WHERE LOWER(ROLE) = 'student'");
                                 ResultSet rs = ps.executeQuery()) {
                                Class.forName("oracle.jdbc.driver.OracleDriver");
                                if (!rs.isBeforeFirst()) {
                                    out.println("<tr><td colspan='3'>No students found.</td></tr>");
                                }
                                while (rs.next()) {
                                    String name = rs.getString("NAME");
                                    String email = rs.getString("EMAIL");
                                    String role = rs.getString("ROLE");
                        %>
                        <tr>
                            <td><a href="javascript:void(0)" onclick="showProfile('<%= email %>', 'student')"><%= name != null ? name : "N/A" %></a></td>
                            <td><%= email %></td>
                            <td><%= role %></td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                        %>
                        <tr><td colspan="3">Error: <%= e.getMessage() %></td></tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <div id="totalFaculty" class="form-section">
                <h2>Total Faculty</h2>
                <table class="table table-striped table-bordered">
                    <thead><tr><th>Name</th><th>Email</th><th>Role</th></tr></thead>
                    <tbody>
                        <%
                            try (Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                                 PreparedStatement ps = con.prepareStatement("SELECT NAME, EMAIL, ROLE FROM Users WHERE LOWER(ROLE) = 'faculty'");
                                 ResultSet rs = ps.executeQuery()) {
                                Class.forName("oracle.jdbc.driver.OracleDriver");
                                if (!rs.isBeforeFirst()) {
                                    out.println("<tr><td colspan='3'>No faculty found.</td></tr>");
                                }
                                while (rs.next()) {
                                    String name = rs.getString("NAME");
                                    String email = rs.getString("EMAIL");
                                    String role = rs.getString("ROLE");
                        %>
                        <tr>
                            <td><a href="javascript:void(0)" onclick="showProfile('<%= email %>', 'faculty')"><%= name != null ? name : "N/A" %></a></td>
                            <td><%= email %></td>
                            <td><%= role %></td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                        %>
                        <tr><td colspan="3">Error: <%= e.getMessage() %></td></tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <div id="totalCourses" class="form-section">
                <h2>Total Courses</h2>
                <table class="table table-striped table-bordered">
                    <thead><tr><th>Course ID</th><th>Course Name</th><th>Faculty Email</th><th>Description</th><th>Created At</th></tr></thead>
                    <tbody>
                        <%
                            try (Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                                 PreparedStatement ps = con.prepareStatement("SELECT COURSE_ID, COURSE_NAME, FACULTY_EMAIL, DESCRIPTION, CREATED_AT FROM Courses");
                                 ResultSet rs = ps.executeQuery()) {
                                Class.forName("oracle.jdbc.driver.OracleDriver");
                                if (!rs.isBeforeFirst()) {
                                    out.println("<tr><td colspan='5'>No courses found.</td></tr>");
                                }
                                while (rs.next()) {
                                    int courseId = rs.getInt("COURSE_ID");
                                    String courseName = rs.getString("COURSE_NAME");
                                    String facultyEmail = rs.getString("FACULTY_EMAIL");
                                    String description = rs.getString("DESCRIPTION");
                                    Timestamp createdAt = rs.getTimestamp("CREATED_AT");
                        %>
                        <tr>
                            <td><%= courseId %></td>
                            <td><%= courseName %></td>
                            <td><%= facultyEmail != null ? facultyEmail : "N/A" %></td>
                            <td><%= description != null ? description : "N/A" %></td>
                            <td><%= createdAt %></td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                        %>
                        <tr><td colspan="5">Error: <%= e.getMessage() %></td></tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <div id="totalTests" class="form-section">
                <h2>Total Tests</h2>
                <table class="table table-striped table-bordered">
                    <thead><tr><th>Test ID</th><th>Test Name</th><th>Course ID</th><th>Faculty Email</th><th>Created At</th><th>Schedule Time</th><th>End Time</th><th>Avg Score</th><th>Avg Percentage</th></tr></thead>
                    <tbody>
                        <%
                            try (Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123")) {
                                Class.forName("oracle.jdbc.driver.OracleDriver");
                                try (PreparedStatement psTests = con.prepareStatement("SELECT TEST_ID, TEST_NAME, COURSE_ID, FACULTY_EMAIL, CREATED_AT, SCHEDULE_TIME, END_TIME FROM Mcq_Tests");
                                     ResultSet rsTests = psTests.executeQuery()) {
                                    if (!rsTests.isBeforeFirst()) {
                                        out.println("<tr><td colspan='9'>No tests found.</td></tr>");
                                    }
                                    while (rsTests.next()) {
                                        int testId = rsTests.getInt("TEST_ID");
                                        String testName = rsTests.getString("TEST_NAME");
                                        int courseId = rsTests.getInt("COURSE_ID");
                                        String facultyEmail = rsTests.getString("FACULTY_EMAIL");
                                        Timestamp createdAt = rsTests.getTimestamp("CREATED_AT");
                                        Timestamp scheduleTime = rsTests.getTimestamp("SCHEDULE_TIME");
                                        Timestamp endTime = rsTests.getTimestamp("END_TIME");

                                        try (PreparedStatement psScore = con.prepareStatement("SELECT AVG(SCORE), COUNT(*) FROM Results WHERE TEST_ID = ?")) {
                                            psScore.setInt(1, testId);
                                            try (ResultSet rsScore = psScore.executeQuery()) {
                                                String avgScore = "N/A";
                                                String avgPercentage = "N/A";
                                                if (rsScore.next()) {
                                                    int submissionCount = rsScore.getInt(2);
                                                    if (submissionCount > 0) {
                                                        double avg = rsScore.getDouble(1);
                                                        avgScore = String.format("%.2f", avg);
                                                        try (PreparedStatement psQuestions = con.prepareStatement("SELECT COUNT(*) FROM Mcq_Questions WHERE TEST_ID = ?")) {
                                                            psQuestions.setInt(1, testId);
                                                            try (ResultSet rsQuestions = psQuestions.executeQuery()) {
                                                                if (rsQuestions.next()) {
                                                                    int totalQuestions = rsQuestions.getInt(1);
                                                                    if (totalQuestions > 0) {
                                                                        double percentage = (avg / totalQuestions) * 100;
                                                                        avgPercentage = String.format("%.2f%%", percentage);
                                                                    } else {
                                                                        avgPercentage = "No Questions";
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        avgScore = "No Submissions";
                                                        avgPercentage = "No Submissions";
                                                    }
                                                }
                        %>
                        <tr>
                            <td><%= testId %></td>
                            <td><%= testName %></td>
                            <td><%= courseId %></td>
                            <td><%= facultyEmail != null ? facultyEmail : "N/A" %></td>
                            <td><%= createdAt %></td>
                            <td><%= scheduleTime != null ? scheduleTime : "N/A" %></td>
                            <td><%= endTime != null ? endTime : "N/A" %></td>
                            <td><%= avgScore %></td>
                            <td><%= avgPercentage %></td>
                        </tr>
                        <%
                                            }
                                        }
                                    }
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                        %>
                        <tr><td colspan="9">Error: <%= e.getMessage() %></td></tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <!-- Results Section -->
            <div id="results" class="form-section">
                <h2>Test Results</h2>
                <form action="ResultsServlet" method="get" class="filter-form">
                    <div class="row">
                        <div class="col-md-3">
                            <select name="courseId" id="courseSelect" class="form-select" onchange="updateTestOptions()">
                                <option value="">Select Course</option>
                                <%
                                    String selectedCourseId = (String) session.getAttribute("courseId");
                                    Map<Integer, String> courseMap = new HashMap<>();
                                    try (Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                                         PreparedStatement ps = con.prepareStatement("SELECT COURSE_ID, COURSE_NAME FROM Courses");
                                         ResultSet rs = ps.executeQuery()) {
                                        while (rs.next()) {
                                            int courseId = rs.getInt("COURSE_ID");
                                            String courseName = rs.getString("COURSE_NAME");
                                            courseMap.put(courseId, courseName);
                                %>
                                <option value="<%= courseId %>" <%= courseId == (selectedCourseId != null ? Integer.parseInt(selectedCourseId) : -1) ? "selected" : "" %>><%= courseName %></option>
                                <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                %>
                                <option value="">Error loading courses</option>
                                <%
                                    }
                                %>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select name="testId" id="testSelect" class="form-select">
                                <option value="">Select Test</option>
                                <%
                                    String selectedTestId = (String) session.getAttribute("testId");
                                    if (selectedCourseId != null && !selectedCourseId.isEmpty()) {
                                        try (Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                                             PreparedStatement ps = con.prepareStatement("SELECT TEST_ID, TEST_NAME FROM Mcq_Tests WHERE COURSE_ID = ?")) {
                                            ps.setInt(1, Integer.parseInt(selectedCourseId));
                                            ResultSet rs = ps.executeQuery();
                                            while (rs.next()) {
                                                int testId = rs.getInt("TEST_ID");
                                                String testName = rs.getString("TEST_NAME");
                                %>
                                <option value="<%= testId %>" <%= testId == (selectedTestId != null ? Integer.parseInt(selectedTestId) : -1) ? "selected" : "" %>><%= testName %></option>
                                <%
                                            }
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                %>
                                <option value="">Error loading tests</option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select name="attemptStatus" class="form-select">
                                <%
                                    String selectedAttemptStatus = (String) session.getAttribute("attemptStatus");
                                %>
                                <option value="all" <%= "all".equals(selectedAttemptStatus) ? "selected" : "" %>>All Students</option>
                                <option value="attempted" <%= "attempted".equals(selectedAttemptStatus) ? "selected" : "" %>>Attempted</option>
                                <option value="not_attempted" <%= "not_attempted".equals(selectedAttemptStatus) ? "selected" : "" %>>Not Attempted</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <div class="button-group">
                                <button type="submit" class="btn btn-custom me-2">Fetch Results</button>
                                <a href="DownloadResultsServlet" id="downloadLink" class="btn btn-custom" style="display:none;">Download CSV</a>
                            </div>
                        </div>
                    </div>
                </form>

                <!-- Display Selected Filters -->
                <%
                    if (selectedCourseId != null && !selectedCourseId.isEmpty()) {
                        String courseName = courseMap.get(Integer.parseInt(selectedCourseId));
                        String testName = "";
                        if (selectedTestId != null && !selectedTestId.isEmpty()) {
                            try (Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                                 PreparedStatement ps = con.prepareStatement("SELECT TEST_NAME FROM Mcq_Tests WHERE TEST_ID = ?")) {
                                ps.setInt(1, Integer.parseInt(selectedTestId));
                                ResultSet rs = ps.executeQuery();
                                if (rs.next()) {
                                    testName = rs.getString("TEST_NAME");
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                        String statusLabel = selectedAttemptStatus != null ? 
                            (selectedAttemptStatus.equals("all") ? "All Students" : 
                             selectedAttemptStatus.equals("attempted") ? "Attempted" : "Not Attempted") : "N/A";
                %>
                <div class="filter-info">
                    <strong>Selected Filters:</strong> 
                    Course: <%= courseName != null ? courseName : "N/A" %>, 
                    Test: <%= testName.isEmpty() ? "N/A" : testName %>, 
                    Status: <%= statusLabel %>
                </div>
                <%
                    }
                %>

                <table class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th>Student Name</th>
                            <th>Email</th>
                            <th>Course Name</th>
                            <th>Test Name</th>
                            <th>Score</th>
                            <th>Percentage</th>
                            <th>Submitted At</th>
                        </tr>
                    </thead>
                    <tbody id="resultsTable">
                        <%
                            List<Map<String, String>> results = (List<Map<String, String>>) request.getAttribute("results");
                            if (results != null && !results.isEmpty()) {
                                for (Map<String, String> result : results) {
                        %>
                        <tr>
                            <td><%= result.get("studentName") %></td>
                            <td><%= result.get("email") %></td>
                            <td><%= result.get("courseName") %></td>
                            <td><%= result.get("testName") %></td>
                            <td><%= result.get("score") %></td>
                            <td><%= result.get("percentage") %></td>
                            <td><%= result.get("submittedAt") %></td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr><td colspan="7">No results found.</td></tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <!-- Queries Section -->
            <div id="queries" class="form-section">
                <h2>Queries</h2>
                <h3>All Courses</h3>
                <%
                    Connection conQueries = null;
                    try {
                        Class.forName("oracle.jdbc.driver.OracleDriver");
                        conQueries = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                        PreparedStatement psCourses = conQueries.prepareStatement("SELECT COURSE_ID, COURSE_NAME FROM Courses");
                        ResultSet rsCourses = psCourses.executeQuery();
                        while (rsCourses.next()) {
                            int courseId = rsCourses.getInt("COURSE_ID");
                            String courseName = rsCourses.getString("COURSE_NAME");
                %>
                <div class="course-item" onclick="openCourse('<%= courseId %>', '<%= courseName %>')">
                    <%= courseName %>
                </div>
                <%
                        }
                        rsCourses.close();
                        psCourses.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<p class='text-danger'>Error fetching courses: " + e.getMessage() + "</p>");
                    } finally {
                        if (conQueries != null) {
                            try {
                                conQueries.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        }
                    }
                %>
                <div id="chatContainer" class="chat-container">
                    <div class="chat-sidebar" id="userList"></div>
                    <div class="chat-content">
                        <h4 id="chatHeader">Chat with <span id="chatUser"></span></h4>
                        <input type="hidden" id="receiverEmail" name="receiverEmail">
                        <div id="chatMessages" class="chat-messages"></div>
                        <div class="chat-input">
                            <input type="text" id="messageInput" class="form-control" placeholder="Type your message..." required>
                            <button type="button" onclick="sendMessage()">Send</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="calendar-container">
        <button id="calendar-toggle" onclick="toggleCalendar()">Toggle Calendar</button>
        <div id="calendar" class="collapsed"></div>
    </div>

    <div class="modal fade" id="profileModal" tabindex="-1" aria-labelledby="profileModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="profileModalLabel">User Profile</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="profileContent"></div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-custom" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" defer></script>
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js" defer></script>
    <script>
        function toggleDropdown() {
            document.getElementById("dropdownMenu").classList.toggle("show");
        }

        function logout() {
            fetch('<%= request.getContextPath() %>/LogoutServlet', { method: 'GET' })
                .then(response => {
                    if (!response.ok) throw new Error('Logout failed');
                    window.location.href = "<%= request.getContextPath() %>/index.jsp";
                })
                .catch(error => {
                    console.error('Logout error:', error);
                    alert('Logout failed');
                });
        }

        function toggleSidebar() {
            const sidebar = document.getElementById("sidebar");
            const contentWrapper = document.getElementById("contentWrapper");
            sidebar.classList.toggle("collapsed");
            contentWrapper.classList.toggle("expanded");
        }

        function showSection(sectionId) {
            const sections = document.querySelectorAll('.form-section');
            sections.forEach(section => {
                section.classList.toggle('active', section.id === sectionId);
            });
            if (sectionId === 'queries') {
                document.getElementById('chatContainer').classList.add('show');
            } else {
                document.getElementById('chatContainer').classList.remove('show');
            }
        }

        function toggleCalendar() {
            const calendar = document.getElementById("calendar");
            calendar.classList.toggle("collapsed");
            document.getElementById("calendar-toggle").textContent = calendar.classList.contains("collapsed") ? "Show Calendar" : "Hide Calendar";
        }

        function updateTestOptions() {
            const courseId = document.getElementById('courseSelect').value;
            const testSelect = document.getElementById('testSelect');
            testSelect.innerHTML = '<option value="">Select Test</option>';

            if (courseId) {
                fetch('<%= request.getContextPath() %>/ResultsServlet?courseId=' + encodeURIComponent(courseId) + '&action=getTests')
                    .then(response => {
                        if (!response.ok) throw new Error('Failed to fetch tests');
                        return response.json();
                    })
                    .then(tests => {
                        tests.forEach(test => {
                            const option = document.createElement('option');
                            option.value = test.testId;
                            option.text = test.testName;
                            testSelect.appendChild(option);
                        });
                        // Restore selected test if available
                        const selectedTestId = '<%= session.getAttribute("testId") != null ? session.getAttribute("testId") : "" %>';
                        if (selectedTestId) {
                            testSelect.value = selectedTestId;
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching tests:', error);
                        testSelect.innerHTML = '<option value="">Error loading tests</option>';
                    });
            }
        }

        window.onclick = function(event) {
            if (!event.target.matches('.profile-icon')) {
                document.getElementById("dropdownMenu").classList.remove("show");
            }
        }

        function showProfile(email, role) {
            fetch('<%= request.getContextPath() %>/getProfile.jsp?email=' + encodeURIComponent(email) + '&role=' + encodeURIComponent(role))
                .then(response => {
                    if (!response.ok) throw new Error('Failed to load profile');
                    return response.text();
                })
                .then(data => {
                    document.getElementById('profileContent').innerHTML = data;
                    new bootstrap.Modal(document.getElementById('profileModal')).show();
                })
                .catch(error => {
                    console.error('Profile error:', error);
                    document.getElementById('profileContent').innerHTML = '<p>Error loading profile</p>';
                    new bootstrap.Modal(document.getElementById('profileModal')).show();
                });
        }

        document.addEventListener('DOMContentLoaded', function() {
            var calendarEl = document.getElementById('calendar');
            var calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                height: 'auto',
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,listDay'
                },
                events: [
                    <%
                        try (Connection connection = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                             PreparedStatement ps = connection.prepareStatement(
                                 "SELECT c.course_name, l.meet_link, l.schedule_time FROM LiveClasses l JOIN Courses c ON l.course_id = c.course_id");
                             ResultSet rs = ps.executeQuery()) {
                            Class.forName("oracle.jdbc.driver.OracleDriver");
                            while (rs.next()) {
                                String courseName = rs.getString("course_name");
                                String meetLink = rs.getString("meet_link");
                                Timestamp scheduleTime = rs.getTimestamp("schedule_time");
                                String eventDate = scheduleTime.toString().substring(0, 10);
                                String eventTime = scheduleTime.toString().substring(11, 19);
                                out.println("{");
                                out.println("title: '" + courseName.replace("'", "\\'") + " - " + eventTime + "',");
                                out.println("start: '" + eventDate + "T" + eventTime + "',");
                                out.println("url: '" + meetLink + "',");
                                out.println("},");
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                ],
                eventClick: function(info) {
                    info.jsEvent.preventDefault();
                    if (info.event.url) {
                        window.open(info.event.url, '_blank');
                    }
                }
            });
            calendar.render();
            document.getElementById("calendar-toggle").textContent = "Show Calendar";

            // Show download link if results are present
            <% if (results != null && !results.isEmpty()) { %>
                document.getElementById('downloadLink').style.display = 'inline-block';
            <% } %>

            // Ensure Results section is shown if results are present
            <% if (request.getAttribute("results") != null) { %>
                showSection('results');
                updateTestOptions(); // Refresh test options for selected course
            <% } %>
        });

        function openCourse(courseId, courseName) {
            const chatContainer = document.getElementById("chatContainer");
            chatContainer.classList.add("show");
            fetchUsers(courseId, courseName);
        }

        function fetchUsers(courseId, courseName) {
            const userList = document.getElementById("userList");
            const chatHeader = document.getElementById("chatHeader");
            chatHeader.textContent = `Chat with ${courseName}`;
            userList.innerHTML = "<p>Loading users...</p>";
            fetch('<%= request.getContextPath() %>/FetchUsersServlet?courseId=' + encodeURIComponent(courseId), {
                headers: {
                    'Accept': 'application/json'
                }
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Failed to fetch users: ' + response.statusText);
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.status === "success" && data.users.length > 0) {
                        userList.innerHTML = "";
                        data.users.forEach(user => {
                            const div = document.createElement("div");
                            div.className = "user-item";
                            div.textContent = user.name + " (" + user.role + ")";
                            div.onclick = () => openChat(user.email, user.name, user.role);
                            userList.appendChild(div);
                        });
                    } else {
                        userList.innerHTML = "<p>No users enrolled in this course.</p>";
                    }
                })
                .catch(error => {
                    console.error('Error fetching users:', error);
                    userList.innerHTML = "<p>Error loading users: " + error.message + "</p>";
                });
        }

        function openChat(userEmail, userName, userRole) {
            const chatHeader = document.getElementById("chatHeader");
            const chatUser = document.getElementById("chatUser");
            const receiverEmail = document.getElementById("receiverEmail");
            if (chatUser) {
                chatUser.textContent = `${userName} (${userRole})`;
            }
            chatHeader.textContent = `Chat with ${userName} (${userRole})`;
            receiverEmail.value = userEmail;
            fetchMessages(userEmail);
        }

        function fetchMessages(userEmail) {
            const adminEmail = '<%= session.getAttribute("email") %>';
            fetch('<%= request.getContextPath() %>/FetchMessagesServlet?otherEmail=' + encodeURIComponent(userEmail) + '&courseId=0', {
                headers: {
                    'Accept': 'application/json'
                }
            })
                .then(response => {
                    if (!response.ok) throw new Error('Failed to fetch messages');
                    return response.json();
                })
                .then(data => {
                    const chatMessages = document.getElementById("chatMessages");
                    chatMessages.innerHTML = "";
                    if (data.status === "success" && data.messages.length > 0) {
                        data.messages.forEach(msg => {
                            const div = document.createElement("div");
                            div.className = "message " + (msg.senderEmail === adminEmail ? "sent" : "received");
                            const timestamp = new Date(msg.sentAt).toLocaleString();
                            div.innerHTML = "<p>" + msg.content.replace(/[\u0000-\u001F\u007F-\u009F]/g, '') + "</p><div class='timestamp'>" + timestamp + "</div>";
                            chatMessages.appendChild(div);
                        });
                        chatMessages.scrollTop = chatMessages.scrollHeight;
                    } else {
                        chatMessages.innerHTML = '<p class="no-messages">No messages yet.</p>';
                    }
                })
                .catch(error => {
                    console.error('Error fetching messages:', error);
                    document.getElementById("chatMessages").innerHTML = '<p class="text-danger">Error loading messages: ' + error.message + '</p>';
                });
        }

        function sendMessage() {
            const receiverEmail = document.getElementById("receiverEmail").value;
            const content = document.getElementById("messageInput").value;

            fetch('<%= request.getContextPath() %>/SendMessageServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'receiverEmail=' + encodeURIComponent(receiverEmail) +
                      '&courseId=0' +
                      '&content=' + encodeURIComponent(content)
            })
                .then(response => {
                    if (!response.ok) throw new Error('Failed to send message');
                    return response.json();
                })
                .then(data => {
                    if (data.status === "success") {
                        document.getElementById("messageInput").value = "";
                        fetchMessages(receiverEmail);
                    } else {
                        alert("Error sending message: " + data.message);
                    }
                })
                .catch(error => {
                    console.error('Error sending message:', error);
                    alert("Error sending message: " + error.message);
                });
        }

        // Add Enter key support for sending messages
        document.getElementById("messageInput").addEventListener("keypress", function(event) {
            if (event.key === "Enter") {
                event.preventDefault();
                sendMessage();
            }
        });
    </script>
</body>
</html>