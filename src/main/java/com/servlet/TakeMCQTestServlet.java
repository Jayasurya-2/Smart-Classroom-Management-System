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
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/TakeMCQTestServlet")
public class TakeMCQTestServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            request.setAttribute("message", "You must be logged in to take a test.");
            request.setAttribute("messageType", "danger");
            request.getRequestDispatcher("/login.html").forward(request, response);
            return;
        }

        String studentEmail = (String) session.getAttribute("email");
        String testIdStr = request.getParameter("testId");
        if (testIdStr == null || testIdStr.isEmpty()) {
            request.setAttribute("message", "Invalid test ID.");
            request.setAttribute("messageType", "danger");
            request.getRequestDispatcher("/studentDashboard.jsp").forward(request, response);
            return;
        }

        int testId = Integer.parseInt(testIdStr);
        List<Question> questions = new ArrayList<>();
        String testName = "";
        Timestamp endTime = null;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean alreadyAttempted = false;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");

            // Check if the student has already attempted this test
            ps = con.prepareStatement("SELECT COUNT(*) FROM mcq_submissions WHERE test_id = ? AND student_email = ?");
            ps.setInt(1, testId);
            ps.setString(2, studentEmail);
            rs = ps.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                alreadyAttempted = true;
            }
            rs.close();
            ps.close();

            if (alreadyAttempted) {
                request.setAttribute("message", "You have already attempted this test.");
                request.setAttribute("messageType", "danger");
                request.getRequestDispatcher("/studentDashboard.jsp").forward(request, response);
                return;
            }

            // Load test name and end time
            ps = con.prepareStatement("SELECT test_name, end_time FROM MCQ_Tests WHERE test_id = ?");
            ps.setInt(1, testId);
            rs = ps.executeQuery();
            if (rs.next()) {
                testName = rs.getString("test_name");
                endTime = rs.getTimestamp("end_time");
            }
            rs.close();
            ps.close();

            // Load questions
            ps = con.prepareStatement("SELECT question_id, question_text, option_a, option_b, option_c, option_d FROM MCQ_Questions WHERE test_id = ?");
            ps.setInt(1, testId);
            rs = ps.executeQuery();

            while (rs.next()) {
                Question question = new Question();
                question.setQuestionId(rs.getInt("question_id"));
                question.setQuestionText(rs.getString("question_text"));
                List<String> options = new ArrayList<>();
                options.add(rs.getString("option_a"));
                options.add(rs.getString("option_b"));
                options.add(rs.getString("option_c"));
                options.add(rs.getString("option_d"));
                question.setOptions(options);
                questions.add(question);
            }

            // Pass data to JSP
            request.setAttribute("testId", testId);
            request.setAttribute("testName", testName);
            request.setAttribute("endTime", endTime);
            request.setAttribute("questions", questions);
            request.getRequestDispatcher("/takeTest.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Error loading test: " + e.getMessage());
            request.setAttribute("messageType", "danger");
            request.getRequestDispatcher("/studentDashboard.jsp").forward(request, response);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (ps != null) ps.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }

    public static class Question {
        private int questionId;
        private String questionText;
        private List<String> options;

        public int getQuestionId() { return questionId; }
        public void setQuestionId(int questionId) { this.questionId = questionId; }
        public String getQuestionText() { return questionText; }
        public void setQuestionText(String questionText) { this.questionText = questionText; }
        public List<String> getOptions() { return options; }
        public void setOptions(List<String> options) { this.options = options; }
    }
}