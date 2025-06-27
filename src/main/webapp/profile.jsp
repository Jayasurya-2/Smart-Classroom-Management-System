<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Profile - JAAS Institute</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { font-family: Arial, sans-serif; background-color: #f0faff; }
        .profile-container { max-width: 600px; margin: 50px auto; padding: 20px; background-color: #fff; border-radius: 8px; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1); }
    </style>
</head>
<body>
    <div class="profile-container">
        <h2>My Profile</h2>
        <p><strong>Name:</strong> <%= session.getAttribute("name") != null ? session.getAttribute("name") : "N/A" %></p>
        <p><strong>Email:</strong> <%= session.getAttribute("email") != null ? session.getAttribute("email") : "N/A" %></p>
        <p><strong>Role:</strong> <%= session.getAttribute("role") != null ? session.getAttribute("role") : "N/A" %></p>
        
    </div>
</body>
</html>