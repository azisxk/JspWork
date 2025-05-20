<%--
  Created by IntelliJ IDEA.
  User: Ker
  Date: 2025/5/19
  Time: 18:17
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>注册</title>
</head>
<body>
<link rel="stylesheet" type="text/css" href="styles.css">
<table>
    <form>
        <tr>
            <td>用户名</td>
            <td><input type="text" name="username" size="16px"></td>
        </tr>
        <tr>
            <td>密码</td>
            <td><input type="password" name="password" size="16px"></td>
        </tr>
        <tr>
            <td>学号</td>
            <td><input type="text" name="number" size="16px"></td>
        </tr>
        <tr>
            <td>班级</td>
            <td><input type="text" name="class" size="16px"></td>
        </tr>
        <tr>
            <td>性别</td>
            <td><input type="text" name="gender" size="16px"></td>
        </tr>
        <input type="submit" value="注册">
        <input type="submit" value="重置">
    </form>
</table>
</body>
</html>
