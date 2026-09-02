package com.eauction.dao;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.eauction.model.User;

public class UserDAO {

    // Helper method to get the Oracle DB connection
    private Connection getConnection() throws Exception {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        return DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:XE", "system", "manager");
    }

 // 1. Insert User (Registration Flow)
    public boolean insertUser(User user) {
        String sql = "INSERT INTO registration (name, email_id, password, phone_number, address, gender) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmailId());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getPhoneNumber());
            ps.setString(5, user.getAddress());
            ps.setString(6, user.getGender());

            int rows = ps.executeUpdate();
            return rows > 0; // Returns true if insert succeeds

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    
    
    
    
    
    
    
    

 }