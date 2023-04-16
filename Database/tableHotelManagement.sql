CREATE DATABASE HotelManagement
GO
USE HotelManagement
GO

CREATE TABLE EMPLOYEE(
	Employee_id varchar(20) constraint PK_employee primary key, 
	Employee_name nvarchar(50) not null,
	Gender nvarchar(6),
	Birthday date check (DATEDIFF(year, Birthday, GETDATE())>=18), --Nhân viên phải trên 18 tuổi
	Identify_Card varchar(20) not null check(len(Identify_Card)=12), --CCCD đúng định dạng
	Phone varchar(12) not null check(len(Phone)=10), 
	Mail varchar(50) check(Mail like'%@gmail.com'),
	Employee_address nvarchar(255)
);

CREATE TABLE ACCOUNT(
	Username varchar(20) constraint PK_account primary key,
	Pass varchar(20) not null check(len(Pass)>=6),
	Employee_id varchar(20) constraint FK_employee references EMPLOYEE(Employee_id)
	ON DELETE CASCADE -- Xóa tài khoản nhân viên thì thông tin nhân viên đó cũng bị xóa
);

CREATE TABLE CUSTOMER(
	Customer_id varchar(20) constraint PK_customer primary key, 
	Customer_name nvarchar(50) not null,
	Gender nvarchar(6),
	Birthday date check (DATEDIFF(year, Birthday, GETDATE())>=18), --Khách hàng phải trên 18 tuổi
	Identify_card varchar(20) not null check(len(Identify_Card)=12) , --CCCD đúng định dạng
	Phone varchar(10) not null check(len(Phone)=10),
	Mail varchar(50) check(Mail like'%@gmail.com'),
	Customer_address nvarchar(255)
);

CREATE TABLE TYPE_ROOM(
	Type_room_id varchar(20) constraint PK_typeroom primary key,
	Type_room_name nvarchar(50),
	Unit money, --VND
	Discount_room float --phần trăm giảm giá tiền phòng
);

CREATE TABLE ROOM(
	Room_id varchar(20) constraint PK_room primary key,
	Room_status bit DEFAULT 0,
	Room_type varchar(20) constraint FK_room references TYPE_ROOM(Type_room_id)
);

CREATE TABLE SERVICE_ROOM(
	Service_room_id varchar(20) constraint PK_service_room primary key,
	Service_room_name nvarchar(100),
	Unit money, --VND
	Discount_service float --phần trăm giảm giá tiền dịch vụ
);

CREATE TABLE BILL(
	Bill_id varchar(20) constraint PK_bill primary key,
	Pay_time datetime, --Xác định đã thanh toán, pay_time chính là thời gian thanh toán hóa đơn
	Employee_id varchar(20) constraint FK references EMPLOYEE(Employee_id),
	Payment_method nvarchar(20), -- Phương thức thanh toán 
	Total_money money, --Tạo triggers tự động tính tổng tiền gộp số tiền dịch vụ và số tiền phòng, nhớ trừ ra
);

CREATE TABLE DETAILS_BILL(
	Details_bill_id varchar(20) constraint PK_details_bill primary key,
	Total_day int,
	Bill_id varchar(20) constraint FK_bill_id references BILL(Bill_id)
	ON DELETE CASCADE -- Khi khách hàng hủy đặt phòng hoặc k tới nhận phòng thì xóa Bill_ID và các dữ liệu liên quan đến BILL_id này đều bị xóa
);

CREATE TABLE DETAILS_RESERVED(
	Customer_id varchar(20) constraint FK_customer_id references CUSTOMER(Customer_id),
	Room_id varchar(20) constraint FK_room_id_reserved references ROOM(room_id),
	Details_bill_id varchar(20) constraint FK_details_bill_id_reserved references DETAILS_BILL(Details_bill_id)
	ON DELETE CASCADE, -- Khi khách hàng hủy đặt phòng hoặc k tới nhận phòng thì xóa Bill_ID và các dữ liệu liên quan đến BILL_id này đều bị
	Reserved_day int default 0,
	Date_check_in datetime, --Thời gian check-in phải có rõ ngày tháng năm giờ phút giây
	Constraint PK_details_reserved Primary Key (Customer_id, Room_id, Details_bill_id),
	Check_room_received bit DEFAULT 0, --Để xác định được đã tới nhận phòng hay chưa
	Deposit money, -- số tiền cọc 10% tiền phòng, nếu như thuê phòng trực tiếp thì deposit = null
	Check_paid_deposit bit, --Check xem đã trả tiền cọc hay chưa, nếu như thuê phòng trực tiếp thì = null 
	Date_create datetime,
);

CREATE TABLE DETAILS_USED_SERVICE(
	Room_id varchar(20) constraint FK_room_id_service references ROOM(room_id),
	Details_bill_id varchar(20) constraint FK_details_bill_id_service references DETAILS_BILL(Details_bill_id)
	ON DELETE CASCADE,
	Service_room_id varchar(20) constraint FK_service_room_id references SERVICE_ROOM(Service_room_id),
	Number_of_service int default 0,
	Date_used datetime,
	Constraint FK_details_used_service Primary Key (Room_id, Details_bill_id, Service_room_id)
);

-- Bảng TRACKING_LOG để ghi nhận lịch sử thay đổi khi thêm khách hàng hoặc xóa khách hàng nhằm tránh mất dữ liệu khách hàng đã từng đặt phòng
CREATE TABLE TRACKING_LOG(
	Id int DEFAULT 1 constraint PK_trackinglog primary key,
	Customer_id varchar(20), 
	Customer_name nvarchar(50), 
	Identify_card varchar(20) not null check(len(Identify_Card)=12),
	Operation char(3),
	Updated_at datetime,
);