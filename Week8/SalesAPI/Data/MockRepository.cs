using SalesAPI.Models;

namespace SalesAPI.Data
{
    public class MockRepository
    {
        private List<Customer> _customers;
        private List<Order> _orders;
        private List<OrderItem> _orderItems;
        private List<Product> _products;

        public MockRepository()
        {
            InitializeProducts();
            InitializeCustomers();
            InitializeOrders();
            InitializeOrderItems();
        }

        private void InitializeProducts()
        {
            _products = new List<Product>
            {
                new Product { Id = 1, Name = "Laptop", Description = "High-performance laptop", Price = 1299.99m },
                new Product { Id = 2, Name = "Smartphone", Description = "Latest model smartphone", Price = 799.99m },
                new Product { Id = 3, Name = "Headphones", Description = "Wireless noise-canceling headphones", Price = 199.99m },
                new Product { Id = 4, Name = "Tablet", Description = "10-inch tablet with stylus", Price = 499.99m },
                new Product { Id = 5, Name = "Smartwatch", Description = "Fitness tracking smartwatch", Price = 299.99m }
            };
        }

        private void InitializeCustomers()
        {
            _customers = new List<Customer>
            {
                new Customer { Id = 1, FirstName = "John", LastName = "Doe", Email = "john.doe@email.com" },
                new Customer { Id = 2, FirstName = "Jane", LastName = "Smith", Email = "jane.smith@email.com" },
                new Customer { Id = 3, FirstName = "Bob", LastName = "Johnson", Email = "bob.johnson@email.com" },
                new Customer { Id = 4, FirstName = "Alice", LastName = "Brown", Email = "alice.brown@email.com" },
                new Customer { Id = 5, FirstName = "Charlie", LastName = "Wilson", Email = "charlie.wilson@email.com" }
            };
        }

        private void InitializeOrders()
        {
            _orders = new List<Order>
            {
                new Order { Id = 1, CustomerId = 1, OrderDate = DateTime.Now.AddDays(-5), TotalAmount = 1499.98m },
                new Order { Id = 2, CustomerId = 2, OrderDate = DateTime.Now.AddDays(-3), TotalAmount = 799.99m },
                new Order { Id = 3, CustomerId = 1, OrderDate = DateTime.Now.AddDays(-2), TotalAmount = 699.98m },
                new Order { Id = 4, CustomerId = 3, OrderDate = DateTime.Now.AddDays(-1), TotalAmount = 1999.97m },
                new Order { Id = 5, CustomerId = 4, OrderDate = DateTime.Now, TotalAmount = 499.99m }
            };
        }

        private void InitializeOrderItems()
        {
            _orderItems = new List<OrderItem>
            {
                new OrderItem { Id = 1, OrderId = 1, ProductId = 1, Quantity = 1, UnitPrice = 1299.99m },
                new OrderItem { Id = 2, OrderId = 1, ProductId = 3, Quantity = 1, UnitPrice = 199.99m },
                new OrderItem { Id = 3, OrderId = 2, ProductId = 2, Quantity = 1, UnitPrice = 799.99m },
                new OrderItem { Id = 4, OrderId = 3, ProductId = 4, Quantity = 1, UnitPrice = 499.99m },
                new OrderItem { Id = 5, OrderId = 3, ProductId = 3, Quantity = 1, UnitPrice = 199.99m },
                new OrderItem { Id = 6, OrderId = 4, ProductId = 1, Quantity = 1, UnitPrice = 1299.99m },
                new OrderItem { Id = 7, OrderId = 4, ProductId = 2, Quantity = 1, UnitPrice = 799.99m },
                new OrderItem { Id = 8, OrderId = 5, ProductId = 4, Quantity = 1, UnitPrice = 499.99m }
            };
        }

        // Public methods to access the data - just the basic List getters
        public List<Customer> GetAllCustomers() => _customers;
        public List<Order> GetAllOrders() => _orders;
        public List<OrderItem> GetAllOrderItems() => _orderItems;
        public List<Product> GetAllProducts() => _products;
    }
}