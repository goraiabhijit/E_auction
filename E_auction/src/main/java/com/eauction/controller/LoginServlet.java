package com.eauction.controller;
import com.eauction.dao.UserDao;
import com.eauction.model.User;

import jakarta.servlet.ServletException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet implementation class LoginServlet
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

    /**
     * Default constructor. 
     */
    public LoginServlet() {
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.sendRedirect("signin.html");
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		String email = request.getParameter("email");
        String password = request.getParameter("password");

        UserDao userDao = new UserDao();
        User loggedInUser = userDao.validateUser(email, password);

        if (loggedInUser != null) {
            // Create HTTP Session and store user object & name
            HttpSession session = request.getSession();
            session.setAttribute("currentUser", loggedInUser);
            session.setAttribute("userName", loggedInUser.getName());

            // Redirect to dashboard
            response.sendRedirect("dashboard.jsp");
        } else {
            // Invalid credentials -> redirect back with error parameter
            response.sendRedirect("signin.html?error=invalid");
        }
	}

}
