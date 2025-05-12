package servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/userManagement")
public class UserManagementServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            // 添加用户逻辑
        } else if ("delete".equals(action)) {
            // 删除用户逻辑
        } else if ("modifyRole".equals(action)) {
            // 修改用户身份逻辑
        }

        response.sendRedirect("admin.jsp"); // 操作完刷新admin.jsp
    }
}
