package com.work.test;

import com.work.bean.User;
import com.work.dao.UserDAO;
import com.work.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;

public class TestUserInserter {

    public static void main(String[] args) {
        // 通过 DBUtil 获取数据库连接
        try (Connection conn = DBUtil.getConnection()) {
            // 创建 UserDAO 实例
            UserDAO userDAO = new UserDAO(conn);

            // 创建一个测试用户
            User testUser = new User("AzisKer", "123456", "admin");

            // 插入用户并返回生成的 ID
            int generatedId = userDAO.addUserAndReturnId(testUser);

            // 输出结果
            if (generatedId > 0) {
                System.out.println("测试用户插入成功，生成的 ID 是：" + generatedId);
            } else {
                System.out.println("插入测试用户失败");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("数据库连接或插入操作失败！");
        }
    }
}
