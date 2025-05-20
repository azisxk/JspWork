<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*, com.work.bean.*, com.work.dao.ProjectDAO, java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String currentUser = (String) session.getAttribute("userName");
    String currentRole = (String) session.getAttribute("role");
    List<Project> projects = new ArrayList<>();
    try {
        Connection conn = com.work.util.DBUtil.getConnection();
        ProjectDAO dao = new ProjectDAO(conn);
        projects = dao.getAllProjects();
    } catch (Exception e) {
        e.printStackTrace();
    }

    // 定义进度阶段顺序
    String[] stages = {"框架搭建", "逻辑完成", "细节美化", "部署完成"};
    Map<String, Integer> stageIndexMap = new HashMap<>();
    for (int i = 0; i < stages.length; i++) {
        stageIndexMap.put(stages[i], i);
    }
%>
<fmt:formatDate value="${p.getStartdate()}" pattern="yyyy-MM-dd"/>
<html>
<head>

    <title>项目列表</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
    <style>
        .project-container {
            width: 95%;
            margin: 40px auto;
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(330px, 1fr));
            gap: 20px;
        }

        .project-card {
            background-color: #ffffff;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .project-title {
            font-size: 18px;
            font-weight: bold;
            color: #333;
        }

        .status {
            font-size: 14px;
            padding: 4px 10px;
            border-radius: 12px;
        }

        .status.done {
            background-color: #d4edda;
            color: #155724;
        }

        .status.ongoing {
            background-color: #fff3cd;
            color: #856404;
        }

        .card-content {
            font-size: 14px;
            color: #555;
            line-height: 1.6;
        }

        .members, .dates, .creator {
            font-size: 13px;
            color: #666;
        }

        .progress-container {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .progress-bar {
            width: 100%;
            height: 10px;
            background-color: #e9ecef;
            border-radius: 6px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            background-color: #007BFF;
        }

    </style>
</head>
<body>
<%
    List<Project> unfinishedProjects = new ArrayList<>();
    List<Project> finishedProjects = new ArrayList<>();
    for (Project p : projects) {
        if ("user".equals(currentRole) && !p.getAssignedMembers().contains(currentUser)) {
            continue; // 普通用户只能看自己的任务
        }

        if ("部署完成".equals(p.getProgressStage())) {
            finishedProjects.add(p);
        } else {
            unfinishedProjects.add(p);
        }
    }
%>

<jsp:include page="navbar.jsp" />
<h2 style="text-align:center; margin-top: 30px;">未完成项目</h2>
<div class="project-container">
    <%
        for (Project p : unfinishedProjects) {
            int progressIndex = stageIndexMap.getOrDefault(p.getProgressStage(), 0);
            int percent = (int) (((progressIndex + 1) / 4.0) * 100);
    %>
    <div class="project-card">
        <div class="card-header">
            <span class="project-title"><%= p.getName() %></span>
            <span class="status ongoing">⏳ 进行中</span>
        </div>
        <div class="card-content"><%= p.getContent() %></div>
        <div class="members">👥
            <%= String.join("，", p.getAssignedMembers()) %>
        </div>
        <div class="progress-container">
            <div class="progress-bar">
                <div class="progress-fill" style="width: <%= percent %>%"></div>
            </div>
            <div class="stage-text">
                已完成：<%= String.join("，", Arrays.copyOfRange(stages, 0, progressIndex + 1)) %>
            </div>
        </div>
        <div class="dates">🕒 <%= p.getStartdate() %> → <%= p.getEnddate() %></div>
        <div class="creator">创建人：<%= p.getCreator() %></div>
    </div>
    <% } %>
</div>

<h2 style="text-align:center; margin-top: 50px;">已完成项目</h2>
<div class="project-container">
    <%
        for (Project p : finishedProjects) {
            int progressIndex = stageIndexMap.getOrDefault(p.getProgressStage(), 0);
    %>
    <div class="project-card">
        <div class="card-header">
            <span class="project-title"><%= p.getName() %></span>
            <span class="status done">✅ 已完成</span>
        </div>
        <div class="card-content"><%= p.getContent() %></div>
        <div class="members">👥
            <%= String.join("，", p.getAssignedMembers()) %>
        </div>
        <div class="progress-container">
            <div class="progress-bar">
                <div class="progress-fill" style="width: 100%"></div>
            </div>
            <div class="stage-text">已完成全部阶段</div>
        </div>
        <div class="dates">🕒 <%= p.getStartdate() %> → <%= p.getEnddate() %></div>
        <div class="creator">创建人：<%= p.getCreator() %></div>
    </div>
    <% } %>
</div>

</body>
</html>
