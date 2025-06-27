
package com.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;


@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class UploadMaterialServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "uploads/materials";
    private static final String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String DB_USER = "c##practicesql";
    private static final String DB_PASSWORD = "surya123";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String courseId = request.getParameter("courseId");
        String title = request.getParameter("materialTitle");
        String description = request.getParameter("description");
        Part filePart = request.getPart("materialFile");
        String fileName = filePart.getSubmittedFileName();
        String applicationPath = request.getServletContext().getRealPath("");
        String uploadPath = applicationPath + File.separator + UPLOAD_DIR;

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String filePath = uploadPath + File.separator + fileName;
        filePart.write(filePath);

        Connection con = null;
        PreparedStatement ps = null;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            String sql = "INSERT INTO Course_Materials (material_id, course_id, title, description, file_name, file_path, uploaded_at) " +
                         "VALUES (material_seq.NEXTVAL, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
            ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(courseId));
            ps.setString(2, title);
            ps.setString(3, description);
            ps.setString(4, fileName);
            ps.setString(5, filePath);
            ps.executeUpdate();

            request.setAttribute("message", "Material uploaded successfully!");
            request.setAttribute("messageType", "success");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Error uploading material: " + e.getMessage());
            request.setAttribute("messageType", "danger");
        } finally {
            if (ps != null) try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }

        request.getRequestDispatcher("facultyDashboard.jsp").forward(request, response);
    }
}
