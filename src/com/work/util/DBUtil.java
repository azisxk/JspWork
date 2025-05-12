package com.work.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    // 数据库连接信息
    private static final String URL = "jdbc:mysql://localhost:3306/department_system?useUnicode=true&characterEncoding=utf8&serverTimezone=UTC";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "123456";
    // 获取连接的方法
    public static Connection getConnection() throws SQLException {
        try {
            // 手动加载 JDBC 驱动
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("Loaded MySQL Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new SQLException("数据库驱动加载失败", e);
        }
        Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
        System.out.println("连接的数据库：" + conn.getCatalog());  // 新增这行
        System.out.println("DBUtil.getConnection 正在执行");
        return conn;
    }

    // 关闭连接的方法
    public static void close(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                System.out.println("关闭数据库连接失败：" + e.getMessage());
            }
        }
    }
}
