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
    String[] stages = {"搭建框架", "逻辑完成", "细节美化", "部署完成"};
    Map<String, Integer> stageIndexMap = new HashMap<>();
    for (int i = 0; i < stages.length; i++) {
        stageIndexMap.put(stages[i], i);
    }
%>
<html>
<head>
    <title>项目列表</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
    <style>
        .project-table {
            width: 95%;
            margin: 40px auto;
            border-collapse: collapse;
            background-color: #fff;
            box-shadow: 0 0 8px rgba(0,0,0,0.1);
        }
        .project-table th, .project-table td {
            padding: 12px;
            border: 1px solid #ddd;
            text-align: left;
        }
        .project-table th {
            background-color: #f2f2f2;
        }
        .progress-bar {
            background-color: #e9ecef;
            border-radius: 4px;
            overflow: hidden;
            height: 20px;
        }
        .progress-fill {
            background-color: #007BFF;
            height: 100%;
        }
    </style>
</head>
<body>
<jsp:include page="navbar.jsp" />
<h2 style="text-align:center; margin-top: 30px;">项目列表</h2>
<table class="project-table">
    <tr>
        <th style="width: 12%">项目名称</th>
        <th>内容</th>
        <th style="width: 15%">参与成员</th>
        <th style="width: 18%">进度</th>
        <th style="width: 28%">已完成阶段</th>
    </tr>
    <%
        for (Project p : projects) {
            if ("user".equals(currentRole)) {
                if (!p.getAssignedMembers().contains(currentUser)) {
                    continue; // 普通用户只能看自己的任务
                }
            }

            int progressIndex = stageIndexMap.getOrDefault(p.getProgressStage(), 0);
            int percent = (int) (((progressIndex + 1) / 4.0) * 100);
    %>
    <tr>
        <td><%= p.getName() %></td>
        <td><%= p.getContent() %></td>
        <td>
            <%
                List<String> members = p.getAssignedMembers();
                for (int i = 0; i < members.size(); i++) {
                    out.print(members.get(i));
                    if (i < members.size() - 1) out.print("，");
                }
            %>
        </td>
        <td>
            <div class="progress-bar">
                <div class="progress-fill" style="width: <%= percent %>%"></div>
            </div>
        </td>
        <td>
            <%
                for (int i = 0; i <= progressIndex && i < stages.length; i++) {
                    out.print(stages[i]);
                    if (i < progressIndex) out.print("，");
                }
            %>
        </td>
    </tr>
    <% } %>
</table>
</body>
</html>
