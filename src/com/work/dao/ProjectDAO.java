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
        String sql = "INSERT INTO projects (name, content, progress_stage, start_date, end_date, creator) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, project.getName());
            ps.setString(2, project.getContent());
            ps.setString(3, project.getProgressStage());
            ps.setDate(4, project.getStartdate());
            ps.setDate(5, project.getEnddate());
            ps.setString(6, project.getCreator());

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

    // 删除项目
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
    public boolean updateProject(Project p) throws SQLException {
        // 更新项目表基本信息
        String sqlUpdateProject = "UPDATE projects SET name=?, content=?, progress_stage=?, end_date=? WHERE id=?";
        try (PreparedStatement ps = conn.prepareStatement(sqlUpdateProject)) {
            ps.setString(1, p.getName());
            ps.setString(2, p.getContent());
            ps.setString(3, p.getProgressStage());
            ps.setDate(4, p.getEndDate());
            ps.setInt(5, p.getId());
            ps.executeUpdate();
        }

        // 删除旧成员关系
        String sqlDeleteMembers = "DELETE FROM project_members WHERE project_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sqlDeleteMembers)) {
            ps.setInt(1, p.getId());
            ps.executeUpdate();
        }

        // 插入新成员关系
        String sqlInsertMember = "INSERT INTO project_members(project_id, user_id) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sqlInsertMember)) {
            UserDAO userDAO = new UserDAO(conn); // 假设你已有这个 DAO 类
            for (String username : p.getAssignedMembers()) {
                int userId = userDAO.getUserIdByUsername(username);
                ps.setInt(1, p.getId());
                ps.setInt(2, userId);
                ps.addBatch();
            }
            ps.executeBatch();
        }

        return true;
    }


    // 获取某个项目
    public Project getProjectById(int id) throws SQLException {
        Project project = null;
        String sql = "SELECT * FROM projects WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    project = extractProjectFromResultSet(rs);
                }
            }
        }
        return project;
    }
    public void clearProjectMembers(int projectId) throws SQLException {
        String sql = "DELETE FROM project_members WHERE project_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, projectId);
            stmt.executeUpdate();
        }
    }
    public void addProjectMember(int projectId, int userId) throws SQLException {
        String sql = "INSERT INTO project_members (project_id, user_id) VALUES (?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, projectId);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
        }
    }
    public int countUnfinishedProjectsByUser(String username) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT p.id) " +
                "FROM projects p " +
                "LEFT JOIN project_members pm ON p.id = pm.project_id " +
                "LEFT JOIN users u ON pm.user_id = u.id " +
                "WHERE (u.username = ?) " +
                "AND p.progress_stage <> '部署完成'";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }




    public List<Project> getProjectsCreatedBy(String username) throws SQLException {
        List<Project> list = new ArrayList<>();
        String sql = "SELECT * FROM projects WHERE creator = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Project p = extractProjectFromResultSet(rs);
                list.add(p);
            }
        }
        return list;
    }

    // 提取项目对象
    private Project extractProjectFromResultSet(ResultSet rs) throws SQLException {
        Project p = new Project();
        int projectId = rs.getInt("id");
        p.setId(projectId);
        p.setName(rs.getString("name"));
        p.setContent(rs.getString("content"));
        p.setProgressStage(rs.getString("progress_stage"));
        p.setStartDate(rs.getDate("start_date"));
        p.setEndDate(rs.getDate("end_date"));
        p.setCreator(rs.getString("creator"));
//        p.setAssignedDepartment(rs.getString("assigned_department"));
//        p.setAssignedContactInfo(rs.getString("assigned_contact_info"));

        // 获取成员用户名
        List<String> members = getMembersByProjectId(projectId);
        p.setAssignedMembers(members);

        return p;
    }
    public List<Project> getProjectsByDepartment(String departmentName) throws SQLException {
        List<Project> list = new ArrayList<>();
        String sql = "SELECT p.id, p.name, p.content, p.progress_stage, p.end_date " +
                "FROM projects p " +
                "JOIN project_departments pd ON p.id = pd.project_id " +
                "WHERE pd.department_name = ? " +
                "GROUP BY p.id";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, departmentName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Project p = new Project();
                    p.setId(rs.getInt("id"));
                    p.setName(rs.getString("name"));
                    p.setContent(rs.getString("content"));
                    p.setProgressStage(rs.getString("progress_stage"));
                    p.setEndDate(rs.getDate("end_date"));

                    List<String> members = getProjectMembers(p.getId());
                    p.setAssignedMembers(members);

                    list.add(p);
                }
            }
        }
        return list;
    }


    // 辅助方法，获取某项目的参与成员用户名列表
    private List<String> getProjectMembers(int projectId) throws SQLException {
        List<String> members = new ArrayList<>();
        String sql = "SELECT u.username FROM users u " +
                "JOIN project_members pm ON u.id = pm.user_id " +
                "WHERE pm.project_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    members.add(rs.getString("username"));
                }
            }
        }
        return members;
    }

    // 获取所有项目
    public List<Project> getAllProjects() throws SQLException {
        List<Project> projects = new ArrayList<>();
        String sql = "SELECT * FROM projects";
        try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Project p = extractProjectFromResultSet(rs);
                projects.add(p);
            }
        }
        return projects;
    }

    // 获取某用户参与的项目
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

    // 更新项目进度
    public boolean updateProjectStage(int id, String stage) throws SQLException {
        String sql = "UPDATE projects SET progress_stage=? WHERE id=?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, stage);
            stmt.setInt(2, id);
            return stmt.executeUpdate() > 0;
        }
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

    // 获取项目成员用户名
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
