package com.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/ManageCourseServlet")
public class ManageCourseServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String DB_USER = "c##practicesql";
    private static final String DB_PASSWORD = "surya123";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null || session.getAttribute("role") == null 
            || !session.getAttribute("role").toString().equalsIgnoreCase("Admin")) {
            response.sendRedirect("index.jsp");
            return;
        }

        String action = request.getParameter("action");
        Connection con = null;
        PreparedStatement ps = null;
        String message = null;
        String messageType = "success";

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            if ("create".equalsIgnoreCase(action)) {
                String courseName = request.getParameter("courseName");
                String description = request.getParameter("description");
                String facultyEmail = request.getParameter("facultyEmail");

                if (courseName == null || courseName.trim().isEmpty() || description == null || description.trim().isEmpty()) {
                    throw new IllegalArgumentException("Course name and description are required.");
                }

                String sql = "INSERT INTO Courses (course_id, course_name, description, faculty_email, status) VALUES (course_seq.NEXTVAL, ?, ?, ?, 'active')";
                ps = con.prepareStatement(sql);
                ps.setString(1, courseName);
                ps.setString(2, description);
                ps.setString(3, facultyEmail != null && !facultyEmail.trim().isEmpty() ? facultyEmail : null);
                int rows = ps.executeUpdate();
                message = rows > 0 ? "Course created successfully." : "Failed to create course.";
                messageType = rows > 0 ? "success" : "danger";

            } else if ("update".equalsIgnoreCase(action)) {
                String courseId = request.getParameter("courseId");
                String courseName = request.getParameter("courseName");
                String description = request.getParameter("description");
                String facultyEmail = request.getParameter("facultyEmail");

                if (courseId == null || courseName == null || courseName.trim().isEmpty() || description == null || description.trim().isEmpty()) {
                    throw new IllegalArgumentException("Course ID, name, and description are required.");
                }

                String sql = "UPDATE Courses SET course_name = ?, description = ?, faculty_email = ? WHERE course_id = ?";
                ps = con.prepareStatement(sql);
                ps.setString(1, courseName);
                ps.setString(2, description);
                ps.setString(3, facultyEmail != null && !facultyEmail.trim().isEmpty() ? facultyEmail : null);
                ps.setInt(4, Integer.parseInt(courseId));
                int rows = ps.executeUpdate();
                message = rows > 0 ? "Course updated successfully." : "Failed to update course or course not found.";
                messageType = rows > 0 ? "success" : "danger";

            } else if ("delete".equalsIgnoreCase(action)) {
                String courseId = request.getParameter("courseId");

                if (courseId == null) {
                    throw new IllegalArgumentException("Course ID is required.");
                }

                String sql = "DELETE FROM Courses WHERE course_id = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(courseId));
                int rows = ps.executeUpdate();
                message = rows > 0 ? "Course deleted successfully." : "Failed to delete course or course not found.";
                messageType = rows > 0 ? "success" : "danger";

            } else if ("block".equalsIgnoreCase(action)) {
                String courseId = request.getParameter("courseId");

                if (courseId == null) {
                    throw new IllegalArgumentException("Course ID is required.");
                }

                String sql = "UPDATE Courses SET status = 'inactive' WHERE course_id = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(courseId));
                int rows = ps.executeUpdate();
                message = rows > 0 ? "Course blocked successfully." : "Failed to block course or course not found.";
                messageType = rows > 0 ? "success" : "danger";

            } else if ("unblock".equalsIgnoreCase(action)) {
                String courseId = request.getParameter("courseId");

                if (courseId == null) {
                    throw new IllegalArgumentException("Course ID is required.");
                }

                String sql = "UPDATE Courses SET status = 'active' WHERE course_id = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(courseId));
                int rows = ps.executeUpdate();
                message = rows > 0 ? "Course unblocked successfully." : "Failed to unblock course or course not found.";
                messageType = rows > 0 ? "success" : "danger";

            } else {
                throw new IllegalArgumentException("Invalid action specified.");
            }

        } catch (IllegalArgumentException e) {
            message = e.getMessage();
            messageType = "danger";
        } catch (SQLException e) {
            message = "Database error: " + e.getMessage();
            messageType = "danger";
            e.printStackTrace();
        } catch (Exception e) {
            message = "Unexpected error: " + e.getMessage();
            messageType = "danger";
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        request.setAttribute("message", message);
        request.setAttribute("messageType", messageType);
        request.getRequestDispatcher("adminDashboard.jsp").forward(request, response);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}