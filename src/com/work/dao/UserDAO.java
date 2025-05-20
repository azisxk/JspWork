package com.work.dao;

import com.work.bean.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import static com.work.util.DBUtil.getConnection;

public class UserDAO {
    private Connection conn;

    public UserDAO(Connection conn) {
        this.conn = conn;
    }

    public int addUserAndReturnId(User user) throws SQLException {
        String sql = "INSERT INTO users (username, password, role, contact_info,department) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getRole());
            ps.setString(4, user.getContactInfo());  // 新增：联系方式
            ps.setString(5, user.getDepartment());
            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("添加用户失败，未影响任何行。");
            }

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("添加用户失败，未获得生成的 ID。");
                }
            }
        }
    }

    public boolean userExists(String username) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    public boolean removeUser(String username) throws SQLException {
        String sql = "DELETE FROM users WHERE username = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            return ps.executeUpdate() > 0;
        }
    }

    public User getUser(String username) throws SQLException {
        String sql = "SELECT * FROM users WHERE username = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User user = new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("password"),
                        rs.getString("role")
                );
                user.setContactInfo(rs.getString("contact_info")); // 设置 contact_info
                user.setDepartment(rs.getString("department"));
                return user;
            }
        }
        return null;
    }

    public boolean updateRole(String username, String newRole) throws SQLException {
        String sql = "UPDATE users SET role = ? WHERE username = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newRole);
            ps.setString(2, username);
            return ps.executeUpdate() > 0;
        }
    }

    // 新增：更新联系方式
    public void updateContactInfo(String username, String contactInfo) throws SQLException {
        String sql = "UPDATE users SET contact_info = ? WHERE username = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, contactInfo);
            stmt.setString(2, username);
            stmt.executeUpdate();
        }
    }
    public void updateRoleAndContact(String username, String role, String contactInfo) throws SQLException {
        String sql = "UPDATE users SET role = ?, contact_info = ? WHERE username = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, role);
            stmt.setString(2, contactInfo);
            stmt.setString(3, username);
            stmt.executeUpdate();
        }
    }
    public boolean updateRoleContactAndDepartment(String username, String role, String contactInfo, String department) throws SQLException {
        String sql = "UPDATE users SET role = ?, contact_info = ?, department = ? WHERE username = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            ps.setString(2, contactInfo);
            ps.setString(3, department);
            ps.setString(4, username);
            int rows = ps.executeUpdate();
            return rows > 0;
        }
    }

    public List<User> getUsersByDepartment(String departmentName) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE department = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, departmentName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setUsername(rs.getString("username"));
                    u.setDepartment(rs.getString("department")); // 一定要从数据库读取部门字段，确认没写错
                    u.setContactInfo(rs.getString("contact_info"));
                    users.add(u);
                }
            }
        }
        return users;
    }

    public int getUserIdByUsername(String username) throws SQLException {
        String sql = "SELECT id FROM users WHERE username = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                } else {
                    throw new SQLException("未找到用户名: " + username);
                }
            }
        }
    }

    public List<User> getAllUsers() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users";
        try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                User user = new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("password"),
                        rs.getString("role")
                );
                user.setContactInfo(rs.getString("contact_info")); // 加入 contact_info
                user.setDepartment(rs.getString("department"));
                users.add(user);
            }
        }
        return users;
    }
    public void updateDepartment(String username, String department) throws SQLException {
        String sql = "UPDATE users SET department = ? WHERE username = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, department);
            stmt.setString(2, username);
            stmt.executeUpdate();
        }
    }
    public void updateUserDetails(String username, String role, String contact, String department) throws SQLException {
        String sql = "UPDATE users SET role = ?, contact_info = ?, department = ? WHERE username = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, role);
            stmt.setString(2, contact);
            stmt.setString(3, department);
            stmt.setString(4, username);
            stmt.executeUpdate();
        }
    }

    public static boolean isAdmin(String username) {
        String query = "SELECT role FROM users WHERE username = ?";
        try (Connection connection = getConnection();
             PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return "admin".equals(rs.getString("role"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }


}
