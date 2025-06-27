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
import java.sql.ResultSet;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet("/GetTasksServlet")
public class GetTasksServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String date = request.getParameter("date");
        String email = (String) request.getSession().getAttribute("email");
        response.setContentType("application/json");
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
            PreparedStatement ps = con.prepareStatement(
                "SELECT c.course_name, l.meet_link, l.schedule_time " +
                "FROM LiveClasses l JOIN Courses c ON l.course_id = c.course_id " +
                "WHERE l.faculty_email = ? AND DATE(l.schedule_time) = ?"
            );
            ps.setString(1, email);
            ps.setString(2, date);
            ResultSet rs = ps.executeQuery();
            
            JSONArray tasks = new JSONArray();
            while (rs.next()) {
                JSONObject task = new JSONObject();
                task.put("courseName", rs.getString("course_name"));
                task.put("meetLink", rs.getString("meet_link"));
                task.put("scheduleTime", rs.getTimestamp("schedule_time").toString());
                tasks.put(task);
            }
            con.close();
            response.getWriter().write(tasks.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }
}