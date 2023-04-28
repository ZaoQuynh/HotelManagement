USE HotelManagement
GO

CREATE VIEW ROOMMANAGEMENTSSS AS             --Hiển thị tất cả Room_status          
SELECT r.Room_id, 
	   r.Room_type, 
       ty.Type_room_name, 
       r.Room_status, 
       ty.Unit AS Type_unit, 
       se.Service_room_name,
       se.Unit AS Service_unit,
	   de.Number_of_service AS Number_service
FROM ROOM r 
LEFT JOIN TYPE_ROOM ty ON r.Room_type = ty.Type_room_id
LEFT JOIN DETAILS_USED_SERVICE de ON  de.Room_id = r.Room_id
LEFT JOIN SERVICE_ROOM se ON se.Service_room_id = de.Service_room_id


--1: ĐÃ ĐẶT , 0: TRỐNG

CREATE VIEW BOOKING AS                          
SELECT r.Room_id, 
	   r.Room_type, 
       ty.Type_room_name, 
       r.Room_status, 
       ty.Unit AS Type_unit, 
       se.Service_room_name,
       se.Unit AS Service_unit,
	   de.Number_of_service AS Number_service
FROM ROOM r 
LEFT JOIN TYPE_ROOM ty ON r.Room_type = ty.Type_room_id
LEFT JOIN DETAILS_USED_SERVICE de ON  de.Room_id = r.Room_id
LEFT JOIN SERVICE_ROOM se ON se.Service_room_id = de.Service_room_id
WHERE r.Room_status = '1';

--

CREATE VIEW EMPTYROOM AS                          
SELECT r.Room_id, 
	   r.Room_type, 
       ty.Type_room_name, 
       r.Room_status, 
       ty.Unit AS Type_unit, 
       se.Service_room_name,
       se.Unit AS Service_unit,
	   de.Number_of_service AS Number_service
FROM ROOM r 
LEFT JOIN TYPE_ROOM ty ON r.Room_type = ty.Type_room_id
LEFT JOIN DETAILS_USED_SERVICE de ON  de.Room_id = r.Room_id
LEFT JOIN SERVICE_ROOM se ON se.Service_room_id = de.Service_room_id
WHERE r.Room_status = '0';

----------------------------------

-- 2 TRƯỜNG HỢP : DANH SÁCH PHÒNG THEO LOẠI : LIỆT KÊ VÀ ĐẾM

CREATE VIEW ROOMLISTBYROOMTYPES AS
SELECT  r.Room_type,
	    r.Room_id,
	    ty.Type_room_name
FROM ROOM r
JOIN TYPE_ROOM ty ON r.Room_type = ty.Type_room_id

--//

CREATE VIEW ROOMLISTBYROOMTYPESNUMER AS
SELECT Room_type, COUNT(*) AS Number_room
FROM ROOM
GROUP BY Room_type;

-------------------------------------

CREATE VIEW BOOKINGMANAGEMENTSS AS
SELECT det. details_bill_id, cus.Customer_name, cus.Phone, em.Employee_name
FROM DETAILS_RESERVED det
JOIN CUSTOMER cus ON det. Customer_id = cus. Customer_id
JOIN DETAILS_BILL detbi on det.Details_bill_id = detbi.Details_bill_id
JOIN BILL bi ON bi.Bill_id = detbi.Bill_id
JOIN EMPLOYEE em ON em.Employee_id = bi.Employee_id

----------------------------------------


--TRƯỜNG HỢP LÀ XÁC ĐỊNH THANH TOÁN BẰNG Pay_time

CREATE VIEW PAYMENT_PAID AS
SELECT bi.Bill_id, cus.Customer_name, COUNT(DISTINCT detre.Room_id) AS Number_of_room, 
       COUNT(DISTINCT detuseser.Service_room_id) AS Number_of_service, bi.Pay_time, bi.Payment_method
FROM BILL bi
JOIN DETAILS_BILL detbi ON detbi.Bill_id = bi.Bill_id
JOIN DETAILS_RESERVED detre ON detre.Details_bill_id = detbi.Details_bill_id
JOIN CUSTOMER cus ON cus.Customer_id = detre.Customer_id
JOIN DETAILS_USED_SERVICE detuseser ON detuseser.Details_bill_id = detre.Details_bill_id
WHERE bi.Pay_time IS NOT NULL
GROUP BY bi.Bill_id, cus.Customer_name, bi.Pay_time, bi.Payment_method;          -- display paid bills  	-- hiển thị hóa đơn đã thanh toán

----

CREATE VIEW PAYMENT_UNPAID AS
SELECT bi.Bill_id, cus.Customer_name, COUNT(DISTINCT detre.Room_id) AS Number_of_room, 
       COUNT(DISTINCT detuseser.Service_room_id) AS Number_of_service, bi.Pay_time, bi.Payment_method
FROM BILL bi
JOIN DETAILS_BILL detbi ON detbi.Bill_id = bi.Bill_id
JOIN DETAILS_RESERVED detre ON detre.Details_bill_id = detbi.Details_bill_id
JOIN CUSTOMER cus ON cus.Customer_id = detre.Customer_id
JOIN DETAILS_USED_SERVICE detuseser ON detuseser.Details_bill_id = detre.Details_bill_id
WHERE bi.Pay_time IS NULL
GROUP BY bi.Bill_id, cus.Customer_name, bi.Pay_time, bi.Payment_method;            --  display unpaid bills  -- hiển thị hóa đơn chưa thanh toán


--//
--TRƯỜNG HỢP LÀ XÁC ĐỊNH THANH TOÁN BẰNG Payment_method
 
CREATE VIEW BILLMANAGEMENTSS  AS
SELECT
	    bi.Bill_id, cus.Customer_name, COUNT(DISTINCT detre.Room_id) AS Number_of_room, 
       COUNT(DISTINCT detuseser.Service_room_id) AS Number_of_service, bi.Pay_time, bi.Payment_method,
	CASE
    	WHEN Payment_method = 'Tiền mặt' OR Payment_method = 'Thẻ'
        	 THEN 'unpaid bills'
    	ELSE 'paid bills'
	END AS Payment_status
FROM BILL bi
JOIN DETAILS_BILL detbi ON detbi.Bill_id = bi.Bill_id
JOIN DETAILS_RESERVED detre ON detre.Details_bill_id = detbi.Details_bill_id
JOIN CUSTOMER cus ON cus.Customer_id = detre.Customer_id
JOIN DETAILS_USED_SERVICE detuseser ON detuseser.Details_bill_id = detre.Details_bill_id
GROUP BY bi.Bill_id, cus.Customer_name, bi.Pay_time, bi.Payment_method;
 
--SELECT * FROM BILLMANAGEMENTSS; -- hiển thị trạng thái hóa đơn có trường Payment_status
--SELECT * FROM BILLMANAGEMENTSS WHERE Payment_status = 'paid bills'; -- display paid bills  	-- hiển thị hóa đơn đã thanh toán
--SELECT * FROM BILLMANAGEMENTSS WHERE Payment_status = 'unpaid bills'; -- display unpaid bills  -- hiển thị hóa đơn chưa thanh toán


--//
--Danh sách hóa đơn (không trường Payment_status)

CREATE VIEW BILLMANAGEMENTT AS
SELECT bi.Bill_id, cus.Customer_name, COUNT(DISTINCT detre.Room_id) AS Number_of_room, 
       COUNT(DISTINCT detuseser.Service_room_id) AS Number_of_service, bi.Pay_time, bi.Payment_method
FROM BILL bi
JOIN DETAILS_BILL detbi ON detbi.Bill_id = bi.Bill_id
JOIN DETAILS_RESERVED detre ON detre.Details_bill_id = detbi.Details_bill_id
JOIN CUSTOMER cus ON cus.Customer_id = detre.Customer_id
JOIN DETAILS_USED_SERVICE detuseser ON detuseser.Details_bill_id = detre.Details_bill_id
GROUP BY bi.Bill_id, cus.Customer_name, bi.Pay_time, bi.Payment_method;

CREATE VIEW CURRENT_CUSTOMER AS
SELECT *
FROM Customer
WHERE Customer.customer_id IN (Select  DISTINCT customer_id 
				From 
				DETAILS_RESERVED
				JOIN DETAILS_BILL ON DETAILS_BILL.Details_bill_id = DETAILS_RESERVED.Details_bill_id
				JOIN Bill ON Bill.Bill_id = DETAILS_BILL.Bill_id
				WHERE DETAILS_RESERVED.Customer_id = Customer.customer_id
				AND GETDATE() >= DETAILS_RESERVED.Date_check_in
				AND Bill.Pay_time IS NULL
				) 

--View chứa thông tin khác hàng đã check in thì trong chi tiết đặt phòng giá trị Check_room_received được ghi nhận mang giá trị 1
CREATE VIEW CHECKED_CUSTOMER AS
SELECT *
FROM Customer  
WHERE Customer.customer_id IN (SELECT  DISTINCT customer_id
							   FROM DETAILS_RESERVED
							   WHERE Check_room_received ='1');

--View chứa thông tin khác hàng chưa check in thì trong chi tiết đặt phòng giá trị Check_room_received được ghi nhận mang giá trị 0
CREATE VIEW UNCHECKED_CUSTOMER AS
SELECT *
FROM Customer  
WHERE Customer.customer_id IN (SELECT  DISTINCT customer_id
							   FROM DETAILS_RESERVED
							   WHERE Check_room_received = '0');

-- View chứa thông tin về khách hàng đã thanh toán hóa đơn, ở Bill giá trị Pay_time là khác Null
CREATE VIEW PAID_CUSTOMER AS
SELECT *
FROM Customer
WHERE Customer.customer_id IN (Select  DISTINCT customer_id 
				From 
				DETAILS_RESERVED
				JOIN DETAILS_BILL ON DETAILS_RESERVED.Details_bill_id = DETAILS_BILL.Details_bill_id
				JOIN Bill ON Bill.Bill_id = DETAILS_BILL.Bill_id
				WHERE Bill.Pay_time IS NOT NULL
				) 	

-- View chứa thông tin về khách hàng chưa thanh toán hóa đơn, ở Bill giá trị Pay_time là Null
CREATE VIEW UNPAID_CUSTOMER AS
SELECT *
FROM Customer
WHERE Customer.customer_id IN (Select  DISTINCT customer_id
				From 
				DETAILS_RESERVED
				JOIN DETAILS_BILL ON DETAILS_RESERVED.Details_bill_id = DETAILS_BILL.Details_bill_id
				JOIN Bill ON Bill.Bill_id = DETAILS_BILL.Bill_id
				WHERE Bill.Pay_time IS NULL
				) 	

-- View chứa thông tin doanh thu theo năm, tháng, ngày, loại, phòng, loại dịch vụ và tổng doanh thu
CREATE VIEW REVENUE AS
SELECT
	YEAR(Bill.Pay_time) AS Year_bill,
	MONTH(Bill.Pay_time) AS Month_bill,
	Type_Room.Type_room_name,
	SERVICE_ROOM.Service_room_name,
	SUM(Bill.Total_money) AS Revenue
FROM
	Bill
	JOIN DETAILS_BILL ON Bill.Bill_id = DETAILS_BILL.Bill_id
	JOIN DETAILS_RESERVED ON DETAILS_RESERVED.Details_bill_id = DETAILS_BILL.Details_bill_id
	JOIN ROOM ON ROOM.Room_id = DETAILS_RESERVED.Room_id
	JOIN TYPE_ROOM ON TYPE_ROOM.Type_room_id = ROOM.Room_type
	-- Do có thể phòng đó không dùng dịch vụ nên kết ngoại
	LEFT JOIN DETAILS_USED_SERVICE ON DETAILS_USED_SERVICE.Details_bill_id = DETAILS_BILL.Details_bill_id 
	LEFT JOIN SERVICE_ROOM ON SERVICE_ROOM.Service_room_id = DETAILS_USED_SERVICE.Service_room_id
GROUP BY
	YEAR(Bill.Pay_time),
	MONTH(Bill.Pay_time),
	Type_Room.Type_room_name,
	SERVICE_ROOM.Service_room_name

-- Doanh thu theo loại phòng
CREATE VIEW REVENUE_BY_TYPE_ROOM AS
SELECT Year_bill, Month_bill, Type_room_name, SUM(Revenue) Revenue
FROM REVENUE
GROUP BY Year_bill, Month_bill, Type_room_name

-- Doanh thu theo dịch vụ
CREATE VIEW REVENUE_BY_TYPE_SERVICE AS
SELECT Year_bill, Month_bill, Service_room_name, SUM(Revenue) Revenue
FROM REVENUE
GROUP BY Year_bill, Month_bill, Service_room_name
