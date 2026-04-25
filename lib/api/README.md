# Cinema Booking API Layer

This folder is API-ready and mirrors the intended backend boundary.

- `client/` holds the API client and endpoint constants.
- `payload/` holds `ApiResponse`, `PaginationMeta`, and paginated response helpers.
- `services/` exposes feature-specific API classes.

The current mobile build uses mock-backed services so UI screens do not parse
raw payloads directly. Swapping to HTTP later should happen inside `ApiClient`
and service classes only.
