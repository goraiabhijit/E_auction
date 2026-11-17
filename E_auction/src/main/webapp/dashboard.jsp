<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Date, java.text.SimpleDateFormat" %>
<%@ page import="com.eauction.model.Item, com.eauction.model.Bid, com.eauction.model.Commission, com.eauction.model.AuctionResult, com.eauction.model.User" %>
<%
    User loggedInUser = (User) session.getAttribute("currentUser");
    if (loggedInUser == null) { response.sendRedirect("signin.html"); return; }

    List<Item>          allItems      = (List<Item>)          request.getAttribute("allItems");
    List<Bid>           myBids        = (List<Bid>)           request.getAttribute("myBids");
    List<Bid>           allBids       = (List<Bid>)           request.getAttribute("allBids");
    List<Item>          myListings    = (List<Item>)          request.getAttribute("myListings");
    List<Commission>    myCommissions = (List<Commission>)    request.getAttribute("myCommissions");
    List<AuctionResult> myWinnings    = (List<AuctionResult>) request.getAttribute("myWinnings");

    String userEmail = loggedInUser.getEmail();
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy HH:mm");
    Date now = new Date();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Dashboard – E-Auction</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background: #f1f5f9; color: #333; display: flex; flex-direction: column; min-height: 100vh; }

        /* Header */
        header {
            background: #0f0f1a; color: #fff; height: 64px;
            padding: 0 24px; display: flex; justify-content: space-between;
            align-items: center; border-top: 3px solid #f59e0b;
            border-bottom: 1px solid #312e81;
            box-shadow: 0 3px 12px rgba(0,0,0,0.25);
            position: sticky; top: 0; z-index: 1000;
        }
        .logo { font-size: 24px; font-weight: bold; color: white; text-decoration: none; letter-spacing: -1px; }
        .logo span { color: #f59e0b; }
        .user-menu { position: relative; }
        .user-trigger {
            display: flex; align-items: center; gap: 8px;
            background: transparent; border: 1px solid #f59e0b;
            border-radius: 6px; padding: 7px 12px; color: white;
            font-size: 13px; font-weight: bold; cursor: pointer;
        }
        .user-trigger:hover { background: rgba(245,158,11,0.1); }
        .avatar {
            width: 26px; height: 26px; background: #f59e0b; color: #111827;
            border-radius: 50%; display: flex; align-items: center;
            justify-content: center; font-size: 12px; font-weight: bold;
        }
        .chevron { font-size: 10px; transition: transform 0.2s; }
        .user-menu.open .chevron { transform: rotate(180deg); }
        .dropdown {
            display: none; position: absolute; right: 0; top: calc(100% + 8px);
            background: #1e293b; border: 1px solid #334155; border-radius: 8px;
            min-width: 180px; box-shadow: 0 10px 30px rgba(0,0,0,0.4);
            overflow: hidden; z-index: 2000;
        }
        .user-menu.open .dropdown { display: block; }
        .dropdown-header { padding: 12px 16px; border-bottom: 1px solid #334155; }
        .dropdown-header .name  { font-weight: bold; font-size: 14px; color: white; }
        .dropdown-header .email { font-size: 11px; color: #9ca3af; margin-top: 2px; word-break: break-all; }
        .dropdown a { display: block; padding: 10px 16px; color: #f87171; font-size: 13px; text-decoration: none; border-top: 1px solid #334155; }
        .dropdown a:hover { background: rgba(248,113,113,0.1); }

        /* App shell */
        .app-shell { display: flex; flex: 1; }

        /* Sidebar */
        .sidebar {
            width: 220px; background: #1e1b4b; padding: 20px 10px;
            flex-shrink: 0; display: flex; flex-direction: column; gap: 4px;
            position: sticky; top: 64px; height: calc(100vh - 64px); overflow-y: auto;
        }
        .sidebar-label { color: #818cf8; font-size: 10px; text-transform: uppercase; letter-spacing: 1px; padding: 0 10px; margin-bottom: 6px; }
        .nav-btn {
            display: flex; align-items: center; gap: 10px;
            background: transparent; border: none; color: #a5b4fc;
            text-align: left; padding: 11px 12px; border-radius: 8px;
            cursor: pointer; font-size: 14px; width: 100%;
            transition: background 0.15s, color 0.15s;
        }
        .nav-btn:hover  { background: rgba(245,158,11,0.15); color: #f59e0b; }
        .nav-btn.active { background: #f59e0b; color: #111; border-radius: 999px; font-weight: bold; }
        .nav-icon { font-size: 16px; width: 20px; text-align: center; flex-shrink: 0; }

        /* Main */
        .main { flex: 1; padding: 24px; overflow-x: hidden; background: #f1f5f9; }
        .tab-panel { display: none; }
        .tab-panel.active { display: block; }

        .panel-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px; flex-wrap: wrap; gap: 10px; }
        .panel-header h2 { font-size: 20px; color: #111827; }
        .panel-header p  { font-size: 13px; color: #64748b; margin-top: 3px; }

        /* Buttons */
        .btn-primary {
            background: #f59e0b; color: #111827; padding: 9px 16px;
            border-radius: 999px; font-weight: bold; font-size: 13px;
            text-decoration: none; border: none; cursor: pointer; display: inline-block;
        }
        .btn-primary:hover { background: #d97706; color: white; }
        .btn-ghost {
            background: transparent; border: 1px solid #cbd5e1; color: #64748b;
            padding: 6px 12px; border-radius: 6px; font-size: 12px; cursor: pointer;
        }
        .btn-ghost:hover, .btn-ghost.active { border-color: #f59e0b; color: #f59e0b; background: rgba(245,158,11,0.08); }

        /* Item grid */
        .items-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 16px; }
        .item-card { background: white; border-radius: 16px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); overflow: hidden; display: flex; flex-direction: column; transition: transform 0.2s, box-shadow 0.2s; }
        .item-card:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.12); }
        .item-image { width: 100%; height: 160px; object-fit: cover; border-radius: 16px 16px 0 0; }
        .item-body  { padding: 12px; display: flex; flex-direction: column; gap: 5px; flex: 1; }
        .item-name  { font-size: 15px; font-weight: bold; color: #111827; }
        .item-desc  { font-size: 12px; color: #64748b; line-height: 1.4; }
        .item-price { font-size: 18px; font-weight: bold; color: #059669; }
        .item-meta  { font-size: 11px; color: #94a3b8; }
        .item-footer { padding: 10px 12px; border-top: 1px solid #f1f5f9; display: flex; gap: 8px; align-items: center; }

        .btn-bid         { flex: 1; text-align: center; background: #f59e0b; color: #111827; font-weight: bold; font-size: 13px; padding: 8px; border-radius: 999px; text-decoration: none; border: none; cursor: pointer; }
        .btn-bid:hover   { background: #d97706; color: white; }
        .btn-bid-off     { flex: 1; text-align: center; background: #e2e8f0; color: #94a3b8; font-weight: bold; font-size: 13px; padding: 8px; border-radius: 999px; border: none; cursor: not-allowed; filter: grayscale(1); opacity: 0.75; }
        .btn-bid-yours   { flex: 1; text-align: center; background: #dbeafe; color: #1e40af; font-weight: bold; font-size: 12px; padding: 8px; border-radius: 999px; border: none; }
        .btn-history     { background: transparent; border: 1px solid #e2e8f0; color: #64748b; font-size: 12px; padding: 7px 10px; border-radius: 999px; cursor: pointer; white-space: nowrap; }
        .btn-history:hover { border-color: #94a3b8; color: #374151; }

        /* Countdown */
        .countdown-box   { display: flex; align-items: center; justify-content: flex-end; gap: 5px; font-size: 11px; margin-top: 2px; }
        .countdown-label { color: #94a3b8; }
        .countdown-value { background: #111827; color: #f59e0b; padding: 2px 7px; border-radius: 4px; font-family: monospace; font-size: 11px; }
        .countdown-value.urgent { background: #dc2626; color: white; }
        .countdown-ended { font-size: 11px; color: #dc2626; font-weight: bold; text-align: right; }
        .ended-inline    { font-size: 11px; color: #dc2626; }

        /* Badge */
        .badge        { display: inline-block; padding: 3px 9px; border-radius: 999px; font-size: 11px; font-weight: bold; }
        .badge-green  { background: #dcfce7; color: #166534; }
        .badge-amber  { background: #fef3c7; color: #92400e; }
        .badge-blue   { background: #dbeafe; color: #1e40af; }
        .badge-red    { background: #fee2e2; color: #991b1b; }
        .badge-purple { background: #ede9fe; color: #5b21b6; }

        /* Bids table */
        .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,0.08); }
        .data-table th { background: #1e1b4b; color: white; padding: 12px 14px; text-align: left; font-size: 12px; }
        .data-table td { padding: 12px 14px; border-bottom: 1px solid #f1f5f9; font-size: 13px; }
        .data-table tr:last-child td { border-bottom: none; }
        .data-table tr:hover td { background: #f9fafb; }

        /* Commission panel */
        .comm-panel { background: white; border-radius: 16px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); overflow: hidden; margin-top: 24px; }
        .comm-panel-header { padding: 14px 16px; border-bottom: 1px solid #e2e8f0; font-weight: bold; font-size: 14px; color: white; background: #1e1b4b; border-radius: 16px 16px 0 0; }
        .comm-row { padding: 12px 16px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #374151; }
        .comm-row:last-child { border-bottom: none; }
        .comm-item { font-weight: bold; color: #111827; }
        .comm-amt  { color: #ef4444; font-weight: bold; }
        .comm-sale { color: #059669; font-weight: bold; }
        .comm-time { font-size: 11px; color: #94a3b8; display: block; margin-top: 2px; }
        .no-data   { padding: 24px; font-size: 13px; color: #94a3b8; text-align: center; }

        /* Bid History Modal */
        .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 3000; align-items: center; justify-content: center; }
        .modal-overlay.open { display: flex; }
        .modal { background: white; border-radius: 16px; width: 100%; max-width: 460px; max-height: 80vh; overflow-y: auto; box-shadow: 0 20px 60px rgba(0,0,0,0.3); margin: 20px; }
        .modal-header { padding: 16px 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; background: white; }
        .modal-header h3 { font-size: 16px; color: #111827; }
        .modal-close { background: none; border: none; font-size: 22px; color: #94a3b8; cursor: pointer; line-height: 1; }
        .modal-close:hover { color: #374151; }
        .modal-body { padding: 16px 20px; }
        .modal-bid-row { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid #f1f5f9; font-size: 13px; gap: 8px; }
        .modal-bid-row:last-child { border-bottom: none; }
        .modal-bid-left  { display: flex; flex-direction: column; gap: 2px; }
        .modal-bid-email { color: #374151; }
        .modal-bid-you   { color: #6366f1; font-weight: bold; }
        .modal-bid-time  { font-size: 11px; color: #94a3b8; }
        .modal-bid-amt   { color: #059669; font-weight: bold; font-size: 15px; white-space: nowrap; }
        .modal-loading   { padding: 24px; text-align: center; color: #94a3b8; font-size: 13px; }

        /* Stats banner */
        .stats-banner { background: #1e1b4b; color: white; border-radius: 16px; padding: 20px 28px; margin-bottom: 20px; display: flex; gap: 32px; align-items: center; }
        .stat-item { display: flex; flex-direction: column; }
        .stat-num { font-size: 28px; font-weight: bold; color: #f59e0b; }
        .stat-lbl { font-size: 12px; color: #a5b4fc; text-transform: uppercase; letter-spacing: 1px; }

        /* Filter row */
        .filter-row { display: flex; align-items: center; gap: 8px; margin-bottom: 16px; flex-wrap: wrap; }
        .filter-row span { font-size: 13px; color: #64748b; }

        /* Responsive */
        @media (max-width: 768px) {
            .sidebar { width: 58px; }
            .nav-btn span:not(.nav-icon) { display: none; }
            .sidebar-label { display: none; }
        }
        @media (max-width: 480px) {
            .sidebar { display: none; }
            .items-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<!-- Header -->
<header>
    <a class="logo" href="DashboardServlet">E-<span>Auction</span></a>
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

<div class="app-shell">

    <!-- Sidebar -->
    <nav class="sidebar">
        <div class="sidebar-label">Menu</div>
        <button class="nav-btn active" onclick="switchTab('live',       this)"><span class="nav-icon">🏷</span><span>Live Auctions</span></button>
        <button class="nav-btn"        onclick="switchTab('mybids',     this)"><span class="nav-icon">📋</span><span>My Bids</span></button>
        <button class="nav-btn"        onclick="switchTab('mylistings', this)"><span class="nav-icon">📦</span><span>My Listings</span></button>
    </nav>

    <!-- Main -->
    <div class="main">

        <%-- ══════════════════════════════════
             TAB 1 — Live Auctions
             ══════════════════════════════════ --%>
        <div class="tab-panel active" id="tab-live">
            <div class="panel-header">
                <div><h2>Live Auctions</h2><p>Browse and bid on active listings.</p></div>
            </div>

            <div class="filter-row">
                <span>Show:</span>
                <button class="btn-ghost active" id="f-active" onclick="filterAuctions('active', this)">Active</button>
                <button class="btn-ghost"        id="f-ended"  onclick="filterAuctions('ended',  this)">Ended</button>
                <button class="btn-ghost"        id="f-all"    onclick="filterAuctions('all',    this)">All</button>
            </div>

            <div class="stats-banner">
                <div class="stat-item">
                    <span class="stat-num"><%= allItems != null ? allItems.stream().filter(i -> i.getAuctionEndTime() != null && !i.getAuctionEndTime().before(now)).count() : 0 %></span>
                    <span class="stat-lbl">Active Auctions</span>
                </div>
                <div class="stat-item">
                    <span class="stat-num"><%= allItems != null ? allItems.size() : 0 %></span>
                    <span class="stat-lbl">Total Items</span>
                </div>
            </div>

            <div class="items-grid" id="auctionsGrid">
            <%
                if (allItems != null && !allItems.isEmpty()) {
                    for (Item item : allItems) {
                        boolean ended  = item.getAuctionEndTime() != null && item.getAuctionEndTime().before(now);
                        boolean isOwn  = item.getSellerEmail().equalsIgnoreCase(userEmail);
                        String  endFmt = item.getAuctionEndTime() != null ? sdf.format(item.getAuctionEndTime()) : "N/A";
                        long    endMs  = item.getAuctionEndTime() != null ? item.getAuctionEndTime().getTime() : 0;
            %>
                <div class="item-card" data-status="<%= ended ? "ended" : "active" %>">
                    <img class="item-image"
                         src="<%= request.getContextPath() %>/<%= (item.getItemPicture() != null && !item.getItemPicture().trim().isEmpty()) ? item.getItemPicture() : "images/placeholder.png" %>"
                         alt="<%= item.getItemName() %>"
                         onerror="this.onerror=null;this.src='https://via.placeholder.com/280x160?text=No+Image';" />
                    <div class="item-body">
                        <div class="item-name"><%= item.getItemName() %></div>
                        <div class="item-desc"><%= item.getItemDescription() %></div>
                        <div style="display:flex; flex-direction:column; gap:3px; margin-top:2px;">
                            <div style="font-size:12px; color:#94a3b8;">Starting Price: <span style="color:#374151; font-weight:bold;">₹<%= item.getStartingPrice() %></span></div>
                            <div style="font-size:13px;">
                                <% if (item.getHighestBid() > 0) { %>
                                    Current Bid: <span style="color:#059669; font-weight:bold; font-size:16px;">₹<%= item.getHighestBid() %></span>
                                <% } else { %>
                                    <span style="color:#94a3b8; font-size:12px;">No bids yet</span>
                                <% } %>
                            </div>
                        </div>
                        <div class="item-meta">Seller: <%= item.getSellerEmail() %></div>
                        <% if (ended) { %>
                            <div class="countdown-ended">Auction ended at <%= endFmt %></div>
                        <% } else { %>
                            <div class="item-meta">⏰ Ends: <%= endFmt %></div>
                            <div class="countdown-box">
                                <span class="countdown-label">Time left:</span>
                                <span class="countdown-value" data-endtime="<%= endMs %>" data-endfmt="<%= endFmt %>">--:--:--</span>
                            </div>
                        <% } %>
                    </div>
                    <div class="item-footer">
                        <% if (ended) { %>
                            <button class="btn-bid-off" onclick="alert('Auction ended on <%= endFmt %>')">Place Bid</button>
                        <% } else if (isOwn) { %>
                            <button class="btn-bid-yours">Your Listing</button>
                        <% } else { %>
                            <a class="btn-bid" href="bidItem.jsp?itemId=<%= item.getItemId() %>">Place Bid</a>
                        <% } %>
                        <button class="btn-history" onclick="openBidHistory(<%= item.getItemId() %>, '<%= item.getItemName().replace("'","\'") %>')">Bids</button>
                    </div>
                </div>
            <%
                    }
                } else {
            %>
                <p class="no-data">No auction items listed yet.</p>
            <%  } %>
            </div>
        </div>


        <%-- ══════════════════════════════════
             TAB 2 — My Bids
             ══════════════════════════════════ --%>
        <div class="tab-panel" id="tab-mybids">
            <div class="panel-header">
                <div><h2>My Bids</h2><p>All items you have placed bids on.</p></div>
            </div>

            <% if (myBids != null && !myBids.isEmpty()) { %>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Item</th>
                        <th>Your Bid</th>
                        <th>Current Highest</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    for (Bid bid : myBids) {
                        // Find matching item from allItems for auction status + highest bid
                        Item matchItem = null;
                        if (allItems != null) {
                            for (Item it : allItems) {
                                if (it.getItemId() == bid.getItemId()) { matchItem = it; break; }
                            }
                        }
                        boolean live        = matchItem != null && matchItem.getAuctionEndTime() != null && matchItem.getAuctionEndTime().after(now);
                        boolean over        = matchItem != null && matchItem.getAuctionEndTime() != null && matchItem.getAuctionEndTime().before(now);
                        double  highest     = matchItem != null ? matchItem.getHighestBid() : 0;
                        boolean isWinning   = live && bid.getBidAmount() >= highest;
                        boolean isOutbid    = live && bid.getBidAmount() < highest;
                        boolean hasWon      = over && bid.getBidAmount() >= highest && highest > 0;
                        boolean hasLost     = over && bid.getBidAmount() < highest;
                        String  bidFmt      = matchItem != null && matchItem.getAuctionEndTime() != null ? sdf.format(matchItem.getAuctionEndTime()) : "";
                %>
                <tr>
                    <td><strong><%= bid.getItemName() %></strong></td>
                    <td style="color:#059669; font-weight:bold;">₹<%= bid.getBidAmount() %></td>
                    <td><%= highest > 0 ? "₹" + highest : "—" %></td>
                    <td>
                        <% if (live) { %>
                            <span class="badge badge-amber">Ongoing</span>
                        <% } else if (over && highest > 0) { %>
                            <span class="badge badge-green">Completed</span>
                        <% } else { %>
                            <span class="badge badge-red">Unsold</span>
                        <% } %>
                    </td>
                    <td>
                        <% if (live && isOutbid) { %>
                            <a class="btn-primary" href="bidItem.jsp?itemId=<%= bid.getItemId() %>" style="font-size:12px; padding:6px 12px;">Bid Higher</a>
                        <% } else if (live && isWinning) { %>
                            <span style="font-size:12px; color:#94a3b8;">Leading</span>
                        <% } else { %>
                            <span style="font-size:12px; color:#94a3b8;"><%= bidFmt %></span>
                        <% } %>
                    </td>
                </tr>
                <%  } %>
                </tbody>
            </table>
            <% } else { %>
                <p class="no-data">You haven't placed any bids yet.</p>
            <% } %>

            <!-- My Winnings -->
            <% if (myWinnings != null && !myWinnings.isEmpty()) { %>
            <div style="margin-top: 32px;">
                <h3 style="font-size:17px; color:#111827; margin-bottom:14px;">🏆 My Winnings</h3>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Item</th>
                            <th>Seller</th>
                            <th>Winning Bid</th>
                            <th>Closed On</th>
                            <th>Amount Due</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (AuctionResult win : myWinnings) { %>
                        <tr>
                            <td><strong><%= win.getItemName() %></strong></td>
                            <td style="color:#64748b;"><%= win.getSellerEmail() %></td>
                            <td style="color:#059669; font-weight:bold;">₹<%= win.getClosingBid() %></td>
                            <td style="color:#94a3b8; font-size:12px;"><%= win.getAuctionEndTime() != null ? sdf.format(win.getAuctionEndTime()) : "—" %></td>
                            <td>
                                <span style="background:#fef3c7; color:#92400e; padding:4px 10px; border-radius:20px; font-size:12px; font-weight:bold;">
                                    ₹<%= win.getClosingBid() %> due
                                </span>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>


        <%-- ══════════════════════════════════
             TAB 3 — My Listings
             ══════════════════════════════════ --%>
        <div class="tab-panel" id="tab-mylistings">
            <div class="panel-header">
                <div><h2>My Listings</h2><p>Items you have listed for auction.</p></div>
                <a class="btn-primary" href="addItem.jsp">+ Add New Item</a>
            </div>

            <% if (myListings != null && !myListings.isEmpty()) { %>
            <div class="items-grid">
            <%
                for (Item item : myListings) {
                    boolean ended  = item.getAuctionEndTime() != null && item.getAuctionEndTime().before(now);
                    String  endFmt = item.getAuctionEndTime() != null ? sdf.format(item.getAuctionEndTime()) : "N/A";
                    long    endMs  = item.getAuctionEndTime() != null ? item.getAuctionEndTime().getTime() : 0;
            %>
                <div class="item-card">
                    <img class="item-image"
                         src="<%= request.getContextPath() %>/<%= (item.getItemPicture() != null && !item.getItemPicture().trim().isEmpty()) ? item.getItemPicture() : "images/placeholder.png" %>"
                         alt="<%= item.getItemName() %>"
                         onerror="this.onerror=null;this.src='https://via.placeholder.com/280x160?text=No+Image';" />
                    <div class="item-body">
                        <div class="item-name"><%= item.getItemName() %></div>
                        <div class="item-desc"><%= item.getItemDescription() %></div>
                        <div class="item-price">Starting: ₹<%= item.getStartingPrice() %></div>
                        <div class="item-meta">
                            <% if (item.getHighestBid() > 0) { %>
                                Highest bid: <strong style="color:#059669;">₹<%= item.getHighestBid() %></strong>
                            <% } else { %>
                                <span style="color:#ef4444;">No bids yet</span>
                            <% } %>
                        </div>
                        <% if (ended) { %>
                            <div class="ended-inline">⏰ Ended: <%= endFmt %></div>
                        <% } else { %>
                            <div class="item-meta">⏰ Ends: <%= endFmt %></div>
                            <div class="countdown-box">
                                <span class="countdown-label">Time left:</span>
                                <span class="countdown-value" data-endtime="<%= endMs %>" data-endfmt="<%= endFmt %>">--:--:--</span>
                            </div>
                        <% } %>
                    </div>
                    <div class="item-footer">
                        <% if (ended) { %>
                            <span class="badge <%= item.getHighestBid() > 0 ? "badge-green" : "badge-red" %>"><%= item.getHighestBid() > 0 ? "Completed" : "Unsold" %></span>
                        <% } else { %>
                            <span class="badge badge-amber">Ongoing</span>
                        <% } %>
                        <button class="btn-history" onclick="openBidHistory(<%= item.getItemId() %>, '<%= item.getItemName().replace("'","\'") %>')">Bid History</button>
                    </div>
                </div>
            <%  } %>
            </div>
            <% } else { %>
                <p class="no-data">You haven't listed any items yet. <a href="addItem.jsp" style="color:#f59e0b; font-weight:bold;">Add your first item →</a></p>
            <% } %>

            <!-- My Commissions -->
            <div class="comm-panel">
                <div class="comm-panel-header">💳 Platform Fee Due</div>
                <% if (myCommissions != null && !myCommissions.isEmpty()) {
                    for (Commission comm : myCommissions) { %>
                <div class="comm-row">
                    <span class="comm-item"><%= comm.getItemName() %></span>
                    &nbsp;—&nbsp; Sale: <span class="comm-sale">₹<%= comm.getSaleAmount() %></span>
                    &nbsp;—&nbsp; Commission (<%= comm.getCommissionPct() %>%): <span class="comm-amt">₹<%= comm.getCommissionAmt() %></span>
                    <span class="comm-time"><%= comm.getGeneratedAt() != null ? sdf.format(comm.getGeneratedAt()) : "" %></span>
                </div>
                <%  } %>
                <% } else { %>
                <div class="no-data">No commissions generated for your listings yet.</div>
                <% } %>
            </div>
        </div>

    </div><!-- /main -->
</div><!-- /app-shell -->


<!-- Bid History Modal -->
<div class="modal-overlay" id="bidModal" onclick="closeBidModal(event)">
    <div class="modal">
        <div class="modal-header">
            <h3 id="modalTitle">Bid History</h3>
            <button class="modal-close" onclick="closeBidModalDirect()">&#x2715;</button>
        </div>
        <div class="modal-body" id="modalBody">
            <div class="modal-loading">Loading...</div>
        </div>
    </div>
</div>


<script>
    /* ── Tab switching ── */
    function switchTab(id, btn) {
        document.querySelectorAll(".tab-panel").forEach(p => p.classList.remove("active"));
        document.querySelectorAll(".nav-btn").forEach(b => b.classList.remove("active"));
        document.getElementById("tab-" + id).classList.add("active");
        btn.classList.add("active");
    }

    /* ── Dropdown ── */
    function toggleDropdown() { document.getElementById("userMenu").classList.toggle("open"); }
    document.addEventListener("click", e => {
        const m = document.getElementById("userMenu");
        if (!m.contains(e.target)) m.classList.remove("open");
    });

    /* ── Auction filter ── */
    function filterAuctions(mode, btn) {
        document.querySelectorAll("#auctionsGrid .item-card").forEach(card => {
            const s = card.dataset.status;
            card.style.display = (mode === "all" || mode === s) ? "" : "none";
        });
        document.querySelectorAll(".filter-row .btn-ghost").forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
    }

    /* ── Countdown ── */
    function pad(n) { return String(n).padStart(2, "0"); }
    function formatRemaining(ms) {
        if (ms <= 0) return null;
        const s = Math.floor(ms / 1000);
        const d = Math.floor(s / 86400), h = Math.floor((s % 86400) / 3600),
              m = Math.floor((s % 3600) / 60), sc = s % 60;
        return d > 0 ? d + "d " + pad(h) + "h " + pad(m) + "m " + pad(sc) + "s"
                     : pad(h) + ":" + pad(m) + ":" + pad(sc);
    }
    function tickAllCountdowns() {
        const now = Date.now();
        document.querySelectorAll(".countdown-value[data-endtime]").forEach(el => {
            const endMs  = parseInt(el.getAttribute("data-endtime"), 10);
            const endFmt = el.getAttribute("data-endfmt");
            const rem    = endMs - now;
            if (rem <= 0) {
                const box = el.closest(".countdown-box");
                if (box) {
                    const d = document.createElement("div");
                    d.className = "countdown-ended";
                    d.textContent = "Auction ended at " + endFmt;
                    box.replaceWith(d);
                }
                const footer = el.closest(".item-card")?.querySelector(".item-footer");
                if (footer) {
                    const bidBtn = footer.querySelector(".btn-bid");
                    if (bidBtn) {
                        const off = document.createElement("button");
                        off.className = "btn-bid-off";
                        off.textContent = "Place Bid";
                        off.onclick = () => alert("Auction ended on " + endFmt);
                        bidBtn.replaceWith(off);
                    }
                }
            } else {
                el.textContent = formatRemaining(rem);
                if (rem < 3600000) el.classList.add("urgent");
            }
        });
    }
    tickAllCountdowns();
    setInterval(tickAllCountdowns, 1000);

    /* ── Bid History Modal ── */
    const bidData = {};
    <%
        if (allBids != null) {
            java.util.Map<Integer, java.util.List<Bid>> bidsByItem = new java.util.LinkedHashMap<>();
            for (Bid b : allBids) {
                bidsByItem.computeIfAbsent(b.getItemId(), k -> new java.util.ArrayList<>()).add(b);
            }
            for (java.util.Map.Entry<Integer, java.util.List<Bid>> entry : bidsByItem.entrySet()) {
                out.print("bidData[" + entry.getKey() + "] = [");
                for (Bid b : entry.getValue()) {
                    String safeEmail = b.getBidderEmail().replace("\\", "\\\\").replace("\"", "\\\"");
                    String safeTime  = sdf.format(b.getBidTime());
                    out.print("{email:\"" + safeEmail + "\",amt:" + b.getBidAmount() + ",time:\"" + safeTime + "\"},");
                }
                out.print("];");
            }
        }
    %>

    function openBidHistory(itemId, itemName) {
        document.getElementById("modalTitle").textContent = "Bid History \u2014 " + itemName;
        const body = document.getElementById("modalBody");
        const me   = "<%= userEmail.replace("\"","\\\"") %>";

        const bids = bidData[itemId];
        if (bids && bids.length > 0) {
            body.innerHTML = bids.map(function(b) {
                const isMe = b.email.toLowerCase() === me.toLowerCase();
                return '<div class="modal-bid-row">'
                     + '<div class="modal-bid-left">'
                     + '<span class="' + (isMe ? 'modal-bid-you' : 'modal-bid-email') + '">' + (isMe ? 'You' : b.email) + '</span>'
                     + '<span class="modal-bid-time">' + b.time + '</span>'
                     + '</div>'
                     + '<span class="modal-bid-amt">\u20B9' + b.amt + '</span>'
                     + '</div>';
            }).join("");
        } else {
            body.innerHTML = '<div class="modal-loading">No bids placed on this item yet.</div>';
        }
        document.getElementById("bidModal").classList.add("open");
    }

    function closeBidModal(e) {
        if (e.target === document.getElementById("bidModal")) closeBidModalDirect();
    }
    function closeBidModalDirect() {
        document.getElementById("bidModal").classList.remove("open");
    }
    document.addEventListener("keydown", e => { if (e.key === "Escape") closeBidModalDirect(); });
</script>

</body>
</html>
