<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.eauction.model.Admin" %>
<%@ page import="com.eauction.model.AuctionResult" %>
<%@ page import="com.eauction.model.Item" %>
<%@ page import="com.eauction.model.User" %>
<%@ page import="com.eauction.model.Commission" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Admin currentAdmin = (Admin) session.getAttribute("currentAdmin");
    if (currentAdmin == null) {
        response.sendRedirect("signin.html");
        return;
    }

    List<User>          allUsers          = (List<User>)          request.getAttribute("allUsers");
    List<Item>          activeItems       = (List<Item>)          request.getAttribute("activeItems");
    List<Item>          completedItems    = (List<Item>)          request.getAttribute("completedItems");
    List<AuctionResult> completedWithBids = (List<AuctionResult>) request.getAttribute("completedWithBids");
    Map<Integer,Commission> commissionMap = (Map<Integer,Commission>) request.getAttribute("commissionMap");

    int totalUsers     = (Integer) request.getAttribute("totalUsers");
    int activeCount    = (Integer) request.getAttribute("activeCount");
    int completedCount = (Integer) request.getAttribute("completedCount");

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy HH:mm");
    Date now = new Date();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin Dashboard - E-Auction</title>
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }

        body { background: #0f172a; color: #e2e8f0; min-height: 100vh; }

        /* Header */
        .admin-header {
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
        .admin-title { flex: 1; font-size: 12px; color: #334155; letter-spacing: 1.5px; text-transform: uppercase; }
        .admin-info { font-size: 13px; color: #64748b; }
        .admin-info strong { color: #f59e0b; }
        .logout-btn {
            background: transparent; color: #f87171;
            border: 1px solid #334155; padding: 8px 20px;
            border-radius: 50px; cursor: pointer;
            font-size: 13px; font-weight: 600;
            transition: background 0.2s, border-color 0.2s;
        }
        .logout-btn:hover { background: rgba(248,113,113,0.1); border-color: #f87171; }

        /* Layout */
        .dashboard-container { display: flex; min-height: calc(100vh - 68px); }

        /* Sidebar */
        .sidebar {
            width: 220px; background: #0f172a;
            padding: 28px 14px; flex-shrink: 0;
            border-right: 1px solid #1e293b;
        }
        .sidebar h3 {
            color: #334155; font-size: 10px;
            text-transform: uppercase; letter-spacing: 1.5px;
            margin-bottom: 16px; padding-left: 12px;
        }
        .menu-btn {
            width: 100%; display: flex; align-items: center; gap: 10px;
            background: transparent; color: #64748b;
            border: none; text-align: left; padding: 11px 14px;
            margin-bottom: 4px; border-radius: 14px;
            cursor: pointer; font-size: 13px; font-weight: 500;
            transition: background 0.2s, color 0.2s;
        }
        .menu-btn:hover  { background: #1e293b; color: #e2e8f0; }
        .menu-btn.active { background: #f59e0b; color: #111827; font-weight: 700; }
        .menu-icon { font-size: 15px; width: 20px; text-align: center; }

        /* Main */
        .main-content { flex: 1; padding: 2rem; overflow-x: auto; }
        .content-section { display: none; }
        .content-section.active-section { display: block; }

        .section-header { margin-bottom: 20px; }
        .section-header h1 { font-size: 22px; font-weight: 700; color: #f1f5f9; }
        .section-header p  { color: #475569; margin-top: 6px; font-size: 13px; }

        /* Stat cards */
        .stat-cards { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-bottom: 28px; }
        .stat-card  { background: #1e293b; padding: 24px; border-radius: 20px; border: 1px solid #334155; }
        .stat-card h3 { color: #64748b; font-size: 11px; text-transform: uppercase; letter-spacing: 0.8px; margin-bottom: 12px; }
        .stat-card .stat-value { font-size: 36px; font-weight: 800; }
        .stat-card.blue  .stat-value { color: #60a5fa; }
        .stat-card.green .stat-value { color: #34d399; }
        .stat-card.amber .stat-value { color: #f59e0b; }

        /* Table */
        .table-container { background: #1e293b; border-radius: 20px; overflow: hidden; border: 1px solid #334155; }
        table { width: 100%; border-collapse: collapse; min-width: 600px; }
        th {
            background: #0f172a; color: #94a3b8;
            padding: 14px 16px; text-align: left;
            font-size: 11px; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.8px;
        }
        td { padding: 13px 16px; border-bottom: 1px solid #0f172a; font-size: 13px; color: #cbd5e1; }
        tr:last-child td { border-bottom: none; }
        tr.clickable-row { cursor: pointer; }
        tr.clickable-row:hover td { background: rgba(245,158,11,0.05); }
        .empty-row td { text-align: center; color: #334155; padding: 32px; font-style: italic; }

        .badge { padding: 4px 12px; border-radius: 50px; font-size: 11px; font-weight: 700; display: inline-block; }
        .badge-green  { background: rgba(52,211,153,0.15);  color: #34d399; }
        .badge-amber  { background: rgba(245,158,11,0.15);  color: #f59e0b; }
        .badge-blue   { background: rgba(96,165,250,0.15);  color: #60a5fa; }
        .badge-red    { background: rgba(248,113,113,0.15); color: #f87171; }
        .badge-purple { background: rgba(167,139,250,0.15); color: #a78bfa; }

        /* Commission form */
        .commission-form {
            background: #1e293b; max-width: 560px;
            padding: 28px; border-radius: 20px;
            border: 1px solid #334155; margin-bottom: 24px;
        }
        .commission-form h2 { font-size: 16px; font-weight: 700; color: #f1f5f9; margin-bottom: 20px; }
        .form-group { margin-bottom: 18px; }
        .form-group label {
            display: block; margin-bottom: 7px;
            font-weight: 600; font-size: 11px;
            color: #94a3b8; text-transform: uppercase; letter-spacing: 0.5px;
        }
        .form-group input {
            width: 100%; padding: 11px 14px;
            border: 1px solid #334155; border-radius: 12px;
            font-size: 14px; outline: none;
            background: #0f172a; color: #e2e8f0;
            transition: border-color 0.2s;
        }
        .form-group input:focus { border-color: #f59e0b; }
        .form-group input::placeholder { color: #334155; }
        .generate-btn {
            background: #f59e0b; border: none; padding: 12px 28px;
            border-radius: 50px; cursor: pointer;
            font-weight: 700; font-size: 14px; color: #111827;
            transition: background 0.2s, transform 0.1s;
        }
        .generate-btn:hover { background: #d97706; transform: translateY(-1px); }

        /* Item Detail Modal */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,0.65); z-index: 9000;
            align-items: center; justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal {
            background: #1e293b; border: 1px solid #334155;
            border-radius: 24px; width: 100%; max-width: 580px;
            max-height: 85vh; display: flex; flex-direction: column;
            overflow: hidden; box-shadow: 0 24px 60px rgba(0,0,0,0.6);
        }
        .modal-header {
            padding: 22px 28px; border-bottom: 1px solid #334155;
            display: flex; align-items: flex-start; justify-content: space-between;
        }
        .modal-header h3  { font-size: 18px; font-weight: 700; color: #f1f5f9; }
        .modal-header p   { font-size: 12px; color: #475569; margin-top: 4px; }
        .modal-close {
            background: transparent; border: 1px solid #334155;
            color: #94a3b8; border-radius: 50%;
            width: 32px; height: 32px; font-size: 16px;
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            transition: border-color 0.2s, color 0.2s; flex-shrink: 0;
        }
        .modal-close:hover { border-color: #f87171; color: #f87171; }
        .modal-body { overflow-y: auto; padding: 24px 28px; }
        .detail-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 16px;
        }
        .detail-item { background: #0f172a; border-radius: 12px; padding: 14px 16px; }
        .detail-item .label { font-size: 10px; color: #475569; text-transform: uppercase; letter-spacing: 0.8px; margin-bottom: 6px; }
        .detail-item .value { font-size: 14px; color: #f1f5f9; font-weight: 600; word-break: break-all; }
        .detail-item .value.green  { color: #34d399; }
        .detail-item .value.amber  { color: #f59e0b; }
        .detail-item .value.blue   { color: #60a5fa; }
        .detail-item .value.red    { color: #f87171; }
        .detail-full { grid-column: 1 / -1; }

        /* Scrollbar */
        ::-webkit-scrollbar { width: 5px; height: 5px; }
        ::-webkit-scrollbar-track { background: #0f172a; }
        ::-webkit-scrollbar-thumb { background: #334155; border-radius: 10px; }

        @media (max-width: 1000px) { .stat-cards { grid-template-columns: repeat(2,1fr); } }
        @media (max-width: 700px)  { .stat-cards { grid-template-columns: 1fr; } }
        @media (max-width: 550px)  { .dashboard-container { flex-direction: column; } .sidebar { width: 100%; } }
    </style>
</head>
<body>

<header class="admin-header">
    <a class="logo" href="AdminDashboardServlet">E-<span>Auction</span></a>
    <div class="admin-title">Admin Panel</div>
    <div class="admin-info">Logged in as <strong><%= currentAdmin.getName() %></strong> &nbsp;|&nbsp; <%= currentAdmin.getEmail() %></div>
    <button class="logout-btn" onclick="confirmLogout()">Logout</button>
</header>

<div class="dashboard-container">

    <!-- Sidebar -->
    <aside class="sidebar">
        <h3>Navigation</h3>
        <button class="menu-btn active" onclick="showSection('dashboard',    this)"><span class="menu-icon">📊</span> Dashboard</button>
        <button class="menu-btn"        onclick="showSection('users',         this)"><span class="menu-icon">👥</span> Users</button>
        <button class="menu-btn"        onclick="showSection('itemDetails',   this)"><span class="menu-icon">🏷</span> Item Details</button>
        <button class="menu-btn"        onclick="showSection('auctionDetails',this)"><span class="menu-icon">🔨</span> Auction Details</button>
        <button class="menu-btn"        onclick="showSection('commission',    this)"><span class="menu-icon">💰</span> Generate Commission</button>
    </aside>

    <!-- Main -->
    <main class="main-content">

        <!-- Dashboard -->
        <section id="dashboard" class="content-section active-section">
            <div class="section-header">
                <h1>Dashboard</h1>
                <p>Overview of the E-Auction platform.</p>
            </div>
            <div class="stat-cards">
                <div class="stat-card blue">
                    <h3>Total Users</h3>
                    <div class="stat-value"><%= totalUsers %></div>
                </div>
                <div class="stat-card green">
                    <h3>Items Sold</h3>
                    <div class="stat-value"><%= completedCount %></div>
                </div>
                <div class="stat-card amber">
                    <h3>Active Auctions</h3>
                    <div class="stat-value"><%= activeCount %></div>
                </div>
            </div>
        </section>

        <!-- Users -->
        <section id="users" class="content-section">
            <div class="section-header">
                <h1>Users</h1>
                <p>All registered users on the platform.</p>
            </div>
            <div class="table-container">
                <table>
                    <thead><tr><th>Name</th><th>Email</th><th>Mobile</th><th>Address</th><th>Gender</th></tr></thead>
                    <tbody>
                    <% if (allUsers != null && !allUsers.isEmpty()) {
                           for (User u : allUsers) { %>
                        <tr>
                            <td><%= u.getName() %></td>
                            <td><%= u.getEmail() %></td>
                            <td><%= u.getMobile() %></td>
                            <td><%= u.getAddress() %></td>
                            <td><%= u.getGender() %></td>
                        </tr>
                    <% } } else { %>
                        <tr class="empty-row"><td colspan="5">No users registered yet.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- Item Details -->
        <section id="itemDetails" class="content-section">
            <div class="section-header">
                <h1>Item Details</h1>
                <p>All auction items — click a row to view full details.</p>
            </div>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Item ID</th>
                            <th>Item Name</th>
                            <th>Seller</th>
                            <th>Starting Price</th>
                            <th>Start Time</th>
                            <th>End Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        /* Merge active + completed into one loop for display */
                        java.util.List<Item> allItemsList = new java.util.ArrayList<>();
                        if (activeItems    != null) allItemsList.addAll(activeItems);
                        if (completedItems != null) allItemsList.addAll(completedItems);

                        if (!allItemsList.isEmpty()) {
                            for (Item it : allItemsList) {
                                boolean ended  = it.getAuctionEndTime() != null && it.getAuctionEndTime().before(now);
                                boolean hasBid = it.getHighestBid() > 0;

                                String statusLabel, statusClass;
                                if (!ended) {
                                    statusLabel = "Ongoing";   statusClass = "badge-green";
                                } else if (hasBid) {
                                    statusLabel = "Completed"; statusClass = "badge-blue";
                                } else {
                                    statusLabel = "Unsold";    statusClass = "badge-red";
                                }

                                String startFmt = it.getAuctionStartTime() != null ? sdf.format(it.getAuctionStartTime()) : "—";
                                String endFmt   = it.getAuctionEndTime()   != null ? sdf.format(it.getAuctionEndTime())   : "—";

                                // Build safe JS strings for the modal
                                String safeItemName = it.getItemName().replace("'","\\&#39;");
                                String safeSeller   = it.getSellerEmail().replace("'","\\&#39;");
                                String safeDesc     = it.getItemDescription() != null ? it.getItemDescription().replace("'","\\&#39;") : "—";
                                String highBidStr   = hasBid ? String.valueOf(it.getHighestBid()) : "No bids";
                    %>
                        <tr class="clickable-row"
                            onclick="openItemDetail({
                                id:    '<%= it.getItemId() %>',
                                name:  '<%= safeItemName %>',
                                seller:'<%= safeSeller %>',
                                desc:  '<%= safeDesc %>',
                                price: '<%= it.getStartingPrice() %>',
                                high:  '<%= highBidStr %>',
                                start: '<%= startFmt %>',
                                end:   '<%= endFmt %>',
                                status:'<%= statusLabel %>',
                                sClass:'<%= statusClass %>'
                            })">
                            <td>#<%= it.getItemId() %></td>
                            <td><strong><%= it.getItemName() %></strong></td>
                            <td style="color:#60a5fa;"><%= it.getSellerEmail() %></td>
                            <td>₹<%= it.getStartingPrice() %></td>
                            <td style="color:#475569;"><%= startFmt %></td>
                            <td style="color:#475569;"><%= endFmt %></td>
                            <td><span class="badge <%= statusClass %>"><%= statusLabel %></span></td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr class="empty-row"><td colspan="7">No items found.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- Auction Details -->
        <section id="auctionDetails" class="content-section">
            <div class="section-header">
                <h1>Auction Details</h1>
                <p>All completed auctions — closing bid, buyer, and seller information.</p>
            </div>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Item ID</th>
                            <th>Item Name</th>
                            <th>Seller Email</th>
                            <th>Starting Price</th>
                            <th>Closing Bid</th>
                            <th>Buyer Email</th>
                            <th>Closed At</th>
                            <th>Result</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (completedWithBids != null && !completedWithBids.isEmpty()) {
                            for (AuctionResult ar : completedWithBids) {
                                boolean hasBid2 = ar.getBuyerEmail() != null;
                    %>
                        <tr>
                            <td>#<%= ar.getItemId() %></td>
                            <td><strong><%= ar.getItemName() %></strong></td>
                            <td style="color:#60a5fa;"><%= ar.getSellerEmail() %></td>
                            <td>₹<%= ar.getStartingPrice() %></td>
                            <td style="color:#34d399;font-weight:700;"><%= hasBid2 ? "₹" + ar.getClosingBid() : "—" %></td>
                            <td style="color:#818cf8;"><%= hasBid2 ? ar.getBuyerEmail() : "—" %></td>
                            <td style="color:#475569;"><%= ar.getAuctionEndTime() != null ? sdf.format(ar.getAuctionEndTime()) : "—" %></td>
                            <td><span class="badge <%= hasBid2 ? "badge-green" : "badge-red" %>"><%= hasBid2 ? "Sold" : "Unsold" %></span></td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr class="empty-row"><td colspan="8">No completed auctions yet.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- Generate Commission -->
        <section id="commission" class="content-section">
            <div class="section-header">
                <h1>Generate Commission</h1>
                <p>Closed auctions with bids. Commission is fixed at 5% of the closing bid.</p>
            </div>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Item</th>
                            <th>Seller</th>
                            <th>Closing Bid</th>
                            <th>Commission (5%)</th>
                            <th>Closed At</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (completedWithBids != null && !completedWithBids.isEmpty()) {
                            for (AuctionResult ar : completedWithBids) {
                                Commission existingComm = (commissionMap != null) ? commissionMap.get(ar.getItemId()) : null;
                                double commAmt = Math.round(ar.getClosingBid() * 5.0) / 100.0;
                    %>
                        <tr>
                            <td><strong><%= ar.getItemName() %></strong></td>
                            <td style="color:#60a5fa;"><%= ar.getSellerEmail() %></td>
                            <td style="color:#34d399;font-weight:700;">₹<%= ar.getClosingBid() %></td>
                            <td style="color:#f59e0b;font-weight:700;">₹<%= commAmt %></td>
                            <td style="color:#475569;"><%= ar.getAuctionEndTime() != null ? sdf.format(ar.getAuctionEndTime()) : "—" %></td>
                            <td>
                                <% if (existingComm != null) { %>
                                    <span class="badge badge-green">Generated</span>
                                <% } else { %>
                                    <form action="GenerateCommissionServlet" method="POST" style="display:inline;">
                                        <input type="hidden" name="itemId"      value="<%= ar.getItemId() %>" />
                                        <input type="hidden" name="sellerEmail" value="<%= ar.getSellerEmail() %>" />
                                        <input type="hidden" name="saleAmount"  value="<%= ar.getClosingBid() %>" />
                                        <button type="submit" class="generate-btn" style="padding:7px 16px;font-size:12px;">
                                            Generate Commission
                                        </button>
                                    </form>
                                <% } %>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr class="empty-row"><td colspan="6">No closed auctions with bids yet.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

    </main>
</div>

<!-- Item Detail Modal -->
<div class="modal-overlay" id="itemDetailModal" onclick="closeModalOnOverlay(event)">
    <div class="modal">
        <div class="modal-header">
            <div>
                <h3 id="modalItemName">Item Name</h3>
                <p id="modalItemSub">Item details</p>
            </div>
            <button class="modal-close" onclick="closeItemModal()">✕</button>
        </div>
        <div class="modal-body">
            <div class="detail-grid" id="modalDetailGrid"></div>
        </div>
    </div>
</div>

<script>
    function showSection(id, btn) {
        document.querySelectorAll(".content-section").forEach(function(s) { s.classList.remove("active-section"); });
        document.getElementById(id).classList.add("active-section");
        document.querySelectorAll(".menu-btn").forEach(function(b) { b.classList.remove("active"); });
        btn.classList.add("active");
    }

    function confirmLogout() {
        if (confirm("Are you sure you want to logout?")) window.location.href = "LogoutServlet";
    }

    // Item Detail Modal
    function openItemDetail(d) {
        document.getElementById("modalItemName").textContent = d.name;
        document.getElementById("modalItemSub").textContent  = "Item #" + d.id;

        var statusColor = d.sClass === "badge-green" ? "green" : d.sClass === "badge-blue" ? "blue" : "red";

        var html =
            '<div class="detail-item"><div class="label">Item ID</div><div class="value">#' + d.id + '</div></div>' +
            '<div class="detail-item"><div class="label">Status</div><div class="value ' + statusColor + '">' + d.status + '</div></div>' +
            '<div class="detail-item"><div class="label">Seller Email</div><div class="value blue">' + d.seller + '</div></div>' +
            '<div class="detail-item"><div class="label">Starting Price</div><div class="value green">₹' + d.price + '</div></div>' +
            '<div class="detail-item"><div class="label">Highest Bid</div><div class="value ' + (d.high === "No bids" ? "red" : "green") + '">' + (d.high === "No bids" ? "No bids" : "₹" + d.high) + '</div></div>' +
            '<div class="detail-item"><div class="label">Auction Start</div><div class="value">' + d.start + '</div></div>' +
            '<div class="detail-item detail-full"><div class="label">Auction End</div><div class="value">' + d.end + '</div></div>' +
            '<div class="detail-item detail-full"><div class="label">Description</div><div class="value" style="font-weight:400;color:#94a3b8;">' + d.desc + '</div></div>';

        document.getElementById("modalDetailGrid").innerHTML = html;
        document.getElementById("itemDetailModal").classList.add("open");
        document.body.style.overflow = "hidden";
    }

    function closeItemModal() {
        document.getElementById("itemDetailModal").classList.remove("open");
        document.body.style.overflow = "";
    }

    function closeModalOnOverlay(e) {
        if (e.target === document.getElementById("itemDetailModal")) closeItemModal();
    }

    document.addEventListener("keydown", function(e) { if (e.key === "Escape") closeItemModal(); });

</script>
</body>
</html>
