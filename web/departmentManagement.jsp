<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*, java.sql.*, com.work.util.DBUtil, com.work.dao.DepartmentDAO" %>
<%@ page session="true" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("super_department")) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<String> subDepartments = DepartmentDAO.getAllSubDepartments();

    // 处理表单提交
    String message = null;
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String content = request.getParameter("content");
        String startDate = request.getParameter("start_date");
        String endDate = request.getParameter("end_date");
        String progressStage = request.getParameter("progress_stage");
        String creator = (String) session.getAttribute("userName");
        String[] departments = request.getParameterValues("departments");

        if (departments == null || departments.length == 0) {
            message = "必须选择至少一个下级部门！";
        } else if (name == null || name.trim().isEmpty()) {
            message = "项目名称不能为空！";
        } else if (endDate == null || endDate.trim().isEmpty()) {
            message = "截止日期不能为空！";
        } else {
            Connection conn = null;
            PreparedStatement psProject = null;
            PreparedStatement psDept = null;
            ResultSet rs = null;
            try {
                conn = DBUtil.getConnection();
                conn.setAutoCommit(false);

                // 插入项目
                String insertProjectSql = "INSERT INTO projects (name, content, start_date, end_date, progress_stage, creator) VALUES (?, ?, ?, ?, ?, ?)";
                psProject = conn.prepareStatement(insertProjectSql, Statement.RETURN_GENERATED_KEYS);
                psProject.setString(1, name);
                psProject.setString(2, content);
                psProject.setString(3, startDate);
                psProject.setString(4, endDate);
                psProject.setString(5, progressStage);
                psProject.setString(6, creator);
                psProject.executeUpdate();

                rs = psProject.getGeneratedKeys();
                int projectId = -1;
                if (rs.next()) {
                    projectId = rs.getInt(1);
                }

                // 插入项目-部门关联
                String insertDeptSql = "INSERT INTO project_departments (project_id, department_name) VALUES (?, ?)";

                psDept = conn.prepareStatement(insertDeptSql);
                for (String dept : departments) {
                    psDept.setInt(1, projectId);
                    psDept.setString(2, dept);
                    psDept.addBatch();
                }
                psDept.executeBatch();

                conn.commit();
                message = "项目发布成功！";

            } catch (Exception e) {
                if (conn != null) {
                    try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
                }
                message = "任务发布失败：" + e.getMessage();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                if (psDept != null) try { psDept.close(); } catch (SQLException ignored) {}
                if (psProject != null) try { psProject.close(); } catch (SQLException ignored) {}
                if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
            }
        }
    }
%>
<html>
<head>
    <title>部门项目管理 - 上级部门任务发布</title>
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
        label {
            font-weight: 600;
            display: block;
            margin-top: 15px;
            margin-bottom: 6px;
        }
        input[type="text"], textarea, select, input[type="date"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 14px;
            box-sizing: border-box;
        }
        input[type="submit"] {
            background-color: #3498db;
            color: #fff;
            border: none;
            padding: 12px 20px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 25px;
            width: 100%;
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
        .dept-checkboxes {
            max-height: 200px;
            overflow-y: auto;
            border: 1px solid #ddd;
            padding: 12px;
            border-radius: 6px;
            background-color: #fafafa;
        }
        .dept-checkboxes label {
            font-weight: normal;
            display: block;
            margin-bottom: 8px;
        }
    </style>
</head>
<body>
<jsp:include page="navbar.jsp"/>

<div class="container">
    <h2>📌 上级部门任务发布</h2>

    <% if (message != null) { %>
    <p style="color: <%= message.contains("成功") ? "green" : "red" %>;"><%= message %></p>
    <% } %>

    <form method="post" onsubmit="return validateForm()">
        <label for="name">项目名称</label>
        <input type="text" id="name" name="name" required>

        <label for="content">项目内容</label>
        <textarea id="content" name="content" rows="4" required></textarea>

        <label for="start_date">起始日期</label>
        <input type="date" id="start_date" name="start_date" required min="<%= java.time.LocalDate.now() %>">

        <label for="end_date">截止日期</label>
        <input type="date" id="end_date" name="end_date" required min="<%= java.time.LocalDate.now().plusDays(1) %>">

        <label for="progress_stage">项目阶段</label>
        <select id="progress_stage" name="progress_stage">
            <option value="框架搭建">框架搭建</option>
            <option value="逻辑完成">逻辑完成</option>
            <option value="细节美化">细节美化</option>
            <option value="部署完成">部署完成</option>
        </select>

        <label>负责下级部门</label>
        <div class="dept-checkboxes" style="max-height:200px; overflow-y:auto; border:1px solid #ddd; padding:12px; background:#fafafa;">
            <% for (String dept : subDepartments) { %>
            <label>
                <input type="checkbox" name="departments" value="<%= dept %>"> <%= dept %>
            </label>
            <% } %>
        </div>

        <input type="submit" value="发布任务">
    </form>
</div>

<script>
    function validateForm() {
        const depts = document.querySelectorAll('input[name="departments"]:checked');
        if (depts.length === 0) {
            alert("❌ 请至少选择一个负责下级部门！");
            return false;
        }
        const startDate = document.getElementById('start_date').value;
        const endDate = document.getElementById('end_date').value;
        if (!startDate || !endDate) {
            alert("❌ 请填写完整日期！");
            return false;
        }
        if (startDate > endDate) {
            alert("❌ 起始日期不能晚于截止日期！");
            return false;
        }
        return true;
    }
</script>
</body>
</html>
