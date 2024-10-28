using System;
using System.Collections.Generic;

namespace GuidedActivity5.Models;

//A model is a C# class that represents an entry in a table
public partial class Product
{
    public int ProductId { get; set; }

    public string ProductName { get; set; } = null!;

    public decimal Price { get; set; }

    public string? Description { get; set; }
}
