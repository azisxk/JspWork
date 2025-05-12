package com.work.bean;

import java.util.ArrayList;
import java.util.List;

public class User {
    private String username;
    private String password;
    private String role;
    private int id;
    private List<String> assignedProjects = new ArrayList<>();
    public User(){
    }
    public User(String username,String password,String role){
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
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public void setRole(String role) {
        this.role = role;
    }public List<String> getAssignedProjects() {
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
