/**
 * onboarding.js — Saabi AI
 * 3-step wizard that collects a user profile on first launch.
 * Saves to localStorage and generates a persistent user UUID.
 */

import { startApp } from "./app.js";

let currentStep = 1;
const TOTAL_STEPS = 3;

const selections = {
  name: "",
  age: "",
  goals: [],
  preference: "friendly",
};

export function initOnboarding() {
  renderStep(1);
}

function renderStep(step) {
  currentStep = step;
  updateDots(step);

  const container = document.getElementById("onboarding-step-content");

  const steps = {
    1: renderStep1,
    2: renderStep2,
    3: renderStep3,
  };

  container.innerHTML = "";
  container.style.opacity = "0";
  container.style.transform = "translateY(8px)";

  steps[step]?.();

  requestAnimationFrame(() => {
    container.style.transition = "opacity 0.3s ease, transform 0.3s ease";
    container.style.opacity = "1";
    container.style.transform = "translateY(0)";
  });
}

function updateDots(active) {
  document.querySelectorAll(".step-dot").forEach((dot, i) => {
    dot.classList.remove("active", "done");
    if (i + 1 === active) dot.classList.add("active");
    else if (i + 1 < active) dot.classList.add("done");
  });
}

function renderStep1() {
  document.getElementById("onboarding-step-content").innerHTML = `
    <div class="step-title">Welcome to Saabi 👋</div>
    <div class="step-subtitle">Your personal health companion. Let's set things up so I can help you better.</div>
    <div class="form-group">
      <label class="form-label" for="input-name">What should I call you?</label>
      <input class="form-input" type="text" id="input-name" placeholder="Your name or nickname"
        value="${selections.name}" maxlength="40" autocomplete="given-name" />
    </div>
    <div class="form-group">
      <label class="form-label" for="input-age">Your age (optional)</label>
      <input class="form-input" type="number" id="input-age" placeholder="e.g. 24"
        value="${selections.age}" min="10" max="100" />
    </div>
    <button class="btn-primary" id="step1-next">Continue →</button>
    <button class="btn-skip" id="step1-skip">Skip setup, just start chatting</button>
  `;

  document.getElementById("step1-next").addEventListener("click", () => {
    selections.name = document.getElementById("input-name").value.trim();
    selections.age  = document.getElementById("input-age").value.trim();
    renderStep(2);
  });

  document.getElementById("step1-skip").addEventListener("click", finishOnboarding);
  document.getElementById("input-name").addEventListener("keydown", (e) => {
    if (e.key === "Enter") document.getElementById("step1-next").click();
  });
}

function renderStep2() {
  const GOALS = [
    { id: "hiv",      emoji: "🔴", label: "HIV & ART"       },
    { id: "srhr",     emoji: "💚", label: "Sexual Health"   },
    { id: "mental",   emoji: "🧠", label: "Mental Health"   },
    { id: "nutrition",emoji: "🥗", label: "Nutrition"       },
    { id: "stigma",   emoji: "🤝", label: "Rights & Stigma" },
    { id: "general",  emoji: "❤️", label: "General Health"  },
  ];

  document.getElementById("onboarding-step-content").innerHTML = `
    <div class="step-title">What matters to you?</div>
    <div class="step-subtitle">Pick the health topics you want to explore. You can always change this later.</div>
    <div class="chip-grid">
      ${GOALS.map(g => `
        <button class="chip ${selections.goals.includes(g.id) ? "selected" : ""}"
          data-goal="${g.id}" id="goal-${g.id}">
          <span>${g.emoji}</span> ${g.label}
        </button>
      `).join("")}
    </div>
    <button class="btn-primary" id="step2-next">Continue →</button>
    <button class="btn-skip" id="step2-back">← Back</button>
  `;

  document.querySelectorAll(".chip[data-goal]").forEach(btn => {
    btn.addEventListener("click", () => {
      const goal = btn.dataset.goal;
      if (selections.goals.includes(goal)) {
        selections.goals = selections.goals.filter(g => g !== goal);
        btn.classList.remove("selected");
      } else {
        selections.goals.push(goal);
        btn.classList.add("selected");
      }
    });
  });

  document.getElementById("step2-next").addEventListener("click", () => renderStep(3));
  document.getElementById("step2-back").addEventListener("click", () => renderStep(1));
}

function renderStep3() {
  const PREFS = [
    {
      id: "simple",
      label: "Keep it simple",
      desc: "Plain language, no jargon — explain everything clearly",
    },
    {
      id: "friendly",
      label: "Friendly & conversational",
      desc: "Warm, supportive tone with some depth",
    },
    {
      id: "detailed",
      label: "Give me the details",
      desc: "I want thorough explanations with context",
    },
  ];

  document.getElementById("onboarding-step-content").innerHTML = `
    <div class="step-title">How do you like your information?</div>
    <div class="step-subtitle">Saabi will tailor its responses to match your preference.</div>
    <div class="pref-grid">
      ${PREFS.map(p => `
        <button class="pref-btn ${selections.preference === p.id ? "selected" : ""}"
          data-pref="${p.id}" id="pref-${p.id}">
          <span class="pref-label">${p.label}</span>
          <span class="pref-desc">${p.desc}</span>
        </button>
      `).join("")}
    </div>
    <button class="btn-primary" id="step3-finish">Start chatting with Saabi 🌿</button>
    <button class="btn-skip" id="step3-back">← Back</button>
  `;

  document.querySelectorAll(".pref-btn[data-pref]").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".pref-btn").forEach(b => b.classList.remove("selected"));
      btn.classList.add("selected");
      selections.preference = btn.dataset.pref;
    });
  });

  document.getElementById("step3-finish").addEventListener("click", finishOnboarding);
  document.getElementById("step3-back").addEventListener("click", () => renderStep(2));
}

function finishOnboarding() {
  // Generate a persistent UUID for this user
  const userId = crypto.randomUUID();

  const profile = {
    userId,
    name:       selections.name  || "Friend",
    age:        selections.age   || null,
    goals:      selections.goals,
    preference: selections.preference,
    createdAt:  new Date().toISOString(),
  };

  localStorage.setItem("saabi_user", JSON.stringify(profile));
  localStorage.setItem("saabi_setup_done", "true");

  startApp(profile);
}
