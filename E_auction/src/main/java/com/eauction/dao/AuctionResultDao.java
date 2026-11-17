package com.eauction.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.eauction.model.AuctionResult;

public class AuctionResultDao {

    private static final String URL      = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String USER     = "e_auction";
    private static final String PASSWORD = "eauction";

    private Connection getConnection() throws Exception {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    /**
     * Returns all items whose auction has ended (auction_end_time < NOW).
     * For each item, also fetches the winning bid amount and buyer email
     * by finding the bid with MAX(bid_amount) for that item.
     * Items with no bids are still included — closingBid = 0, buyerEmail = null.
     */
    public List<AuctionResult> getCompletedAuctions() {
        List<AuctionResult> results = new ArrayList<>();

        // LEFT JOIN so items with zero bids still appear
        // Subquery finds the single winning bid row per item
        // Get completed items that have at least one bid
        // Use MAX(bid_amount) subquery to find the winning bid row
        String sql =
            "SELECT i.item_id, i.item_name, i.seller_email, i.starting_price, " +
            "       i.auction_end_time, " +
            "       b.bid_amount AS closing_bid, b.bidder_email AS buyer_email " +
            "FROM Item_Details i " +
            "JOIN Bid_Details b " +
            "    ON b.item_id = i.item_id " +
            "    AND b.bid_amount = ( " +
            "        SELECT MAX(bid_amount) FROM Bid_Details WHERE item_id = i.item_id " +
            "    ) " +
            "WHERE i.auction_end_time < CURRENT_TIMESTAMP " +
            "ORDER BY i.auction_end_time DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                AuctionResult ar = new AuctionResult();
                ar.setItemId(rs.getInt("item_id"));
                ar.setItemName(rs.getString("item_name"));
                ar.setSellerEmail(rs.getString("seller_email"));
                ar.setStartingPrice(rs.getDouble("starting_price"));
                ar.setAuctionEndTime(rs.getTimestamp("auction_end_time"));

                // closing_bid and buyer_email can be null if no bids placed
                double closingBid = rs.getDouble("closing_bid");
                ar.setClosingBid(rs.wasNull() ? 0.0 : closingBid);
                ar.setBuyerEmail(rs.getString("buyer_email")); // null if no bids

                results.add(ar);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return results;
    }

    // Returns all items won by a specific buyer (auction ended + their bid was highest)
    public List<AuctionResult> getWinningsByBuyerEmail(String buyerEmail) {
        List<AuctionResult> results = new ArrayList<>();

        String sql =
            "SELECT i.item_id, i.item_name, i.seller_email, i.starting_price, " +
            "       i.auction_end_time, b.bid_amount AS closing_bid, b.bidder_email AS buyer_email " +
            "FROM Item_Details i " +
            "JOIN Bid_Details b ON b.item_id = i.item_id " +
            "WHERE i.auction_end_time < CURRENT_TIMESTAMP " +
            "  AND b.bidder_email = ? " +
            "  AND b.bid_amount = ( " +
            "      SELECT MAX(bid_amount) FROM Bid_Details WHERE item_id = i.item_id " +
            "  ) " +
            "ORDER BY i.auction_end_time DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, buyerEmail);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuctionResult ar = new AuctionResult();
                    ar.setItemId(rs.getInt("item_id"));
                    ar.setItemName(rs.getString("item_name"));
                    ar.setSellerEmail(rs.getString("seller_email"));
                    ar.setStartingPrice(rs.getDouble("starting_price"));
                    ar.setAuctionEndTime(rs.getTimestamp("auction_end_time"));
                    ar.setClosingBid(rs.getDouble("closing_bid"));
                    ar.setBuyerEmail(rs.getString("buyer_email"));
                    results.add(ar);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return results;
    }
}
