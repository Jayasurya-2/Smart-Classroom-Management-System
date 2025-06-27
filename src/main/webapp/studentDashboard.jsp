<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat, java.time.Instant" %>
<%
    // Session validation
    if (session.getAttribute("email") == null || session.getAttribute("name") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - JAAS Institute</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300..700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
    <style>
        body { font-family: "Space Grotesk", sans-serif; background-color: #f0faff; color: #333; margin: 0; padding: 0; }
        .dashboard-header { background-color: #4070f4; color: #fff; padding: 30px; text-align: center; margin-bottom: 20px; border-radius: 10px 10px 0 0; }
        .header-container { 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            position: relative; 
            padding: 15px 0; 
            background-color: #fff; 
            border-bottom: 1px solid #ddd; 
        }
        .header-title { 
            font-size: 1.5rem; 
            font-weight: bold; 
            color: #333; 
            margin: 0; 
        }
        .profile-dropdown { 
            position: absolute; 
            right: 20px; 
            top: 50%; 
            transform: translateY(-50%); 
        }
        .sidebar { 
            width: 280px; 
            background: #f8f9fa; 
            transition: transform 0.3s ease; 
            position: fixed; 
            top: 0; 
            left: 0; 
            height: 100%; 
            z-index: 1000; 
            overflow-y: auto; 
            padding-top: 70px; 
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1); 
        }
        .sidebar.collapsed { transform: translateX(-280px); }
        .hamburger { 
            font-size: 24px; 
            cursor: pointer; 
            position: fixed; 
            top: 20px; 
            left: 20px; 
            z-index: 1100; 
            color: #4070f4; 
            background: none; 
            border: none; 
            transition: color 0.3s ease; 
        }
        .hamburger:hover { color: #3050d0; }
        .content-wrapper { 
            width: calc(100% - 280px); 
            margin-left: 280px; 
            transition: margin-left 0.3s ease, width 0.3s ease; 
            padding: 0; 
            min-height: 100vh; 
            background-color: #fff; 
            border-radius: 10px; 
        }
        .content-wrapper.expanded { 
            width: 90%; 
            margin-left: auto; 
            margin-right: auto; 
        }
        .profile-icon { width: 40px; height: 40px; border-radius: 50%; cursor: pointer; transition: transform 0.2s ease; }
        .profile-icon:hover { transform: scale(1.1); }
        .dropdown-menu { display: none; position: absolute; right: 0; background-color: #fff; min-width: 180px; box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.15); border-radius: 8px; z-index: 100; padding: 10px 0; text-align: left; }
        .dropdown-menu.show { display: block; }
        .dropdown-menu span, .dropdown-menu a { display: block; padding: 10px 15px; text-decoration: none; color: #333; font-size: 16px; font-family: "Space Grotesk", sans-serif; transition: background-color 0.3s ease, color 0.3s ease; }
        .dropdown-menu span { font-weight: 500; color: #4070f4; border-bottom: 1px solid #f0f0f0; }
        .dropdown-menu a { color: #555; }
        .dropdown-menu a:hover { background-color: #4070f4; color: #fff; }
        .form-section { background-color: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); margin-bottom: 20px; width: 100%; }
        .btn-custom { background-color: #4070f4; color: #fff; }
        .btn-custom:hover { background-color: #3050d0; }
        .btn-enroll { background-color: #28a745; color: #fff; }
        .btn-enroll:hover { background-color: #218838; }
        .alert81 { margin-bottom: 20px; width: 100%; }
        .course-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); 
            gap: 20px; 
            padding: 10px; 
        }
        .course-card { 
            background-color: #fff; 
            padding: 20px; 
            border-radius: 8px; 
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); 
            transition: transform 0.2s ease; 
        }
        .course-card:hover { transform: translateY(-5px); }
        .course-card h3 { margin-top: 0; font-size: 1.5em; }
        .course-card p { margin: 10px 0; }
        #calendar { 
            position: fixed; 
            bottom: 20px; 
            right: 20px; 
            width: 400px; 
            background-color: #fff; 
            border-radius: 10px; 
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); 
            z-index: 1000; 
            transition: height 0.3s ease; 
            overflow: hidden; 
        }
        #calendar.collapsed { 
            height: 40px; 
            width: 40px; 
            padding: 0; 
        }
        #calendar.expanded { 
            height: 450px; 
            width: 400px; 
            padding: 10px; 
        }
        #calendar.collapsed .calendar-content { 
            display: none; 
        }
        #calendar.expanded .calendar-content { 
            display: block; 
            height: 400px; 
            overflow-y: auto; 
        }
        .calendar-toggle { 
            background: none; 
            border: none; 
            font-size: 24px; 
            color: #4070f4; 
            cursor: pointer; 
            transition: color 0.3s ease; 
            width: 40px; 
            height: 40px; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            z-index: 1001; 
        }
        #calendar.collapsed .calendar-toggle { 
            position: absolute; 
            top: 0; 
            left: 0; 
        }
        #calendar.expanded .calendar-toggle { 
            position: fixed; 
            bottom: 470px; 
            right: 30px; 
        }
        .calendar-toggle:hover { color: #3050d0; }
        .calendar-toggle.collapsed::before { 
            content: "▲"; 
        }
        .calendar-toggle.expanded::before { 
            content: "▼"; 
        }
        .calendar-toggle.collapsed:hover::after { 
            content: "Show Calendar"; 
            position: absolute; 
            left: 50px; 
            background-color: #4070f4; 
            color: #fff; 
            padding: 2px 8px; 
            border-radius: 5px; 
            font-size: 14px; 
            white-space: nowrap; 
        }
        .calendar-toggle.expanded:hover::after { 
            content: "Hide Calendar"; 
            position: absolute; 
            right: 50px; 
            background-color: #4070f4; 
            color: #fff; 
            padding: 2px 8px; 
            border-radius: 5px; 
            font-size: 14px; 
            white-space: nowrap; 
        }
        /* Custom Calendar Styles */
        .fc { font-family: "Space Grotesk", sans-serif; }
        .fc .fc-toolbar { background: #4070f4; color: #fff; border-radius: 5px; padding: 10px; margin-bottom: 10px; }
        .fc .fc-toolbar-title { font-size: 1.5em; font-weight: 600; }
        .fc .fc-button { 
            background: #3050d0; 
            border: none; 
            color: #fff; 
            border-radius: 5px; 
            padding: 5px 10px; 
            font-size: 14px; 
        }
        .fc .fc-button:hover { background: #2040a0; }
        .fc .fc-button-primary:not(:disabled).fc-button-active { background: #2040a0; }
        .fc .fc-daygrid-day { background: #f8f9fa; }
        .fc .fc-daygrid-day:hover { background: #e0e7ff; }
        .fc .fc-event { 
            border-radius: 3px; 
            font-size: 12px; 
            padding: 2px 5px; 
            border: none; 
        }
        .fc .fc-event.class { background: #4070f4; color: #fff; }
        .fc .fc-event.test { background: #ff4d4d; color: #fff; }
        .fc .fc-daygrid-day-number { color: #333; }
        .fc .fc-col-header-cell { background: #4070f4; color: #fff; }
        .fc-daygrid-body { width: 100% !important; }
        .fc-scroller { overflow-y: auto !important; }
        .chat-container { 
            display: none; 
            position: fixed; 
            bottom: 20px; 
            right: 20px; 
            width: 600px; 
            max-width: 90%; 
            height: 600px; 
            background-color: #fff; 
            border-radius: 10px; 
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2); 
            z-index: 1100; 
            overflow: hidden; 
        }
        .chat-container.show { display: flex; }
        .chat-sidebar { width: 30%; background-color: #f8f9fa; border-right: 1px solid #ddd; overflow-y: auto; max-height: 100%; }
        .chat-area { width: 70%; display: flex; flex-direction: column; }
        .chat-header { background-color: #4070f4; color: #fff; padding: 10px; font-size: 16px; font-weight: 500; position: relative; }
        .chat-messages { flex: 1; padding: 15px; overflow-y: auto; background-color: #e5ddd5; }
        .chat-input { border-top: 1px solid #ddd; padding: 10px; background-color: #fff; }
        .chat-input form { display: flex; gap: 10px; }
        .chat-input input { flex: 1; padding: 8px; border: 1px solid #ddd; border-radius: 20px; font-size: 14px; }
        .chat-input button { background-color: #4070f4; color: #fff; border: none; padding: 8px 15px; border-radius: 20px; cursor: pointer; }
        .chat-input button:hover { background-color: #3050d0; }
        .faculty-item { padding: 15px; border-bottom: 1px solid #ddd; cursor: pointer; transition: background-color 0.2s; }
        .faculty-item:hover { background-color: #e0e7ff; }
        .faculty-item.active { background-color: #d0d9ff; }
        .message { margin-bottom: 10px; max-width: 70%; padding: 8px 12px; border-radius: 10px; font-size: 14px; }
        .message.sent { background-color: #dcf8c6; margin-left: auto; }
        .message.received { background-color: #fff; margin-right: auto; }
        .message .timestamp { font-size: 10px; color: #666; margin-top: 4px; }
        .no-messages { font-style: italic; color: #777; text-align: center; margin-top: 20px; }
        .close-chat { 
            position: absolute; 
            top: 10px; 
            right: 10px; 
            background: #ff4d4d; 
            color: #fff; 
            border: none; 
            border-radius: 50%; 
            width: 24px; 
            height: 24px; 
            line-height: 24px; 
            text-align: center; 
            cursor: pointer; 
            font-size: 14px; 
        }
        .close-chat:hover { background: #cc0000; }
        #queries { position: relative; }
        #queries .form-section { padding-bottom: 620px; }
        @media (max-width: 768px) {
            .sidebar { transform: translateX(-280px); }
            .sidebar.collapsed { transform: translateX(0); }
            .content-wrapper { margin-left: 0; width: 100%; }
            #calendar.collapsed { width: 40px; height: 40px; right: 10px; bottom: 10px; }
            #calendar.expanded { width: 100%; right: 0; bottom: 0; height: 400px; }
            #calendar.expanded .calendar-toggle { bottom: 410px; right: 10px; }
            #calendar.expanded .calendar-content { height: 350px; }
            .form-section, .course-card, .alert81 { width: 100%; }
            .chat-container { width: 100%; height: 100%; right: 0; bottom: 0; border-radius: 0; }
            .chat-sidebar { width: 40%; }
            .chat-area { width: 60%; }
            .course-grid { grid-template-columns: 1fr; }
            #queries .form-section { padding-bottom: 100%; }
        }
        .performance-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .performance-table th, .performance-table td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        .performance-table th { background-color: #4070f4; color: #fff; }
        .performance-table tr:nth-child(even) { background-color: #f9f9f9; }
        .performance-table tr:hover { background-color: #e0e7ff; }
        .no-data { font-style: italic; color: #777; }
        .material-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .material-table th, .material-table td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        .material-table th { background-color: #4070f4; color: #fff; }
        .material-table tr:nth-child(even) { background-color: #f9f9f9; }
        .material-table tr:hover { background-color: #e0e7ff; }
        .test-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .test-table th, .test-table td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        .test-table th { background-color: #4070f4; color: #fff; }
        .test-table tr:nth-child(even) { background-color: #f9f9f9; }
        .test-table tr:hover { background-color: #e0e7ff; }
        .sidebar .nav-link { 
            color: #333; 
            padding: 12px 20px; 
            border-radius: 8px; 
            margin: 5px 10px; 
            transition: background-color 0.3s ease, transform 0.2s ease, color 0.3s ease; 
            position: relative; 
            overflow: hidden; 
        }
        .sidebar .nav-link:hover { 
            background: linear-gradient(135deg, #4070f4 0%, #3050d0 100%); 
            color: #fff; 
            transform: translateX(5px); 
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
    </style>
</head>
<body>
    <header class="header-container">
        <h1 class="header-title">JAAS Institute</h1>
        <div class="profile-dropdown">
            <div class="dropdown">
                <img src="asserts/default-profile.png" id="profileIcon" alt="Profile" class="profile-icon" onclick="toggleDropdown()">
                <div class="dropdown-menu" id="dropdownMenu">
                    <span>Welcome 😊, <%= session.getAttribute("name") %></span>
                    <a href="profile.jsp">My Profile</a>
                    <a href="#" onclick="logout()">Logout</a>
                </div>
            </div>
        </div>
    </header>
    <button class="hamburger" onclick="toggleSidebar()">☰</button>
    <div class="d-flex min-vh-100">
        <div class="sidebar d-flex flex-column flex-shrink-0 p-3" id="sidebar">
            <hr>
            <ul class="nav nav-pills flex-column mb-auto">
                <li class="nav-item"><a href="#myCourses" class="nav-link" onclick="showSection('myCourses')">My Courses</a></li>
                <li><a href="#performance" class="nav-link" onclick="showSection('performance')">My Performance</a></li>
                <li><a href="#availableCourses" class="nav-link" onclick="showSection('availableCourses')">Available Courses</a></li>
                <li><a href="#materials" class="nav-link" onclick="showSection('materials')">Course Materials</a></li>
                <li><a href="#queries" class="nav-link" onclick="showSection('queries')">Queries</a></li>
                <li><a href="#availableTests" class="nav-link" onclick="showSection('availableTests')">Available Tests</a></li>
            </ul>
        </div>
        <div class="content-wrapper" id="contentWrapper">
            <div class="dashboard-header">
                <h1>Welcome, <%= session.getAttribute("name") %>!</h1>
                <p>Your Student Dashboard</p>
            </div>
            <% 
                String message = (String) request.getAttribute("message");
                String messageType = (String) request.getAttribute("messageType");
                if (message != null) {
            %>
                <div class="alert81 <%= messageType.equals("success") ? "alert-success" : messageType.equals("warning") ? "alert-warning" : messageType.equals("info") ? "alert-info" : "alert-danger" %>" role="alert">
                    <%= message %>
                </div>
            <% } %>
            <div id="myCourses" class="form-section" style="display: block;">
                <h2>My Courses</h2>
                <div class="course-grid">
                    <%
                        Connection con = null;
                        PreparedStatement ps = null;
                        ResultSet rs = null;
                        boolean hasCourses = false;
                        try {
                            Class.forName("oracle.jdbc.driver.OracleDriver");
                            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                            String email = (String) session.getAttribute("email");
                            ps = con.prepareStatement(
                                "SELECT c.course_id, c.course_name, c.description " +
                                "FROM Enrollments e JOIN Courses c ON e.course_id = c.course_id " +
                                "WHERE e.student_email = ?"
                            );
                            ps.setString(1, email);
                            rs = ps.executeQuery();
                            if (rs.isBeforeFirst()) {
                                hasCourses = true;
                            }
                            while (rs.next()) {
                                int courseId = rs.getInt("course_id");
                                String courseName = rs.getString("course_name");
                                String description = rs.getString("description");
                    %>
                                <div class="course-card">
                                    <h3><%= courseName %></h3>
                                    <p><strong>Description:</strong> <%= description %></p>
                                    <a href="#course_<%= courseId %>" class="btn btn-custom" onclick="showSection('course_<%= courseId %>')">View Details</a>
                                </div>
                    <%
                            }
                            if (!hasCourses) {
                                out.println("<p>No enrolled courses found.</p>");
                            }
                        } catch (Exception e) {
                            out.println("<p class='text-danger'>Error loading courses: " + e.getMessage() + "</p>");
                            e.printStackTrace();
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    %>
                </div>
            </div>
            <div id="performance" class="form-section" style="display: none;">
                <h2>My Performance</h2>
                <%
                    con = null;
                    ps = null;
                    rs = null;
                    try {
                        Class.forName("oracle.jdbc.driver.OracleDriver");
                        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                        String email = (String) session.getAttribute("email");
                        ps = con.prepareStatement(
                            "SELECT ms.score, ms.submitted_at, mt.test_name, c.course_name, " +
                            "(SELECT COUNT(*) FROM MCQ_Questions mq WHERE mq.test_id = mt.test_id) as total_conducted_marks " +
                            "FROM MCQ_Submissions ms " +
                            "JOIN MCQ_Tests mt ON ms.test_id = mt.test_id " +
                            "JOIN Courses c ON mt.course_id = c.course_id " +
                            "WHERE ms.student_email = ? " +
                            "ORDER BY ms.submitted_at DESC"
                        );
                        ps.setString(1, email);
                        rs = ps.executeQuery();
                        boolean hasSubmissions = rs.isBeforeFirst();
                %>
                        <table class="performance-table">
                            <thead>
                                <tr>
                                    <th>Test Name</th>
                                    <th>Course</th>
                                    <th>Score</th>
                                    <th>Percentage</th>
                                    <th>Submitted At</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
                                    while (rs.next()) {
                                        int score = rs.getInt("score");
                                        int totalConductedMarks = rs.getInt("total_conducted_marks");
                                        double percentage = totalConductedMarks != 0 ? (score * 100.0 / totalConductedMarks) : 0.0;
                                        String formattedPercentage = String.format("%.2f%%", percentage);
                                        Timestamp submittedAt = rs.getTimestamp("submitted_at");
                                        String testName = rs.getString("test_name");
                                        String courseName = rs.getString("course_name");
                                        String formattedDate = sdf.format(submittedAt);
                                %>
                                    <tr>
                                        <td><%= testName %></td>
                                        <td><%= courseName %></td>
                                        <td><%= score %>/<%= totalConductedMarks %></td>
                                        <td><%= formattedPercentage %></td>
                                        <td><%= formattedDate %></td>
                                    </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                        <% if (!hasSubmissions) { %>
                            <p class="no-data">No submissions yet.</p>
                        <% } %>
                <%
                    } catch (Exception e) {
                        out.println("<p class='text-danger'>Error loading performance data: " + e.getMessage() + "</p>");
                        e.printStackTrace();
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>
            </div>
            <div id="availableCourses" class="form-section" style="display: none;">
                <h2>Available Courses</h2>
                <div class="course-grid">
                    <%
                        con = null;
                        PreparedStatement psCourses = null;
                        PreparedStatement psEnrolled = null;
                        ResultSet rsCourses = null;
                        ResultSet rsEnrolled = null;
                        boolean hasAvailableCourses = false;
                        try {
                            Class.forName("oracle.jdbc.driver.OracleDriver");
                            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                            String email = (String) session.getAttribute("email");
                            psCourses = con.prepareStatement(
                                "SELECT course_id, course_name, description, faculty_email " +
                                "FROM Courses"
                            );
                            rsCourses = psCourses.executeQuery();
                            if (rsCourses.isBeforeFirst()) {
                                hasAvailableCourses = true;
                            }
                            psEnrolled = con.prepareStatement(
                                "SELECT course_id FROM Enrollments WHERE student_email = ?"
                            );
                            psEnrolled.setString(1, email);
                            rsEnrolled = psEnrolled.executeQuery();
                            Set<Integer> enrolledCourseIds = new HashSet<>();
                            while (rsEnrolled.next()) {
                                enrolledCourseIds.add(rsEnrolled.getInt("course_id"));
                            }
                            while (rsCourses.next()) {
                                int courseId = rsCourses.getInt("course_id");
                                String courseName = rsCourses.getString("course_name");
                                String description = rsCourses.getString("description");
                                String facultyEmail = rsCourses.getString("faculty_email");
                    %>
                                <div class="course-card">
                                    <h3><%= courseName %></h3>
                                    <p><strong>Description:</strong> <%= description %></p>
                                    <p><strong>Faculty:</strong> <%= facultyEmail %></p>
                                    <% if (enrolledCourseIds.contains(courseId)) { %>
                                        <span class="badge bg-success">Enrolled</span>
                                    <% } else { %>
                                        <form action="RequestEnrollmentServlet" method="post" style="display: inline;">
                                            <input type="hidden" name="courseId" value="<%= courseId %>">
                                            <button type="submit" class="btn btn-enroll">Enroll</button>
                                        </form>
                                    <% } %>
                                </div>
                    <%
                            }
                            if (!hasAvailableCourses) {
                                out.println("<p>No courses available.</p>");
                            }
                        } catch (Exception e) {
                            out.println("<p class='text-danger'>Error loading available courses: " + e.getMessage() + "</p>");
                            e.printStackTrace();
                        } finally {
                            if (rsCourses != null) try { rsCourses.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (rsEnrolled != null) try { rsEnrolled.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (psCourses != null) try { psCourses.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (psEnrolled != null) try { psEnrolled.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    %>
                </div>
            </div>
            <div id="materials" class="form-section" style="display: none;">
                <h2>Course Materials</h2>
                <%
                    con = null;
                    ps = null;
                    rs = null;
                    try {
                        Class.forName("oracle.jdbc.driver.OracleDriver");
                        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                        String email = (String) session.getAttribute("email");
                        ps = con.prepareStatement(
                            "SELECT m.material_id, m.course_id, m.title, m.description, m.file_name, m.uploaded_at, c.course_name " +
                            "FROM Course_Materials m " +
                            "JOIN Courses c ON m.course_id = c.course_id " +
                            "JOIN Enrollments e ON c.course_id = e.course_id " +
                            "WHERE e.student_email = ? " +
                            "ORDER BY m.uploaded_at DESC"
                        );
                        ps.setString(1, email);
                        rs = ps.executeQuery();
                        boolean hasMaterials = rs.isBeforeFirst();
                %>
                        <table class="material-table">
                            <thead>
                                <tr>
                                    <th>Course</th>
                                    <th>Title</th>
                                    <th>Description</th>
                                    <th>File Name</th>
                                    <th>Uploaded At</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
                                    while (rs.next()) {
                                        int materialId = rs.getInt("material_id");
                                        String courseName = rs.getString("course_name");
                                        String title = rs.getString("title");
                                        String description = rs.getString("description");
                                        String fileName = rs.getString("file_name");
                                        Timestamp uploadedAt = rs.getTimestamp("uploaded_at");
                                        String formattedDate = sdf.format(uploadedAt);
                                %>
                                    <tr>
                                        <td><%= courseName %></td>
                                        <td><%= title %></td>
                                        <td><%= description %></td>
                                        <td><%= fileName %></td>
                                        <td><%= formattedDate %></td>
                                        <td>
                                            <a href="DownloadMaterialServlet?materialId=<%= materialId %>" class="btn btn-custom">Download</a>
                                        </td>
                                    </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                        <% if (!hasMaterials) { %>
                            <p class="no-data">No course materials available.</p>
                        <% } %>
                <%
                    } catch (Exception e) {
                        out.println("<p class='text-danger'>Error loading course materials: " + e.getMessage() + "</p>");
                        e.printStackTrace();
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>
            </div>
            <div id="queries" class="form-section" style="display: none;">
                <h2>Queries</h2>
            </div>
            <div id="availableTests" class="form-section" style="display: none;">
                <h2>Available Tests</h2>
                <%
                    con = null;
                    PreparedStatement psTests = null;
                    ResultSet rsTests = null;
                    try {
                        Class.forName("oracle.jdbc.driver.OracleDriver");
                        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                        String email = (String) session.getAttribute("email");
                        psTests = con.prepareStatement(
                            "SELECT mt.test_id, mt.test_name, mt.schedule_time, mt.end_time, c.course_name " +
                            "FROM MCQ_Tests mt " +
                            "JOIN Courses c ON mt.course_id = c.course_id " +
                            "JOIN Enrollments e ON c.course_id = e.course_id " +
                            "WHERE e.student_email = ?"
                        );
                        psTests.setString(1, email);
                        rsTests = psTests.executeQuery();
                        boolean hasTests = rsTests.isBeforeFirst();
                %>
                        <table class="test-table">
                            <thead>
                                <tr>
                                    <th>Test Name</th>
                                    <th>Course</th>
                                    <th>Start Time</th>
                                    <th>End Time</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
                                    long currentTime = Instant.now().toEpochMilli();
                                    while (rsTests.next()) {
                                        int testId = rsTests.getInt("test_id");
                                        String testName = rsTests.getString("test_name");
                                        String courseName = rsTests.getString("course_name");
                                        Timestamp scheduleTime = rsTests.getTimestamp("schedule_time");
                                        Timestamp endTime = rsTests.getTimestamp("end_time");
                                        String formattedStartTime = scheduleTime != null ? sdf.format(scheduleTime) : "N/A";
                                        String formattedEndTime = endTime != null ? sdf.format(endTime) : "N/A";
                                        
                                        String status;
                                        if (scheduleTime != null && currentTime < scheduleTime.getTime()) {
                                            status = "Scheduled";
                                        } else if ((scheduleTime == null || currentTime >= scheduleTime.getTime()) && 
                                                   (endTime == null || currentTime <= endTime.getTime())) {
                                            status = "Active";
                                        } else {
                                            status = "Closed";
                                        }
                                        
                                        PreparedStatement psAttempt = con.prepareStatement(
                                            "SELECT ATTEMPTED FROM MCQ_Submissions WHERE test_id = ? AND student_email = ?"
                                        );
                                        psAttempt.setInt(1, testId);
                                        psAttempt.setString(2, email);
                                        ResultSet rsAttempt = psAttempt.executeQuery();
                                        boolean hasAttempted = rsAttempt.next() && rsAttempt.getInt("ATTEMPTED") == 1;
                                        rsAttempt.close();
                                        psAttempt.close();
                                %>
                                    <tr>
                                        <td><%= testName %></td>
                                        <td><%= courseName %></td>
                                        <td><%= formattedStartTime %></td>
                                        <td><%= formattedEndTime %></td>
                                        <td><%= status %></td>
                                        <td>
                                            <%
                                                boolean canTakeTest = !hasAttempted && status.equals("Active");
                                                if (canTakeTest) {
                                            %>
                                                <a href="TakeMCQTestServlet?testId=<%= testId %>" class="btn btn-custom">Take Test</a>
                                            <% } else { %>
                                                <span class="text-muted">
                                                    <%= hasAttempted ? "Already Attempted" : (status.equals("Closed") ? "Not Attempted" : "Test Not Active") %>
                                                </span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                        <% if (!hasTests) { %>
                            <p class="no-data">No tests found.</p>
                        <% } %>
                <%
                    } catch (Exception e) {
                        out.println("<p class='text-danger'>Error loading tests: " + e.getMessage() + "</p>");
                        e.printStackTrace();
                    } finally {
                        if (rsTests != null) try { rsTests.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (psTests != null) try { psTests.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>
            </div>
            <%
                con = null;
                ps = null;
                rs = null;
                try {
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                    con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                    String email = (String) session.getAttribute("email");
                    ps = con.prepareStatement(
                        "SELECT c.course_id, c.course_name, c.description " +
                        "FROM Enrollments e JOIN Courses c ON e.course_id = c.course_id " +
                        "WHERE e.student_email = ?"
                    );
                    ps.setString(1, email);
                    rs = ps.executeQuery();
                    while (rs.next()) {
                        int courseId = rs.getInt("course_id");
                        String courseName = rs.getString("course_name");
                        String description = rs.getString("description");
            %>
                        <div id="course_<%= courseId %>" class="form-section" style="display: none;">
                            <h2><%= courseName %></h2>
                            <p><strong>Description:</strong> <%= description %></p>
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
                                %>
                                            <li><a href="<%= meetLink %>" target="_blank" onclick="return checkLink('<%= meetLink %>')"><%= meetLink %></a> - <%= scheduleTime %></li>
                                <%
                                        }
                                    } catch (Exception e) {
                                        out.println("<li class='text-danger'>Error loading live classes: " + e.getMessage() + "</li>");
                                        e.printStackTrace();
                                    } finally {
                                        if (rsLive != null) try { rsLive.close(); } catch (SQLException e) { e.printStackTrace(); }
                                        if (psLive != null) try { psLive.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    }
                                %>
                            </ul>
                        </div>
            <%
                    }
                    if (!rs.isBeforeFirst()) {
                        out.println("<div class='form-section' style='display: none;'><p>No enrolled courses found.</p></div>");
                    }
                } catch (Exception e) {
                    out.println("<p class='text-danger'>Error loading course details: " + e.getMessage() + "</p>");
                    e.printStackTrace();
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            %>
        </div>
    </div>
    <div id="calendar" class="collapsed">
        <button class="calendar-toggle collapsed" onclick="toggleCalendar()"></button>
        <div class="calendar-content">
            <!-- FullCalendar will render here -->
        </div>
    </div>
    <div id="chatContainer" class="chat-container">
        <div class="chat-sidebar">
            <div class="chat-header">Faculty</div>
            <ul id="facultyList" class="list-group">
                <%
                    con = null;
                    ps = null;
                    rs = null;
                    boolean hasFaculty = false;
                    try {
                        Class.forName("oracle.jdbc.driver.OracleDriver");
                        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                        String email = (String) session.getAttribute("email");
                        ps = con.prepareStatement(
                            "SELECT DISTINCT c.course_id, c.course_name, c.faculty_email " +
                            "FROM Enrollments e JOIN Courses c ON e.course_id = c.course_id " +
                            "WHERE e.student_email = ? AND c.faculty_email IS NOT NULL"
                        );
                        ps.setString(1, email);
                        rs = ps.executeQuery();
                        if (rs.isBeforeFirst()) {
                            hasFaculty = true;
                        }
                        while (rs.next()) {
                            int courseId = rs.getInt("course_id");
                            String courseName = rs.getString("course_name");
                            String facultyEmail = rs.getString("faculty_email");
                            String facultyName = facultyEmail.split("@")[0];
                            String[] nameParts = facultyName.split("\\.");
                            StringBuilder formattedName = new StringBuilder();
                            for (String part : nameParts) {
                                if (part.length() > 0) {
                                    formattedName.append(Character.toUpperCase(part.charAt(0)))
                                                 .append(part.substring(1).toLowerCase())
                                                 .append(" ");
                                }
                            }
                            String displayName = formattedName.toString().trim();
                %>
                            <li class="faculty-item list-group-item" 
                                data-course-id="<%= courseId %>" 
                                data-faculty-email="<%= facultyEmail %>"
                                data-faculty-name="<%= displayName %>"
                                onclick="openChat('<%= facultyEmail %>', <%= courseId %>, '<%= courseName %>', '<%= displayName %>')">
                                <strong><%= displayName %></strong>
                            </li>
                <%
                        }
                        if (!hasFaculty) {
                            out.println("<li class='no-data'>No faculty available.</li>");
                        }
                    } catch (Exception e) {
                        out.println("<li class='text-danger'>Error loading faculty: " + e.getMessage() + "</li>");
                        e.printStackTrace();
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>
            </ul>
        </div>
        <div class="chat-area">
            <div class="chat-header" id="chatHeader">
                Select a faculty to start chatting
                <button class="close-chat" onclick="closeChat()">✕</button>
            </div>
            <div class="chat-messages" id="chatMessages">
                <p class="no-messages">No messages yet.</p>
            </div>
            <div class="chat-input">
                <form id="chatForm" onsubmit="sendMessage(event)">
                    <input type="hidden" id="receiverEmail" name="receiverEmail">
                    <input type="hidden" id="courseId" name="courseId">
                    <input type="text" id="messageInput" name="content" placeholder="Type a message..." required>
                    <button type="submit">Send</button>
                </form>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js"></script>
    <script>
        console.log("StudentDashboard.jsp script started loading");
        try {
            const currentUserEmail = '<%= session.getAttribute("email") %>';
            console.log("Current user email:", currentUserEmail);

            function toggleDropdown() {
                console.log("toggleDropdown called");
                document.getElementById("dropdownMenu").classList.toggle("show");
            }

            function logout() {
                console.log("logout called");
                window.location.href = "LogoutServlet";
            }

            function toggleSidebar() {
                console.log("toggleSidebar called");
                const sidebar = document.getElementById("sidebar");
                const contentWrapper = document.getElementById("contentWrapper");
                sidebar.classList.toggle("collapsed");
                contentWrapper.classList.toggle("expanded");
            }

            function showSection(sectionId) {
                console.log("showSection called with sectionId:", sectionId);
                const staticSections = ['myCourses', 'performance', 'availableCourses', 'materials', 'queries', 'availableTests'];
                const courseSections = Array.from(document.querySelectorAll('[id^="course_"]')).map(el => el.id);
                const allSections = [...staticSections, ...courseSections];
                allSections.forEach(id => {
                    const element = document.getElementById(id);
                    if (element) {
                        element.style.display = id === sectionId ? 'block' : 'none';
                    }
                });
                const chatContainer = document.getElementById("chatContainer");
                if (sectionId === "queries") {
                    chatContainer.classList.add("show");
                } else {
                    chatContainer.classList.remove("show");
                }
            }

            function closeChat() {
                console.log("closeChat called");
                const chatContainer = document.getElementById("chatContainer");
                chatContainer.classList.remove("show");
                document.getElementById("chatHeader").textContent = "Select a faculty to start chatting";
                document.getElementById("chatMessages").innerHTML = '<p class="no-messages">No messages yet.</p>';
                document.getElementById("receiverEmail").value = "";
                document.getElementById("courseId").value = "";
                document.querySelectorAll(".faculty-item").forEach(item => item.classList.remove("active"));
            }

            window.onclick = function(event) {
                if (!event.target.matches('.profile-icon')) {
                    let dropdowns = document.getElementsByClassName("dropdown-menu");
                    for (let i = 0; i < dropdowns.length; i++) {
                        let openDropdown = dropdowns[i];
                        if (openDropdown.classList.contains("show")) {
                            openDropdown.classList.remove("show");
                        }
                    }
                }
            }

            function checkLink(url) {
                console.log("checkLink called with url:", url);
                return true;
            }

            function openChat(facultyEmail, courseId, courseName, facultyName) {
                console.log("openChat called with facultyEmail:", facultyEmail, "courseId:", courseId);
                document.getElementById("chatHeader").innerHTML = "Chat with " + facultyName + " (" + courseName + ")" +
                    '<button class="close-chat" onclick="closeChat()">✕</button>';
                document.getElementById("receiverEmail").value = facultyEmail;
                document.getElementById("courseId").value = courseId;
                document.querySelectorAll(".faculty-item").forEach(item => {
                    item.classList.remove("active");
                    if (item.dataset.facultyEmail === facultyEmail && item.dataset.courseId === courseId.toString()) {
                        item.classList.add("active");
                    }
                });
                const chatContainer = document.getElementById("chatContainer");
                chatContainer.classList.add("show");
                fetchMessages(facultyEmail, courseId);
            }

            function fetchMessages(facultyEmail, courseId) {
                console.log("fetchMessages called with facultyEmail:", facultyEmail, "courseId:", courseId);
                fetch("FetchMessagesServlet?otherEmail=" + encodeURIComponent(facultyEmail) + "&courseId=" + courseId)
                    .then(response => {
                        console.log("FetchMessagesServlet response status:", response.status);
                        if (!response.ok) {
                            return response.text().then(text => {
                                throw new Error("HTTP error " + response.status + ": " + text);
                            });
                        }
                        return response.json();
                    })
                    .then(data => {
                        console.log("FetchMessagesServlet data:", data);
                        const chatMessages = document.getElementById("chatMessages");
                        chatMessages.innerHTML = "";
                        if (data.status === "success" && data.messages.length > 0) {
                            data.messages.forEach(msg => {
                                const div = document.createElement("div");
                                div.className = "message " + (msg.senderEmail === currentUserEmail ? "sent" : "received");
                                const timestamp = new Date(msg.sentAt).toLocaleString();
                                div.innerHTML = "<p>" + msg.content + "</p><div class='timestamp'>" + timestamp + "</div>";
                                chatMessages.appendChild(div);
                            });
                            chatMessages.scrollTop = chatMessages.scrollHeight;
                        } else {
                            chatMessages.innerHTML = '<p class="no-messages">No messages yet.</p>';
                        }
                    })
                    .catch(error => {
                        console.error("Error fetching messages:", error);
                        document.getElementById("chatMessages").innerHTML = '<p class="text-danger">Error loading messages: ' + error.message + '</p>';
                    });
            }

            function sendMessage(event) {
                console.log("sendMessage called");
                event.preventDefault();
                const receiverEmail = document.getElementById("receiverEmail").value;
                const courseId = document.getElementById("courseId").value;
                const content = document.getElementById("messageInput").value;

                fetch("SendMessageServlet", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: "receiverEmail=" + encodeURIComponent(receiverEmail) + 
                          "&courseId=" + encodeURIComponent(courseId) + 
                          "&content=" + encodeURIComponent(content)
                })
                    .then(response => {
                        console.log("SendMessageServlet response status:", response.status);
                        if (!response.ok) {
                            return response.text().then(text => {
                                throw new Error("HTTP error " + response.status + ": " + text);
                            });
                        }
                        return response.json();
                    })
                    .then(data => {
                        console.log("SendMessageServlet data:", data);
                        if (data.status === "success") {
                            document.getElementById("messageInput").value = "";
                            fetchMessages(receiverEmail, courseId);
                        } else {
                            alert("Error sending message: " + data.message);
                        }
                    })
                    .catch(error => {
                        console.error("Error sending message:", error);
                        alert("Error sending message: " + error.message);
                    });
            }

            document.addEventListener('DOMContentLoaded', function() {
                console.log("DOM fully loaded, initializing calendar");
                try {
                    var calendarEl = document.getElementById('calendar').querySelector('.calendar-content');
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
                                con = null;
                                PreparedStatement psLive = null;
                                ResultSet rsLive = null;
                                PreparedStatement psTestEvents = null;
                                ResultSet rsTestEvents = null;
                                try {
                                    Class.forName("oracle.jdbc.driver.OracleDriver");
                                    con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                                    String email = (String) session.getAttribute("email");
                                    psLive = con.prepareStatement(
                                        "SELECT c.course_name, l.meet_link, l.schedule_time " +
                                        "FROM LiveClasses l JOIN Courses c ON l.course_id = c.course_id " +
                                        "JOIN Enrollments e ON c.course_id = e.course_id " +
                                        "WHERE e.student_email = ?"
                                    );
                                    psLive.setString(1, email);
                                    rsLive = psLive.executeQuery();
                                    while (rsLive.next()) {
                                        String courseName = rsLive.getString("course_name").replace("'", "\\'");
                                        String meetLink = rsLive.getString("meet_link");
                                        Timestamp scheduleTime = rsLive.getTimestamp("schedule_time");
                                        String eventDate = scheduleTime.toString().substring(0, 10);
                                        String eventTime = scheduleTime.toString().substring(11, 19);
                                        out.println("{");
                                        out.println("title: 'Class: " + courseName + " - " + eventTime + "',");
                                        out.println("start: '" + eventDate + "T" + eventTime + "',");
                                        out.println("url: '" + meetLink + "',");
                                        out.println("classNames: ['class'],");
                                        out.println("},");
                                    }
                                    rsLive.close();
                                    psLive.close();
                                    psTestEvents = con.prepareStatement(
                                        "SELECT mt.test_name, mt.schedule_time, c.course_name " +
                                        "FROM MCQ_Tests mt JOIN Courses c ON mt.course_id = c.course_id " +
                                        "JOIN Enrollments e ON c.course_id = e.course_id " +
                                        "WHERE e.student_email = ?"
                                    );
                                    psTestEvents.setString(1, email);
                                    rsTestEvents = psTestEvents.executeQuery();
                                    while (rsTestEvents.next()) {
                                        String testName = rsTestEvents.getString("test_name").replace("'", "\\'");
                                        String courseName = rsTestEvents.getString("course_name").replace("'", "\\'");
                                        Timestamp scheduleTime = rsTestEvents.getTimestamp("schedule_time");
                                        if (scheduleTime != null) {
                                            String eventDate = scheduleTime.toString().substring(0, 10);
                                            String eventTime = scheduleTime.toString().substring(11, 19);
                                            out.println("{");
                                            out.println("title: 'Test: " + testName + " (" + courseName + ") - " + eventTime + "',");
                                            out.println("start: '" + eventDate + "T" + eventTime + "',");
                                            out.println("classNames: ['test'],");
                                            out.println("},");
                                        }
                                    }
                                } catch (Exception e) {
                                    out.println("// Error loading calendar events: " + e.getMessage());
                                    e.printStackTrace();
                                } finally {
                                    if (rsLive != null) try { rsLive.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (psLive != null) try { psLive.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (rsTestEvents != null) try { rsTestEvents.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (psTestEvents != null) try { psTestEvents.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                                }
                            %>
                        ],
                        eventClick: function(info) {
                            console.log("Calendar event clicked:", info.event.title);
                            info.jsEvent.preventDefault();
                            if (info.event.url) {
                                window.open(info.event.url, '_blank');
                            }
                        }
                    });
                    calendar.render();
                    console.log("Calendar initialized successfully");
                } catch (e) {
                    console.error("Error initializing calendar:", e);
                }
            });

            function toggleCalendar() {
                console.log("toggleCalendar called");
                const calendar = document.getElementById('calendar');
                const toggleButton = document.querySelector('.calendar-toggle');
                if (calendar.classList.contains('collapsed')) {
                    calendar.classList.remove('collapsed');
                    calendar.classList.add('expanded');
                    toggleButton.classList.remove('collapsed');
                    toggleButton.classList.add('expanded');
                } else {
                    calendar.classList.add('collapsed');
                    calendar.classList.remove('expanded');
                    toggleButton.classList.add('collapsed');
                    toggleButton.classList.remove('expanded');
                }
            }

            console.log("StudentDashboard.jsp script loaded successfully");
            console.log("showSection defined:", typeof showSection === 'function');
        } catch (e) {
            console.error("Error in studentDashboard.jsp script:", e);
        }
    </script>
</body>
</html>