package com.work.dao;

import com.work.bean.Project;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProjectDAO {
    private Connection conn;

    public ProjectDAO(Connection conn) {
        this.conn = conn;
    }

    // 添加项目（含成员）
    public boolean addProject(Project project) throws SQLException {
        String sql = "INSERT INTO projects (name, content, progress_stage) VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, project.getName());
            ps.setString(2, project.getContent());
            ps.setString(3, project.getProgressStage());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                ResultSet generatedKeys = ps.getGeneratedKeys();
                if (generatedKeys.next()) {
                    int projectId = generatedKeys.getInt(1);
                    project.setId(projectId);
                    insertProjectMembers(projectId, project.getAssignedMembers());
                }
                return true;
            }
            return false;
        }
    }

    // 删除项目（project_members 表使用 ON DELETE CASCADE 时不需要手动删成员）
    public boolean deleteProject(int id) throws SQLException {
        String sql = "DELETE FROM projects WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
    public boolean projectExistsByName(String name) throws SQLException {
        String sql = "SELECT COUNT(*) FROM projects WHERE name = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    // 更新项目及其成员
    public boolean updateProject(Project project) throws SQLException {
        String sql = "UPDATE projects SET name = ?, content = ?, progress_stage = ? WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, project.getName());
            ps.setString(2, project.getContent());
            ps.setString(3, project.getProgressStage());
            ps.setInt(4, project.getId());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                deleteProjectMembers(project.getId());
                insertProjectMembers(project.getId(), project.getAssignedMembers());
            }
            return affected > 0;
        }
    }

    // 获取某个项目
    public Project getProjectById(int id) throws SQLException {
        Project project = null;
        String sql = "SELECT * FROM projects WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    project = new Project();
                    project.setId(rs.getInt("id"));
                    project.setName(rs.getString("name"));
                    project.setContent(rs.getString("content"));
                    project.setProgressStage(rs.getString("progress_stage"));
                }
            }
        }
        return project;
    }
    private Project extractProjectFromResultSet(ResultSet rs) throws SQLException {
        Project p = new Project();
        int projectId = rs.getInt("id");
        p.setId(projectId);
        p.setName(rs.getString("name"));
        p.setContent(rs.getString("content"));
        p.setProgressStage(rs.getString("progress_stage"));

        // 这里调用已有方法，从中间表查出成员用户名列表
        List<String> members = getMembersByProjectId(projectId);
        p.setAssignedMembers(members);

        return p;
    }


    // 根据用户名获取其参与的所有项目
    public List<Project> getProjectsByUser(String username) throws SQLException {
        List<Project> list = new ArrayList<>();
        String sql = "SELECT * FROM projects";
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Project p = extractProjectFromResultSet(rs);
                if (p.getAssignedMembers().contains(username)) {
                    list.add(p);
                }
            }
        }
        return list;
    }

    // 更新项目的进度（注意权限校验在 JSP 层完成）
    public boolean updateProjectStage(int id, String stage) throws SQLException {
        String sql = "UPDATE projects SET progress_stage=? WHERE id=?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, stage);
            stmt.setInt(2, id);
            return stmt.executeUpdate() > 0;
        }
    }

    // 获取所有项目及其成员
    public List<Project> getAllProjects() throws SQLException {
        List<Project> projects = new ArrayList<>();
        String sql = "SELECT * FROM projects";
        try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Project p = new Project(
                        rs.getString("name"),
                        rs.getString("content"),
                        rs.getString("progress_stage"),
                        rs.getInt("id")
                );
                p.setAssignedMembers(getMembersByProjectId(p.getId()));
                projects.add(p);
            }
        }
        return projects;
    }

    // 插入项目成员
    private void insertProjectMembers(int projectId, List<String> members) throws SQLException {
        if (members == null || members.isEmpty()) return;

        String findUserIdSql = "SELECT id FROM users WHERE username = ?";
        String insertSql = "INSERT INTO project_members (project_id, user_id) VALUES (?, ?)";

        try (PreparedStatement findPs = conn.prepareStatement(findUserIdSql);
             PreparedStatement insertPs = conn.prepareStatement(insertSql)) {

            for (String username : members) {
                findPs.setString(1, username);
                ResultSet rs = findPs.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    insertPs.setInt(1, projectId);
                    insertPs.setInt(2, userId);
                    insertPs.addBatch();
                }
            }
            insertPs.executeBatch();
        }
    }


    // 删除项目成员
    private void deleteProjectMembers(int projectId) throws SQLException {
        String sql = "DELETE FROM project_members WHERE project_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            ps.executeUpdate();
        }
    }

    // 获取指定项目的所有成员
    private List<String> getMembersByProjectId(int projectId) throws SQLException {
        List<String> members = new ArrayList<>();
        String sql = "SELECT u.username FROM users u " +
                "JOIN project_members pm ON u.id = pm.user_id " +
                "WHERE pm.project_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                members.add(rs.getString("username"));
            }
        }
        return members;
    }

}
