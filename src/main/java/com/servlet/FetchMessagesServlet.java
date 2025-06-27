package com.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class FetchMessagesServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String DB_USER = "c##practicesql";
    private static final String DB_PASSWORD = "surya123";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        String otherEmail = request.getParameter("otherEmail");
        String courseIdStr = request.getParameter("courseId");

        if (otherEmail == null || courseIdStr == null) {
            out.print("{\"status\":\"error\",\"message\":\"Missing parameters\"}");
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
        ResultSet rs = null;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            ps = con.prepareStatement(
                "SELECT sender_email, receiver_email, content, sent_at " +
                "FROM Messages " +
                "WHERE (sender_email = ? AND receiver_email = ?) OR (sender_email = ? AND receiver_email = ?) " +
                "AND course_id = ? " +
                "ORDER BY sent_at ASC"
            );
            ps.setString(1, otherEmail);
            ps.setString(2, request.getSession().getAttribute("email").toString());
            ps.setString(3, request.getSession().getAttribute("email").toString());
            ps.setString(4, otherEmail);
            ps.setInt(5, courseId);
            rs = ps.executeQuery();

            StringBuilder json = new StringBuilder("{\"status\":\"success\",\"messages\":[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{");
                json.append("\"senderEmail\":\"").append(rs.getString("sender_email")).append("\",");
                json.append("\"receiverEmail\":\"").append(rs.getString("receiver_email")).append("\",");
                json.append("\"content\":\"").append(rs.getString("content").replace("\"", "\\\"")).append("\",");
                json.append("\"sentAt\":\"").append(rs.getTimestamp("sent_at").toString()).append("\"");
                json.append("}");
                first = false;
            }
            json.append("]}");
            out.print(json.toString());
        } catch (SQLException e) {
            out.print("{\"status\":\"error\",\"message\":\"Database error: " + e.getMessage() + "\"}");
            e.printStackTrace();
        } catch (Exception e) {
            out.print("{\"status\":\"error\",\"message\":\"Unexpected error: " + e.getMessage() + "\"}");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
            out.flush();
        }
    }
}