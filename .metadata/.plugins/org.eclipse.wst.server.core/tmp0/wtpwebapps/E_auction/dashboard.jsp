<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.eauction.model.Item" %>
<%@ page import="com.eauction.model.Bid" %>
<%@ page import="com.eauction.model.User" %>
<%@ page import="com.eauction.model.AuctionResult" %>
<%@ page import="com.eauction.model.Commission" %>
<%
    User loggedInUser = (User) session.getAttribute("currentUser");
    if (loggedInUser == null) {
        response.sendRedirect("signin.html");
        return;
    }

    List<Item>          allItems      = (List<Item>)          request.getAttribute("allItems");
    List<Bid>           myBids        = (List<Bid>)           request.getAttribute("myBids");
    List<Item>          myListings    = (List<Item>)          request.getAttribute("myListings");
    List<Commission>    myCommissions = (List<Commission>)    request.getAttribute("myCommissions");
    List<AuctionResult> myWinnings    = (List<AuctionResult>) request.getAttribute("myWinnings");

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy HH:mm");
    Date now = new Date();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - E-Auction</title>
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }

        body { background: #0f172a; color: #e2e8f0; min-height: 100vh; }

        /* Header */
        .header {
            height: 68px;
            background: #0f172a;
            display: flex;
            align-items: center;
            padding: 0 2rem;
            gap: 16px;
            border-bottom: 1px solid #1e293b;
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .logo { font-size: 22px; font-weight: 800; color: #f59e0b; text-decoration: none; letter-spacing: -0.5px; }
        .logo span { color: white; }
        .header-title { flex: 1; font-size: 12px; color: #334155; letter-spacing: 1.5px; text-transform: uppercase; }

        .btn-add {
            background: #f59e0b;
            color: #111827;
            padding: 9px 20px;
            border-radius: 50px;
            font-weight: 700;
            font-size: 13px;
            text-decoration: none;
            transition: background 0.2s, transform 0.1s;
        }
        .btn-add:hover { background: #d97706; transform: translateY(-1px); }

        /* User menu */
        .user-menu { position: relative; }
        .user-trigger {
            display: flex;
            align-items: center;
            gap: 10px;
            background: transparent;
            border: 1px solid #334155;
            border-radius: 50px;
            padding: 6px 14px 6px 6px;
            color: white;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: border-color 0.2s;
        }
        .user-trigger:hover { border-color: #f59e0b; }
        .avatar {
            width: 32px; height: 32px;
            background: #f59e0b; color: #111827;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; font-weight: 800; flex-shrink: 0;
        }
        .chevron { font-size: 10px; color: #64748b; transition: transform 0.2s; }
        .user-menu.open .chevron { transform: rotate(180deg); }
        .dropdown {
            display: none;
            position: absolute; right: 0; top: calc(100% + 10px);
            background: #1e293b; border: 1px solid #334155;
            border-radius: 16px; min-width: 200px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.5);
            overflow: hidden; z-index: 2000;
        }
        .user-menu.open .dropdown { display: block; }
        .dropdown-header { padding: 14px 18px; border-bottom: 1px solid #334155; }
        .dropdown-header .name  { font-weight: 700; font-size: 14px; color: white; }
        .dropdown-header .email { font-size: 11px; color: #64748b; margin-top: 3px; word-break: break-all; }
        .dropdown a { display: block; padding: 12px 18px; color: #f87171; font-size: 13px; text-decoration: none; transition: background 0.2s; }
        .dropdown a:hover { background: rgba(248,113,113,0.1); }

        /* Layout */
        .dashboard-container { display: flex; min-height: calc(100vh - 68px); }

        /* Sidebar */
        .sidebar {
            width: 220px;
            background: #0f172a;
            padding: 28px 14px;
            flex-shrink: 0;
            border-right: 1px solid #1e293b;
        }
        .sidebar h3 {
            color: #334155; font-size: 10px;
            text-transform: uppercase; letter-spacing: 1.5px;
            margin-bottom: 16px; padding-left: 12px;
        }
        .menu-btn {
            width: 100%;
            display: flex; align-items: center; gap: 10px;
            background: transparent; color: #64748b;
            border: none; text-align: left;
            padding: 11px 14px; margin-bottom: 4px;
            border-radius: 14px; cursor: pointer;
            font-size: 13px; font-weight: 500;
            transition: background 0.2s, color 0.2s;
        }
        .menu-btn:hover  { background: #1e293b; color: #e2e8f0; }
        .menu-btn.active { background: #f59e0b; color: #111827; font-weight: 700; }
        .menu-icon { font-size: 15px; width: 20px; text-align: center; }

        /* Main content */
        .main-content { flex: 1; padding: 2rem; overflow-x: auto; }

        .content-section { display: none; }
        .content-section.active-section { display: block; }

        .section-header { margin-bottom: 20px; }
        .section-header h1 { font-size: 22px; font-weight: 700; color: #f1f5f9; }
        .section-header p  { color: #475569; margin-top: 6px; font-size: 13px; }

        /* Filter bar */
        .filter-bar {
            display: flex; gap: 8px; margin-bottom: 20px; flex-wrap: wrap;
        }
        .filter-btn {
            padding: 7px 18px; border-radius: 50px;
            border: 1px solid #334155; background: transparent;
            color: #64748b; font-size: 12px; font-weight: 600;
            cursor: pointer; transition: all 0.2s;
        }
        .filter-btn:hover  { border-color: #f59e0b; color: #f59e0b; }
        .filter-btn.active { background: #f59e0b; border-color: #f59e0b; color: #111827; }

        /* Item grid */
        .items-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 1.2rem;
        }

        .item-card {
            background: #1e293b;
            border-radius: 20px;
            overflow: hidden;
            display: flex; flex-direction: column;
            border: 1px solid #334155;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .item-card:hover { transform: translateY(-3px); box-shadow: 0 12px 32px rgba(0,0,0,0.4); }
        .item-card.ended { opacity: 0.7; }

        .item-image { width: 100%; height: 160px; object-fit: cover; }

        .item-body {
            padding: 1rem 1.1rem;
            display: flex; flex-direction: column; gap: 0.35rem; flex: 1;
        }
        .item-body h3    { font-size: 14px; font-weight: 700; color: #f1f5f9; }
        .item-body p     { font-size: 12px; color: #64748b; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .item-body small { font-size: 11px; color: #475569; }
        .item-price      { font-size: 1.2rem; font-weight: 800; color: #34d399; }

        .bid-btn {
            display: block; text-align: center;
            background: #f59e0b; color: #111827;
            font-weight: 700; font-size: 13px;
            padding: 9px; border-radius: 50px;
            text-decoration: none; margin-top: 8px;
            transition: background 0.2s, transform 0.1s;
        }
        .bid-btn:hover { background: #d97706; color: white; transform: translateY(-1px); }

        .bid-btn-ended {
            display: block; text-align: center;
            background: #334155; color: #475569;
            font-weight: 700; font-size: 13px;
            padding: 9px; border-radius: 50px;
            margin-top: 8px; border: none; cursor: not-allowed; width: 100%;
        }

        .status-badge {
            display: inline-block; padding: 3px 10px;
            border-radius: 50px; font-size: 10px; font-weight: 700;
        }
        .badge-active  { background: rgba(52,211,153,0.15);  color: #34d399; }
        .badge-ended   { background: rgba(248,113,113,0.15); color: #f87171; }

        /* Countdown */
        .countdown-box { display: flex; align-items: center; gap: 6px; margin-top: 2px; }
        .countdown-label { color: #475569; font-size: 10px; }
        .countdown-value {
            background: #0f172a; color: #f59e0b;
            padding: 2px 8px; border-radius: 50px;
            font-family: monospace; font-size: 11px;
        }
        .countdown-value.urgent { background: #ef4444; color: white; }
        .countdown-ended { font-size: 11px; color: #f87171; font-weight: 700; margin-top: 4px; }
        .ended-msg { font-size: 11px; color: #ef4444; margin-top: 4px; text-align: center; }

        /* Table */
        .table-container {
            background: #1e293b;
            border-radius: 20px;
            overflow: hidden;
            border: 1px solid #334155;
        }
        table { width: 100%; border-collapse: collapse; min-width: 500px; }
        th {
            background: #0f172a; color: #94a3b8;
            padding: 13px 16px; text-align: left;
            font-size: 11px; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.8px;
        }
        td {
            padding: 13px 16px;
            border-bottom: 1px solid #0f172a;
            font-size: 13px; color: #cbd5e1;
        }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: rgba(255,255,255,0.02); }
        .empty-row td { text-align: center; color: #334155; padding: 32px; font-style: italic; }

        .badge {
            padding: 4px 12px; border-radius: 50px;
            font-size: 11px; font-weight: 700; display: inline-block;
        }
        .badge-green  { background: rgba(52,211,153,0.15);  color: #34d399; }
        .badge-amber  { background: rgba(245,158,11,0.15);  color: #f59e0b; }
        .badge-blue   { background: rgba(96,165,250,0.15);  color: #60a5fa; }
        .badge-red    { background: rgba(248,113,113,0.15); color: #f87171; }

        /* Winnings summary banner */
        .summary-banner {
            background: linear-gradient(135deg, #1e3a8a 0%, #312e81 100%);
            border-radius: 20px;
            padding: 20px 24px;
            margin-bottom: 20px;
            display: flex; gap: 32px; flex-wrap: wrap;
            border: 1px solid #3730a3;
        }
        .summary-stat h4 { font-size: 11px; color: #a5b4fc; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 6px; }
        .summary-stat .val { font-size: 28px; font-weight: 800; color: white; }

        /* Scrollbar */
        ::-webkit-scrollbar { width: 5px; height: 5px; }
        ::-webkit-scrollbar-track { background: #0f172a; }
        ::-webkit-scrollbar-thumb { background: #334155; border-radius: 10px; }

        /* Bid History Modal */
        .modal-overlay {
            display: none;
            position: fixed; inset: 0;
            background: rgba(0,0,0,0.7);
            z-index: 9000;
            align-items: center;
            justify-content: center;
        }
        .modal-overlay.open { display: flex; }

        .modal {
            background: #1e293b;
            border: 1px solid #334155;
            border-radius: 24px;
            width: 100%;
            max-width: 540px;
            max-height: 80vh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            box-shadow: 0 24px 60px rgba(0,0,0,0.6);
        }

        .modal-header {
            padding: 20px 24px;
            border-bottom: 1px solid #334155;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .modal-header h3 { font-size: 16px; font-weight: 700; color: #f1f5f9; }
        .modal-header small { font-size: 12px; color: #475569; margin-top: 3px; display: block; }

        .modal-close {
            background: transparent;
            border: 1px solid #334155;
            color: #94a3b8;
            border-radius: 50%;
            width: 32px; height: 32px;
            font-size: 16px;
            cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            transition: border-color 0.2s, color 0.2s;
            flex-shrink: 0;
        }
        .modal-close:hover { border-color: #f87171; color: #f87171; }

        .modal-body { overflow-y: auto; padding: 0; }

        .modal-bid-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 24px;
            border-bottom: 1px solid #0f172a;
            font-size: 13px;
        }
        .modal-bid-row:last-child { border-bottom: none; }
        .modal-bid-row .bidder { color: #818cf8; font-weight: 600; }
        .modal-bid-row .amount { color: #34d399; font-weight: 700; font-size: 14px; }
        .modal-bid-row .time   { color: #475569; font-size: 11px; }
        .modal-bid-row.top-bid { background: rgba(52,211,153,0.05); }

        .modal-empty {
            padding: 32px;
            text-align: center;
            color: #334155;
            font-style: italic;
            font-size: 13px;
        }

        .btn-history {
            display: block;
            text-align: center;
            background: transparent;
            border: 1px solid #334155;
            color: #94a3b8;
            font-size: 12px;
            font-weight: 600;
            padding: 8px;
            border-radius: 50px;
            cursor: pointer;
            margin-top: 6px;
            width: 100%;
            transition: border-color 0.2s, color 0.2s;
        }
        .btn-history:hover { border-color: #818cf8; color: #818cf8; }
    </style>
</head>
<body>

<!-- Header -->
<header class="header">
    <a class="logo" href="DashboardServlet">E-<span>Auction</span></a>
    <div class="header-title">User Dashboard</div>
    <a href="addItem.jsp" class="btn-add">+ Add New Item</a>
    <div class="user-menu" id="userMenu">
        <button class="user-trigger" onclick="toggleDropdown()">
            <div class="avatar"><%= loggedInUser.getName().trim().substring(0,1).toUpperCase() %></div>
            <%= loggedInUser.getName() %>
            <span class="chevron">&#9660;</span>
        </button>
        <div class="dropdown">
            <div class="dropdown-header">
                <div class="name"><%= loggedInUser.getName() %></div>
                <div class="email"><%= loggedInUser.getEmail() %></div>
            </div>
            <a href="LogoutServlet">&#x2192; Logout</a>
        </div>
    </div>
</header>

<div class="dashboard-container">

    <!-- Sidebar -->
    <aside class="sidebar">
        <h3>Navigation</h3>
        <button class="menu-btn active" onclick="showSection('auctions', this)">
            <span class="menu-icon">🏷</span> Auctions
        </button>
        <button class="menu-btn" onclick="showSection('myBids', this)">
            <span class="menu-icon">🏹</span> My Bids
        </button>
        <button class="menu-btn" onclick="showSection('myWinnings', this)">
            <span class="menu-icon">🏆</span> My Winnings
        </button>
        <button class="menu-btn" onclick="showSection('myListings', this)">
            <span class="menu-icon">📦</span> My Listings
        </button>
    </aside>

    <!-- Main content -->
    <main class="main-content">

        <!-- TAB 1: Auctions -->
        <section id="auctions" class="content-section active-section">
            <div class="section-header">
                <h1>Auctions</h1>
                <p>Browse all items listed for auction. Filter by status below.</p>
            </div>

            <div class="filter-bar">
                <button class="filter-btn active" onclick="filterItems('all', this)">All</button>
                <button class="filter-btn" onclick="filterItems('active', this)">Active</button>
                <button class="filter-btn" onclick="filterItems('closed', this)">Closed</button>
            </div>

            <div class="items-grid" id="itemsGrid">
            <%
                if (allItems != null && !allItems.isEmpty()) {
                    for (Item item : allItems) {
                        boolean ended = item.getAuctionEndTime() != null && item.getAuctionEndTime().before(now);
                        String endFmt = item.getAuctionEndTime() != null ? sdf.format(item.getAuctionEndTime()) : "N/A";
            %>
                <div class="item-card <%= ended ? "ended" : "" %>" data-status="<%= ended ? "closed" : "active" %>">
                    <img class="item-image"
                         src="<%= request.getContextPath() %>/<%= (item.getItemPicture() != null && !item.getItemPicture().trim().isEmpty()) ? item.getItemPicture() : "images/placeholder.png" %>"
                         alt="<%= item.getItemName() %>"
                         onerror="this.onerror=null;this.src='https://via.placeholder.com/240x160?text=No+Image';" />
                    <div class="item-body">
                        <div style="display:flex;justify-content:space-between;align-items:center;">
                            <h3><%= item.getItemName() %></h3>
                            <span class="status-badge <%= ended ? "badge-ended" : "badge-active" %>"><%= ended ? "Closed" : "Active" %></span>
                        </div>
                        <p><%= item.getItemDescription() %></p>
                        <div class="item-price">₹<%= item.getStartingPrice() %></div>
                        <small>Seller: <%= item.getSellerEmail() %></small>
                        <% if (ended) { %>
                            <div class="countdown-ended">Ended: <%= endFmt %></div>
                            <button class="bid-btn-ended" disabled>Auction Closed</button>
                        <% } else if (item.getSellerEmail().equalsIgnoreCase(loggedInUser.getEmail())) { %>
                            <small style="color:#f59e0b;">⏰ Ends: <%= endFmt %></small>
                            <div class="countdown-box">
                                <span class="countdown-label">Time left:</span>
                                <span class="countdown-value"
                                      data-endtime="<%= item.getAuctionEndTime().getTime() %>"
                                      data-endfmt="<%= endFmt %>">--:--:--</span>
                            </div>
                            <button class="bid-btn-ended" disabled>Your Listing</button>
                        <% } else { %>
                            <small style="color:#f59e0b;">⏰ Ends: <%= endFmt %></small>
                            <div class="countdown-box">
                                <span class="countdown-label">Time left:</span>
                                <span class="countdown-value"
                                      data-endtime="<%= item.getAuctionEndTime().getTime() %>"
                                      data-endfmt="<%= endFmt %>">--:--:--</span>
                            </div>
                            <a class="bid-btn" href="bidItem.jsp?itemId=<%= item.getItemId() %>">Place Bid</a>
                        <% } %>
                        <button class="btn-history" onclick="openBidHistory(<%= item.getItemId() %>, '<%= item.getItemName().replace("'", "\\'") %>')">📋 Bid History</button>
                    </div>
                </div>
            <%
                    }
                } else {
            %>
                <p style="color:#334155;grid-column:1/-1;">No items listed for auction yet.</p>
            <%
                }
            %>
            </div>
        </section>

        <!-- TAB 2: My Bids -->
        <section id="myBids" class="content-section">
            <div class="section-header">
                <h1>My Bids</h1>
                <p>All bids you have placed across auctions.</p>
            </div>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Bid ID</th>
                            <th>Item</th>
                            <th>Bid Amount</th>
                            <th>Placed At</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (myBids != null && !myBids.isEmpty()) {
                            for (Bid bid : myBids) {
                    %>
                        <tr>
                            <td><span class="badge badge-blue">#<%= bid.getBidId() %></span></td>
                            <td><strong><%= bid.getItemName() %></strong></td>
                            <td style="color:#34d399;font-weight:700;">₹<%= bid.getBidAmount() %></td>
                            <td style="color:#475569;"><%= bid.getBidTime() %></td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr class="empty-row"><td colspan="4">You haven't placed any bids yet.</td></tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- TAB 3: My Winnings -->
        <section id="myWinnings" class="content-section">
            <div class="section-header">
                <h1>My Winnings</h1>
                <p>Auctions you have won.</p>
            </div>

            <%
                double totalWon = 0;
                int    wonCount = 0;
                if (myWinnings != null) {
                    for (AuctionResult ar : myWinnings) {
                        wonCount++;
                        totalWon += ar.getClosingBid();
                    }
                }
            %>

            <div class="summary-banner">
                <div class="summary-stat">
                    <h4>Auctions Won</h4>
                    <div class="val"><%= wonCount %></div>
                </div>
                <div class="summary-stat">
                    <h4>Total Spent</h4>
                    <div class="val">₹<%= String.format("%.0f", totalWon) %></div>
                </div>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Item</th>
                            <th>Seller</th>
                            <th>Starting Price</th>
                            <th>Winning Bid</th>
                            <th>Closed At</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (myWinnings != null && !myWinnings.isEmpty()) {
                            for (AuctionResult ar : myWinnings) {
                    %>
                        <tr>
                            <td><strong><%= ar.getItemName() %></strong><br><small style="color:#334155;">#<%= ar.getItemId() %></small></td>
                            <td style="color:#64748b;"><%= ar.getSellerEmail() %></td>
                            <td style="color:#94a3b8;">₹<%= ar.getStartingPrice() %></td>
                            <td style="color:#34d399;font-weight:700;">₹<%= ar.getClosingBid() %></td>
                            <td style="color:#475569;"><%= ar.getAuctionEndTime() != null ? sdf.format(ar.getAuctionEndTime()) : "—" %></td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr class="empty-row"><td colspan="5">You haven't won any auctions yet.</td></tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- TAB 4: My Listings -->
        <section id="myListings" class="content-section">
            <div class="section-header">
                <h1>My Listings</h1>
                <p>Items you have listed for auction.</p>
            </div>

            <%
                int ongoingCount  = 0;
                int soldCount     = 0;
                int unsoldCount   = 0;
                if (myListings != null) {
                    for (Item it : myListings) {
                        boolean ended = it.getAuctionEndTime() != null && it.getAuctionEndTime().before(now);
                        if (!ended) {
                            ongoingCount++;
                        } else if (it.getHighestBid() > 0) {
                            soldCount++;
                        } else {
                            unsoldCount++;
                        }
                    }
                }
            %>

            <div class="summary-banner">
                <div class="summary-stat">
                    <h4>Total Listed</h4>
                    <div class="val"><%= myListings != null ? myListings.size() : 0 %></div>
                </div>
                <div class="summary-stat">
                    <h4>Ongoing</h4>
                    <div class="val" style="color:#34d399;"><%= ongoingCount %></div>
                </div>
                <div class="summary-stat">
                    <h4>Completed</h4>
                    <div class="val" style="color:#60a5fa;"><%= soldCount %></div>
                </div>
                <div class="summary-stat">
                    <h4>Unsold</h4>
                    <div class="val" style="color:#f87171;"><%= unsoldCount %></div>
                </div>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Item</th>
                            <th>Starting Price</th>
                            <th>Highest Bid</th>
                            <th>Start Time</th>
                            <th>End Time</th>
                            <th>Status</th>
                            <th>Commission</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (myListings != null && !myListings.isEmpty()) {
                            for (Item it : myListings) {
                                boolean ended  = it.getAuctionEndTime() != null && it.getAuctionEndTime().before(now);
                                boolean hasBid = it.getHighestBid() > 0;

                                // Determine status string
                                String statusLabel;
                                String statusClass;
                                if (!ended) {
                                    statusLabel = "Ongoing";
                                    statusClass = "badge-green";
                                } else if (hasBid) {
                                    statusLabel = "Completed";
                                    statusClass = "badge-blue";
                                } else {
                                    statusLabel = "Unsold";
                                    statusClass = "badge-red";
                                }

                                // Match commission for this item
                                Commission comm = null;
                                if (myCommissions != null) {
                                    for (Commission c : myCommissions) {
                                        if (c.getItemId() == it.getItemId()) {
                                            comm = c;
                                            break;
                                        }
                                    }
                                }
                    %>
                        <tr>
                            <td>
                                <strong><%= it.getItemName() %></strong>
                            </td>
                            <td style="color:#94a3b8;">₹<%= it.getStartingPrice() %></td>
                            <td style="color:#34d399;font-weight:700;">
                                <%= hasBid ? "₹" + it.getHighestBid() : "—" %>
                            </td>
                            <td style="color:#475569;"><%= it.getAuctionStartTime() != null ? sdf.format(it.getAuctionStartTime()) : "—" %></td>
                            <td style="color:#475569;"><%= it.getAuctionEndTime()   != null ? sdf.format(it.getAuctionEndTime())   : "—" %></td>
                            <td><span class="badge <%= statusClass %>"><%= statusLabel %></span></td>
                            <td>
                                <% if (!ended) { %>
                                    <span style="color:#334155;font-size:12px;">Auction ongoing</span>
                                <% } else if (!hasBid) { %>
                                    <span style="color:#475569;font-size:12px;">No sale — no commission</span>
                                <% } else if (comm != null) { %>
                                    <span class="badge badge-amber">
                                        <%= comm.getCommissionPct() %>% — ₹<%= comm.getCommissionAmt() %>
                                    </span>
                                <% } else { %>
                                    <span class="badge badge-blue">Not generated yet</span>
                                <% } %>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr class="empty-row"><td colspan="7">You haven't listed any items yet.</td></tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </section>

    </main>
</div>

<!-- Bid History Modal -->
<div class="modal-overlay" id="bidHistoryModal" onclick="closeModalOnOverlay(event)">
    <div class="modal">
        <div class="modal-header">
            <div>
                <h3 id="modalTitle">Bid History</h3>
                <small id="modalSub"></small>
            </div>
            <button class="modal-close" onclick="closeModal()">✕</button>
        </div>
        <div class="modal-body" id="modalBody"></div>
    </div>
</div>

<script>
    // Embed all bids from server as a JS lookup: { itemId: [ {bidder, amount, time}, ... ] }
    const BID_DATA = {};
    <%
        List<Bid> allBids = (List<Bid>) request.getAttribute("allBids");
        if (allBids != null) {
            java.util.Map<Integer, java.util.List<Bid>> bidMap = new java.util.LinkedHashMap<>();
            for (Bid b : allBids) {
                bidMap.computeIfAbsent(b.getItemId(), k -> new java.util.ArrayList<>()).add(b);
            }
            for (java.util.Map.Entry<Integer, java.util.List<Bid>> entry : bidMap.entrySet()) {
                out.print("BID_DATA[" + entry.getKey() + "] = [");
                java.util.List<Bid> bids = entry.getValue();
                for (int i = 0; i < bids.size(); i++) {
                    Bid b = bids.get(i);
                    String bidder = b.getBidderEmail().replace("'", "\\'");
                    String time   = b.getBidTime() != null ? b.getBidTime().toString() : "";
                    out.print("{bidder:'" + bidder + "',amount:" + b.getBidAmount() + ",time:'" + time + "'}");
                    if (i < bids.size() - 1) out.print(",");
                }
                out.println("];");
            }
        }
    %>

    function openBidHistory(itemId, itemName) {
        const modal    = document.getElementById("bidHistoryModal");
        const title    = document.getElementById("modalTitle");
        const sub      = document.getElementById("modalSub");
        const body     = document.getElementById("modalBody");
        const bids     = BID_DATA[itemId] || [];

        title.textContent = itemName;

        if (bids.length === 0) {
            sub.textContent = "No bids placed yet";
            body.innerHTML  = '<div class="modal-empty">No bids have been placed on this item yet.</div>';
        } else {
            sub.textContent = bids.length + " bid" + (bids.length !== 1 ? "s" : "") + " placed";
            // Sort descending by amount so highest is first
            const sorted = bids.slice().sort(function(a, b) { return b.amount - a.amount; });
            let html = "";
            sorted.forEach(function(bid, idx) {
                html += '<div class="modal-bid-row' + (idx === 0 ? " top-bid" : "") + '">' +
                    '<div>' +
                        '<span class="bidder">' + bid.bidder + '</span>' +
                        (idx === 0 ? ' <span style="font-size:10px;color:#34d399;margin-left:6px;">▲ Highest</span>' : '') +
                    '</div>' +
                    '<div style="text-align:right;">' +
                        '<div class="amount">₹' + bid.amount + '</div>' +
                        '<div class="time">' + bid.time + '</div>' +
                    '</div>' +
                '</div>';
            });
            body.innerHTML = html;
        }

        modal.classList.add("open");
        document.body.style.overflow = "hidden";
    }

    function closeModal() {
        document.getElementById("bidHistoryModal").classList.remove("open");
        document.body.style.overflow = "";
    }

    function closeModalOnOverlay(e) {
        if (e.target === document.getElementById("bidHistoryModal")) closeModal();
    }

    document.addEventListener("keydown", function(e) {
        if (e.key === "Escape") closeModal();
    });
    function toggleDropdown() {
        document.getElementById("userMenu").classList.toggle("open");
    }
    document.addEventListener("click", function(e) {
        const menu = document.getElementById("userMenu");
        if (!menu.contains(e.target)) menu.classList.remove("open");
    });

    // Tab switching
    function showSection(id, btn) {
        document.querySelectorAll(".content-section").forEach(function(s) {
            s.classList.remove("active-section");
        });
        document.getElementById(id).classList.add("active-section");
        document.querySelectorAll(".menu-btn").forEach(function(b) {
            b.classList.remove("active");
        });
        btn.classList.add("active");
    }

    // Item filter
    function filterItems(status, btn) {
        document.querySelectorAll(".filter-btn").forEach(function(b) { b.classList.remove("active"); });
        btn.classList.add("active");
        document.querySelectorAll(".item-card").forEach(function(card) {
            if (status === "all" || card.dataset.status === status) {
                card.style.display = "flex";
            } else {
                card.style.display = "none";
            }
        });
    }

    // Countdown timers
    function pad(n) { return String(n).padStart(2, "0"); }

    function formatRemaining(ms) {
        if (ms <= 0) return null;
        const s = Math.floor(ms / 1000);
        const d = Math.floor(s / 86400);
        const h = Math.floor((s % 86400) / 3600);
        const m = Math.floor((s % 3600) / 60);
        const sec = s % 60;
        if (d > 0) return d + "d " + pad(h) + "h " + pad(m) + "m";
        return pad(h) + ":" + pad(m) + ":" + pad(sec);
    }

    function tickCountdowns() {
        const now = Date.now();
        document.querySelectorAll(".countdown-value[data-endtime]").forEach(function(el) {
            const endMs  = parseInt(el.getAttribute("data-endtime"), 10);
            const endFmt = el.getAttribute("data-endfmt");
            const rem    = endMs - now;

            if (rem <= 0) {
                const box = el.closest(".countdown-box");
                if (box) {
                    const d = document.createElement("div");
                    d.className = "countdown-ended";
                    d.textContent = "Ended: " + endFmt;
                    box.replaceWith(d);
                }
                const card = el.closest(".item-card");
                if (card) {
                    card.classList.add("ended");
                    card.dataset.status = "closed";
                    const btn = card.querySelector(".bid-btn");
                    if (btn) {
                        const dis = document.createElement("button");
                        dis.className = "bid-btn-ended";
                        dis.textContent = "Auction Closed";
                        dis.disabled = true;
                        btn.replaceWith(dis);
                    }
                    const sb = card.querySelector(".status-badge");
                    if (sb) { sb.className = "status-badge badge-ended"; sb.textContent = "Closed"; }
                }
            } else {
                el.textContent = formatRemaining(rem);
                el.classList.toggle("urgent", rem < 3600000);
            }
        });
    }

    tickCountdowns();
    setInterval(tickCountdowns, 1000);
</script>
</body>
</html>
