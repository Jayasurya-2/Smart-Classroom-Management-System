<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Questions - JAAS Institute</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300..700&display=swap" rel="stylesheet">
    <style>
        body { font-family: "Space Grotesk", sans-serif; background-color: #f0faff; }
        .question-container { max-width: 800px; margin: 50px auto; padding: 20px; background: #fff; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .question-block { margin-bottom: 20px; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="question-container">
        <h2>Manage Questions</h2>
        <form action="AddQuestionServlet" method="post">
            <div id="questions">
                <div class="question-block">
                    <div class="mb-3">
                        <label for="courseId" class="form-label">Course ID</label>
                        <input type="text" class="form-control" id="courseId" name="courseId" required>
                    </div>
                    <div class="mb-3">
                        <label for="question" class="form-label">Question</label>
                        <input type="text" class="form-control" name="question" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Options</label>
                        <input type="text" class="form-control mb-2" name="option1" placeholder="Option 1" required>
                        <input type="text" class="form-control mb-2" name="option2" placeholder="Option 2" required>
                        <input type="text" class="form-control mb-2" name="option3" placeholder="Option 3" required>
                        <input type="text" class="form-control mb-2" name="option4" placeholder="Option 4" required>
                    </div>
                    <div class="mb-3">
                        <label for="correctAnswer" class="form-label">Correct Answer</label>
                        <select class="form-control" name="correctAnswer" required>
                            <option value="1">Option 1</option>
                            <option value="2">Option 2</option>
                            <option value="3">Option 3</option>
                            <option value="4">Option 4</option>
                        </select>
                    </div>
                </div>
            </div>
            <button type="button" class="btn btn-secondary" onclick="addQuestion()">Add Question</button>
            <button type="submit" class="btn btn-primary">Submit Questions</button>
        </form>
    </div>
    <script>
        function addQuestion() {
            const questionBlock = document.querySelector('.question-block').cloneNode(true);
            document.getElementById('questions').appendChild(questionBlock);
        }
    </script>
</body>
</html>