<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Details - JAAS Institute</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300..700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            font-family: "Space Grotesk", sans-serif;
            background-color: #f0faff;
            color: #333;
        }
        .dashboard-header {
            background-color: #4070f4;
            color: #fff;
            padding: 30px;
            text-align: center;
        }
        .content-wrapper {
            padding: 20px;
            min-height: 100vh;
        }
        .form-section {
            background-color: #fff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
        .btn-custom {
            background-color: #4070f4;
            color: #fff;
        }
        .btn-custom:hover {
            background-color: #3050d0;
        }
        .table {
            margin-top: 20px;
            width: 100%;
            table-layout: auto;
        }
        .table th, .table td {
            padding: 12px;
            text-align: left;
            white-space: nowrap;
            vertical-align: middle;
        }
        .table th {
            background-color: #f8f9fa;
            font-weight: 500;
        }
        .modal-content {
            font-family: "Space Grotesk", sans-serif;
        }
        .profile-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            cursor: pointer;
            transition: transform 0.2s ease;
        }
        .profile-icon:hover {
            transform: scale(1.1);
        }
        .dropdown-menu {
            display: none;
            position: absolute;
            right: 0;
            background-color: #fff;
            min-width: 180px;
            box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.15);
            border-radius: 8px;
            z-index: 100;
            padding: 10px 0;
            text-align: left;
        }
        .dropdown-menu.show {
            display: block;
        }
        .dropdown-menu span, .dropdown-menu a {
            display: block;
            padding: 10px 15px;
            text-decoration: none;
            color: #333;
            font-size: 16px;
            font-family: "Space Grotesk", sans-serif;
            transition: background-color 0.3s ease, color 0.3s ease;
        }
        .dropdown-menu span {
            font-weight: 500;
            color: #4070f4;
            border-bottom: 1px solid #f0f0f0;
        }
        .dropdown-menu a {
            color: #555;
        }
        .dropdown-menu a:hover {
            background-color: #4070f4;
            color: #fff;
        }
        @media (max-width: 768px) {
            .content-wrapper {
                padding: 10px;
            }
            .table {
                font-size: 14px;
            }
            .table th, .table td {
                padding: 8px;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <header class="d-flex flex-wrap align-items-center justify-content-between py-3 mb-4 border-bottom">
        <div class="col-md-3 mb-2 mb-md-0">
            <a href="facultyDashboard.jsp" class="d-inline-flex link-body-emphasis text-decoration-none">
                <span class="fs-4 fw-bold">JAAS Institute</span>
            </a>
        </div>
        <div class="col-md-3 text-end">
            <div class="dropdown">
                <img src="<%= request.getContextPath() %>/assets/default-profile.png" id="profileIcon" alt="Profile" class="profile-icon" onclick="toggleDropdown()">
                <div class="dropdown-menu" id="dropdownMenu">
                    <span>Welcome, <%= session.getAttribute("name") != null ? session.getAttribute("name") : "Faculty" %></span>
                    <a href="profile.jsp">My Profile</a>
                    <a href="#" onclick="logout()">Logout</a>
                </div>
            </div>
        </div>
    </header>

    <!-- Content Wrapper -->
    <div class="content-wrapper">
        <div class="dashboard-header">
            <%
                String courseIdParam = request.getParameter("courseId");
                String courseName = "Unknown Course";
                try {
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                    Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                    PreparedStatement ps = con.prepareStatement("SELECT course_name FROM Courses WHERE course_id = ?");
                    ps.setInt(1, Integer.parseInt(courseIdParam));
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        courseName = rs.getString("course_name");
                    }
                    rs.close();
                    ps.close();
                    con.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
            <h1>Course Details: <%= courseName %></h1>
        </div>

        <!-- Enrolled Students Section -->
        <div class="form-section">
            <h2>Enrolled Students</h2>
            <table class="table table-striped table-bordered">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Enrolled At</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("oracle.jdbc.driver.OracleDriver");
                            Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
                            PreparedStatement ps = con.prepareStatement(
                                "SELECT u.name, u.email, u.role, e.enrolled_at " +
                                "FROM Users u JOIN Enrollments e ON u.email = e.student_email " +
                                "WHERE e.course_id = ?"
                            );
                            ps.setInt(1, Integer.parseInt(courseIdParam));
                            ResultSet rs = ps.executeQuery();
                            if (!rs.isBeforeFirst()) {
                                out.println("<tr><td colspan='4'>No students enrolled.</td></tr>");
                            }
                            while (rs.next()) {
                                String name = rs.getString("name");
                                String email = rs.getString("email");
                                String role = rs.getString("role");
                                Timestamp enrolledAt = rs.getTimestamp("enrolled_at");
                    %>
                    <tr>
                        <td><a href="javascript:void(0)" onclick="showProfile('<%= email %>', 'student')"><%= name != null ? name : "N/A" %></a></td>
                        <td><%= email %></td>
                        <td><%= role %></td>
                        <td><%= enrolledAt != null ? enrolledAt : "N/A" %></td>
                    </tr>
                    <%
                            }
                            rs.close();
                            ps.close();
                            con.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                            out.println("<tr><td colspan='4'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
            <a href="facultyDashboard.jsp" class="btn btn-custom mt-3">Back to Dashboard</a>
        </div>
    </div>

    <!-- Profile Modal -->
    <div class="modal fade" id="profileModal" tabindex="-1" aria-labelledby="profileModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="profileModalLabel">Student Profile</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="profileContent"></div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-custom" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
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
                    document.getElementById('profileContent').innerHTML = '<p>Error loading profile: ' + error.message + '</p>';
                    new bootstrap.Modal(document.getElementById('profileModal')).show();
                });
        }
    </script>
</body>
</html>