using Market_Express.Domain.Abstractions.Repositories;
using Market_Express.Domain.Abstractions.Validations;
using Market_Express.Domain.Entities;

namespace Market_Express.Domain.EntityValidations
{
    public class ArticleValidations : IArticleValidations
    {
        private Article _articulo;
        private readonly IUnitOfWork _unitOfWork;

        public ArticleValidations(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public Article Article
        {
            private get { return _articulo; }
            set { _articulo = value; }
        }

        public bool ExistsBarCode()
        {
            return _unitOfWork.Article.GetFirstOrDefault(x => x.BarCode == Article.BarCode) != null;
        }
    }
}