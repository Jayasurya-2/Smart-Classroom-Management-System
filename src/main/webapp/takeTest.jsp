<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="com.servlet.TakeMCQTestServlet.Question" %>
<%
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    int testId = (Integer) request.getAttribute("testId");
    String testName = (String) request.getAttribute("testName");
    Timestamp endTime = (Timestamp) request.getAttribute("endTime");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= testName %></title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Poppins', sans-serif;
            background-color: #f2f5f7;
        }
        .header {
            text-align: center;
            padding: 30px 0 10px;
            background-color: #fff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .header h2 {
            margin: 0;
            font-size: 32px;
            color: #003366;
        }
        .timer {
            margin-top: 10px;
            font-size: 20px;
            font-weight: 600;
            color: #ff4d4d;
        }
        .main-content {
            max-width: 1300px;
            margin: 0 auto;
            display: flex;
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
            overflow: hidden;
            min-height: 650px;
        }
        .left-side {
            flex: 3;
            padding: 40px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .right-side {
            flex: 1;
            background-color: #f7f9fb;
            padding: 30px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            border-left: 1px solid #e0e0e0;
        }
        .question-title {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 20px;
            color: #333;
        }
        .option {
            margin: 18px 0;
        }
        .option input[type="radio"] {
            margin-right: 10px;
        }
        .navigation-buttons {
            text-align: center;
            margin-top: 30px;
        }
        .navigation-buttons button {
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 10px;
            padding: 12px 30px;
            margin: 0 15px;
            font-size: 18px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .navigation-buttons button:hover {
            background-color: #0056b3;
        }
        .navigation-buttons button:disabled {
            background-color: #b0b0b0;
            cursor: not-allowed;
        }
        .question-list {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 15px;
            margin-top: 20px;
        }
        .question-list button {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: white;
            color: #007bff;
            font-size: 18px;
            font-weight: bold;
            border: 2px solid #007bff;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .question-list button:hover {
            background: #007bff;
            color: white;
        }
        .question-list button.answered {
            background: #28a745;
            color: white;
            border-color: #28a745;
        }
        .submit-button {
            background-color: #28a745;
            border: none;
            padding: 15px;
            width: 100%;
            border-radius: 10px;
            color: white;
            font-size: 20px;
            cursor: pointer;
            margin-top: 30px;
            transition: background-color 0.3s;
        }
        .submit-button:hover {
            background-color: #1e7e34;
        }
        .submit-button:disabled {
            background-color: #b0b0b0;
            cursor: not-allowed;
        }
        #reviewModal {
            display: none;
            position: fixed;
            top: 0; 
            left: 0;
            width: 100%; 
            height: 100%;
            background-color: rgba(0,0,0,0.6);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }
        #reviewContent {
            background: white;
            padding: 30px;
            border-radius: 10px;
            width: 400px;
            text-align: center;
        }
        #reviewContent h3 {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<div class="header">
    <h2><%= testName %></h2>
    <div class="timer">
        Time Remaining: <span id="time"></span>
    </div>
</div>
<form id="testForm" action="SubmitMCQTestServlet" method="post">
    <input type="hidden" name="testId" value="<%= testId %>">
    <div class="main-content">
        <div class="left-side">
            <div>
                <% for (int i = 0; i < questions.size(); i++) {
                    Question question = questions.get(i);
                %>
                <div class="question" style="display: none;">
                    <div class="question-title">
                        Question <%= i + 1 %>:
                    </div>
                    <p><%= question.getQuestionText() %></p>
                    <% for (int j = 0; j < question.getOptions().size(); j++) { %>
                        <div class="option">
                            <input type="radio" 
                                   name="answer_<%= question.getQuestionId() %>"
                                   value="<%= question.getOptions().get(j) %>"
                                   id="q<%= question.getQuestionId() %>_option<%= j %>">
                            <label for="q<%= question.getQuestionId() %>_option<%= j %>">
                                <%= question.getOptions().get(j) %>
                            </label>
                        </div>
                    <% } %>
                </div>
                <% } %>
            </div>
            <div class="navigation-buttons">
                <button type="button" id="prevBtn" onclick="prevQuestion()">Previous</button>
                <button type="button" id="nextBtn" onclick="nextQuestion()">Next</button>
            </div>
        </div>
        <div class="right-side">
            <div>
                <h3 style="text-align: center;">Questions</h3>
                <div class="question-list">
                    <% for (int i = 0; i < questions.size(); i++) { %>
                        <button type="button" 
                                id="btn_<%= questions.get(i).getQuestionId() %>"
                                onclick="jumpToQuestion(<%= i %>)">
                            <%= (i + 1) %>
                        </button>
                    <% } %>
                </div>
            </div>
            <button type="button" 
                    id="submitBtn" 
                    class="submit-button" 
                    onclick="reviewAndSubmit()">
                Submit Test
            </button>
        </div>
    </div>
</form>
<div id="reviewModal">
    <div id="reviewContent">
        <h3>Review your Test</h3>
        <ul id="reviewList" style="text-align: left;"></ul>
        <button onclick="finalSubmit()" style="margin-top: 20px;">Confirm and Submit</button>
        <button onclick="closeReview()" style="margin-top: 10px;">Cancel</button>
    </div>
</div>
<script>
    let currentQuestion = 0;
    const totalQuestions = <%= questions.size() %>;
    const endTime = new Date(<%= endTime.getTime() %>);
    let timerInterval = null;
    let hasSubmitted = false;

    function showQuestion(index) {
        const allQuestions = document.querySelectorAll('.question');
        allQuestions.forEach((q, i) => {
            q.style.display = (i === index) ? 'block' : 'none';
        });
        document.getElementById('prevBtn').disabled = (index === 0);
        document.getElementById('nextBtn').disabled = (index === totalQuestions - 1);
        currentQuestion = index;
    }

    function nextQuestion() {
        if (currentQuestion < totalQuestions - 1) {
            currentQuestion++;
            showQuestion(currentQuestion);
        }
    }

    function prevQuestion() {
        if (currentQuestion > 0) {
            currentQuestion--;
            showQuestion(currentQuestion);
        }
    }

    function jumpToQuestion(index) {
        showQuestion(index);
    }

    function markAnswered(questionId) {
        const radios = document.getElementsByName('answer_' + questionId);
        let answered = false;
        for (const radio of radios) {
            if (radio.checked) {
                answered = true;
                break;
            }
        }
        const button = document.getElementById('btn_' + questionId);
        if (answered) {
            button.classList.add('answered');
        } else {
            button.classList.remove('answered');
        }
    }

    function startTimer(display) {
        timerInterval = setInterval(function () {
            if (hasSubmitted) {
                clearInterval(timerInterval);
                return;
            }
            const now = new Date();
            let diff = Math.floor((endTime - now) / 1000);
            if (diff <= 0) {
                clearInterval(timerInterval);
                if (!hasSubmitted) {
                    alert("Time's up! Submitting your test...");
                    finalSubmit();
                }
                return;
            }
            let hrs = Math.floor(diff / 3600);
            let mins = Math.floor((diff % 3600) / 60);
            let secs = diff % 60;
            display.textContent = 
                (hrs > 0 ? hrs + " Hr " : "") +
                (mins > 0 ? mins + " mins " : "") +
                secs + " secs";
        }, 1000);
    }

    function reviewAndSubmit() {
        if (hasSubmitted) return;
        const list = document.getElementById('reviewList');
        list.innerHTML = "";
        <% for (int i = 0; i < questions.size(); i++) { 
            Question q = questions.get(i); %>
            {
                let qid = <%= q.getQuestionId() %>;
                const radios = document.getElementsByName('answer_' + qid);
                let attempted = false;
                for (let radio of radios) {
                    if (radio.checked) {
                        attempted = true;
                        break;
                    }
                }
                const li = document.createElement('li');
                li.textContent = "Question <%= i + 1 %> - " + (attempted ? "Attempted" : "Not Attempted");
                list.appendChild(li);
            }
        <% } %>
        document.getElementById('reviewModal').style.display = 'flex';
    }

    function closeReview() {
        if (!hasSubmitted) {
            document.getElementById('reviewModal').style.display = 'none';
        }
    }

    function finalSubmit() {
        if (hasSubmitted) return;
        hasSubmitted = true;
        clearInterval(timerInterval);
        document.getElementById('submitBtn').disabled = true;
        document.getElementById('testForm').submit();
    }

    window.onload = function () {
        showQuestion(currentQuestion);
        startTimer(document.getElementById('time'));
        document.querySelectorAll('input[type=radio]').forEach(radio => {
            radio.addEventListener('change', function() {
                const qid = this.name.split("_")[1];
                markAnswered(qid);
            });
        });
    };
</script>
</body>
</html>