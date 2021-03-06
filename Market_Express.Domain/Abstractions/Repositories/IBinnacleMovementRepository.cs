using Market_Express.Domain.CustomEntities.Pagination;
using Market_Express.Domain.Entities;
using Market_Express.Domain.QueryFilter.BinnacleMovement;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Market_Express.Domain.Abstractions.Repositories
{
    public interface IBinnacleMovementRepository : IGenericRepository<BinnacleAccess>
    {
        Task<SQLServerPagedList<BinnacleMovement>> GetAllPaginated(BinnacleMovementQueryFilter filters);
        Task<List<BinnacleMovement>> GetAllForReport(BinnacleMovementQueryFilter filters);
    }
}
