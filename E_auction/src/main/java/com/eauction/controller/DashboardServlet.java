package com.eauction.controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.eauction.dao.ItemDao;
import com.eauction.dao.BidDao;
import com.eauction.model.Item;
import com.eauction.model.Bid;
import com.eauction.model.User;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public DashboardServlet() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Session Guard Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("signin.html");
            return;
        }

        // 2. Fetch real active items from Oracle DB via ItemDao
        ItemDao itemDao = new ItemDao();
        List<Item> itemList = itemDao.getAllItems();

        // 3. Fetch bids — user's own bids and all bids
        User loggedInUser = (User) session.getAttribute("currentUser");
        BidDao bidDao = new BidDao();
        List<Bid> myBids  = bidDao.getBidsByUser(loggedInUser.getEmail());
        List<Bid> allBids = bidDao.getAllBids();

        // 4. Attach all lists to request scope
        request.setAttribute("itemList", itemList);
        request.setAttribute("myBids",   myBids);
        request.setAttribute("allBids",  allBids);

        // 4. Forward execution to dashboard.jsp
        RequestDispatcher dispatcher = request.getRequestDispatcher("dashboard.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}