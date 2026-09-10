package com.eauction.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Bid implements Serializable {
    private static final long serialVersionUID = 1L;

    private int    bidId;
    private int    itemId;
    private String itemName;
    private String bidderEmail;
    private double bidAmount;
    private Timestamp bidTime;

    // Default constructor
    public Bid() {}

    // Constructor used by BidServlet: Bid(itemId, bidderEmail, bidAmount)
    public Bid(int itemId, String bidderEmail, double bidAmount) {
        this.itemId      = itemId;
        this.bidderEmail = bidderEmail;
        this.bidAmount   = bidAmount;
    }

    // Getters and Setters
    public int getBidId() { return bidId; }
    public void setBidId(int bidId) { this.bidId = bidId; }

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public String getBidderEmail() { return bidderEmail; }
    public void setBidderEmail(String bidderEmail) { this.bidderEmail = bidderEmail; }

    public double getBidAmount() { return bidAmount; }
    public void setBidAmount(double bidAmount) { this.bidAmount = bidAmount; }

    public Timestamp getBidTime() { return bidTime; }
    public void setBidTime(Timestamp bidTime) { this.bidTime = bidTime; }
}
