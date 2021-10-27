﻿using Market_Express.Domain.Abstractions.Repositories;
using Market_Express.Domain.Entities;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System;
using System.Threading.Tasks;

namespace Market_Express.Infrastructure.Data.Repositories
{
    public class AppUserRoleRepository : GenericRepository<AppUserRole>, IAppUserRoleRepository
    {
        private const string _Sp_AppUserRole_GetUserCountUsingARole = "Sp_AppUserRole_GetUserCountUsingARole";

        public AppUserRoleRepository(MARKET_EXPRESSContext context, IConfiguration configuration)
            : base(context, configuration)
        { }

        public async Task<int> GetUserCountUsingARole(Guid roleId)
        {
            int count = 0;

            var arrParams = new[]
            {
                new SqlParameter("@roleId",roleId)
            };

            var dtResult = await ExecuteQuery(_Sp_AppUserRole_GetUserCountUsingARole, arrParams);

            if(dtResult?.Rows != null)
            {
                var drResult = dtResult.Rows[0];

                count = (int)drResult[0];
            }

            return count;
        }
    }
}
