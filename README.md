# E-Auction Platform

A web-based online auction platform built with Java Servlets, JSP, and Oracle DB.

---

## Tech Stack

| Layer    | Technology                        |
|----------|-----------------------------------|
| Frontend | HTML, CSS, JavaScript, JSP        |
| Backend  | Java Servlets (Jakarta EE)        |
| Database | Oracle XE                         |
| Server   | Apache Tomcat 10                  |

---

## Database Tables

### 1. `Registration`
Stores user account information.

| Column   | Type          | Constraints     |
|----------|---------------|-----------------|
| name     | VARCHAR2      | NOT NULL        |
| email    | VARCHAR2      | NOT NULL        |
| password | VARCHAR2      | NOT NULL        |
| mobile   | VARCHAR2      | NOT NULL        |
| address  | VARCHAR2      | NOT NULL        |
| gender   | VARCHAR2      | NOT NULL        |
| role     | VARCHAR2      | NULLABLE        |

---

### 2. `Item_Details`
Stores auction items listed by sellers.

| Column             | Type           | Constraints              |
|--------------------|----------------|--------------------------|
| item_id            | NUMBER         | PRIMARY KEY              |
| item_name          | VARCHAR2(100)  | NOT NULL                 |
| item_description   | VARCHAR2(500)  | NULLABLE                 |
| item_picture       | VARCHAR2(255)  | NULLABLE                 |
| starting_price     | NUMBER(12,2)   | NOT NULL                 |
| auction_start_time | TIMESTAMP(6)   | NOT NULL                 |
| auction_end_time   | TIMESTAMP(6)   | NOT NULL                 |
| seller_email       | VARCHAR2(100)  | NOT NULL                 |
| status             | VARCHAR2(20)   | DEFAULT 'OPEN'           |

> `item_id` is auto-incremented via Oracle sequence `item_id_seq`.
> Create with: `CREATE SEQUENCE item_id_seq START WITH 1 INCREMENT BY 1;`

---

## Project Structure

```
E_auction/
└── src/main/
    ├── java/com/eauction/
    │   ├── controller/
    │   │   ├── LoginServlet.java
    │   │   ├── RegisterServlet.java
    │   │   ├── LogoutServlet.java
    │   │   ├── DashboardServlet.java
    │   │   ├── PutItemServlet.java
    │   │   └── BidServlet.java
    │   ├── dao/
    │   │   ├── UserDao.java
    │   │   ├── ItemDao.java
    │   │   └── BidDao.java
    │   └── model/
    │       ├── User.java
    │       ├── Item.java
    │       └── Bid.java
    └── webapp/
        ├── index.html
        ├── signin.html
        ├── signup.html
        ├── dashboard.jsp
        ├── addItem.jsp
        ├── bidItem.jsp
        └── uploads/         (user-uploaded item images)
```

---

## User Flow

```
index.html (Landing Page)
  ├── Login   → signin.html → LoginServlet → DashboardServlet → dashboard.jsp
  └── Sign Up → signup.html → RegisterServlet → signin.html

dashboard.jsp (Main Hub)
  ├── View all live auction items (with images, starting price, seller info)
  ├── My Bids panel (right sidebar) - shows user's own bids
  ├── All Bids panel (right sidebar) - shows all bids from everyone
  ├── + Add New Item → addItem.jsp → PutItemServlet → DashboardServlet
  ├── Place Bid button → bidItem.jsp → BidServlet → DashboardServlet
  └── Logout → LogoutServlet → signin.html

bidItem.jsp (Bid Placement)
  ├── Shows item details (image, description, price, seller, auction times)
  ├── Displays starting price and current highest bid
  ├── Validates bid amount (must exceed both starting price and highest bid)
  ├── Prevents seller from bidding on own item
  └── Success → redirects to DashboardServlet with status message

addItem.jsp (Item Creation)
  ├── Upload item image (sanitized filename to prevent Unicode issues)
  ├── Enter item details (name, description, starting price)
  ├── Set auction start and end times
  └── Success → redirects to DashboardServlet
```

---

## Oracle Setup

**⚠️ IMPORTANT: Run these commands in order before using the application!**

```sql
-- 1. Create Sequence for Item_Details primary key (REQUIRED!)
CREATE SEQUENCE item_id_seq START WITH 1 INCREMENT BY 1;

-- 2. Create Item_Details table
CREATE TABLE Item_Details (
    item_id            NUMBER PRIMARY KEY,
    item_name          VARCHAR2(100) NOT NULL,
    item_description   VARCHAR2(500),
    item_picture       VARCHAR2(255),
    starting_price     NUMBER(12, 2) NOT NULL,
    auction_start_time TIMESTAMP NOT NULL,
    auction_end_time   TIMESTAMP NOT NULL,
    seller_email       VARCHAR2(100) NOT NULL,
    status             VARCHAR2(20) DEFAULT 'OPEN'
);

-- 3. Create Registration table
CREATE TABLE Registration (
    name     VARCHAR2(100) NOT NULL,
    email    VARCHAR2(100) NOT NULL,
    password VARCHAR2(100) NOT NULL,
    mobile   VARCHAR2(15)  NOT NULL,
    address  VARCHAR2(255) NOT NULL,
    gender   VARCHAR2(10)  NOT NULL,
    role     VARCHAR2(20)
);

COMMIT;
```

> **Note on `status` column:**  
> The database table includes a `status` column with default value 'OPEN', but the Java code (Item.java, ItemDao.java) does NOT use it. The status is intended to be calculated dynamically at runtime by comparing `auction_end_time` with the current timestamp. The database column exists for future use or manual updates, but the application code ignores it.

---

### 3. `Bid_Details`
Stores bids placed by users on auction items.

| Column       | Type          | Constraints                                         |
|--------------|---------------|-----------------------------------------------------|
| bid_id       | NUMBER        | PRIMARY KEY (auto via trigger)                      |
| item_id      | NUMBER        | NOT NULL, FK → Item_Details(item_id) ON DELETE CASCADE |
| bidder_email | VARCHAR2(100) | NOT NULL, FK → Registration(email) ON DELETE CASCADE|
| bid_amount   | NUMBER(12,2)  | NOT NULL                                            |
| bid_time     | TIMESTAMP     | DEFAULT CURRENT_TIMESTAMP, NOT NULL                 |

---

## Bid_Details Oracle Setup

**⚠️ Run these commands in order after creating Item_Details and Registration tables!**

```sql
-- 1. Create Bid_Details Table
CREATE TABLE Bid_Details (
    bid_id       NUMBER PRIMARY KEY,
    item_id      NUMBER NOT NULL,
    bidder_email VARCHAR2(100) NOT NULL,
    bid_amount   NUMBER(12, 2) NOT NULL,
    bid_time     TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_bid_item FOREIGN KEY (item_id)
        REFERENCES Item_Details(item_id) ON DELETE CASCADE,
    CONSTRAINT fk_bid_user FOREIGN KEY (bidder_email)
        REFERENCES Registration(email) ON DELETE CASCADE
);

-- 2. Create Sequence for Auto-Incrementing bid_id (REQUIRED!)
CREATE SEQUENCE bid_seq START WITH 1 INCREMENT BY 1;

-- 3. Create Trigger to Auto-Fill bid_id on INSERT
CREATE OR REPLACE TRIGGER trg_bid_id
BEFORE INSERT ON Bid_Details
FOR EACH ROW
BEGIN
    IF :NEW.bid_id IS NULL THEN
        SELECT bid_seq.NEXTVAL INTO :NEW.bid_id FROM DUAL;
    END IF;
END;
/

COMMIT;
```

---

## Troubleshooting

### 1. Stale Compiled Classes (ORA-00904: invalid identifier)

**Symptom:** Dashboard shows empty even though data exists in DB, or errors mentioning fields that don't exist in your current code.

**Cause:** Stale compiled `.class` files in Tomcat deployment directory containing old code.

**Solution:**
1. **Stop Tomcat server** (if running)
2. **Clean the project**: Right-click project → **Clean...**
3. **Clean Tomcat work directory**: In Servers view → Right-click "Tomcat v10.1 Server" → **Clean...**
4. **Rebuild the project**: Project → **Build Project** (or wait for auto-build)
5. **Start Tomcat** and test again

---

### 2. Sequence Does Not Exist (ORA-02289)

**Symptom:** Item insert fails with `ORA-02289: sequence does not exist`

**Cause:** The `item_id_seq` or `bid_seq` sequence was not created in Oracle.

**Solution:** Run these SQL commands in your Oracle database:

```sql
-- For Item_Details auto-increment
CREATE SEQUENCE item_id_seq START WITH 1 INCREMENT BY 1;

-- For Bid_Details auto-increment
CREATE SEQUENCE bid_seq START WITH 1 INCREMENT BY 1;
```

---

### 3. Table Does Not Exist (ORA-00942)

**Symptom:** `ORA-00942: table or view does not exist`

**Cause:** Required tables haven't been created yet.

**Solution:** Run the complete SQL setup from the "Oracle Setup" and "Bid_Details Oracle Setup" sections in this README.

---

## Features

### Authentication & User Management
- User registration with role-based accounts
- Secure login with session management
- User profile display in dashboard header with avatar and dropdown menu

### Auction Item Management
- Sellers can list items with image uploads
- Item details include: name, description, starting price, auction start/end times
- Automatic filename sanitization for uploaded images (prevents Unicode corruption)
- Items stored in Oracle DB with auto-incremented IDs via sequences
- Real-time item display on dashboard with images

### Bidding System
- Users can place bids on auction items
- **Bid validation:**
  - Bid must be greater than starting price
  - Bid must exceed current highest bid
  - User cannot bid on their own items
- **Bid information display:**
  - Shows current highest bid on bidItem.jsp
  - Minimum required bid calculated dynamically
  - Real-time bid history in dashboard sidebar
- **My Bids panel:** Shows user's own bidding history
- **All Bids panel:** Shows all bids from all users (displays "You" for current user's bids)

### UI/UX Features
- Responsive grid layout for auction items
- Two-column dashboard (items grid + bid panels)
- Image fallback handling (placeholder if image fails to load)
- Success/error message banners with query parameters
- Context-aware navigation (back to dashboard, logout)

---

## Development Notes

- **Database credentials** are hardcoded in DAO classes (URL, USER, PASSWORD). For production, use connection pooling or externalized configuration.
- **File uploads** are stored in `webapp/uploads/` and copied to both deployment and source directories.
  - Filenames are sanitized: special Unicode characters replaced with underscores
  - If sanitized name is empty, generates timestamp-based name: `item_1726081234567.jpg`
- **Session management**: User login creates `currentUser` session attribute with User object.
- **Bid validation**: Enforced at servlet level (user can't bid on own item, bid must exceed starting price and current highest bid).
- **Always use DashboardServlet**: Never redirect directly to `dashboard.jsp` - always go through `DashboardServlet` to ensure data is loaded.
- **Image paths**: Use `request.getContextPath() + "/" + item.getItemPicture()` to generate correct URLs.
