package servlet;

import com.work.bean.Project;
import com.work.bean.User;
import com.work.dao.ProjectDAO;
import com.work.dao.UserDAO;
import com.work.util.DBUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.util.*;

@WebServlet("/department")
public class DepartmentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String msg = "";

        try (Connection conn = DBUtil.getConnection()) {
            ProjectDAO projectDAO = new ProjectDAO(conn);
            UserDAO userDAO = new UserDAO(conn);

            if ("add".equals(action)) {
                String name = request.getParameter("name");
                String content = request.getParameter("content");
                String[] members = request.getParameterValues("members");

                if (name != null && content != null) {
                    Project p = new Project(name, content, "搭建框架"); // 默认阶段：搭建框架
                    if (members != null) {
                        p.setAssignedMembers(Arrays.asList(members));
                    }
                    boolean added = projectDAO.addProject(p);
                    msg = added ? "✅ 项目添加成功！" : "❌ 项目添加失败！";
                }
            }

            if ("edit".equals(action)) {
                String idStr = request.getParameter("projectId");
                if (idStr != null && !idStr.isEmpty()) {
                    int id = Integer.parseInt(idStr);
                    String newName = request.getParameter("editName");
                    String newContent = request.getParameter("editContent");
                    String stage = request.getParameter("progressStage");
                    String[] members = request.getParameterValues("editMembers");

                    Project p = new Project(newName, newContent, stage, id);
                    if (members != null) {
                        p.setAssignedMembers(Arrays.asList(members));
                    }
                    boolean updated = projectDAO.updateProject(p);
                    msg = updated ? "🔄 项目更新成功！" : "❌ 项目更新失败！";
                }
            }

            if ("delete".equals(action)) {
                String idStr = request.getParameter("projectId");
                if (idStr != null && !idStr.isEmpty()) {
                    int id = Integer.parseInt(idStr);
                    boolean deleted = projectDAO.deleteProject(id);
                    msg = deleted ? "🗑️ 项目删除成功！" : "❌ 删除失败，项目不存在或数据库错误。";
                }
            }

            // 获取所有项目及用户信息用于展示
            List<Project> projects = projectDAO.getAllProjects();
            List<User> users = userDAO.getAllUsers();
            if (users == null) {
                users = new ArrayList<>();
            }

            request.setAttribute("projects", projects);
            request.setAttribute("allUsers", users);
            request.setAttribute("msg", msg);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("msg", "🚨 操作异常：" + e.getMessage());
        }

        request.getRequestDispatcher("department.jsp").forward(request, response);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
    @Override
    public void init() throws ServletException {
        System.out.println("🚀 DepartmentServlet 启动成功！");
    }

}
