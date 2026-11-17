package com.eauction.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import com.eauction.dao.ItemDao;
import com.eauction.model.Item;
import com.eauction.model.User;

/**
 * Servlet implementation class PutItemServlet
 */
@WebServlet("/PutItemServlet")
public class PutItemServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    public PutItemServlet() {
        super();
    }

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// 1. Fetch logged-in user from session
        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (loggedInUser == null) {
            response.sendRedirect("signin.html");
            return;
        }

        // 2. Fetch parameters matching exact form names
        String itemName        = request.getParameter("itemName");
        String itemDescription = request.getParameter("itemDescription");
        double startingPrice   = Double.parseDouble(request.getParameter("startingPrice"));
        String sellerEmail     = loggedInUser.getEmail();

        // Parse datetime-local values into Timestamps
        String startTimeStr = request.getParameter("auctionStartTime"); // format: 2026-09-03T10:30
        String endTimeStr   = request.getParameter("auctionEndTime");

        java.sql.Timestamp auctionStartTime = java.sql.Timestamp.valueOf(startTimeStr.replace("T", " ") + ":00");
        java.sql.Timestamp auctionEndTime   = java.sql.Timestamp.valueOf(endTimeStr.replace("T", " ") + ":00");

        // 3. Get image filename from form parameter (plain text value of file input)
        String itemPicture = request.getParameter("itemPicture");
        String dbPicturePath;
        if (itemPicture != null && !itemPicture.trim().isEmpty()) {
            itemPicture = itemPicture.trim().replace("\\", "/");
            int lastSlash = itemPicture.lastIndexOf('/');
            if (lastSlash >= 0) itemPicture = itemPicture.substring(lastSlash + 1);
            dbPicturePath = "uploads/" + itemPicture;
        } else {
            dbPicturePath = "images/placeholder.png";
        }

        // 4. Populate Item model object
        Item item = new Item();
        item.setItemName(itemName);
        item.setItemDescription(itemDescription);
        item.setStartingPrice(startingPrice);
        item.setItemPicture(dbPicturePath);
        item.setSellerEmail(sellerEmail);
        item.setAuctionStartTime(auctionStartTime);
        item.setAuctionEndTime(auctionEndTime);

        // 5. Call DAO method putItem
        ItemDao itemDao = new ItemDao();
        if (itemDao.putItem(item)) {
            response.sendRedirect("DashboardServlet");
        } else {
            response.sendRedirect("addItem.jsp?error=insert_failed");
        }
	}
}
