package com.eauction.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Commission {
  

    private int       commissionId;
    private int       itemId;
    private String    itemName;
    private String    sellerEmail;
    private double    saleAmount;
    private double    commissionPct;
    private double    commissionAmt;
    private Timestamp generatedAt;

    public Commission() {}

    public int    getCommissionId()              { return commissionId; }
    public void   setCommissionId(int v)         { this.commissionId = v; }

    public int    getItemId()                    { return itemId; }
    public void   setItemId(int v)               { this.itemId = v; }

    public String getItemName()                  { return itemName; }
    public void   setItemName(String v)          { this.itemName = v; }

    public String getSellerEmail()               { return sellerEmail; }
    public void   setSellerEmail(String v)       { this.sellerEmail = v; }

    public double getSaleAmount()                { return saleAmount; }
    public void   setSaleAmount(double v)        { this.saleAmount = v; }

    public double getCommissionPct()             { return commissionPct; }
    public void   setCommissionPct(double v)     { this.commissionPct = v; }

    public double getCommissionAmt()             { return commissionAmt; }
    public void   setCommissionAmt(double v)     { this.commissionAmt = v; }

    public Timestamp getGeneratedAt()            { return generatedAt; }
    public void      setGeneratedAt(Timestamp v) { this.generatedAt = v; }
}
