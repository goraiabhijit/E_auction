package com.eauction.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Item implements Serializable {
    private static final long serialVersionUID = 1L;

    private int itemId;
    private String itemName;
    private String itemDescription;
    private double startingPrice;
    private Timestamp auctionStartTime;
    private String itemPicture;
    private String sellerEmail;

    // Default Constructor
    public Item() {
    }

    // Parameterized Constructor
    public Item(int itemId, String itemName, String itemDescription, double startingPrice, 
                Timestamp auctionStartTime, String itemPicture, String sellerEmail) {
        this.itemId = itemId;
        this.itemName = itemName;
        this.itemDescription = itemDescription;
        this.startingPrice = startingPrice;
        this.auctionStartTime = auctionStartTime;
        this.itemPicture = itemPicture;
        this.sellerEmail = sellerEmail;
    }

    // Getters and Setters
    public int getItemId() {
        return itemId;
    }

    public void setItemId(int itemId) {
        this.itemId = itemId;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public String getItemDescription() {
        return itemDescription;
    }

    public void setItemDescription(String itemDescription) {
        this.itemDescription = itemDescription;
    }

    public double getStartingPrice() {
        return startingPrice;
    }

    public void setStartingPrice(double startingPrice) {
        this.startingPrice = startingPrice;
    }

    public Timestamp getAuctionStartTime() {
        return auctionStartTime;
    }

    public void setAuctionStartTime(Timestamp auctionStartTime) {
        this.auctionStartTime = auctionStartTime;
    }

    public String getItemPicture() {
        return itemPicture;
    }

    public void setItemPicture(String itemPicture) {
        this.itemPicture = itemPicture;
    }

    public String getSellerEmail() {
        return sellerEmail;
    }

    public void setSellerEmail(String sellerEmail) {
        this.sellerEmail = sellerEmail;
    }
}