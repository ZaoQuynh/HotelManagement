using HotelManagement.DAO.Base;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Windows.Markup;

namespace HotelManagement.Models
{
    public class DetailsUsedService
    {
        private string customerID;
        private string roomID;
        private string detailsBillID;
        private int reservedDay;
        private DateTime dateCheckIn;
        private bool checkRoomReceived;
        private int deposit;
        private bool checkPaidDeposit;
        private DateTime dateCreate;

        public string CustomerID
        {
            get { return customerID; }
            set { customerID = value; }
        }

        public string RoomID
        {
            get { return roomID; }
            set { roomID = value; }
        }

        public string DetailsBillID
        {
            get { return detailsBillID; }
            set { detailsBillID = value; }
        }

        public int ReservedDay
        {
            get { return reservedDay; }
            set { reservedDay = value; }
        }

        public DateTime DateCheckIn
        {
            get { return dateCheckIn; }
            set { dateCheckIn = value; }
        }

        public bool CheckRoomReceived
        {
            get { return checkRoomReceived; }
            set { checkRoomReceived = value; }
        }

        public int Deposit
        {
            get { return deposit; }
            set { deposit = value; }
        }

        public bool CheckPaidDeposit
        {
            get { return checkPaidDeposit; }
            set { checkPaidDeposit = value; }
        }

        public DateTime DateCreate
        {
            get { return dateCreate; }
            set { dateCreate = value; }
        }

        public DetailsUsedService() { }

        public DetailsUsedService(string customerID, string roomID, string detailsBillID, int reservedDay, DateTime dateCheckIn, bool checkRoomReceived, int deposit, bool checkPaidDeposit, DateTime dateCreate)
        {
            this.customerID = customerID;
            this.roomID = roomID;
            this.detailsBillID = detailsBillID;
            this.reservedDay = reservedDay;
            this.dateCheckIn = dateCheckIn;
            this.checkRoomReceived = checkRoomReceived;
            this.deposit = deposit;
            this.checkPaidDeposit = checkPaidDeposit;
            this.dateCreate = dateCreate;
        }

        public DetailsUsedService(SqlDataReader reader)
        {
            try
            {
                customerID = (string)reader[BaseDao.DETAILS_RESERVED_CUSTOMER_ID];
                roomID = (string)reader[BaseDao.DETAILS_RESERVED_ROOM_ID];
                detailsBillID = (string)reader[BaseDao.DETAILS_RESERVED_DETAILS_BILL_ID];
                reservedDay = int.Parse(reader[BaseDao.DETAILS_RESERVED_RESERVED_DAY].ToString());
                dateCheckIn = reader.GetDateTime(reader.GetOrdinal(BaseDao.DETAILS_RESERVED_DATE_CHECK_IN));
                checkRoomReceived = (bool)reader[BaseDao.DETAILS_RESERVED_CHECK_ROOM_RECEIVED];
                deposit = int.Parse(reader[BaseDao.DETAILS_RESERVED_DEPOSIT].ToString());
                checkPaidDeposit = (bool)reader[BaseDao.DETAILS_RESERVED_CHECK_PAID_DEPOSIT];
                dateCreate = reader.GetDateTime(reader.GetOrdinal(BaseDao.DETAILS_RESERVED_DATE_CREATE));
            }
            catch (Exception ex)
            {
                MessageBox.Show("Convert DetailsUsedService From SQL: Failed!")
            }
        }
    }
}
