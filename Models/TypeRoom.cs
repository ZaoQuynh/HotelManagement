using HotelManagement.DAO.Base;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace HotelManagement.Models
{
    public class TypeRoom
    {
        private string id;
        private string name;
        private int unit;
        private float discount;


        public string ID
        {
            get { return id; }
            set { id = value; }
        }

        public string Name
        {
            get { return name; }
            set { name = value; }
        }

        public int Unit
        {
            get { return unit; }
            set { unit = value; }
        }

        public float Discount
        {
            get { return discount; }
            set { discount = value; }
        }

        public TypeRoom() { }

        public TypeRoom(string id, string name, int unit, float discount)
        {
            this.id = id;
            this.name = name;
            this.unit = unit;
            this.discount = discount;
        }

        public TypeRoom(SqlDataReader reader)
        {
            try
            {
                id = (string)reader[BaseDao.TYPE_ROOM_ID];
                name = (string)reader[BaseDao.TYPE_ROOM_NAME];
                unit = int.Parse(reader[BaseDao.TYPE_ROOM_UNIT].ToString());
                discount = float.Parse(reader[BaseDao.TYPE_ROOM_DISCOUNT].ToString());
            }
            catch (Exception ex)
            {
                MessageBox.Show("Convert TypeRoom From SQL: Failed!")
            }
        }
    }
}
