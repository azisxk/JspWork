package com.work.bean;

import java.util.ArrayList;
import java.sql.Date;
import java.util.List;

public class Project {
    private Date startDate;
    private Date endDate;
    private String name;
    private String content;
    private String creator;
    private int id;
    private String assignedDepartment;     // 指定的负责人部门名（或用户名）
    private String assignedContactInfo;    // 对应部门负责人联系方式

    private String progressStage;
    private List<String> assignedMembers = new ArrayList<>();
    private List<Integer> assignedMemberIds = new ArrayList<>();
    public List<Integer> getAssignedMemberIds() {
        return assignedMemberIds;
    }
    public void setStartDate(Date startdate) { this.startDate = startdate; }
    public Date getStartdate() { return startDate; }
    public void setEndDate(Date enddate) { this.endDate = enddate; }
    public Date getEnddate() { return endDate; }
    public void setAssignedMemberIds(List<Integer> ids) {
        this.assignedMemberIds = ids;
    }
    public void addAssignedMemberId(int id) {
        this.assignedMemberIds.add(id);
    }

    public String getAssignedDepartment() {
        return assignedDepartment;
    }

    public void setAssignedDepartment(String assignedDepartment) {
        this.assignedDepartment = assignedDepartment;
    }

    public String getAssignedContactInfo() {
        return assignedContactInfo;
    }

    public void setAssignedContactInfo(String assignedContactInfo) {
        this.assignedContactInfo = assignedContactInfo;
    }

    public String getCreator() {
        return creator;
    }

    public void setCreator(String creator) {
        this.creator = creator;
    }

    public Date getEndDate() {
        return endDate;
    }

    public Date getStartDate() {
        return startDate;
    }

    public Project() {}
    public void setId(int id){
        this.id = id;
    }
    public int getId(){
        return id;
    }
    public void setContent(String content) {
        this.content = content;
    }
    public String getContent() {
        return content;
    }
    public void setProgressStage(String progressStage) {
        this.progressStage = progressStage;
    }
    public String getProgressStage() {
        return progressStage;
    }

    public Project(String name){
        this.name = name;
    }
    public Project(String name,String content){
        this.name = name;
        this.content = content;
    }
    public Project(String name,String content,String progressStage){
        this.name = name;
        this.content = content;
        this.progressStage = progressStage;
    }
    public Project(String name,String content,String progressStage,int id){
        this.name = name;
        this.content = content;
        this.progressStage = progressStage;
        this.id = id;
    }
    public Project(String name,String content,String progressStage,String creator,int id){
        this.name = name;
        this.content = content;
        this.progressStage = progressStage;
        this.creator = creator;
        this.id = id;
    }
    public Project(String name,String content,String progressStage,int id,Date enddate){
        this.name = name;
        this.content = content;
        this.progressStage = progressStage;
        this.id = id;
        this.endDate = enddate;
    }
    public Project(String name, String content, Date startDate, Date endDate) {
        this.name = name;
        this.content = content;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public List<String> getAssignedMembers() {
        return assignedMembers;
    }
    public void setAssignedMembers(List<String> assignedMembers) {
        this.assignedMembers = assignedMembers;
    }
    public void addAssignedMember(String id) {this.assignedMembers.add(id);}
    public boolean addMember(String member) {
        if (!assignedMembers.contains(member)) {
            this.assignedMembers.add(member);
            return true;
        }
        return false;
    }

}
