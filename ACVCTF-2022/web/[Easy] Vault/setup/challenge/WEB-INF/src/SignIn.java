import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.Base64;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class SignIn extends HttpServlet{
	private static final Logger logger = LogManager.getLogger(SignIn.class);
    public void service(HttpServletRequest req, HttpServletResponse res)throws ServletException,IOException{
    	String username = req.getParameter("username");
    	String password = req.getParameter("password");
        if(username.equals("admin") && password.equals("dFe4@cVo06%")){
            HttpSession session=req.getSession();  
            session.setAttribute("username", username);
            RequestDispatcher rd =  req.getRequestDispatcher("home.jsp"); 
            rd.forward(req, res);
        }
        else{
            int count;
        	HttpSession session=req.getSession();
        	if (session.getAttribute("limit") == null)
            {
                session.setAttribute("limit", 0);
                res.sendRedirect("/?err=Invalid_Credentials");
            }
            else
            {
                try{
                 count = (Integer) session.getAttribute("limit");
                 if(count >= 10){
                    //Behind HeistFirewall
                    String ip =  req.getHeader("X-FORWARDED-FOR");
                    //Log the malicious attempt
                    logger.error("Malicious event detected from ip: ", ip);
                    res.sendRedirect("/blocked.jsp");
                }
                else{
                    System.out.println(count++);
                    session.setAttribute("limit", count++);
                    res.sendRedirect("/?err=Invalid_Credentials");
                }
            }
                catch (Exception e){
                    res.sendRedirect("/?err=Invalid_Credentials");
                }
            }
        }
    }
}