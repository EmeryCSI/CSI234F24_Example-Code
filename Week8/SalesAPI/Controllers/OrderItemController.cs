using Microsoft.AspNetCore.Mvc;
using SalesAPI.Data;
using SalesAPI.Models;

namespace SalesAPI.Controllers
{
    /// <summary>
    /// API Controller for managing order items
    /// Handles the individual items within orders
    /// Route prefix: api/orderitems
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class OrderItemController : ControllerBase
    {
        private readonly MockRepository _repository;

        public OrderItemController(MockRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// GET: api/orderitems
        /// Retrieves all order items with their related order and product information
        /// </summary>
        [HttpGet]
        public ActionResult<IEnumerable<OrderItem>> GetOrderItems()
        {
            var orderItems = _repository.GetAllOrderItems();
            foreach (var item in orderItems)
            {
                // Populate product information
                item.Product = _repository.GetAllProducts()
                    .FirstOrDefault(p => p.Id == item.ProductId);
            }
            return Ok(orderItems);
        }

        /// <summary>
        /// GET: api/orderitems/{id}
        /// Retrieves a specific order item with its related order and product information
        /// </summary>
        [HttpGet("{id}")]
        public ActionResult<OrderItem> GetOrderItem(int id)
        {
            var orderItem = _repository.GetAllOrderItems()
                .FirstOrDefault(oi => oi.Id == id);

            if (orderItem == null)
            {
                return NotFound();
            }

            // Populate product information
            orderItem.Product = _repository.GetAllProducts()
                .FirstOrDefault(p => p.Id == orderItem.ProductId);

            return Ok(orderItem);
        }

        /// <summary>
        /// GET: api/orderitems/order/{orderId}
        /// Retrieves all items for a specific order
        /// </summary>
        [HttpGet("order/{orderId}")]
        public ActionResult<IEnumerable<OrderItem>> GetOrderItemsByOrder(int orderId)
        {
            // Verify order exists
            var orderExists = _repository.GetAllOrders()
                .Any(o => o.Id == orderId);

            if (!orderExists)
            {
                return NotFound("Order not found");
            }

            var items = _repository.GetAllOrderItems()
                .Where(oi => oi.OrderId == orderId)
                .ToList();

            // Populate product information
            foreach (var item in items)
            {
                item.Product = _repository.GetAllProducts()
                    .FirstOrDefault(p => p.Id == item.ProductId);
            }

            return Ok(items);
        }

        /// <summary>
        /// POST: api/orderitems
        /// Creates a new order item and updates the order's total amount
        /// </summary>
        [HttpPost]
        public ActionResult<OrderItem> CreateOrderItem(OrderItem orderItem)
        {
            var orders = _repository.GetAllOrders();
            var orderItems = _repository.GetAllOrderItems();

            // Verify order exists
            var order = orders.FirstOrDefault(o => o.Id == orderItem.OrderId);
            if (order == null)
            {
                return BadRequest("Invalid OrderId");
            }

            // Verify product exists and get its price
            var product = _repository.GetAllProducts()
                .FirstOrDefault(p => p.Id == orderItem.ProductId);
            if (product == null)
            {
                return BadRequest("Invalid ProductId");
            }

            // Generate new ID
            orderItem.Id = orderItems.Max(oi => oi.Id) + 1;
            orderItem.UnitPrice = product.Price;

            // Add the order item
            orderItems.Add(orderItem);

            // Update order total
            order.TotalAmount += orderItem.UnitPrice * orderItem.Quantity;

            return CreatedAtAction(
                nameof(GetOrderItem),
                new { id = orderItem.Id },
                orderItem);
        }

        /// <summary>
        /// PUT: api/orderitems/{id}
        /// Updates an existing order item and adjusts the order's total amount
        /// </summary>
        [HttpPut("{id}")]
        public IActionResult UpdateOrderItem(int id, OrderItem orderItem)
        {
            if (id != orderItem.Id)
            {
                return BadRequest();
            }

            var orderItems = _repository.GetAllOrderItems();
            var existingItem = orderItems.FirstOrDefault(oi => oi.Id == id);

            if (existingItem == null)
            {
                return NotFound();
            }

            // Verify product exists if product is changed
            if (orderItem.ProductId != existingItem.ProductId)
            {
                var product = _repository.GetAllProducts()
                    .FirstOrDefault(p => p.Id == orderItem.ProductId);
                if (product == null)
                {
                    return BadRequest("Invalid ProductId");
                }
                orderItem.UnitPrice = product.Price;
            }

            // Update order total amount
            var order = _repository.GetAllOrders()
                .FirstOrDefault(o => o.Id == existingItem.OrderId);
            if (order != null)
            {
                // Remove old amount and add new amount
                order.TotalAmount -= existingItem.UnitPrice * existingItem.Quantity;
                order.TotalAmount += orderItem.UnitPrice * orderItem.Quantity;
            }

            // Update item properties
            existingItem.ProductId = orderItem.ProductId;
            existingItem.Quantity = orderItem.Quantity;
            existingItem.UnitPrice = orderItem.UnitPrice;

            return NoContent();
        }

        /// <summary>
        /// DELETE: api/orderitems/{id}
        /// Deletes an order item and updates the order's total amount
        /// </summary>
        [HttpDelete("{id}")]
        public IActionResult DeleteOrderItem(int id)
        {
            var orderItems = _repository.GetAllOrderItems();
            var item = orderItems.FirstOrDefault(oi => oi.Id == id);

            if (item == null)
            {
                return NotFound();
            }

            // Update order total amount
            var order = _repository.GetAllOrders()
                .FirstOrDefault(o => o.Id == item.OrderId);
            if (order != null)
            {
                order.TotalAmount -= item.UnitPrice * item.Quantity;
            }

            // Remove the item
            orderItems.Remove(item);

            return NoContent();
        }
    }
}