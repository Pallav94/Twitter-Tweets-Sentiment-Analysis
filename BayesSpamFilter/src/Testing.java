
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class Testing
 */
@WebServlet("/Testing")
public class Testing extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public Testing() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.setContentType("text/html");
		PrintWriter out = response.getWriter();
		
		String testData = request.getParameter("testData");
		String[] lowerTestData = testData.toLowerCase().split("[^\\p{L}0-9']+");
		double p1 = 1;
		double p2 = 1;
		double catprob1=0;
		double catprob2=0;
		try {

			PreparedStatement ps;
			ResultSet rs;
			Class.forName("com.mysql.jdbc.Driver");
			Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BayesSpamFilter", "root", "root");
			for (int i = 0; i < lowerTestData.length; i++) {
				ps = con.prepareStatement("select word_value from HamWords where words =?");
				ps.setString(1, lowerTestData[i]);
				rs = ps.executeQuery();
				double x = 0;
				if (rs.next()) {
					x = rs.getInt(1);
				}
				ps = con.prepareStatement("select count from MailCount where category='Ham'");
				rs = ps.executeQuery();
				double y = 0;
				if (rs.next()) {
					y = rs.getInt(1);
				}
				double condProbability = x / y;
				
				double count1 = 0;
				ps = con.prepareStatement("select word_value from HamWords where words =?");
				ps.setString(1, lowerTestData[i]);
				rs = ps.executeQuery();
				rs = ps.executeQuery();
				if (rs.next()) {
					count1 = rs.getInt(1);
				}
				double count2 = 0;
				ps = con.prepareStatement("select word_value from SpamWords where words =?");
				ps.setString(1, lowerTestData[i]);
				rs = ps.executeQuery();
				rs = ps.executeQuery();
				if (rs.next()) {
					count2 = rs.getInt(1);
				}
				double total = count1 + count2;
				double weightedAverage = (double) (((1 * 0.5) + (total * condProbability)) / (1 + total));
				p1 = p1 * weightedAverage;

			}
			ps = con.prepareStatement("select count from MailCount where category='Ham'");
			rs = ps.executeQuery();
			double hamDocuments=0;
			if (rs.next()) {
				hamDocuments= rs.getInt(1);
			}
			ps = con.prepareStatement("select count from MailCount where category='Spam'");
			rs = ps.executeQuery();
			double spamDocuments=0;
			if (rs.next()) {
				spamDocuments= rs.getInt(1);
			}
			catprob1=hamDocuments/(hamDocuments+spamDocuments);
			
			con.close();
			
		} catch (Exception e) {
			out.println(e);
		}

		try {

			PreparedStatement ps;
			ResultSet rs;
			Class.forName("com.mysql.jdbc.Driver");
			Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BayesSpamFilter", "root", "root");
			for (int i = 0; i < lowerTestData.length; i++) {
				ps = con.prepareStatement("select word_value from SpamWords where words =?");
				ps.setString(1, lowerTestData[i]);
				rs = ps.executeQuery();
				double x = 0;
				if (rs.next()) {
					x = rs.getInt(1);
				}
				ps = con.prepareStatement("select count from MailCount where category='Spam' ;");
				rs = ps.executeQuery();
				double y = 0;
				if (rs.next()) {
					y = rs.getInt(1);
				}
				double condProbability = x / y;
				double count1 = 0;
				ps = con.prepareStatement("select word_value from HamWords where words =?");
				ps.setString(1, lowerTestData[i]);
				rs = ps.executeQuery();
				if (rs.next()) {
					count1 = rs.getInt(1);
				}
				double count2 = 0;
				ps = con.prepareStatement("select word_value from SpamWords where words =?");
				ps.setString(1, lowerTestData[i]);
				rs = ps.executeQuery();
				if (rs.next()) {
					count2 = rs.getInt(1);
				}
				double total = count1 + count2;
				double weightedAverage = (double) (((1 * 0.5) + (total * condProbability)) / (1 + total));
				p2 = p2 * weightedAverage;

			}
			ps = con.prepareStatement("select count from MailCount where category='Ham'");
			rs = ps.executeQuery();
			double hamDocuments=0;
			if (rs.next()) {
				hamDocuments= rs.getInt(1);
			}
			ps = con.prepareStatement("select count from MailCount where category='Spam'");
			rs = ps.executeQuery();
			double spamDocuments=0;
			if (rs.next()) {
				spamDocuments= rs.getInt(1);
			}
			catprob2=spamDocuments/(hamDocuments+spamDocuments);
			
			con.close();

			
		} catch (Exception e) {
			out.println(e);
		}
		out.print("<body style=background:#1DA1F2><div align=center><h4 style=font-family:Helvetica Neue;color:white;>"
				+ "Ham Probability:" + p1*catprob1+"<br>");
		out.print("Spam Probability:" + p2*catprob2+"<br></div>");
		
		if ((p2*catprob2)>= (p1*catprob1)) {
			if ((p2*catprob2)>= (3 * p1*catprob1)) {
				out.println("<div align="+"center"+"><h2 style=font-family:sans-serif;color:white;>It's a Spam Mail !!!</h2></div>");
			} else {
				out.println("<div align="+"center"+"><h2>Status Unknown ? ?</h2></div>");
			}
		} else if ((p1*catprob1) > (p2*catprob2)) {
			out.println("<div align="+"center"+"><h2>It's a Ham Mail !!!</h2></div>");
		}
		out.println("</body>");
		
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
