<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.eauction.model.Admin" %>
<%@ page import="com.eauction.model.AuctionResult" %>
<%@ page import="com.eauction.model.Commission" %>
<%@ page import="com.eauction.model.Item" %>
<%@ page import="com.eauction.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
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
    Map<Integer, Commission> commissionMap = (Map<Integer, Commission>) request.getAttribute("commissionMap");

    int totalUsers     = request.getAttribute("totalUsers")     != null ? (Integer) request.getAttribute("totalUsers")     : 0;
    int activeCount    = request.getAttribute("activeCount")    != null ? (Integer) request.getAttribute("activeCount")    : 0;
    int completedCount = request.getAttribute("completedCount") != null ? (Integer) request.getAttribute("completedCount") : 0;

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin Dashboard - E-Auction</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: Arial, Helvetica, sans-serif; }

        body { background: #f1f5f9; color: #1f2937; }

        /* ── Header ── */
        .admin-header {
            height: 70px;
            background: #0f0f1a;
            color: white;
            display: flex;
            align-items: center;
            padding: 0 30px;
            gap: 20px;
            border-top: 3px solid #f59e0b;
            border-bottom: 1px solid #312e81;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .logo { font-size: 22px; font-weight: bold; color: #f59e0b; text-decoration: none; }
        .logo span { color: white; }

        .admin-title { flex: 1; font-size: 16px; color: #9ca3af; }

        .admin-info { font-size: 13px; color: #d1d5db; }
        .admin-info strong { color: #f59e0b; }

        .logout-btn {
            background: #ef4444;
            color: white;
            border: none;
            padding: 9px 18px;
            border-radius: 999px;
            cursor: pointer;
            font-size: 13px;
            font-weight: bold;
        }
        .logout-btn:hover { background: #dc2626; }

        /* ── Layout ── */
        .dashboard-container { display: flex; min-height: calc(100vh - 70px); }

        /* ── Sidebar ── */
        .sidebar { width: 240px; background: #1e1b4b; padding: 24px 12px; flex-shrink: 0; }

        .sidebar h3 { color: #818cf8; font-size: 11px; text-transform: uppercase;
                      letter-spacing: 1px; margin-bottom: 14px; padding-left: 10px; }

        .menu-btn {
            width: 100%;
            display: flex;
            align-items: center;
            gap: 10px;
            background: transparent;
            color: #a5b4fc;
            border: none;
            text-align: left;
            padding: 12px 14px;
            margin-bottom: 4px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            transition: background 0.2s, color 0.2s;
        }
        .menu-btn:hover { background: rgba(245,158,11,0.15); color: #f59e0b; }
        .menu-btn.active { background: #f59e0b; color: #111; border-radius: 999px; font-weight: bold; }

        .menu-icon { font-size: 16px; width: 20px; text-align: center; }

        /* ── Main content ── */
        .main-content { flex: 1; padding: 30px; overflow-x: auto; background: #f1f5f9; }

        .content-section { display: none; }
        .content-section.active-section { display: block; }

        .section-header { margin-bottom: 24px; }
        .section-header h1 { font-size: 24px; color: #1e1b4b; }
        .section-header p { color: #6b7280; margin-top: 6px; font-size: 14px; }

        /* ── Stat cards ── */
        .stat-cards {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 24px;
            border-radius: 16px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.07);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .stat-card:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.1); }

        .stat-card h3 { color: #6b7280; font-size: 13px; text-transform: uppercase;
                        letter-spacing: 0.5px; margin-bottom: 10px; }

        .stat-card .stat-value { font-size: 36px; font-weight: bold; color: #111827; }

        .stat-card.blue  { border-top: 4px solid #6366f1; }
        .stat-card.green { border-top: 4px solid #10b981; }
        .stat-card.amber { border-top: 4px solid #f59e0b; }

        /* ── Table ── */
        .table-container {
            background: white;
            border-radius: 16px;
            padding: 20px;
            overflow-x: auto;
            box-shadow: 0 2px 10px rgba(0,0,0,0.07);
        }

        table { width: 100%; border-collapse: collapse; min-width: 600px; }

        th {
            background: #1e1b4b;
            color: white;
            padding: 13px 14px;
            text-align: left;
            font-size: 13px;
            font-weight: bold;
        }

        td { padding: 12px 14px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #374151; }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: #f9fafb; }

        .empty-row td { text-align: center; color: #94a3b8; padding: 30px; font-style: italic; }

        .badge {
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: bold;
            display: inline-block;
        }
        .badge-green  { background: #dcfce7; color: #166534; }
        .badge-amber  { background: #fef3c7; color: #92400e; }
        .badge-blue   { background: #dbeafe; color: #1e40af; }
        .badge-red    { background: #fee2e2; color: #991b1b; }

        /* ── Commission form ── */
        .commission-form {
            background: white;
            max-width: 560px;
            padding: 28px;
            border-radius: 16px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.07);
            margin-bottom: 28px;
        }

        .commission-form h2 { font-size: 16px; color: #111827; margin-bottom: 20px; }

        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; margin-bottom: 6px; font-weight: bold;
                            font-size: 13px; color: #4f46e5; }
        .form-group input, .form-group select {
            width: 100%; padding: 10px 12px; border: 1px solid #d1d5db;
            border-radius: 6px; font-size: 14px; outline: none;
        }
        .form-group input:focus, .form-group select:focus {
            border-color: #6366f1;
            box-shadow: 0 0 0 2px rgba(99,102,241,0.15);
        }

        .generate-btn {
            background: #f59e0b; border: none; padding: 11px 22px;
            border-radius: 999px; cursor: pointer; font-weight: bold;
            font-size: 14px; color: #111827; transition: background 0.2s;
        }
        .generate-btn:hover { background: #d97706; color: white; }

        .commission-result {
            margin-top: 16px; padding: 14px; background: #f0fdf4;
            border: 1px solid #86efac; border-radius: 6px;
            font-size: 14px; color: #166534; display: none;
        }

        @media (max-width: 1000px) { .stat-cards { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 700px)  { .stat-cards { grid-template-columns: 1fr; }
                                     .sidebar { width: 200px; } }
        @media (max-width: 550px)  { .dashboard-container { flex-direction: column; }
                                     .sidebar { width: 100%; } }
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

    <!-- ── Sidebar ── -->
    <aside class="sidebar">
        <h3>Navigation</h3>
        <button class="menu-btn active" onclick="showSection('dashboard',    this)"><span class="menu-icon">📊</span> Dashboard</button>
        <button class="menu-btn"        onclick="showSection('users',         this)"><span class="menu-icon">👥</span> Users</button>
        <button class="menu-btn"        onclick="showSection('itemDetails',   this)"><span class="menu-icon">🏷</span> Item Details</button>
        <button class="menu-btn"        onclick="showSection('commission',    this)"><span class="menu-icon">💰</span> Generate Commission</button>
    </aside>

    <!-- ── Main ── -->
    <main class="main-content">

        <!-- Dashboard Section -->
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
                    <h3>Items Sold (Auction Completed)</h3>
                    <div class="stat-value"><%= completedCount %></div>
                </div>
                <div class="stat-card amber">
                    <h3>Items Currently in Auction</h3>
                    <div class="stat-value"><%= activeCount %></div>
                </div>
            </div>
        </section>

        <!-- Users Section -->
        <section id="users" class="content-section">
            <div class="section-header">
                <h1>Users</h1>
                <p>All registered users on the platform.</p>
            </div>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Mobile</th>
                            <th>Address</th>
                            <th>Gender</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (allUsers != null && !allUsers.isEmpty()) {
                                for (User u : allUsers) {
                        %>
                        <tr>
                            <td><%= u.getName() %></td>
                            <td><%= u.getEmail() %></td>
                            <td><%= u.getMobile() %></td>
                            <td><%= u.getAddress() %></td>
                            <td><%= u.getGender() %></td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr class="empty-row"><td colspan="5">No users registered yet.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- Item Details Section -->
        <section id="itemDetails" class="content-section">
            <div class="section-header">
                <h1>Item Details</h1>
                <p>All auction items — completed and in progress.</p>
            </div>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Item ID</th>
                            <th>Item Name</th>
                            <th>Seller</th>
                            <th>Starting Price</th>
                            <th>Highest Bid</th>
                            <th>End Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (activeItems != null && !activeItems.isEmpty()) {
                                for (Item it : activeItems) {
                        %>
                        <tr>
                            <td>#<%= it.getItemId() %></td>
                            <td><strong><%= it.getItemName() %></strong></td>
                            <td><%= it.getSellerEmail() %></td>
                            <td>₹<%= it.getStartingPrice() %></td>
                            <td><%= it.getHighestBid() > 0 ? "₹" + it.getHighestBid() : "<span class=\"badge badge-red\">No bids</span>" %></td>
                            <td><%= it.getAuctionEndTime() != null ? sdf.format(it.getAuctionEndTime()) : "—" %></td>
                            <td><span class="badge badge-amber">Active</span></td>
                        </tr>
                        <%
                                }
                            }
                            if (completedItems != null && !completedItems.isEmpty()) {
                                for (Item it : completedItems) {
                        %>
                        <tr>
                            <td>#<%= it.getItemId() %></td>
                            <td><strong><%= it.getItemName() %></strong></td>
                            <td><%= it.getSellerEmail() %></td>
                            <td>₹<%= it.getStartingPrice() %></td>
                            <td><%= it.getHighestBid() > 0 ? "₹" + it.getHighestBid() : "<span class=\"badge badge-red\">No bids</span>" %></td>
                            <td><%= it.getAuctionEndTime() != null ? sdf.format(it.getAuctionEndTime()) : "—" %></td>
                            <td>
                                <% if (it.getHighestBid() > 0) { %>
                                    <span class="badge badge-green">Completed</span>
                                <% } else { %>
                                    <span class="badge badge-red">Unsold</span>
                                <% } %>
                            </td>
                        </tr>
                        <%
                                }
                            }
                            if ((activeItems == null || activeItems.isEmpty()) &&
                                (completedItems == null || completedItems.isEmpty())) {
                        %>
                        <tr class="empty-row"><td colspan="7">No items found.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- Generate Commission Section -->
        <section id="commission" class="content-section">
            <div class="section-header">
                <h1>Generate Commission</h1>
                <p>Completed auctions with bids. Commission rate: <strong>5%</strong> of closing bid.</p>
            </div>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Item ID</th>
                            <th>Item Name</th>
                            <th>Seller Email</th>
                            <th>Closing Bid</th>
                            <th>Commission (5%)</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (completedWithBids != null && !completedWithBids.isEmpty()) {
                            for (AuctionResult ar : completedWithBids) {
                                Commission existing = commissionMap != null ? commissionMap.get(ar.getItemId()) : null;
                                double commAmt = Math.round(ar.getClosingBid() * 5.0) / 100.0;
                    %>
                        <tr>
                            <td>#<%= ar.getItemId() %></td>
                            <td><strong><%= ar.getItemName() %></strong></td>
                            <td><%= ar.getSellerEmail() %></td>
                            <td>₹<%= ar.getClosingBid() %></td>
                            <td>₹<%= commAmt %></td>
                            <td>
                                <% if (existing != null) { %>
                                    <span class="badge badge-green">
                                        ✓ ₹<%= existing.getCommissionAmt() %> on <%= sdf.format(existing.getGeneratedAt()) %>
                                    </span>
                                <% } else { %>
                                    <form action="GenerateCommissionServlet" method="POST" style="margin:0;">
                                        <input type="hidden" name="itemId"      value="<%= ar.getItemId() %>" />
                                        <input type="hidden" name="sellerEmail" value="<%= ar.getSellerEmail() %>" />
                                        <input type="hidden" name="saleAmount"  value="<%= ar.getClosingBid() %>" />
                                        <button type="submit" class="generate-btn" style="padding:6px 14px; font-size:12px;">
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
                        <tr class="empty-row">
                            <td colspan="6">No completed auctions with bids found.</td>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </section>

    </main>
</div>

<script>
    // ── Tab switching ──
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

    // ── Logout ──
    function confirmLogout() {
        if (confirm("Are you sure you want to logout?")) {
            window.location.href = "LogoutServlet";
        }
    }
</script>

</body>
</html>
