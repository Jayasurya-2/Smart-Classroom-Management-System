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
import java.sql.Timestamp;


public class ScheduleLiveClassServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String facultyEmail = (String) session.getAttribute("email");
        int courseId = Integer.parseInt(request.getParameter("courseId"));
        String meetLink = request.getParameter("meetLink");
        String scheduleTimeStr = request.getParameter("scheduleTime");
        Timestamp scheduleTime = Timestamp.valueOf(scheduleTimeStr.replace("T", " ") + ":00");

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
            PreparedStatement ps = con.prepareStatement("INSERT INTO LiveClasses (course_id, faculty_email, meet_link, schedule_time) VALUES (?, ?, ?, ?)");
            ps.setInt(1, courseId);
            ps.setString(2, facultyEmail);
            ps.setString(3, meetLink);
            ps.setTimestamp(4, scheduleTime);
            ps.executeUpdate();
            con.close();
            request.setAttribute("message", "Live class scheduled successfully for " + scheduleTime + "!");
            request.setAttribute("messageType", "success");
            request.getRequestDispatcher("facultyDashboard.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Error scheduling class: " + e.getMessage());
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("facultyDashboard.jsp").forward(request, response);
        }
    }
}