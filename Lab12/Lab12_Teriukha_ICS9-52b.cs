using System;
using System.Data.SqlClient;
using System.Data;
using System.Configuration;

namespace Lab12
{
    class DB
    {
        private static SqlConnection connection;
        private static DataSet dataset;
        private static SqlDataAdapter data_adapter;
        private static string UpdateString = "UPDATE ControllersOffice SET PhoneNumber = @PhoneNumber WHERE Address = @address";
        private static string InsertString =  "INSERT INTO ControllersOffice(Address,PhoneNumber,Mail,Fax,Schedule) VALUES (@address,@phone,@mail,@fax,@schedule)";
        private static string DeleteString = "DELETE FROM ControllersOffice WHERE OfficeID = @OfficeID";
        private static string CheckString = "SELECT Address FROM ControllersOffice WHERE Address = @address";
        
        static public void connect()
        {
            connection = new SqlConnection(ConfigurationManager.AppSettings.Get("connectionString"));
          
                try
                {
                    connection.Open();
                    Console.WriteLine("Connected!");
                }
                catch (Exception ex)
                {
                    Console.Write(ex.Message);
                    Console.ReadKey();
                    Environment.Exit(-1);
                }
        }

        static public bool isConnect()
        {
            return connection != null && connection.State != ConnectionState.Closed;
        }

        static public void disconnect()
        {
            if (isConnect())
            {
                try
                {
                    connection.Close();
                    Console.WriteLine("disconnected!");
                }
                catch (Exception ex)
                {
                    Console.Write(ex.Message);
                    Console.ReadKey();
                    Environment.Exit(-1);
                }
            }
            else
            {
                Console.WriteLine("Disconnected {0}");
            }
        }
        static public void ConfigDisconn()
        {
            connect();
            Console.WriteLine("configurate");
            dataset = new DataSet();
            data_adapter = new SqlDataAdapter("SELECT * FROM ControllersOffice", connection);
            data_adapter.Fill(dataset, "ControllersOffice");
            disconnect();
        }
        static public void ShowConnected(string table_name)
        {
            connect();
            try
            {
                Console.WriteLine("Showconnection(" + table_name + ")");
                SqlCommand newComm = connection.CreateCommand();
                newComm.Connection = connection;
                newComm.CommandText = "SELECT * FROM " + table_name;

                SqlDataReader reader = newComm.ExecuteReader();

                for (int i = 0; i < reader.FieldCount; i++)
                {
                    Console.Write(reader.GetName(i) + "\t");
                }
                Console.Write("\n");
                while (reader.Read())
                {
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        Object temp = reader.GetValue(i);
                        if (temp.ToString() != "")
                        {
                        
                            Console.Write(temp + "\t");
                        }
                        else
                        {
                            Console.Write("null" + "\t");
                        }
                    }
                    Console.WriteLine();
                }

                reader.Close();

            }
            catch (SqlException ex)
            {
                Console.Write(ex.Message);
                Console.ReadKey();
                Environment.Exit(-1);
            }
            catch (Exception ex)
            {
                Console.Write(ex.Message);
                Console.ReadKey();
                Environment.Exit(-1);
            }
            disconnect();
        }

        static public void ShowDisconnected(string table_name)
        {
            Console.WriteLine("ShowDisconnected {0}",table_name);
            DataTableReader tableReader = dataset.CreateDataReader();
            for (int i = 0; i < tableReader.FieldCount; i++)
            {
                Console.Write($"{tableReader.GetName(i)}\t");
            }
            Console.WriteLine();
            while (tableReader.Read())
            {
                for (int i = 0; i < tableReader.FieldCount; i++)
                {
                    Object temp = tableReader.GetValue(i);
                    if (temp.ToString() != "")
                    {
                        Console.Write(temp + "\t");
                    }
                    else
                    {
                        Console.Write("null" + "\t");
                    }
                }
                Console.WriteLine();
            }
            Console.WriteLine();
            tableReader.Close();
        }
        static public void DeleteConnected(int i)
        {
            connect();
            Console.WriteLine("delete connected {0}",i);
            try
            {
                SqlCommand newComm = connection.CreateCommand();
                newComm.Connection = connection;
                newComm.CommandText = DeleteString;

                SqlParameter param = new SqlParameter();
                param.ParameterName = "@OfficeID";
                param.Value = i;
                param.SqlDbType = SqlDbType.Int;
                newComm.Parameters.Add(param);
                newComm.ExecuteNonQuery();

            }
            catch (Exception ex)
            {
                Console.Write(ex.Message);
                Console.ReadKey();
                Environment.Exit(-1);
            }
            disconnect();
        }
        static public void DeleteDisconnected(int OfficeID)
        {
            Console.WriteLine("DeleteDisconnected {0}",OfficeID);
            SqlCommand newComm = new SqlCommand();
            newComm.Connection = connection;
            newComm.CommandText = DeleteString;
            newComm.Parameters.Add("@OfficeID", SqlDbType.Int, 0, "OfficeID");
            data_adapter.DeleteCommand = newComm;
            for (int i = 0; i < dataset.Tables["ControllersOffice"].Rows.Count ; i++)
            {
                DataRow row = dataset.Tables["ControllersOffice"].Rows[i];
                if (row["OfficeID"]!= DBNull.Value &&(int)row["OfficeID"] == OfficeID)
                {
                    row.Delete();
                }
            }
        }
        static public void InsertConnected(string address, string phone, string mail,string fax,string schedule)
        {
            connect();
            Console.WriteLine("delete connected {0}",address);
            try
            {
                SqlCommand newCommcheckPatient = connection.CreateCommand();
                newCommcheckPatient.Connection = connection;
                newCommcheckPatient.CommandText = CheckString;

                SqlParameter param = new SqlParameter();
                param.ParameterName = "@address";
                param.Value = address;
                param.SqlDbType = SqlDbType.VarChar;

                newCommcheckPatient.Parameters.Add(param);

                string Address = (string)newCommcheckPatient.ExecuteScalar();
                if (Address != null)
                {
                    Console.WriteLine("Уже было, удаляй");
                    return;
                }


                SqlCommand newComm = connection.CreateCommand();
                newComm.Connection = connection;
                newComm.CommandText = InsertString;

                SqlParameter[] parametes = new SqlParameter[5];
                parametes[0] = new SqlParameter();
                parametes[0].ParameterName = "@address";
                parametes[0].Value = address;
                parametes[0].SqlDbType = SqlDbType.VarChar;

                parametes[1] = new SqlParameter();
                parametes[1].ParameterName = "@phone";
                parametes[1].Value = phone;
                parametes[1].SqlDbType = SqlDbType.VarChar;

                parametes[2] = new SqlParameter();
                parametes[2].ParameterName = "@mail";
                parametes[2].Value = mail;
                parametes[2].SqlDbType = SqlDbType.VarChar;
                
                parametes[3] = new SqlParameter();
                parametes[3].ParameterName = "@fax";
                parametes[3].Value = fax;
                parametes[3].SqlDbType = SqlDbType.VarChar;
                
                parametes[4] = new SqlParameter();
                parametes[4].ParameterName = "@schedule";
                parametes[4].Value = schedule;
                parametes[4].SqlDbType = SqlDbType.VarChar;

                newComm.Parameters.AddRange(parametes);
                newComm.ExecuteNonQuery();

            }
            catch (Exception ex)
            {
                Console.Write(ex.Message);
                Console.ReadKey();
                Environment.Exit(-1);
            }
            disconnect();
        }
        static public void InsertDisconnected(string Address, string PhoneNumber, string Mail,string Fax,string Schedule)
        {
            Console.WriteLine("InsertDisconnected {0}",Address);
            DataTableReader tableReader = dataset.CreateDataReader();
            Console.WriteLine();
            int was = 0;
            while (tableReader.Read())
            {
                for (int i = 0; i < tableReader.FieldCount; i++)
                {
                    Object temp = tableReader.GetValue(i);
                    if (temp.ToString() == Address)
                    {
                        Console.WriteLine("Уже было, удаляй");
                        return;
                    }
                   
                }
            }
            tableReader.Close();
            SqlCommand newComm = connection.CreateCommand();
            newComm.Connection = connection;
            newComm.CommandText = InsertString;
            newComm.Parameters.Add("@address", SqlDbType.VarChar, 0, "Address");
            newComm.Parameters.Add("@phone", SqlDbType.VarChar, 0, "PhoneNumber");
            newComm.Parameters.Add("@mail", SqlDbType.VarChar, 0, "Mail");
            newComm.Parameters.Add("@fax", SqlDbType.VarChar, 0, "Fax");
            newComm.Parameters.Add("@schedule", SqlDbType.VarChar, 0, "Schedule");
            
            data_adapter.InsertCommand = newComm;
            DataRow dataRow = dataset.Tables["ControllersOffice"].NewRow();
            dataRow["Address"] = Address;
            dataRow["PhoneNumber"] = PhoneNumber;
            dataRow["Mail"] = Mail;
            dataRow["Fax"] = Fax;
            dataRow["Schedule"] = Schedule;
            dataset.Tables["ControllersOffice"].Rows.Add(dataRow);
        }

        static public void UpdateConnected(string address, string phone)
        {
            connect();
            Console.WriteLine("update connected {0}",address);
            try
            {
                SqlCommand newCommcheckPatient = connection.CreateCommand();
                newCommcheckPatient.Connection = connection;
                newCommcheckPatient.CommandText = CheckString;

                SqlParameter param = new SqlParameter();
                param.ParameterName = "@address";
                param.Value = address;
                param.SqlDbType = SqlDbType.VarChar;

                newCommcheckPatient.Parameters.Add(param);

                int Address =(int)newCommcheckPatient.ExecuteScalar();
                if (Address != 0)
                {
                    Console.WriteLine("Не нашел такого");
                    return;
                }


                SqlCommand newComm = connection.CreateCommand();
                newComm.Connection = connection;
                newComm.CommandText = UpdateString;

                SqlParameter[] parametes = new SqlParameter[2];
                parametes[0] = new SqlParameter();
                parametes[0].ParameterName = "@address";
                parametes[0].Value = address;
                parametes[0].SqlDbType = SqlDbType.VarChar;

                parametes[1] = new SqlParameter();
                parametes[1].ParameterName = "@PhoneNumber";
                parametes[1].Value = phone;
                parametes[1].SqlDbType = SqlDbType.VarChar;

                newComm.Parameters.AddRange(parametes);
                newComm.ExecuteNonQuery();

            }
            catch (Exception ex)
            {
                Console.Write(ex.Message);
                Console.ReadKey();
                Environment.Exit(-1);
            }
            disconnect();
        }
        static public void UpdateDisconnected(string Address, string PhoneNumber)
        {
            Console.WriteLine("UpdateDisconnected {0}",Address);
            SqlCommand newComm = connection.CreateCommand();
            newComm.Connection = connection;
            newComm.CommandText = UpdateString;

            newComm.Parameters.Add("@Address", SqlDbType.VarChar, 0, "Address");
            newComm.Parameters.Add("@PhoneNumber", SqlDbType.VarChar, 0, "PhoneNumber");
            data_adapter.UpdateCommand = newComm;

            for (int i = 0; i < dataset.Tables["ControllersOffice"].Rows.Count; i++)
            {
                DataRow row = dataset.Tables["ControllersOffice"].Rows[i];
                if (row["Address"]!= DBNull.Value && (string)row["Address"] == Address)
                {
                    row["Address"] = Address;
                    row["PhoneNumber"] = PhoneNumber;
                }
            }
        }
        static public void DataExchange()
        {
            connect();
            Console.Write("DataExchahnge");
            data_adapter.Update(dataset, "ControllersOffice");
            data_adapter.Fill(dataset, "ControllersOffice");
            disconnect();
        }

    }
    class Program
    {   
        static public void consol()
        {
           
            // Связный уровень //
          /*  DB.ShowConnected("ControllersOffice");
            DB.DeleteConnected(2);
            DB.ShowConnected("ControllersOffice");
            DB.InsertConnected("pyshkina 5", "+79056364162", "index@mail.ru", "", "Monday");
            DB.ShowConnected("ControllersOffice");
            DB.InsertConnected("pyshkina 5", "+79056364162", "index@mail.ru", "", "Monday");
            DB.ShowConnected("ControllersOffice");
            DB.UpdateConnected("pyshkina 5","0");
            DB.ShowConnected("ControllersOffice");
            */
            DB.ConfigDisconn();
            DB.ShowDisconnected("ControllersOffice");
            DB.InsertDisconnected("pyshkina 251113", "+710521631643162", "inde21113@mail.ru", "sl1d2311", "M112n1day");
           // DB.ShowDisconnected("ControllersOffice");
            //DB.UpdateDisconnected("pyshkina 135","135");
            DB.ShowDisconnected("ControllersOffice");
           // DB.DeleteDisconnected(39);
            //DB.ShowDisconnected("ControllersOffice");
            DB.DataExchange();
            DB.ShowDisconnected("ControllersOffice");
        }
        static void Main(string[] args)
        {
            consol();
            Console.ReadKey();
        }
    }
}