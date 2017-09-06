<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="twitter4j.Query"%>
<%@page import="twitter4j.QueryResult"%>
<%@page import="twitter4j.Status"%>
<%@page import="twitter4j.Twitter"%>
<%@page import="twitter4j.TwitterException"%>
<%@page import="twitter4j.TwitterFactory"%>
<%@page import="twitter4j.conf.ConfigurationBuilder"%>
<%@page import="java.util.List"%>
<%@page import="java.sql.PreparedStatement"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>Result</title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<style>
		input[type=submit] {
    
		    background-color: #1d7ef2;
		    color: white;
		    padding: 8px 20px;
		    margin: 8px 0;
		    border: none;
		    border-radius: 4px;
		    cursor: pointer;
		    width: 10%;
		 }
		 input[type=submit]:hover {
    		background-color:#1d6cf2 ;
		}
	</style>
 
    
  </head>
<title>Insert title here</title>
</head>
<body style="background-color:#1DA1F2; height:515px; overflow:hidden;">
<div id="piechart" style="width: 31.5%; height: 515px; margin-left:68.5%"></div>
<%
		int positive=0,negative=0,unknown=0;
		String search=request.getParameter("search");
		ConfigurationBuilder cf = new ConfigurationBuilder();
		cf.setDebugEnabled(true).setOAuthConsumerKey("vWMRY8FaDc9rrIB2FalT7NBHt")
				.setOAuthConsumerSecret("87jF0yrFVZCrb6uRE9U8YIvEQCdOHm8R3UXfUBW0o4taZBOngF")
				.setOAuthAccessToken("2328407071-Wgo7KmaOIgdBvirdQ4ShQ6nyPMEhmLcUI7fWykT")
				.setOAuthAccessTokenSecret("mHC8WvrBQhcFXEaBVf1Io9TsF3kL1IAlXan5RvTCABqsN");
		TwitterFactory tf = new TwitterFactory(cf.build());
		String storetweetdata ="";
		
		Twitter twitter = tf.getInstance();
		try {
			Query query = new Query(search);
			query.setCount(50);
			QueryResult result;
			result = twitter.search(query);
			List<Status> tweets = result.getTweets();
			for (Status tweet : tweets) {
				String testData="@" +tweet.getText();
				
				String[] lowerTestData = testData.toLowerCase().split("[^a-zA-Z']+");
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
						s = "<b><font color=red>Negative !!!</font></b>";
						negative++;
					} else {
						s = "<b><font color=black>Unknown Status !!!</font></b>";
						unknown++;
					}
				} else if ((p1 * catprob1) > (p2 * catprob2)) {
					s = "<b><font color=Green>Positive !!!</font></b>";
					positive++;
				}
				storetweetdata=storetweetdata+"<p>"+testData+":    "+s+"</p>";
			}

		} catch (TwitterException te) {
			te.printStackTrace();
			System.out.println("Failed to search tweets: " + te.getMessage());
}
%>
	<div style="margin-left: 1%; margin-top:-515px; width:67%; height: 100%; float:left; word-wrap:break-word; font-family:Helvetica Neue; font-size:15px; 
			background-color:#1DA1F2; color:white; overflow-y: scroll 
			!important;">
			<!-- <textarea rows="30" cols="122" name="testData"  style="border: none;resize:none; font-family:Helvetica Neue; font-size:15px; 
			background-color:#1DA1F2; color:white;">-->
			<%=storetweetdata%>
			
		<!--	</textarea>-->
	</div>
	<br><br>
	<p id='p' hidden><%=positive%></p>
	<p id='n' hidden><%=negative%></p>
	<p id='u' hidden><%=unknown%></p>
	<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
      google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback(drawChart);
	  var p=document.getElementById('p').innerHTML;
	  var n=document.getElementById('n').innerHTML;
	  var u=document.getElementById('u').innerHTML;
	  
      function drawChart() {

        var data = google.visualization.arrayToDataTable([
          ['Tweets', 'Value'],
          ['Positive',Number(p)],
          ['Negative',Number(n)],
          ['Unkown',Number(u)]
         ]);

        var options = {
          title: 'Tweets Clasification'
        };

        var chart = new google.visualization.PieChart(document.getElementById('piechart'));

        chart.draw(data, options);
      }
    </script>
	
</body>
</html>