<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Signup & Login</title>
    <link rel="stylesheet" href="login.css">
    <style>
        .error-message, .success-message {
            margin: 10px 0;
            padding: 10px;
            border-radius: 5px;
            text-align: center;
            font-size: 14px;
        }
        .error-message {
            background-color: #ffe6e6;
            color: #d8000c;
            border: 1px solid #d8000c;
        }
        .success-message {
            background-color: #e6ffe6;
            color: #006600;
            border: 1px solid #006600;
        }
    </style>
</head>
<body>
    <div class="sign-inup-container">
        <section class="wrapper">
            <div class="form signup">
                <header>Signup</header>
                <div id="signup-error" class="error-message" style="display: none;"></div>
                <div id="signup-success" class="success-message" style="display: none;"></div>
                <form id="signup-form" action="SignupServlet" method="post">
                    <input type="text" id="name" name="name" placeholder="Full Name" required />
                    <input type="email" id="signup-email" name="email" placeholder="Email Address" required />
                    <input type="password" id="signup-password" name="password" placeholder="Password" required />

                    <div class="role-selection">
                        <p>Select Role:</p>
                        <button type="button" class="role-btn" data-role="Student">Student</button>
                        <button type="button" class="role-btn" data-role="Faculty">Faculty</button>
                        <input type="hidden" name="role" id="selected-role" required>
                    </div>

                    <div class="checkbox">
                        <input type="checkbox" id="signupCheck" required>
                        <label for="signupCheck">I Accept all terms & conditions</label>
                    </div>
                    <button type="submit" id="signup-submit">Signup</button>
                </form>
            </div>
    
            <div class="form login">
                <header>Login</header>
                <div id="login-error" class="error-message" style="display: none;"></div>
                <form id="login-form" action="LoginServlet" method="post">
                    <input type="email" id="login-email" name="email" placeholder="Email Address" required />
                    <input type="password" id="login-password" name="password" placeholder="Password" required />
                    <a href="#">Forget Password</a>
                    <button type="submit" id="login-submit">Login</button>
                </form>
            </div>
        </section>
    </div>

    <script src="login.js"></script>

    <!-- Pass server values into JavaScript safely -->
    <%
        String signupError = (String) request.getAttribute("signupError");
        String signupSuccess = (String) request.getAttribute("signupSuccess");
        String loginError = (String) request.getAttribute("loginError");
    %>

    <script>
    document.addEventListener("DOMContentLoaded", function () {
        const wrapper = document.querySelector(".wrapper");

        var signupError = "<%= signupError != null ? signupError.replace("\"", "\\\"") : "" %>";
        var signupSuccess = "<%= signupSuccess != null ? signupSuccess.replace("\"", "\\\"") : "" %>";
        var loginError = "<%= loginError != null ? loginError.replace("\"", "\\\"") : "" %>";

        if (signupError && signupError.length > 0) {
            document.getElementById("signup-error").textContent = signupError;
            document.getElementById("signup-error").style.display = "block";
            wrapper.classList.remove("active"); // Show signup form
        } else if (signupSuccess && signupSuccess.length > 0) {
            document.getElementById("signup-success").textContent = signupSuccess;
            document.getElementById("signup-success").style.display = "block";
            wrapper.classList.add("active"); // Switch to login form
        } else if (loginError && loginError.length > 0) {
            document.getElementById("login-error").textContent = loginError;
            document.getElementById("login-error").style.display = "block";
            wrapper.classList.add("active"); // Show login form
        }
    });
    </script>

</body>
</html>
