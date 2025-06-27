package com.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;

public class SendMessageServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String DB_USER = "c##practicesql";
    private static final String DB_PASSWORD = "surya123";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();
        String senderEmail = (String) session.getAttribute("email");
        String receiverEmail = request.getParameter("receiverEmail");
        String courseIdStr = request.getParameter("courseId");
        String content = request.getParameter("content");

        if (senderEmail == null || receiverEmail == null || courseIdStr == null || content == null) {
            out.print("{\"status\":\"error\",\"message\":\"Missing required parameters\"}");
            out.flush();
            return;
        }

        int courseId;
        try {
            courseId = Integer.parseInt(courseIdStr);
        } catch (NumberFormatException e) {
            out.print("{\"status\":\"error\",\"message\":\"Invalid course ID\"}");
            out.flush();
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            ps = con.prepareStatement(
                "INSERT INTO Messages (sender_email, receiver_email, course_id, content, sent_at) " +
                "VALUES (?, ?, ?, ?, ?)"
            );
            ps.setString(1, senderEmail);
            ps.setString(2, receiverEmail);
            ps.setInt(3, courseId);
            ps.setString(4, content);
            ps.setTimestamp(5, new Timestamp(System.currentTimeMillis()));
            int rowsAffected = ps.executeUpdate();

            if (rowsAffected > 0) {
                out.print("{\"status\":\"success\",\"message\":\"Message sent successfully\"}");
            } else {
                out.print("{\"status\":\"error\",\"message\":\"Failed to send message\"}");
            }
        } catch (SQLException e) {
            out.print("{\"status\":\"error\",\"message\":\"Database error: " + e.getMessage() + "\"}");
            e.printStackTrace();
        } catch (Exception e) {
            out.print("{\"status\":\"error\",\"message\":\"Unexpected error: " + e.getMessage() + "\"}");
            e.printStackTrace();
        } finally {
            if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
            out.flush();
        }
    }
}