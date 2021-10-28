﻿using Market_Express.CrossCutting.Utility;
using Market_Express.Domain.Abstractions.DomainServices;
using Market_Express.Domain.Abstractions.InfrastructureServices;
using Market_Express.Domain.Abstractions.Repositories;
using Market_Express.Domain.Entities;
using Market_Express.Domain.Enumerations;
using Market_Express.Domain.QueryFilter.AppUser;
using System;
using System.Linq;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Market_Express.Domain.Services
{
    public class AppUserService : IAppUserService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IPasswordService _passwordService;

        public AppUserService(IUnitOfWork unitOfWork,
                              IPasswordService passwordService)
        {
            _unitOfWork = unitOfWork;
            _passwordService = passwordService;
        }

        public IEnumerable<AppUser> GetAll(AppUserIndexQueryFilter filters)
        {
            var lstAppUser = _unitOfWork.AppUser.GetAll();

            if (filters.Name != null)
                lstAppUser = lstAppUser.Where(u => u.Name.Trim().ToUpper().Contains(filters.Name.Trim().ToUpper()));

            if (filters.Identification != null)
                lstAppUser = lstAppUser.Where(u => u.Identification.Trim().ToUpper().Contains(filters.Identification.Trim().ToUpper()) ||
                                                   u.IdentificationWithoutHypens.Trim().ToUpper().Contains(filters.Identification.Trim().ToUpper()));

            if (filters.Type != null)
                lstAppUser = lstAppUser.Where(u => u.Type == filters.Type);

            if (filters.Status != null)
                lstAppUser = lstAppUser.Where(u => u.Status == filters.Status);

            return lstAppUser;
        }

        public async Task<BusisnessResult> Create(AppUser appUser, List<Guid> roles, Guid currentUserId)
        {
            BusisnessResult oResult = new();
            Client client;
            AppUser oUserToValidate;

            if (string.IsNullOrEmpty(appUser.Name) ||
               string.IsNullOrEmpty(appUser.Identification) ||
               string.IsNullOrEmpty(appUser.Email) ||
               string.IsNullOrEmpty(appUser.Phone))
            {
                oResult.Message = "No se pueden enviar campos vacíos.";

                return oResult;
            }

            if (appUser.Type == AppUserType.ADMINISTRADOR && roles?.Count <= 0)
            {
                oResult.Message = "Se debe seleccionar al menos un rol.";

                return oResult;
            }

            oUserToValidate = _unitOfWork.AppUser.GetFirstOrDefault(u => u.Identification.Trim().ToUpper() == appUser.Identification.Trim().ToUpper());

            if (oUserToValidate != null)
            {
                oResult.Message = "El número de identificación ya está en uso.";
                oResult.ResultCode = 0;

                return oResult;
            }

            oUserToValidate = _unitOfWork.AppUser.GetFirstOrDefault(u => u.Email.Trim().ToUpper() == appUser.Email.Trim().ToUpper());

            if (oUserToValidate != null)
            {
                oResult.Message = "El correo electrónico ya está en uso.";
                oResult.ResultCode = 1;

                return oResult;
            }

            oUserToValidate = _unitOfWork.AppUser.GetFirstOrDefault(u => u.Phone.Trim().ToUpper() == appUser.Phone.Trim().ToUpper());

            if (oUserToValidate != null)
            {
                oResult.Message = "El número de teléfono ya está en uso.";
                oResult.ResultCode = 2;

                return oResult;
            }

            if (appUser.Type == AppUserType.ADMINISTRADOR)
            {
                appUser.AppUserRoles = new List<AppUserRole>();

                roles.ForEach(roleId =>
                {
                    appUser.AppUserRoles.Add(new AppUserRole
                    {
                        RoleId = roleId,
                        AppUserId = appUser.Id
                    });
                });
            }

            string sIdentificationWithoutHypens = appUser.IdentificationWithoutHypens;
            string sEncryptedPassword = _passwordService.Hash(sIdentificationWithoutHypens);

            appUser.Id = Guid.NewGuid();
            appUser.AddedBy = currentUserId.ToString();
            appUser.CreationDate = DateTimeUtility.NowCostaRica;
            appUser.Status = EntityStatus.ACTIVADO;
            appUser.Password = sEncryptedPassword;

            client = new();
            client.AppUserId = appUser.Id;
            client.AutoSync = false;

            _unitOfWork.AppUser.Create(appUser);
            _unitOfWork.Client.Create(client);

            try
            {
                await _unitOfWork.BeginTransactionAsync();

                oResult.Success = await _unitOfWork.Save();

                await _unitOfWork.CommitTransactionAsync();
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollBackAsync();

                throw ex;
            }

            oResult.Message = "El usuario se creó correctamente!";

            return oResult;
        }

        public async Task<BusisnessResult> ChangeStatus(Guid userToChangeId, Guid currentUserId)
        {
            BusisnessResult oResult = new();

            if (userToChangeId == currentUserId)
            {
                oResult.Message = "No puedes desactivar tu cuenta de usuario, inicia sesión con otra cuenta.";

                return oResult;
            }

            var oUser = await _unitOfWork.AppUser.GetByIdAsync(userToChangeId);

            if (oUser == null)
            {
                oResult.Message = "El usuario no existe.";

                return oResult;
            }

            if (oUser.Status == EntityStatus.ACTIVADO)
            {
                oUser.Status = EntityStatus.DESACTIVADO;

                oResult.ResultCode = 0;

                oResult.Message = "La cuenta de usuario se ha desactivado.";
            }
            else
            {
                oUser.Status = EntityStatus.ACTIVADO;

                oResult.ResultCode = 1;

                oResult.Message = "La cuenta de usuario se ha activado.";
            }

            oUser.ModificationDate = DateTimeUtility.NowCostaRica;
            oUser.ModifiedBy = currentUserId.ToString();

            oResult.Success = await _unitOfWork.Save();

            return oResult;
        }
    }
}
