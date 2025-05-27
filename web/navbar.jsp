<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.work.bean.User, com.work.dao.ProjectDAO, com.work.util.DBUtil" %>
<%@ page session="true" %>
<%
    String currentUserName = (String) session.getAttribute("userName");
    int unfinishedCount = 0;

    if (currentUserName != null) {
        out.println("当前 session 用户名：" + currentUserName);
        try (java.sql.Connection conn = DBUtil.getConnection()) {
            ProjectDAO projectDAO = new ProjectDAO(conn);
            unfinishedCount = projectDAO.countUnfinishedProjectsByUser(currentUserName);
        } catch (Exception e) {
            e.printStackTrace();
        }
    } else {
        out.println("⚠️ 当前 session 中没有 userName！");
    }
%>

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
        .badge {
            display: inline-flex;
            justify-content: center;
            align-items: center;
            width: 20px;
            height: 20px;
            font-size: 12px;
            font-weight: bold;
            color: white;
            background-color: #e74c3c;
            border-radius: 50%;
            vertical-align: top;
            margin-left: 6px;
            box-shadow: 0 0 2px rgba(0,0,0,0.3);
            padding: 0;
            line-height: 1;
            position: absolute; top: -4px; right: -6px;
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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<div class="navbar">
    <div class="navbar-left">
        <div style="color:red;">
            <%
                out.println("【调试输出】当前用户是：" + currentUserName);
            %>
        </div>
        <a href="index.jsp"><i class="fas fa-home"></i> 首页</a>
        <a href="admin.jsp"><i class="fas fa-user-shield"></i> 管理员中心</a>
        <a href="department.jsp"><i class="fas fa-building"></i> 部门管理</a>
        <%
            String displayCount = unfinishedCount > 99 ? "99+" : String.valueOf(unfinishedCount);
        %>
        <a href="personal.jsp" id="personalTaskLink" style="position: relative;" title="你有 <%= unfinishedCount %> 个未完成项目">
            <i class="fas fa-tasks"></i> 个人任务
            <% if (unfinishedCount > 0) { %>
            <span class="badge"><%= displayCount %></span>
            <% } %>
        </a>
        <%= "当前用户：" + currentUserName + " 未完成数：" + unfinishedCount %>
        <a href="projectList.jsp"><i class="fas fa-list"></i> 项目总览</a>
        <%
            String role = (String) session.getAttribute("role");
            if ("super_department".equals(role)) {
        %>
        <a href="departmentManagement.jsp"><i class="fas fa-upload"></i> 任务发布</a>
        <%
        } else if ("sub_department".equals(role)) {
        %>
        <a href="taskManagement.jsp"><i class="fas fa-clipboard-list"></i> 任务管理</a>
        <%
            }
        %>
    </div>
    <div class="navbar-right">
        <%
            String currentUser = (String) session.getAttribute("userName");
            if (currentUser != null) {
        %>
        <span class="user-info"><i class="fas fa-user-circle"></i> 已登录：<%= currentUser %></span>
        <a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> 退出</a>
        <%
        } else {
        %>
        <a href="login.jsp"><i class="fas fa-sign-in-alt"></i> 登录</a>
        <%
            }
        %>
        &nbsp;&nbsp;&nbsp;&nbsp;
    </div>
</div>

</body>
</html>