package com.eauction.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.eauction.model.Item;

public class ItemDao {

    private static final String URL      = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String USER     = "e_auction";
    private static final String PASSWORD = "eauction";

    private Connection getConnection() throws Exception {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    // ── Get single item by ID ──
    public Item getItemById(int itemId) {
        String sql = "SELECT item_id, item_name, item_description, starting_price, " +
                     "auction_start_time, auction_end_time, item_picture, seller_email " +
                     "FROM Item_Details WHERE item_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, itemId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Item item = new Item();
                    item.setItemId(rs.getInt("item_id"));
                    item.setItemName(rs.getString("item_name"));
                    item.setItemDescription(rs.getString("item_description"));
                    item.setStartingPrice(rs.getDouble("starting_price"));
                    item.setAuctionStartTime(rs.getTimestamp("auction_start_time"));
                    item.setAuctionEndTime(rs.getTimestamp("auction_end_time"));
                    item.setItemPicture(rs.getString("item_picture"));
                    item.setSellerEmail(rs.getString("seller_email"));
                    return item;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // ── Step 3: getAllItems ──
    public List<Item> getAllItems() {
        List<Item> itemList = new ArrayList<>();
        String sql = "SELECT item_id, item_name, item_description, starting_price, " +
                     "auction_start_time, auction_end_time, item_picture, seller_email " +
                     "FROM Item_Details ORDER BY auction_start_time DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Item item = new Item();
                item.setItemId(rs.getInt("item_id"));
                item.setItemName(rs.getString("item_name"));
                item.setItemDescription(rs.getString("item_description"));
                item.setStartingPrice(rs.getDouble("starting_price"));
                item.setAuctionStartTime(rs.getTimestamp("auction_start_time"));
                item.setAuctionEndTime(rs.getTimestamp("auction_end_time"));   // new
                item.setItemPicture(rs.getString("item_picture"));
                item.setSellerEmail(rs.getString("seller_email"));

                itemList.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return itemList;
    }

    // ── Active items: auction_end_time > NOW ──
    public List<Item> getActiveItems() {
        List<Item> items = new ArrayList<>();
        String sql = "SELECT item_id, item_name, item_description, starting_price, " +
                     "auction_start_time, auction_end_time, item_picture, seller_email " +
                     "FROM Item_Details WHERE auction_end_time > CURRENT_TIMESTAMP " +
                     "ORDER BY auction_end_time ASC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Item item = new Item();
                item.setItemId(rs.getInt("item_id"));
                item.setItemName(rs.getString("item_name"));
                item.setItemDescription(rs.getString("item_description"));
                item.setStartingPrice(rs.getDouble("starting_price"));
                item.setAuctionStartTime(rs.getTimestamp("auction_start_time"));
                item.setAuctionEndTime(rs.getTimestamp("auction_end_time"));
                item.setItemPicture(rs.getString("item_picture"));
                item.setSellerEmail(rs.getString("seller_email"));
                items.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return items;
    }

    // ── Completed items: auction_end_time <= NOW ──
    public List<Item> getCompletedItems() {
        List<Item> items = new ArrayList<>();
        String sql = "SELECT item_id, item_name, item_description, starting_price, " +
                     "auction_start_time, auction_end_time, item_picture, seller_email " +
                     "FROM Item_Details WHERE auction_end_time <= CURRENT_TIMESTAMP " +
                     "ORDER BY auction_end_time DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Item item = new Item();
                item.setItemId(rs.getInt("item_id"));
                item.setItemName(rs.getString("item_name"));
                item.setItemDescription(rs.getString("item_description"));
                item.setStartingPrice(rs.getDouble("starting_price"));
                item.setAuctionStartTime(rs.getTimestamp("auction_start_time"));
                item.setAuctionEndTime(rs.getTimestamp("auction_end_time"));
                item.setItemPicture(rs.getString("item_picture"));
                item.setSellerEmail(rs.getString("seller_email"));
                items.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return items;
    }

    // ── Step 2: putItem — include auction_start_time and auction_end_time ──    public boolean putItem(Item item) {
        String sql = "INSERT INTO Item_Details " +
                     "(item_id, item_name, item_description, item_picture, starting_price, " +
                     "auction_start_time, auction_end_time, seller_email) " +
                     "VALUES (item_id_seq.NEXTVAL, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, item.getItemName());
            ps.setString(2, item.getItemDescription());
            ps.setString(3, item.getItemPicture());
            ps.setDouble(4, item.getStartingPrice());
            ps.setTimestamp(5, item.getAuctionStartTime());  // new
            ps.setTimestamp(6, item.getAuctionEndTime());    // new
            ps.setString(7, item.getSellerEmail());

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
