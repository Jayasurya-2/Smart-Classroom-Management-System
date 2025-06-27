<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, org.json.*" %>
<%
    response.setContentType("application/json");
    String receiverEmail = request.getParameter("receiverEmail");
    String senderEmail = (String) session.getAttribute("email");
    JSONArray messages = new JSONArray();
    Connection con = null;
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "c##practicesql", "surya123");
        String query = "SELECT SENDER_EMAIL, RECEIVER_EMAIL, CONTENT, SENT_AT FROM Messages WHERE (SENDER_EMAIL = ? AND RECEIVER_EMAIL = ?) OR (SENDER_EMAIL = ? AND RECEIVER_EMAIL = ?) ORDER BY SENT_AT";
        try (PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, senderEmail);
            ps.setString(2, receiverEmail);
            ps.setString(3, receiverEmail);
            ps.setString(4, senderEmail);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    JSONObject msg = new JSONObject();
                    msg.put("senderEmail", rs.getString("SENDER_EMAIL"));
                    msg.put("receiverEmail", rs.getString("RECEIVER_EMAIL"));
                    msg.put("content", rs.getString("CONTENT"));
                    msg.put("sentAt", rs.getTimestamp("SENT_AT").toString());
                    messages.put(msg);
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        JSONObject error = new JSONObject();
        error.put("error", "Failed to load messages: " + e.getMessage());
        out.print(error.toString());
        return;
    } finally {
        if (con != null) {
            try {
                con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    out.print(messages.toString());
%>