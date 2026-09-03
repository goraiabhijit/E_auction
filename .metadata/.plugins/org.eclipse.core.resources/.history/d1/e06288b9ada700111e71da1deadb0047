package com.eauction.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.eauction.model.User;

public class UserDao {

    // Helper method to get the Oracle DB connection
    private Connection getConnection() throws Exception {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        return DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:XE", "e_auction", "eauction");
    }

    // 1. Insert User (Registration Flow)
    public boolean insertUser(User user) {
        String sql = "INSERT INTO Registration (name, email, password, mobile, address, gender) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getMobile());
            ps.setString(5, user.getAddress());
            ps.setString(6, user.getGender());

            int rows = ps.executeUpdate();
            return rows > 0; // Returns true if insert succeeds

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 2. Validate User (Login Flow)
    public boolean validateUser(String email, String password) {
        // Fixed: changed 'email_id' to 'email' to match your Registration table primary key
        String sql = "SELECT * FROM Registration WHERE email = ? AND password = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next(); // Returns true if credentials match
            }

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}