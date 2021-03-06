using Market_Express.Domain.Entities;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Market_Express.Domain.Abstractions.DomainServices
{
    public interface ISliderService
    {
        IEnumerable<Slider> GetAll();
        Task<Slider> GetById(Guid id);
        Task<BusisnessResult> Create(string name, IFormFile image, Guid userId);
        Task<BusisnessResult> Update(Slider slider, IFormFile image, Guid userId);
        Task<BusisnessResult> ChangeStatus(Guid sliderId, Guid userId);
    }
}
