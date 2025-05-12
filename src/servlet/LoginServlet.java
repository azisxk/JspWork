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

@WebServlet("/loginCheck")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        System.out.println("LoginServlet 开始执行 doPost");

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String inputCode = request.getParameter("validationCode1");
        String correctCode = request.getParameter("validationCode");

        // 验证码校验
        if (!inputCode.equalsIgnoreCase(correctCode)) {
            request.getSession().setAttribute("loginAlert", "验证码错误");
            response.sendRedirect("login.jsp");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            UserDAO userDAO = new UserDAO(conn);
            User user = userDAO.getUser(username);

            if (user != null && user.getPassword().equals(password)) {
                // 登录成功，存储用户名到 session
                request.getSession().setAttribute("userName", username);  // 存储用户名
                request.getSession().setAttribute("user", user);  // 存储完整的 User 对象（如需要）
                System.out.println("登录成功，设置 userName 为：" + username);


                response.sendRedirect("index.jsp");
            } else {
                request.getSession().setAttribute("loginAlert", "账号或密码错误！");
                response.sendRedirect("login.jsp");

                // 输出调试信息
                if (user != null) {
                    System.out.println("数据库返回的密码：" + user.getPassword());
                }
                System.out.println("用户输入的用户名：" + username);
                System.out.println("用户输入的密码：" + password);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("loginAlert", "数据库连接失败！");
            response.sendRedirect("login.jsp");
        }
    }
}
