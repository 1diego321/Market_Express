using Market_Express.Application.Services;
using Market_Express.Domain.Options;
using Market_Express.Domain.Abstractions.ApplicationServices;
using Market_Express.Domain.Abstractions.DomainServices;
using Market_Express.Domain.Abstractions.InfrastructureServices;
using Market_Express.Domain.Abstractions.Repositories;
using Market_Express.Domain.Abstractions.Validations;
using Market_Express.Domain.EntityValidations;
using Market_Express.Domain.Services;
using Market_Express.Infrastructure.Data;
using Market_Express.Infrastructure.Data.Repositories;
using Market_Express.Infrastructure.EmailServices;
using Market_Express.Infrastructure.Services;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Azure;
using System;
using Market_Express.Infrastructure.ExternalServices.Azure;

namespace Market_Express.Infrastructure.Extensions
{
    public static class ServiceCollectionExtensions
    {
        public static void AddRepositories(this IServiceCollection services)
        {
            services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));

            services.AddTransient<IUnitOfWork, UnitOfWork>();
        }

        public static void AddDomainServices(this IServiceCollection services)
        {
            services.AddScoped(typeof(IAccountService), typeof(AccountService));

            services.AddScoped(typeof(IAddressService), typeof(AddressService));

            services.AddScoped(typeof(ICartService), typeof(CartService));

            services.AddScoped(typeof(IHomeService), typeof(HomeService));

            services.AddScoped(typeof(ISliderService), typeof(SliderService));

            services.AddScoped(typeof(ICategoryService), typeof(CategoryService));

            services.AddScoped(typeof(IRoleService), typeof(RoleService));

            services.AddScoped(typeof(IAppUserService), typeof(AppUserService));

            services.AddScoped(typeof(IArticleService), typeof(ArticleService));

            services.AddScoped(typeof(IOrderService), typeof(OrderService));

            services.AddScoped(typeof(IBinnacleAccessService), typeof(BinnacleAccessService));

            services.AddScoped(typeof(IBinnacleMovementService), typeof(BinnacleMovementService));

            services.AddScoped(typeof(IReportService), typeof(ReportService));

            services.AddScoped(typeof(IResourceService), typeof(ResourceService));
        }

        public static void AddApplicationServices(this IServiceCollection services)
        {
            services.AddScoped(typeof(ISystemService), typeof(SystemService));
        }

        public static void AddInfrastructureServices(this IServiceCollection services)
        {
            services.AddScoped(typeof(IAuthenticationService), typeof(AuthenticationService));

            services.AddScoped(typeof(IPasswordService), typeof(PasswordService));

            services.AddScoped(typeof(IBusisnessMailService), typeof(BusisnessMailService));

            services.AddScoped(typeof(IAzureBlobStorageService), typeof(AzureBlobStorageService));
        }

        public static void AddValidations(this IServiceCollection services)
        {
            services.AddTransient(typeof(IAppUserValidations), typeof(AppUserValidations));

            services.AddTransient(typeof(IClientValidations), typeof(ClientValidations));

            services.AddTransient(typeof(IArticleValidations), typeof(ArticleValidations));
        }

        public static void ConfigureAzureClients(this IServiceCollection services, IConfiguration configuration, bool isDevelopment)
        {
            string cnn = isDevelopment ? "Development_AzureBlobStorage" : "Production_AzureBlobStorage";

            services.AddAzureClients(builder =>
            {
                builder.AddBlobServiceClient(configuration.GetConnectionString(cnn));
            });
        }

        public static void ConfigureOptions(this IServiceCollection services, IConfiguration configuration)
        {
            services.Configure<AuthenticationOptions>(configuration.GetSection("Options:AuthenticationOptions"));

            services.Configure<PasswordOptions>(configuration.GetSection("Options:PasswordOptions"));

            services.Configure<EmailServicesOptions>(configuration.GetSection("Options:EmailServicesOptions"));

            services.Configure<AzureBlobStorageOptions>(configuration.GetSection("Options:AzureBlobStorageOptions"));

            services.Configure<PaginationOptions>(configuration.GetSection("Options:PaginationOptions"));

            services.Configure<ArticleOptions>(configuration.GetSection("Options:ArticleOptions"));

            services.Configure<CategoryOptions>(configuration.GetSection("Options:CategoryOptions"));

            services.Configure<OrderOptions>(configuration.GetSection("Options:OrderOptions"));
        }

        public static void ConfigureDbContext(this IServiceCollection services, IConfiguration configuration, bool isDevelopment)
        {
            string cnn = isDevelopment ? "Development_SQL" : "Production_SQL";

            services.AddDbContext<MARKET_EXPRESSContext>(options =>
            {
                options.UseSqlServer(configuration.GetConnectionString(cnn), sqlServerOptions =>
                {
                    sqlServerOptions.CommandTimeout(420);
                });
            });
        }

        public static void ConfigureAuthentication(this IServiceCollection services)
        {
            services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
                .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, config =>
                {
                    config.Cookie.Name = "App.Auth";
                    config.LoginPath = "/Account/Login";
                    config.AccessDeniedPath = "/Account/AccessDenied";
                    config.LogoutPath = "/Account/Logout";
                    config.ExpireTimeSpan = TimeSpan.FromMinutes(30);
                });
        }
    }
}
