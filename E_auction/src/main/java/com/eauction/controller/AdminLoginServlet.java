package com.eauction.controller;

import com.eauction.dao.AdminUserDao;
import com.eauction.model.Admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public AdminLoginServlet() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("signin.html");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        AdminUserDao adminDao = new AdminUserDao();
        Admin admin = adminDao.validateAdmin(email, password);

        if (admin != null) {
            HttpSession session = request.getSession();
            session.setAttribute("currentAdmin", admin);
            session.setAttribute("adminName",    admin.getName());
            session.setAttribute("adminEmail",   admin.getEmail());

            response.sendRedirect("AdminDashboardServlet");
        } else {
            response.sendRedirect("signin.html?error=invalid_admin");
        }
    }
}
