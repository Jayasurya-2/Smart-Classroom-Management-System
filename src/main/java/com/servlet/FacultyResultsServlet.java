package com.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

public class FacultyResultsServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(FacultyResultsServlet.class.getName());
    private static final String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String DB_USER = "c##practicesql";
    private static final String DB_PASSWORD = "surya123";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String facultyEmail = (String) request.getSession().getAttribute("email");
        LOGGER.info("FacultyResultsServlet called with action: " + action + ", facultyEmail: " + facultyEmail);

        if (facultyEmail == null) {
            LOGGER.severe("No faculty email in session");
            request.setAttribute("message", "Session expired. Please log in again.");
            request.setAttribute("messageType", "danger");
            request.getRequestDispatcher("/facultyDashboard.jsp").forward(request, response);
            return;
        }

        try {
            if ("getTests".equals(action)) {
                handleGetTests(request, response, facultyEmail);
            } else {
                handleGetResults(request, response, facultyEmail);
            }
        } catch (Exception e) {
            LOGGER.severe("Error in FacultyResultsServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("message", "Failed to fetch results: " + e.getMessage());
            request.setAttribute("messageType", "danger");
            request.getRequestDispatcher("/facultyDashboard.jsp").forward(request, response);
        }
    }

    private void handleGetTests(HttpServletRequest request, HttpServletResponse response, String facultyEmail)
            throws IOException {
        String courseId = request.getParameter("courseId");
        List<Map<String, String>> tests = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            String query = "SELECT TEST_ID, TEST_NAME FROM Mcq_Tests WHERE COURSE_ID = ? AND COURSE_ID IN (SELECT COURSE_ID FROM Courses WHERE FACULTY_EMAIL = ?)";
            LOGGER.info("Fetching tests for courseId: " + courseId + ", facultyEmail: " + facultyEmail);
            ps = con.prepareStatement(query);
            ps.setInt(1, Integer.parseInt(courseId));
            ps.setString(2, facultyEmail);
            rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> test = new HashMap<>();
                test.put("testId", String.valueOf(rs.getInt("TEST_ID")));
                test.put("testName", rs.getString("TEST_NAME"));
                tests.add(test);
            }
            LOGGER.info("Found " + tests.size() + " tests for courseId: " + courseId);

            response.setContentType("application/json");
            response.getWriter().write(new com.google.gson.Gson().toJson(tests));
        } catch (Exception e) {
            LOGGER.severe("Error fetching tests: " + e.getMessage());
            response.setContentType("application/json");
            response.getWriter().write("[]");
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                LOGGER.severe("Error closing resources: " + e.getMessage());
            }
        }
    }

    private void handleGetResults(HttpServletRequest request, HttpServletResponse response, String facultyEmail)
            throws ServletException, IOException {
        String courseId = request.getParameter("courseId");
        String testId = request.getParameter("testId");
        String attemptStatus = request.getParameter("attemptStatus");
        LOGGER.info("Fetching results with courseId: " + courseId + ", testId: " + testId + ", attemptStatus: " + attemptStatus + ", facultyEmail: " + facultyEmail);

        // Store filters in session
        request.getSession().setAttribute("facultyCourseId", courseId);
        request.getSession().setAttribute("facultyTestId", testId);
        request.getSession().setAttribute("facultyAttemptStatus", attemptStatus);

        List<Map<String, String>> results = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            StringBuilder query = new StringBuilder(
                "SELECT u.NAME AS student_name, u.EMAIL, c.COURSE_NAME, t.TEST_NAME, r.SCORE, r.SUBMITTED_AT, " +
                "(SELECT COUNT(*) FROM Mcq_Questions q WHERE q.TEST_ID = t.TEST_ID) AS total_questions " +
                "FROM Users u " +
                "JOIN Enrollments e ON u.EMAIL = e.STUDENT_EMAIL " +
                "JOIN Courses c ON e.COURSE_ID = c.COURSE_ID " +
                "JOIN Mcq_Tests t ON c.COURSE_ID = t.COURSE_ID " +
                "LEFT JOIN Results r ON u.EMAIL = r.STUDENT_EMAIL AND t.TEST_ID = r.TEST_ID " +
                "WHERE u.ROLE = 'Student' AND c.FACULTY_EMAIL = ?"
            );

            List<Object> parameters = new ArrayList<>();
            parameters.add(facultyEmail);

            if (courseId != null && !courseId.trim().isEmpty()) {
                query.append(" AND c.COURSE_ID = ?");
                parameters.add(Integer.parseInt(courseId));
            }
            if (testId != null && !testId.trim().isEmpty()) {
                query.append(" AND t.TEST_ID = ?");
                parameters.add(Integer.parseInt(testId));
            }
            if ("attempted".equals(attemptStatus)) {
                query.append(" AND r.SCORE IS NOT NULL");
            } else if ("not_attempted".equals(attemptStatus)) {
                query.append(" AND r.SCORE IS NULL");
            }

            LOGGER.info("Executing query: " + query.toString() + ", parameters: " + parameters);
            ps = con.prepareStatement(query.toString());
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> result = new HashMap<>();
                result.put("studentName", rs.getString("student_name") != null ? rs.getString("student_name") : "N/A");
                result.put("email", rs.getString("EMAIL") != null ? rs.getString("EMAIL") : "N/A");
                result.put("courseName", rs.getString("COURSE_NAME") != null ? rs.getString("COURSE_NAME") : "N/A");
                result.put("testName", rs.getString("TEST_NAME") != null ? rs.getString("TEST_NAME") : "N/A");
                String score = rs.getString("SCORE");
                result.put("score", score != null ? score : "Not Attempted");
                result.put("submittedAt", rs.getString("SUBMITTED_AT") != null ? rs.getString("SUBMITTED_AT") : "N/A");

                int totalQuestions = rs.getInt("total_questions");
                if (score != null && totalQuestions > 0) {
                    double percentage = (Double.parseDouble(score) / totalQuestions) * 100;
                    result.put("percentage", String.format("%.2f%%", percentage));
                } else {
                    result.put("percentage", "N/A");
                }

                results.add(result);
            }
            LOGGER.info("Fetched " + results.size() + " results");

            request.setAttribute("results", results);
            request.getSession().setAttribute("facultyResultsForDownload", results);
            request.getRequestDispatcher("/facultyDashboard.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.severe("Error fetching results: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("message", "Failed to fetch results: " + e.getMessage());
            request.setAttribute("messageType", "danger");
            request.getRequestDispatcher("/facultyDashboard.jsp").forward(request, response);
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                LOGGER.severe("Error closing resources: " + e.getMessage());
            }
        }
    }
}