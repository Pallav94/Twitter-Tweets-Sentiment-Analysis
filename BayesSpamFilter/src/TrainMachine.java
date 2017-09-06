

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class TrainMachine
 */
@WebServlet("/TrainMachine")
public class TrainMachine extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public TrainMachine() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	@SuppressWarnings("resource")
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		String sampleData=request.getParameter("sampleData");
		String category=request.getParameter("category");
		String wordData[]=sampleData.toLowerCase().split("[^a-zA-Z']+");
		if(category.equals("Ham")){
			try{  
				
				Class.forName("com.mysql.jdbc.Driver");  
				Connection con=DriverManager.getConnection(  
				"jdbc:mysql://localhost:3306/BayesSpamFilter","root","root");  
				PreparedStatement ps=con.prepareStatement("select count from MailCount where category ='Ham'");
				ResultSet rs=ps.executeQuery();
				int value1=0;
				if(rs.next()){  
					value1=rs.getInt(1);
				}
				ps=con.prepareStatement("update MailCount set count=? where category='Ham'");
				ps.setInt(1, value1+1);
				ps.executeUpdate();
				
				for(int i=0;i<wordData.length;i++){
				    ps=con.prepareStatement("select word_value from HamWords where words =?");  
					ps.setString(1, wordData[i]);
					rs=ps.executeQuery();
					int value=0;
					if(rs.next()){  
						value=rs.getInt(1);
					}
					if(value==0){
						ps=con.prepareStatement("insert into HamWords values(?,?)");  
						ps.setString(1, wordData[i]);
						ps.setInt(2, 1);
				        ps.executeUpdate();  
					}
					else if(value>0){
						
						ps=con.prepareStatement("update HamWords set word_value=? where words=?");
						ps.setInt(1, value+1);
						ps.setString(2,wordData[i]);
						ps.executeUpdate();  
					}
					
				}
				con.close(); 
			   RequestDispatcher rd=request.getRequestDispatcher("/trainMachine.html");  
			   rd.include(request, response);  
			}catch(Exception e){ System.out.println(e);}  
			
			} 
		else if(category.equals("Spam")){
			try{  
				
				Class.forName("com.mysql.jdbc.Driver");  
				Connection con=DriverManager.getConnection(  
				"jdbc:mysql://localhost:3306/BayesSpamFilter","root","root");  
				
				PreparedStatement ps=con.prepareStatement("select count from MailCount where category ='Spam'");
				ResultSet rs=ps.executeQuery();
				int value1=0;
				if(rs.next()){  
					value1=rs.getInt(1);
				}
				ps=con.prepareStatement("update MailCount set count=? where category='Spam'");
				ps.setInt(1, value1+1);
				ps.executeUpdate();
				
				for(int i=0;i<wordData.length;i++){
					ps=con.prepareStatement("select word_value from SpamWords where words =?");  
					ps.setString(1, wordData[i]);
					rs=ps.executeQuery();
					int value=0;
					if(rs.next()){  
						value=rs.getInt(1);
					}
					if(value==0){
						ps=con.prepareStatement("insert into SpamWords values(?,?)");  
						ps.setString(1, wordData[i]);
						ps.setInt(2, 1);
				        ps.executeUpdate(); 
				        
					}
					else if(value>0){
						
						ps=con.prepareStatement("update SpamWords set word_value=? where words=?");
						ps.setInt(1, value+1);
						ps.setString(2,wordData[i]);
						ps.executeUpdate(); 
					    
					}
					
				}
					con.close();
					RequestDispatcher rd=request.getRequestDispatcher("/trainMachine.html");  
					   rd.include(request, response);
			}catch(Exception e){ System.out.println(e);}  
			
			}
		
}
		
		
	

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
		
	}

}
