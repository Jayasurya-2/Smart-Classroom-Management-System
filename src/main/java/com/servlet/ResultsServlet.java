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
import org.json.JSONArray;
import org.json.JSONObject;
import java.util.logging.Logger;

public class ResultsServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String DB_USER = "c##practicesql";
    private static final String DB_PASSWORD = "surya123";
    private static final Logger LOGGER = Logger.getLogger(ResultsServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        LOGGER.info("ResultsServlet called with action: " + action);

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            if ("getTests".equals(action)) {
                handleGetTests(request, response);
            } else {
                handleGetResults(request, response);
            }
        } catch (Exception e) {
            LOGGER.severe("Error in ResultsServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("message", "Error fetching results: " + e.getMessage());
            request.setAttribute("messageType", "danger");
            request.getRequestDispatcher("adminDashboard.jsp#results").forward(request, response);
        }
    }

    private void handleGetTests(HttpServletRequest request, HttpServletResponse response)
            throws IOException, SQLException {
        String courseId = request.getParameter("courseId");
        LOGGER.info("Fetching tests for courseId: " + courseId);
        response.setContentType("application/json");
        JSONArray tests = new JSONArray();

        try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement ps = con.prepareStatement(
                 "SELECT TEST_ID, TEST_NAME FROM Mcq_Tests WHERE COURSE_ID = ?")) {
            ps.setInt(1, Integer.parseInt(courseId));
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                JSONObject test = new JSONObject();
                test.put("testId", rs.getInt("TEST_ID"));
                test.put("testName", rs.getString("TEST_NAME"));
                tests.put(test);
            }
        }

        LOGGER.info("Returning " + tests.length() + " tests");
        response.getWriter().write(tests.toString());
    }

    private void handleGetResults(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String courseId = request.getParameter("courseId");
        String testId = request.getParameter("testId");
        String attemptStatus = request.getParameter("attemptStatus");
        LOGGER.info("Fetching results with courseId: " + courseId + ", testId: " + testId + ", attemptStatus: " + attemptStatus);

        List<Map<String, String>> results = new ArrayList<>();

        try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            StringBuilder query = new StringBuilder(
                "SELECT u.NAME AS student_name, u.EMAIL, c.COURSE_NAME, t.TEST_NAME, r.SCORE, r.SUBMITTED_AT, " +
                "(SELECT COUNT(*) FROM Mcq_Questions q WHERE q.TEST_ID = t.TEST_ID) AS total_questions " +
                "FROM Users u " +
                "JOIN Enrollments e ON u.EMAIL = e.STUDENT_EMAIL " +
                "JOIN Courses c ON e.COURSE_ID = c.COURSE_ID " +
                "JOIN Mcq_Tests t ON c.COURSE_ID = t.COURSE_ID " +
                "LEFT JOIN Results r ON u.EMAIL = r.STUDENT_EMAIL AND t.TEST_ID = r.TEST_ID " +
                "WHERE u.ROLE = 'Student'");

            List<String> conditions = new ArrayList<>();
            List<Object> parameters = new ArrayList<>();
            if (courseId != null && !courseId.isEmpty()) {
                conditions.add("c.COURSE_ID = ?");
                parameters.add(Integer.parseInt(courseId));
            }
            if (testId != null && !testId.isEmpty()) {
                conditions.add("t.TEST_ID = ?");
                parameters.add(Integer.parseInt(testId));
            }
            if ("attempted".equals(attemptStatus)) {
                conditions.add("r.SCORE IS NOT NULL");
            } else if ("not_attempted".equals(attemptStatus)) {
                conditions.add("r.SCORE IS NULL");
            }

            if (!conditions.isEmpty()) {
                query.append(" AND ").append(String.join(" AND ", conditions));
            }

            LOGGER.info("Executing query: " + query.toString());
            try (PreparedStatement ps = con.prepareStatement(query.toString())) {
                for (int i = 0; i < parameters.size(); i++) {
                    ps.setObject(i + 1, parameters.get(i));
                }

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    Map<String, String> result = new HashMap<>();
                    result.put("studentName", rs.getString("student_name") != null ? rs.getString("student_name") : "N/A");
                    result.put("email", rs.getString("EMAIL"));
                    result.put("courseName", rs.getString("COURSE_NAME"));
                    result.put("testName", rs.getString("TEST_NAME"));
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
            }

            // Store results and filters in session
            LOGGER.info("Storing " + results.size() + " results in session for download");
            request.getSession().setAttribute("resultsForDownload", results);
            request.getSession().setAttribute("courseId", courseId);
            request.getSession().setAttribute("testId", testId);
            request.getSession().setAttribute("attemptStatus", attemptStatus);

            request.setAttribute("results", results);
            if (results.isEmpty()) {
                request.setAttribute("message", "No results found for the selected filters.");
                request.setAttribute("messageType", "info");
            }
            request.getRequestDispatcher("adminDashboard.jsp#results").forward(request, response);
        }
    }
}