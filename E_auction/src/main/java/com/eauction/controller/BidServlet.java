package com.eauction.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import com.eauction.dao.BidDao;
import com.eauction.dao.ItemDao;
import com.eauction.model.Bid;
import com.eauction.model.Item;
import com.eauction.model.User;

/**
 * Servlet implementation class BidServlet
 */
@WebServlet("/BidServlet")
public class BidServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public BidServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // 1. Verify user session
        if (user == null) {
            response.sendRedirect("signin.html?error=unauthorized");
            return;
        }

        try {
            int itemId = Integer.parseInt(request.getParameter("itemId"));
            double bidAmount = Double.parseDouble(request.getParameter("bidAmount"));
            double startingPrice = Double.parseDouble(request.getParameter("startingPrice"));
            String sellerEmail = request.getParameter("sellerEmail");

            // 2. Prevent seller from bidding on their own listing
            if (user.getEmail().equalsIgnoreCase(sellerEmail)) {
                response.sendRedirect("bidItem.jsp?itemId=" + itemId + "&error=own_item");
                return;
            }

            BidDao bidDao = new BidDao();
            double currentHighest = bidDao.getHighestBid(itemId);

            // 3. Validate bid amount against starting price
            if (bidAmount <= startingPrice) {
                response.sendRedirect("DashboardServlet?error=below_starting_price&itemId=" + itemId);
                return;
            }

            // 4. Validate bid amount against current highest bid
            if (bidAmount <= currentHighest) {
                response.sendRedirect("DashboardServlet?error=low_bid&itemId=" + itemId);
                return;
            }

            // 5. Persist the bid
            Bid newBid = new Bid(itemId, user.getEmail(), bidAmount);
            boolean success = bidDao.placeBid(newBid);

            if (success) {
                response.sendRedirect("DashboardServlet?status=bid_success&itemId=" + itemId);
            } else {
                response.sendRedirect("DashboardServlet?error=bid_failed&itemId=" + itemId);
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("DashboardServlet?error=invalid_input");
        }
    }
}
