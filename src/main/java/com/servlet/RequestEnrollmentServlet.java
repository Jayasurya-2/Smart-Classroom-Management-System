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
import java.sql.ResultSet;

@WebServlet("/RequestEnrollmentServlet")
public class RequestEnrollmentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String studentEmail = (String) session.getAttribute("email");
        int courseId = Integer.parseInt(request.getParameter("courseId"));

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");

            // Check if request already exists or student is enrolled
            PreparedStatement psCheck = con.prepareStatement(
                "SELECT COUNT(*) FROM Enrollment_Requests WHERE course_id = ? AND student_email = ? AND request_status = 'PENDING'" +
                " UNION ALL " +
                "SELECT COUNT(*) FROM Enrollments WHERE course_id = ? AND student_email = ?"
            );
            psCheck.setInt(1, courseId);
            psCheck.setString(2, studentEmail);
            psCheck.setInt(3, courseId);
            psCheck.setString(4, studentEmail);
            ResultSet rsCheck = psCheck.executeQuery();
            rsCheck.next();
            int pendingCount = rsCheck.getInt(1);
            rsCheck.next();
            int enrolledCount = rsCheck.getInt(1);

            if (pendingCount > 0) {
                request.setAttribute("message", "Enrollment request already pending for this course.");
                request.setAttribute("messageType", "warning");
            } else if (enrolledCount > 0) {
                request.setAttribute("message", "You are already enrolled in this course.");
                request.setAttribute("messageType", "info");
            } else {
                // Get faculty email for the course
                PreparedStatement psFaculty = con.prepareStatement("SELECT faculty_email FROM Courses WHERE course_id = ?");
                psFaculty.setInt(1, courseId);
                ResultSet rsFaculty = psFaculty.executeQuery();
                String facultyEmail = rsFaculty.next() ? rsFaculty.getString("faculty_email") : null;

                // Insert enrollment request
                PreparedStatement psInsert = con.prepareStatement(
                    "INSERT INTO Enrollment_Requests (course_id, student_email, faculty_email, request_status) VALUES (?, ?, ?, 'PENDING')"
                );
                psInsert.setInt(1, courseId);
                psInsert.setString(2, studentEmail);
                psInsert.setString(3, facultyEmail);
                psInsert.executeUpdate();

                request.setAttribute("message", "Enrollment request sent successfully!");
                request.setAttribute("messageType", "success");
            }
            con.close();
            request.getRequestDispatcher("studentDashboard.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Error sending enrollment request: " + e.getMessage());
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("studentDashboard.jsp").forward(request, response);
        }
    }
}