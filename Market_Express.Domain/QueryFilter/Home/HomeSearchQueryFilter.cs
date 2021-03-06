using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;

namespace Market_Express.Domain.QueryFilter.Home
{
    public class HomeSearchQueryFilter : PaginationQueryFilter
    {
        [BindProperty(Name = "Query")]
        public string Query { get; set; }

        [BindProperty(Name = "Category")]
        public List<Guid> Category { get; set; }

        [BindProperty(Name = "MaxPrice")]
        public int? MaxPrice { get; set; }

        [BindProperty(Name = "MinPrice")]
        public int? MinPrice { get; set; }

        [BindProperty(Name = "FromSearchView")]
        public bool? FromSearchView { get; set; }
    }
}
