package servlet;

import com.work.bean.User;
import com.work.dao.UserDAO;
import com.work.util.DBUtil;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

@WebServlet("/adminServlet")
public class AdminServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User currentUser = (User) request.getSession().getAttribute("user");
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try (Connection conn = DBUtil.getConnection()) {
            UserDAO userDAO = new UserDAO(conn);
            String successMessage = "";
            String errorMessage = "";

            switch (action) {
                case "add":
                    String newUsername = request.getParameter("newUsername");
                    String newPassword = request.getParameter("newPassword");
                    String newRole = request.getParameter("newRole");
                    String newContactInfo = request.getParameter("newContactInfo");
                    String newDepartment = request.getParameter("newDepartment");

                    if (userDAO.userExists(newUsername)) {
                        request.setAttribute("message", "用户名已存在！");
                        request.getRequestDispatcher("admin.jsp").forward(request, response);
                        return;
                    }

                    if (newUsername != null && newPassword != null && newRole != null) {
                        User newUser = new User(newUsername, newPassword, newRole);
                        newUser.setContactInfo(newContactInfo);
                        newUser.setDepartment(newDepartment);
                        userDAO.addUserAndReturnId(newUser);
                        successMessage = "用户添加成功！";
                    }
                    break;
                case "modifyContactAndDepartment":
                    String usernameAdmin = request.getParameter("modifyUsername");
                    String contactAdmin = request.getParameter("modifyContactInfo");
                    String departmentAdmin = request.getParameter("modifyDepartment");
                    if (usernameAdmin != null) {
                        userDAO.updateUserDetails(usernameAdmin, "admin", contactAdmin, departmentAdmin);
                    }
                    successMessage = "管理员信息修改成功！";
                    break;

                case "delete":
                    String deleteUsername = request.getParameter("deleteUsername");
                    if (deleteUsername != null && !deleteUsername.trim().isEmpty()) {
                        User userToDelete = userDAO.getUser(deleteUsername);
                        if (userToDelete == null) {
                            errorMessage = "要删除的用户不存在！";
                        } else if ("admin".equals(userToDelete.getRole())) {
                            errorMessage = "不允许删除管理员账户！";
                        } else {
                            userDAO.removeUser(deleteUsername);
                            successMessage = "用户删除成功！";
                        }
                    } else {
                        errorMessage = "请选择要删除的用户！";
                    }
                    break;

                case "modifyRole":
                    String modifyUsername = request.getParameter("modifyUsername");
                    String setRole = request.getParameter("modifyRole");
                    if (modifyUsername != null && setRole != null) {
                        userDAO.updateRole(modifyUsername, setRole);
                        successMessage = "用户角色更新成功！";
                    }
                    break;

                case "modifyContactOnly":
                    String username = request.getParameter("modifyUsername");
                    String contact = request.getParameter("modifyContactInfo");
                    if (username != null) {
                        userDAO.updateContactInfo(username, contact);
                        successMessage = "联系方式更新成功！";
                    }
                    break;

                case "modifyRoleAndContact":
                    String modUsername = request.getParameter("modifyUsername");
                    String modRole = request.getParameter("modifyRole");
                    String modContact = request.getParameter("modifyContactInfo");
                    String modDepartment = request.getParameter("modifyDepartment");

                    if (modUsername != null && modRole != null) {
                        userDAO.updateUserDetails(modUsername, modRole, modContact, modDepartment);
                        successMessage = "用户信息修改成功！";
                    }
                    break;
            }

            if (!successMessage.isEmpty()) {
                request.setAttribute("successMessage", successMessage);
                request.setAttribute("actionType", action);
            }

            if (!errorMessage.isEmpty()) {
                request.setAttribute("message", errorMessage);
            }

            // 刷新页面前，重新查询用户列表
            request.setAttribute("users", userDAO.getAllUsers());
            RequestDispatcher dispatcher = request.getRequestDispatcher("admin.jsp");
            dispatcher.forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("adminError", "操作失败：" + e.getMessage());
            response.sendRedirect("admin.jsp");
        }
    }
}
