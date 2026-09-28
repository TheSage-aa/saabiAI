/**
 * escalation.js — Saabi AI
 * Manages the escalation panel shown when the backend returns escalated: true,
 * or when a client-side keyword pre-check fires before the API call.
 *
 * Nigeria-specific emergency contacts by resource_key.
 */

const CONTACTS = {
  mental_health_crisis: {
    title: "You're not alone — reach out now",
    subtitle: "Mental health support is available to you",
    icon: "💙",
    contacts: [
      { emoji: "📞", name: "MANI Helpline", detail: "08091116264 — free, confidential", href: "tel:08091116264" },
      { emoji: "💬", name: "Mentally Aware Nigeria", detail: "mentally-aware.org — chat & resources", href: "https://mentally-aware.org" },
      { emoji: "🏥", name: "Nearest Mental Health Facility", detail: "Find a clinic near you", href: "https://www.google.com/maps/search/mental+health+clinic+near+me" },
    ],
  },
  medical_emergency: {
    title: "This sounds like an emergency",
    subtitle: "Please get help immediately — don't wait",
    icon: "🚨",
    contacts: [
      { emoji: "📞", name: "Emergency Services", detail: "Call 112 — Nigeria Emergency", href: "tel:112" },
      { emoji: "📞", name: "Lagos LASEMA", detail: "Call 767 — Lagos State Emergency", href: "tel:767" },
      { emoji: "🏥", name: "Nearest Emergency Room", detail: "Find the closest hospital ER", href: "https://www.google.com/maps/search/emergency+hospital+near+me" },
    ],
  },
  abuse_support: {
    title: "You deserve to be safe",
    subtitle: "Confidential support is available right now",
    icon: "🤝",
    contacts: [
      { emoji: "📞", name: "NAPTIP Hotline", detail: "0800-627847-1 — free, 24/7", href: "tel:08006278471" },
      { emoji: "📞", name: "Project Alert GBV", detail: "08052001111 — gender-based violence", href: "tel:08052001111" },
      { emoji: "🌐", name: "WARIF Support", detail: "warif.org — confidential rape & trauma", href: "https://warif.org" },
    ],
  },
  hiv_crisis: {
    title: "Your medication matters",
    subtitle: "Let's get you back on track quickly",
    icon: "💊",
    contacts: [
      { emoji: "📞", name: "NACA Helpline", detail: "0800-235-6682 — free ART support", href: "tel:08002356682" },
      { emoji: "🏥", name: "Nearest ART Clinic", detail: "Find a PEPFAR-supported site", href: "https://www.google.com/maps/search/ART+HIV+clinic+Nigeria" },
      { emoji: "🌐", name: "NACA Nigeria", detail: "naca.gov.ng — resources & facilities", href: "https://naca.gov.ng" },
    ],
  },
};

// Client-side keyword pre-check — fires before the API call
const EMERGENCY_KEYWORDS = [
  "kill myself", "want to die", "end my life", "suicidal", "suicide",
  "can't breathe", "cannot breathe", "chest pain", "heart attack",
  "seizure", "fitting", "overdose", "unconscious",
  "being raped", "was raped", "sexual assault", "he beats me",
  "ran out of arv", "stopped taking art", "need pep",
];

export function clientSideCheck(message) {
  const lower = message.toLowerCase();
  for (const kw of EMERGENCY_KEYWORDS) {
    if (lower.includes(kw)) return true;
  }
  return false;
}

export function showEscalation(resourceKey) {
  const data = CONTACTS[resourceKey] || CONTACTS["medical_emergency"];

  const overlay = document.createElement("div");
  overlay.className = "escalation-overlay";
  overlay.id = "escalation-overlay";

  overlay.innerHTML = `
    <div class="escalation-panel" role="dialog" aria-modal="true" aria-label="Emergency Support">
      <div class="escalation-header">
        <div class="escalation-icon-wrap">
          <div class="escalation-icon">${data.icon}</div>
          <div class="escalation-title-block">
            <div class="escalation-title">${data.title}</div>
            <div class="escalation-subtitle">${data.subtitle}</div>
          </div>
        </div>
        <button class="escalation-close" id="esc-close-btn" aria-label="Close">✕</button>
      </div>
      <div class="escalation-contacts">
        ${data.contacts.map(c => `
          <a class="contact-card" href="${c.href}" target="_blank" rel="noopener noreferrer">
            <div class="contact-info">
              <span class="contact-emoji">${c.emoji}</span>
              <div>
                <span class="contact-name">${c.name}</span>
                <span class="contact-detail">${c.detail}</span>
              </div>
            </div>
            <span class="contact-arrow">→</span>
          </a>
        `).join("")}
      </div>
      <p class="escalation-note">
        Saabi AI is here to support you, but some situations need a real human expert.<br>
        The contacts above are confidential and available to help you right now.
      </p>
    </div>
  `;

  document.body.appendChild(overlay);

  document.getElementById("esc-close-btn").addEventListener("click", hideEscalation);
  overlay.addEventListener("click", (e) => {
    if (e.target === overlay) hideEscalation();
  });
}

export function hideEscalation() {
  const overlay = document.getElementById("escalation-overlay");
  if (overlay) overlay.remove();
}
