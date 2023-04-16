USE HotelManagement
GO

INSERT INTO EMPLOYEE(Employee_id, Employee_name, Gender, Birthday, Identify_Card, Phone, Mail, Employee_address)
VALUES
('NV01', N'Nguyễn Văn Hào', 'Nam', '2003-10-09', '012345488233', '0352500861', 'haovan@gmail.com', 'HCM'),
('NV02', N'Nguyễn Phú Thành', 'Nam', '2003-05-15', '345673883233', '0126438487', 'thanh@gmail.com', 'HCM'),
('NV03', N'Lê Thúy An', N'Nữ', '1975-04-30', '864471718234', '0986421373', 'an@gmail.com', 'HCM'),
('NV04', N'Nguyễn Văn An', 'Nam', '1990-01-01', '123456789012', '0987654321', 'nva@gmail.com', N'Hà Nội'),
('NV05', N'Trần Thị Bống', 'Nữ', '1991-02-02', '234567890123', '0976543210', 'ttb@gmail.com', N'Hải Phòng'),
('NV06', N'Lê Văn Cường', 'Nam', '1992-03-03', '345678901234', '0965432109', 'lvc@gmail.com', N'Đà Nẵng'),
('NV07', N'Phạm Thị Dung', N'Nữ','1993-04-04','456789012345','0954321098','ptd@gmail.com', N'Huế'),
('NV08', N'Hoàng Văn Nam','Nam','1994-05-05','567890123456','0943210987','hve@gmail.com', N'Nha Trang'),
('NV09', N'Ngô Thị Phước', N'Nữ','1995-06-06','678901234567','0932109876','ntf@gmail.com', N'Cần Thơ')

INSERT INTO ACCOUNT(Username, Pass, Employee_id)
VALUES 
('hao123', '123456', 'NV01'),
('thanh234', '234567', 'NV02'),
('an345', '345678', 'NV03'),
('an456', '456789', 'NV04'),
('bong567', '567890', 'NV05'),
('cuong678', '678901', 'NV06'),
('dung789', '789012', 'NV07'),
('nam890', '890123', 'NV08'),
('phuoc901','901234','NV09');

INSERT INTO CUSTOMER(Customer_id, Customer_name, Gender, Birthday, Identify_card, Phone, Mail, Customer_address)
VALUES
('KH0001', N'Vương Dinh Hiếu', 'Nam', '2003-01-01', '123483573817','0846362655','hieu@gmail.com','HCM'),
('KH0002', N'Võ Hoàng Bửu', 'Nam','2003-12-03', '012736736462','0123448344','buu@gmail.com', N'Quảng Ngãi'),
('KH0003', N'Lê Vân Bình','Nam','2001-03-03','345678912345','0932109876','binhle@gmail.com', N'Đà Nẵng'),
('KH0004', N'Trần Văn Dũng', 'Nam', '1999-05-05', '567891234567', '0910987654','dungtran@gmail.com', N'Hải Phòng'),
('KH0005', N'Nguyễn Thị Mai Hương', N'Nữ','1998-06-06','678912345678','0909876543','huongnguyen@gmail.com', N'Huế'),
('KH0006', N'Lê Thị Ngọc Anh', N'Nữ', '1996-08-08', '891234567890', '0908765432','ngocanhle@gmail.com',N'Cần Thơ'),
('KH0007', N'Nguyễn Văn Quang','Nam','1995-09-09','912345678901','0897654321','quangnguyen@gmail.com', N'Đà Lạt')

INSERT INTO TYPE_ROOM(Type_room_id, Type_room_name, Unit, Discount_room)
VALUES
('STD', N'Phòng Standard', 375000, 0),
('SUP', N'Phòng Superior', 525000, 0.3),
('DLX', N'Phòng Deluxe', 885000, 0.15),
('SUT', N'Phòng Suite', 1999000, 0.25),
('CNT', N'Phòng Connecting', 1500000, 0),
('TWB', N'Phòng Twin Bed Room', 700000, 0),
('DOB', N'Phòng Double Bed Room', 445000, 0),
('TRB', N'Phòng Triple Bed Room', 900000, 0);

INSERT INTO ROOM(Room_id, Room_status, Room_type)
VALUES
('STD001', '0', 'STD'),
('STD002', '0', 'STD'),
('STD003', '0', 'STD'),

('SUP001', '0', 'SUP'),
('SUP002', '0', 'SUP'),
('SUP003', '0', 'SUP'),

('DLX001', '0', 'DLX'),
('DLX002', '0', 'DLX'),
('DLX003', '0', 'DLX'),

('SUT001', '1', 'SUT'),
('SUT002', '1', 'SUT'),
('SUT003', '1', 'SUT'),

('CNT001', '1', 'CNT'),
('CNT002', '1', 'CNT'),

('TWB001', '1', 'TWB'),
('TWB002', '1', 'TWB'),
('TWB003', '1', 'TWB'),

('DOB001', '1', 'DOB'),
('DOB002', '1', 'DOB'),
('DOB003', '1', 'DOB'),

('TRB001', '1', 'TRB'),
('TRB002', '1', 'TRB'),
('TRB003', '1', 'TRB');

INSERT INTO SERVICE_ROOM(Service_room_id, Service_room_name, Unit, Discount_service)
VALUES
('SVC001', N'Giặt là', 40000, 0),
('SVC002', N'Spa', 450000, 0.2),
('SVC003', N'Thuê xe', 200000, 0.3),
('SVC004', N'Đưa đón sân bay', 200000, 0.1),
('SVC005', N'Buffet sáng', 300000, 0),
('SVC006', N'Hoa quả', 200000, 0),
('SVC007', N'Nước ngọt', 100000, 0);

INSERT INTO BILL(Bill_id, Pay_time, Employee_id, Payment_method)
VALUES 
('Bill0001', '2023-03-17 11:50:00', 'NV01', N'Chuyển khoản'),
--('Bill0002', , , ), --  Xóa do kiểm tra ngày hiện tại quá hạn check in 12h hôm sau vẫn chưa nhận phòng
('Bill0003', '2023-03-18 11:35:00', 'NV03', N'Chuyển khoản'),
('Bill0004', '2023-03-18 8:35:00', 'NV04', N'Tiền mặt'),
('Bill0005', '2023-03-18 9:35:00', 'NV05', N'Chuyển khoản'),
('Bill0006', '2023-03-18 9:50:00', 'NV06', N'Tiền mặt'),
('Bill0007', '2023-03-18 11:05:00', 'NV07', N'Chuyển khoản');

INSERT INTO DETAILS_BILL(Details_bill_id, Total_day, Bill_id)
VALUES
('Bill0001A', 1, 'Bill0001'), 
--('Bill0002A', 2, 'Bill0002'), -- Xóa do kiểm tra ngày hiện tại quá hạn check in 12h hôm sau vẫn chưa nhận phòng
('Bill0003A', 3, 'Bill0003'), 
('Bill0004A', 1, 'Bill0004'), 
('Bill0005A', 2, 'Bill0005'), 
('Bill0006A', 1, 'Bill0006'),
('Bill0007A', 1, 'Bill0007');

INSERT INTO DETAILS_RESERVED(Customer_id, Room_id, Details_bill_id, Reserved_day, Date_check_in, Check_room_received, Check_paid_deposit, Date_create)
VALUES ('KH0007', 'DLX001', 'Bill0007A', 1, '2023-03-17 14:10:00', '1', 0, '2023-03-17 14:10:00')
('KH0001', 'STD001', 'Bill0001A', 1, '2023-03-16 8:00:00', '1', 1, '2023-03-14 19:00:00'),
--('KH0002', 'STD002', 'Bill0002A', 2, '2023-03-17 9:00:00', '0', 1, '2023-03-15 08:00:00'), --Xóa do kiểm tra ngày hiện tại quá hạn check in 12h hôm sau vẫn chưa nhận phòng
('KH0003', 'STD003', 'Bill0003A', 3, '2023-03-17 10:30:00', '1', 1, '2023-03-13 16:00:00'),

('KH0004', 'SUP001', 'Bill0004A', 1, '2023-03-17 8:30:00', '1', 1, '2023-03-14 18:00:00'),
('KH0005', 'SUP002', 'Bill0005A', 2, '2023-03-17 9:30:00', '1', 0, '2023-03-17 9:30:00'),
('KH0006', 'SUP003', 'Bill0006A', 1, '2023-03-17 9:45:00', '1', 0, '2023-03-17 9:45:00'),

('KH0007', 'DLX001', 'Bill0007A', 1, '2023-03-17 14:10:00', '1', 0, '2023-03-17 14:10:00');


INSERT INTO DETAILS_USED_SERVICE(Room_id, Details_bill_id, Service_room_id, Number_of_service, Date_used)
VALUES ('DLX001','Bill0007A', 'SVC001', 1, '2023-03-17 17:00:00')
('STD001','Bill0001A', 'SVC002', 1, '2023-03-16 15:15:00'),
--('STD002','Bill0002A', , , ), -- đặt cọc rồi mà quá hạn check in vẫn chưa nhận phòng
('STD003','Bill0003A', 'SVC001', 1, '2023-03-17 14:30:00'),

('SUP001','Bill0004A', 'SVC001', 1, '2023-03-17 16:30:00'),
('SUP002','Bill0005A', 'SVC001', 1, '2023-03-17 17:30:00'),
('SUP003','Bill0006A', 'SVC001', 1, '2023-03-17 14:45:00'),

('DLX001','Bill0007A', 'SVC001', 1, '2023-03-17 17:00:00');