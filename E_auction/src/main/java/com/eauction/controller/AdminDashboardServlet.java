package com.eauction.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

import com.eauction.dao.AuctionResultDao;
import com.eauction.dao.ItemDao;
import com.eauction.dao.UserDao;
import com.eauction.model.AuctionResult;
import com.eauction.model.Item;
import com.eauction.model.User;

@WebServlet("/AdminDashboardServlet")
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public AdminDashboardServlet() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session guard
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentAdmin") == null) {
            response.sendRedirect("signin.html");
            return;
        }

        // ── Users tab ──
        UserDao userDao = new UserDao();
        List<User> allUsers = userDao.getAllUsers();

        // ── Item Details tab ──
        ItemDao itemDao = new ItemDao();
        List<Item> activeItems    = itemDao.getActiveItems();
        List<Item> completedItems = itemDao.getCompletedItems();

        // ── Auction Details tab ──
        AuctionResultDao auctionResultDao = new AuctionResultDao();
        List<AuctionResult> completedAuctions = auctionResultDao.getCompletedAuctions();

        // ── Dashboard stat counts ──
        int totalUsers    = allUsers.size();
        int activeCount   = activeItems.size();
        int completedCount = completedItems.size();

        // ── Attach all to request ──
        request.setAttribute("allUsers",           allUsers);
        request.setAttribute("activeItems",        activeItems);
        request.setAttribute("completedItems",     completedItems);
        request.setAttribute("completedAuctions",  completedAuctions);
        request.setAttribute("totalUsers",         totalUsers);
        request.setAttribute("activeCount",        activeCount);
        request.setAttribute("completedCount",     completedCount);

        request.getRequestDispatcher("adminDashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
