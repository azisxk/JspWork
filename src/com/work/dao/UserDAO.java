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
        String sql = "INSERT INTO users (username, password, role) VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getRole());
            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("添加用户失败，未影响任何行。");
            }

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1); // 返回生成的 id
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
                return new User(rs.getInt("id"), rs.getString("username"), rs.getString("password"), rs.getString("role"));
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

    public List<User> getAllUsers() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users";
        try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                System.out.println("Found user: " + rs.getString("username")); // ✅ 检查是否真的查到了用户
                users.add(new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("password"),
                        rs.getString("role")
                ));
            }
        }
        return users;
    }

    public static boolean isAdmin(String username) {
        // 此方法根据数据库中用户角色进行判断
        String query = "SELECT role FROM users WHERE username = ?";
        try (Connection connection = getConnection();
             PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                System.out.println("is Admin");
                return "admin".equals(rs.getString("role"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
