/**
 * app.js — Saabi AI
 * Entry point. Handles view routing and bootstraps the correct flow
 * (setup → onboarding → chat, or straight to chat for returning users).
 */

import { initOnboarding } from "./onboarding.js";
import { initChat }        from "./chat.js";

// Show a named view, hide all others
export function showView(name) {
  document.querySelectorAll(".view").forEach(v => v.classList.remove("active"));
  const target = document.getElementById(`view-${name}`);
  if (target) target.classList.add("active");
}

// Called by onboarding.js when setup completes
export function startApp(profile) {
  showView("chat");
  initChat(profile);
}

// ---- Boot sequence ----
function boot() {
  const setupDone  = localStorage.getItem("saabi_setup_done");
  const storedUser = localStorage.getItem("saabi_user");

  if (setupDone && storedUser) {
    // Returning user — go straight to chat
    const profile = JSON.parse(storedUser);
    showView("chat");
    initChat(profile);
  } else {
    // New user — show onboarding
    showView("onboarding");
    initOnboarding();
  }
}

// Setup view — API key entry
function initSetupView() {
  const form = document.getElementById("setup-form");
  if (!form) return;

  // Pre-fill from localStorage if already saved
  const saved = JSON.parse(localStorage.getItem("saabi_api_keys") || "{}");
  ["anthropic", "google", "perplexity"].forEach(key => {
    const input = document.getElementById(`key-${key}`);
    if (input && saved[key]) input.value = saved[key];
  });

  // Toggle visibility buttons
  document.querySelectorAll(".key-toggle").forEach(btn => {
    btn.addEventListener("click", () => {
      const targetId = btn.dataset.target;
      const input = document.getElementById(targetId);
      if (!input) return;
      if (input.type === "password") {
        input.type = "text";
        btn.textContent = "🙈";
      } else {
        input.type = "password";
        btn.textContent = "👁";
      }
    });
  });

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const keys = {};
    const anthropic   = document.getElementById("key-anthropic")?.value.trim();
    const google      = document.getElementById("key-google")?.value.trim();
    const perplexity  = document.getElementById("key-perplexity")?.value.trim();

    if (!anthropic && !google && !perplexity) {
      alert("Please enter at least one API key to continue.");
      return;
    }

    if (anthropic)  keys.anthropic  = anthropic;
    if (google)     keys.google     = google;
    if (perplexity) keys.perplexity = perplexity;

    localStorage.setItem("saabi_api_keys", JSON.stringify(keys));
    boot();
  });

  document.getElementById("btn-skip-setup")?.addEventListener("click", () => {
    boot();
  });
}

// Settings button in chat header
document.getElementById("btn-settings")?.addEventListener("click", () => {
  showView("setup");
  initSetupView();
});

// Reset profile button
document.getElementById("btn-reset")?.addEventListener("click", () => {
  if (confirm("Reset your Saabi profile? This clears your history and preferences.")) {
    localStorage.clear();
    location.reload();
  }
});

// Initialize
initSetupView();
boot();
