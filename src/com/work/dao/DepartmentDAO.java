package com.work.dao;

import com.work.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class DepartmentDAO {
    public static List<String> getAllSubDepartments() {
        List<String> departments = new ArrayList<>();
        String sql = "SELECT DISTINCT department FROM users WHERE role = 'sub_department' AND department IS NOT NULL AND department != ''";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                departments.add(rs.getString("department"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return departments;
    }

}
