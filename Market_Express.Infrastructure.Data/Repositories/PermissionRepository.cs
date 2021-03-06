using Market_Express.Domain.Abstractions.Repositories;
using Market_Express.Domain.Entities;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace Market_Express.Infrastructure.Data.Repositories
{
    public class PermissionRepository : GenericRepository<Permission>, IPermissionRepository
    {
        private const string _Sp_Permission_GetAllByRoleId = "Sp_Permission_GetAllByRoleId";
        private const string _Sp_Permission_GetAllTypes = "Sp_Permission_GetAllTypes";

        public PermissionRepository(MARKET_EXPRESSContext context, IConfiguration configuration, IHostingEnvironment hostingEnvironment)
            : base(context, configuration, hostingEnvironment)
        { }

        public async Task<List<Permission>> GetAllByRoleId(Guid id)
        {
            List<Permission> lstPermissions = new();

            var arrParams = new[]
            {
                new SqlParameter("@Id",id)
            };

            var dtResult = await ExecuteQuery(_Sp_Permission_GetAllByRoleId, arrParams);

            foreach (DataRow oRow in dtResult.Rows)
            {
                lstPermissions.Add(new Permission
                {
                    Id = (Guid)oRow["Id"],
                    Name = oRow["Name"].ToString(),
                    Description = oRow["Description"].ToString(),
                    PermissionCode = oRow["PermissionCode"].ToString(),
                    Type = oRow["Type"].ToString()
                });
            }

            return lstPermissions;
        }

        public async Task<List<string>> GetAllTypes()
        {
            List<string> lstTypes = new();

            var dtResult = await ExecuteQuery(_Sp_Permission_GetAllTypes);

            foreach (DataRow oRow in dtResult.Rows)
            {
                lstTypes.Add(oRow[0].ToString());
            }

            return lstTypes;
        }
    }
}
