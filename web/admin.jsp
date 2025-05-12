<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.work.bean.User, com.work.dao.UserDAO, com.work.util.DBUtil" %>
<%@ page import="java.sql.Connection" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 获取当前登录用户
    String currentUser = (String) session.getAttribute("userName");

    // 权限校验：必须是管理员
    if (currentUser == null || !UserDAO.isAdmin(currentUser)) {
        response.sendRedirect("unauthorized.jsp"); // 跳转到未授权页面
        return;
    }

    // 获取所有用户信息（必须在 try 内部完成）
    List<User> users = new ArrayList<>();
    try (Connection conn = DBUtil.getConnection()) {
        UserDAO userDAO = new UserDAO(conn);
        users = userDAO.getAllUsers();
    } catch (Exception e) {
        e.printStackTrace();
        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "数据库连接失败！");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>用户管理</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
<jsp:include page="navbar.jsp" />

<div class="container">
    <h2 id="adduser">添加用户</h2>
    <form method="post" action="adminServlet">
        <% if (request.getAttribute("message") != null) { %>
        <p style="color:red;"><%= request.getAttribute("message") %></p>
        <% } %>
        <input type="hidden" name="action" value="add">
        <div class="form-group">
            用户名：<input type="text" name="newUsername" required>
        </div>
        <div class="form-group">
            密码：<input type="password" name="newPassword" required>
        </div>
        <div class="form-group">
            身份：
            <select name="newRole" required>
                <option value="user">个人级用户</option>
                <option value="department">部门级用户</option>
                <option value="admin">管理员</option>
            </select>
        </div>
        <input type="submit" value="添加用户">
    </form>

    <h2>删除用户</h2>
    <form method="post" action="adminServlet">
        <input type="hidden" name="action" value="delete">
        <div class="form-group">
            选择用户：
            <select name="deleteUsername" required>
                <% for (User u : users) { %>
                <option value="<%=u.getUsername()%>"><%=u.getUsername()%></option>
                <% } %>
            </select>
        </div>
        <input type="submit" value="删除用户">
    </form>

    <h2>所有用户</h2>
    <table>
        <tr>
            <th>用户名</th>
            <th>身份</th>
            <th>操作</th>
        </tr>
        <% for (User u : users) { %>
        <tr>
            <td><%= u.getUsername() %></td>
            <td>
                <%
                    String roleLabel = switch (u.getRole()) {
                        case "admin" -> "管理员";
                        case "department" -> "部门级用户";
                        case "user" -> "个人级用户";
                        default -> "未知";
                    };
                %>
                <%= roleLabel %>
            </td>
            <td>
                <% if (!"admin".equals(u.getRole())) { %>
                <form method="post" action="adminServlet" style="display:inline;">
                    <input type="hidden" name="action" value="modifyRole">
                    <input type="hidden" name="modifyUsername" value="<%=u.getUsername()%>">
                    <div style="display: inline-flex; width: 70%">
                        <select name="modifyRole" required style="margin-right: 10px;">
                            <option value="department" <%="department".equals(u.getRole()) ? "selected" : ""%>>部门级用户</option>
                            <option value="user" <%="user".equals(u.getRole()) ? "selected" : ""%>>个人级用户</option>
                        </select>
                        <input type="submit" value="修改">
                    </div>
                </form>
                <% } else { %>
                （管理员身份不可修改）
                <% } %>
            </td>
        </tr>
        <% } %>
    </table>
</div>

</body>
</html>
