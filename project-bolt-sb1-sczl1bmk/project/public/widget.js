(function() {
  const SUPABASE_URL = 'https://ncnimbaalexocfcqwlie.supabase.co';

  const workspaceId = document.currentScript.getAttribute('data-workspace-id');
  const theme = document.currentScript.getAttribute('data-theme') || 'blue';
  const position = document.currentScript.getAttribute('data-position') || 'bottom-right';
  const greeting = document.currentScript.getAttribute('data-greeting') || 'Hi! How can we help you today?';

  if (!workspaceId) {
    console.error('FrontDesk AI: Missing data-workspace-id attribute');
    return;
  }

  const themeColors = {
    blue: { primary: '#3b82f6', hover: '#2563eb' },
    green: { primary: '#10b981', hover: '#059669' },
    purple: { primary: '#8b5cf6', hover: '#7c3aed' },
    orange: { primary: '#f97316', hover: '#ea580c' },
  };

  const colors = themeColors[theme] || themeColors.blue;

  const styles = `
    .frontdesk-widget-container {
      position: fixed;
      ${position.includes('right') ? 'right: 20px;' : 'left: 20px;'}
      ${position.includes('bottom') ? 'bottom: 20px;' : 'top: 20px;'}
      z-index: 999999;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
    .frontdesk-widget-button {
      width: 60px;
      height: 60px;
      border-radius: 30px;
      background: ${colors.primary};
      border: none;
      cursor: pointer;
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.3s ease;
    }
    .frontdesk-widget-button:hover {
      background: ${colors.hover};
      transform: scale(1.1);
    }
    .frontdesk-widget-button svg {
      width: 28px;
      height: 28px;
      fill: white;
    }
    .frontdesk-widget-chat {
      position: absolute;
      ${position.includes('right') ? 'right: 0;' : 'left: 0;'}
      ${position.includes('bottom') ? 'bottom: 75px;' : 'top: 75px;'}
      width: 380px;
      max-width: calc(100vw - 40px);
      height: 500px;
      max-height: calc(100vh - 120px);
      background: white;
      border-radius: 12px;
      box-shadow: 0 5px 40px rgba(0,0,0,0.16);
      display: none;
      flex-direction: column;
      overflow: hidden;
    }
    .frontdesk-widget-chat.open {
      display: flex;
    }
    .frontdesk-widget-header {
      background: ${colors.primary};
      color: white;
      padding: 16px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .frontdesk-widget-header h3 {
      margin: 0;
      font-size: 16px;
      font-weight: 600;
    }
    .frontdesk-widget-close {
      background: none;
      border: none;
      color: white;
      cursor: pointer;
      font-size: 24px;
      padding: 0;
      width: 24px;
      height: 24px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .frontdesk-widget-messages {
      flex: 1;
      overflow-y: auto;
      padding: 16px;
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    .frontdesk-widget-message {
      max-width: 80%;
      padding: 10px 14px;
      border-radius: 12px;
      font-size: 14px;
      line-height: 1.4;
    }
    .frontdesk-widget-message.bot {
      background: #f1f5f9;
      color: #1e293b;
      align-self: flex-start;
    }
    .frontdesk-widget-message.user {
      background: ${colors.primary};
      color: white;
      align-self: flex-end;
    }
    .frontdesk-widget-input-container {
      padding: 16px;
      border-top: 1px solid #e2e8f0;
      display: flex;
      gap: 8px;
    }
    .frontdesk-widget-input {
      flex: 1;
      padding: 10px 14px;
      border: 1px solid #e2e8f0;
      border-radius: 20px;
      font-size: 14px;
      outline: none;
    }
    .frontdesk-widget-input:focus {
      border-color: ${colors.primary};
    }
    .frontdesk-widget-send {
      background: ${colors.primary};
      color: white;
      border: none;
      width: 40px;
      height: 40px;
      border-radius: 20px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }
    .frontdesk-widget-send:hover {
      background: ${colors.hover};
    }
    .frontdesk-widget-send:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
  `;

  const styleSheet = document.createElement('style');
  styleSheet.textContent = styles;
  document.head.appendChild(styleSheet);

  const container = document.createElement('div');
  container.className = 'frontdesk-widget-container';
  container.innerHTML = `
    <button class="frontdesk-widget-button" id="frontdesk-open-btn">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z"/>
      </svg>
    </button>
    <div class="frontdesk-widget-chat" id="frontdesk-chat">
      <div class="frontdesk-widget-header">
        <h3>Chat with us</h3>
        <button class="frontdesk-widget-close" id="frontdesk-close-btn">&times;</button>
      </div>
      <div class="frontdesk-widget-messages" id="frontdesk-messages">
        <div class="frontdesk-widget-message bot">${greeting}</div>
      </div>
      <div class="frontdesk-widget-input-container">
        <input type="text" class="frontdesk-widget-input" id="frontdesk-input" placeholder="Type a message..." />
        <button class="frontdesk-widget-send" id="frontdesk-send-btn">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="22" y1="2" x2="11" y2="13"></line>
            <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
          </svg>
        </button>
      </div>
    </div>
  `;

  document.body.appendChild(container);

  const openBtn = document.getElementById('frontdesk-open-btn');
  const closeBtn = document.getElementById('frontdesk-close-btn');
  const chat = document.getElementById('frontdesk-chat');
  const messages = document.getElementById('frontdesk-messages');
  const input = document.getElementById('frontdesk-input');
  const sendBtn = document.getElementById('frontdesk-send-btn');

  let leadId = localStorage.getItem(`frontdesk-lead-${workspaceId}`);
  let isTyping = false;

  openBtn.addEventListener('click', () => {
    chat.classList.add('open');
    input.focus();
  });

  closeBtn.addEventListener('click', () => {
    chat.classList.remove('open');
  });

  function addMessage(text, isUser) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `frontdesk-widget-message ${isUser ? 'user' : 'bot'}`;
    messageDiv.textContent = text;
    messages.appendChild(messageDiv);
    messages.scrollTop = messages.scrollHeight;
  }

  async function sendMessage() {
    const message = input.value.trim();
    if (!message || isTyping) return;

    addMessage(message, true);
    input.value = '';
    isTyping = true;
    sendBtn.disabled = true;

    try {
      const response = await fetch(`${SUPABASE_URL}/functions/v1/ai-chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          workspaceId,
          leadId,
          message,
        }),
      });

      const data = await response.json();

      if (data.leadId) {
        leadId = data.leadId;
        localStorage.setItem(`frontdesk-lead-${workspaceId}`, leadId);
      }

      addMessage(data.response, false);
    } catch (error) {
      console.error('FrontDesk AI Error:', error);
      addMessage("Sorry, I'm having trouble connecting. Please try again!", false);
    } finally {
      isTyping = false;
      sendBtn.disabled = false;
    }
  }

  sendBtn.addEventListener('click', sendMessage);

  input.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
      sendMessage();
    }
  });
})();
