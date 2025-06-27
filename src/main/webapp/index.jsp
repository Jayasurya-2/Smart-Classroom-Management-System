<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SIH 1625</title>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300..700&display=swap" rel="stylesheet">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Font Awesome for Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

    <!-- Custom CSS -->
    <style>
        :root {
            /* Light Mode (Default) */
            --primary-color: #4070f4;
            --secondary-color: #3050d0;
            --bg-light: #f8f9fa;
            --text-dark: #333;
            --text-muted: #666;
            --background: #f4f7fc;
            --card-bg: #fff;
            --shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        [data-theme="dark"] {
            /* Dark Mode */
            --primary-color: #6b8af7;
            --secondary-color: #4a6bd0;
            --bg-light: #2c2f33;
            --text-dark: #e0e0e0;
            --text-muted: #a0a0a0;
            --background: #1e2124;
            --card-bg: #2f3136;
            --shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        }

        body {
            font-family: "Space Grotesk", sans-serif;
            background-color: var(--background);
            color: var(--text-dark);
            transition: background-color 0.3s ease, color 0.3s ease;
        }

        /* Header */
        header {
            position: sticky;
            top: 0;
            background-color: var(--card-bg);
            box-shadow: var(--shadow);
            z-index: 1200;
            padding: 1rem 2rem;
        }

        header .fs-4 {
            color: var(--primary-color);
            transition: color 0.3s ease;
        }

        header .fs-4:hover {
            color: var(--secondary-color);
        }

        .nav-link {
            color: var(--text-dark);
            font-weight: 500;
            transition: color 0.3s ease, transform 0.3s ease;
        }

        .nav-link:hover {
            color: var(--primary-color);
            transform: translateY(-2px);
        }

        /* Toggle Button */
        .mode-toggle {
            background: none;
            border: none;
            color: var(--text-dark);
            font-size: 1.5rem;
            cursor: pointer;
            transition: color 0.3s ease, transform 0.3s ease;
            margin-left: 10px;
        }

        .mode-toggle:hover {
            color: var(--primary-color);
            transform: rotate(360deg);
        }

        /* Dropdown */
        .dropdown .profile-icon {
            width: 45px;
            height: 45px;
            border: 2px solid var(--primary-color);
            transition: transform 0.3s ease, border-color 0.3s ease;
        }

        .dropdown .profile-icon:hover {
            transform: scale(1.15);
            border-color: var(--secondary-color);
        }

        .dropdown-menu {
            border-radius: 10px;
            border: none;
            background-color: var(--card-bg);
            box-shadow: var(--shadow);
            animation: fadeIn 0.3s ease;
        }

        .dropdown-menu span {
            color: var(--primary-color);
            font-weight: 600;
        }

        .dropdown-menu a {
            color: var(--text-muted);
            transition: background-color 0.3s ease, color 0.3s ease;
        }

        .dropdown-menu a:hover {
            background-color: var(--primary-color);
            color: #fff;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Sidebar */
        .sidebar {
            width: 220px;
            background: linear-gradient(180deg, var(--card-bg), var(--bg-light));
            box-shadow: var(--shadow);
            transition: transform 0.4s ease;
        }

        .sidebar.collapsed {
            transform: translateX(-220px);
        }

        .sidebar .nav-link {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            border-radius: 8px;
            margin: 5px 10px;
            color: var(--text-dark);
            transition: background-color 0.3s ease, color 0.3s ease, transform 0.3s ease;
        }

        .sidebar .nav-link i {
            margin-right: 10px;
            font-size: 1.2rem;
        }

        .sidebar .nav-link:hover, .sidebar .nav-link.active {
            background-color: var(--primary-color);
            color: #fff;
            transform: translateX(5px);
        }

        .hamburger {
            font-size: 28px;
            color: var(--primary-color);
            background: transparent;
            border: none;
            padding: 10px;
            transition: color 0.3s ease, transform 0.3s ease;
        }

        .hamburger:hover {
            color: var(--secondary-color);
            transform: rotate(90deg);
        }

        .content-wrapper {
            margin-left: 220px;
            transition: margin-left 0.4s ease;
        }

        .content-wrapper.expanded {
            margin-left: 0;
        }

        /* Hero Section */
        .hero-section {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            color: #fff;
            padding: 4rem 2rem;
            border-radius: 20px;
            margin: 2rem;
            text-align: center;
            animation: slideIn 1s ease;
        }

        .hero-section h1 {
            font-weight: 700;
            font-size: 3rem;
            margin-bottom: 1.5rem;
        }

        .hero-section p {
            font-size: 1.2rem;
            margin-bottom: 2rem;
        }

        .hero-section .btn {
            padding: 12px 30px;
            font-size: 1.1rem;
            font-weight: 500;
            border-radius: 50px;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .hero-section .btn:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Carousel */
        .carousel-item img {
            transition: transform 0.5s ease;
        }

        .carousel-item img:hover {
            transform: scale(1.05);
        }

        .carousel-caption {
            background: rgba(0, 0, 0, 0.5);
            border-radius: 10px;
            padding: 15px;
        }

        /* Marketing Section */
        .marketing .col-lg-4 {
            background: var(--card-bg);
            border-radius: 15px;
            padding: 20px;
            box-shadow: var(--shadow);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            margin-bottom: 2rem;
        }

        .marketing .col-lg-4:hover {
            transform: translateY(-10px);
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
        }

        .marketing img {
            border: 3px solid var(--primary-color);
            transition: transform 0.3s ease;
        }

        .marketing img:hover {
            transform: rotate(5deg);
        }

        /* Featurette */
        .featurette {
            background: var(--card-bg);
            border-radius: 15px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: var(--shadow);
        }

        .featurette img {
            border-radius: 10px;
            transition: transform 0.3s ease;
        }

        .featurette img:hover {
            transform: scale(1.05);
        }

        /* Footer */
        footer {
            background: var(--bg-light);
            padding: 3rem 2rem;
            border-top: 1px solid var(--text-muted);
        }

        footer .footer-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 2rem;
        }

        footer .social-icons a {
            color: var(--text-muted);
            font-size: 1.5rem;
            margin-right: 1rem;
            transition: color 0.3s ease;
        }

        footer .social-icons a:hover {
            color: var(--primary-color);
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-220px);
            }

            .sidebar.collapsed {
                transform: translateX(0);
            }

            .content-wrapper {
                margin-left: 0;
            }

            .hero-section h1 {
                font-size: 2rem;
            }

            .hero-section p {
                font-size: 1rem;
            }

            .carousel-item img {
                height: 200px;
            }
        }
    </style>
</head>
<body data-theme="dark">
    <!-- Header / Navbar -->
    <header class="d-flex flex-wrap align-items-center justify-content-between">
        <div class="col-md-3 mb-2 mb-md-0">
            <a href="/" class="d-inline-flex link-body-emphasis text-decoration-none">
                <span class="fs-4 fw-bold">JAAS Institute</span>
            </a>
        </div>
  
        <ul class="nav col-12 col-md-auto mb-2 justify-content-center mb-md-0">
            <li><a href="#" class="nav-link px-2">Home</a></li>
            <li><a href="features.html" class="nav-link px-2">Features</a></li>
            <li><a href="faqs.html" class="nav-link px-2">FAQs</a></li>
            <li><a href="about.html" class="nav-link px-2">About</a></li>
        </ul>
  
        <div class="col-md-3 text-end d-flex align-items-center" id="userSection">
            <% 
                String name = (String) session.getAttribute("name");
                String email = (String) session.getAttribute("email");
                if (name != null && email != null) { 
            %>
                <!-- User Profile Dropdown -->
                <div class="dropdown" id="profileDropdown">
                    <img src="/SIH1625/src/main/webapp/asserts/default-profile.png" id="profileIcon" alt="Profile" class="profile-icon" onclick="toggleDropdown()">
                    <div class="dropdown-menu" id="dropdownMenu">
                        <span>Welcome, <%= name %></span>
                        <a href="profile.html">My Profile</a>
                        <a href="#" onclick="logout()">Logout</a>
                    </div>
                </div>
            <% } else { %>
                <!-- Default Login Button -->
                <button type="button" id="loginBtn" class="btn btn-outline-primary me-2" onclick="window.location.href='login.jsp';">Login</button>
            <% } %>
            <button class="mode-toggle" id="modeToggle" title="Toggle Light Mode">
                <i class="fas fa-adjust"></i>
            </button>
        </div>
    </header>

    <!-- Hamburger Menu Icon -->
    <button class="hamburger" onclick="toggleSidebar()">☰</button>

    <!-- Sidebar + Hero Section Wrapper -->
    <div class="d-flex min-vh-100">
        <!-- Sidebar -->
        <div class="sidebar d-flex flex-column flex-shrink-0 p-3" id="sidebar">
            <a href="/" class="d-flex align-items-center mb-3 mb-md-0 me-md-auto link-body-emphasis text-decoration-none">
                <span class="fs-4">Explore Content</span>
            </a>
            <hr>
            <ul class="nav nav-pills flex-column mb-auto">
                <li class="nav-item"><a href="index.jsp" class="nav-link active"><i class="fas fa-home"></i> Home</a></li>
                <li><a href="login.jsp" class="nav-link"><i class="fas fa-book"></i> Courses</a></li>
                <li><a href="login.jsp" class="nav-link"><i class="fas fa-video"></i> Live Classroom</a></li>
                <li><a href="login.jsp" class="nav-link"><i class="fas fa-comments"></i> Connect for doubts</a></li>
                <li><a href="login.jsp" class="nav-link"><i class="fas fa-chart-bar"></i> Student Report</a></li>
            </ul>
        </div>

        <!-- Content Wrapper -->
        <div class="content-wrapper" id="contentWrapper">
            <!-- Hero Section -->
            <div class="hero-section">
                <h1 class="display-4 fw-bold">JASS Institute of Technology</h1>
                <div class="col-lg-8 mx-auto">
                    <p class="lead">Welcome to JASS Institute of Technology, where we empower minds and shape futures, fostering innovation, excellence, and beyond.</p>
                    <div class="d-grid gap-2 d-sm-flex justify-content-sm-center mb-5">
                        <a href="login.jsp"><button type="button" class="btn btn-light btn-lg px-4 me-sm-3">Explore Courses</button></a>
                        <a href="login.jsp"><button type="button" class="btn btn-light btn-lg px-4 me-sm-3">Live Sessions</button></a>
                    </div>
                </div>
                <div class="overflow-hidden" style="max-height: 30vh;">
                    <div class="container px-5">
                        <img src="asserts/hero.jpg" class="img-fluid border rounded-3 shadow-lg mb-4" alt="Example image" width="700" height="500" loading="lazy">
                    </div>
                </div>
            </div>

            <main>
                <div id="myCarousel" class="carousel slide mb-6" data-bs-ride="carousel">
                    <div class="carousel-indicators">
                        <button type="button" data-bs-target="#myCarousel" data-bs-slide-to="0" class="" aria-label="Slide 1"></button>
                        <button type="button" data-bs-target="#myCarousel" data-bs-slide-to="1" aria-label="Slide 2" class="active" aria-current="true"></button>
                        <button type="button" data-bs-target="#myCarousel" data-bs-slide-to="2" aria-label="Slide 3" class=""></button>
                    </div>
                    <div class="carousel-inner">
                        <div class="carousel-item">
                            <img src="asserts/c1.png" class="d-block mx-auto w-auto" style="max-width: 70%; height: 400px; border-radius: 20px;" alt="Slide 1">
                            <div class="carousel-caption d-none d-md-block">
                                <h5>Innovative Learning</h5>
                                <p>Discover cutting-edge courses tailored for success.</p>
                            </div>
                        </div>
                        <div class="carousel-item active">
                            <img src="asserts/c2.jpg" class="d-block mx-auto w-auto" style="max-width: 70%; height: 400px; border-radius: 20px;" alt="Slide 2">
                            <div class="carousel-caption d-none d-md-block">
                                <h5>Live Sessions</h5>
                                <p>Join interactive classes with expert instructors.</p>
                            </div>
                        </div>
                        <div class="carousel-item">
                            <img src="asserts/c3.webp" class="d-block mx-auto w-auto" style="max-width: 70%; height: 400px; border-radius: 20px;" alt="Slide 3">
                            <div class="carousel-caption d-none d-md-block">
                                <h5>Community Engagement</h5>
                                <p>Connect and grow with our vibrant community.</p>
                            </div>
                        </div>
                    </div>
                    <button class="carousel-control-prev" type="button" data-bs-target="#myCarousel" data-bs-slide="prev">
                        <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                        <span class="visually-hidden">Previous</span>
                    </button>
                    <button class="carousel-control-next" type="button" data-bs-target="#myCarousel" data-bs-slide="next">
                        <span class="carousel-control-next-icon" aria-hidden="true"></span>
                        <span class="visually-hidden">Next</span>
                    </button>
                </div>
              
                <div class="container marketing">
                    <div class="row">
                        <div class="col-lg-4 text-center">
                            <img src="asserts/Ashwan-Tech.jpg" alt="Code With Harry" class="rounded-circle img-fluid" width="140" height="140">
                            <h2 class="fw-normal">Code With Ashwan</h2>
                            <p>CodeWithHarry offers beginner-friendly programming tutorials in Hindi, covering Python, JavaScript, web development, and more. 🚀</p>
                            <p><a class="btn btn-primary" href="#">View details »</a></p>
                        </div>
                        <div class="col-lg-4 text-center">
                            <img src="asserts/tutor3.jpeg" alt="Tarun Speaks" class="rounded-circle img-fluid" width="140" height="140">
                            <h2 class="fw-normal">Tarun Speaks</h2>
                            <p>Tarun Speaks focuses on motivational and self-improvement content, offering practical advice on communication, confidence, and career success. 🎯📢</p>
                            <p><a class="btn btn-primary" href="#">View details »</a></p>
                        </div>
                        <div class="col-lg-4 text-center">
                            <img src="asserts/tutor5.jpg" alt="Aman Dattarwal" class="rounded-circle img-fluid" width="140" height="140">
                            <h2 class="fw-normal">Aman Dattarwal</h2>
                            <p>Aman Dhattarwal is known for his engaging teaching style, career guidance, and motivational content. 🎓🚀</p>
                            <p><a class="btn btn-primary" href="#">View details »</a></p>
                        </div>
                    </div>

                    <hr class="featurette-divider">
              
                    <div class="row featurette">
                        <div class="col-md-7">
                            <h2 class="featurette-heading fw-normal lh-1">State-of-the-Art Infrastructure: <span class="text-body-secondary">Designed for Excellence</span></h2>
                            <p class="lead">Our college offers <b>modern classrooms, advanced labs, a digital library, and high-speed internet</b> for a seamless learning experience. With <b>innovation hubs, recreational areas, and top-notch sports facilities</b>, we ensure a vibrant campus life.</p>
                        </div>
                        <div class="col-md-5">
                            <img src="asserts/hm1.jpg" alt="Infrastructure" class="bd-placeholder-img bd-placeholder-img-lg featurette-image img-fluid mx-auto" width="500" height="500">
                        </div>
                    </div>
              
                    <hr class="featurette-divider">
              
                    <div class="row featurette">
                        <div class="col-md-7 order-md-2">
                            <h2 class="featurette-heading fw-normal lh-1">Expert Faculty: <span class="text-body-secondary">Mentors Who Inspire</span></h2>
                            <p class="lead">Our highly qualified faculty are dedicated to nurturing talent through innovative teaching and personalized guidance, empowering students to excel.</p>
                        </div>
                        <div class="col-md-5 order-md-1">
                            <img src="asserts/hm2.jpg" alt="Faculty" class="bd-placeholder-img bd-placeholder-img-lg featurette-image img-fluid mx-auto" width="500" height="500">
                        </div>
                    </div>
              
                    <hr class="featurette-divider">
              
                    <div class="row featurette">
                        <div class="col-md-7">
                            <h2 class="featurette-heading fw-normal lh-1">Dynamic Clubs & <span class="text-body-secondary">Engaging Meetups</span></h2>
                            <p class="lead">Our online college offers interactive clubs, networking meetups, and engaging events that foster collaboration and growth.</p>
                        </div>
                        <div class="col-md-5">
                            <img src="asserts/hm3.jpg" alt="Clubs" class="bd-placeholder-img bd-placeholder-img-lg featurette-image img-fluid mx-auto" width="500" height="500">
                        </div>
                    </div>
              
                    <hr class="featurette-divider">
                </div>

                <!-- FOOTER -->
                <footer class="container">
                    <div class="footer-grid">
                        <div>
                            <h5>JAAS Institute</h5>
                            <p>Empowering minds, shaping futures.</p>
                        </div>
                        <div>
                            <h5>Quick Links</h5>
                            <ul class="list-unstyled">
                                <li><a href="#" class="text-muted">Home</a></li>
                                <li><a href="features.html" class="text-muted">Features</a></li>
                                <li><a href="faqs.html" class="text-muted">FAQs</a></li>
                                <li><a href="about.html" class="text-muted">About</a></li>
                            </ul>
                        </div>
                        <div>
                            <h5>Connect</h5>
                            <div class="social-icons">
                                <a href="#"><i class="fab fa-facebook-f"></i></a>
                                <a href="#"><i class="fab fa-twitter"></i></a>
                                <a href="#"><i class="fab fa-linkedin-in"></i></a>
                                <a href="#"><i class="fab fa-instagram"></i></a>
                            </div>
                        </div>
                    </div>
                    <p class="text-center mt-4">© 2025 JAAS Institute, Inc. · <a href="#">Privacy</a> · <a href="#">Terms</a></p>
                </footer>
            </main>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function toggleDropdown() {
            document.getElementById("dropdownMenu").classList.toggle("show");
        }

        function logout() {
            window.location.href = "LogoutServlet";
        }

        function toggleSidebar() {
            const sidebar = document.getElementById("sidebar");
            const contentWrapper = document.getElementById("contentWrapper");
            sidebar.classList.toggle("collapsed");
            contentWrapper.classList.toggle("expanded");
        }

        // Close dropdown if clicked outside
        window.onclick = function(event) {
            if (!event.target.matches('.profile-icon')) {
                let dropdowns = document.getElementsByClassName("dropdown-menu");
                for (let i = 0; i < dropdowns.length; i++) {
                    let openDropdown = dropdowns[i];
                    if (openDropdown.classList.contains("show")) {
                        openDropdown.classList.remove("show");
                    }
                }
            }
        }

        // Dark Mode Toggle
        const modeToggle = document.getElementById('modeToggle');
        const body = document.body;

        // Set default to dark mode and store in localStorage
        if (!localStorage.getItem('theme')) {
            body.setAttribute('data-theme', 'dark');
            localStorage.setItem('theme', 'dark');
        } else if (localStorage.getItem('theme') === 'dark') {
            body.setAttribute('data-theme', 'dark');
        }

        modeToggle.addEventListener('click', () => {
            if (body.getAttribute('data-theme') === 'dark') {
                body.removeAttribute('data-theme');
                localStorage.removeItem('theme');
            } else {
                body.setAttribute('data-theme', 'dark');
                localStorage.setItem('theme', 'dark');
            }
        });
    </script>
</body>
</html>