package com.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;


public class FetchStudentsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String courseId = request.getParameter("courseId");
        JSONObject jsonResponse = new JSONObject();
        JSONArray studentsArray = new JSONArray();

        if (courseId == null || courseId.trim().isEmpty()) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Course ID is required");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
            String sql = "SELECT u.NAME, e.STUDENT_EMAIL FROM ENROLLMENTS e JOIN users u ON e.STUDENT_EMAIL = u.EMAIL WHERE e.COURSE_ID = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(courseId));
            rs = ps.executeQuery();

            while (rs.next()) {
                JSONObject student = new JSONObject();
                student.put("name", rs.getString("NAME"));
                student.put("email", rs.getString("STUDENT_EMAIL"));
                studentsArray.put(student);
            }

            jsonResponse.put("status", "success");
            jsonResponse.put("students", studentsArray);
        } catch (Exception e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Failed to fetch students: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        response.getWriter().write(jsonResponse.toString());
    }
}