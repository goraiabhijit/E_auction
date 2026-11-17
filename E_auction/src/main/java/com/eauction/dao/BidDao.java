package com.eauction.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.eauction.model.Bid;

public class BidDao {

    private static final String URL      = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String USER     = "e_auction";
    private static final String PASSWORD = "eauction";

    private Connection getConnection() throws Exception {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    // Returns the current highest bid for an item, or 0.0 if no bids yet
    public double getHighestBid(int itemId) {
        String sql = "SELECT MAX(bid_amount) FROM Bid_Details WHERE item_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, itemId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getObject(1) != null) {
                    return rs.getDouble(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0.0; // No bids placed yet
    }

    // Inserts a new bid into Bid_Details
    public boolean placeBid(Bid bid) {
        String sql = "INSERT INTO Bid_Details (item_id, bidder_email, bid_amount) VALUES (?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bid.getItemId());
            ps.setString(2, bid.getBidderEmail());
            ps.setDouble(3, bid.getBidAmount());

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Returns all bids placed by a specific user (JOIN with Item_Details for item name)
    public List<Bid> getBidsByUser(String email) {
        List<Bid> bids = new ArrayList<>();
        String sql = "SELECT b.bid_id, b.item_id, b.bidder_email, b.bid_amount, b.bid_time, i.item_name " +
                     "FROM Bid_Details b JOIN Item_Details i ON b.item_id = i.item_id " +
                     "WHERE b.bidder_email = ? ORDER BY b.bid_time DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Bid bid = new Bid();
                    bid.setBidId(rs.getInt("bid_id"));
                    bid.setItemId(rs.getInt("item_id"));
                    bid.setItemName(rs.getString("item_name"));
                    bid.setBidderEmail(rs.getString("bidder_email"));
                    bid.setBidAmount(rs.getDouble("bid_amount"));
                    bid.setBidTime(rs.getTimestamp("bid_time"));
                    bids.add(bid);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return bids;
    }

    // Returns all bids placed by everyone (JOIN with Item_Details for item name)
    public List<Bid> getAllBids() {
        List<Bid> bids = new ArrayList<>();
        String sql = "SELECT b.bid_id, b.item_id, b.bidder_email, b.bid_amount, b.bid_time, i.item_name " +
                     "FROM Bid_Details b JOIN Item_Details i ON b.item_id = i.item_id " +
                     "ORDER BY b.bid_time DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Bid bid = new Bid();
                bid.setBidId(rs.getInt("bid_id"));
                bid.setItemId(rs.getInt("item_id"));
                bid.setItemName(rs.getString("item_name"));
                bid.setBidderEmail(rs.getString("bidder_email"));
                bid.setBidAmount(rs.getDouble("bid_amount"));
                bid.setBidTime(rs.getTimestamp("bid_time"));
                bids.add(bid);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return bids;
    }

    // Returns all bids for a specific item ordered highest first (for bid history modal)
    public List<Bid> getBidsByItemId(int itemId) {
        List<Bid> bids = new ArrayList<>();
        String sql = "SELECT b.bid_id, b.item_id, b.bidder_email, b.bid_amount, b.bid_time, i.item_name " +
                     "FROM Bid_Details b JOIN Item_Details i ON b.item_id = i.item_id " +
                     "WHERE b.item_id = ? ORDER BY b.bid_amount DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, itemId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Bid bid = new Bid();
                    bid.setBidId(rs.getInt("bid_id"));
                    bid.setItemId(rs.getInt("item_id"));
                    bid.setItemName(rs.getString("item_name"));
                    bid.setBidderEmail(rs.getString("bidder_email"));
                    bid.setBidAmount(rs.getDouble("bid_amount"));
                    bid.setBidTime(rs.getTimestamp("bid_time"));
                    bids.add(bid);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return bids;
    }
}
