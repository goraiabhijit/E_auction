package com.eauction.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import com.eauction.dao.CommissionDao;
import com.eauction.model.Commission;

@WebServlet("/GenerateCommissionServlet")
public class GenerateCommissionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Fixed commission rate
    private static final double COMMISSION_PCT = 5.0;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session guard
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentAdmin") == null) {
            response.sendRedirect("signin.html");
            return;
        }

        try {
            int    itemId      = Integer.parseInt(request.getParameter("itemId"));
            String sellerEmail = request.getParameter("sellerEmail");
            double saleAmount  = Double.parseDouble(request.getParameter("saleAmount"));
            double commAmt     = Math.round(saleAmount * COMMISSION_PCT) / 100.0;

            Commission c = new Commission();
            c.setItemId(itemId);
            c.setSellerEmail(sellerEmail);
            c.setSaleAmount(saleAmount);
            c.setCommissionPct(COMMISSION_PCT);
            c.setCommissionAmt(commAmt);

            CommissionDao dao = new CommissionDao();
            dao.insertCommission(c);

        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        // Always redirect back to admin dashboard on commission tab
        response.sendRedirect("AdminDashboardServlet#commission");
    }
}
