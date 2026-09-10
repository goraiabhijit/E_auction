<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.eauction.model.Item" %>
<%@ page import="com.eauction.model.Bid" %>
<%@ page import="com.eauction.model.User" %>
<%
    User loggedInUser = (User) session.getAttribute("currentUser");

    if (loggedInUser == null) {
        response.sendRedirect("signin.html");
        return;
    }

    List<Item> itemList = (List<Item>) request.getAttribute("itemList");
    List<Bid>  myBids   = (List<Bid>)  request.getAttribute("myBids");
    List<Bid>  allBids  = (List<Bid>)  request.getAttribute("allBids");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - E-Auction Platform</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        body {
            background-color: #f4f6f9;
            color: #333;
        }
        header {
            background-color: #101827;
            color: #fff;
            height: 84px;
            padding: 0 7%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 3px solid #f59e0b;
            box-shadow: 0 3px 12px rgba(0,0,0,0.25);
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        .logo {
            font-size: 28px;
            font-weight: bold;
            color: white;
            text-decoration: none;
            letter-spacing: -1px;
        }
        .logo span { color: #f59e0b; }

        .user-menu { position: relative; }

        .user-trigger {
            display: flex;
            align-items: center;
            gap: 9px;
            background: transparent;
            border: 1px solid #f59e0b;
            border-radius: 6px;
            padding: 8px 14px;
            color: white;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.2s;
        }
        .user-trigger:hover { background: rgba(245,158,11,0.1); }

        .avatar {
            width: 28px;
            height: 28px;
            background: #f59e0b;
            color: #111827;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: bold;
            flex-shrink: 0;
        }

        .chevron { font-size: 10px; transition: transform 0.2s; }
        .user-menu.open .chevron { transform: rotate(180deg); }

        .dropdown {
            display: none;
            position: absolute;
            right: 0;
            top: calc(100% + 8px);
            background: #1e293b;
            border: 1px solid #334155;
            border-radius: 8px;
            min-width: 180px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.4);
            overflow: hidden;
            z-index: 2000;
        }
        .user-menu.open .dropdown { display: block; }

        .dropdown-header {
            padding: 12px 16px;
            border-bottom: 1px solid #334155;
        }
        .dropdown-header .name { font-weight: bold; font-size: 14px; color: white; }
        .dropdown-header .email { font-size: 12px; color: #9ca3af; margin-top: 3px; word-break: break-all; }

        .dropdown a {
            display: block;
            padding: 11px 16px;
            color: #f87171;
            font-size: 14px;
            text-decoration: none;
            border-top: 1px solid #334155;
            transition: background 0.2s;
        }
        .dropdown a:hover { background: rgba(248,113,113,0.1); }
        main {
            padding: 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }
        .welcome-card {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .btn-add-item {
            background-color: #f59e0b;
            color: #111827;
            padding: 10px 18px;
            border-radius: 6px;
            font-weight: bold;
            text-decoration: none;
        }

        .items-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 1.5rem;
        }

        .item-card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        /* Added image banner styling */
        .item-image {
            width: 100%;
            height: 180px;
            object-fit: cover;
            border-bottom: 1px solid #e2e8f0;
        }

        .item-body {
            padding: 1rem;
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .item-price {
            font-size: 1.2rem;
            font-weight: bold;
            color: #059669;
        }

        .bid-btn {
            display: block;
            text-align: center;
            background: #f59e0b;
            color: #111827;
            font-weight: bold;
            font-size: 14px;
            padding: 9px;
            border-radius: 6px;
            text-decoration: none;
            margin-top: 6px;
            transition: background 0.2s;
            width: 100%;
        }
        .bid-btn:hover { background: #d97706; color: white; }

        /* ── Two column layout ── */
        .dashboard-layout {
            display: grid;
            grid-template-columns: 1fr 320px;
            gap: 2rem;
            align-items: start;
        }

        /* ── Bid panels ── */
        .bid-panel {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            overflow: hidden;
            margin-bottom: 1.5rem;
        }

        .bid-panel-header {
            padding: 14px 16px;
            border-bottom: 1px solid #e2e8f0;
            font-weight: bold;
            font-size: 15px;
            color: #111827;
            background: #f8fafc;
        }

        .bid-panel-body {
            max-height: 320px;
            overflow-y: auto;
        }

        .bid-row {
            padding: 10px 16px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 13px;
            color: #374151;
            line-height: 1.5;
        }

        .bid-row:last-child { border-bottom: none; }
        .bid-row .bid-item  { font-weight: bold; color: #111827; }
        .bid-row .bid-amt   { color: #059669; font-weight: bold; }
        .bid-row .bid-time  { color: #94a3b8; font-size: 11px; display: block; margin-top: 2px; }
        .bid-row .bid-user  { color: #6366f1; font-weight: bold; }

        .no-bids { padding: 16px; font-size: 13px; color: #94a3b8; text-align: center; }
    </style>
</head>
<body>

    <header>
        <a class="logo" href="DashboardServlet">E-<span>Auction</span></a>

        <a href="addItem.jsp" class="btn-add-item">+ Add New Item</a>

        <div class="user-menu" id="userMenu">
            <button class="user-trigger" onclick="toggleDropdown()">
                <div class="avatar"><%= loggedInUser.getName().trim().substring(0,1).toUpperCase() %></div>
                Welcome, <%= loggedInUser.getName() %>
                <span class="chevron">&#9660;</span>
            </button>
            <div class="dropdown">
                <div class="dropdown-header">
                    <div class="name"><%= loggedInUser.getName() %></div>
                    <div class="email"><%= loggedInUser.getEmail() %></div>
                    <div class="email">Role: <%= loggedInUser.getRole() %></div>
                </div>
                <a href="LogoutServlet">&#x2192; Logout</a>
            </div>
        </div>
    </header>

    <main>
        <section class="welcome-card">
            <div>
                <h2>Live Auctions</h2>
                <p style="margin-top: 0.5rem; color: #64748b;">Active items fetched directly from Oracle DB.</p>
            </div>
        </section>

        <div class="dashboard-layout">

            <!-- Left: item cards -->
            <section class="items-grid">
            <%
                if (itemList != null && !itemList.isEmpty()) {
                    for (Item item : itemList) {
            %>
                <div class="item-card">
                    <img class="item-image" 
                         src="<%= request.getContextPath() %>/<%= (item.getItemPicture() != null && !item.getItemPicture().trim().isEmpty()) ? item.getItemPicture() : "images/placeholder.png" %>" 
                         alt="<%= item.getItemName() %>"
                         onerror="this.onerror=null; this.src='https://via.placeholder.com/280x180?text=No+Image';" />

                    <div class="item-body">
                        <h3><%= item.getItemName() %></h3>
                        <small style="color: #94a3b8;">ID: <%= item.getItemId() %></small>
                        <p style="color: #64748b;"><%= item.getItemDescription() %></p>
                        <div class="item-price">₹<%= item.getStartingPrice() %></div>
                        <small style="color: #94a3b8;">Seller: <%= item.getSellerEmail() %></small>
                        <a class="bid-btn" href="bidItem.jsp?itemId=<%= item.getItemId() %>&startingPrice=<%= item.getStartingPrice() %>&sellerEmail=<%= item.getSellerEmail() %>">Place Bid</a>
                    </div>
                </div>
            <%
                    }
                } else {
            %>
                <p style="color: #64748b;">No active auctions listed yet.</p>
            <%
                }
            %>
            </section>

            <!-- Right: bid panels -->
            <aside>

                <!-- My Bids -->
                <div class="bid-panel">
                    <div class="bid-panel-header">🏷 My Bids</div>
                    <div class="bid-panel-body">
                    <%
                        if (myBids != null && !myBids.isEmpty()) {
                            for (Bid bid : myBids) {
                    %>
                        <div class="bid-row">
                            You bid on <span class="bid-item"><%= bid.getItemName() %></span>
                            for <span class="bid-amt">₹<%= bid.getBidAmount() %></span>
                            <span class="bid-time"><%= bid.getBidTime() %></span>
                        </div>
                    <%
                            }
                        } else {
                    %>
                        <div class="no-bids">You haven't placed any bids yet.</div>
                    <%
                        }
                    %>
                    </div>
                </div>

                <!-- All Bids -->
                <div class="bid-panel">
                    <div class="bid-panel-header">📋 All Bids</div>
                    <div class="bid-panel-body">
                    <%
                        if (allBids != null && !allBids.isEmpty()) {
                            for (Bid bid : allBids) {
                                // Show "You" if the bidder is the current logged-in user
                                String bidderDisplay = bid.getBidderEmail().equalsIgnoreCase(loggedInUser.getEmail()) 
                                                       ? "You" 
                                                       : bid.getBidderEmail();
                    %>
                        <div class="bid-row">
                            <span class="bid-user"><%= bidderDisplay %></span>
                            bid on <span class="bid-item"><%= bid.getItemName() %></span>
                            for <span class="bid-amt">₹<%= bid.getBidAmount() %></span>
                            <span class="bid-time"><%= bid.getBidTime() %></span>
                        </div>
                    <%
                            }
                        } else {
                    %>
                        <div class="no-bids">No bids placed yet.</div>
                    <%
                        }
                    %>
                    </div>
                </div>

            </aside>

        </div>
    </main>

    <script>
        function toggleDropdown() {
            document.getElementById("userMenu").classList.toggle("open");
        }
        document.addEventListener("click", function (e) {
            const menu = document.getElementById("userMenu");
            if (!menu.contains(e.target)) menu.classList.remove("open");
        });
    </script>
</body>
</html>