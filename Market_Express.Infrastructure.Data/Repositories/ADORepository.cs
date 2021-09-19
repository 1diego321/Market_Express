﻿using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;
using System.Threading.Tasks;

namespace Market_Express.Infrastructure.Data.Repositories
{
    public abstract class ADORepository : ConnectionSql
    {
        public ADORepository(IConfiguration configuration)
            : base(configuration)
        { }

        protected async Task<DataTable> ExecuteQuery(string spName, SqlParameter[] parameters = null)
        {
            using (var connection = GetConnection())
            {
                using (var command = new SqlCommand(spName, connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    if (parameters != null)
                        command.Parameters.AddRange(parameters);

                    await connection.OpenAsync();

                    using (var table = new DataTable())
                    {
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            table.Load(reader);

                            return table;
                        }
                    }
                }
            }
        }

        protected int ExecuteNonQuery(string spName, SqlParameter[] parameters)
        {
            using (var connection = GetConnection())
            {
                connection.Open();

                using (var command = new SqlCommand(spName, connection))
                {
                    command.Parameters.AddRange(parameters);

                    int result = command.ExecuteNonQuery();

                    return result;
                }
            }
        }
    }
}
