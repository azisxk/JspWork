package com.work.bean;

import java.util.ArrayList;
import java.util.List;

public class Project {
    private String name;
    private String content;
    private int id;
    private String progressStage;
    private List<String> assignedMembers = new ArrayList<>();
    private List<Integer> assignedMemberIds = new ArrayList<>();
    public List<Integer> getAssignedMemberIds() {
        return assignedMemberIds;
    }
    public void setAssignedMemberIds(List<Integer> ids) {
        this.assignedMemberIds = ids;
    }
    public void addAssignedMemberId(int id) {
        this.assignedMemberIds.add(id);
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
