<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String email = request.getParameter("email");
    String role = request.getParameter("role");
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
        // Fetch user details with case-insensitive role comparison
        PreparedStatement ps = con.prepareStatement("SELECT NAME, EMAIL, ROLE, CREATED_AT FROM Users WHERE EMAIL = ? AND LOWER(ROLE) = LOWER(?)");
        ps.setString(1, email);
        ps.setString(2, role);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            String name = rs.getString("NAME");
            String userEmail = rs.getString("EMAIL");
            String userRole = rs.getString("ROLE");
            Timestamp createdAt = rs.getTimestamp("CREATED_AT");
            out.println("<h3>" + (role.equalsIgnoreCase("student") ? "Student" : "Faculty") + " Profile</h3>");
            out.println("<p><strong>Name:</strong> " + (name != null ? name : "N/A") + "</p>");
            out.println("<p><strong>Email:</strong> " + userEmail + "</p>");
            out.println("<p><strong>Role:</strong> " + userRole + "</p>");
            out.println("<p><strong>Registered On:</strong> " + (createdAt != null ? createdAt.toString() : "Not Available") + "</p>");

            if ("student".equalsIgnoreCase(role)) {
                // Enrolled Courses
                PreparedStatement psEnroll = con.prepareStatement(
                    "SELECT c.COURSE_ID, c.COURSE_NAME " +
                    "FROM Enrollments e JOIN Courses c ON e.COURSE_ID = c.COURSE_ID " +
                    "WHERE e.STUDENT_EMAIL = ?"
                );
                psEnroll.setString(1, email);
                ResultSet rsEnroll = psEnroll.executeQuery();
                out.println("<h4>Enrolled Courses:</h4>");
                if (!rsEnroll.isBeforeFirst()) {
                    out.println("<p>No courses enrolled.</p>");
                } else {
                    out.println("<ul>");
                    while (rsEnroll.next()) {
                        int courseId = rsEnroll.getInt("COURSE_ID");
                        String courseName = rsEnroll.getString("COURSE_NAME");
                        out.println("<li>" + courseName + " (ID: " + courseId + ")</li>");
                    }
                    out.println("</ul>");
                }
                rsEnroll.close();
                psEnroll.close();

                // Course-wise Average Score and Percentage
                PreparedStatement psCourses = con.prepareStatement(
                    "SELECT c.COURSE_ID, c.COURSE_NAME " +
                    "FROM Enrollments e JOIN Courses c ON e.COURSE_ID = c.COURSE_ID " +
                    "WHERE e.STUDENT_EMAIL = ?"
                );
                psCourses.setString(1, email);
                ResultSet rsCourses = psCourses.executeQuery();
                out.println("<h4>Course-wise Performance:</h4>");
                if (!rsCourses.isBeforeFirst()) {
                    out.println("<p>No performance data available.</p>");
                } else {
                    out.println("<table class='table table-bordered'>");
                    out.println("<thead><tr><th>Course Name</th><th>Average Score</th><th>Average Percentage</th></tr></thead>");
                    out.println("<tbody>");
                    while (rsCourses.next()) {
                        int courseId = rsCourses.getInt("COURSE_ID");
                        String courseName = rsCourses.getString("COURSE_NAME");

                        // Fetch tests for this course
                        PreparedStatement psTests = con.prepareStatement(
                            "SELECT TEST_ID FROM Mcq_Tests WHERE COURSE_ID = ?"
                        );
                        psTests.setInt(1, courseId);
                        ResultSet rsTests = psTests.executeQuery();
                        double totalScore = 0.0;
                        int testCount = 0;
                        double totalPercentage = 0.0;
                        while (rsTests.next()) {
                            int testId = rsTests.getInt("TEST_ID");
                            // Fetch student's score for this test
                            PreparedStatement psScore = con.prepareStatement(
                                "SELECT SCORE FROM Results WHERE TEST_ID = ? AND STUDENT_EMAIL = ?"
                            );
                            psScore.setInt(1, testId);
                            psScore.setString(2, email);
                            ResultSet rsScore = psScore.executeQuery();
                            if (rsScore.next()) {
                                double score = rsScore.getDouble("SCORE");
                                totalScore += score;
                                testCount++;
                                // Calculate percentage
                                PreparedStatement psQuestions = con.prepareStatement(
                                    "SELECT COUNT(*) FROM Mcq_Questions WHERE TEST_ID = ?"
                                );
                                psQuestions.setInt(1, testId);
                                ResultSet rsQuestions = psQuestions.executeQuery();
                                if (rsQuestions.next()) {
                                    int totalQuestions = rsQuestions.getInt(1);
                                    if (totalQuestions > 0) {
                                        double percentage = (score / totalQuestions) * 100;
                                        totalPercentage += percentage;
                                    }
                                }
                                rsQuestions.close();
                                psQuestions.close();
                            }
                            rsScore.close();
                            psScore.close();
                        }
                        rsTests.close();
                        psTests.close();

                        String avgScore = testCount > 0 ? String.format("%.2f", totalScore / testCount) : "N/A";
                        String avgPercentage = testCount > 0 ? String.format("%.2f%%", totalPercentage / testCount) : "N/A";
                        out.println("<tr>");
                        out.println("<td>" + courseName + "</td>");
                        out.println("<td>" + avgScore + "</td>");
                        out.println("<td>" + avgPercentage + "</td>");
                        out.println("</tr>");
                    }
                    out.println("</tbody></table>");
                }
                rsCourses.close();
                psCourses.close();
            } else if ("faculty".equalsIgnoreCase(role)) {
                // Created Courses
                PreparedStatement psCourses = con.prepareStatement(
                    "SELECT COURSE_ID, COURSE_NAME FROM Courses WHERE FACULTY_EMAIL = ?"
                );
                psCourses.setString(1, email);
                ResultSet rsCourses = psCourses.executeQuery();
                out.println("<h4>Created Courses:</h4>");
                if (!rsCourses.isBeforeFirst()) {
                    out.println("<p>No courses created.</p>");
                } else {
                    out.println("<ul>");
                    while (rsCourses.next()) {
                        int courseId = rsCourses.getInt("COURSE_ID");
                        String courseName = rsCourses.getString("COURSE_NAME");
                        out.println("<li>" + courseName + " (ID: " + courseId + ")</li>");
                    }
                    out.println("</ul>");
                }
                rsCourses.close();
                psCourses.close();
            }
        } else {
            out.println("<p>No profile found for " + email + " with role " + role + ".</p>");
        }
        rs.close();
        ps.close();
        con.close();
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>Error: " + e.getMessage() + "</p>");
    }
%>