<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.eauction.model.User" %>
<%@ page import="com.eauction.model.Item" %>
<%@ page import="com.eauction.dao.ItemDao" %>
<%@ page import="com.eauction.dao.BidDao" %>
<%
    User loggedInUser = (User) session.getAttribute("currentUser");
    if (loggedInUser == null) {
        response.sendRedirect("signin.html");
        return;
    }

    String itemIdStr = request.getParameter("itemId");
    if (itemIdStr == null) {
        response.sendRedirect("DashboardServlet");
        return;
    }

    int itemId = Integer.parseInt(itemIdStr);
    ItemDao itemDao = new ItemDao();
    Item item = itemDao.getItemById(itemId);

    if (item == null) {
        response.sendRedirect("DashboardServlet");
        return;
    }

    // Fetch current highest bid
    BidDao bidDao = new BidDao();
    double currentHighestBid = bidDao.getHighestBid(itemId);
    
    // Determine minimum bid required (max of starting price and current highest bid)
    double minBidRequired = Math.max(item.getStartingPrice(), currentHighestBid);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Place Bid – <%= item.getItemName() %></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@500;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg:#eef5ff; --top:#d9e8ff; --side:#fff; --panel:#fff; --ink:#0c2250; --muted:#5d79ab;
            --line:#9bbdf2; --line2:#dce8fb; --accent:#2563eb; --on:#fff; --head:#e4efff; --banner:#cfe2ff;
            --s1:#ffd966; --good:#0d8a4e; --bad:#d3303b; --info:#2563eb; --link:#2563eb;
        }
        * { margin:0; padding:0; box-sizing:border-box; font-family:'Manrope','Segoe UI',system-ui,sans-serif; }
        *:focus-visible { outline:2px solid var(--accent); outline-offset:2px; }
        body { background:var(--bg); color:var(--ink); min-height:100vh; display:flex; flex-direction:column; }

        header { background:var(--top); height:auto; padding:14px 7%; display:flex; align-items:center; justify-content:space-between; border-bottom:1.5px solid var(--line); position:sticky; top:0; z-index:100; }
        .logo { font-size:25px; font-weight:800; color:var(--accent); text-decoration:none; letter-spacing:-0.5px; }
        .logo span { color:var(--ink); }
        .back-link { color:var(--link); font-size:14px; text-decoration:none; font-weight:700; }
        .back-link:hover { opacity:0.75; }

        main { flex:1; display:flex; align-items:flex-start; justify-content:center; gap:2rem; padding:40px 7%; flex-wrap:wrap; }

        .item-card { background:var(--panel); border-radius:10px; border:1.5px solid var(--line); overflow:hidden; width:100%; max-width:440px; flex-shrink:0; }
        .item-card img { width:100%; height:260px; object-fit:cover; }
        .item-body { padding:1.4rem; display:flex; flex-direction:column; gap:0.6rem; }
        .item-body h2 { font-size:20px; color:var(--ink); font-weight:800; }
        .description { font-size:14px; color:var(--muted); line-height:1.6; }
        .price { font-size:22px; font-weight:800; color:var(--good); }
        .detail-row { display:flex; justify-content:space-between; font-size:13px; color:var(--muted); border-top:1px solid var(--line2); padding-top:0.6rem; }
        .detail-row span { font-weight:700; color:var(--ink); }

        .bid-card { background:var(--panel); border-radius:10px; border:1.5px solid var(--line); padding:32px 28px; width:100%; max-width:380px; }
        .bid-card h3 { font-size:20px; margin-bottom:6px; color:var(--ink); font-weight:800; }
        .bid-card h3 span { color:var(--accent); }
        .bid-info { background:var(--bg); border:1.5px solid var(--line2); border-radius:8px; padding:14px; margin-bottom:20px; font-size:13px; line-height:1.8; }
        .bid-info-row { display:flex; justify-content:space-between; align-items:center; }
        .bid-info-row + .bid-info-row { margin-top:8px; }
        .bid-info-label { color:var(--muted); font-weight:600; }
        .bid-info-value { font-weight:700; color:var(--ink); }
        .bid-info-value.starting { color:var(--info); }
        .bid-info-value.highest { color:var(--good); font-size:15px; }
        .bid-info-value.none { color:var(--muted); font-style:italic; }
        .bid-requirement { background:var(--banner); border-left:3px solid var(--accent); padding:10px 12px; margin-bottom:18px; font-size:13px; color:var(--ink); border-radius:4px; }
        .bid-requirement strong { color:var(--accent); font-size:14px; }

        label { display:block; font-size:11px; font-weight:800; color:var(--muted); margin-bottom:5px; text-transform:uppercase; letter-spacing:.12em; }
        input[type="number"] { width:100%; padding:11px 14px; border:1.5px solid var(--line); border-radius:8px; font-size:15px; outline:none; color:var(--ink); background:#fff; transition:border-color 0.2s; }
        input[type="number"]:focus { border-color:var(--accent); }
        input.error { border-color:var(--bad); }

        .err { color:var(--bad); font-size:12px; margin-top:5px; display:none; font-weight:600; }
        .banner { padding:10px 14px; border-radius:8px; font-size:13px; margin-bottom:18px; display:none; border:1.5px solid; font-weight:600; }
        .banner.error   { background:rgba(211,48,59,0.08); color:var(--bad); border-color:var(--bad); }
        .banner.success { background:rgba(13,138,78,0.08); color:var(--good); border-color:var(--good); }

        .btn-submit { width:100%; margin-top:20px; padding:12px; background:var(--accent); color:#fff; border:none; border-radius:8px; font-size:15px; font-weight:700; cursor:pointer; transition:opacity 0.15s; font-family:inherit; }
        .btn-submit:hover { opacity:0.85; }

        footer { background:var(--top); padding:20px 7%; text-align:center; color:var(--muted); font-size:13px; border-top:1.5px solid var(--line); }
    </style>
</head>
<body>

    <header>
        <a class="logo" href="DashboardServlet">E-<span>Auction</span></a>
        <a class="back-link" href="DashboardServlet">&larr; Back to Dashboard</a>
    </header>

    <main>

        <!-- Item details -->
        <div class="item-card">
            <img
                src="<%= request.getContextPath() %>/<%= (item.getItemPicture() != null && !item.getItemPicture().trim().isEmpty()) ? item.getItemPicture() : "images/placeholder.png" %>"
                alt="<%= item.getItemName() %>"
                onerror="this.onerror=null; this.src='https://via.placeholder.com/440x260?text=No+Image';"
            />
            <div class="item-body">
                <h2><%= item.getItemName() %></h2>
                <p class="description"><%= item.getItemDescription() %></p>
                <div class="price">₹<%= item.getStartingPrice() %></div>
                <div class="detail-row">Seller <span><%= item.getSellerEmail() %></span></div>
                <div class="detail-row">Start <span><%= item.getAuctionStartTime() %></span></div>
                <div class="detail-row">End <span><%= item.getAuctionEndTime() %></span></div>
                <div class="detail-row">Item ID <span>#<%= item.getItemId() %></span></div>
            </div>
        </div>

        <!-- Bid form -->
        <div class="bid-card">
            <h3>Place a <span>Bid</span></h3>
            
            <div class="bid-info">
                <div class="bid-info-row">
                    <span class="bid-info-label">Starting Price:</span>
                    <span class="bid-info-value starting">₹<%= item.getStartingPrice() %></span>
                </div>
                <div class="bid-info-row">
                    <span class="bid-info-label">Current Highest Bid:</span>
                    <% if (currentHighestBid > 0) { %>
                        <span class="bid-info-value highest">₹<%= currentHighestBid %></span>
                    <% } else { %>
                        <span class="bid-info-value none">No bids yet</span>
                    <% } %>
                </div>
            </div>
            
            <div class="bid-requirement">
                Your bid must be greater than <strong>₹<%= minBidRequired %></strong>
            </div>

            <div id="banner" class="banner"></div>

            <form action="BidServlet" method="POST" id="bidForm">
                <input type="hidden" name="itemId"        value="<%= item.getItemId() %>" />
                <input type="hidden" name="startingPrice" value="<%= item.getStartingPrice() %>" />
                <input type="hidden" name="sellerEmail"   value="<%= item.getSellerEmail() %>" />

                <label for="bidAmount">Your Bid (₹)</label>
                <input
                    type="number"
                    id="bidAmount"
                    name="bidAmount"
                    step="1"
                    min="<%= (int) minBidRequired + 1 %>"
                    placeholder="Enter amount greater than ₹<%= minBidRequired %>"
                    required
                />
                <div class="err" id="bidErr"></div>

                <button type="submit" class="btn-submit">Submit Bid</button>
            </form>
        </div>

    </main>

    <footer>© 2026 E-Auction. All Rights Reserved.</footer>

    <script>
        // Step 4 — Read error param and show banner
        (function () {
            const params = new URLSearchParams(window.location.search);
            const banner = document.getElementById("banner");
            const error  = params.get("error");

            if (error === "own_item") {
                banner.textContent = "You cannot bid on your own listing.";
                banner.classList.add("error");
                banner.style.display = "block";
            }
        })();
        document.getElementById("bidForm").addEventListener("submit", function (e) {
            e.preventDefault();

            const bid          = parseFloat(document.getElementById("bidAmount").value);
            const minRequired  = <%= minBidRequired %>;
            const errEl        = document.getElementById("bidErr");
            const input        = document.getElementById("bidAmount");

            if (!bid || isNaN(bid)) {
                errEl.textContent = "Please enter a bid amount.";
                errEl.style.display = "block";
                input.classList.add("error");
                return;
            }
            if (bid <= minRequired) {
                errEl.textContent = "Bid must be greater than ₹" + minRequired + ".";
                errEl.style.display = "block";
                input.classList.add("error");
                return;
            }

            errEl.style.display = "none";
            input.classList.remove("error");
            this.submit();
        });
    </script>

</body>
</html>
