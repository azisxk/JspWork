<%@ page import="java.util.*, com.work.bean.*, com.work.dao.*, java.sql.*, javax.servlet.*" %>
<%@ page import="java.sql.Date" %>
<%@ page import="java.time.LocalDate" %>
<%@ page session="true" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String role = (String) session.getAttribute("role");
    String currentDept = (String) session.getAttribute("departmentName"); // 假设session存了当前部门名
    if (role == null || !role.equals("sub_department")) {
        response.sendRedirect("login.jsp");
        return;
    }

    request.setCharacterEncoding("UTF-8");
    String msg = "";
    List<Project> projects = new ArrayList<>();
    List<User> users = new ArrayList<>();

    try (Connection conn = com.work.util.DBUtil.getConnection()) {
        ProjectDAO projectDAO = new ProjectDAO(conn);
        UserDAO userDAO = new UserDAO(conn);

        // 只获取分配给当前部门的项目
        projects = projectDAO.getProjectsByDepartment(currentDept);
        users = userDAO.getUsersByDepartment(currentDept);

        // 处理编辑提交
        String action = request.getParameter("action");
        if ("edit".equals(action)) {
            String idStr = request.getParameter("projectId");
            if (idStr != null && !idStr.isEmpty()) {
                int id = Integer.parseInt(idStr);
                String newName = request.getParameter("editName");
                String newContent = request.getParameter("editContent");
                String stage = request.getParameter("progressStage");
                String[] members = request.getParameterValues("editMembers");
                String endStr = request.getParameter("editEnddate");

                Project p = new Project(newName, newContent, stage, id);
                if (endStr != null && !endStr.isEmpty()) {
                    p.setEndDate(Date.valueOf(endStr));
                }

                boolean updated = projectDAO.updateProject(p);

                if (updated) {
                    // 清除旧的成员关系
                    projectDAO.clearProjectMembers(id);

                    // 添加新的成员关系（通过 username 查 userId）
                    if (members != null) {
                        for (String username : members) {
                            User user = userDAO.getUser(username);
                            if (user != null) {
                                projectDAO.addProjectMember(id, user.getId());
                            }
                        }
                    }

                    msg = "🔄 项目更新成功！";
                } else {
                    msg = "❌ 项目更新失败！";
                }

                // 刷新项目列表
                projects = projectDAO.getProjectsByDepartment(currentDept);
            }
        }



        // 处理删除
        if ("delete".equals(action)) {
            String idStr = request.getParameter("projectId");
            if (idStr != null && !idStr.isEmpty()) {
                int id = Integer.parseInt(idStr);
                boolean deleted = projectDAO.deleteProject(id);
                msg = deleted ? "🗑️ 项目删除成功！" : "❌ 删除失败，项目不存在或数据库错误。";
                projects = projectDAO.getProjectsByDepartment(currentDept);
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
        msg = "🚨 数据库操作异常：" + e.getMessage();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>下级部门任务管理</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/choices.js/public/assets/styles/choices.min.css">
    <script src="https://cdn.jsdelivr.net/npm/choices.js/public/assets/scripts/choices.min.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(to bottom right, #f0f4f8, #d9e2ec);
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 960px;
            margin: 60px auto;
            background-color: #ffffff;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
        }
        h2 {
            border-left: 5px solid #007bff;
            color: #333333;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 10px;
        }

        .form-group {
            margin-bottom: 20px;
        }
        .member-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 10px;
        }
        .member-grid label {
            font-weight: normal;
        }
        label {
            font-weight: 600;
        }
        input[type="text"], textarea, select {
            width: 100%;
            padding: 10px;
            margin-top: 6px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 14px;
        }
        input[type="submit"] {
            background-color: #3498db;
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        input[type="submit"]:hover {
            background-color: #2980b9;
        }
        .message {
            color: #27ae60;
            font-weight: bold;
            margin-bottom: 20px;
        }
        hr {
            border: none;
            border-top: 1px solid #ddd;
            margin: 40px 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 40px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #f7f9fc;
        }
        .actions button {
            margin-right: 8px;
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            color: #fff;
            background-color: #3498db;
        }
        .actions button.delete {
            background-color: #e74c3c;
        }
    </style>
</head>
<body>
<jsp:include page="navbar.jsp"/>
<div class="container">
    <h2>下级部门任务管理</h2>
    <p class="message"><%= msg %></p>

    <h3>任务列表</h3>
    <table>
        <thead>
        <tr>
            <th>项目名称</th>
            <th>项目内容</th>
            <th>项目进度</th>
            <th>结束日期</th>
            <th>参与成员</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <% for(Project p : projects) { %>
        <tr>
            <td><%= p.getName() %></td>
            <td><%= p.getContent() %></td>
            <td><%= p.getProgressStage() %></td>
            <td><%= p.getEnddate() != null ? p.getEnddate().toString() : "-" %></td>
            <td><%= String.join(", ", p.getAssignedMembers()) %></td>
            <td class="actions">
                <button onclick="showEditForm(<%= p.getId() %>)">编辑</button>
                <form action="taskManagement.jsp" method="post" style="display:inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="projectId" value="<%= p.getId() %>">
                    <button type="submit" class="delete" onclick="return confirm('确认删除该项目吗？')">删除</button>
                </form>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>

    <hr>

    <h3>编辑项目</h3>
    <form method="post" action="taskManagement.jsp" id="editForm" style="display:none;">
        <input type="hidden" name="action" value="edit">
        <input type="hidden" name="projectId" id="editProjectId">

        <div class="form-group">
            <label>项目名称</label>
            <input type="text" name="editName" id="editName" required>
        </div>
        <div class="form-group">
            <label>项目内容</label>
            <textarea name="editContent" rows="4" id="editContent" required></textarea>
        </div>
        <div class="form-group">
            <label>项目进度</label>
            <select name="progressStage" id="progressStage" required>
                <option value="框架搭建">框架搭建</option>
                <option value="逻辑完成">逻辑完成</option>
                <option value="细节美化">细节美化</option>
                <option value="部署完成">部署完成</option>
            </select>
        </div>
        <div class="form-group">
            <label>结束日期（可选）</label>
            <input type="date" name="editEnddate" id="editEnddate">
        </div>
        <div class="form-group">
            <label>参与成员</label>
            <div class="member-grid" id="editMembersContainer">
                <% for(User u : users) { %>
                <label><input type="checkbox" name="editMembers" value="<%= u.getUsername() %>" class="editMemberCheckbox"> <%= u.getUsername() %></label>
                <% } %>
            </div>
        </div>
        <input type="submit" value="更新项目" style="width: 100%">
    </form>
</div>

<script>
    // 成员列表（来自服务端）：
    const allUsers = [
        <% for (User u : users) { %>
        "<%= u.getUsername().replace("\"", "\\\"") %>",
        <% } %>
    ];

    const projectsData = {
        <% for(Project p : projects) { %>
        "<%= p.getId() %>": {
            name: "<%= p.getName().replace("\"", "\\\"") %>",
            content: "<%= p.getContent().replace("\"", "\\\"").replace("\n", "\\n") %>",
            stage: "<%= p.getProgressStage() %>",
            enddate: "<%= p.getEnddate() != null ? p.getEnddate().toString() : "" %>",
            members: [<%
                List<String> mems = p.getAssignedMembers();
                for (int i = 0; i < mems.size(); i++) {
                    out.print("\"" + mems.get(i).replace("\"", "\\\"") + "\"");
                    if (i != mems.size() - 1) out.print(",");
                }
            %>]
        },
        <% } %>
    };

    let choicesInstance;

    function showEditForm(projectId) {
        const data = projectsData[projectId];
        if (!data) return;

        document.getElementById("editForm").style.display = "block";
        document.getElementById("editProjectId").value = projectId;
        document.getElementById("editName").value = data.name;
        document.getElementById("editContent").value = data.content;
        document.getElementById("progressStage").value = data.stage;
        document.getElementById("editEnddate").value = data.enddate || "";

        const select = document.getElementById("editMembersSelect");
        select.innerHTML = ""; // 清空旧选项

        allUsers.forEach(username => {
            const option = document.createElement("option");
            option.value = username;
            option.text = username;
            if (data.members.includes(username)) {
                option.selected = true;
            }
            select.appendChild(option);
        });

        // 初始化或更新 choices.js
        if (choicesInstance) {
            choicesInstance.destroy();
        }
        choicesInstance = new Choices(select, {
            removeItemButton: true,
            placeholderValue: '请选择参与成员',
            noResultsText: '未找到匹配成员'
        });

        window.scrollTo({top: document.getElementById("editForm").offsetTop, behavior: "smooth"});
    }
</script>


</body>
</html>
