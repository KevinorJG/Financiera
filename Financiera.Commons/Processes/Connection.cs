﻿using System;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Financiera.Domain.Entities;
using Financiera.Domain.Enums;

namespace Financiera.Commons.Processes
{
    public class Connection
    {
        public static string StringConnection = "";
        public static SqlConnectionStringBuilder? builder { get; set; }
        public static SqlConnection? connection { get; set; }
        public static ConnectionState State { get; set; }
        protected static SqlCommand? cmd { get; set; }
        public static Roles Roles { get; set; }
        public static bool StatusRol { get; set; }
        public Connection()
        {
            //connection = new SqlConnection();
        }

        public ConnectionState Connect(string dni, string pass, string login)
        {
            StatusRol = false;

            builder = new SqlConnectionStringBuilder()
            {
                DataSource = "KEVINOR\\SQLEXPRESS",
                InitialCatalog = "Financiera",
                UserID = login,
                Password = pass,

            };

            try
            {
                using (connection = new SqlConnection(builder.ConnectionString))
                {
                    connection.Open();

                    if (connection.State == ConnectionState.Open)
                    {
                        State = ConnectionState.Open;//Indica que la conexion de abrio
                        StringConnection = builder.ConnectionString;//obtiene la cadena de conexion para poder utilizarla luego
                        SqlCommand command = new SqlCommand(connection.ConnectionString, connection);
                        command.CommandText = "sp_ValidarAcceso";
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@usario", dni);
                        SqlDataReader reader = command.ExecuteReader();

                        while (reader.Read() == true)
                        {
                            if(reader["Resultado"].ToString() == "Acceso Exitoso")
                            {
                                if (reader["Roll"].ToString() == Roles.Empleado.ToString())
                                {                                
                                    User.Rol = Roles.Empleado.ToString();
                                    StatusRol = true;
                                }
                                if (reader["Roll"].ToString() == Roles.Administrador.ToString())
                                {
                                    User.Rol = Roles.Administrador.ToString();
                                    StatusRol = true;
                                }
                                if (reader["NameEmployee"].ToString() != null)
                                {
                                    User.Name = reader["NamesEmployee"].ToString();
                                }
                            }

                        }

                        var result = (StatusRol != true) ? State = ConnectionState.Closed : State = ConnectionState.Open;
                    }

                }
            }
            catch (Exception ex)
            {

            }
            connection.Dispose();
            connection.Close();
            return State;
        }

    }
}
