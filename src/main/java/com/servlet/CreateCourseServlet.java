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


public class CreateCourseServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String facultyEmail = (String) session.getAttribute("email");
        String courseName = request.getParameter("courseName");
        String description = request.getParameter("description");

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
            PreparedStatement ps = con.prepareStatement("INSERT INTO Courses (faculty_email, course_name, description) VALUES (?, ?, ?)");
            ps.setString(1, facultyEmail);
            ps.setString(2, courseName);
            ps.setString(3, description);
            ps.executeUpdate();
            con.close();
            request.setAttribute("message", "Course '" + courseName + "' created successfully!");
            request.setAttribute("messageType", "success");
            request.getRequestDispatcher("facultyDashboard.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Error creating course: " + e.getMessage());
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("facultyDashboard.jsp").forward(request, response);
        }
    }
}