using Market_Express.Domain.Entities;
using Market_Express.Domain.QueryFilter.AppUser;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Market_Express.Domain.Abstractions.DomainServices
{
    public interface IAppUserService
    {
        IEnumerable<AppUser> GetAll(AppUserIndexQueryFilter filters);
        Task<AppUser> GetById(Guid id, bool includeClient = false);
        List<string> SearchNames(string query, bool onlyAdmin = false);
        Task<BusisnessResult> ChangeStatus(Guid userToChangeId, Guid currentUserId);
        Task<BusisnessResult> Create(AppUser appUser, List<Guid> roles, Guid currentUserId);
        Task<BusisnessResult> Edit(AppUser appUser, List<Guid> roles, Guid currentUserId);
    }
}
