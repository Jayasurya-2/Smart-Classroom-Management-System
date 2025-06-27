package com.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/GetStudentDetailsServlet")
public class GetStudentDetailsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        String email = request.getParameter("email");

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");

            // Fetch enrolled courses
            PreparedStatement psCourses = con.prepareStatement(
                "SELECT c.course_id, c.course_name " +
                "FROM enrollment_requests er " +
                "JOIN courses c ON er.course_id = c.course_id " +
                "WHERE er.student_email = ? AND er.request_status = 'APPROVED'"
            );
            psCourses.setString(1, email);
            ResultSet rsCourses = psCourses.executeQuery();
            List<Map<String, Object>> courses = new ArrayList<>();
            while (rsCourses.next()) {
                Map<String, Object> course = new HashMap<>();
                course.put("courseId", rsCourses.getInt("course_id"));
                course.put("courseName", rsCourses.getString("course_name"));
                courses.add(course);
            }

            // Fetch test history
            PreparedStatement psTests = con.prepareStatement(
                "SELECT t.test_name, ms.score, ms.submitted_at " +
                "FROM mcq_submissions ms " +
                "JOIN mcq_tests t ON ms.test_id = t.test_id " +
                "WHERE ms.student_email = ?"
            );
            psTests.setString(1, email);
            ResultSet rsTests = psTests.executeQuery();
            List<Map<String, Object>> tests = new ArrayList<>();
            while (rsTests.next()) {
                Map<String, Object> test = new HashMap<>();
                test.put("testName", rsTests.getString("test_name"));
                test.put("score", rsTests.getInt("score"));
                test.put("submittedAt", rsTests.getTimestamp("submitted_at").toString());
                tests.add(test);
            }

            // Build JSON response
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("courses", courses);
            responseData.put("tests", tests);

            out.print(new com.google.gson.Gson().toJson(responseData));
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        } finally {
            out.close();
        }
    }
}