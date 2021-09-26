﻿using Market_Express.Domain.Entities;

namespace Market_Express.Domain.Abstractions.Validations
{
    public interface IArticuloValidations
    {
        bool ExistsCodigoBarras();
        Article Articulo { set; }
    }
}
