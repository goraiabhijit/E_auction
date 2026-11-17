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
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@500;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg:#eef5ff; --top:#d9e8ff; --side:#fff; --panel:#fff; --ink:#0c2250; --muted:#5d79ab;
            --line:#9bbdf2; --line2:#dce8fb; --accent:#2563eb; --on:#fff; --head:#e4efff; --banner:#cfe2ff;
            --s1:#ffd966; --good:#0d8a4e; --bad:#d3303b; --info:#2563eb; --link:#2563eb;
        }
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; font-family:'Manrope','Segoe UI',system-ui,sans-serif; }
        *:focus-visible { outline:2px solid var(--accent); outline-offset:2px; }
        body { background:var(--bg); color:var(--ink); min-height:100vh; padding:2rem; font-family:'Manrope','Segoe UI',system-ui,sans-serif; }
        .form-card { max-width:520px; margin:0 auto; background:var(--panel); padding:2rem; border-radius:10px; border:1.5px solid var(--line); }
        h2 { margin-bottom:1.5rem; color:var(--ink); font-size:22px; font-weight:800; letter-spacing:-.03em; }
        .form-group { margin-bottom:1.2rem; }
        label { display:block; font-weight:800; font-size:11px; margin-bottom:0.5rem; color:var(--muted); text-transform:uppercase; letter-spacing:.12em; }
        input[type="text"], input[type="number"], input[type="datetime-local"], textarea, input[type="file"], select { width:100%; padding:11px 14px; border:1.5px solid var(--line); border-radius:8px; box-sizing:border-box; font-size:14px; color:var(--ink); background:#fff; outline:none; transition:border-color 0.2s; font-family:inherit; }
        input:focus, textarea:focus, select:focus { border-color:var(--accent); }
        button { width:100%; padding:12px; background:var(--accent); border:none; border-radius:8px; font-weight:700; color:#fff; cursor:pointer; font-size:1rem; transition:opacity 0.15s; font-family:inherit; }
        button:hover { opacity:0.85; }
        .back-link { display:inline-block; margin-top:1rem; color:var(--link); text-decoration:none; font-size:13px; font-weight:700; }
        .preview-box { margin-top:8px; }
        .preview-img { max-width:140px; max-height:140px; border-radius:8px; border:1.5px solid var(--line); object-fit:cover; display:none; margin-top:6px; }
        small { font-size:11px; color:var(--muted); }
        #filePreviewName { color:var(--good); font-weight:700; }
    </style>
</head>
<body>

<div class="form-card">
    <h2>Put Item for Auction</h2>
    <form action="PutItemServlet" method="POST">
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
            <label for="auctionStartTime">Auction Start Time</label>
            <input type="datetime-local" id="auctionStartTime" name="auctionStartTime" required />
        </div>

        <div class="form-group">
            <label for="auctionEndTime">Auction End Time</label>
            <input type="datetime-local" id="auctionEndTime" name="auctionEndTime" required />
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