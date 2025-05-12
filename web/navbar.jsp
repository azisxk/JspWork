<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <style>
        /* 通用字体 */
        body {
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }

        /* 顶栏样式 */
        .navbar {
            background-color: #343a40; /* 深灰背景 */
            color: #ffffff;
            padding: 12px 30px;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 1000;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            transition: background-color 0.3s ease;
        }

        .navbar-left,
        .navbar-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .navbar a {
            color: #ffffff;
            text-decoration: none;
            font-weight: 500;
            font-size: 15px;
            padding: 6px 10px;
            border-radius: 4px;
            transition: background-color 0.2s ease, color 0.2s ease;
        }

        .navbar a:hover {
            background-color: #495057;
            color: #f8f9fa;
        }

        .user-info {
            font-size: 14px;
            color: #ced4da;
        }

        body {
            margin-top: 70px; /* 防止内容被导航栏遮挡 */
        }

        /* 响应式设计 */
        @media (max-width: 768px) {
            .navbar {
                flex-direction: column;
                align-items: flex-start;
                padding: 15px 20px;
            }

            .navbar-left,
            .navbar-right {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
                width: 100%;
            }

            .navbar a {
                font-size: 14px;
                width: 100%;
            }

            .user-info {
                margin-top: 5px;
            }
        }
    </style>
</head>
<body>
<div class="navbar">
    <div class="navbar-left">
        <a href="index.jsp">首页</a>
        <a href="admin.jsp">管理员中心</a>
        <a href="department.jsp">部门管理</a>
        <a href="personal.jsp">个人任务</a>
        <a href="projectList.jsp">项目总览</a>
    </div>
    <div class="navbar-right">
        <%
            String currentUser = (String) session.getAttribute("userName");
            if (currentUser != null) {
                System.out.println("logined");
        %>
        <span class="user-info">已登录：<%= currentUser %></span>
        <a href="logout.jsp">退出</a>
        <%
        } else {
        %>
        <a href="login.jsp">登录</a>
        <%
            }
        %>
        &nbsp;&nbsp;&nbsp;&nbsp;
    </div>
</div>
</body>
</html>