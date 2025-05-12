<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% request.setCharacterEncoding("UTF-8"); %>
<%
    String checkpwd = request.getParameter("checkpwd");
    String checkval = request.getParameter("checkval");
%>
<html>
<head>
    <%
        String loginAlert = (String) session.getAttribute("loginAlert");
        if (loginAlert != null) {
            session.removeAttribute("loginAlert"); // 显示一次就清除
        }
    %>

    <% if (loginAlert != null) { %>
    <script type="text/javascript">
        alert("<%= loginAlert %>");
    </script>
    <% } %>
    <title>登录页面</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
    <script type="text/javascript">
        function mycheck(){
            var form = document.forms["form1"];
            if (form1.userName.value==""){
                alert("用户名不能为空，请输入用户名!");
                form1.userName.focus();
                return false;
            }
            if (form1.password.value==""){
                alert("密码不能为空，请输入密码!");
                form1.password.focus();
                return false;
            }
            if (form1.validationCode.value != form1.validationCode1.value){
                alert("请输入正确的验证码!");
                form1.validationCode.focus();
                return false;
            } return true;
        }
        window.onload = function () {
            <% if ("False".equals(checkpwd)) { %>
            alert("账号或密码错误，请重新输入！");
            <% } else if ("False".equals(checkval)) { %>
            alert("验证码错误，请重新输入！");
            <% } %>
        }
    </script>
</head>
<body>
<%@ include file="navbar.jsp" %>

<div class="container">
    <h2>登录系统</h2>
    <form action="loginCheck" name="form1" method="post" onsubmit="return mycheck();">
        <div class="form-group">
            <label for="userName">用户名</label>
            <input type="text" name="username" id="userName" required>
        </div>
        <div class="form-group">
            <label for="password">密码</label>
            <input type="password" name="password" id="password" required>
        </div>
        <div class="form-group captcha-group">
            <label for="validationCode">验证码</label>
            <div class="captcha-combo">
                <input type="text" name="validationCode" id="validationCode" size="6" required>
                <%
                    int intmethod1 = (int)((((Math.random()) * 11)) - 1);
                    int intmethod2 = (int)((((Math.random()) * 11)) - 1);
                    int intmethod3 = (int)((((Math.random()) * 11)) - 1);
                    int intmethod4 = (int)((((Math.random()) * 11)) - 1);
                    String intsum = intmethod1 + "" + intmethod2 + intmethod3 + intmethod4;
                %>
                <div class="captcha-images" style="width:20%;">
                    <img src="img/<%= intmethod1 %>.png" alt="captcha1">
                    <img src="img/<%= intmethod2 %>.png" alt="captcha2">
                    <img src="img/<%= intmethod3 %>.png" alt="captcha3">
                    <img src="img/<%= intmethod4 %>.png" alt="captcha4">
                </div>
            </div>
            <input type="hidden" name="validationCode1" value="<%= intsum %>">
        </div>
        <div class="button-group">
            <input type="submit" name="submit1" value="登录">
            <br><br>
            <input type="reset" value="重置">
        </div>
    </form>
</div>
</body>
</html>
