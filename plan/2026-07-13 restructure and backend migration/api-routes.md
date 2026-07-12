# API Routes — v1

Base URL: `https://api.<domain>/v1`. JSON everywhere. Auth: `Authorization: Bearer <access-token>` unless marked public. Related: [[plan]]

## Auth (public)

| Method | Route | Purpose |
|---|---|---|
| POST | `/auth/otp/request` | `{phone}` → send SMS code (rate-limited) |
| POST | `/auth/otp/verify` | `{phone, code}` → tokens + `isNewUser` |
| POST | `/auth/email/register` | `{email, password, name}` |
| POST | `/auth/email/login` | `{email, password}` → tokens |
| POST | `/auth/google` | `{idToken}` (web Google Sign-In) → tokens |
| POST | `/auth/refresh` | `{refreshToken}` → rotated token pair |
| POST | `/auth/logout` | revoke refresh token |

## Profile & addresses (customer)

| Method | Route | Purpose |
|---|---|---|
| GET / PATCH | `/users/me` | profile (name, email, phone, language) |
| GET / POST | `/users/me/addresses` | list / add address |
| PATCH / DELETE | `/users/me/addresses/:id` | edit / remove |
| POST | `/devices` | register FCM token `{token, platform}` |

## Catalog (public)

| Method | Route | Purpose |
|---|---|---|
| GET | `/categories` | list categories |
| GET | `/products?category=&search=&page=` | paginated catalog |
| GET | `/products/:id` | product detail |

## Orders (customer)

| Method | Route | Purpose |
|---|---|---|
| POST | `/orders` | `{addressId, items:[{productId, qty}], notes}` — COD, price computed server-side |
| GET | `/orders?page=` | my orders |
| GET | `/orders/:id` | detail + status timeline |
| POST | `/orders/:id/cancel` | allowed while status ≤ `confirmed` |

Live tracking: poll `GET /orders/:id`, plus FCM push on every status change (SSE endpoint can be added later if polling isn't enough).

## Driver (role: driver)

| Method | Route | Purpose |
|---|---|---|
| GET | `/driver/orders?status=` | orders assigned to me |
| PATCH | `/driver/orders/:id/status` | `{status, cashCollected?}` — enforce legal transitions |
| POST | `/driver/location` | `{lat, lng}` heartbeat while out for delivery |

## Admin (role: admin)

| Method | Route | Purpose |
|---|---|---|
| GET | `/admin/orders?status=&driverId=&from=&to=` | all orders, filters |
| PATCH | `/admin/orders/:id` | status override / edit |
| POST | `/admin/orders/:id/assign` | `{driverId}` |
| GET | `/admin/customers?search=` | customer list |
| CRUD | `/admin/products`, `/admin/categories` | catalog management (image upload: `POST /admin/uploads`) |
| GET / PATCH | `/admin/drivers` | manage driver accounts |
| GET | `/admin/stats?from=&to=` | orders/day, revenue, COD collected vs pending |

## Conventions

- Errors: `{statusCode, error, message}` (NestJS default), validation via class-validator.
- Money: integer cents, `EUR`.
- Pagination: `?page=&limit=` → `{items, total, page, limit}`.
- Versioned under `/v1` from day one; OpenAPI docs auto-generated at `/docs` (disabled in production or behind admin auth).
