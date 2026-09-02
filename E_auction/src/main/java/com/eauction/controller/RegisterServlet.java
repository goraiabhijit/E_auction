package com.eauction.controller;


import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

import com.eauction.dao.UserDao;
import com.eauction.model.User;

/**
 * Servlet implementation class RegisterServlet
 */
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public RegisterServlet() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.getWriter().append("Served at: ").append(request.getContextPath());
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Fetch form data using exact table column names: name, email, password, mobile, address, gender
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String mobile = request.getParameter("mobile");
        String address = request.getParameter("address");
        String gender = request.getParameter("gender");

        // 2. Wrap form values in User POJO
        User user = new User(name, email, password, mobile, address, gender);

        // 3. Delegate database save operation to UserDAO
        UserDao userDAO = new UserDao();
        boolean isSuccess = userDAO.insertUser(user);
        PrintWriter out = response.getWriter();

        // 4. Redirect based on query execution
//        if (isSuccess) {
//            response.sendRedirect("login.html?status=registered");
//        } else {
//            response.sendRedirect("register.html?error=failed");
//        }
        if (isSuccess) {
            out.println("<h2 style='color: green; text-align: center; margin-top: 50px;'>Register Success!</h2>");
            out.println("<p style='text-align: center;'><a href='index.html'>Click here to login</a></p>");
        } else {
            out.println("<h2 style='color: red; text-align: center; margin-top: 50px;'>Registration Failed!</h2>");
            out.println("<p style='text-align: center;'><a href='index.html'>Try Again</a></p>");
        }
    }
}