package com.servlet.SignupServlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/SignupServlet")
public class RegisterServlet extends HttpServlet {

    private static final String CHECK_EMAIL_QUERY = "SELECT COUNT(*) FROM Users WHERE email = ?";
    private static final String INSERT_QUERY = "INSERT INTO Users (name, email, password, role) VALUES (?, ?, ?, ?)";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");

            // Check if email already exists
            PreparedStatement checkStmt = con.prepareStatement(CHECK_EMAIL_QUERY);
            checkStmt.setString(1, email);
            ResultSet rs = checkStmt.executeQuery();
            rs.next();
            int emailCount = rs.getInt(1);

            if (emailCount > 0) {
                // Email already exists
                request.setAttribute("signupError", "Email already registered. Please use a different email.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            // Insert new user
            PreparedStatement pstmt = con.prepareStatement(INSERT_QUERY);
            pstmt.setString(1, name);
            pstmt.setString(2, email);
            pstmt.setString(3, password);
            pstmt.setString(4, role);

            int count = pstmt.executeUpdate();
            if (count > 0) {
                // Successful signup
                request.setAttribute("signupSuccess", "Account created successfully! Please login.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            } else {
                request.setAttribute("signupError", "Registration failed. Please try again.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

            con.close();
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            request.setAttribute("signupError", "Server error: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}
