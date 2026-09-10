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
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }

        body { background: #f4f6f9; min-height: 100vh; display: flex; flex-direction: column; }

        /* ── Navbar ── */
        header {
            background: #101827;
            height: 84px;
            padding: 0 7%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-top: 3px solid #f59e0b;
            box-shadow: 0 3px 12px rgba(0,0,0,0.25);
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .logo { font-size: 26px; font-weight: bold; color: white; text-decoration: none; letter-spacing: -1px; }
        .logo span { color: #f59e0b; }
        .back-link { color: #9ca3af; font-size: 14px; text-decoration: none; }
        .back-link:hover { color: #f59e0b; }

        /* ── Layout ── */
        main {
            flex: 1;
            display: flex;
            align-items: flex-start;
            justify-content: center;
            gap: 2rem;
            padding: 40px 7%;
            flex-wrap: wrap;
        }

        /* ── Item detail card ── */
        .item-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.08);
            overflow: hidden;
            width: 100%;
            max-width: 440px;
            flex-shrink: 0;
        }

        .item-card img {
            width: 100%;
            height: 260px;
            object-fit: cover;
        }

        .item-body {
            padding: 1.4rem;
            display: flex;
            flex-direction: column;
            gap: 0.6rem;
        }

        .item-body h2 { font-size: 20px; color: #111827; }

        .item-body .description { font-size: 14px; color: #64748b; line-height: 1.6; }

        .item-body .price {
            font-size: 22px;
            font-weight: bold;
            color: #059669;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            font-size: 13px;
            color: #64748b;
            border-top: 1px solid #f1f5f9;
            padding-top: 0.6rem;
        }
        .detail-row span { font-weight: bold; color: #374151; }

        /* ── Bid form card ── */
        .bid-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.08);
            padding: 32px 28px;
            width: 100%;
            max-width: 380px;
        }

        .bid-card h3 { font-size: 20px; margin-bottom: 6px; color: #111827; }
        .bid-card h3 span { color: #f59e0b; }
        
        .bid-info {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 14px;
            margin-bottom: 20px;
            font-size: 13px;
            line-height: 1.8;
        }
        
        .bid-info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .bid-info-row + .bid-info-row {
            margin-top: 8px;
        }
        
        .bid-info-label {
            color: #64748b;
            font-weight: 500;
        }
        
        .bid-info-value {
            font-weight: bold;
            color: #111827;
        }
        
        .bid-info-value.starting {
            color: #0284c7;
        }
        
        .bid-info-value.highest {
            color: #059669;
            font-size: 15px;
        }
        
        .bid-info-value.none {
            color: #94a3b8;
            font-style: italic;
        }
        
        .bid-requirement {
            background: #fef3c7;
            border-left: 3px solid #f59e0b;
            padding: 10px 12px;
            margin-bottom: 18px;
            font-size: 13px;
            color: #92400e;
            border-radius: 4px;
        }
        
        .bid-requirement strong {
            color: #78350f;
            font-size: 14px;
        }

        label { display: block; font-size: 13px; font-weight: bold; color: #374151; margin-bottom: 5px; }

        input[type="number"] {
            width: 100%;
            padding: 11px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 15px;
            outline: none;
        }
        input[type="number"]:focus { border-color: #f59e0b; box-shadow: 0 0 0 2px rgba(245,158,11,0.15); }
        input.error { border-color: #dc2626; }

        .err { color: #dc2626; font-size: 12px; margin-top: 5px; display: none; }

        .banner {
            padding: 10px 14px;
            border-radius: 6px;
            font-size: 13px;
            margin-bottom: 18px;
            display: none;
        }
        .banner.error   { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }
        .banner.success { background: #dcfce7; color: #166534; border: 1px solid #86efac; }

        .btn-submit {
            width: 100%;
            margin-top: 20px;
            padding: 12px;
            background: #f59e0b;
            color: #111827;
            border: none;
            border-radius: 6px;
            font-size: 15px;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-submit:hover { background: #d97706; color: white; }

        footer { background: #030712; padding: 20px 7%; text-align: center; color: #9ca3af; font-size: 13px; }
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
