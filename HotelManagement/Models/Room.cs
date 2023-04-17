using HotelManagement.DAO.Base;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace HotelManagement.Model
{
    public class Room
    {

        private string id;
        private bool roomTypeStatus;
        private string roomTypeID;

        public string ID
        {
            get { return id; }
            set { this.id = value; }
        }

        public bool RoomTypeStatus
        {
            get { return roomTypeStatus; }
            set { this.roomTypeStatus = value; }
        }

        public string RoomTypeID
        {
            get { return roomTypeID; }
            set { this.roomTypeID = value; }
        }

        public void Room() { }

        public void Room(string id, bool roomTypeStatus, string roomTypeID)
        {
            this.id = id;
            this.roomTypeStatus = roomTypeStatus;
            this.roomTypeID = roomTypeID;
        }

        public void Room(SqlDataReader reader)
        {
            try
            {
                id = (string)reader[BaseDao.ROOM_ID];
                roomTypeStatus = (bool)reader[BaseDao.ROOM_STATUS];
                roomTypeID = (string)reader[BaseDao.ROOM_TYPE];
            }
            catch(Exception ex)
            {
                MessageBox.Show("Convert Room From SQL: Failed!")
            }
        }
    }
}
