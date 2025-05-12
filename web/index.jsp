<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*, com.work.bean.*, com.work.dao.ProjectDAO, java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String msg = request.getParameter("msg") != null ? request.getParameter("msg") : "";

    List<Project> projects = new ArrayList<>();
    try {
        Connection conn = com.work.util.DBUtil.getConnection();
        ProjectDAO projectDAO = new ProjectDAO(conn);
        projects = projectDAO.getAllProjects();
    } catch (SQLException e) {
        e.printStackTrace();
        msg = "加载项目失败：" + e.getMessage();
    }
%>

<html>
<head>
    <title>首页</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        /* 样式保持不变 */
    </style>
</head>
<body>
<jsp:include page="navbar.jsp"/>

<div class="container">
    <h2>项目列表</h2>
    <p class="message"><%= msg %></p>

    <!-- 项目展示 -->
    <h3>所有项目</h3>
    <% if (projects != null && !projects.isEmpty()) { %>
    <table style="width: 100%; border-collapse: collapse; margin-bottom: 20px;">
        <thead>
        <tr style="background-color: #3498db; color: #000;">
            <th>项目名称</th>
            <th>进度</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <% for (Project p : projects) { %>
        <tr>
            <td><%= p.getName() %></td>
            <td><%= p.getProgressStage() %></td>
            <td>
                <a href="department.jsp?action=edit&projectId=<%= p.getId() %>" style="color: #3498db; text-decoration: none;">编辑</a> |
                <a href="department.jsp?action=delete&projectId=<%= p.getId() %>" style="color: #e74c3c; text-decoration: none;">删除</a>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
    <% } else { %>
    <p>暂无项目。</p>
    <% } %>
</div>
</body>
</html>
