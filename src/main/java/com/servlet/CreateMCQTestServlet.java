package com.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;


@MultipartConfig
public class CreateMCQTestServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String facultyEmail = (String) session.getAttribute("email");
        int courseId = Integer.parseInt(request.getParameter("courseId"));
        String testName = request.getParameter("testName");
        String scheduleTimeStr = request.getParameter("scheduleTime");
        String endTimeStr = request.getParameter("endTime");

        Connection con = null;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
            con.setAutoCommit(false);

            Timestamp scheduleTime = scheduleTimeStr != null && !scheduleTimeStr.isEmpty() ? Timestamp.valueOf(scheduleTimeStr.replace("T", " ") + ":00") : null;
            Timestamp endTime = endTimeStr != null && !endTimeStr.isEmpty() ? Timestamp.valueOf(endTimeStr.replace("T", " ") + ":00") : null;

            PreparedStatement psTest = con.prepareStatement(
                "INSERT INTO MCQ_Tests (course_id, faculty_email, test_name, schedule_time, end_time) VALUES (?, ?, ?, ?, ?)",
                new String[] {"TEST_ID"}
            );
            psTest.setInt(1, courseId);
            psTest.setString(2, facultyEmail);
            psTest.setString(3, testName);
            psTest.setTimestamp(4, scheduleTime);
            psTest.setTimestamp(5, endTime);
            psTest.executeUpdate();
            ResultSet rs = psTest.getGeneratedKeys();
            int testId = -1;
            if (rs.next()) {
                testId = rs.getInt(1);
            }
            rs.close();
            psTest.close();

            if (testId == -1) {
                throw new SQLException("Failed to retrieve generated test_id");
            }

            Part filePart = request.getPart("mcqFile");
            if (filePart != null && filePart.getSize() > 0) {
                try (InputStream fileContent = filePart.getInputStream();
                     InputStreamReader reader = new InputStreamReader(fileContent);
                     CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT.withHeader("question_text", "option_a", "option_b", "option_c", "option_d", "correct_answer").withSkipHeaderRecord())) {

                    PreparedStatement psQuestion = con.prepareStatement(
                        "INSERT INTO MCQ_Questions (test_id, question_text, option_a, option_b, option_c, option_d, correct_answer) VALUES (?, ?, ?, ?, ?, ?, ?)"
                    );
                    for (CSVRecord record : csvParser) {
                        psQuestion.setInt(1, testId);
                        psQuestion.setString(2, record.get("question_text"));
                        psQuestion.setString(3, record.get("option_a"));
                        psQuestion.setString(4, record.get("option_b"));
                        psQuestion.setString(5, record.get("option_c"));
                        psQuestion.setString(6, record.get("option_d"));
                        String correctAnswer = record.get("correct_answer").toUpperCase();
                        if (!"A".equals(correctAnswer) && !"B".equals(correctAnswer) && !"C".equals(correctAnswer) && !"D".equals(correctAnswer)) {
                            throw new IllegalArgumentException("Invalid correct_answer: " + correctAnswer);
                        }
                        psQuestion.setString(7, correctAnswer);
                        psQuestion.addBatch();
                    }
                    psQuestion.executeBatch();
                    psQuestion.close();
                }
            } else {
                String[] questionTexts = request.getParameterValues("questionText[]");
                String[] optionsA = request.getParameterValues("optionA[]");
                String[] optionsB = request.getParameterValues("optionB[]");
                String[] optionsC = request.getParameterValues("optionC[]");
                String[] optionsD = request.getParameterValues("optionD[]");
                String[] correctAnswers = request.getParameterValues("correctAnswer[]");

                if (questionTexts != null && questionTexts.length > 0) {
                    PreparedStatement psQuestion = con.prepareStatement(
                        "INSERT INTO MCQ_Questions (test_id, question_text, option_a, option_b, option_c, option_d, correct_answer) VALUES (?, ?, ?, ?, ?, ?, ?)"
                    );
                    for (int i = 0; i < questionTexts.length; i++) {
                        psQuestion.setInt(1, testId);
                        psQuestion.setString(2, questionTexts[i]);
                        psQuestion.setString(3, optionsA[i]);
                        psQuestion.setString(4, optionsB[i]);
                        psQuestion.setString(5, optionsC[i]);
                        psQuestion.setString(6, optionsD[i]);
                        psQuestion.setString(7, correctAnswers[i]);
                        psQuestion.addBatch();
                    }
                    psQuestion.executeBatch();
                    psQuestion.close();
                }
            }

            con.commit();
            request.setAttribute("message", "MCQ Test '" + testName + "' created successfully!");
            request.setAttribute("messageType", "success");
            request.getRequestDispatcher("facultyDashboard.jsp").forward(request, response);
        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (SQLException rollbackEx) { rollbackEx.printStackTrace(); }
            e.printStackTrace();
            request.setAttribute("message", "Error creating MCQ test: " + e.getMessage());
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("facultyDashboard.jsp").forward(request, response);
        } finally {
            if (con != null) try { con.setAutoCommit(true); con.close(); } catch (SQLException closeEx) { closeEx.printStackTrace(); }
        }
    }
}