<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, org.json.*" %>
<%
    response.setContentType("application/json");
    JSONObject jsonResponse = new JSONObject();
    JSONArray postsArray = new JSONArray();

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
        int courseId = Integer.parseInt(request.getParameter("courseId"));
        PreparedStatement ps = con.prepareStatement(
            "SELECT POSTER_EMAIL, POST_TYPE, CONTENT, FILE_NAME, CREATED_AT " +
            "FROM Classroom_Posts WHERE COURSE_ID = ? ORDER BY CREATED_AT DESC"
        );
        ps.setInt(1, courseId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            JSONObject post = new JSONObject();
            post.put("posterEmail", rs.getString("POSTER_EMAIL"));
            post.put("postType", rs.getString("POST_TYPE"));
            post.put("content", rs.getString("CONTENT"));
            post.put("fileName", rs.getString("FILE_NAME"));
            post.put("createdAt", rs.getTimestamp("CREATED_AT").toString());
            postsArray.put(post);
        }
        con.close();
        out.print(postsArray.toString());
    } catch (Exception e) {
        e.printStackTrace();
        jsonResponse.put("error", e.getMessage());
        out.print(jsonResponse.toString());
    }
%>