package com.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;


public class ManageEnrollmentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        String action = request.getParameter("action"); // "accept" or "reject"

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
            con.setAutoCommit(false); // Start transaction

            if ("accept".equals(action)) {
                // Get request details
                PreparedStatement psRequest = con.prepareStatement(
                    "SELECT course_id, student_email FROM Enrollment_Requests WHERE request_id = ?"
                );
                psRequest.setInt(1, requestId);
                java.sql.ResultSet rs = psRequest.executeQuery();
                if (rs.next()) {
                    int courseId = rs.getInt("course_id");
                    String studentEmail = rs.getString("student_email");

                    // Insert into Enrollments
                    PreparedStatement psEnroll = con.prepareStatement(
                        "INSERT INTO Enrollments (course_id, student_email) VALUES (?, ?)"
                    );
                    psEnroll.setInt(1, courseId);
                    psEnroll.setString(2, studentEmail);
                    psEnroll.executeUpdate();

                    // Update request status
                    PreparedStatement psUpdate = con.prepareStatement(
                        "UPDATE Enrollment_Requests SET request_status = 'APPROVED' WHERE request_id = ?"
                    );
                    psUpdate.setInt(1, requestId);
                    psUpdate.executeUpdate();

                    request.setAttribute("message", "Enrollment request accepted successfully!");
                    request.setAttribute("messageType", "success");
                }
            } else if ("reject".equals(action)) {
                // Update request status to REJECTED
                PreparedStatement psUpdate = con.prepareStatement(
                    "UPDATE Enrollment_Requests SET request_status = 'REJECTED' WHERE request_id = ?"
                );
                psUpdate.setInt(1, requestId);
                psUpdate.executeUpdate();

                request.setAttribute("message", "Enrollment request rejected.");
                request.setAttribute("messageType", "info");
            }

            con.commit();
            con.close();
            request.getRequestDispatcher("facultyDashboard.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Error managing enrollment request: " + e.getMessage());
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("facultyDashboard.jsp").forward(request, response);
        }
    }
}