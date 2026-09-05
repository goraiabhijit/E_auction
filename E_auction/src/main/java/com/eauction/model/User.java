package com.eauction.model;

import java.io.Serializable;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private String name;
    private String email;
    private String password;
    private String mobile;
    private String address;
    private String gender;
    private String role;

    
    // Default constructor (required for standard JavaBean practices)
    public User() {
    }

    // Parameterized constructor using exact schema field names
    public User(String name, String email, String password, String mobile, String address, String gender) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.mobile = mobile;
        this.address = address;
        this.gender = gender;
      
    }

    
    public String getName() { 
        return name; 
    }
    public void setName(String name) { 
        this.name = name; 
    }

    public String getEmail() { 
        return email; 
    }
    public void setEmail(String email) { 
        this.email = email; 
    }

    public String getPassword() { 
        return password; 
    }
    public void setPassword(String password) { 
        this.password = password; 
    }

    public String getMobile() { 
        return mobile; 
    }
    public void setMobile(String mobile) { 
        this.mobile = mobile; 
    }

    public String getAddress() { 
        return address; 
    }
    public void setAddress(String address) { 
        this.address = address; 
    }

    public String getGender() { 
        return gender; 
    }
    public void setGender(String gender) { 
        this.gender = gender; 
    }
}