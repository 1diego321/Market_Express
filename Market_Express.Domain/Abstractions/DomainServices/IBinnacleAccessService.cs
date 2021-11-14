﻿using Market_Express.Domain.CustomEntities.Pagination;
using Market_Express.Domain.Entities;
using Market_Express.Domain.QueryFilter.BinnacleAccess;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Market_Express.Domain.Abstractions.DomainServices
{
    public interface IBinnacleAccessService
    {
        Task RegisterAccess(Guid userId);
        Task RegisterExit(Guid userId);
        PagedList<BinnacleAccess> GetAllPaginated(BinnacleAccessQueryFilter filters);
        IEnumerable<BinnacleAccess> GetResultForReport(BinnacleAccessQueryFilter filters);
    }
}
