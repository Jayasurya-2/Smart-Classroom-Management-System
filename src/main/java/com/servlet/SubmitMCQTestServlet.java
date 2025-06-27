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
import java.util.HashMap;
import java.util.Map;

@WebServlet("/SubmitMCQTestServlet")
public class SubmitMCQTestServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            request.setAttribute("message", "You must be logged in to submit a test.");
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
        Map<Integer, String> userAnswers = new HashMap<>();

        // Retrieve all parameters starting with "answer_"
        for (String paramName : request.getParameterMap().keySet()) {
            if (paramName.startsWith("answer_")) {
                String questionIdStr = paramName.substring("answer_".length());
                int questionId = Integer.parseInt(questionIdStr);
                String userAnswer = request.getParameter(paramName);
                userAnswers.put(questionId, userAnswer);
            }
        }

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean alreadyAttempted = false;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");

            ps = con.prepareStatement("SELECT COUNT(*) FROM mcq_submissions WHERE test_id = ? AND student_email = ?");
            ps.setInt(1, testId);
            ps.setString(2, studentEmail);
            rs = ps.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                alreadyAttempted = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) { e.printStackTrace(); }
            if (ps != null) try { ps.close(); } catch (Exception e) { e.printStackTrace(); }
        }

        if (alreadyAttempted) {
            request.setAttribute("message", "You have already attempted this test.");
            request.setAttribute("messageType", "danger");
            request.getRequestDispatcher("/studentDashboard.jsp").forward(request, response);
            return;
        }

        int score = 0;
        int totalQuestions = 0;

        try {
            ps = con.prepareStatement("SELECT question_id, correct_answer FROM MCQ_Questions WHERE test_id = ?");
            ps.setInt(1, testId);
            rs = ps.executeQuery();

            while (rs.next()) {
                totalQuestions++;
                int questionId = rs.getInt("question_id");
                String correctAnswer = rs.getString("correct_answer").trim();
                String userAnswer = userAnswers.get(questionId);

                if (userAnswer != null) {
                    String correctOptionText = getOptionText(con, questionId, correctAnswer);
                    if (userAnswer != null && userAnswer.equals(correctOptionText)) {
                        score++;
                    }
                }
            }

            Timestamp submittedAt = new Timestamp(System.currentTimeMillis());
            int attempted = (userAnswers.size() > 0) ? 1 : 0;

            ps = con.prepareStatement("INSERT INTO mcq_submissions (test_id, student_email, score, submitted_at, attempted) VALUES (?, ?, ?, ?, ?)");
            ps.setInt(1, testId);
            ps.setString(2, studentEmail);
            ps.setInt(3, score);
            ps.setTimestamp(4, submittedAt);
            ps.setInt(5, attempted);
            ps.executeUpdate();

            request.setAttribute("score", score);
            request.setAttribute("totalQuestions", totalQuestions);
            request.setAttribute("message", "Test submitted successfully! Your score: " + score + "/" + totalQuestions);
            request.setAttribute("messageType", "success");
            request.getRequestDispatcher("/studentDashboard.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Error submitting test: " + e.getMessage());
            request.setAttribute("messageType", "danger");
            request.getRequestDispatcher("/studentDashboard.jsp").forward(request, response);
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) { e.printStackTrace(); }
            if (ps != null) try { ps.close(); } catch (Exception e) { e.printStackTrace(); }
            if (con != null) try { con.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }

    private String getOptionText(Connection con, int questionId, String correctAnswer) throws Exception {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = con.prepareStatement("SELECT option_a, option_b, option_c, option_d FROM MCQ_Questions WHERE question_id = ?");
            ps.setInt(1, questionId);
            rs = ps.executeQuery();
            if (rs.next()) {
                switch (correctAnswer) {
                    case "A": return rs.getString("option_a");
                    case "B": return rs.getString("option_b");
                    case "C": return rs.getString("option_c");
                    case "D": return rs.getString("option_d");
                    default: return null;
                }
            }
            return null;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) { e.printStackTrace(); }
            if (ps != null) try { ps.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }
}