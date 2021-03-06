using Market_Express.Domain.Abstractions.Repositories;
using Market_Express.Domain.Constants;
using Market_Express.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;
using Market_Express.CrossCutting.Response;
using Market_Express.Domain.Abstractions.ApplicationServices;
using Market_Express.Domain.Abstractions.Validations;
using Market_Express.Domain.Abstractions.InfrastructureServices;
using Market_Express.CrossCutting.Utility;
using System.Linq;
using Market_Express.Domain.Enumerations;

namespace Market_Express.Application.Services
{
    public class SystemService : ISystemService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAppUserValidations _appUserValidations;
        private readonly IClientValidations _clientValidations;
        private readonly IArticleValidations _articuloValidations;
        private readonly IPasswordService _passwordService;

        public SystemService(IUnitOfWork unitOfWork,
                             IAppUserValidations usuarioValidations,
                             IClientValidations clienteValidations,
                             IArticleValidations articuloValidations,
                             IPasswordService passwordService)
        {
            _unitOfWork = unitOfWork;
            _appUserValidations = usuarioValidations;
            _clientValidations = clienteValidations;
            _articuloValidations = articuloValidations;
            _passwordService = passwordService;
        }


        public async Task<SyncResponse> SyncClients(List<Client> lstClientsToClient)
        {
            SyncResponse oResponse = new();

            if (lstClientsToClient?.Count <= 0)
                return oResponse;

            List<Client> lstClientsToAdd = new();
            bool bIsNew = false;
            int iAdded = 0;
            int iUpdated = 0;

            var lstClientsFromDb = _unitOfWork.Client.GetAll(nameof(Client.AppUser));

            //lstClientsToClient.ForEach(oClientPOS =>
            foreach(var oClientPOS in lstClientsToClient)
            {
                bIsNew = true;

                foreach (var oClientDb in lstClientsFromDb)
                {
                    if (oClientDb.Id == oClientPOS.Id)
                    {
                        if (oClientDb.AutoSync)
                        {
                            if (oClientDb.AppUser.Name.Trim().ToUpper() != oClientPOS.AppUser.Name?.Trim().ToUpper() ||
                                oClientDb.AppUser.Identification.Trim().ToUpper() != oClientPOS.AppUser.Identification?.Trim().ToUpper() ||
                                oClientDb.AppUser.Email.Trim().ToUpper() != oClientPOS.AppUser.Email?.Trim().ToUpper() ||
                                oClientDb.AppUser.Phone.Trim().ToUpper() != oClientPOS.AppUser.Phone?.Trim().ToUpper())
                            {
                                _appUserValidations.AppUser = oClientPOS.AppUser;

                                if (!_appUserValidations.ExistsEmail())
                                    oClientDb.AppUser.Email = oClientPOS.AppUser.Email?.Trim();


                                if (!_appUserValidations.ExistsIdentification())
                                    oClientDb.AppUser.Identification = oClientPOS.AppUser.Identification?.Trim();


                                oClientDb.AppUser.Name = oClientPOS.AppUser.Name?.Trim();
                                oClientDb.AppUser.Phone = oClientPOS.AppUser.Phone?.Trim();

                                oClientDb.AppUser.ModifiedBy = SystemConstants.SYSTEM;
                                oClientDb.AppUser.ModificationDate = DateTimeUtility.NowCostaRica;

                                _unitOfWork.AppUser.Update(oClientDb.AppUser);

                                iUpdated++;
                            }
                        }

                        bIsNew = false;

                        break;
                    }
                }

                if (bIsNew)
                {
                    if (!lstClientsToAdd.Contains(oClientPOS))
                    {
                        _clientValidations.Client = oClientPOS;
                        _appUserValidations.AppUser = oClientPOS.AppUser;

                        if (!_clientValidations.ExistsClientCode() &&
                            !_appUserValidations.ExistsIdentification() &&
                            !_appUserValidations.ExistsEmail())
                        {
                            oClientPOS.AutoSync = false;
                            oClientPOS.AppUser.CreationDate = DateTimeUtility.NowCostaRica;
                            oClientPOS.AppUser.Status = EntityStatus.ACTIVADO;
                            oClientPOS.AppUser.AddedBy = SystemConstants.SYSTEM;
                            oClientPOS.AppUser.Password = _passwordService.Hash(oClientPOS.AppUser.IdentificationWithoutHypens);

                            lstClientsToAdd.Add(oClientPOS);
                        }
                    }
                }
            }

            iAdded = lstClientsToAdd.Count;

            if (iAdded > 0)
                _unitOfWork.Client.Create(lstClientsToAdd);

            if (iAdded > 0 || iUpdated > 0)
                await _unitOfWork.Save();

            oResponse.AddedCount = iAdded;
            oResponse.UpdatedCount = iUpdated;
            oResponse.Success = true;

#pragma warning disable CS4014 // Dado que no se esperaba esta llamada, la ejecución del método actual continuará antes de que se complete la llamada
            Task.Run(() => CreateCarts(lstClientsToAdd));
#pragma warning restore CS4014 // Dado que no se esperaba esta llamada, la ejecución del método actual continuará antes de que se complete la llamada

            return oResponse;
        }

        private async Task CreateCarts(List<Client> clients)
        {
            foreach (var client in clients)
            {
                _unitOfWork.Cart.Create(new Cart
                {
                    Status = CartStatus.ABIERTO,
                    OpeningDate = DateTimeUtility.NowCostaRica,
                    ClientId = client.Id,
                    Id = new System.Guid()
                });
            }

            await _unitOfWork.Save();
        }

        public async Task<SyncResponse> SyncArticles(List<Article> lstArticlesToSync)
        {
            SyncResponse oResponse = new();

            if (lstArticlesToSync?.Count <= 0)
                return oResponse;

            List<Article> lstArticlesToAdd = new();
            bool bIsNew = false;
            int iAdded = 0;
            int iUpdated = 0;


            var lstArticlesFromDb = _unitOfWork.Article.GetAll().ToList();

            foreach (var oArticlePOS in lstArticlesToSync)
            {
                bIsNew = true;

                foreach (var oArticleDb in lstArticlesFromDb)
                {
                    if (oArticleDb.Id == oArticlePOS.Id)
                    {
                        if (oArticleDb.AutoSync)
                        {
                            if (oArticleDb.Description.Trim() != oArticlePOS.Description?.Trim() ||
                                oArticleDb.BarCode.Trim() != oArticlePOS.BarCode?.Trim() ||
                                oArticleDb.Price != oArticlePOS.Price)
                            {
                                _articuloValidations.Article = oArticlePOS;

                                //if (!_articuloValidations.ExistsBarCode())

                                if (oArticleDb.AutoSyncDescription)
                                    oArticleDb.Description = oArticlePOS.Description.Trim();

                                oArticleDb.BarCode = oArticlePOS.BarCode.Trim();
                                oArticleDb.Price = oArticlePOS.Price;
                                oArticleDb.ModifiedBy = SystemConstants.SYSTEM;
                                oArticleDb.ModificationDate = DateTimeUtility.NowCostaRica;

                                _unitOfWork.Article.Update(oArticleDb);

                                iUpdated++;
                            }
                        }

                        bIsNew = false;

                        break;
                    }
                }

                if (bIsNew)
                {
                    if (!lstArticlesToAdd.Contains(oArticlePOS))
                    {
                        _articuloValidations.Article = oArticlePOS;

                        //if (!_articuloValidations.ExistsBarCode())
                        //{

                        oArticlePOS.AutoSync = true;
                        oArticlePOS.AutoSyncDescription = true;
                        oArticlePOS.CreationDate = DateTimeUtility.NowCostaRica;
                        oArticlePOS.Status = EntityStatus.ACTIVADO;
                        oArticlePOS.AddedBy = SystemConstants.SYSTEM;

                        lstArticlesToAdd.Add(oArticlePOS);

                        //}
                    }
                }
            }

            iAdded = lstArticlesToAdd.Count;

            if (iAdded > 0)
                _unitOfWork.Article.Create(lstArticlesToAdd);

            if (iAdded > 0 || iUpdated > 0)
                await _unitOfWork.Save();

            oResponse.AddedCount = iAdded;
            oResponse.UpdatedCount = iUpdated;
            oResponse.Success = true;

            return oResponse;
        }
    }
}
