using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HotelManagement.DAO.Base
{
    public abstract class BaseDao
    {
        protected const string ROOM_TABLE = "ROOM";
        public const string ROOM_ID = "Room_id";
        public const string ROOM_STATUS = "Room_status";
        public const string ROOM_TYPE = "Room_type";

        protected const string SERVICE_ROOM = "SERVICE_ROOM";
        public const string SERVICE_ROOM_ID = "Service_room_id";
        public const string SERVICE_ROOM_NAME = "Service_room_name";
        public const string SERVICE_ROOM_UNIT = "Unit";
        public const string SERVICE_ROOM_DISCOUNT = "Discount_service";

        protected const string TYPE_ROOM_TABLE = "TYPE_ROOM";
        public const string TYPE_ROOM_ID = "Type_room_id";
        public const string TYPE_ROOM_NAME = "Type_room_name";
        public const string TYPE_ROOM_UNIT = "Unit";
        public const string TYPE_ROOM_DISCOUNT = "Discount_room";

        protected const string DETAILS_RESERVED_TABLE = "DETAILS_RESERVED";
        public const string DETAILS_RESERVED_CUSTOMER_ID = "Customer_id";
        public const string DETAILS_RESERVED_ROOM_ID = "Room_id";
        public const string DETAILS_RESERVED_DETAILS_BILL_ID = "Details_bill_id";
        public const string DETAILS_RESERVED_RESERVED_DAY = "Reserved_day";
        public const string DETAILS_RESERVED_DATE_CHECK_IN = "Date_check_in";
        public const string DETAILS_RESERVED_CHECK_ROOM_RECEIVED = "Check_room_received";
        public const string DETAILS_RESERVED_DEPOSIT = "Deposit";
        public const string DETAILS_RESERVED_CHECK_PAID_DEPOSIT = "Check_paid_deposit";
        public const string DETAILS_RESERVED_DATE_CREATE = "Date_create";

        protected DBConnection dbConnection = new DBConnection();
    }
}
