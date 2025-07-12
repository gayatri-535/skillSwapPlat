console.log("Skill Swap Platform JS Loaded");

document.getElementById("loginForm")?.addEventListener("submit", function(e) { e.preventDefault(); alert("Login functionality is under development."); });

document.getElementById("profileForm")?.addEventListener("submit", function(e) { e.preventDefault(); alert("Profile saved (mockup)."); });
fetch("https://localhost:8080/api/users");