<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
String selectedTestId = (String) session.getAttribute("facultyTestId");
if (selectedTestId == null) {
    selectedTestId = "";
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Faculty Dashboard - JAAS Institute</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300..700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css" rel="stylesheet">
    <!-- Add Bootstrap Icons CDN -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
    	body { font-family: "Space Grotesk", sans-serif; background-color: #f0faff; color: #333; margin: 0; }
			.dashboard-header { background-color: #4070f4; color: #fff; padding: 30px; text-align: center; }
			.profile-dropdown {
			    display: flex;
			    align-items: center;
			}
			.header-container { 
			    display: flex; 
			    justify-content: space-between; 
			    align-items: center; 
			    position: relative; 
			    padding: 10px 20px; 
			    background-color: #fff; 
			    border-bottom: 1px solid #ddd; 
			}
			.header-title { 
			    position: absolute;
			    left: 50%;
			    transform: translateX(-50%);
			    font-size: 24px;
			    font-weight: bold;
			    color: #333; 
			}
			.sidebar { width: 280px; background-color: #f8f9fa; transition: transform 0.3s ease; position: fixed; top: 0; left: 0; height: 100%; character: 1000; overflow-y: auto; }
			.sidebar.collapsed { transform: translateX(-280px); }
			.sidebar.collapsed ~ .header-container .header-title { 
			    position: absolute; 
			    left: 50%; 
			    transform: translateX(-50%); 
			    font-size: 1.8rem; 
			    font-weight: 700; 
			    letter-spacing: 1px; 
			}
			.hamburger { font-size: 24px; cursor: pointer; position: fixed; top: 20px; left: 20px; z-index: 1100; color: #4070f4; background: none; border: none; }
			.hamburger:hover { color: #3050d0; }
			.content-wrapper { margin-left: 280px; transition: margin-left 0.3s ease; padding: 20px; min-height: 100vh; position: relative; width: calc(100% - 280px); box-sizing: border-box; }
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
			.btn-accept { background-color: #28a745; color: #fff; }
			.btn-accept:hover { background-color: #218838; }
			.btn-reject { background-color: #dc3545; color: #fff; }
			.btn-reject:hover { background-color: #c82333; }
			.alert { margin-bottom: 20px; }
			.course-list { padding-left: 20px; }
			.course-list .nav-link { padding: 5px 10px; font-size: 14px; }
			#calendar-container { position: fixed; bottom: 20px; right: 20px; z-index: 900; }
			#calendar { width: 400px; max-height: 400px; background-color: #fff; border-radius: 10px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); padding: 10px; overflow-y: auto; transition: max-height 0.3s ease; display: none; }
			#calendar.expanded { display: block; }
			#calendar-toggle-up { position: fixed; bottom: 20px; right: 20px; background-color: #4070f4; color: #fff; border: none; padding: 5px 10px; border-radius: 5px; cursor: pointer; font-size: 16px; z-index: 950; }
			#calendar-toggle-up:hover { background-color: #3050d0; }
			#calendar-toggle-up:hover::after { content: "Show Calendar"; position: absolute; bottom: 35px; right: 0; background-color: #333; color: #fff; padding: 5px; border-radius: 5px; font-size: 12px; }
			#calendar-toggle-down { background-color: #4070f4; color: #fff; border: none; padding: 5px 10px; border-radius: 5px; cursor: pointer; font-size: 16px; z-index: 950; margin-bottom: 5px; display: none; }
			#calendar-toggle-down:hover { background-color: #3050d0; }
			#calendar-toggle-down:hover::after { content: "Hide Calendar"; position: absolute; bottom: 35px; right: 0; background-color: #333; color: #fff; padding: 5px; border-radius: 5px; font-size: 12px; }
			.fc-event { font-size: 12px; padding: 2px 5px; }
			.fc-daygrid-day { height: 50px; }
			.modal-content { font-family: "Space Grotesk", sans-serif; }
			.table { margin-top: 20px; width: 100%; table-layout: auto; }
			.table th, .table td { padding: 12px; text-align: left; white-space: nowrap; vertical-align: middle; }
			.table th { background-color: #f8f9fa; font-weight: 500; }
			.filter-form { margin-bottom: 20px; }
			.button-group { display: flex; align-items: center; gap: 10px; }
			.filter-info { margin-bottom: 15px; padding: 10px; background-color: #f8f9fa; border-radius: 5px; }
			.me-2 { margin-right: 10px; }
			.chat-container { display: none; position: fixed; bottom: 60px; right: 20px; width: 700px; height: 550px; z-index: 1000; background-color: #fff; border-radius: 10px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); font-size: 16px; }
			.chat-container.show { display: flex; }
			.chat-sidebar { width: 35%; background-color: #f8f9fa; border-right: 1px solid #ddd; overflow-y: auto; height: 100%; }
			.chat-sidebar h4 {
			    font-size: 20px;
			    padding: 15px;
			    margin: 0;
			    background-color: #4070f4;
			    color: #fff;
			    height: 60px; /* Set consistent height */
			    line-height: 30px; /* Center text vertically */
			    width: 100%; /* Ensure full width */
			    box-sizing: border-box;
			}
			.chat-content { width: 65%; padding: 20px; background-color: #e5ddd5; height: 100%; position: relative; }
			.chat-content-header {
			    display: flex;
			    justify-content: space-between;
			    align-items: center;
			    margin-bottom: 15px;
			    background-color: #4070f4; /* Full blue background for the header */
			    padding: 0; /* Remove padding to let h4 handle it */
			    width: 100%; /* Ensure full width */
			    box-sizing: border-box;
			}
			.chat-content h4 {
			    font-size: 20px;
			    margin: 0;
			    padding: 15px;
			    color: #fff;
			    border-radius: 0; /* Remove border-radius to make background full width */
			    height: 60px; /* Set consistent height */
			    line-height: 30px; /* Center text vertically */
			    flex-grow: 1; /* Allow h4 to take available space */
			}
			.close-chat {
			    font-size: 20px;
			    color: #fff;
			    cursor: pointer;
			    background-color: #dc3545;
			    border-radius: 50%;
			    width: 24px;
			    height: 24px;
			    line-height: 24px;
			    text-align: center;
			    margin-right: 15px; /* Space from the right edge */
			}
			.close-chat:hover { background-color: #c82333; }
			.chat-messages { height: calc(100% - 90px); overflow-y: auto; padding: 10px; }
			.message { margin-bottom: 10px; padding: 10px; border-radius: 5px; max-width: 70%; }
			.sent { background-color: #dcf8c6; margin-left: auto; }
			.received { background-color: #fff; }
			.timestamp { font-size: 12px; color: #666; }
			.no-messages { text-align: center; color: #666; }
			.chat-input { position: absolute; bottom: 0; width: 100%; padding: 10px; background-color: #f0faff; display: flex; }
			.chat-input input { flex: 1; border: none; background: transparent; outline: none; font-family: "Space Grotesk", sans-serif; color: #333; font-size: 16px; }
			.chat-input button { background-color: #075e54; color: #fff; border: none; padding: 5px 15px; border-radius: 5px; cursor: pointer; font-size: 16px; }
			.chat-input button:hover { background-color: #054d44; }
			.course-item { padding: 10px; cursor: pointer; }
			.course-item:hover { background-color: #e0e0e0; }
			.student-item { padding: 10px; cursor: pointer; border-bottom: 1px solid #ddd; font-size: 16px; }
			.student-item:hover { background-color: #e0e0e0; }
			.sidebar .nav-link { 
			    color: #333; 
			    padding: 12px 20px; 
			    border-radius: 8px; 
			    margin: 5px 10px; 
			    transition: background-color 0.3s ease, transform 0.2s ease, color 0.3s ease; 
			    position: relative; 
			    overflow: hidden; 
			    display: flex; 
			    align-items: center; 
			}
			.sidebar .nav-link i { 
			    margin-right: 10px; 
			    font-size: 18px; 
			}
			.sidebar .nav-link:hover { 
			    background: linear-gradient(135deg, #4070f4 0%, #3050d0 100%); 
			    color: #fff; 
			    transform: translateX(5px); 
			}
			.sidebar .nav-link:hover i { 
			    color: #fff; 
			}
			.sidebar .nav-link::before { 
			    content: ''; 
			    position: absolute; 
			    left: 0; 
			    top: 0; 
			    width: 5px; 
			    height: 100%; 
			    background-color: #4070f4; 
			    opacity: 0; 
			    transition: opacity 0.3s ease; 
			}
			.sidebar .nav-link:hover::before { opacity: 1; }
			.sidebar hr { border-color: #ddd; margin: 15px 0; }
			@media (max-width: 768px) {
			    .sidebar { transform: translateX(-280px); }
			    .sidebar.collapsed { transform: translateX(0); }
			    .content-wrapper { margin-left: 0; width: 100%; padding: 10px; }
			    #calendar-container { width: 100%; right: 0; bottom: 0; }
			    #calendar { width: 100%; max-height: 300px; }
			    #calendar-toggle-up { right: 10px; bottom: 10px; }
			    .table { font-size: 14px; }
			    .table th, .table td { padding: 8px; }
			    .button-group { flex-direction: column; gap: 8px; }
			    .btn-custom { width: 100%; text-align: center; }
			    .chat-container { width: 100%; height: 60vh; right: 0; bottom: 40px; font-size: 14px; }
			    .chat-sidebar { width: 100%; height: 30%; }
			    .chat-sidebar h4 { font-size: 18px; }
			    .chat-content { width: 100%; height: 70%; }
			    .chat-content h4 { font-size: 18px; }
			    .chat-input input, .chat-input button { font-size: 14px; }
			    .student-item { font-size: 14px; }
			}
			.header-spacer {
			    width: 40px; /* Same width as profile icon */
			}
    </style>
</head>
<body>
    <!-- Navbar -->
    <header class="header-container">
        <div class="header-spacer"></div>
            <h1 class="header-title">JAAS Institute</h1>
            <div class="profile-dropdown">
                <div class="dropdown">
                    <img src="<%= request.getContextPath() %>/asserts/default-profile.png" id="profileIcon" alt="Profile" class="profile-icon" onclick="toggleDropdown()">
                    <div class="dropdown-menu" id="dropdownMenu">
                        <span>Welcome 😊, <%= session.getAttribute("name") != null ? session.getAttribute("name") : "Faculty" %></span>
                        <a href="profile.jsp">My Profile</a>
                        <a href="#" onclick="logout()">Logout</a>
                    </div>
                </div>
            </div>
    </header>

    <!-- Hamburger Menu Icon -->
    <button class="hamburger" onclick="toggleSidebar()">☰</button>

    <!-- Sidebar + Content Wrapper -->
    <div class="d-flex min-vh-100">
        <!-- Sidebar -->
        <div class="sidebar d-flex flex-column flex-shrink-0 p-3 bg-light" id="sidebar">
            <hr>
            <ul class="nav nav-pills flex-column mb-auto">
                <li class="nav-item"><a href="#createCourse" class="nav-link" onclick="showSection('createCourse')"><i class="bi bi-plus-circle"></i>Create a Course</a></li>
                <li><a href="#liveClasses" class="nav-link" onclick="showSection('liveClasses')"><i class="bi bi-camera-video"></i>Schedule Live Class</a></li>
                <li><a href="#createMCQTest" class="nav-link" onclick="showSection('createMCQTest')"><i class="bi bi-file-earmark-text"></i>Create MCQ Test</a></li>
                <li><a href="#uploadMaterials" class="nav-link" onclick="showSection('uploadMaterials')"><i class="bi bi-upload"></i>Upload Materials</a></li>
                <li><a href="#enrollmentRequests" class="nav-link" onclick="showSection('enrollmentRequests')"><i class="bi bi-person-check"></i>Enrollment Requests</a></li>
                <li><a href="#results" class="nav-link" onclick="showSection('results')"><i class="bi bi-bar-chart"></i>Results</a></li>
                <li><a href="#queries" class="nav-link" onclick="showSection('queries')"><i class="bi bi-chat-left-text"></i>Queries</a></li>
                <li>
                    <a href="#myCourses" class="nav-link" onclick="showSection('myCourses')"><i class="bi bi-book"></i>My Courses</a>
                    <ul class="course-list">
                    </ul>
                </li>
            </ul>
        </div>

        <!-- Content Wrapper -->
        <div class="content-wrapper" id="contentWrapper">
            <div class="dashboard-header">
                <h1>Welcome, <%= session.getAttribute("name") != null ? session.getAttribute("name") : "Faculty" %>!</h1>
                <p>Your Faculty Dashboard</p>
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

            <!-- Create Course Section -->
            <div id="createCourse" class="form-section">
                <h2>Create a Course</h2>
                <form action="CreateCourseServlet" method="post">
                    <div class="mb-3">
                        <label for="courseName" class="form-label">Course Name</label>
                        <input type="text" class="form-control" id="courseName" name="courseName" required>
                    </div>
                    <div class="mb-3">
                        <label for="description" class="form-label">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="3" required></textarea>
                    </div>
                    <button type="submit" class="btn btn-custom">Create Course</button>
                </form>
            </div>

            <!-- Schedule Live Class Section -->
            <div id="liveClasses" class="form-section">
                <h2>Schedule a Live Class</h2>
                <form action="ScheduleLiveClassServlet" method="post">
                    <div class="mb-3">
                        <label for="liveCourseId" class="form-label">Select Course</label>
                        <select class="form-select" id="liveCourseId" name="courseId" required>
                            <option value="">-- Select a Course --</option>
                            <%
                                Connection con = null;
                                PreparedStatement ps = null;
                                ResultSet rs = null;
                                try {
                                    Class.forName("oracle.jdbc.driver.OracleDriver");
                                    con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                                    String email = (String) session.getAttribute("email");
                                    ps = con.prepareStatement("SELECT course_id, course_name FROM Courses WHERE faculty_email = ?");
                                    ps.setString(1, email);
                                    rs = ps.executeQuery();
                                    while (rs.next()) {
                                        int courseId = rs.getInt("course_id");
                                        String courseName = rs.getString("course_name");
                            %>
                            <option value="<%= courseId %>"><%= courseName %></option>
                            <%
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                                }
                            %>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="meetLink" class="form-label">Google Meet Link</label>
                        <input type="url" class="form-control" id="meetLink" name="meetLink" placeholder="https://meet.google.com/..." required>
                    </div>
                    <div class="mb-3">
                        <label for="scheduleTime" class="form-label">Schedule Time</label>
                        <input type="datetime-local" class="form-control" id="scheduleTime" name="scheduleTime" required>
                    </div>
                    <button type="submit" class="btn btn-custom">Schedule Class</button>
                </form>
            </div>

            <!-- Create MCQ Test Section -->
            <div id="createMCQTest" class="form-section">
                <h2>Create MCQ Test</h2>
                <ul class="nav nav-tabs mb-3" id="mcqTab" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="manual-tab" data-bs-toggle="tab" data-bs-target="#manual" type="button" role="tab" aria-controls="manual" aria-selected="true">Manual Entry</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="upload-tab" data-bs-toggle="tab" data-bs-target="#upload" type="button" role="tab" aria-controls="upload" aria-selected="false">Upload File</button>
                    </li>
                </ul>
                <div class="tab-content" id="mcqTabContent">
                    <div class="tab-pane fade show active" id="manual" role="tabpanel" aria-labelledby="manual-tab">
                        <form action="CreateMCQTestServlet" method="post" enctype="multipart/form-data">
                            <div class="mb-3">
                                <label for="testCourseIdManual" class="form-label">Select Course</label>
                                <select class="form-select" id="testCourseIdManual" name="courseId" required>
                                    <option value="">-- Select a Course --</option>
                                    <%
                                        con = null;
                                        ps = null;
                                        rs = null;
                                        try {
                                            Class.forName("oracle.jdbc.driver.OracleDriver");
                                            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                                            String email = (String) session.getAttribute("email");
                                            ps = con.prepareStatement("SELECT course_id, course_name FROM Courses WHERE faculty_email = ?");
                                            ps.setString(1, email);
                                            rs = ps.executeQuery();
                                            while (rs.next()) {
                                                int courseId = rs.getInt("course_id");
                                                String courseName = rs.getString("course_name");
                                    %>
                                    <option value="<%= courseId %>"><%= courseName %></option>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                        } finally {
                                            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                                            if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                                            if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="testNameManual" class="form-label">Test Name</label>
                                <input type="text" class="form-control" id="testNameManual" name="testName" required>
                            </div>
                            <div class="mb-3">
                                <label for="scheduleTimeManual" class="form-label">Start Time (Optional)</label>
                                <input type="datetime-local" class="form-control" id="scheduleTimeManual" name="scheduleTime">
                                <small class="form-text text-muted">Leave blank to keep test open until manually disabled.</small>
                            </div>
                            <div class="mb-3">
                                <label for="endTimeManual" class="form-label">End Time (Optional)</label>
                                <input type="datetime-local" class="form-control" id="endTimeManual" name="endTime">
                                <small class="form-text text-muted">Leave blank to keep test open until manually disabled.</small>
                            </div>
                            <div id="questionsContainer">
                                <div class="question mb-3">
                                    <label>Question 1</label>
                                    <input type="text" class="form-control mb-2" name="questionText[]" placeholder="Enter question" required>
                                    <input type="text" class="form-control mb-2" name="optionA[]" placeholder="Option A" required>
                                    <input type="text" class="form-control mb-2" name="optionB[]" placeholder="Option B" required>
                                    <input type="text" class="form-control mb-2" name="optionC[]" placeholder="Option C" required>
                                    <input type="text" class="form-control mb-2" name="optionD[]" placeholder="Option D" required>
                                    <select class="form-select" name="correctAnswer[]" required>
                                        <option value="">Select Correct Answer</option>
                                        <option value="A">A</option>
                                        <option value="B">B</option>
                                        <option value="C">C</option>
                                        <option value="D">D</option>
                                    </select>
                                </div>
                            </div>
                            <button type="button" class="btn btn-secondary mb-3" onclick="addQuestion()">Add Another Question</button>
                            <button type="submit" class="btn btn-custom">Create Test</button>
                        </form>
                    </div>
                    <div class="tab-pane fade" id="upload" role="tabpanel" aria-labelledby="upload-tab">
                        <form action="CreateMCQTestServlet" method="post" enctype="multipart/form-data">
                            <div class="mb-3">
                                <label for="testCourseIdUpload" class="form-label">Select Course</label>
                                <select class="form-select" id="testCourseIdUpload" name="courseId" required>
                                    <option value="">-- Select a Course --</option>
                                    <%
                                        con = null;
                                        ps = null;
                                        rs = null;
                                        try {
                                            Class.forName("oracle.jdbc.driver.OracleDriver");
                                            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                                            String email = (String) session.getAttribute("email");
                                            ps = con.prepareStatement("SELECT course_id, course_name FROM Courses WHERE faculty_email = ?");
                                            ps.setString(1, email);
                                            rs = ps.executeQuery();
                                            while (rs.next()) {
                                                int courseId = rs.getInt("course_id");
                                                String courseName = rs.getString("course_name");
                                    %>
                                    <option value="<%= courseId %>"><%= courseName %></option>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                        } finally {
                                            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                                            if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                                            if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="testNameUpload" class="form-label">Test Name</label>
                                <input type="text" class="form-control" id="testNameUpload" name="testName" required>
                            </div>
                            <div class="mb-3">
                                <label for="scheduleTimeUpload" class="form-label">Start Time (Optional)</label>
                                <input type="datetime-local" class="form-control" id="scheduleTimeUpload" name="scheduleTime">
                                <small class="form-text text-muted">Leave blank to keep test open until manually disabled.</small>
                            </div>
                            <div class="mb-3">
                                <label for="endTimeUpload" class="form-label">End Time (Optional)</label>
                                <input type="datetime-local" class="form-control" id="endTimeUpload" name="endTime">
                                <small class="form-text text-muted">Leave blank to keep test open until manually disabled.</small>
                            </div>
                            <div class="mb-3">
                                <label for="mcqFile" class="form-label">Upload MCQ File (CSV)</label>
                                <input type="file" class="form-control" id="mcqFile" name="mcqFile" accept=".csv" required>
                                <small class="form-text text-muted">Format: question_text,option_a,option_b,option_c,option_d,correct_answer</small>
                            </div>
                            <button type="submit" class="btn btn-custom">Create Test from File</button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Upload Materials Section -->
            <div id="uploadMaterials" class="form-section">
                <h2>Upload Materials</h2>
                <form action="UploadMaterialServlet" method="post" enctype="multipart/form-data">
                    <div class="mb-3">
                        <label for="materialCourseId" class="form-label">Select Course</label>
                        <select class="form-select" id="materialCourseId" name="courseId" required>
                            <option value="">-- Select a Course --</option>
                            <%
                                con = null;
                                ps = null;
                                rs = null;
                                try {
                                    Class.forName("oracle.jdbc.driver.OracleDriver");
                                    con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                                    String email = (String) session.getAttribute("email");
                                    ps = con.prepareStatement("SELECT course_id, course_name FROM Courses WHERE faculty_email = ?");
                                    ps.setString(1, email);
                                    rs = ps.executeQuery();
                                    while (rs.next()) {
                                        int courseId = rs.getInt("course_id");
                                        String courseName = rs.getString("course_name");
                            %>
                            <option value="<%= courseId %>"><%= courseName %></option>
                            <%
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                                }
                            %>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="materialTitle" class="form-label">Material Title</label>
                        <input type="text" class="form-control" id="materialTitle" name="materialTitle" required>
                    </div>
                    <div class="mb-3">
                        <label for="description" class="form-label">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="3" required></textarea>
                    </div>
                    <div class="mb-3">
                        <label for="materialFile" class="form-label">Upload File</label>
                        <input type="file" class="form-control" id="materialFile" name="materialFile" accept=".pdf,.doc,.docx,.ppt,.pptx,.txt,.zip" required>
                        <small class="form-text text-muted">Supported formats: PDF, DOC, DOCX, PPT, PPTX, TXT, ZIP</small>
                    </div>
                    <button type="submit" class="btn btn-custom">Upload Material</button>
                </form>
            </div>

            <!-- Enrollment Requests Section -->
            <div id="enrollmentRequests" class="form-section">
                <h2>Enrollment Requests</h2>
                <%
                    con = null;
                    ps = null;
                    rs = null;
                    try {
                        Class.forName("oracle.jdbc.driver.OracleDriver");
                        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                        String email = (String) session.getAttribute("email");
                        ps = con.prepareStatement(
                            "SELECT er.request_id, er.course_id, er.student_email, er.requested_at, c.course_name " +
                            "FROM Enrollment_Requests er JOIN Courses c ON er.course_id = c.course_id " +
                            "WHERE er.faculty_email = ? AND er.request_status = 'PENDING'"
                        );
                        ps.setString(1, email);
                        rs = ps.executeQuery();
                        boolean hasRequests = false;
                        while (rs.next()) {
                            hasRequests = true;
                            int requestId = rs.getInt("request_id");
                            int courseId = rs.getInt("course_id");
                            String studentEmail = rs.getString("student_email");
                            String courseName = rs.getString("course_name");
                            Timestamp requestedAt = rs.getTimestamp("requested_at");
                %>
                <div class="mb-3">
                    <p><strong>Student:</strong> <%= studentEmail %> | <strong>Course:</strong> <%= courseName %> | <strong>Requested At:</strong> <%= requestedAt %></p>
                    <form action="ManageEnrollmentServlet" method="post" style="display: inline;">
                        <input type="hidden" name="requestId" value="<%= requestId %>">
                        <input type="hidden" name="action" value="accept">
                        <button type="submit" class="btn btn-accept me-2">Accept</button>
                    </form>
                    <form action="ManageEnrollmentServlet" method="post" style="display: inline;">
                        <input type="hidden" name="requestId" value="<%= requestId %>">
                        <input type="hidden" name="action" value="reject">
                        <button type="submit" class="btn btn-reject">Reject</button>
                    </form>
                </div>
                <%
                        }
                        if (!hasRequests) {
                            out.println("<p>No pending enrollment requests.</p>");
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>
            </div>

            <!-- Results Section -->
            <div id="results" class="form-section">
                <h2>Test Results</h2>
                <form action="<%= request.getContextPath() %>/FacultyResultsServlet" method="get" class="filter-form">
                    <div class="row">
                        <div class="col-md-3 mb-3">
                            <select name="courseId" id="courseSelect" class="form-select" onchange="updateTestOptions()">
                                <option value="">Select Course</option>
                                <%
                                    String selectedCourseId = (String) session.getAttribute("facultyCourseId");
                                    Map<Integer, String> courseMap = new HashMap<>();
                                    con = null;
                                    ps = null;
                                    rs = null;
                                    try {
                                        Class.forName("oracle.jdbc.driver.OracleDriver");
                                        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                                        ps = con.prepareStatement("SELECT COURSE_ID, COURSE_NAME FROM Courses WHERE FACULTY_EMAIL = ?");
                                        ps.setString(1, (String) session.getAttribute("email"));
                                        rs = ps.executeQuery();
                                        while (rs.next()) {
                                            int courseId = rs.getInt("COURSE_ID");
                                            String courseName = rs.getString("COURSE_NAME");
                                            courseMap.put(courseId, courseName);
                                            String selected = courseId == (selectedCourseId != null && !selectedCourseId.isEmpty() ? Integer.parseInt(selectedCourseId) : -1) ? "selected" : "";
                                %>
                                <option value="<%= courseId %>" <%= selected %>><%= courseName %></option>
                                <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                %>
                                <option value="">Error loading courses</option>
                                <%
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                                        if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                                        if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    }
                                %>
                            </select>
                        </div>
                        <div class="col-md-3 mb-3">
                            <select name="testId" id="testSelect" class="form-select">
                                <option value="">Select Test</option>
                            </select>
                        </div>
                        <div class="col-md-3 mb-3">
                            <select name="attemptStatus" class="form-select">
                                <%
                                    String selectedAttemptStatus = (String) session.getAttribute("facultyAttemptStatus");
                                    String allSelected = "all".equals(selectedAttemptStatus) ? "selected" : "";
                                    String attemptedSelected = "attempted".equals(selectedAttemptStatus) ? "selected" : "";
                                    String notAttemptedSelected = "not_attempted".equals(selectedAttemptStatus) ? "selected" : "";
                                %>
                                <option value="all" <%= allSelected %>>All Students</option>
                                <option value="attempted" <%= attemptedSelected %>>Attempted</option>
                                <option value="not_attempted" <%= notAttemptedSelected %>>Not Attempted</option>
                            </select>
                        </div>
                        <div class="col-md-3 mb-3">
                            <div class="button-group">
                                <button type="submit" class="btn btn-custom me-2">Fetch Results</button>
                                <a href="<%= request.getContextPath() %>/FacultyDownloadResultsServlet" id="downloadLink" class="btn btn-custom" style="display:none;">Download CSV</a>
                            </div>
                        </div>
                    </div>
                </form>

                <%
                    if (selectedCourseId != null && !selectedCourseId.isEmpty()) {
                        String courseName = courseMap.get(Integer.parseInt(selectedCourseId));
                        String testName = "";
                        con = null;
                        ps = null;
                        rs = null;
                        if (selectedTestId != null && !selectedTestId.isEmpty()) {
                            try {
                                Class.forName("oracle.jdbc.driver.OracleDriver");
                                con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                                ps = con.prepareStatement("SELECT TEST_NAME FROM MCQ_TESTS WHERE TEST_ID = ?");
                                ps.setString(1, selectedTestId);
                                rs = ps.executeQuery();
                                if (rs.next()) {
                                    testName = rs.getString("TEST_NAME");
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            } finally {
                                if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                                if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                                if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                            }
                        }
                %>
                <div class="filter-info">
                    <p>Showing results for: <%= courseName %> <%= !testName.isEmpty() ? "| Test: " + testName : "" %></p>
                </div>
                <%
                    con = null;
                    ps = null;
                    rs = null;
                    try {
                        Class.forName("oracle.jdbc.driver.OracleDriver");
                        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                        String sql = "SELECT ms.STUDENT_EMAIL, ms.SCORE, ms.SUBMITTED_AT, " +
                                     "c.COURSE_NAME, mt.TEST_NAME, " +
                                     "(SELECT COUNT(*) FROM MCQ_QUESTIONS mq WHERE mq.TEST_ID = mt.TEST_ID) as TOTAL_CONDUCTED_MARKS " +
                                     "FROM MCQ_SUBMISSIONS ms " +
                                     "JOIN MCQ_TESTS mt ON ms.TEST_ID = mt.TEST_ID " +
                                     "JOIN COURSES c ON mt.COURSE_ID = c.COURSE_ID " +
                                     "WHERE mt.COURSE_ID = ? ";
                        if (!selectedTestId.isEmpty()) {
                            sql += "AND ms.TEST_ID = ?";
                        }
                        String attemptStatus = request.getParameter("attemptStatus");
                        if ("attempted".equals(attemptStatus)) {
                            sql += "AND ms.SCORE IS NOT NULL";
                        } else if ("not_attempted".equals(attemptStatus)) {
                            sql += "AND ms.SCORE IS NULL";
                        }
                        ps = con.prepareStatement(sql);
                        ps.setInt(1, Integer.parseInt(selectedCourseId));
                        if (!selectedTestId.isEmpty()) {
                            ps.setString(2, selectedTestId);
                        }
                        rs = ps.executeQuery();
                        boolean hasResults = rs.isBeforeFirst();
                %>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Student Email</th>
                            <th>Course Name</th>
                            <th>Test Name</th>
                            <th>Score</th>
                            <th>Percentage</th>
                            <th>Submitted At</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rs.next()) {
                                String studentEmail = rs.getString("STUDENT_EMAIL");
                                String courseNameResult = rs.getString("COURSE_NAME");
                                String testNameResult = rs.getString("TEST_NAME");
                                int score = rs.getInt("SCORE");
                                int totalConductedMarks = rs.getInt("TOTAL_CONDUCTED_MARKS");
                                double percentage = totalConductedMarks != 0 ? (score * 100.0 / totalConductedMarks) : 0.0;
                                String formattedPercentage = String.format("%.2f%%", percentage);
                                Timestamp submittedAt = rs.getTimestamp("SUBMITTED_AT");
                        %>
                        <tr>
                            <td><%= studentEmail != null ? studentEmail : "N/A" %></td>
                            <td><%= courseNameResult %></td>
                            <td><%= testNameResult %></td>
                            <td><%= score %>/<%= totalConductedMarks %></td>
                            <td><%= formattedPercentage %></td>
                            <td><%= submittedAt != null ? submittedAt : "N/A" %></td>
                        </tr>
                        <%
                            }
                            if (!hasResults && !selectedTestId.isEmpty()) {
                                ps = con.prepareStatement(
                                    "SELECT STUDENT_EMAIL FROM ENROLLMENTS WHERE COURSE_ID = ? AND STUDENT_EMAIL NOT IN " +
                                    "(SELECT STUDENT_EMAIL FROM MCQ_SUBMISSIONS WHERE TEST_ID = ?)"
                                );
                                ps.setInt(1, Integer.parseInt(selectedCourseId));
                                ps.setString(2, selectedTestId);
                                rs = ps.executeQuery();
                                while (rs.next()) {
                                    String studentEmail = rs.getString("STUDENT_EMAIL");
                        %>
                        <tr>
                            <td><%= studentEmail %></td>
                            <td><%= courseName %></td>
                            <td><%= testName %></td>
                            <td>N/A</td>
                            <td>N/A</td>
                            <td>N/A</td>
                        </tr>
                        <%
                                }
                            }
                        %>
                    </tbody>
                </table>
                <%
                    if (!hasResults && selectedTestId.isEmpty()) {
                        out.println("<p>No submissions yet for this course.</p>");
                    } else if (!hasResults) {
                        out.println("<p>No submissions or students for this test.</p>");
                    }
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<p class='text-danger'>Error loading results: " + e.getMessage() + "</p>");
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>
                <%
                    }
                %>
            </div>

            <!-- Queries Section -->
            <div id="queries" class="form-section">
                <h2>Queries</h2>
                <h3>Your Courses</h3>
                <%
                    con = null;
                    ps = null;
                    rs = null;
                    try {
                        Class.forName("oracle.jdbc.driver.OracleDriver");
                        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                        String facultyEmail = (String) session.getAttribute("email");
                        ps = con.prepareStatement("SELECT course_id, course_name FROM Courses WHERE faculty_email = ?");
                        ps.setString(1, facultyEmail);
                        rs = ps.executeQuery();
                        while (rs.next()) {
                            int courseId = rs.getInt("course_id");
                            String courseName = rs.getString("course_name");
                %>
                <div class="course-item" onclick="openCourse('<%= courseId %>', '<%= courseName %>')">
                    <%= courseName %>
                </div>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>
            </div>

            <!-- Chat Container -->
            <div id="chatContainer" class="chat-container">
                <div class="chat-sidebar" id="studentList">
                    <h4>Students</h4>
                </div>
                <div class="chat-content">
                    <div class="chat-content-header">
                        <h4>Chat with <span id="chatStudent"></span></h4>
                        <span class="close-chat" onclick="closeChat()">✖</span>
                    </div>
                    <input type="hidden" id="receiverEmail" name="receiverEmail">
                    <div id="chatMessages" class="chat-messages"></div>
                    <div class="chat-input">
                        <input type="text" id="messageInput" class="form-control" placeholder="Type your message..." required>
                        <button type="button" onclick="sendMessage()">Send</button>
                    </div>
                </div>
            </div>

            <!-- My Courses Section -->
            <div id="myCourses" class="form-section active">
                <h2>My Courses</h2>
                <div class="row">
                    <%
                        con = null;
                        ps = null;
                        rs = null;
                        try {
                            Class.forName("oracle.jdbc.driver.OracleDriver");
                            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                            String email = (String) session.getAttribute("email");
                            ps = con.prepareStatement("SELECT course_id, course_name, description FROM Courses WHERE faculty_email = ?");
                            ps.setString(1, email);
                            rs = ps.executeQuery();
                            if (!rs.isBeforeFirst()) {
                                out.println("<p>No courses found.</p>");
                            }
                            while (rs.next()) {
                                int courseId = rs.getInt("course_id");
                                String courseName = rs.getString("course_name");
                                String description = rs.getString("description");
                    %>
                    <div class="col-md-4 mb-3">
                        <div class="card">
                            <div class="card-body">
                                <h5 class="card-title"><%= courseName %></h5>
                                <p class="card-text"><%= description != null ? description.substring(0, Math.min(description.length(), 100)) + (description.length() > 100 ? "..." : "") : "No description" %></p>
                                <a href="#course_<%= courseId %>" class="btn btn-custom" onclick="showSection('course_<%= courseId %>')">View Details</a>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            out.println("<p class='text-danger'>Error fetching courses: " + e.getMessage() + "</p>");
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    %>
                </div>
            </div>

            <!-- Dynamic Course Sections -->
            <%
                con = null;
                ps = null;
                rs = null;
                try {
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                    con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                    String email = (String) session.getAttribute("email");
                    ps = con.prepareStatement("SELECT course_id, course_name, description FROM Courses WHERE faculty_email = ?");
                    ps.setString(1, email);
                    rs = ps.executeQuery();
                    while (rs.next()) {
                        int courseId = rs.getInt("course_id");
                        String courseName = rs.getString("course_name");
                        String description = rs.getString("description");
            %>
            <div id="course_<%= courseId %>" class="form-section">
                <h2><%= courseName %></h2>
                <p><strong>Description:</strong> <%= description != null ? description : "N/A" %></p>
            
                <!-- Scheduled Live Classes -->
                <h3>Scheduled Live Classes</h3>
                <ul>
                    <%
                        PreparedStatement psLive = null;
                        ResultSet rsLive = null;
                        try {
                            psLive = con.prepareStatement("SELECT meet_link, schedule_time FROM LiveClasses WHERE course_id = ?");
                            psLive.setInt(1, courseId);
                            rsLive = psLive.executeQuery();
                            if (!rsLive.isBeforeFirst()) {
                                out.println("<li>No live classes scheduled.</li>");
                            }
                            while (rsLive.next()) {
                                String meetLink = rsLive.getString("meet_link");
                                Timestamp scheduleTime = rsLive.getTimestamp("schedule_time");
                                if (meetLink != null && !meetLink.isEmpty()) {
                    %>
                    <li><a href="<%= meetLink %>" target="_blank">Join Class</a> - <%= scheduleTime %></li>
                    <%
                                }
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            out.println("<li>Error fetching live classes: " + e.getMessage() + "</li>");
                        } finally {
                            if (rsLive != null) try { rsLive.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (psLive != null) try { psLive.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    %>
                </ul>
            
                <!-- Uploaded Materials -->
                <h3>Uploaded Materials</h3>
                <%
                    PreparedStatement psMaterials = null;
                    ResultSet rsMaterials = null;
                    try {
                        psMaterials = con.prepareStatement(
                            "SELECT material_id, title, description, file_name, uploaded_at FROM Course_Materials WHERE course_id = ? ORDER BY uploaded_at DESC"
                        );
                        psMaterials.setInt(1, courseId);
                        rsMaterials = psMaterials.executeQuery();
                        if (!rsMaterials.isBeforeFirst()) {
                            out.println("<p>No materials uploaded for this course.</p>");
                        } else {
                %>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Description</th>
                            <th>File Name</th>
                            <th>Uploaded At</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rsMaterials.next()) {
                                int materialId = rsMaterials.getInt("material_id");
                                String title = rsMaterials.getString("title");
                                String materialDescription = rsMaterials.getString("description");
                                String fileName = rsMaterials.getString("file_name");
                                Timestamp uploadedAt = rsMaterials.getTimestamp("uploaded_at");
                        %>
                        <tr>
                            <td><%= title != null ? title : "N/A" %></td>
                            <td><%= materialDescription != null ? materialDescription.substring(0, Math.min(materialDescription.length(), 50)) + (materialDescription.length() > 50 ? "..." : "") : "N/A" %></td>
                            <td><%= fileName != null ? fileName : "N/A" %></td>
                            <td><%= uploadedAt != null ? uploadedAt : "N/A" %></td>
                            <td>
                                <a href="DownloadMaterialServlet?materialId=<%= materialId %>" class="btn btn-custom">Download</a>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<p class='text-danger'>Error fetching materials: " + e.getMessage() + "</p>");
                    } finally {
                        if (rsMaterials != null) try { rsMaterials.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (psMaterials != null) try { psMaterials.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>
            
                <!-- Created Tests -->
                <h3>Created Tests</h3>
                <%
                    PreparedStatement psTests = null;
                    ResultSet rsTests = null;
                    try {
                        psTests = con.prepareStatement(
                            "SELECT test_id, test_name, schedule_time, end_time FROM MCQ_Tests WHERE course_id = ? ORDER BY schedule_time DESC"
                        );
                        psTests.setInt(1, courseId);
                        rsTests = psTests.executeQuery();
                        if (!rsTests.isBeforeFirst()) {
                            out.println("<p>No tests created for this course.</p>");
                        } else {
                %>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Test Name</th>
                            <th>Schedule Time</th>
                            <th>End Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            java.util.Date currentTime = new java.util.Date();
                            while (rsTests.next()) {
                                int testId = rsTests.getInt("test_id");
                                String testName = rsTests.getString("test_name");
                                Timestamp scheduleTime = rsTests.getTimestamp("schedule_time");
                                Timestamp endTime = rsTests.getTimestamp("end_time");
                                String status = "Active";
                                if (endTime != null && endTime.before(currentTime)) {
                                    status = "Completed";
                                } else if (endTime == null && scheduleTime != null && scheduleTime.before(currentTime)) {
                                    status = "Active (No End Time)";
                                }
                        %>
                        <tr>
                            <td><%= testName != null ? testName : "N/A" %></td>
                            <td><%= scheduleTime != null ? scheduleTime : "N/A" %></td>
                            <td><%= endTime != null ? endTime : "N/A" %></td>
                            <td><%= status %></td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<p class='text-danger'>Error fetching tests: " + e.getMessage() + "</p>");
                    } finally {
                        if (rsTests != null) try { rsTests.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (psTests != null) try { psTests.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>

                <!-- Enrolled Students -->
                <h3>Enrolled Students</h3>
                <%
                    PreparedStatement psEnrollments = null;
                    ResultSet rsEnrollments = null;
                    try {
                        psEnrollments = con.prepareStatement(
                            "SELECT student_email, enrolled_at FROM enrollments WHERE course_id = ? ORDER BY enrolled_at DESC"
                        );
                        psEnrollments.setInt(1, courseId);
                        rsEnrollments = psEnrollments.executeQuery();
                        if (!rsEnrollments.isBeforeFirst()) {
                            out.println("<p>No students enrolled in this course.</p>");
                        } else {
                %>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Student Email</th>
                            <th>Enrolled At</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rsEnrollments.next()) {
                                String studentEmail = rsEnrollments.getString("student_email");
                                Timestamp enrolledAt = rsEnrollments.getTimestamp("enrolled_at");
                        %>
                        <tr>
                            <td><%= studentEmail != null ? studentEmail : "N/A" %></td>
                            <td><%= enrolledAt != null ? enrolledAt : "N/A" %></td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<p class='text-danger'>Error fetching enrolled students: " + e.getMessage() + "</p>");
                    } finally {
                        if (rsEnrollments != null) try { rsEnrollments.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (psEnrollments != null) try { psEnrollments.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>
            </div>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<p class='text-danger'>Error: " + e.getMessage() + "</p>");
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            %>
        </div>
    </div>

    <!-- Calendar Container -->
    <div id="calendar-container">
        <button id="calendar-toggle-up" onclick="toggleCalendar()">▲</button>
        <button id="calendar-toggle-down" onclick="toggleCalendar()">▼</button>
        <div id="calendar"></div>
    </div>

    <!-- Modal for Date Tasks -->
    <div class="modal fade" id="dateTasksModal" tabindex="-1" aria-labelledby="dateTasksModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="dateTasksModalLabel">Tasks for Selected Date</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="dateTasksContent"></div>
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
        const staticSections = ['createCourse', 'liveClasses', 'createMCQTest', 'uploadMaterials', 'enrollmentRequests', 'results', 'myCourses', 'queries'];
        const courseSections = Array.from(document.querySelectorAll('[id^="course_"]')).map(el => el.id);
        const allSections = [...staticSections, ...courseSections];
        
        allSections.forEach(id => {
            const element = document.getElementById(id);
            if (element) {
                element.classList.toggle('active', id === sectionId);
                element.style.display = id === sectionId ? 'block' : 'none';
            }
        });
        
        if (sectionId === 'queries') {
            document.getElementById('chatContainer').classList.remove('show');
        }
    }

    function toggleCalendar() {
        const calendar = document.getElementById("calendar");
        const toggleUp = document.getElementById("calendar-toggle-up");
        const toggleDown = document.getElementById("calendar-toggle-down");
        
        calendar.classList.toggle("expanded");
        toggleUp.style.display = calendar.classList.contains("expanded") ? "none" : "block";
        toggleDown.style.display = calendar.classList.contains("expanded") ? "block" : "none";
    }

    let questionCount = 1;
    function addQuestion() {
        questionCount++;
        const container = document.getElementById('questionsContainer');
        const newQuestion = document.createElement('div');
        newQuestion.className = 'question mb-3';
        newQuestion.innerHTML = `
            <label>Question ${questionCount}</label>
            <input type="text" class="form-control mb-2" name="questionText[]" placeholder="Enter question" required>
            <input type="text" class="form-control mb-2" name="optionA[]" placeholder="Option A" required>
            <input type="text" class="form-control mb-2" name="optionB[]" placeholder="Option B" required>
            <input type="text" class="form-control mb-2" name="optionC[]" placeholder="Option C" required>
            <input type="text" class="form-control mb-2" name="optionD[]" placeholder="Option D" required>
            <select class="form-select" name="correctAnswer[]" required>
                <option value="">Select Correct Answer</option>
                <option value="A">A</option>
                <option value="B">B</option>
                <option value="C">C</option>
                <option value="D">D</option>
            </select>
        `;
        container.appendChild(newQuestion);
    }

    function updateTestOptions() {
        const courseId = document.getElementById('courseSelect').value;
        const testSelect = document.getElementById('testSelect');
        testSelect.innerHTML = '<option value="">Select Test</option>';
        if (courseId) {
            fetch('<%= request.getContextPath() %>/FacultyResultsServlet?courseId=' + encodeURIComponent(courseId) + '&action=getTests')
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
                    if ('<%= selectedTestId %>') {
                        testSelect.value = '<%= selectedTestId %>';
                    }
                })
                .catch(error => {
                    console.error('Error fetching tests:', error);
                    testSelect.innerHTML = '<option value="">Error loading tests</option>';
                });
        }
    }

    function openCourse(courseId, courseName) {
        const chatContainer = document.getElementById("chatContainer");
        chatContainer.classList.add("show");
        fetchStudents(courseId, courseName);
    }

    function fetchStudents(courseId, courseName) {
        const studentList = document.getElementById("studentList");
        studentList.innerHTML = "<h4>Students</h4><p>Loading students...</p>";
        fetch('<%= request.getContextPath() %>/FetchStudentsServlet?courseId=' + encodeURIComponent(courseId))
            .then(response => {
                if (!response.ok) throw new Error('Failed to fetch students: ' + response.statusText);
                return response.json();
            })
            .then(data => {
                studentList.innerHTML = "<h4>Students</h4>";
                if (data.status === "success" && data.students.length > 0) {
                    data.students.forEach(student => {
                        const div = document.createElement("div");
                        div.className = "student-item";
                        div.textContent = student.name;
                        div.onclick = () => openChat(student.email, student.name);
                        studentList.appendChild(div);
                    });
                } else {
                    studentList.innerHTML += "<p>No students enrolled.</p>";
                }
            })
            .catch(error => {
                console.error('Error fetching students:', error);
                studentList.innerHTML = "<h4>Students</h4><p>Error loading students: " + error.message + "</p>";
            });
    }

    async function fetchStudentName(email) {
        try {
            const response = await fetch('<%= request.getContextPath() %>/FetchStudentNameServlet?email=' + encodeURIComponent(email));
            if (!response.ok) throw new Error('Failed to fetch student name');
            const data = await response.json();
            return data.status === "success" ? data.name : email;
        } catch (error) {
            console.error('Error fetching student name:', error);
            return email;
        }
    }

    function openChat(studentEmail, studentName) {
        const chatStudent = document.getElementById("chatStudent");
        const receiverEmail = document.getElementById("receiverEmail");
        chatStudent.textContent = studentName;
        receiverEmail.value = studentEmail;
        fetchMessages(studentEmail);
    }

    function closeChat() {
        const chatContainer = document.getElementById("chatContainer");
        chatContainer.classList.remove("show");
    }

    function fetchMessages(studentEmail) {
        const facultyEmail = '<%= session.getAttribute("email") %>';
        fetch('<%= request.getContextPath() %>/FetchMessagesServlet?otherEmail=' + encodeURIComponent(studentEmail) + '&courseId=0')
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
                        div.className = "message " + (msg.senderEmail === facultyEmail ? "sent" : "received");
                        const timestamp = new Date(msg.sentAt).toLocaleString();
                        div.innerHTML = "<p>" + msg.content.replace(/[-\u001F\u007F-\u009F]/g, '') + "</p><div class='timestamp'>" + timestamp + "</div>";
                        chatMessages.appendChild(div);
                    });
                    chatMessages.scrollTop = chatMessages.scrollHeight;
                } else {
                    chatMessages.innerHTML = '<p class="no-messages">No messages yet.</p>';
                }
            })
            .catch(error => {
                console.error('Error fetching messages:', error);
                document.getElementById("chatMessages").innerHTML = '<p>Error loading messages: ' + error.message + '</p>';
            });
    }

    function sendMessage() {
        const messageInput = document.getElementById("messageInput");
        const receiverEmail = document.getElementById("receiverEmail").value;
        const content = messageInput.value.trim();
        if (!content) {
            alert("Please enter a message.");
            return;
        }

        const facultyEmail = '<%= session.getAttribute("email") %>';
        const messageData = {
            senderEmail: facultyEmail,
            receiverEmail: receiverEmail,
            content: content,
            courseId: 0
        };

        fetch('<%= request.getContextPath() %>/SendMessageServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(messageData)
        })
            .then(response => {
                if (!response.ok) throw new Error('Failed to send message');
                return response.json();
            })
            .then(data => {
                if (data.status === "success") {
                    messageInput.value = "";
                    fetchMessages(receiverEmail);
                } else {
                    alert("Failed to send message: " + data.message);
                }
            })
            .catch(error => {
                console.error('Error sending message:', error);
                alert("Error sending message: " + error.message);
            });
    }

    function fetchTasks(date) {
        const tasksContent = document.getElementById('dateTasksContent');
        tasksContent.innerHTML = '<p>Loading...</p>';
        const events = [
            <%
                Connection conn = null;
                PreparedStatement pss = null;
                ResultSet rss = null;
                try {
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                    conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                    String email = (String) session.getAttribute("email");
                    pss = conn.prepareStatement(
                        "SELECT c.course_name, l.meet_link, l.schedule_time " +
                        "FROM LiveClasses l JOIN Courses c ON l.course_id = c.course_id " +
                        "WHERE c.faculty_email = ?"
                    );
                    pss.setString(1, email);
                    rss = pss.executeQuery();
                    while (rss.next()) {
                        String courseName = rss.getString("course_name").replace("'", "\\'");
                        String meetLink = rss.getString("meet_link");
                        Timestamp scheduleTime = rss.getTimestamp("schedule_time");
                        String eventDate = scheduleTime.toString().substring(0, 10);
            %>
            {
                courseName: '<%= courseName %>',
                meetLink: '<%= meetLink.replace("'", "\\'") %>',
                scheduleTime: '<%= scheduleTime %>',
                date: '<%= eventDate %>'
            },
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rss != null) try { rss.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (pss != null) try { pss.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            %>
        ];
    }
	</script>
</body>
</html>