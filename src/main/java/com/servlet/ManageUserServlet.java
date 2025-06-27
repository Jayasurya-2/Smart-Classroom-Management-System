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
import java.sql.SQLException;

@WebServlet("/ManageUserServlet")
public class ManageUserServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String DB_USER = "c##practicesql";
    private static final String DB_PASSWORD = "surya123";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String email = request.getParameter("email");

        if (action == null || email == null) {
            request.setAttribute("message", "Invalid request parameters.");
            request.setAttribute("messageType", "danger");
            request.getRequestDispatcher("/adminDashboard.jsp").forward(request, response);
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        String message = null;
        String messageType = "success";

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            String sql;
            switch (action.toLowerCase()) {
                case "block":
                    sql = "UPDATE Users SET STATUS = 'blocked' WHERE EMAIL = ? AND LOWER(ROLE) IN ('student', 'faculty')";
                    ps = con.prepareStatement(sql);
                    ps.setString(1, email);
                    message = "User blocked successfully.";
                    break;
                case "unblock":
                    sql = "UPDATE Users SET STATUS = 'active' WHERE EMAIL = ? AND LOWER(ROLE) IN ('student', 'faculty')";
                    ps = con.prepareStatement(sql);
                    ps.setString(1, email);
                    message = "User unblocked successfully.";
                    break;
                case "delete":
                    sql = "DELETE FROM Users WHERE EMAIL = ? AND LOWER(ROLE) IN ('student', 'faculty')";
                    ps = con.prepareStatement(sql);
                    ps.setString(1, email);
                    message = "User deleted successfully.";
                    break;
                default:
                    throw new IllegalArgumentException("Invalid action: " + action);
            }

            int rowsUpdated = ps.executeUpdate();
            if (rowsUpdated == 0) {
                message = "Operation failed: User not found or invalid role.";
                messageType = "danger";
            }

        } catch (Exception e) {
            e.printStackTrace();
            message = "Error: " + e.getMessage();
            messageType = "danger";
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        request.setAttribute("message", message);
        request.setAttribute("messageType", messageType);
        request.getRequestDispatcher("/adminDashboard.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}