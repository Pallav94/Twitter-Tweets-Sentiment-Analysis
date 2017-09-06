<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<!DOCTYPE bodybackground: PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>Negative Words</title>
	<style>
		a,h1,h3{
			font-family: Helvetica Neue;
			color: white;
		}
		table, th, td {
    		border: 1px solid white;
			border-spacing: 0px;
		}
	</style>
</head>
<body style="background-color:#1DA1F2;">
<%
	String driverName = "com.mysql.jdbc.Driver";
	String connectionUrl = "jdbc:mysql://localhost:3306/";
	String dbName = "BayesSpamFilter";
	String userId = "root";
	String password = "root";

	try {
		Class.forName(driverName);
	} catch (ClassNotFoundException e) {
		e.printStackTrace();
	}

	Connection connection = null;
	Statement statement = null;
	ResultSet resultSet = null;
%>

<h1 align="center"><font><strong>List Of Negative Words</strong></font></h1>
<table  align="center" width="400">
<tr>

</tr>
<tr>
<th><h3><b>Word</b></h3></th>
<th><h3><b>Count</b></h3></th>
</tr>

<%
	try {
			connection = DriverManager.getConnection(connectionUrl + dbName, userId, password);
			statement = connection.createStatement();
			String sql = "SELECT * FROM SpamWords";

			resultSet = statement.executeQuery(sql);
			while (resultSet.next()) {
%>
<tr>
<td><h3><%=resultSet.getString(1)%></h3></td>
<td><h3><%=resultSet.getInt(2)%></h3></td>
</tr>

<%
	}

		} catch (Exception e) {
			e.printStackTrace();
		}
%>
</table>
<span style="position: absolute; top: 5pt; left: 5pt;"><a
	href="trainMachine.html" style="text-decoration: none;"
	target="_parent"><b>Settings</b></a></span>
<span style="position: absolute; top: 5pt; right: 5pt;"><a
	href="FinalFrame.html" style="text-decoration: none;"
	target="_parent"><b>Home</b></a></span>
</body>
</html>