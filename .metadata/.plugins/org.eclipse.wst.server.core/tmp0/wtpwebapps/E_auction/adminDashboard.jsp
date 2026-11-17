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

    // Build a lookup map: itemId -> AuctionResult for enriching item rows
    java.util.Map<Integer, AuctionResult> arMap = new java.util.HashMap<>();
    if (completedWithBids != null) {
        for (AuctionResult ar : completedWithBids) {
            arMap.put(ar.getItemId(), ar);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin Dashboard - E-Auction</title>
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
        body { background:var(--bg); color:var(--ink); min-height:100vh; }

        .admin-header {
            background:var(--top); border-bottom:1.5px solid var(--line); padding:14px 28px;
            height:auto; display:flex; align-items:center; gap:16px; position:sticky; top:0; z-index:100;
        }
        .logo { font-size:25px; font-weight:800; color:var(--accent); text-decoration:none; letter-spacing:-0.5px; display:flex; align-items:center; gap:0; }
        .logo span { color:var(--ink); }
        .admin-title { flex:1; font-size:11px; color:var(--muted); letter-spacing:.18em; text-transform:uppercase; font-weight:700; }
        .admin-info { font-size:13px; color:var(--muted); }
        .admin-info strong { color:var(--accent); }
        .logout-btn { background:#fff; color:var(--bad); border:1.5px solid var(--bad); padding:8px 20px; border-radius:8px; cursor:pointer; font-size:13px; font-weight:700; transition:background 0.2s,color 0.2s; }
        .logout-btn:hover { background:var(--bad); color:#fff; }

        .dashboard-container { display:flex; min-height:calc(100vh - 57px); }

        .sidebar { width:250px; background:var(--side); padding:22px 16px; flex-shrink:0; border-right:1.5px solid var(--line); }
        .sidebar h3 { color:var(--muted); font-size:11px; text-transform:uppercase; letter-spacing:.18em; margin-bottom:16px; padding-left:12px; font-weight:700; }
        .menu-btn { width:100%; display:flex; align-items:center; gap:10px; background:transparent; color:var(--muted); border:none; text-align:left; padding:13px 16px; margin-bottom:4px; border-radius:10px; cursor:pointer; font-size:14.5px; font-weight:700; transition:background 0.15s,color 0.15s; }
        .menu-icon { display:none; }
        .menu-btn:hover { background:var(--head); color:var(--ink); }
        .menu-btn.active { background:var(--accent); color:#fff; }

        .main-content { flex:1; padding:22px 28px; overflow-x:auto; }
        .content-section { display:none; }
        .content-section.active-section { display:block; }

        .section-header { position:relative; overflow:hidden; background:var(--banner); border:1.5px solid var(--line); border-radius:10px; padding:16px 24px; margin-bottom:18px; }
        .section-header::before { content:''; position:absolute; top:-60px; right:-60px; width:170px; height:170px; border-radius:50%; background:var(--s1); opacity:0.5; pointer-events:none; }
        .section-header h1 { font-size:26px; font-weight:800; color:var(--ink); letter-spacing:-.03em; position:relative; z-index:1; }
        .section-header p { font-size:14px; color:var(--ink); opacity:0.72; margin-top:4px; position:relative; z-index:1; }

        /* Filter pills */
        .filter-bar { display:flex; gap:8px; margin-bottom:16px; flex-wrap:wrap; }
        .filter-pill { padding:7px 18px; border-radius:50px; border:1.5px solid var(--line); background:transparent; color:var(--muted); font-size:12px; font-weight:700; cursor:pointer; transition:all 0.15s; }
        .filter-pill:hover { border-color:var(--accent); color:var(--accent); }
        .filter-pill.active { background:var(--accent); border-color:var(--accent); color:#fff; }

        /* Stat cards */
        .stat-cards { display:grid; grid-template-columns:repeat(3,1fr); gap:16px; margin-bottom:28px; }
        .stat-card { background:var(--panel); padding:24px; border-radius:10px; border:1.5px solid var(--line); }
        .stat-card h3 { color:var(--muted); font-size:11px; text-transform:uppercase; letter-spacing:.12em; font-weight:800; margin-bottom:12px; }
        .stat-value { font-size:36px; font-weight:800; }
        .stat-card.blue .stat-value { color:var(--info); }
        .stat-card.green .stat-value { color:var(--good); }
        .stat-card.amber .stat-value { color:#b45309; }

        /* Table */
        .table-container { width:100%; border:1.5px solid var(--line); border-radius:10px; background:#fff; overflow-x:auto; margin-bottom:24px; }
        table { width:100%; table-layout:fixed; border-collapse:collapse; }
        th { background:var(--head); color:var(--ink); padding:15px 18px; text-align:left; font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:.12em; border-bottom:1.5px solid var(--line); }
        td { padding:16px 18px; border-bottom:1px solid var(--line2); font-size:14.5px; color:var(--ink); overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
        tr:last-child td { border-bottom:none; }
        tr.clickable-row { cursor:pointer; }
        tr.clickable-row td:first-child { border-left:5px solid transparent; }
        tr.clickable-row:hover td { background:var(--bg); }
        tr.clickable-row:hover td:first-child { border-left-color:var(--accent); }
        .empty-row td { text-align:center; color:var(--muted); padding:32px; font-style:italic; }

        .badge { display:inline-block; padding:4px 13px; border-radius:7px; font-size:12px; font-weight:800; }
        .badge-green { background:rgba(13,138,78,0.12); color:var(--good); border:1.5px solid var(--good); }
        .badge-amber { background:rgba(180,83,9,0.12); color:#b45309; border:1.5px solid #b45309; }
        .badge-blue  { background:rgba(37,99,235,0.12); color:var(--info); border:1.5px solid var(--info); }
        .badge-red   { background:rgba(211,48,59,0.12); color:var(--bad); border:1.5px solid var(--bad); }
        .badge-purple { background:rgba(109,40,217,0.12); color:#6d28d9; border:1.5px solid #6d28d9; }

        .commission-form { background:var(--panel); max-width:560px; padding:28px; border-radius:10px; border:1.5px solid var(--line); margin-bottom:24px; }
        .commission-form h2 { font-size:16px; font-weight:700; color:var(--ink); margin-bottom:20px; }
        .form-group { margin-bottom:18px; }
        .form-group label { display:block; margin-bottom:7px; font-weight:800; font-size:11px; color:var(--muted); text-transform:uppercase; letter-spacing:.12em; }
        .form-group input { width:100%; padding:11px 14px; border:1.5px solid var(--line); border-radius:8px; font-size:14px; outline:none; background:#fff; color:var(--ink); transition:border-color 0.2s; }
        .form-group input:focus { border-color:var(--accent); }
        .form-group input::placeholder { color:var(--muted); }
        .generate-btn { background:var(--accent); border:none; padding:12px 28px; border-radius:8px; cursor:pointer; font-weight:700; font-size:14px; color:#fff; transition:opacity 0.15s; }
        .generate-btn:hover { opacity:0.85; }

        /* Modal */
        .modal-overlay { display:none; position:fixed; inset:0; background:rgba(12,34,80,0.45); z-index:9000; align-items:center; justify-content:center; }
        .modal-overlay.open { display:flex; }
        .modal { background:#fff; border:1.5px solid var(--line); border-radius:10px; border-top:10px solid var(--accent); width:100%; max-width:880px; max-height:85vh; display:flex; flex-direction:column; overflow:hidden; }
        .modal-header { padding:20px 28px; border-bottom:1.5px solid var(--line2); display:flex; align-items:flex-start; justify-content:space-between; }
        .modal-header h3 { font-size:18px; font-weight:800; color:var(--ink); }
        .modal-header p { font-size:12px; color:var(--muted); margin-top:4px; }
        .modal-close { background:#fff; border:1.5px solid var(--line); color:var(--muted); border-radius:50%; width:32px; height:32px; font-size:16px; cursor:pointer; display:flex; align-items:center; justify-content:center; transition:border-color 0.2s,color 0.2s; flex-shrink:0; }
        .modal-close:hover { border-color:var(--bad); color:var(--bad); }
        .modal-body { overflow-y:auto; padding:24px 28px; display:flex; gap:24px; align-items:flex-start; }
        .modal-image-col { flex-shrink:0; width:280px; display:flex; flex-direction:column; }
        .modal-image-col img { width:100%; height:280px; object-fit:cover; border-radius:8px; border:1.5px solid var(--line); display:block; }
        .modal-image-col .no-img { width:100%; height:280px; border-radius:8px; background:var(--bg); border:1.5px dashed var(--line); display:flex; align-items:center; justify-content:center; color:var(--muted); font-size:13px; text-align:center; padding:12px; }
        .modal-details-col { flex:1; min-width:0; }
        .detail-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
        .detail-item { background:var(--bg); border-radius:8px; padding:12px 14px; border:1px solid var(--line2); }
        .detail-item .label { font-size:10px; color:var(--muted); text-transform:uppercase; letter-spacing:.12em; font-weight:800; margin-bottom:4px; }
        .detail-item .value { font-size:13.5px; color:var(--ink); font-weight:700; word-break:break-all; }
        .detail-item .value.green { color:var(--good); }
        .detail-item .value.amber { color:#b45309; }
        .detail-item .value.blue { color:var(--info); }
        .detail-item .value.red { color:var(--bad); }
        .detail-item .value.purple { color:#6d28d9; }
        .detail-full { grid-column:1/-1; }

        ::-webkit-scrollbar { width:5px; height:5px; }
        ::-webkit-scrollbar-track { background:var(--bg); }
        ::-webkit-scrollbar-thumb { background:var(--line); border-radius:10px; }

        @media (max-width:1000px) { .stat-cards { grid-template-columns:repeat(2,1fr); } }
        @media (max-width:860px) {
            .dashboard-container { flex-direction:column; }
            .sidebar { width:100%; flex-direction:row; overflow-x:auto; border-right:none; border-bottom:1.5px solid var(--line); padding:12px 8px; }
            .sidebar h3 { display:none; }
            .menu-btn { white-space:nowrap; margin-bottom:0; margin-right:4px; }
            .table-container { overflow-x:auto; }
            .modal { max-width:95vw; }
            .modal-body { flex-direction:column; align-items:center; gap:16px; }
            .modal-image-col { width:100%; max-width:280px; }
        }
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

    <!-- Sidebar — Auction Details removed, Item Details renamed to Auction Details -->
    <aside class="sidebar">
        <h3>Navigation</h3>
        <button class="menu-btn active" onclick="showSection('dashboard',  this)"><span class="menu-icon">📊</span> Dashboard</button>
        <button class="menu-btn"        onclick="showSection('users',       this)"><span class="menu-icon">👥</span> Users</button>
        <button class="menu-btn"        onclick="showSection('itemDetails', this)"><span class="menu-icon">🔨</span> Auction Details</button>
        <button class="menu-btn"        onclick="showSection('commission',  this)"><span class="menu-icon">💰</span> Generate Commission</button>
    </aside>

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

        <!-- Auction Details (merged Item Details + Auction Details) -->
        <section id="itemDetails" class="content-section">
            <div class="section-header">
                <h1>Auction Details</h1>
                <p>All auction items — click any row to view full details.</p>
            </div>

            <!-- Filter pills -->
            <div class="filter-bar">
                <button class="filter-pill active" onclick="filterRows('all',    this)">All</button>
                <button class="filter-pill"         onclick="filterRows('ongoing', this)">Ongoing</button>
                <button class="filter-pill"         onclick="filterRows('sold',    this)">Sold</button>
                <button class="filter-pill"         onclick="filterRows('unsold',  this)">Unsold</button>
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
                    <tbody id="auctionTableBody">
                    <%
                        java.util.List<Item> allItemsList = new java.util.ArrayList<>();
                        if (activeItems    != null) allItemsList.addAll(activeItems);
                        if (completedItems != null) allItemsList.addAll(completedItems);

                        if (!allItemsList.isEmpty()) {
                            for (Item it : allItemsList) {
                                boolean ended  = it.getAuctionEndTime() != null && it.getAuctionEndTime().before(now);
                                boolean hasBid = it.getHighestBid() > 0;

                                // Status
                                String statusLabel, statusClass, rowStatus;
                                if (!ended) {
                                    statusLabel = "Ongoing"; statusClass = "badge-green"; rowStatus = "ongoing";
                                } else if (hasBid) {
                                    statusLabel = "Sold";    statusClass = "badge-green"; rowStatus = "sold";
                                } else {
                                    statusLabel = "Unsold";  statusClass = "badge-red";   rowStatus = "unsold";
                                }

                                String startFmt = it.getAuctionStartTime() != null ? sdf.format(it.getAuctionStartTime()) : "—";
                                String endFmt   = it.getAuctionEndTime()   != null ? sdf.format(it.getAuctionEndTime())   : "—";

                                // Enrich with AuctionResult data if available
                                AuctionResult ar = arMap.get(it.getItemId());
                                String closingBid = (ar != null && ar.getClosingBid() > 0) ? String.valueOf(ar.getClosingBid()) : "";
                                String buyerEmail = (ar != null && ar.getBuyerEmail() != null) ? ar.getBuyerEmail() : "";

                                // Safe JS strings
                                String safeName   = it.getItemName().replace("'","&#39;").replace("\"","&quot;");
                                String safeSeller = it.getSellerEmail().replace("'","&#39;");
                                String safeDesc   = it.getItemDescription() != null ? it.getItemDescription().replace("'","&#39;").replace("\"","&quot;") : "";
                                String safeBuyer  = buyerEmail.replace("'","&#39;");
                                String safePic    = (it.getItemPicture() != null && !it.getItemPicture().trim().isEmpty()) ? it.getItemPicture() : "";
                    %>
                        <tr class="clickable-row"
                            data-status="<%= rowStatus %>"
                            data-id="<%= it.getItemId() %>"
                            data-name="<%= safeName %>"
                            data-seller="<%= safeSeller %>"
                            data-desc="<%= safeDesc %>"
                            data-price="<%= it.getStartingPrice() %>"
                            data-high="<%= hasBid ? it.getHighestBid() : "" %>"
                            data-closing="<%= closingBid %>"
                            data-buyer="<%= safeBuyer %>"
                            data-start="<%= startFmt %>"
                            data-end="<%= endFmt %>"
                            data-statuslabel="<%= statusLabel %>"
                            data-statusclass="<%= statusClass %>"
                            data-picture="<%= safePic %>"
                            onclick="openItemDetail(this)">
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
                            for (AuctionResult ar2 : completedWithBids) {
                                Commission existingComm = (commissionMap != null) ? commissionMap.get(ar2.getItemId()) : null;
                                double commAmt = Math.round(ar2.getClosingBid() * 5.0) / 100.0;
                    %>
                        <tr>
                            <td><strong><%= ar2.getItemName() %></strong></td>
                            <td style="color:#60a5fa;"><%= ar2.getSellerEmail() %></td>
                            <td style="color:#34d399;font-weight:700;">₹<%= ar2.getClosingBid() %></td>
                            <td style="color:#f59e0b;font-weight:700;">₹<%= commAmt %></td>
                            <td style="color:#475569;"><%= ar2.getAuctionEndTime() != null ? sdf.format(ar2.getAuctionEndTime()) : "—" %></td>
                            <td>
                                <% if (existingComm != null) { %>
                                    <span class="badge badge-green">Generated</span>
                                <% } else { %>
                                    <form action="GenerateCommissionServlet" method="POST" style="display:inline;">
                                        <input type="hidden" name="itemId"      value="<%= ar2.getItemId() %>" />
                                        <input type="hidden" name="sellerEmail" value="<%= ar2.getSellerEmail() %>" />
                                        <input type="hidden" name="saleAmount"  value="<%= ar2.getClosingBid() %>" />
                                        <button type="submit" class="generate-btn" style="padding:7px 18px;font-size:12px;">
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
                <h3 id="modalItemName"></h3>
                <p id="modalItemSub"></p>
            </div>
            <button class="modal-close" onclick="closeItemModal()">✕</button>
        </div>
        <div class="modal-body">
            <div class="modal-image-col">
                <img id="modalItemImg" src="" alt="Item" onerror="this.style.display='none';document.getElementById('modalNoImg').style.display='flex';" />
                <div id="modalNoImg" class="no-img" style="display:none;">No image available</div>
            </div>
            <div class="modal-details-col">
                <div class="detail-grid" id="modalDetailGrid"></div>
            </div>
        </div>
    </div>
</div>

<script>
    // Tab switching
    function showSection(id, btn) {
        document.querySelectorAll(".content-section").forEach(function(s) { s.classList.remove("active-section"); });
        document.getElementById(id).classList.add("active-section");
        document.querySelectorAll(".menu-btn").forEach(function(b) { b.classList.remove("active"); });
        btn.classList.add("active");
    }

    function confirmLogout() {
        if (confirm("Are you sure you want to logout?")) window.location.href = "LogoutServlet";
    }

    // Filter pills
    function filterRows(status, btn) {
        document.querySelectorAll(".filter-pill").forEach(function(b) { b.classList.remove("active"); });
        btn.classList.add("active");
        document.querySelectorAll("#auctionTableBody tr[data-status]").forEach(function(row) {
            row.style.display = (status === "all" || row.dataset.status === status) ? "" : "none";
        });
    }

    // Modal — reads data-* from the clicked <tr>
    function openItemDetail(row) {
        var d = row.dataset;
        document.getElementById("modalItemName").textContent = d.name;
        document.getElementById("modalItemSub").textContent  = "Item #" + d.id;

        // Image
        var imgEl   = document.getElementById("modalItemImg");
        var noImgEl = document.getElementById("modalNoImg");
        if (d.picture) {
            imgEl.src           = "<%= request.getContextPath() %>/" + d.picture;
            imgEl.style.display = "block";
            noImgEl.style.display = "none";
        } else {
            imgEl.style.display   = "none";
            noImgEl.style.display = "flex";
        }

        var statusColor = d.statusclass === "badge-green" ? "green" : d.statusclass === "badge-blue" ? "blue" : "red";
        var finalBid = d.closing || d.high;
        var closingDisplay = finalBid ? "₹" + finalBid : "No bids placed";
        var closingClass   = finalBid ? "green" : "red";
        var buyerDisplay   = d.buyer   ? d.buyer          : "No bids placed";
        var buyerClass     = d.buyer   ? "purple"          : "red";
        var descDisplay    = d.desc    ? d.desc            : "—";

        var html =
            '<div class="detail-item"><div class="label">Item ID</div><div class="value">#' + d.id + '</div></div>' +
            '<div class="detail-item"><div class="label">Status</div><div class="value ' + statusColor + '">' + d.statuslabel + '</div></div>' +
            '<div class="detail-item"><div class="label">Seller Email</div><div class="value blue">' + d.seller + '</div></div>' +
            '<div class="detail-item"><div class="label">Starting Price</div><div class="value green">₹' + d.price + '</div></div>' +
            '<div class="detail-item"><div class="label">Closing Bid</div><div class="value ' + closingClass + '">' + closingDisplay + '</div></div>' +
            '<div class="detail-item"><div class="label">Buyer Email</div><div class="value ' + buyerClass + '">' + buyerDisplay + '</div></div>' +
            '<div class="detail-item"><div class="label">Auction Start</div><div class="value">' + d.start + '</div></div>' +
            '<div class="detail-item"><div class="label">Auction End</div><div class="value">' + d.end + '</div></div>' +
            '<div class="detail-item detail-full"><div class="label">Description</div><div class="value" style="font-weight:400;color:#5d79ab;">' + (descDisplay || '—') + '</div></div>';

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
