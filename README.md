**Sales Data Analysis**   

📌 **Project Overview**  
This project explores sales transaction data using SQL in PostgreSQL. It provides key insights into total sales, regional sales trends, customer behavior, and delivery performance and more. 

**Key Insights & Analysis**  

1. firstly I observed City and Region Mismatching. Corrected it by Updatind Region Column be like:
     UPDATE sales  
          SET region = CASE  
              WHEN city IN ('Ahmedabad', 'Mumbai', 'Pune') THEN 'West'  
              WHEN city IN ('Bangalore', 'Chennai', 'Hyderabad') THEN 'South'  
              WHEN city IN ('Delhi', 'Jaipur', 'Lucknow') THEN 'North'  
              WHEN city = 'Kolkata' THEN 'East'  
              ELSE 'Unknown'  
          END;  
   
