package com.eauction.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;

import com.eauction.dao.ItemDao;
import com.eauction.model.Item;
import com.eauction.model.User;

/**
 * Servlet implementation class PutItemServlet
 */
@WebServlet("/PutItemServlet")
@MultipartConfig
public class PutItemServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public PutItemServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		// 1. Fetch logged-in user from session
        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (loggedInUser == null) {
            response.sendRedirect("signin.html");
            return;
        }

        // 2. Fetch parameters matching exact form names
        String itemName = request.getParameter("itemName");
        String itemDescription = request.getParameter("itemDescription");
        double startingPrice = Double.parseDouble(request.getParameter("startingPrice"));
        String sellerEmail = loggedInUser.getEmail();

     // 1. Get file part and file name
        Part filePart = request.getPart("itemPicture");
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

        // 2. Deployment Upload Path (Where Tomcat serves files live)
        String deployUploadPath = getServletContext().getRealPath("/uploads");
        File deployDir = new File(deployUploadPath);
        if (!deployDir.exists()) {
            deployDir.mkdirs();
        }

        File deployFile = new File(deployUploadPath + File.separator + fileName);

        // Primary write call (consumes the multipart stream)
        filePart.write(deployFile.getAbsolutePath());

        // 3. Source Upload Path (Permanent storage in src/main/webapp/uploads)
        String sourceUploadPath = getServletContext().getRealPath("").split("\\.metadata")[0] 
                + "E_auction" + File.separator + "src" + File.separator + "main" 
                + File.separator + "webapp" + File.separator + "uploads";

        File sourceDir = new File(sourceUploadPath);
        if (!sourceDir.exists()) {
            sourceDir.mkdirs();
        }

        File sourceFile = new File(sourceUploadPath + File.separator + fileName);

        // Use Files.copy instead of calling filePart.write() again
        java.nio.file.Files.copy(
            deployFile.toPath(), 
            sourceFile.toPath(), 
            java.nio.file.StandardCopyOption.REPLACE_EXISTING
        );

        
        // 4. Store relative path for Oracle DB insertion
        String dbPicturePath = "uploads/" + fileName;

        // 4. Populate Item model object
        Item item = new Item();
        item.setItemName(itemName);
        item.setItemDescription(itemDescription);
        item.setStartingPrice(startingPrice);
        item.setItemPicture(dbPicturePath);
        item.setSellerEmail(sellerEmail);

        // 5. Call DAO method putItem
        ItemDao itemDao = new ItemDao();
        if (itemDao.putItem(item)) {
            response.sendRedirect("DashboardServlet");
        } else {
            response.sendRedirect("addItem.jsp?error=insert_failed");
        }
	}

}
