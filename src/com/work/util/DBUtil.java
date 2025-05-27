package com.work.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;

public class DBUtil {
    private static final String URL = "jdbc:mysql://127.0.0.1:3306/department_system?useUnicode=true&characterEncoding=utf8&serverTimezone=UTC";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "123456";

    // 获取数据库连接
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("Loaded MySQL Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new SQLException("数据库驱动加载失败", e);
        }
        Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
        System.out.println("连接的数据库：" + conn.getCatalog());
        System.out.println("DBUtil.getConnection 正在执行");
        return conn;
    }

    // 关闭 Connection
    public static void close(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                System.out.println("关闭数据库连接失败：" + e.getMessage());
            }
        }
    }

    // 关闭 Statement
    public static void close(Statement stmt) {
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                System.out.println("关闭 Statement 失败：" + e.getMessage());
            }
        }
    }

    // 关闭 ResultSet
    public static void close(ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                System.out.println("关闭 ResultSet 失败：" + e.getMessage());
            }
        }
    }

    // 统一关闭多个资源（重载）
    public static void close(ResultSet rs, Statement stmt, Connection conn) {
        close(rs);
        close(stmt);
        close(conn);
    }
}
