using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace GuidedActivity5.Models;
//The context provides access to the database
public partial class GA5Context : DbContext
{
    public GA5Context()
    {
    }

    public GA5Context(DbContextOptions<GA5Context> options)
        : base(options)
    {
    }
    //DbSet of Product
    //DbSet is a collection very similar to a list
    public virtual DbSet<Product> Products { get; set; }


    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.ProductId).HasName("PK__Products__B40CC6CD5569CA86");

            entity.ToTable("Products", "GA5");

            entity.Property(e => e.Price).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.ProductName).HasMaxLength(100);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
