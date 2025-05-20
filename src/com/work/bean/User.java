package com.work.bean;

import java.util.ArrayList;
import java.util.List;

public class User {

    // 常量定义角色类型，避免硬编码字符串
    public static final String ROLE_USER = "user";
    public static final String ROLE_SUB_DEPARTMENT = "sub_department";
    public static final String ROLE_SUPER_DEPARTMENT = "super_department";
    public static final String ROLE_ADMIN = "admin";

    private int id;
    private String username;
    private String password;
    private String role;
    private String contactInfo; // 新增：联系方式（可选）

    private List<String> assignedProjects = new ArrayList<>();
    private String department;

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    // 无参构造
    public User() {}

    // 常用构造方法
    public User(String username, String password, String role) {
        this.username = username;
        this.password = password;
        this.role = role;
    }

    public User(int id, String username, String password, String role) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.role = role;
    }

    // Getters & Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getContactInfo() {
        return contactInfo;
    }

    public void setContactInfo(String contactInfo) {
        this.contactInfo = contactInfo;
    }

    // 项目管理相关方法
    public List<String> getAssignedProjects() {
        return assignedProjects;
    }

    public void setAssignedProjects(List<String> assignedProjects) {
        this.assignedProjects = assignedProjects;
    }

    public void addProject(String projectName) {
        if (!assignedProjects.contains(projectName)) {
            assignedProjects.add(projectName);
        }
    }

    public void removeProject(String projectName) {
        assignedProjects.remove(projectName);
    }
}
