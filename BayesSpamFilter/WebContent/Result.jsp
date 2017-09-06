<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.servlet.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Result</title>
<style>
	h4,h2 {
		font-family: Helvetica Neue;
		color: white;
	}
</style>
<title>Insert title here</title>
</head>
<body style="background: #1DA1F2; overflow:hidden">

	<%
		String testData = request.getParameter("testData");
		String[] lowerTestData = testData.toLowerCase().split("[^\\p{L}0-9']+");
		double p1 = 1;
		double p2 = 1;
		double catprob1 = 0;
		double catprob2 = 0;
		try {

			PreparedStatement ps;
			ResultSet rs;
			Class.forName("com.mysql.jdbc.Driver");
			Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BayesSpamFilter", "root",
					"root");
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
				//out.println(x+" "+y);
				//out.println(condProbability);

				double count1 = 0;
				ps = con.prepareStatement("select word_value from HamWords where words =?");
				ps.setString(1, lowerTestData[i]);
				rs = ps.executeQuery();
				//rs = ps.executeQuery();
				if (rs.next()) {
					count1 = rs.getInt(1);
				}
				double count2 = 0;
				ps = con.prepareStatement("select word_value from SpamWords where words =?");
				ps.setString(1, lowerTestData[i]);
				rs = ps.executeQuery();
				//rs = ps.executeQuery();
				if (rs.next()) {
					count2 = rs.getInt(1);
				}
				double total = count1 + count2;
				double weightedAverage = (double) (((1 * 0.5) + (total * condProbability)) / (1 + total));
				//out.println(weightedAverage);
				p1 = p1 * weightedAverage;
				

			}
			ps = con.prepareStatement("select count from MailCount where category='Ham'");
			rs = ps.executeQuery();
			double hamDocuments = 0;
			if (rs.next()) {
				hamDocuments = rs.getInt(1);
			}
			ps = con.prepareStatement("select count from MailCount where category='Spam'");
			rs = ps.executeQuery();
			double spamDocuments = 0;
			if (rs.next()) {
				spamDocuments = rs.getInt(1);
			}
			catprob1 = hamDocuments / (hamDocuments + spamDocuments);

			con.close();

		} catch (Exception e) {
			out.println(e);
		}

		try {

			PreparedStatement ps;
			ResultSet rs;
			Class.forName("com.mysql.jdbc.Driver");
			Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BayesSpamFilter", "root",
					"root");
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
			double hamDocuments = 0;
			if (rs.next()) {
				hamDocuments = rs.getInt(1);
			}
			ps = con.prepareStatement("select count from MailCount where category='Spam'");
			rs = ps.executeQuery();
			double spamDocuments = 0;
			if (rs.next()) {
				spamDocuments = rs.getInt(1);
			}
			catprob2 = spamDocuments / (hamDocuments + spamDocuments);

			con.close();

		} catch (Exception e) {
			out.println(e);
		}
		String s = null;
		if ((p2 * catprob2) >= (p1 * catprob1)) {
			if ((p2 * catprob2) > (3 * p1 * catprob1)) {
				s = "Negative Views !!!";
			} else {
				s = "Unknown Status !!!";
			}
		} else if ((p1 * catprob1) > (p2 * catprob2)) {
			s = "Positive Views !!!";
		}
	%>
	<div align="center">
		<h4>Positive Probability:<%=p1*catprob1%></h4>
		<h4>Negative Probability:<%=p2*catprob2%></h4>
		<h2><%=s%></h2>
	</div>
</body>
</html>