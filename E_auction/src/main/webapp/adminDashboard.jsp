<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.eauction.model.Admin" %>
<%@ page import="com.eauction.model.AuctionResult" %>
<%@ page import="com.eauction.model.Item" %>
<%@ page import="com.eauction.model.User" %>
<%@ page import="java.util.List" %>
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
    List<AuctionResult> completedAuctions = (List<AuctionResult>) request.getAttribute("completedAuctions");

    int totalUsers     = (Integer) request.getAttribute("totalUsers");
    int activeCount    = (Integer) request.getAttribute("activeCount");
    int completedCount = (Integer) request.getAttribute("completedCount");

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

        body { background: #f4f6f9; color: #1f2937; }

        /* ── Header ── */
        .admin-header {
            height: 70px;
            background: #101827;
            color: white;
            display: flex;
            align-items: center;
            padding: 0 30px;
            gap: 20px;
            border-top: 3px solid #f59e0b;
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
            border-radius: 6px;
            cursor: pointer;
            font-size: 13px;
            font-weight: bold;
        }
        .logout-btn:hover { background: #dc2626; }

        /* ── Layout ── */
        .dashboard-container { display: flex; min-height: calc(100vh - 70px); }

        /* ── Sidebar ── */
        .sidebar { width: 240px; background: #111827; padding: 24px 12px; flex-shrink: 0; }

        .sidebar h3 { color: #9ca3af; font-size: 11px; text-transform: uppercase;
                      letter-spacing: 1px; margin-bottom: 14px; padding-left: 10px; }

        .menu-btn {
            width: 100%;
            display: flex;
            align-items: center;
            gap: 10px;
            background: transparent;
            color: #d1d5db;
            border: none;
            text-align: left;
            padding: 12px 14px;
            margin-bottom: 4px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            transition: background 0.2s, color 0.2s;
        }
        .menu-btn:hover { background: rgba(245,158,11,0.1); color: #f59e0b; }
        .menu-btn.active { background: #f59e0b; color: #111827; font-weight: bold; }

        .menu-icon { font-size: 16px; width: 20px; text-align: center; }

        /* ── Main content ── */
        .main-content { flex: 1; padding: 30px; overflow-x: auto; }

        .content-section { display: none; }
        .content-section.active-section { display: block; }

        .section-header { margin-bottom: 24px; }
        .section-header h1 { font-size: 24px; color: #111827; }
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
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.07);
            border-left: 4px solid #f59e0b;
        }

        .stat-card h3 { color: #6b7280; font-size: 13px; text-transform: uppercase;
                        letter-spacing: 0.5px; margin-bottom: 10px; }

        .stat-card .stat-value { font-size: 32px; font-weight: bold; color: #111827; }

        .stat-card.blue  { border-left-color: #3b82f6; }
        .stat-card.green { border-left-color: #10b981; }
        .stat-card.amber { border-left-color: #f59e0b; }

        /* ── Table ── */
        .table-container {
            background: white;
            border-radius: 10px;
            padding: 20px;
            overflow-x: auto;
            box-shadow: 0 2px 10px rgba(0,0,0,0.07);
        }

        table { width: 100%; border-collapse: collapse; min-width: 600px; }

        th {
            background: #101827;
            color: white;
            padding: 13px 14px;
            text-align: left;
            font-size: 13px;
            font-weight: bold;
        }

        td { padding: 12px 14px; border-bottom: 1px solid #e5e7eb; font-size: 13px; color: #374151; }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: #f9fafb; }

        .empty-row td { text-align: center; color: #94a3b8; padding: 30px; font-style: italic; }

        .badge {
            padding: 4px 10px;
            border-radius: 20px;
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
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.07);
            margin-bottom: 28px;
        }

        .commission-form h2 { font-size: 16px; color: #111827; margin-bottom: 20px; }

        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; margin-bottom: 6px; font-weight: bold;
                            font-size: 13px; color: #374151; }
        .form-group input, .form-group select {
            width: 100%; padding: 10px 12px; border: 1px solid #d1d5db;
            border-radius: 6px; font-size: 14px; outline: none;
        }
        .form-group input:focus, .form-group select:focus { border-color: #f59e0b; }

        .generate-btn {
            background: #f59e0b; border: none; padding: 11px 22px;
            border-radius: 6px; cursor: pointer; font-weight: bold;
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
        <button class="menu-btn"        onclick="showSection('auctionDetails',this)"><span class="menu-icon">🔨</span> Auction Details</button>
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
                            <td>—</td>
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
                            <td>—</td>
                            <td><%= it.getAuctionEndTime() != null ? sdf.format(it.getAuctionEndTime()) : "—" %></td>
                            <td><span class="badge badge-green">Completed</span></td>
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

        <!-- Auction Details Section -->
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
                        if (completedAuctions != null && !completedAuctions.isEmpty()) {
                            for (AuctionResult ar : completedAuctions) {
                                boolean hasBid = ar.getBuyerEmail() != null;
                    %>
                        <tr>
                            <td>#<%= ar.getItemId() %></td>
                            <td><strong><%= ar.getItemName() %></strong></td>
                            <td><%= ar.getSellerEmail() %></td>
                            <td>₹<%= ar.getStartingPrice() %></td>
                            <td><%= hasBid ? "₹" + ar.getClosingBid() : "—" %></td>
                            <td><%= hasBid ? ar.getBuyerEmail() : "—" %></td>
                            <td><%= ar.getAuctionEndTime() != null ? sdf.format(ar.getAuctionEndTime()) : "—" %></td>
                            <td>
                                <% if (hasBid) { %>
                                    <span class="badge badge-green">Sold</span>
                                <% } else { %>
                                    <span class="badge badge-red">Unsold</span>
                                <% } %>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr class="empty-row">
                            <td colspan="8">No completed auctions yet.</td>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- Generate Commission Section -->
        <section id="commission" class="content-section">
            <div class="section-header">
                <h1>Generate Commission</h1>
                <p>Calculate and record commission for completed auctions.</p>
            </div>

            <div class="commission-form">
                <h2>Commission Calculator</h2>

                <div class="form-group">
                    <label for="sellerEmail">Seller Email</label>
                    <input type="email" id="sellerEmail" placeholder="Enter seller email" />
                </div>

                <div class="form-group">
                    <label for="saleAmount">Sale Amount (₹)</label>
                    <input type="number" id="saleAmount" placeholder="Enter sale amount" min="0" />
                </div>

                <div class="form-group">
                    <label for="commissionRate">Commission Percentage (%)</label>
                    <input type="number" id="commissionRate" placeholder="e.g. 5" min="0" max="100" />
                </div>

                <button class="generate-btn" onclick="generateCommission()">Generate Commission</button>

                <div class="commission-result" id="commissionResult"></div>
            </div>

            <!-- Commission log table -->
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Seller Email</th>
                            <th>Sale Amount</th>
                            <th>Commission %</th>
                            <th>Commission Amount</th>
                            <th>Generated On</th>
                        </tr>
                    </thead>
                    <tbody id="commissionTable">
                        <tr class="empty-row" id="commissionEmptyRow">
                            <td colspan="6">No commissions generated yet.</td>
                        </tr>
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

    // ── Commission generator ──
    let commissionCount = 0;

    function generateCommission() {
        const email          = document.getElementById("sellerEmail").value.trim();
        const saleAmount     = parseFloat(document.getElementById("saleAmount").value);
        const commissionRate = parseFloat(document.getElementById("commissionRate").value);
        const result         = document.getElementById("commissionResult");

        if (!email) {
            showResult(result, "Please enter a seller email.", false); return;
        }
        if (isNaN(saleAmount) || saleAmount <= 0) {
            showResult(result, "Please enter a valid sale amount.", false); return;
        }
        if (isNaN(commissionRate) || commissionRate <= 0 || commissionRate > 100) {
            showResult(result, "Commission percentage must be between 1 and 100.", false); return;
        }

        const commissionAmount = (saleAmount * commissionRate / 100).toFixed(2);

        showResult(result,
            "Sale Amount: ₹" + saleAmount.toFixed(2) +
            " &nbsp;|&nbsp; Rate: " + commissionRate + "%" +
            " &nbsp;|&nbsp; Commission: <strong>₹" + commissionAmount + "</strong>",
            true
        );

        // Add to table
        commissionCount++;
        const emptyRow = document.getElementById("commissionEmptyRow");
        if (emptyRow) emptyRow.remove();

        const tbody = document.getElementById("commissionTable");
        const today = new Date();
        const dateStr = String(today.getDate()).padStart(2,"0") + " " +
                        today.toLocaleString("default", { month: "short" }) + " " +
                        today.getFullYear() + " " +
                        String(today.getHours()).padStart(2,"0") + ":" +
                        String(today.getMinutes()).padStart(2,"0");

        const row = tbody.insertRow(0);
        row.innerHTML =
            "<td>" + commissionCount + "</td>" +
            "<td>" + email + "</td>" +
            "<td>₹" + saleAmount.toFixed(2) + "</td>" +
            "<td>" + commissionRate + "%</td>" +
            "<td><strong>₹" + commissionAmount + "</strong></td>" +
            "<td>" + dateStr + "</td>";
    }

    function showResult(el, msg, success) {
        el.innerHTML = msg;
        el.style.display = "block";
        el.style.background  = success ? "#f0fdf4" : "#fee2e2";
        el.style.borderColor = success ? "#86efac" : "#fca5a5";
        el.style.color       = success ? "#166534" : "#991b1b";
    }
</script>

</body>
</html>
