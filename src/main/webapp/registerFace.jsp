<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register Face - JAAS Institute</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { font-family: "Space Grotesk", sans-serif; background-color: #f0faff; padding: 20px; }
    </style>
</head>
<body>
    <div class="container mt-5">
        <h2>Register Your Face</h2>
        <p>Please position your face in front of the webcam and click the button below to register.</p>
        <video id="video" width="320" height="240" autoplay style="border: 1px solid #ccc;"></video>
        <canvas id="canvas" width="320" height="240" style="display: none;"></canvas>
        <button class="btn btn-primary mt-2" onclick="captureFace()">Capture and Register</button>
        <p id="status"></p>
        <a href="studentDashboard.jsp" class="btn btn-secondary mt-2">Back to Dashboard</a>
    </div>

    <script>
        const video = document.getElementById('video');
        navigator.mediaDevices.getUserMedia({ video: true })
            .then(stream => video.srcObject = stream)
            .catch(err => document.getElementById('status').innerText = "Error: " + err);

        function captureFace() {
            const canvas = document.getElementById('canvas');
            const context = canvas.getContext('2d');
            context.drawImage(video, 0, 0, canvas.width, canvas.height);
            const imageData = canvas.toDataURL('image/jpeg');
            
            const xhr = new XMLHttpRequest();
            xhr.open("POST", "RegisterFaceServlet", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    document.getElementById('status').innerText = xhr.responseText;
                }
            };
            xhr.send(`image=${encodeURIComponent(imageData)}`);
        }
    </script>
</body>
</html>