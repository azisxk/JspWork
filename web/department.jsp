<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*, com.work.bean.*, com.work.dao.*, java.sql.*, javax.servlet.*" %>
<%@ page import="java.sql.Date" %>
<%@ page import="java.time.LocalDate" %>
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
            String endStr = request.getParameter("enddate");
            String name = request.getParameter("name");
            String content = request.getParameter("content");
            String[] members = request.getParameterValues("members");

            if (name != null && content != null) {
                if (projectDAO.projectExistsByName(name)) {
                    msg = "❌ 项目名称已存在，请更换名称。";
                } else if (endStr == null || endStr.isEmpty()) {
                    msg = "❌ 请输入项目结束时间。";
                } else if (members == null || members.length == 0) {
                    msg = "❌ 请至少选择一名参与成员。";
                } else {
                    Project p = new Project(name, content, "框架搭建");
                    p.setStartDate(Date.valueOf(LocalDate.now()));
                    String creator = (String) session.getAttribute("userName");
                    p.setCreator(creator);
                    if (endStr != null && !endStr.isEmpty()) {
                        p.setEndDate(Date.valueOf(endStr));
                    }
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
                String endStr = request.getParameter("editEnddate");
                Project p = new Project(newName, newContent, stage, id);
                if (endStr != null && !endStr.isEmpty()) {
                    p.setEndDate(Date.valueOf(endStr));
                }
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
    <!-- 放在<head>中 -->
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
        h2, h3 {
            color: #2c3e50;
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
    </style>
</head>
<body>
<jsp:include page="navbar.jsp"/>


<div class="container">
    <h2>部门项目管理</h2>
    <p class="message"><%= msg %></p>

    <!-- 添加项目 -->
    <form method="post" action="department.jsp" onsubmit="return validateAddForm()">
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
            <label>分配成员</label>
            <div class="member-grid">
                <% for (User u : users) { %>
                <label><input type="checkbox" name="members" value="<%= u.getUsername() %>"> <%= u.getUsername() %></label>
                <% } %>
            </div>
        </div>

        <div class="form-group">
            <label>项目结束时间</label>
            <%
                java.time.LocalDate today = java.time.LocalDate.now();
            %>
            <input type="date" name="enddate" required min="<%= today.plusDays(1) %>">
        </div>

        <input type="submit" value="添加项目" style="width: 100%">
    </form>

    <hr>

    <!-- 编辑项目 -->
    <form method="post" action="department.jsp">
        <input type="hidden" name="action" value="edit">
        <h3>✏️ 编辑项目</h3>
        <div class="form-group">
            <label>选择项目</label>
            <select name="projectId" id="editProjectSelect" onchange="fillForm()">
                <option value=""></option>
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
            <label>项目结束时间（可选）</label>
            <input type="date" name="editEnddate" id="editEnddate" value="<%= editProject != null && editProject.getEnddate() != null ? editProject.getEnddate().toString() : "" %>">
        </div>

        <div class="form-group">
            <label>参与成员</label>
            <div class="member-grid">
                <% for (User u : users) { %>
                <label><input type="checkbox" name="editMembers" value="<%= u.getUsername() %>" class="editMemberCheckbox"> <%= u.getUsername() %></label>
                <% } %>
            </div>
        </div>

        <input type="submit" value="更新项目" style="width: 100%">
    </form>

    <hr>

    <!-- 删除项目 -->
    <form method="post" action="department.jsp">
        <input type="hidden" name="action" value="delete">
        <h3>🗑️ 删除项目</h3>
        <div class="form-group">
            <label>选择项目</label>
            <select name="projectId" id="projectIdDelete">
                <option value=""></option>
                <% for (Project p : projects) { %>
                <option value="<%= p.getId() %>"><%= p.getName() %></option>
                <% } %>
            </select>

        </div>
        <input type="submit" value="删除项目" style="width: 100%">
    </form>
</div>

<script>
    const editSelect = new Choices('#editProjectSelect', {
        searchEnabled: true,
        itemSelectText: '',
        placeholderValue: '请选择项目'
    });

    const deleteSelect = new Choices('#projectIdDelete', {
        searchEnabled: true,
        itemSelectText: '',
        placeholderValue: '请选择项目'
    });
    function validateAddForm() {
        const checkboxes = document.querySelectorAll('input[name="members"]:checked');
        const endDate = document.querySelector('input[name="enddate"]').value;

        if (checkboxes.length === 0) {
            alert("❌ 请至少选择一名参与成员！");
            return false;
        }
        if (!endDate) {
            alert("❌ 请输入项目结束时间！");
            return false;
        }
        return true;
    }
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