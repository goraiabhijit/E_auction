package com.eauction.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.eauction.model.Commission;

public class CommissionDao {

    private static final String URL      = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String USER     = "e_auction";
    private static final String PASSWORD = "eauction";

    private Connection getConnection() throws Exception {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    // Insert a new commission record — trigger auto-fills commission_id
    public boolean insertCommission(Commission c) {
        String sql = "INSERT INTO Commission_Details " +
                     "(item_id, seller_email, sale_amount, commission_pct, commission_amt) " +
                     "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1,    c.getItemId());
            ps.setString(2, c.getSellerEmail());
            ps.setDouble(3, c.getSaleAmount());
            ps.setDouble(4, c.getCommissionPct());
            ps.setDouble(5, c.getCommissionAmt());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Fetch all commission records ordered by most recent first
    public List<Commission> getAllCommissions() {
        List<Commission> list = new ArrayList<>();
        String sql = "SELECT commission_id, item_id, seller_email, sale_amount, " +
                     "commission_pct, commission_amt, generated_at " +
                     "FROM Commission_Details ORDER BY generated_at DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Commission c = new Commission();
                c.setCommissionId(rs.getInt("commission_id"));
                c.setItemId(rs.getInt("item_id"));
                c.setSellerEmail(rs.getString("seller_email"));
                c.setSaleAmount(rs.getDouble("sale_amount"));
                c.setCommissionPct(rs.getDouble("commission_pct"));
                c.setCommissionAmt(rs.getDouble("commission_amt"));
                c.setGeneratedAt(rs.getTimestamp("generated_at"));
                list.add(c);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // Get commission for a specific item — returns null if not generated yet
    public Commission getCommissionByItemId(int itemId) {        String sql = "SELECT commission_id, item_id, seller_email, sale_amount, " +
                     "commission_pct, commission_amt, generated_at " +
                     "FROM Commission_Details WHERE item_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, itemId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Commission c = new Commission();
                    c.setCommissionId(rs.getInt("commission_id"));
                    c.setItemId(rs.getInt("item_id"));
                    c.setSellerEmail(rs.getString("seller_email"));
                    c.setSaleAmount(rs.getDouble("sale_amount"));
                    c.setCommissionPct(rs.getDouble("commission_pct"));
                    c.setCommissionAmt(rs.getDouble("commission_amt"));
                    c.setGeneratedAt(rs.getTimestamp("generated_at"));
                    return c;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null; // not generated yet
    }

    // Get all commissions for a specific seller email (for user dashboard)
    public List<Commission> getCommissionsBySellerEmail(String sellerEmail) {
        List<Commission> list = new ArrayList<>();
        String sql = "SELECT c.commission_id, c.item_id, i.item_name, c.seller_email, " +
                     "c.sale_amount, c.commission_pct, c.commission_amt, c.generated_at " +
                     "FROM Commission_Details c " +
                     "JOIN Item_Details i ON i.item_id = c.item_id " +
                     "WHERE c.seller_email = ? " +
                     "ORDER BY c.generated_at DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, sellerEmail);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Commission c = new Commission();
                    c.setCommissionId(rs.getInt("commission_id"));
                    c.setItemId(rs.getInt("item_id"));
                    c.setItemName(rs.getString("item_name"));
                    c.setSellerEmail(rs.getString("seller_email"));
                    c.setSaleAmount(rs.getDouble("sale_amount"));
                    c.setCommissionPct(rs.getDouble("commission_pct"));
                    c.setCommissionAmt(rs.getDouble("commission_amt"));
                    c.setGeneratedAt(rs.getTimestamp("generated_at"));
                    list.add(c);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
