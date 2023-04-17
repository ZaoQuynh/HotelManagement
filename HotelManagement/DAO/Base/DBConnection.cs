using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Resources.ResXFileRef;

namespace HotelManagement.DAO.Base
{
    public class DBConnection
    {
        SqlConnection conn;

        public DBConnection()
        {
            conn = new SqlConnection(Properties.Settings.Default.connStr);
        }

        public void ExcuteNonQuery(string sqlStr, CommandType commandType, params SqlParameter[] param)
        {
            try
            {
                conn.Open();
                SqlCommand cmd = conn.CreateCommand();
                cmd.CommandType = commandType;
                cmd.CommandText = sqlStr;
                if(param!= null)
                    foreach(SqlParameter p in param)
                    {
                        cmd.Parameters.Add(p);
                    }    

                if(cmd.ExecuteNonQuery()>0)
                {
                    MessageBox.Show("Completed!");
                }    
            }
            catch(Exception ex)
            {
                MessageBox.Show("Failed!");
            }
            finally
            {
                conn.Close();
            }
        }

        public List<T> GetList<T>(Func<SqlDataReader, T>, string sqlStr, converter, CommandType commandType, params SqlParameter[] param)
        {
            List<T> list = new List<T>();
            try
            {
                conn.Open();
                SqlCommand cmd = conn.CreateCommand();
                cmd.CommandType = commandType;
                cmd.CommandText = sqlStr;
                if (param != null)
                    foreach (SqlParameter p in param)
                    {
                        cmd.Parameters.Add(p);
                    }
                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                    list.Add(converter(reader));
                cmd.Dispose();
                reader.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Failed!");
            }
            finally
            {
                conn.Close();
            }
            return list;
        }

        public object? GetSingleObject<T>(Func<SqlDataReader, T> converter, string sqlStr, converter, CommandType commandType, params SqlParameter[] param)
        {
            List<T> list = GetList(converter, sqlStr, commandType, param);
            return list.Count == 0 ? null : list[0];
        }
    }
}
