<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.eauction.model.User" %>
<%
    User loggedInUser = (User) session.getAttribute("currentUser");
    if (loggedInUser == null) {
        response.sendRedirect("signin.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Put Item for Bid - E-Auction</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; padding: 2rem; }
        .form-card { max-width: 500px; margin: 0 auto; background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        h2 { margin-bottom: 1.5rem; color: #101827; }
        .form-group { margin-bottom: 1.2rem; }
        label { display: block; font-weight: bold; margin-bottom: 0.4rem; color: #374151; }
        input[type="text"], input[type="number"], textarea, input[type="file"] { width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 6px; box-sizing: border-box; }
        button { width: 100%; padding: 12px; background: #f59e0b; border: none; border-radius: 6px; font-weight: bold; color: #111827; cursor: pointer; font-size: 1rem; }
        button:hover { background: #d97706; }
        .back-link { display: inline-block; margin-top: 1rem; color: #4b5563; text-decoration: none; }
    </style>
</head>
<body>

<div class="form-card">
    <h2>Put Item for Auction</h2>
    <form action="PutItemServlet" method="POST" enctype="multipart/form-data">
        <div class="form-group">
            <label for="itemName">Item Title</label>
            <input type="text" id="itemName" name="itemName" required />
        </div>
        
        <div class="form-group">
            <label for="itemDescription">Description</label>
            <textarea id="itemDescription" name="itemDescription" rows="4" required></textarea>
        </div>

        <div class="form-group">
            <label for="startingPrice">Starting Price (₹)</label>
            <input type="number" id="startingPrice" name="startingPrice" step="1" min="1" required />
        </div>

        <div class="form-group">
            <label for="itemPicture">Item Picture</label>
            <input type="file" id="itemPicture" name="itemPicture" accept="image/*" required />
        </div>

        <button type="submit">Submit Item</button>
    </form>
    <a href="DashboardServlet" class="back-link">&larr; Back to Dashboard</a>
</div>

</body>
</html>