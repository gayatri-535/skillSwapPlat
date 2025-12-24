# SkillSwap Platform - Architecture Overview

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          WEB BROWSER                                    │
│                      (http://localhost:5500)                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │
│  │ Landing Page │  │   Register   │  │    Login     │                 │
│  │ (index.html) │  │(register.html)│  │ (login.html) │                 │
│  └──────────────┘  └──────────────┘  └──────────────┘                 │
│         │                │                │                             │
│         └────────────────┴────────────────┘                             │
│                          │                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │
│  │   Profile    │  │ Swap Manager │  │  API Tester  │                 │
│  │(profile.html)│  │(Swap-req.html)│  │(api-test.html)│               │
│  └──────────────┘  └──────────────┘  └──────────────┘                 │
│         │                │                │                             │
│         └────────────────┴────────────────┘                             │
│                          │                                               │
│         ┌────────────────────────────────┐                             │
│         │      api-client.js             │ ← Core API Library          │
│         │   (All API calls go through)   │                             │
│         └────────────────────────────────┘                             │
│                          │                                               │
│         ┌────────────────────────────────┐                             │
│         │      sessionStorage            │ ← Session Management        │
│         │   (User { id, email, name })   │                             │
│         └────────────────────────────────┘                             │
│                          │                                               │
│         ┌────────────────────────────────┐                             │
│         │    CSS Styling (css.css)       │ ← Responsive Design         │
│         │     (All pages styled)         │                             │
│         └────────────────────────────────┘                             │
│                          │                                               │
└──────────────────────────┼───────────────────────────────────────────────┘
                          │
                   HTTP/JSON (Port 8080)
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      SPRING BOOT BACKEND                                │
│               (http://localhost:8080/api)                               │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────┐     │
│  │              REST Controllers (Routes)                       │     │
│  │                                                              │     │
│  │  ┌──────────────────┐  ┌──────────────────────┐            │     │
│  │  │ UserController   │  │ SwapController       │            │     │
│  │  │  - register      │  │  - createSwap        │            │     │
│  │  │  - login         │  │  - listSwaps         │            │     │
│  │  │  - getUsers      │  │  - acceptSwap        │            │     │
│  │  │  - getUser       │  │  - cancelSwap        │            │     │
│  │  └──────────────────┘  └──────────────────────┘            │     │
│  │                                                              │     │
│  └────────────────────────────────────────────────────────────┘     │
│                          │                                           │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │              Services (Business Logic)                        │   │
│  │                                                              │   │
│  │  ┌──────────────────┐  ┌──────────────────────┐            │   │
│  │  │ UserService      │  │ SwapService          │            │   │
│  │  │  - validate user │  │  - validate swap     │            │   │
│  │  │  - hash password │  │  - process swap flow │            │   │
│  │  │  - fetch users   │  │  - update status     │            │   │
│  │  │  - BCrypt ops    │  │  - notify changes    │            │   │
│  │  └──────────────────┘  └──────────────────────┘            │   │
│  │                                                              │   │
│  └────────────────────────────────────────────────────────────┘   │
│                          │                                           │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │           Data Access Layer (DAO - JDBC)                     │   │
│  │                                                              │   │
│  │  ┌──────────────────┐  ┌──────────────────────┐            │   │
│  │  │ UserDao          │  │ SwapDao              │            │   │
│  │  │  - insertUser()  │  │  - createSwap()      │            │   │
│  │  │  - findByEmail() │  │  - findById()        │            │   │
│  │  │  - listAllUsers()│  │  - listSwaps()       │            │   │
│  │  │  - updateUser()  │  │  - updateStatus()    │            │   │
│  │  │                  │  │  - cancelSwap()      │            │   │
│  │  └──────────────────┘  └──────────────────────┘            │   │
│  │                                                              │   │
│  └────────────────────────────────────────────────────────────┘   │
│                          │                                           │
│         ┌────────────────────────────────┐                         │
│         │   Connection Pool (HikariCP)   │ ← JDBC Connections     │
│         │   (Manages MySQL connections) │                         │
│         └────────────────────────────────┘                         │
│                          │                                           │
└──────────────────────────┼───────────────────────────────────────────┘
                          │
              JDBC/SQL (Port 3306)
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         MYSQL DATABASE                                  │
│                   (skillswapdb on localhost)                            │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────┐     │
│  │                    Tables                                    │     │
│  │                                                              │     │
│  │  ┌──────────────────────────────────────────────────────┐   │     │
│  │  │ users                                                │   │     │
│  │  │  - id (PK)                                          │   │     │
│  │  │  - email (UNIQUE)                                  │   │     │
│  │  │  - password_hash (BCrypt)                          │   │     │
│  │  │  - name                                            │   │     │
│  │  │  - location                                        │   │     │
│  │  │  - availability                                    │   │     │
│  │  │  - created_at, banned_status                       │   │     │
│  │  └──────────────────────────────────────────────────────┘   │     │
│  │                                                              │     │
│  │  ┌──────────────────────────────────────────────────────┐   │     │
│  │  │ swap_requests                                        │   │     │
│  │  │  - id (PK)                                          │   │     │
│  │  │  - requester_id (FK → users.id)                    │   │     │
│  │  │  - receiver_id (FK → users.id)                     │   │     │
│  │  │  - status (ENUM: pending, accepted, declined)      │   │     │
│  │  │  - created_at, updated_at                          │   │     │
│  │  └──────────────────────────────────────────────────────┘   │     │
│  │                                                              │     │
│  │  ┌──────────────────────────────────────────────────────┐   │     │
│  │  │ swap_request_details                                │   │     │
│  │  │  - id (PK)                                          │   │     │
│  │  │  - swap_request_id (FK → swap_requests.id)         │   │     │
│  │  │  - wanted_skill                                    │   │     │
│  │  │  - offered_skill                                   │   │     │
│  │  └──────────────────────────────────────────────────────┘   │     │
│  │                                                              │     │
│  └──────────────────────────────────────────────────────────┘     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow: User Registration

```
┌──────────────────┐
│  User enters     │
│  registration    │
│  data in form    │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  register.html validates form        │
│  (client-side validation)            │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  api-client.js calls                 │
│  SkillSwapAPI.register(userData)     │
│  (fetch POST to /api/users/register) │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  UserController receives request     │
│  (Spring handles routing)            │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  UserService validates & processes   │
│  - Validates email not duplicate     │
│  - Hashes password with BCrypt       │
│  - Prepares user object              │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  UserDao inserts into database       │
│  (JDBC executes SQL INSERT)          │
│  INSERT INTO users (...)             │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  MySQL stores user in database       │
│  (Row added to users table)          │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Response returned to frontend       │
│  { id, email, name, ... }           │
│  HTTP 200 OK                         │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  register.html receives response     │
│  Shows success message               │
│  Redirects to login.html             │
└──────────────────────────────────────┘
```

---

## Data Flow: User Login & Session

```
┌──────────────────┐
│  User enters     │
│  email & password│
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  login.html validates form           │
│  (client-side validation)            │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  api-client.js calls                 │
│  SkillSwapAPI.login(email, password) │
│  (fetch POST to /api/users/login)    │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  UserController receives request     │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  UserService validates credentials   │
│  - Finds user by email in DB         │
│  - Compares password with BCrypt     │
│  - Validates match                   │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Response: { id, email, name, ... }  │
│  or { error: "Invalid credentials" } │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  login.html stores in sessionStorage │
│  sessionStorage.user = user object   │
│  (persists in browser until close)   │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Page redirects to profile.html      │
│  (User is now logged in!)            │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  All other pages can access user via │
│  SkillSwapAPI.getCurrentUser()       │
│  which reads from sessionStorage      │
└──────────────────────────────────────┘
```

---

## Data Flow: Create Swap Request

```
┌──────────────────────┐
│  User on Swap-       │
│  request.html        │
│  searches for user   │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Type email to search                │
│  api-client.js calls                 │
│  SkillSwapAPI.getUserByEmail(email)  │
│  (fetch GET to /api/users/{email})   │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  UserController returns matching user│
│  { id, name, location, skills ... }  │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  UI displays user info               │
│  User clicks to select them          │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  User fills:                         │
│  - Skill they want to learn          │
│  - Skill they can teach              │
│  Clicks: Create Swap Request         │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  api-client.js calls                 │
│  SkillSwapAPI.createSwap()           │
│  POST /api/swaps with payload:       │
│  {                                   │
│    requesterId, receiverId,          │
│    requestedSkill, offeredSkill      │
│  }                                   │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  SwapController receives request     │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  SwapService validates:              │
│  - Both users exist                  │
│  - Not creating swap with self       │
│  - Skills are not empty              │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  SwapDao inserts into database:      │
│  1. INSERT INTO swap_requests        │
│  2. INSERT INTO swap_request_details │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  MySQL stores swap request           │
│  (Status: "pending")                 │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Response: { swapId, status, ... }   │
│  HTTP 200 OK (or error)              │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Swap-request.html shows success     │
│  New swap appears in Browse tab      │
│  Receiver gets notified (logged in)  │
└──────────────────────────────────────┘
```

---

## Component Interaction Map

```
Frontend Components:
├── api-client.js (Core)
│   ├── Used by: ALL HTML pages
│   ├── Provides: API methods + session management
│   └── Depends on: JavaScript Fetch API
│
├── Session Management
│   ├── Stores: User object in sessionStorage
│   ├── Used by: All pages for auth checks
│   └── Cleared: On logout
│
├── Pages
│   ├── index.html (Entry point)
│   │   ├── Depends on: css.css, api-client.js
│   │   ├── Calls: SkillSwapAPI.isLoggedIn()
│   │   └── Navigates to: login, register, profile, swaps
│   │
│   ├── register.html
│   │   ├── Depends on: css.css, api-client.js
│   │   ├── Calls: SkillSwapAPI.register()
│   │   └── Redirects to: login.html
│   │
│   ├── login.html
│   │   ├── Depends on: css.css, api-client.js
│   │   ├── Calls: SkillSwapAPI.login()
│   │   ├── Stores: User in sessionStorage
│   │   └── Redirects to: profile.html
│   │
│   ├── profile.html
│   │   ├── Depends on: css.css, api-client.js
│   │   ├── Requires: User logged in
│   │   ├── Calls: SkillSwapAPI.getCurrentUser()
│   │   ├── Protected: Redirects to login if not auth
│   │   └── Actions: View swaps, logout
│   │
│   ├── Swap-request.html
│   │   ├── Depends on: css.css, api-client.js
│   │   ├── Requires: User logged in
│   │   ├── Calls: getUserByEmail, listSwaps, createSwap, etc.
│   │   ├── Protected: Redirects to login if not auth
│   │   └── Features: 3 tabs (Create, Browse, My Requests)
│   │
│   ├── api-test.html
│   │   ├── Depends on: css.css, api-client.js
│   │   ├── Provides: 4 tabs (User, Swap, Quick Populate, Docs)
│   │   ├── Special: "Quick Populate" generates test data
│   │   └── No auth required (testing tool)
│   │
│   └── script.js
│       ├── Depends on: api-client.js
│       ├── Runs on: Page load
│       └── Function: Backend health check

Backend Components:
├── SkillSwapApp (Entry Point)
│   ├── Spring Boot application
│   ├── Enables: @ComponentScan, @EnableAutoConfiguration
│   └── Configures: CORS for frontend
│
├── Controllers (Routing)
│   ├── UserController
│   │   ├── Routes: /api/users/register, /login, GET /users, etc.
│   │   └── Calls: UserService methods
│   │
│   └── SwapController
│       ├── Routes: /api/swaps/create, GET /swaps, etc.
│       └── Calls: SwapService methods
│
├── Services (Business Logic)
│   ├── UserService
│   │   ├── Validates users
│   │   ├── Hashes passwords (BCrypt)
│   │   └── Calls: UserDao methods
│   │
│   └── SwapService
│       ├── Validates swaps
│       ├── Manages swap status
│       └── Calls: SwapDao methods
│
├── DAOs (Data Access)
│   ├── UserDao
│   │   ├── JDBC queries for users table
│   │   ├── Methods: insertUser, findByEmail, listAllUsers, etc.
│   │   └── Uses: JdbcTemplate from Spring
│   │
│   └── SwapDao
│       ├── JDBC queries for swap tables
│       ├── Methods: createSwap, findById, updateStatus, etc.
│       └── Uses: JdbcTemplate from Spring
│
└── Models (Data Classes)
    ├── User
    │   └── Properties: id, email, name, location, availability, etc.
    │
    └── SwapRequest
        └── Properties: id, requesterId, receiverId, status, etc.

Database:
├── users table
│   ├── Accessed by: UserDao & UserController
│   ├── Stores: User accounts with BCrypt hashed passwords
│   └── Relationships: 1 user = many swap_requests
│
├── swap_requests table
│   ├── Accessed by: SwapDao & SwapController
│   ├── Stores: Swap request headers (who, when, status)
│   └── Relationships: 1 swap_request = 1+ swap_request_details
│
└── swap_request_details table
    ├── Accessed by: SwapDao
    ├── Stores: Specific skills for each swap
    └── Relationships: Many details = 1 swap_request
```

---

## Technology Stack Summary

```
Frontend Layer:
├── HTML5
│   ├── Semantic structure
│   ├── Form validation attributes
│   └── Mobile-responsive viewport
│
├── CSS3
│   ├── Flexbox & Grid layout
│   ├── Responsive design (mobile-first)
│   ├── Professional color scheme (#667eea, #764ba2)
│   └── Focus states for accessibility
│
└── JavaScript (ES6+)
    ├── Fetch API for HTTP requests
    ├── Async/await for promise handling
    ├── sessionStorage for persistence
    ├── DOM manipulation
    └── Event handling & validation

Backend Layer:
├── Spring Boot 3.2.6
│   ├── Auto-configuration
│   ├── Embedded Tomcat (port 8080)
│   ├── Dependency injection
│   └── Exception handling
│
├── Spring JDBC
│   ├── JdbcTemplate for queries
│   ├── HikariCP connection pool
│   ├── Prepared statements (SQL injection prevention)
│   └── Transaction management
│
├── Spring Security
│   ├── BCrypt password encoder
│   ├── Password hashing & verification
│   └── Cryptographic operations
│
└── Java 24
    ├── Record classes (modern syntax)
    ├── Enhanced for-loops
    └── Optional<> for null safety

Database Layer:
├── MySQL 8.0
│   ├── InnoDB storage engine
│   ├── Foreign key relationships
│   ├── Indexed columns for performance
│   └── ENUM data types for status
│
└── JDBC Driver
    ├── Direct database connection
    ├── Connection pooling
    ├── Result set mapping
    └── PreparedStatement support

Communication:
├── HTTP Protocol
│   ├── REST architecture
│   ├── JSON payload format
│   ├── Standard HTTP methods (GET, POST, PUT, DELETE)
│   └── Appropriate status codes
│
├── CORS Headers
│   ├── Allows cross-origin requests
│   ├── Whitelisted origins: localhost:5500, localhost:3000
│   └── Supports credentials
│
└── Session Management
    ├── Browser sessionStorage (frontend)
    ├── Stateless backend (no sessions)
    └── User object in each request
```

---

## Error Handling Flow

```
User Action
    │
    ▼
┌─────────────────────────────────────┐
│ Client-Side Validation (HTML5)      │ ← Catch obvious errors first
├─────────────────────────────────────┤
│ - Required fields filled?           │
│ - Email format valid?               │
│ - Passwords match?                  │
│ - Strings not empty?                │
└─────────────────────────────────────┘
    │
    ├─ Error? Show message to user
    │   (No API call made)
    │
    └─ OK? Continue to backend
         │
         ▼
    ┌─────────────────────────────────────┐
    │ API Request via fetch()             │
    ├─────────────────────────────────────┤
    │ POST /api/users/login               │
    │ { email, password }                 │
    └─────────────────────────────────────┘
         │
         ▼
    ┌─────────────────────────────────────┐
    │ Server-Side Validation (Service)    │ ← Business logic validation
    ├─────────────────────────────────────┤
    │ - User exists?                      │
    │ - Password matches (BCrypt)?        │
    │ - Account not banned?               │
    │ - Email verified?                   │
    └─────────────────────────────────────┘
         │
         ├─ Error? Return HTTP 400/401
         │   Response: { error: "Invalid credentials" }
         │   │
         │   ▼
         │   Frontend shows error message
         │   (User sees clear error)
         │
         └─ OK? Return HTTP 200
             Response: { id, email, name, ... }
             │
             ▼
             Frontend stores in sessionStorage
             User is logged in successfully

Unhandled Errors:
├─ Try/catch blocks in api-client.js
├─ Log to console
├─ Show generic error message to user
├─ Return null or error object
└─ Don't crash the application
```

---

## Performance Considerations

```
Frontend Optimization:
├── Lazy loading (images if added)
├── Minimal HTTP requests
├── Client-side validation (reduce server calls)
├── Caching in sessionStorage
├── CSS minified in production
├── JavaScript minified in production
└── Responsive design (no unnecessary rendering)

Backend Optimization:
├── Connection pooling (HikariCP)
│   ├── Min: 5 connections
│   ├── Max: 20 connections
│   └── Reused across requests
│
├── Database indexes
│   ├── users.email (UNIQUE)
│   ├── swap_requests.requester_id
│   ├── swap_requests.receiver_id
│   └── swap_requests.status
│
├── Query optimization
│   ├── SELECT only needed columns
│   ├── JOIN instead of N+1 queries
│   ├── Pagination for large result sets
│   └── PreparedStatement caching
│
└── Response caching
    ├── User list (low volatility)
    ├── Static responses (user doesn't change often)
    └── Cache-Control headers
```

---

This architecture diagram shows:
- How components communicate
- Data flow through the system
- Technology stack details
- Error handling patterns
- Performance optimizations

The design is clean, modular, and follows best practices for full-stack web applications.
