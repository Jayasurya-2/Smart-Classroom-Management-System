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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

public class FacultyDownloadResultsServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(FacultyDownloadResultsServlet.class.getName());
    private static final String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String DB_USER = "c##practicesql";
    private static final String DB_PASSWORD = "surya123";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String facultyEmail = (String) request.getSession().getAttribute("email");
        LOGGER.info("FacultyDownloadResultsServlet called with facultyEmail: " + facultyEmail);

        if (facultyEmail == null) {
            LOGGER.severe("No faculty email in session");
            response.setContentType("text/plain");
            response.getWriter().write("Session expired. Please log in again.");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        @SuppressWarnings("unchecked")
        List<Map<String, String>> results = (List<Map<String, String>>) request.getSession().getAttribute("facultyResultsForDownload");

        // Re-fetch if session data is missing
        if (results == null || results.isEmpty()) {
            LOGGER.warning("No results in session, re-fetching");
            String courseId = (String) request.getSession().getAttribute("facultyCourseId");
            String testId = (String) request.getSession().getAttribute("facultyTestId");
            String attemptStatus = (String) request.getSession().getAttribute("facultyAttemptStatus");
            results = fetchResults(courseId, testId, attemptStatus, facultyEmail);
            if (results.isEmpty()) {
                LOGGER.warning("Re-fetch returned no results");
                response.setContentType("text/plain");
                response.getWriter().write("No results available for download. Please fetch results first.");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            request.getSession().setAttribute("facultyResultsForDownload", results);
        }

        LOGGER.info("Generating CSV with " + results.size() + " records");
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"faculty_test_results.csv\"");

        try (PrintWriter writer = response.getWriter()) {
            writer.write("Student Name,Email,Course Name,Test Name,Score,Percentage,Submitted At\n");
            for (Map<String, String> result : results) {
                writer.write(String.format("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n",
                    result.get("studentName").replace("\"", "\"\""),
                    result.get("email").replace("\"", "\"\""),
                    result.get("courseName").replace("\"", "\"\""),
                    result.get("testName").replace("\"", "\"\""),
                    result.get("score").replace("\"", "\"\""),
                    result.get("percentage").replace("\"", "\"\""),
                    result.get("submittedAt").replace("\"", "\"\"")));
            }
            LOGGER.info("CSV generated successfully");
        } catch (Exception e) {
            LOGGER.severe("Error generating CSV: " + e.getMessage());
            response.setContentType("text/plain");
            response.getWriter().write("Failed to generate CSV: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private List<Map<String, String>> fetchResults(String courseId, String testId, String attemptStatus, String facultyEmail) {
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
                "WHERE u.ROLE = 'student' AND c.FACULTY_EMAIL = ?"
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

            LOGGER.info("Re-fetching with query: " + query.toString() + ", parameters: " + parameters);
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
            LOGGER.info("Re-fetched " + results.size() + " results");
        } catch (Exception e) {
            LOGGER.severe("Error re-fetching results: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                LOGGER.severe("Error closing resources: " + e.getMessage());
            }
        }
        return results;
    }
}