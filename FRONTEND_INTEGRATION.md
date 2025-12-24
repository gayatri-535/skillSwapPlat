# SkillSwap Frontend Integration Guide

## Quick Start

### 1. **Start the Backend**
Before running the frontend, ensure the backend is running:

```powershell
cd c:\Users\HP\skillswapplat\backend\SSA
$env:DB_URL="jdbc:mysql://localhost:3306/skillswapdb"
$env:DB_USER="root"
$env:DB_PASS=""
java -jar target/skillswap-backend-1.0.0.jar
```

The backend will be available at `http://localhost:8080`

### 2. **Serve the Frontend**

You have two options:

#### Option A: Using a simple HTTP server
```bash
# Using Python (if installed)
cd c:\Users\HP\skillswapplat\frontend
python -m http.server 5500
```

Or use any other HTTP server:
```bash
# Using Node.js http-server
npx http-server -p 5500
```

#### Option B: Using VS Code Live Server
- Install the "Live Server" extension in VS Code
- Right-click `index.html` and select "Open with Live Server"
- It will open on `http://localhost:5500` by default

### 3. **Test the API**

Open the API tester page in your browser:
```
http://localhost:5500/api-test.html
```

## Frontend Architecture

### Files and Their Purposes

#### `api-client.js`
- Core API client library
- Handles all HTTP requests to the backend
- Manages user session in `sessionStorage`
- Key Classes and Functions:
  - `SkillSwapAPI`: Main API client with static methods
  - `sessionStorage_user`: Session management for logged-in user
  - `showMessage()`: Display messages to user
  - `showLoading()`: Show loading state

#### `index.html`
- Landing page with feature overview
- Navigation bar that updates based on login status
- Call-to-action buttons
- Responsive design

#### `register.html`
- User registration form
- Validates password confirmation
- Sends user data to backend
- Auto-redirects to login on success

#### `login.html`
- User login form
- Validates credentials with backend
- Stores user session on success
- Redirects to profile page

#### `profile.html`
- Displays logged-in user's profile
- Shows user details from session
- Quick action buttons
- Protected page (redirects to login if not authenticated)

#### `swap-requests.html`
- Main application interface
- Three tabs:
  1. **Create New Swap**: Find users and create swap requests
  2. **Browse Available Swaps**: View all pending swaps
  3. **My Swap Requests**: View user's own swaps
- Features:
  - User search by email
  - Create swap requests
  - Accept/cancel swaps
  - Real-time updates

#### `api-test.html`
- Advanced testing tool for API endpoints
- Four tabs:
  1. **User Tests**: Register, login, list users
  2. **Swap Tests**: Create, list, manage swaps
  3. **Quick Populate**: Generate test data
  4. **API Docs**: API endpoint documentation
- Dark theme with syntax highlighting
- Real-time response display

#### `css.css`
- Global styles
- Responsive design
- Color scheme: Green (#4CAF50) primary color
- Dark-themed inputs and cards

#### `script.js`
- Utility functions
- Backend health check
- Additional helpers

## API Endpoints

### User Endpoints

```
POST   /api/users/register
- Register a new user
- Body: { name, email, password, location, availability, isPublic, isBanned }

POST   /api/users/login
- Login with email and password
- Query: ?email={email}&password={password}
- Returns: User object

GET    /api/users
- List all active users
- Returns: Array of user objects

GET    /api/users/{email}
- Get user by email
- Returns: User object
```

### Swap Endpoints

```
POST   /api/swaps
- Create a swap request
- Body: { requesterId, receiverId, requestedSkill, offeredSkill }

GET    /api/swaps
- List all swap requests
- Returns: Array of swap objects

GET    /api/swaps/{id}
- Get swap by ID
- Returns: Swap object

GET    /api/swaps/user/{userId}
- List user's swap requests (as requester or receiver)
- Returns: Array of swap objects

POST   /api/swaps/{id}/accept
- Accept a swap request
- Sets status to 'accepted'

POST   /api/swaps/{id}/cancel
- Cancel a swap request
- Sets status to 'cancelled'
```

## Testing Workflow

### 1. **Register Test Users**

Using the API Tester:
1. Go to `api-test.html`
2. Switch to "User Tests" tab
3. Click "Generate 5 Test Users"
   - Or manually fill in user data and click "Register"

### 2. **Verify Users Created**

1. Click "Load Users" button
2. You should see a list of all registered users
3. Note down their IDs (1, 2, 3, etc.)

### 3. **Create Swap Requests**

1. Switch to "Swap Tests" tab
2. Set Requester ID = 1, Receiver ID = 2
3. Enter skills to swap
4. Click "Create Swap"

### 4. **Test Complete Flow**

1. Go to `index.html`
2. Click "Sign Up Now"
3. Register a new account
4. Login with those credentials
5. Go to "Browse Swaps" to see available swaps
6. Create a new swap request
7. In another browser/incognito, login as different user
8. Accept/decline the swap request

### 5. **Quick Populate (Recommended)**

For quick testing, use the "Quick Populate" tab:
1. Click "Generate All Test Data"
   - Creates 5 test users
   - Creates 10 test swaps
2. Instantly ready for full testing

## Sample Test Data

### Test Users (Auto-generated)
```
- Alice Smith (alice@test.com) - New York
- Bob Johnson (bob@test.com) - San Francisco
- Carol Davis (carol@test.com) - Boston
- David Lee (david@test.com) - Austin
- Emma Wilson (emma@test.com) - Seattle
```

All with password: `pass123`

### Sample Swap Requests
```
1 → 2: Python for Web Design
2 → 3: JavaScript for Graphic Design
3 → 4: React for Marketing
4 → 5: Java for Photography
5 → 1: Golang for Writing
```

## Session Management

The frontend uses `sessionStorage` to store the logged-in user:
- User data is stored in `skillswap_user` key
- Data is cleared when browser closes
- Login page checks if user is already logged in

## CORS Configuration

The backend has CORS enabled for:
- `http://localhost:5500` (Frontend port)
- `http://localhost:3000` (Alternative port)

If you use a different port, update the CORS configuration in the backend.

## Troubleshooting

### Backend Not Responding
- Check that backend is running on `http://localhost:8080`
- Verify database is accessible
- Check browser console for detailed errors

### Login Not Working
- Verify user exists (check email in "List Users")
- Verify password is correct (default test password: `pass123`)
- Check that passwords are case-sensitive

### Swap Creation Failing
- Ensure both User IDs exist (use "List Users" to verify)
- User IDs should be different (can't swap with yourself)
- Check user availability status

### Database Errors
- Verify MySQL is running
- Check database credentials in backend
- Re-import schema if needed:
  ```powershell
  mysql -u root -p < "C:\Users\HP\skillswapplat\database\schema.sql"
  ```

## Development Notes

### Adding New Features

1. **Update API Client** (`api-client.js`)
   - Add new methods to `SkillSwapAPI` class
   - Follow existing patterns for consistency

2. **Create/Update HTML Pages**
   - Include `api-client.js` script tag
   - Use `SkillSwapAPI` methods for backend calls
   - Check `SkillSwapAPI.isLoggedIn()` for protected pages

3. **Update CSS** (`css.css`)
   - Follow existing color scheme
   - Keep responsive design principles

### Browser Compatibility
- Modern browsers (Chrome, Firefox, Safari, Edge)
- Requires JavaScript enabled
- LocalStorage/SessionStorage support required

## Security Notes

⚠️ **Important for Production**
- Store sensitive data (API keys, passwords) securely
- Use HTTPS in production
- Implement token-based auth (JWT) instead of session storage
- Add CSRF protection
- Validate all inputs on backend
- Never expose sensitive data in logs

## Performance Tips

- Use the API tester's "Quick Populate" feature to test with real data
- Cache user list if fetching frequently
- Implement pagination for large datasets
- Lazy load user swaps on demand

## Need Help?

Check the following:
1. Backend logs for error details
2. Browser console (F12) for JavaScript errors
3. Network tab for HTTP request details
4. The api-test.html page for detailed API documentation
