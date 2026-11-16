package com.eauction.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.eauction.model.Admin;

public class AdminUserDao {

    private static final String URL      = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String USER     = "e_auction";
    private static final String PASSWORD = "eauction";

    private Connection getConnection() throws Exception {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    // Validate admin credentials against the Admin table
    public Admin validateAdmin(String email, String password) {
        String sql = "SELECT name, email, password FROM Admin WHERE email = ? AND password = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Admin admin = new Admin();
                    admin.setName(rs.getString("name"));
                    admin.setEmail(rs.getString("email"));
                    admin.setPassword(rs.getString("password"));
                    return admin;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null; // Returns null if credentials don't match
    }
}
