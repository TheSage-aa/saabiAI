/**
 * chat.js — Saabi AI
 * Controls the chat UI: renders messages, calls the backend API,
 * handles typing indicators, citations, and escalation triggers.
 */

import { clientSideCheck, showEscalation } from "./escalation.js";

// Use relative URL when served from FastAPI, fallback to localhost for dev
const BACKEND_URL = window.location.protocol === "file:" ? "http://localhost:8000" : "";

const QUICK_STARTS = [
  "What is U=U and does it mean I can't transmit HIV?",
  "How do I start ART and what should I expect?",
  "How can I protect myself from STIs?",
  "I've been feeling really anxious lately",
  "What foods should I eat if I'm living with HIV?",
  "What are my rights if I'm HIV positive in Nigeria?",
];

let userProfile = null;
let conversationHistory = [];

export function initChat(profile) {
  userProfile = profile;
  conversationHistory = JSON.parse(localStorage.getItem("saabi_history") || "[]");

  const messagesEl = document.getElementById("chat-messages");
  const textarea   = document.getElementById("chat-textarea");
  const sendBtn    = document.getElementById("send-btn");

  // Restore previous session or show empty state
  if (conversationHistory.length > 0) {
    conversationHistory.forEach(msg => {
      renderMessage(msg.role, msg.content, msg.meta || {});
    });
    scrollToBottom();
  } else {
    showEmptyState();
  }

  // Auto-resize textarea
  textarea.addEventListener("input", () => {
    textarea.style.height = "auto";
    textarea.style.height = Math.min(textarea.scrollHeight, 140) + "px";
    updateCharCount(textarea.value.length);
  });

  // Send on Enter (Shift+Enter for newline)
  textarea.addEventListener("keydown", (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  });

  sendBtn.addEventListener("click", sendMessage);

  // Clear chat button
  document.getElementById("btn-clear-chat")?.addEventListener("click", clearChat);
}

function updateCharCount(len) {
  const el = document.getElementById("char-count");
  if (el) el.textContent = len > 0 ? `${len} / 500` : "";
}

function showEmptyState() {
  const messagesEl = document.getElementById("chat-messages");
  const name = userProfile?.name || "there";

  messagesEl.innerHTML = `
    <div class="empty-state" id="empty-state">
      <div class="empty-icon">🌿</div>
      <h1 class="empty-title">Hi ${name}, I'm Saabi</h1>
      <p class="empty-subtitle">
        Your personal health companion. Ask me anything about HIV, sexual health,
        mental wellbeing, nutrition, or your rights. I'm here for you.
      </p>
      <div class="quick-starts">
        ${QUICK_STARTS.map(q => `
          <button class="qs-chip" data-q="${encodeURIComponent(q)}">${q}</button>
        `).join("")}
      </div>
    </div>
  `;

  document.querySelectorAll(".qs-chip").forEach(chip => {
    chip.addEventListener("click", () => {
      const question = decodeURIComponent(chip.dataset.q);
      document.getElementById("chat-textarea").value = question;
      sendMessage();
    });
  });
}

async function sendMessage() {
  const textarea = document.getElementById("chat-textarea");
  const message  = textarea.value.trim();
  if (!message) return;

  // Clear input
  textarea.value = "";
  textarea.style.height = "auto";
  updateCharCount(0);
  document.getElementById("send-btn").disabled = true;

  // Remove empty state
  document.getElementById("empty-state")?.remove();

  // Render user message
  renderMessage("user", message, {});
  conversationHistory.push({ role: "user", content: message, meta: {} });

  // Client-side safety pre-check
  if (clientSideCheck(message)) {
    showEscalation("medical_emergency");
    // Still continue to API for the caring response
  }

  // Show typing indicator
  const typingId = showTyping();
  scrollToBottom();

  try {
    const apiKeys = JSON.parse(localStorage.getItem("saabi_api_keys") || "{}");

    const response = await fetch(`${BACKEND_URL}/chat`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        user_id: userProfile?.userId || "anonymous",
        message,
        api_keys: apiKeys,
      }),
    });

    removeTyping(typingId);

    if (!response.ok) {
      throw new Error(`Server error: ${response.status}`);
    }

    const data = await response.json();

    const meta = {
      provider:   data.provider,
      topic:      data.topic_matched,
      citations:  data.citations || [],
      escalated:  data.escalated,
    };

    renderMessage("ai", data.reply, meta);
    conversationHistory.push({ role: "assistant", content: data.reply, meta });
    saveHistory();

    if (data.escalated && data.resource_key) {
      showEscalation(data.resource_key);
    }

  } catch (err) {
    removeTyping(typingId);
    renderError(err.message);
    console.error("Saabi API error:", err);
  } finally {
    document.getElementById("send-btn").disabled = false;
    scrollToBottom();
    textarea.focus();
  }
}

function renderMessage(role, content, meta = {}) {
  const messagesEl = document.getElementById("chat-messages");

  const isAI   = role === "assistant" || role === "ai";
  const avatar  = isAI ? "🌿" : (userProfile?.name?.[0]?.toUpperCase() || "U");
  const time    = new Date().toLocaleTimeString("en-NG", { hour: "2-digit", minute: "2-digit" });

  const providerTag = meta.provider
    ? `<span class="provider-tag ${meta.provider}">${meta.provider}</span>`
    : "";

  const citationsHTML = meta.citations?.length
    ? `<div class="citations">
        ${meta.citations.slice(0, 3).map((url, i) =>
          `<a class="citation-link" href="${url}" target="_blank" rel="noopener">
            📎 Source ${i + 1}
          </a>`
        ).join("")}
       </div>`
    : "";

  const msgEl = document.createElement("div");
  msgEl.className = `message ${isAI ? "ai" : "user"}`;
  msgEl.innerHTML = `
    <div class="message-avatar">${avatar}</div>
    <div class="message-body">
      <div class="message-bubble">${formatContent(content)}</div>
      <div class="message-meta">
        <span>${time}</span>
        ${providerTag}
      </div>
      ${citationsHTML}
    </div>
  `;

  messagesEl.appendChild(msgEl);
}

function formatContent(text) {
  // Basic markdown-like formatting
  return text
    .replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>")
    .replace(/\*(.*?)\*/g, "<em>$1</em>")
    .replace(/\n\n/g, "</p><p>")
    .replace(/\n/g, "<br>")
    .replace(/^/, "<p>")
    .replace(/$/, "</p>");
}

function renderError(msg) {
  const messagesEl = document.getElementById("chat-messages");
  const errEl = document.createElement("div");
  errEl.className = "message ai";
  errEl.innerHTML = `
    <div class="message-avatar">⚠️</div>
    <div class="message-body">
      <div class="message-bubble" style="border-color: var(--danger-border); background: var(--danger-bg);">
        Oops — I couldn't reach the server right now. Please check that the backend is running and try again.<br>
        <small style="color: var(--text-muted); margin-top: 6px; display:block;">${msg}</small>
      </div>
    </div>
  `;
  messagesEl.appendChild(errEl);
}

function showTyping() {
  const messagesEl = document.getElementById("chat-messages");
  const id = "typing-" + Date.now();
  const el = document.createElement("div");
  el.className = "message ai typing-indicator";
  el.id = id;
  el.innerHTML = `
    <div class="message-avatar">🌿</div>
    <div class="typing-bubble">
      <div class="typing-dot"></div>
      <div class="typing-dot"></div>
      <div class="typing-dot"></div>
    </div>
  `;
  messagesEl.appendChild(el);
  return id;
}

function removeTyping(id) {
  document.getElementById(id)?.remove();
}

function scrollToBottom() {
  const el = document.getElementById("chat-messages");
  el.scrollTop = el.scrollHeight;
}

function saveHistory() {
  // Keep last 40 messages in localStorage
  const trimmed = conversationHistory.slice(-40);
  localStorage.setItem("saabi_history", JSON.stringify(trimmed));
}

function clearChat() {
  conversationHistory = [];
  localStorage.removeItem("saabi_history");
  document.getElementById("chat-messages").innerHTML = "";
  showEmptyState();
}
