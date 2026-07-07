# ECR Module

Creates Amazon ECR repositories for all microservices.

## Example

```hcl
repositories = [
  "order-service",
  "inventory-service",
  "notification-service"
]
```