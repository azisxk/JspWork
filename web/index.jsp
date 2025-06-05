<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*, com.work.bean.*, com.work.dao.ProjectDAO, java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String msg = request.getParameter("msg") != null ? request.getParameter("msg") : "";
    String sortField = request.getParameter("sort") != null ? request.getParameter("sort") : "name";
    String sortOrder = request.getParameter("order") != null ? request.getParameter("order") : "asc";

    List<Project> projects = new ArrayList<>();
    try {
        Connection conn = com.work.util.DBUtil.getConnection();
        ProjectDAO projectDAO = new ProjectDAO(conn);
        projects = projectDAO.getAllProjects();
        // 假设ProjectDAO有一个方法可以根据字段和顺序排序
        // projects = projectDAO.getAllProjectsSortedBy(sortField, sortOrder);
    } catch (SQLException e) {
        e.printStackTrace();
        msg = "加载项目失败：" + e.getMessage();
    }
    Collections.sort(projects, new Comparator<Project>() {
        @Override
        public int compare(Project p1, Project p2) {
            if ("name".equals(sortField)) {
                return sortOrder.equals("asc") ? p1.getName().compareTo(p2.getName()) : p2.getName().compareTo(p1.getName());
            } else if ("progress".equals(sortField)) {
                return sortOrder.equals("asc") ? p1.getProgressStage().compareTo(p2.getProgressStage()) : p2.getProgressStage().compareTo(p1.getProgressStage());
            }
            return 0;
        }
    });
%>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>首页</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        /* 样式保持不变 */
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }

        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }

        th {
            background-color: #495057;
            color: white;
        }

        tr:nth-child(even) {
            background-color: #f2f2f2;
        }

        tr:nth-child(odd) {
            background-color: #ffffff;
        }
        .text-over-image {
            position: relative;
            height: 680px; /* 容器高度占视口的100% */
            overflow: hidden;
            width: 100%;
            max-width: 1100px;
            margin: 20px auto;
            border-radius: 12px;
        }

        .text-over-image img {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: auto;
            transform: translateZ(0); /* 启用硬件加速 */
            will-change: transform; /* 提示浏览器优化性能 */
            border-radius: 12px;
        }

        .text-over-image .text {
            position: absolute;
            color: white;
            top: 0;        /* 覆盖整个图片区域 */
            left: 0;
            right: 0;
            bottom: 0;
            padding: 20px;
            background: transparent; /* 透明背景 */
            opacity: 0;                     /* 默认隐藏 */
            transition: opacity 0.5s ease;  /* 过渡效果 */
            border-radius: 12px;
        }
        .text-over-image:hover .text {
            opacity: 1;
        }
        .text-over-image .text ul {
            transform: translateY(20px);    /* 初始位置下移 */
            transition: transform 0.5s ease;
        }

        .text-over-image:hover .text ul {
            transform: translateY(0);       /* 悬停时回到原位 */
        }

        .text-over-image h2 {
            margin-top: 0;
            color: white;
        }

        body {
            position: relative;
            min-height: 100vh;
            margin: 0;
            padding: 0;
        }

        body::before {
            content: "";
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-image: url("img/hero.jpg");
            background-size: cover;
            background-position: center;
            filter: blur(20px);
            z-index: -1; /* 确保在内容之下 */
        }


    </style>
</head>
<body>


<div class="text-over-image">
    <img src="img/hero.jpg" alt="公告图片">

    <div class="text">
        <h2>部门信息交互系统</h2>
        <ul>
            <li>上级部门可以新建项目，发布项目要求，并对下级部门的任务要求进行分配，一个项目可以发布为多个部门同时负责</li>
            <li>下级部门接收任务，对该任务进行人员指派，可以指派一人或多人来负责该项目，由该部门来进行细则分配任务到个人用户</li>
            <li>项目进度由部门级用户进行提交，系统根据完成度，反馈给上级部门</li>
        </ul>
    </div>
</div>
    <div class="container">
        <jsp:include page="navbar.jsp"/>
    <h2>项目列表</h2>
    <p class="message"><%= msg %></p>
    <div style="display: flex; align-items: center; gap: 120px;">
        <div style="white-space: nowrap;">
            <label for="sortField">排序字段:</label>
            <select id="sortField" onchange="location.href='?sort='+this.value+'&order=asc'">
                <option value="name" <%= sortField.equals("name") ? "selected" : "" %>>项目名称</option>
                <option value="progress" <%= sortField.equals("progress") ? "selected" : "" %>>进度</option>
            </select>
        </div>

        <div style="white-space: nowrap;">
            <label for="sortOrder">排序顺序:</label>
            <select id="sortOrder" onchange="location.href='?sort=<%= sortField %>&order='+this.value">
                <option value="asc" <%= sortOrder.equals("asc") ? "selected" : "" %>>升序</option>
                <option value="desc" <%= sortOrder.equals("desc") ? "selected" : "" %>>降序</option>
            </select>
        </div>
    </div>


    <!-- 项目展示 -->
    <h3>所有项目</h3>
    <% if (projects != null && !projects.isEmpty()) { %>
    <table style="width: 100%; border-collapse: collapse; margin-bottom: 20px;">
        <thead>
        <tr style="background-color: #34495e; color: #000;">
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
                <a href="taskManagement.jsp?action=edit&projectId=<%= p.getId() %>" style="color: #3498db; text-decoration: none;">编辑</a> |
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

<div class="container">
    <h2 style="text-align: center">我们的优势</h2>
    <h5 style="text-align: center; color: rgba(128, 128, 128, 0.5);">our advantages</h5>
    <section class="advantages">
        <div class="advantage">
            <div class="icon"><i class="fas fa-server"></i></div>
            <h3>分工明确</h3>
            <p class="advantage-content">上下级分工，减少重复工作</p>
        </div>
        <div class="advantage">
            <div class="icon"><i class="fas fa-dollar-sign"></i></div>
            <h3>节省成本</h3>
            <p class="advantage-content">节省人力维护和时间成本</p>
        </div>
        <div class="advantage">
            <div class="icon"><i class="fas fa-shield-alt"></i></div>
            <h3>安全可靠</h3>
            <p class="advantage-content">保障用户信息安全</p>
        </div>

        <div class="advantage">
            <div class="icon"><i class="fas fa-clock"></i></div>
            <h3>快速响应</h3>
            <p class="advantage-content">项目进度实时显示</p>
        </div>
    </section>
</div>
</body>
<script>
    window.addEventListener('scroll', function() {
        const scrolled = window.pageYOffset;
        const img = document.querySelector('.text-over-image img');
        const speed = 0.1; // 速度系数，值越小视差越明显
        if (img) {
            img.style.transform = `translateY(${scrolled * speed}px)`;
        }
    });
</script>
</html>
