﻿using Market_Express.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Market_Express.Domain.Abstractions.DomainServices
{
    public interface IAccountService
    {
        Task<BusisnessResult> TryChangeAlias(Guid userId, string alias);
        Task<bool> HasValidPassword(Guid id);
        Task<BusisnessResult> TryChangePassword(Guid userId, string currentPass, string newPass, string newPassConf);
        BusisnessResult TryAuthenticate(ref AppUser usuarioRequest);
        Task<BusisnessResult> CreateAddress(Guid userId, Address address);
        Task<BusisnessResult> EditAddress(Address address);
        Task<Address> GetAddressInfo(Guid addressId);
        Task<IEnumerable<Address>> GetAddressList(Guid id);
        Task<List<Permission>> GetPermissionList(Guid id);
        Task<AppUser> GetUserInfo(Guid id);
    }
}
