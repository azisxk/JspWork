<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.work.bean.User, com.work.dao.UserDAO, com.work.util.DBUtil" %>
<%@ page import="java.sql.Connection" %>

<%
    request.setCharacterEncoding("UTF-8");
    String currentUser = (String) session.getAttribute("userName");

    if (currentUser == null || !UserDAO.isAdmin(currentUser)) {
        response.sendRedirect("unauthorized.jsp");
        return;
    }

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
    <style>
        input[type="submit"] {
            padding: 10px 0;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            width: 120px;
            min-width: 100px;
            text-align: center;
        }

        .form-group {
            margin-bottom: 10px;
        }

        .operation-cell {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            width: 100%;
        }

        .operation-cell form {
            display: flex;
            align-items: center;
            flex-wrap: nowrap;
            gap: 8px;
            flex: 1;
        }

        .operation-cell input[type="text"],
        .operation-cell select {
            flex: 1;
            min-width: 120px;
            max-width: 180px;
            padding: 6px 10px;
            font-size: 14px;
        }

        .operation-cell .btn-submit {
            width: 100px;
            height: 36px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            margin-left: auto;
        }

        .operation-cell .btn-submit:hover {
            background-color: #0056b3;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
        }

        th, td {
            padding: 8px;
            border: 1px solid #ddd;
            text-align: center;
            word-wrap: break-word;
            vertical-align: middle;
        }

        td .operation-cell {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-wrap: wrap;
        }

        td .form-group {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            justify-content: center;
            margin-bottom: 5px;
        }

        td input[type="text"],
        td select {
            padding: 4px;
            min-width: 120px;
            max-width: 150px;
            box-sizing: border-box;
        }

        .btn-submit {
            padding: 4px 10px;
            background-color: #4CAF50;
            color: white;
            border: none;
            cursor: pointer;
            border-radius: 3px;
        }

        .btn-submit:hover {
            background-color: #45a049;
        }


    </style>
</head>
<body>
<jsp:include page="navbar.jsp" />

<div class="container">
    <h2 id="adduser">添加用户</h2>
    <% if (request.getAttribute("successMessage") != null && "add".equals(request.getAttribute("actionType"))) { %>
    <p style="color:green;"><%= request.getAttribute("successMessage") %></p>
    <% } %>
    <form method="post" action="adminServlet">
        <% if (request.getAttribute("message") != null) { %>
        <p style="color:red;"><%= request.getAttribute("message") %></p>
        <% } %>
        <input type="hidden" name="action" value="add">
        <div class="form-group">
            <label for="newUsername">用户名：</label>
            <input type="text" name="newUsername" id="newUsername" required>
        </div>
        <div class="form-group">
            <label for="newPassword">密码：</label>
            <input type="password" name="newPassword" id="newPassword" required>
        </div>
        <div class="form-group">
            <label for="newRole">身份：</label>
            <select name="newRole" id="newRole" required>
                <option value="user">个人级用户</option>
                <option value="super_department">上级部门</option>
                <option value="sub_department">下级部门</option>
                <option value="admin">管理员</option>
            </select>
        </div>
        <div class="form-group">
            <label for="newDepartment">部门：</label>
            <input type="text" name="newDepartment" id="newDepartment" placeholder="请输入部门">
        </div>
        <div class="form-group">
            <label for="newContactInfo">联系方式：</label>
            <input type="text" name="newContactInfo" id="newContactInfo" placeholder="请输入联系方式">
        </div>
        <input type="submit" value="添加用户" style="width: 100%">
    </form>

    <h2>删除用户</h2>
    <% if (request.getAttribute("successMessage") != null && "delete".equals(request.getAttribute("actionType"))) { %>
    <p style="color:green;"><%= request.getAttribute("successMessage") %></p>
    <% } %>

    <form method="post" action="adminServlet">
        <input type="hidden" name="action" value="delete">
        <div class="form-group">
            <label for="deleteUsername">选择用户：</label>
            <select name="deleteUsername" id="deleteUsername" required>
                <% for (User u : users) {
                    if (!"admin".equals(u.getRole())) { %>
                <option value="<%=u.getUsername()%>"><%=u.getUsername()%></option>
                <% }} %>
            </select>
        </div>
        <input type="submit" value="删除用户" style="width: 100%">
    </form>

    <h2>所有用户</h2>
    <table>
        <tr>
            <th>用户名</th>
            <th>身份</th>
            <th>联系方式</th>
            <th>部门</th>
            <th style="width: 50%">操作</th>
        </tr>
        <% for (User u : users) { %>
        <tr>
            <td><%= u.getUsername() %></td>
            <td>
                <%
                    String roleLabel;
                    String role = u.getRole();
                    switch (role) {
                        case "admin":
                            roleLabel = "管理员";
                            break;
                        case "super_department":
                            roleLabel = "上级部门";
                            break;
                        case "sub_department":
                            roleLabel = "下级部门";
                            break;
                        case "user":
                            roleLabel = "个人级用户";
                            break;
                        default:
                            roleLabel = "未知";
                            break;
                    }
                    //12321321321
                %>
                <%= roleLabel %>
            </td>
            <td><%= u.getContactInfo() == null ? "" : u.getContactInfo() %></td>
            <td><%= u.getDepartment() == null ? "" : u.getDepartment() %></td>
            <td>
                <div class="operation-cell">
                    <form method="post" action="adminServlet">
                        <input type="hidden" name="modifyUsername" value="<%=u.getUsername()%>">
                        <% if ("admin".equals(u.getRole())) { %>
                        <input type="hidden" name="action" value="modifyContactAndDepartment">
                        <div class="form-group">
                            <input type="text" name="modifyContactInfo"
                                   value="<%= u.getContactInfo() == null ? "" : u.getContactInfo() %>"
                                   placeholder="联系方式">
                            <input type="text" name="modifyDepartment"
                                   value="<%= u.getDepartment() == null ? "" : u.getDepartment() %>"
                                   placeholder="部门">
                        </div>
                        <% } else { %>
                        <input type="hidden" name="action" value="modifyRoleAndContact">
                        <div class="form-group">
                            <select name="modifyRole" required>
                                <option value="super_department" <%="super_department".equals(u.getRole()) ? "selected" : ""%>>上级部门</option>
                                <option value="sub_department" <%="sub_department".equals(u.getRole()) ? "selected" : ""%>>下级部门</option>
                                <option value="user" <%="user".equals(u.getRole()) ? "selected" : ""%>>个人级用户</option>
                            </select>
                            <input type="text" name="modifyContactInfo"
                                   value="<%= u.getContactInfo() == null ? "" : u.getContactInfo() %>"
                                   placeholder="联系方式">
                            <input type="text" name="modifyDepartment"
                                   value="<%= u.getDepartment() == null ? "" : u.getDepartment() %>"
                                   placeholder="部门">
                        </div>
                        <% } %>
                        <input type="submit" value="修改" class="btn-submit">
                    </form>
                </div>
            </td>

        </tr>
        <% } %>
    </table>
</div>
</body>
</html>
