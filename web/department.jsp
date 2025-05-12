<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*, com.work.bean.*, com.work.dao.*, java.sql.*, javax.servlet.*" %>
<%
    if (session == null || session.getAttribute("userName") == null || "user".equals(session.getAttribute("role"))) {
        response.sendRedirect("unauthorized.jsp"); // 跳转到未授权页面
        return;
    }
    request.setCharacterEncoding("UTF-8");
    String action = request.getParameter("action");
    String msg = "";

    List<User> users = new ArrayList<>();
    List<Project> projects = new ArrayList<>();

    try (Connection conn = com.work.util.DBUtil.getConnection()) {
        ProjectDAO projectDAO = new ProjectDAO(conn);
        UserDAO userDAO = new UserDAO(conn);

        if ("add".equals(action)) {
            String name = request.getParameter("name");
            String content = request.getParameter("content");
            String[] members = request.getParameterValues("members");

            if (name != null && content != null) {
                if (projectDAO.projectExistsByName(name)) {
                    msg = "❌ 项目名称已存在，请更换名称。";
                } else {
                    Project p = new Project(name, content, "框架搭建");
                    if (members != null) {
                        p.setAssignedMembers(Arrays.asList(members));
                    }
                    boolean added = projectDAO.addProject(p);
                    msg = added ? "✅ 项目添加成功！" : "❌ 项目添加失败！";
                }
            }
        }


        if ("edit".equals(action)) {
            String idStr = request.getParameter("projectId");
            if (idStr != null && !idStr.isEmpty()) {
                int id = Integer.parseInt(idStr);
                String newName = request.getParameter("editName");
                String newContent = request.getParameter("editContent");
                String stage = request.getParameter("progressStage");
                String[] members = request.getParameterValues("editMembers");

                Project p = new Project(newName, newContent, stage, id);
                if (members != null) {
                    p.setAssignedMembers(Arrays.asList(members));
                }
                boolean updated = projectDAO.updateProject(p);
                msg = updated ? "🔄 项目更新成功！" : "❌ 项目更新失败！";
            }
        }

        if ("delete".equals(action)) {
            String idStr = request.getParameter("projectId");
            if (idStr != null && !idStr.isEmpty()) {
                int id = Integer.parseInt(idStr);
                boolean deleted = projectDAO.deleteProject(id);
                msg = deleted ? "🗑️ 项目删除成功！" : "❌ 删除失败，项目不存在或数据库错误。";
            }
        }

        // 获取展示数据
        projects = projectDAO.getAllProjects();
        users = userDAO.getAllUsers();
    } catch (Exception e) {
        e.printStackTrace();
        msg = "🚨 数据库操作异常：" + e.getMessage();
    }
    Project editProject = null;
    String projectIdStr = request.getParameter("projectId");

    if ("edit".equals(action) && projectIdStr != null) {
        try {
            int projectId = Integer.parseInt(projectIdStr);
            Connection conn = com.work.util.DBUtil.getConnection();
            ProjectDAO projectDAO = new ProjectDAO(conn);
            editProject = projectDAO.getProjectById(projectId);  // 你需要确保 ProjectDAO 有这个方法
        } catch (Exception e) {
            e.printStackTrace();
            msg = "编辑项目加载失败：" + e.getMessage();
        }
    }

%>


<html>
<head>
    <title>部门项目管理</title>
    <link rel="stylesheet" href="styles.css">
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
        h2, h3 {
            color: #2c3e50;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 10px;
        }
        .form-group {
            margin-bottom: 20px;
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
    </style>
</head>
<body>
<jsp:include page="navbar.jsp"/>


<div class="container">
    <h2>部门项目管理</h2>
    <p class="message"><%= msg %></p>

    <!-- 添加项目 -->
    <form method="post" action="department.jsp">
        <input type="hidden" name="action" value="add">
        <h3>📌 添加新项目</h3>
        <div class="form-group">
            <label>项目名称</label>
            <input type="text" name="name" required>
        </div>
        <div class="form-group">
            <label>项目内容</label>
            <textarea name="content" rows="4" required></textarea>
        </div>
        <div class="form-group">
            <label>分配成员</label><br>
            <% for (User u : users) { %>
            <label><input type="checkbox" name="members" value="<%= u.getUsername() %>"> <%= u.getUsername() %></label><br>
            <% } %>
        </div>
        <input type="submit" value="添加项目">
    </form>

    <hr>

    <!-- 编辑项目 -->
    <form method="post" action="department.jsp">
        <input type="hidden" name="action" value="edit">
        <h3>✏️ 编辑项目</h3>
        <div class="form-group">
            <label>选择项目</label>
            <select name="projectId" id="editProjectSelect" onchange="fillForm()">
                <option value="">-- 请选择项目 --</option>
                <% for (Project p : projects) { %>
                <option value="<%= p.getId() %>"><%= p.getName() %></option>
                <% } %>
            </select>

        </div>
        <div class="form-group">
            <input type="hidden" name="projectId" value="<%= editProject != null ? editProject.getId() : "" %>">
            <label>新项目名称</label>
            <input type="text" name="editName" id="editName" value="<%= editProject != null ? editProject.getName() : "" %>">
        </div>
        <div class="form-group">
            <label>新项目内容</label>
            <textarea name="editContent" rows="4" id="editContent"><%= editProject != null ? editProject.getContent() : "" %></textarea>
        </div>
        <div class="form-group">
            <label>项目进度</label>
            <select name="progressStage" id="progressStage">
                <option value="框架搭建" <%= (editProject != null && "框架搭建".equals(editProject.getProgressStage())) ? "selected" : "" %>>框架搭建</option>
                <option value="逻辑完成" <%= (editProject != null && "逻辑完成".equals(editProject.getProgressStage())) ? "selected" : "" %>>逻辑完成</option>
                <option value="细节美化" <%= (editProject != null && "细节美化".equals(editProject.getProgressStage())) ? "selected" : "" %>>细节美化</option>
                <option value="部署完成" <%= (editProject != null && "部署完成".equals(editProject.getProgressStage())) ? "selected" : "" %>>部署完成</option>
            </select>
        </div>
        <div class="form-group">
            <label>参与成员</label><br>
            <% for (User u : users) { %>
            <label><input type="checkbox" name="editMembers" value="<%= u.getUsername() %>" class="editMemberCheckbox"> <%= u.getUsername() %></label><br>
            <% } %>
        </div>
        <input type="submit" value="更新项目">
    </form>

    <hr>

    <!-- 删除项目 -->
    <form method="post" action="department.jsp">
        <input type="hidden" name="action" value="delete">
        <h3>🗑️ 删除项目</h3>
        <div class="form-group">
            <label>选择项目</label>
            <select name="projectId" id="projectIdDelete">
                <option value="">-- 选择项目 --</option>
                <% for (Project p : projects) { %>
                <option value="<%= p.getId() %>"><%= p.getName() %></option>
                <% } %>
            </select>
        </div>
        <input type="submit" value="删除项目">
    </form>
</div>

<script>
    const projectData = {
        <% for (Project p : projects) { %>
        "<%= p.getId() %>": {
            name: "<%= p.getName().replace("\"", "\\\"") %>",
            content: "<%= p.getContent().replace("\"", "\\\"").replace("\n", "\\n") %>",
            stage: "<%= p.getProgressStage() %>",
            members: [<%
                List<String> members = p.getAssignedMembers();
                for (int i = 0; i < members.size(); i++) {
                    out.print("\"" + members.get(i).replace("\"", "\\\"") + "\"");
                    if (i < members.size() - 1) out.print(",");
                }
            %>]
        },
        <% } %>
    };

    function fillForm() {
        const id = document.getElementById("editProjectSelect").value;
        const data = projectData[id];
        if (!data) return;

        document.getElementById("editName").value = data.name;
        document.getElementById("editContent").value = data.content;
        document.getElementById("progressStage").value = data.stage;

        // 清空所有复选框状态
        document.querySelectorAll(".editMemberCheckbox").forEach(cb => {
            cb.checked = data.members.includes(cb.value);
        });
    }
</script>

</body>
</html>