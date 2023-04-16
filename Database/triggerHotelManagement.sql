USE HotelManagement
GO
-------------- 1. Trigger cập nhật tình trạng phòng khi có người đặt
create trigger Update_status_room_reserved on Details_Reserved
after insert as
begin
	update Room
	set room_status=1
	from Room
	where Room.room_id = (select room_id from inserted ) 
end;


GO
-------------- 2. Trigger cập nhật tiền cọc phòng = 30% giá tiền phòng(đặt online)
create trigger Update_deposit on DETAILS_RESERVED
after insert
as
begin
	declare @deposit money, @date_create DateTime, @date_checkin DateTime, @details_bill_id varchar(20);

	select @date_create = Date_create, @date_checkin = Date_check_in, @details_bill_id =Details_bill_id from inserted;

    select @deposit = 0.3 * Unit
	from TYPE_ROOM tr 
	join ROOM r on tr.Type_room_id = r.Room_type
	join inserted ins on ins.Room_id = r.Room_id;

	--khi ngày tạo chi tiết đặt phòng khác với ngày check in thì đặt online -> cần tính cọc,
	--còn đặt offline thì ngày tạo chi tiết đặt phòng cũng là ngày check in luôn -> không cần cọc -> gán bằng 0
	if(@date_create <> @date_checkin)
		update DETAILS_RESERVED set Deposit = @deposit where DETAILS_RESERVED.Details_bill_id = @details_bill_id;
	else 
		update DETAILS_RESERVED set Deposit = 0 where DETAILS_RESERVED.Details_bill_id = @details_bill_id;
end;

GO
-------------- 3. Trigger tính tổng tiền cho hóa đơn khi cập nhật bảng chi tiết sử dụng dịch vụ(không cần bảng chi tiết đặt phòng vì mình
--đã có tổng số ngày ở rồi)
CREATE TRIGGER Calc_total_money_service ON DETAILS_USED_SERVICE 
AFTER INSERT, UPDATE
AS 
BEGIN 
--Khai báo biến
DECLARE @details_bill_id varchar(20), @money_service money, @disco float, @number_used_old int = 0, @number_used_new int;

-- Lấy mã chi tiết hóa đơn, số lượng sử dụng dịch vụ mới được cập nhật từ hàng vừa chèn
SELECT @details_bill_id = Details_bill_id, @number_used_new = Number_of_service FROM inserted

--Lấy số lượng sử dụng dịch vụ cũ vừa được xóa
select @number_used_old = Number_of_service from deleted where deleted.Details_bill_id = @details_bill_id;

--Tính tiền dịch vụ
SET @money_service = (SELECT  SUM(Unit * (@number_used_new - @number_used_old) * (1 - Discount_service) ) 
						FROM SERVICE_ROOM JOIN inserted ON SERVICE_ROOM.Service_room_id = inserted.Service_room_id
						WHERE inserted.Details_bill_id = @details_bill_id)

DECLARE @total_money_old money;
SELECT @total_money_old = Total_money FROM BILL WHERE Bill_id = (select Bill_id from DETAILS_BILL WHERE Details_bill_id = @details_bill_id)
-- Update the total_money in Bill table using details_bill_id 
UPDATE BILL 
SET Total_money = @total_money_old + @money_service
WHERE Bill_id = (SELECT bill_id 
					FROM Details_Bill 
					WHERE details_bill_id = @details_bill_id); 
END;

GO
-------------- 4. Trigger cập nhật trạng thái phòng thành 0 khi thanh toán
--Kiểm tra xem trong Bill mà ngày tạo khác null(đã thanh toán) thì kết bảng và đặt lại trạng thái phòng
create trigger Update_status_room_checkouted on Bill 
after update as
begin
	declare @bill_id varchar(20);
	select @bill_id = Bill_id from inserted where inserted.Pay_time is not null
	if(@bill_id is not null)
		update Room
		set Room_status = 0
		where Room.room_id in ( select room_id
								from Details_Reserved 
								where details_bill_id in ( select Details_bill_id
														   from DETAILS_BILL
														   where DETAILS_BILL.Bill_id = @bill_id ) )
end;

GO
-------------- 5. Trigger cập nhật số ngày đã đặt trước cho tổng số ngày trong chi tiết hóa đơn khi đặt thành công hoặc gia hạn thành công
CREATE TRIGGER Update_total_day ON DETAILS_RESERVED
AFTER INSERT, UPDATE
AS
BEGIN
  -- Declare a variable to store the detail bill id of the inserted or updated row
  DECLARE @details_bill_id varchar(20), @total_day int;
  -- Assign the value of detail bill id from the inserted table
  SELECT @details_bill_id = Details_bill_id, @total_day = Reserved_day FROM inserted;
  
  --cập nhật số ngày đã đặt trước cho tổng số ngày trong chi tiết hóa đơn 
  --khi mà đặt thành công hoặc gia hạn thành công
  UPDATE DETAILS_BILL
  SET Total_day = @total_day
  WHERE DETAILS_BILL.Details_bill_id = @details_bill_id;
END;


GO
-------------- 6. Trigger xóa khỏi Details_Reserved nếu sau 30 phút mà vẫn chưa chuyển tiền cọc(đặt online) 
create trigger Update_status_room_deposited on DETAILS_RESERVED
after update
as
begin
	--Xóa khỏi bảng Details_Reserved
	delete from DETAILS_RESERVED
	where GETDATE()> DATEADD(minute, 30, Date_create) 
		  and Check_paid_deposit = 0				   
		  and Date_create <> Date_check_in;
end;


GO
-------------- 7. Trigger update tình trạng phòng và xóa hóa đơn khi xóa chi tiết đặt phòng (do không chuyển cọc, do không nhận phòng)
create trigger Delete_bill_and_details_bill on DETAILS_RESERVED
after delete
as
begin
	
	update ROOM
	set Room_status = 0
	from Room join deleted on Room.Room_id = deleted.Room_id
	where ROOM.Room_id = deleted.Room_id;

	--xóa khỏi bảng Bill và Details_Bill
	delete from BILL where BILL.Bill_id in (select Bill_id  from DETAILS_BILL join deleted on  deleted.Details_bill_id = DETAILS_BILL.Details_bill_id);

	delete from DETAILS_BILL where DETAILS_BILL.Details_bill_id in (select old.Details_bill_id from deleted as old); 
	
	--không cần xóa trong Details_Used_Service vì khi xóa Details_bill_id trong Details_Bill sẽ tự 
	--động xóa (do delete cascade)
end;


GO
-------------- 8. Trigger cập nhật tiền phòng vào hóa đơn mỗi khi thêm, cập nhật ngày đặt phòng(trường hợp khách hàng không sử dụng dịch vụ) cho từng chi tiết đặt phòng
--ĐÃ TEST
CREATE TRIGGER Update_room_money ON DETAILS_RESERVED
AFTER INSERT, UPDATE
AS
BEGIN

  DECLARE  @details_bill_id varchar(20), @total_day int, @price money, @disco float, @total_money money = 0.0000, @total_day_old int = 0;

  SELECT @details_bill_id = inserted.Details_bill_id, @total_day = inserted.Reserved_day FROM inserted;

  SELECT @price = Unit, @disco =Discount_room FROM TYPE_ROOM JOIN ROOM ON TYPE_ROOM.Type_room_id = ROOM.Room_type
						JOIN DETAILS_RESERVED ON ROOM.Room_id = DETAILS_RESERVED.Room_id
						WHERE Details_Reserved.details_bill_id = @details_bill_id;

  select @total_day_old = Reserved_day from deleted where deleted.Details_bill_id = @details_bill_id;

  SELECT @total_money = Total_money FROM BILL WHERE BILL.Bill_id = (select Bill_id from DETAILS_BILL where DETAILS_BILL.Details_bill_id = @details_bill_id) and Total_money is not null
  --Cập nhật tiền phòng
  if(@total_day > @total_day_old)
	UPDATE BILL
	SET Total_money = @total_money + @price * (1 - @disco) * (@total_day - @total_day_old) - (select Deposit from DETAILS_RESERVED where Details_bill_id =  @details_bill_id)
	WHERE Bill_id = (SELECT bill_id 
					FROM Details_Bill 
					WHERE details_bill_id = @details_bill_id); 
END;


/*
--xóa khỏi chi tiết đặt phòng khi quá hạn check in đến 12h ngày hôm sau
create trigger Update_status_room_overcheckin on DETAILS_RESERVED
after insert, update as
begin
	delete from DETAILS_RESERVED where Check_room_received = 0 and GETDATE() > DATEADD(Day, 1, Date_check_in);
end;
*/

GO
-------------- 9. Trigger tính thêm tiền vào trong hóa đơn nếu check in sớm hơn 14h (đối với khách hàng đặt phòng online)
create trigger Update_total_money_checkin_early_onl on DETAILS_RESERVED
after update
as
begin
	--khai báo biến
	declare @date_checkin_new DateTime, @date_checkin_old DateTime, @room_id varchar(20), @price money, @total_money money = 0.0000, @details_bill_id varchar(20), @bill_id varchar(20);

	--lấy các giá trị cho biến
	select @date_checkin_new = Date_check_in, @room_id = Room_id, @details_bill_id = Details_bill_id from inserted

	select @date_checkin_old = Date_check_in from deleted

	select @bill_id = Bill_id from DETAILS_BILL where DETAILS_BILL.Details_bill_id = @details_bill_id

	select @price = Unit from TYPE_ROOM join ROOM on TYPE_ROOM.Type_room_id = ROOM.Room_type where ROOM.Room_id = @room_id

	select @total_money = Total_money from BILL where Bill_id = @bill_id and Total_money is not null

	if ( @date_checkin_new <> @date_checkin_old and DATEPART(HOUR, @date_checkin_new) >= 5 and DATEPART(HOUR, @date_checkin_new) <= 8 )--kiểm tra giờ checkin mới chèn hoặc cập nhật nếu từ 5-9 thì tính thêm 50% giá phòng 
		begin
			update BILL
			set Total_money = @total_money + 0.5 * @price
			where Bill_id = @bill_id
		end
		else if ( @date_checkin_new <> @date_checkin_old and DATEPART(HOUR, @date_checkin_new) >= 9 and DATEPART(HOUR, @date_checkin_new) <= 13 )----kiểm tra giờ checkin mới chèn hoặc cập nhật nếu từ 9-14 thì tính thêm 30% giá phòng
			 begin
			 update BILL
			 set Total_money = @total_money + 0.3 * @price
			 where Bill_id = @bill_id
			 end
end;


GO
-------------- 10. Trigger tính thêm tiền vào trong hóa đơn nếu check in sớm hơn 14h (đối với khách hàng đặt phòng offline)
create trigger Update_total_money_checkin_early_off on DETAILS_RESERVED
after insert
as
begin
	--khai báo biến
	declare @date_checkin DateTime, @room_id varchar(20), @price money, @total_money money = 0.0000, @details_bill_id varchar(20), @bill_id varchar(20);

	--lấy các giá trị cho biến
	select @date_checkin= Date_check_in, @room_id = Room_id, @details_bill_id = Details_bill_id from inserted

	select @bill_id = Bill_id from DETAILS_BILL where DETAILS_BILL.Details_bill_id = @details_bill_id

	select @price = Unit from TYPE_ROOM join ROOM on TYPE_ROOM.Type_room_id = ROOM.Room_type where ROOM.Room_id = @room_id

	select @total_money = Total_money from BILL where Bill_id = @bill_id and Total_money is not null

	if ( DATEPART(HOUR, @date_checkin) >= 5 and DATEPART(HOUR, @date_checkin) <= 8 )--kiểm tra giờ checkin mới chèn hoặc cập nhật nếu từ 5-9 thì tính thêm 50% giá phòng 
	begin
		update BILL
		set Total_money = @total_money + 0.5 * @price
		where Bill_id = @bill_id
	end
	else if ( DATEPART(HOUR, @date_checkin) >= 9 and DATEPART(HOUR, @date_checkin) <= 13 )----kiểm tra giờ checkin mới chèn hoặc cập nhật nếu từ 9-14 thì tính thêm 30% giá phòng
		 begin
			update BILL
			set Total_money = @total_money + 0.3 * @price
			where Bill_id = @bill_id
		 end
end;

GO
--------------11. Trigger ghi nhận lịch sử khi thêm khách hàng------------
CREATE TRIGGER TrackingLogCustomer_Ins
ON CUSTOMER
AFTER INSERT
AS
declare @Cusomer_id varchar(20), @Customer_name nvarchar(50), @Identify_card varchar(20), @Update_at Datetime, @Operation char(3);
DECLARE @maxID int = (SELECT COALESCE(MAX(ID),0) FROM TRACKING_LOG)
BEGIN 
	SET NOCOUNT ON;
	SELECT	
		@Cusomer_id = Customer_id,
		@Customer_name = Customer_name,
		@Identify_card=Identify_card
	FROM inserted
	INSERT INTO TRACKING_LOG(
		ID,
		Customer_id,
		Customer_name,
		Identify_card,
		Operation,
		Updated_at
		)
	values(@maxID+1,@Cusomer_id,@Customer_name,@Identify_card,'INS',GETDATE())
END


-------------12. Trigger ghi nhận lịch sử khi xóa khách hàng----------------
GO
CREATE TRIGGER TrackingLogCustomer_Del
ON CUSTOMER
AFTER DELETE
AS
declare @Cusomer_id varchar(20), @Customer_name nvarchar(50), @Identify_card varchar(20), @Update_at Datetime, @Operation char(3);
DECLARE @maxID int = (SELECT COALESCE(MAX(ID),0) FROM TRACKING_LOG)
BEGIN 
	SET NOCOUNT ON;
	SELECT	
		@Cusomer_id = Customer_id,
		@Customer_name = Customer_name,
		@Identify_card=Identify_card
	FROM deleted
	INSERT INTO TRACKING_LOG(
		ID,
		Customer_id,
		Customer_name,
		Identify_card,
		Operation,
		Updated_at
		)
	values(@maxID+1,@Cusomer_id,@Customer_name,@Identify_card,'DEL',GETDATE())
END

------------13. Trigger ghi nhận lịch sử khi cập nhật khách hàng-------------
GO
CREATE TRIGGER TrackingLogCustomer_Upd
ON CUSTOMER
AFTER UPDATE
AS
declare @Cusomer_id varchar(20), @Customer_name nvarchar(50), @Identify_card varchar(20), @Update_at Datetime, @Operation char(3);
DECLARE @maxID int = (SELECT COALESCE(MAX(ID),0) FROM TRACKING_LOG)
BEGIN 
	SET NOCOUNT ON;
	SELECT	
		@Cusomer_id = Customer_id,
		@Customer_name = Customer_name,
		@Identify_card=Identify_card
	FROM deleted
	INSERT INTO TRACKING_LOG(
		ID,
		Customer_id,
		Customer_name,
		Identify_card,
		Operation,
		Updated_at
		)
	values(@maxID+1,@Cusomer_id,@Customer_name,@Identify_card,'UPD',GETDATE())
END

-----test trigger trên---
--INSERT INTO CUSTOMER(Customer_id, Customer_name, Gender, Birthday, Identify_card, Phone, Mail, Customer_address)
--VALUES
--('KH0008', N'Võ Thị Minh Thục', 'Nữ', '2003-05-01', '123212312341','0846362325','thuc@gmail.com',N'Quảng Ngãi');
-------


-----------14. Trigger thông báo khi xóa BILL - Thông báo là Đã xóa Bill ---------------------------
GO
CREATE TRIGGER Noti_Delete_BILL on BILL
FOR DELETE
AS
BEGIN
DECLARE @Bill_id varchar(20)
SELECT @Bill_id = ol.Bill_id
FROM 
	deleted AS ol
IF (@Bill_id NOT IN (SELECT Bill_id FROM BILL))
PRINT N'Đã xóa Hóa đơn có mã' + RTRIM(@Bill_id)
END

-----------15. Trigger thông báo khi thêm BILL  - Thông báo là Đã thêm Bill ---------------------------
GO
CREATE TRIGGER Noti_Insert_BILL on BILL
FOR INSERT
AS
BEGIN
DECLARE @Bill_id varchar(20)
SELECT @Bill_id = ol.Bill_id
FROM 
	inserted AS ol
IF (@Bill_id IN (SELECT Bill_id FROM BILL))
PRINT N'Đã thêm Hóa đơn có mã ' + RTRIM(@Bill_id)
END

-----------16. Trigger thông báo khi cập nhật BILL - Thông báo là Đã cập nhật Bill ---------------------------
GO
CREATE TRIGGER Noti_Update_BILL on BILL
FOR UPDATE
AS
BEGIN
DECLARE @Bill_id varchar(20)
SELECT @Bill_id = ol.Bill_id
FROM 
	deleted AS ol
IF (@Bill_id IN (SELECT Bill_id FROM BILL))
PRINT N'Đã cập nhật Hóa đơn có mã ' + RTRIM(@Bill_id)
END

-----------17. Triggers thông báo khi thêm DETAILS_BILL - Thông báo là Đã thêm DETAILS_BILL ---------------------------
GO
CREATE TRIGGER Noti_Insert_DETAIL_BILL on DETAILS_BILL
FOR INSERT
AS
BEGIN
DECLARE @DetailBill_id varchar(20), @Bill_id varchar(20)
SELECT @DetailBill_id = ol.Details_bill_id, @Bill_id=ol.Bill_id
FROM 
	inserted AS ol
IF (@DetailBill_id IN (SELECT Details_bill_id FROM DETAILS_BILL))
PRINT N'Đã thêm Chi tiết Hóa đơn của Hóa đơn có mã ' + RTRIM(@Bill_id)
END

-----------18. Triggers thông báo khi cập nhật DETAILS_BILL - Thông báo là Đã cập nhật DETAILS_Bill ---------------------------
GO
CREATE TRIGGER Noti_Update_DETAIL_BILL on DETAILS_BILL
FOR UPDATE
AS
BEGIN
DECLARE @DetailBill_id varchar(20), @Bill_id varchar(20)
SELECT @DetailBill_id = ol.Details_bill_id, @Bill_id=ol.Bill_id
FROM 
	deleted AS ol
IF (@DetailBill_id IN (SELECT Details_bill_id FROM DETAILS_BILL))
PRINT N'Đã cập nhật Chi tiết Hóa đơn của Hóa đơn có mã ' + RTRIM(@Bill_id)
END

-------------19. Triggers thông báo khi xóa Customer------------------
GO
CREATE TRIGGER Noti_Delete_CUS on CUSTOMER
FOR DELETE
AS
BEGIN
DECLARE @Customer_id varchar(20), @Customer_name nvarchar(50)
SELECT @Customer_id=ol.Customer_id, @Customer_name=ol.Customer_name
FROM deleted AS ol
IF (@Customer_id NOT IN (SELECT Customer_id FROM CUSTOMER))
PRINT N'Đã xóa thông tin Khách hàng ' + RTRIM(@Customer_name)
END
-----TEST--
--DELETE
--FROM CUSTOMER
--WHERE Customer_id='KH0001'
--------------
-------------20. Triggers thông báo khi thêm Customer------------------
GO
CREATE TRIGGER Noti_Insert_CUS on CUSTOMER
FOR INSERT
AS
BEGIN
DECLARE @Customer_id varchar(20), @Customer_name nvarchar(50)
SELECT @Customer_id=ol.Customer_id, @Customer_name=ol.Customer_name
FROM deleted AS ol
IF (@Customer_id IN (SELECT Customer_id FROM CUSTOMER))
PRINT N'Đã thêm thông tin Khách hàng ' + RTRIM(@Customer_name)
END



-------------21. Triggers thông báo khi thêm Customer mà Customer đã tồn tại------------------
GO
CREATE TRIGGER Noti_Update_CUS on CUSTOMER
FOR INSERT
AS
BEGIN
DECLARE @Identify_card varchar(20), @Customer_name nvarchar(50)
SELECT @Identify_card=ol.Identify_card, @Customer_name=ol.Customer_name
FROM deleted AS ol
IF (@Identify_card  IN (SELECT Identify_card FROM CUSTOMER))
BEGIN
	PRINT N'thông tin Khách hàng ' + RTRIM(@Customer_name) + N' đã tồn tại trước đó';
	RollBack;
END
END


---------------------22. Trigger thông báo khi thêm Phiếu đặt phòng thành công---------------
GO
CREATE TRIGGER Noti_Insert_Reserved_Room on DETAILS_RESERVED
FOR INSERT
AS
BEGIN
DECLARE @Room_id varchar(20)
SELECT @Room_id=ol.Room_id
FROM inserted AS ol
IF (@Room_id IN (SELECT Room_id FROM DETAILS_RESERVED))
PRINT N'Đã thêm phiếu đặt phòng cho phòng ' + RTRIM(@Room_id) + N' thành công'
END



---------------------23. Trigger thông báo khi cập nhật Phiếu đặt phòng thành công---------------
GO
CREATE TRIGGER Noti_Update_Reserved_Room on DETAILS_RESERVED
FOR UPDATE
AS
BEGIN
DECLARE @Room_id varchar(20)
SELECT @Room_id=ol.Room_id
FROM deleted AS ol
IF (@Room_id IN (SELECT Room_id FROM DETAILS_RESERVED))
PRINT N'Đã cập nhật phiếu đặt phòng cho phòng ' + RTRIM(@Room_id) + N' thành công'
END


---------------------24. Trigger thông báo khi thêm Phiếu sử dụng dịch vụ thành công---------------
GO
CREATE TRIGGER Noti_Insert_Use_Service on DETAILS_USED_SERVICE
FOR INSERT
AS
BEGIN
DECLARE @Room_id varchar(20)
SELECT @Room_id=ol.Room_id
FROM inserted AS ol
IF (@Room_id IN (SELECT Room_id FROM DETAILS_USED_SERVICE))
PRINT N'Đã thêm phiếu sử dụng dịch vụ cho phòng ' + RTRIM(@Room_id) + N' thành công'
END


---------------------25. Trigger thông báo khi cập nhật Phiếu sử dụng dịch vụ thành công---------------
GO
CREATE TRIGGER Noti_Update_Use_Service on DETAILS_USED_SERVICE
FOR UPDATE
AS
BEGIN
DECLARE @Room_id varchar(20)
SELECT @Room_id=ol.Room_id
FROM deleted AS ol
IF (@Room_id IN (SELECT Room_id FROM DETAILS_USED_SERVICE))
PRINT N'Đã cập nhật phiếu sử dụng dịch vụ cho phòng ' + RTRIM(@Room_id) + N' thành công'
END



