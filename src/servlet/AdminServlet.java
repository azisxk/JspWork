package servlet;

import com.work.bean.User;
import com.work.dao.UserDAO;

import com.work.util.DBUtil;
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

            switch (action) {
                case "add":
                    String newUsername = request.getParameter("newUsername");
                    String newPassword = request.getParameter("newPassword");
                    String newRole = request.getParameter("newRole");
                    if (userDAO.userExists(newUsername)) {
                        request.setAttribute("message", "用户名已存在！");
                        request.getRequestDispatcher("admin.jsp").forward(request, response);
                        return;
                    }

                    if (newUsername != null && newPassword != null && newRole != null) {
                        User newUser = new User(newUsername, newPassword, newRole);
                        userDAO.addUserAndReturnId(newUser);
                    }
                    break;

                case "delete":
                    String deleteUsername = request.getParameter("deleteUsername");
                    if (deleteUsername != null) {
                        userDAO.removeUser(deleteUsername);
                    }
                    break;

                case "modifyRole":
                    String modifyUsername = request.getParameter("modifyUsername");
                    String setRole = request.getParameter("modifyRole");

                    if (modifyUsername != null && setRole != null) {
                        userDAO.updateRole(modifyUsername, setRole);
                    }
                    break;
            }

            response.sendRedirect("admin.jsp");

        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("adminError", "操作失败：" + e.getMessage());
            response.sendRedirect("admin.jsp");
        }
    }
}
