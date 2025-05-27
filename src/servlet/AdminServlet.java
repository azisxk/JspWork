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
            switch (action) {
                case "add":
                    String newUsername = request.getParameter("newUsername");
                    String newPassword = request.getParameter("newPassword");
                    String newRole = request.getParameter("newRole");
                    String newContactInfo = request.getParameter("newContactInfo");
                    String newDepartment = request.getParameter("newDepartment"); // 新增部门参数

                    if (userDAO.userExists(newUsername)) {
                        request.setAttribute("message", "用户名已存在！");
                        request.getRequestDispatcher("admin.jsp").forward(request, response);
                        return;
                    }

                    if (newUsername != null && newPassword != null && newRole != null) {
                        User newUser = new User(newUsername, newPassword, newRole);
                        newUser.setContactInfo(newContactInfo);
                        newUser.setDepartment(newDepartment); // 设置部门
                        userDAO.addUserAndReturnId(newUser);
                    }
                    successMessage = "用户添加成功！";
                    break;


                case "delete":
                    String deleteUsername = request.getParameter("deleteUsername");
                    if (deleteUsername != null) {
                        userDAO.removeUser(deleteUsername);
                    }
                    successMessage = "用户删除成功！";
                    break;

                case "modifyRole":
                    // 旧的只修改角色的处理，保留兼容
                    String modifyUsername = request.getParameter("modifyUsername");
                    String setRole = request.getParameter("modifyRole");
                    if (modifyUsername != null && setRole != null) {
                        userDAO.updateRole(modifyUsername, setRole);
                    }
                    break;
                case "modifyContactOnly":
                    String username = request.getParameter("modifyUsername");
                    String contact = request.getParameter("modifyContactInfo");
                    if (username != null) {
                        userDAO.updateContactInfo(username, contact);
                    }
                    break;
                case "modifyRoleAndContact":
                    String modUsername = request.getParameter("modifyUsername");
                    String modRole = request.getParameter("modifyRole");
                    String modContact = request.getParameter("modifyContactInfo");
                    String modDepartment = request.getParameter("modifyDepartment"); // 加上这个！

                    if (modUsername != null && modRole != null) {
                        userDAO.updateUserDetails(modUsername, modRole, modContact, modDepartment);
                    }
                    successMessage = "用户信息修改成功！";
                    break;
            }
            request.setAttribute("successMessage", successMessage);
            request.setAttribute("actionType", action);
            RequestDispatcher dispatcher = request.getRequestDispatcher("admin.jsp");
            dispatcher.forward(request, response);
//            response.sendRedirect("admin.jsp");

        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("adminError", "操作失败：" + e.getMessage());
            response.sendRedirect("admin.jsp");
        }



    }
}
