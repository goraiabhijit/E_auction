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
import com.eauction.dao.CommissionDao;
import com.eauction.dao.AuctionResultDao;
import com.eauction.model.Item;
import com.eauction.model.Bid;
import com.eauction.model.Commission;
import com.eauction.model.AuctionResult;
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

        // Session guard
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("signin.html");
            return;
        }

        User loggedInUser = (User) session.getAttribute("currentUser");
        String email = loggedInUser.getEmail();

        ItemDao       itemDao       = new ItemDao();
        BidDao        bidDao        = new BidDao();
        CommissionDao commissionDao = new CommissionDao();

        // ── Tab 1: Live Auctions — all items (active + ended), sidebar toggle handled in JSP ──
        List<Item> allItems = itemDao.getAllItems();

        // ── Tab 2: My Bids — items this user has bid on, with highest bid per item ──
        List<Bid> myBids = bidDao.getBidsByUser(email);

        // ── All bids for bid history modal ──
        List<Bid> allBids = bidDao.getAllBids();

        // ── Tab 3: My Listings — items this user listed as seller ──
        List<Item> myListings = itemDao.getItemsBySellerEmail(email);

        // ── My Commissions (shown inside My Listings tab) ──
        List<Commission> myCommissions = commissionDao.getCommissionsBySellerEmail(email);

        // ── My Winnings — auctions this user won ──
        AuctionResultDao auctionResultDao = new AuctionResultDao();
        List<AuctionResult> myWinnings = auctionResultDao.getWinningsByBuyerEmail(email);

        // ── Attach to request ──
        request.setAttribute("allItems",      allItems);
        request.setAttribute("myBids",        myBids);
        request.setAttribute("allBids",       allBids);
        request.setAttribute("myListings",    myListings);
        request.setAttribute("myCommissions", myCommissions);
        request.setAttribute("myWinnings",    myWinnings);

        RequestDispatcher dispatcher = request.getRequestDispatcher("dashboard.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
