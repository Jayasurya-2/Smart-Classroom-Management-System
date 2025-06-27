document.addEventListener("DOMContentLoaded", function () {
    const signupForm = document.getElementById("signup-form");
    const loginForm = document.getElementById("login-form");
    const signupErrorDiv = document.getElementById("signup-error");
    const signupSuccessDiv = document.getElementById("signup-success");
    const loginErrorDiv = document.getElementById("login-error");
    const wrapper = document.querySelector(".wrapper");

    // Clear all message divs initially
    signupErrorDiv.style.display = "none";
    signupSuccessDiv.style.display = "none";
    loginErrorDiv.style.display = "none";

    // Handle error and success messages from URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    const signupError = urlParams.get('signupError');
    const signupSuccess = urlParams.get('signupSuccess');
    const loginError = urlParams.get('loginError');

    if (signupError) {
        signupErrorDiv.textContent = decodeURIComponent(signupError);
        signupErrorDiv.style.display = "block";
        wrapper.classList.remove("active"); // show signup form
    } else if (signupSuccess) {
        signupSuccessDiv.textContent = decodeURIComponent(signupSuccess);
        signupSuccessDiv.style.display = "block";
        wrapper.classList.add("active"); // switch to login form after signup
    } else if (loginError) {
        loginErrorDiv.textContent = decodeURIComponent(loginError);
        loginErrorDiv.style.display = "block";
        wrapper.classList.add("active"); // show login form
    }

    // Clear URL parameters to prevent message persistence on refresh
    if (signupError || signupSuccess || loginError) {
        window.history.replaceState({}, document.title, window.location.pathname);
    }

    // Form Submit Handlers
    if (signupForm) {
        signupForm.addEventListener("submit", function (e) {
            const selectedRole = document.getElementById("selected-role").value;
            if (!selectedRole) {
                e.preventDefault();
                signupErrorDiv.textContent = "Please select a role before signing up.";
                signupErrorDiv.style.display = "block";
                wrapper.classList.remove("active");
            }
        });
    }

    if (loginForm) {
        loginForm.addEventListener("submit", function (e) {
            const email = document.getElementById("login-email").value.trim();
            const password = document.getElementById("login-password").value.trim();
            if (email === "" || password === "") {
                e.preventDefault();
                loginErrorDiv.textContent = "Email and Password are required.";
                loginErrorDiv.style.display = "block";
                wrapper.classList.add("active");
            }
        });
    }

    // Switch between signup/login forms
    const signupHeader = document.querySelector(".signup header");
    const loginHeader = document.querySelector(".login header");

    loginHeader.addEventListener("click", () => {
        wrapper.classList.add("active");
    });
    signupHeader.addEventListener("click", () => {
        wrapper.classList.remove("active");
    });

    // Role selection
    const roleButtons = document.querySelectorAll(".role-btn");
    const roleInputSignup = document.getElementById("selected-role");

    roleButtons.forEach(button => {
        button.addEventListener("click", function () {
            roleButtons.forEach(btn => btn.classList.remove("selected"));
            this.classList.add("selected");
            if (roleInputSignup) {
                roleInputSignup.value = this.getAttribute("data-role");
            }
        });
    });
});
