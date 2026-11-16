package com.eauction.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class AuctionResult implements Serializable {
    private static final long serialVersionUID = 1L;

    private int    itemId;
    private String itemName;
    private String sellerEmail;
    private double startingPrice;
    private double closingBid;      // highest bid at auction close
    private String buyerEmail;      // email of the winning bidder (null if no bids)
    private Timestamp auctionEndTime;

    public AuctionResult() {}

    public int    getItemId()          { return itemId; }
    public void   setItemId(int v)     { this.itemId = v; }

    public String getItemName()           { return itemName; }
    public void   setItemName(String v)   { this.itemName = v; }

    public String getSellerEmail()           { return sellerEmail; }
    public void   setSellerEmail(String v)   { this.sellerEmail = v; }

    public double getStartingPrice()         { return startingPrice; }
    public void   setStartingPrice(double v) { this.startingPrice = v; }

    public double getClosingBid()            { return closingBid; }
    public void   setClosingBid(double v)    { this.closingBid = v; }

    public String getBuyerEmail()            { return buyerEmail; }
    public void   setBuyerEmail(String v)    { this.buyerEmail = v; }

    public Timestamp getAuctionEndTime()           { return auctionEndTime; }
    public void      setAuctionEndTime(Timestamp v){ this.auctionEndTime = v; }
}
