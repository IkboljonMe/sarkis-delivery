# Sarkis Delivery Project Structure

This repository is structured as a monorepo containing three distinct modules. Because of this structure, configuration files like `.env` are placed within their respective project folders rather than at the root.

## 1. `app/` (Mobile Applications)
Contains the Flutter mobile applications for the platform.
*   **`admin_app/`**: The mobile app for store administrators and drivers to manage delivery workflows.
*   **`customer_app/`**: The mobile app for end-users/customers to browse the shop and place orders.
*   *(Both apps have their own `.env` files for frontend API keys and base URLs)*

## 2. `backend/` (API Server)
The core REST API backend for the platform.
*   Built using **Node.js**, **NestJS**, and **Prisma ORM**.
*   Uses a **PostgreSQL** database and Redis (managed locally via Docker Compose).
*   Contains a `.env` file that defines database connection URLs, JWT secrets, and other server-side configurations.

## 3. `frontend/` (Web Applications)
Contains web-based clients.
*   **`landing/`**: Usually a Next.js/React based web application serving as the landing page or a web dashboard.
