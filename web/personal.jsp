<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*, com.work.bean.*, com.work.dao.*, java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String msg = "";
    User currentUser = (User) session.getAttribute("user");

    if (currentUser == null) {
        response.sendRedirect("login.jsp");  // 未登录，跳转登录页
        return;
    }

    List<Project> myProjects = new ArrayList<>();

    try (Connection conn = com.work.util.DBUtil.getConnection()) {
        ProjectDAO projectDAO = new ProjectDAO(conn);

        // 更新进度操作
        if ("更新".equals(request.getParameter("action"))) {
            String idStr = request.getParameter("projectId");
            String newStage = request.getParameter("newStage");
            if (idStr != null && newStage != null) {
                int id = Integer.parseInt(idStr);
                Project project = projectDAO.getProjectById(id);
                if (project != null) {
                    boolean updated = projectDAO.updateProjectStage(id, newStage);
                    msg = updated ? "✅ 项目进度已更新" : "❌ 更新失败";
                } else {
                    msg = "⚠️ 项目不存在";
                }

            }
        }
        if ("删除".equals(request.getParameter("action"))) {
            String idStr = request.getParameter("projectId");
            if (idStr != null) {
                int id = Integer.parseInt(idStr);
                Project project = projectDAO.getProjectById(id);
                if ("user".equals(currentUser.getRole())) {
                    msg = "⛔ 只有管理才能删除项目";
                } else if (project != null) {
                    boolean deleted = projectDAO.deleteProject(id);
                    msg = deleted ? "🗑️ 项目已删除" : "❌ 删除失败";
                } else {
                    msg = "⚠️ 项目不存在";
                }
            }
        }


        // 加载属于当前用户的项目
        myProjects = projectDAO.getProjectsByUser(currentUser.getUsername());

    } catch (Exception e) {
        e.printStackTrace();
        msg = "🚨 操作异常：" + e.getMessage();
    }

%>

<html>
<head>
    <script>
        function confirmDelete(event) {
            if (event.submitter && event.submitter.name === 'action' && event.submitter.value === '删除') {
                return confirm('⚠️ 确定要删除这个项目吗？此操作无法撤销。');
            }
            return true;
        }
    </script>

    <link rel="stylesheet" href="styles.css">
    <title>我的任务</title>
    <style>
        .form-inline {
            display: flex;
            gap: 10px; /* 控制 select 和 button 的间距 */
            align-items: center;
            margin-top: 10px;
        }

        .container {
            max-width: 960px;
            margin: 60px auto;
            background-color: #fff;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        h2 {
            color: #34495e;
            margin-bottom: 30px;
        }
        .message {
            color: #27ae60;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .project-box {
            border: 1px solid #ddd;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .project-title {
            font-weight: bold;
            font-size: 18px;
            margin-bottom: 10px;
        }
        select, input[type="submit"] {
            padding: 8px 12px;
            margin-top: 10px;
            border-radius: 6px;
            border: 1px solid #ccc;
        }
        input[type="submit"] {
            background-color: #3498db;
            color: #fff;
            cursor: pointer;
            border: none;
        }
        input[type="submit"]:hover {
            background-color: #2980b9;
        }
    </style>
</head>
<body>

<jsp:include page="navbar.jsp"/>

<div class="container">
    <h2>👤 我的任务</h2>
    <p class="message"><%= msg %></p>

    <%
        List<Project> ongoingProjects = new ArrayList<>();
        List<Project> completedProjects = new ArrayList<>();

        for (Project p : myProjects) {
            if ("部署完成".equals(p.getProgressStage())) {
                completedProjects.add(p);
            } else {
                ongoingProjects.add(p);
            }
        }
    %>


    <% if (ongoingProjects.isEmpty()) { %>
    <p>⚠️ 你目前没有进行中的项目。</p>
    <% } else { %>
    <h3>🚧 进行中的项目</h3>
    <% for (Project p : ongoingProjects) {
            if ("部署完成".equals(p.getProgressStage())) {
                continue;
            }
    %>
    <div class="project-box">
        <div class="project-title"><%= p.getName() %></div>
        <div><strong>内容：</strong><%= p.getContent() %></div>
        <div><strong>当前进度：</strong><%= p.getProgressStage() %></div>
        <% boolean isAdmin = "admin".equals(currentUser.getRole()); %>
        <form method="post" action="personal.jsp" onsubmit="return confirmDelete(event)">
            <input type="hidden" name="projectId" value="<%= p.getId() %>">
            <label>更新进度：</label>
            <div class="form-inline">
                <select name="newStage">
                    <option value="框架搭建" <%= "框架搭建".equals(p.getProgressStage()) ? "selected" : "" %>>框架搭建</option>
                    <option value="逻辑完成" <%= "逻辑完成".equals(p.getProgressStage()) ? "selected" : "" %>>逻辑完成</option>
                    <option value="细节美化" <%= "细节美化".equals(p.getProgressStage()) ? "selected" : "" %>>细节美化</option>
                    <option value="部署完成" <%= "部署完成".equals(p.getProgressStage()) ? "selected" : "" %>>部署完成</option>
                </select>
                <input type="submit" name="action" value="更新" style="width: 50%">
                <% if (isAdmin) { %>
                <input type="submit" name="action" value="删除" style="background-color:#dc2525;width: 50%">
                <% } %>
            </div>
        </form>
    </div>

    <% }} %>
    <% if (!completedProjects.isEmpty()) { %>
    <h3>✅ 已完成的项目</h3>
    <% for (Project p : completedProjects) { %>
    <div class="project-box" style="background-color: #f4f6f8;">
        <div class="project-title"><%= p.getName() %></div>
        <div><strong>内容：</strong><%= p.getContent() %></div>
        <div><strong>进度：</strong><%= p.getProgressStage() %></div>
    </div>
    <% } %>
    <% } %>
</div>

</body>
</html>
