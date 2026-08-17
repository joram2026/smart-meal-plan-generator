/**
 * Smart Lishe - Unified Support, Broadcast, and Notifications Engine
 */
(function() {
  // Helper to fetch token
  function getAuthToken() {
    return localStorage.getItem('smartlishe_token') || localStorage.getItem('token') || '';
  }

  // Toast Helper
  function toast(msg, type = 'success') {
    if (window.showToast) {
      window.showToast(msg, type);
    } else {
      alert(msg);
    }
  }

  // API Fetch Wrapper
  async function api(endpoint, options = {}) {
    const token = getAuthToken();
    const headers = {
      'Content-Type': 'application/json',
      ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
      ...(options.headers || {})
    };
    try {
      const res = await fetch(endpoint, { ...options, headers });
      const data = await res.json();
      return data;
    } catch (e) {
      console.error('API Error:', e);
      return { success: false, message: e.message };
    }
  }

  // Inject CSS Styles for Support Modal, Broadcast Banner, and Notification Panel
  function injectStyles() {
    if (document.getElementById('smartlishe-support-styles')) return;
    const style = document.createElement('style');
    style.id = 'smartlishe-support-styles';
    style.textContent = `
      /* Broadcast Banner */
      .sl-broadcast-banner {
        background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
        color: #ffffff;
        padding: 14px 20px;
        border-radius: 12px;
        margin: 16px 0 24px 0;
        display: flex;
        align-items: center;
        gap: 14px;
        box-shadow: 0 4px 14px rgba(37, 99, 235, 0.25);
        position: relative;
        animation: slSlideDown 0.3s cubic-bezier(0.16, 1, 0.3, 1);
      }
      .sl-broadcast-banner.warning {
        background: linear-gradient(135deg, #d97706 0%, #b45309 100%);
        box-shadow: 0 4px 14px rgba(217, 119, 6, 0.25);
      }
      .sl-broadcast-banner.emergency {
        background: linear-gradient(135deg, #dc2626 0%, #991b1b 100%);
        box-shadow: 0 4px 14px rgba(220, 38, 38, 0.25);
      }
      .sl-broadcast-banner .bc-icon {
        font-size: 1.5rem;
        background: rgba(255, 255, 255, 0.2);
        width: 42px;
        height: 42px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
      }
      .sl-broadcast-banner .bc-body { flex: 1; }
      .sl-broadcast-banner .bc-title { font-weight: 700; font-size: 0.95rem; margin-bottom: 2px; }
      .sl-broadcast-banner .bc-text { font-size: 0.85rem; opacity: 0.95; line-height: 1.4; }
      .sl-broadcast-banner .bc-close {
        background: transparent;
        border: none;
        color: rgba(255, 255, 255, 0.8);
        cursor: pointer;
        font-size: 1.1rem;
        padding: 6px;
        border-radius: 50%;
        transition: color 0.2s, background 0.2s;
      }
      .sl-broadcast-banner .bc-close:hover { color: #fff; background: rgba(255, 255, 255, 0.2); }

      /* Modals Overlay */
      .sl-modal-overlay {
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        background: rgba(15, 23, 42, 0.65);
        backdrop-filter: blur(4px);
        z-index: 99999;
        display: none;
        align-items: center;
        justify-content: center;
        padding: 16px;
        animation: slFadeIn 0.2s ease-out;
      }
      .sl-modal-overlay.active { display: flex; }

      .sl-modal-card {
        background: var(--bg-card, #ffffff);
        color: var(--text-primary, #1e293b);
        border-radius: 18px;
        width: 100%;
        max-width: 680px;
        max-height: 90vh;
        display: flex;
        flex-direction: column;
        box-shadow: 0 20px 50px rgba(0,0,0,0.25);
        overflow: hidden;
        border: 1px solid var(--basket-line, #e2e8f0);
      }

      .sl-modal-header {
        padding: 20px 24px;
        background: var(--bg-elevated, #f8fafc);
        border-bottom: 1px solid var(--basket-line, #e2e8f0);
        display: flex;
        align-items: center;
        justify-content: space-between;
      }
      .sl-modal-header h3 {
        margin: 0;
        font-size: 1.2rem;
        font-weight: 700;
        display: flex;
        align-items: center;
        gap: 10px;
        color: var(--text-primary, #0f172a);
      }
      .sl-modal-header .sl-close-btn {
        background: none; border: none; font-size: 1.2rem;
        color: var(--text-secondary, #64748b); cursor: pointer;
        padding: 6px; border-radius: 50%; transition: background 0.2s;
      }
      .sl-modal-header .sl-close-btn:hover { background: rgba(0,0,0,0.06); color: #0f172a; }

      .sl-modal-tabs {
        display: flex;
        border-bottom: 1px solid var(--basket-line, #e2e8f0);
        background: var(--bg-elevated, #f8fafc);
        padding: 0 24px;
      }
      .sl-tab-btn {
        padding: 12px 18px;
        background: none; border: none;
        border-bottom: 3px solid transparent;
        font-weight: 600; font-size: 0.9rem;
        color: var(--text-secondary, #64748b);
        cursor: pointer; transition: all 0.2s;
        display: flex; align-items: center; gap: 8px;
      }
      .sl-tab-btn:hover { color: var(--sukuma, #259e82); }
      .sl-tab-btn.active {
        color: var(--sukuma, #259e82);
        border-bottom-color: var(--sukuma, #259e82);
      }

      .sl-modal-body {
        padding: 24px;
        overflow-y: auto;
        flex: 1;
      }

      /* Forms in Modal */
      .sl-form-group { margin-bottom: 18px; }
      .sl-form-group label {
        display: block; font-weight: 600; font-size: 0.88rem;
        margin-bottom: 6px; color: var(--text-primary, #334155);
      }
      .sl-form-control {
        width: 100%; padding: 10px 14px;
        border: 1px solid var(--basket-line, #cbd5e1);
        border-radius: 8px;
        background: var(--bg-elevated, #ffffff);
        color: var(--text-primary, #0f172a);
        font-size: 0.9rem; font-family: inherit;
        transition: border-color 0.2s, box-shadow 0.2s;
      }
      .sl-form-control:focus {
        outline: none; border-color: var(--sukuma, #259e82);
        box-shadow: 0 0 0 3px rgba(37, 158, 130, 0.15);
      }
      .sl-form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }

      /* Submit Button */
      .sl-btn-primary {
        background: var(--sukuma, #259e82);
        color: #ffffff;
        border: none;
        padding: 12px 24px;
        border-radius: 10px;
        font-weight: 700;
        font-size: 0.95rem;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        transition: background 0.2s, transform 0.1s;
        width: 100%;
      }
      .sl-btn-primary:hover { background: #1f856d; transform: translateY(-1px); }

      /* Ticket List Styles */
      .sl-ticket-card {
        border: 1px solid var(--basket-line, #e2e8f0);
        border-radius: 12px;
        padding: 16px;
        margin-bottom: 14px;
        background: var(--bg-elevated, #f8fafc);
        transition: border-color 0.2s;
      }
      .sl-ticket-card:hover { border-color: var(--sukuma, #259e82); }
      .sl-ticket-header {
        display: flex; align-items: center; justify-content: space-between;
        margin-bottom: 8px; flex-wrap: wrap; gap: 8px;
      }
      .sl-ticket-title { font-weight: 700; font-size: 0.98rem; color: var(--text-primary, #0f172a); }
      .sl-badge {
        font-size: 0.75rem; font-weight: 700; padding: 4px 10px;
        border-radius: 20px; text-transform: uppercase; letter-spacing: 0.5px;
      }
      .sl-badge.open { background: #dbeafe; color: #1e40af; }
      .sl-badge.pending { background: #fef3c7; color: #92400e; }
      .sl-badge.resolved { background: #d1fae5; color: #065f46; }

      .sl-ticket-meta { font-size: 0.8rem; color: var(--text-secondary, #64748b); margin-bottom: 10px; }
      .sl-ticket-msg { font-size: 0.9rem; color: var(--text-primary, #334155); line-height: 1.5; white-space: pre-line; }

      /* Admin Replies thread inside ticket */
      .sl-replies-box {
        margin-top: 14px; padding-top: 14px;
        border-top: 1px dashed var(--basket-line, #cbd5e1);
      }
      .sl-reply-bubble {
        background: #f0fdf4; border-left: 3px solid var(--sukuma, #259e82);
        padding: 10px 14px; border-radius: 8px; margin-top: 8px;
      }
      .sl-reply-meta { font-weight: 700; font-size: 0.78rem; color: #166534; margin-bottom: 4px; display: flex; justify-content: space-between; }
      .sl-reply-text { font-size: 0.88rem; color: #14532d; }

      /* Notification Dropdown / Panel */
      .sl-notif-panel {
        position: absolute; top: 100%; right: 0; margin-top: 8px;
        width: 360px; max-width: 90vw;
        background: var(--bg-card, #ffffff);
        border: 1px solid var(--basket-line, #e2e8f0);
        border-radius: 14px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.18);
        z-index: 9999; display: none;
        overflow: hidden; animation: slSlideDown 0.2s ease-out;
      }
      .sl-notif-panel.active { display: block; }
      .sl-notif-header {
        padding: 14px 18px; background: var(--bg-elevated, #f8fafc);
        border-bottom: 1px solid var(--basket-line, #e2e8f0);
        display: flex; align-items: center; justify-content: space-between;
      }
      .sl-notif-header h4 { margin: 0; font-size: 0.95rem; font-weight: 700; }
      .sl-notif-list { max-height: 340px; overflow-y: auto; }
      .sl-notif-item {
        padding: 12px 16px; border-bottom: 1px solid var(--basket-line, #f1f5f9);
        display: flex; gap: 12px; align-items: flex-start; transition: background 0.2s;
      }
      .sl-notif-item:hover { background: var(--bg-elevated, #f8fafc); }
      .sl-notif-item.unread { background: rgba(37, 158, 130, 0.06); }
      .sl-notif-icon {
        width: 32px; height: 32px; border-radius: 50%;
        background: var(--sukuma, #259e82); color: #fff;
        display: flex; align-items: center; justify-content: center;
        font-size: 0.85rem; flex-shrink: 0; margin-top: 2px;
      }
      .sl-notif-text { flex: 1; font-size: 0.84rem; line-height: 1.4; }
      .sl-notif-text strong { display: block; font-size: 0.88rem; color: var(--text-primary, #0f172a); margin-bottom: 2px; }
      .sl-notif-time { font-size: 0.72rem; color: var(--text-secondary, #94a3b8); margin-top: 4px; }
      .sl-notif-footer {
        padding: 10px 16px; background: var(--bg-elevated, #f8fafc);
        border-top: 1px solid var(--basket-line, #e2e8f0); text-align: center;
      }
      .sl-btn-link { background: none; border: none; color: var(--sukuma, #259e82); font-weight: 600; font-size: 0.82rem; cursor: pointer; }

      @keyframes slSlideDown { from { opacity: 0; transform: translateY(-8px); } to { opacity: 1; transform: translateY(0); } }
      @keyframes slFadeIn { from { opacity: 0; } to { opacity: 1; } }
    `;
    document.head.appendChild(style);
  }

  // Inject Support Center Modal into DOM
  function injectSupportModal() {
    if (document.getElementById('slSupportModal')) return;
    const modalHtml = `
      <div class="sl-modal-overlay" id="slSupportModal">
        <div class="sl-modal-card">
          <div class="sl-modal-header">
            <h3><i class="fa-solid fa-headset" style="color:var(--sukuma, #259e82);"></i> Smart Lishe Support Center</h3>
            <button class="sl-close-btn" id="slCloseSupportModal"><i class="fa-solid fa-xmark"></i></button>
          </div>
          <div class="sl-modal-tabs">
            <button class="sl-tab-btn active" id="slTabSubmit"><i class="fa-solid fa-paper-plane"></i> Submit Ticket</button>
            <button class="sl-tab-btn" id="slTabList"><i class="fa-solid fa-list-check"></i> My Support Tickets (<span id="slTicketCount">0</span>)</button>
          </div>
          <div class="sl-modal-body">
            <!-- Submit Form View -->
            <div id="slViewSubmit">
              <form id="slSupportForm">
                <div class="sl-form-row">
                  <div class="sl-form-group">
                    <label for="slCategory">Issue Category</label>
                    <select id="slCategory" class="sl-form-control">
                      <option value="General Support">General Help & Inquiries</option>
                      <option value="Billing & Payments">Billing, M-Pesa STK & Subscriptions</option>
                      <option value="Technical / AI">NutriScan AI & Meal Planner Issues</option>
                      <option value="Account Verification">Nutritionist License Verification</option>
                      <option value="Dietitian Consultation">Professional Consultations</option>
                    </select>
                  </div>
                  <div class="sl-form-group">
                    <label for="slPriority">Priority Level</label>
                    <select id="slPriority" class="sl-form-control">
                      <option value="normal">Normal Priority</option>
                      <option value="high">High Priority</option>
                      <option value="urgent">Urgent</option>
                    </select>
                  </div>
                </div>

                <div class="sl-form-group">
                  <label for="slSubject">Subject / Issue Summary</label>
                  <input type="text" id="slSubject" class="sl-form-control" placeholder="Briefly describe your question or issue..." required>
                </div>

                <div class="sl-form-group">
                  <label for="slMessage">Detailed Description</label>
                  <textarea id="slMessage" class="sl-form-control" rows="4" placeholder="Provide full details so our admin support team can assist you effectively..." required></textarea>
                </div>

                <button type="submit" class="sl-btn-primary">
                  <i class="fa-solid fa-paper-plane"></i> Submit Support Request
                </button>
              </form>
            </div>

            <!-- List View -->
            <div id="slViewList" style="display:none;">
              <div id="slTicketsContainer">
                <p style="text-align:center; color:var(--text-secondary,#64748b); padding:20px 0;">Loading your support tickets...</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    `;
    document.body.insertAdjacentHTML('beforeend', modalHtml);

    // Bind Modal Controls
    const modal = document.getElementById('slSupportModal');
    document.getElementById('slCloseSupportModal').onclick = () => modal.classList.remove('active');
    modal.onclick = (e) => { if (e.target === modal) modal.classList.remove('active'); };

    // Bind Tabs
    const tabSubmit = document.getElementById('slTabSubmit');
    const tabList = document.getElementById('slTabList');
    const viewSubmit = document.getElementById('slViewSubmit');
    const viewList = document.getElementById('slViewList');

    tabSubmit.onclick = () => {
      tabSubmit.classList.add('active'); tabList.classList.remove('active');
      viewSubmit.style.display = 'block'; viewList.style.display = 'none';
    };

    tabList.onclick = () => {
      tabList.classList.add('active'); tabSubmit.classList.remove('active');
      viewSubmit.style.display = 'none'; viewList.style.display = 'block';
      loadUserTickets();
    };

    // Form submission
    document.getElementById('slSupportForm').onsubmit = async (e) => {
      e.preventDefault();
      const subject = document.getElementById('slSubject').value.trim();
      const category = document.getElementById('slCategory').value;
      const priority = document.getElementById('slPriority').value;
      const message = document.getElementById('slMessage').value.trim();

      if (!subject || !message) {
        toast('Please fill out both subject and message', 'error');
        return;
      }

      const res = await api('/api/support', {
        method: 'POST',
        body: JSON.stringify({ subject, category, priority, message })
      });

      if (res.success || res.status === 201 || res.data) {
        toast('Support ticket submitted! Our team will respond shortly.');
        document.getElementById('slSupportForm').reset();
        tabList.click(); // switch to ticket list view
        loadNotifications();
      } else {
        toast(res.message || 'Failed to submit ticket', 'error');
      }
    };
  }

  // Load User Tickets in Modal
  async function loadUserTickets() {
    const container = document.getElementById('slTicketsContainer');
    if (!container) return;
    container.innerHTML = '<p style="text-align:center; color:var(--text-secondary,#64748b); padding:20px 0;"><i class="fa-solid fa-spinner fa-spin"></i> Fetching tickets...</p>';

    const res = await api('/api/support');
    const tickets = res.data || [];

    document.getElementById('slTicketCount').textContent = tickets.length;

    if (!tickets.length) {
      container.innerHTML = `
        <div style="text-align:center; padding:30px 20px; color:var(--text-secondary,#64748b);">
          <i class="fa-solid fa-folder-open" style="font-size:2rem; margin-bottom:10px; color:var(--sukuma,#259e82);"></i>
          <p>You have not submitted any support tickets yet.</p>
        </div>
      `;
      return;
    }

    container.innerHTML = tickets.map(t => {
      const statusClass = (t.status || 'open').toLowerCase();
      const createdDate = t.created_at ? new Date(t.created_at).toLocaleString() : 'Recently';

      let repliesHtml = '';
      if (t.replies && t.replies.length > 0) {
        repliesHtml = `
          <div class="sl-replies-box">
            <strong style="font-size:0.82rem; color:var(--text-secondary,#64748b);">Admin Responses (${t.replies.length}):</strong>
            ${t.replies.map(r => `
              <div class="sl-reply-bubble">
                <div class="sl-reply-meta">
                  <span><i class="fa-solid fa-user-shield"></i> ${r.sender || 'Admin Support'}</span>
                  <span>${r.time ? new Date(r.time).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}) : ''}</span>
                </div>
                <div class="sl-reply-text">${r.message}</div>
              </div>
            `).join('')}
          </div>
        `;
      }

      return `
        <div class="sl-ticket-card">
          <div class="sl-ticket-header">
            <div class="sl-ticket-title">${t.subject}</div>
            <span class="sl-badge ${statusClass}">${t.status || 'Open'}</span>
          </div>
          <div class="sl-ticket-meta">
            <span><strong>Category:</strong> ${t.category || 'General'}</span> · 
            <span><strong>Priority:</strong> ${(t.priority || 'normal').toUpperCase()}</span> · 
            <span>${createdDate}</span>
          </div>
          <div class="sl-ticket-msg">${t.message}</div>
          ${repliesHtml}
        </div>
      `;
    }).join('');
  }

  // Inject Notifications Dropdown / Panel
  function setupNotifications() {
    const notifBtn = document.getElementById('notifBtn') || document.getElementById('notificationBtn');
    if (!notifBtn) return;

    // Remove existing dropdown if any or bind
    let notifPanel = document.getElementById('slNotifPanel');
    if (!notifPanel) {
      notifPanel = document.createElement('div');
      notifPanel.id = 'slNotifPanel';
      notifPanel.className = 'sl-notif-panel';
      notifPanel.innerHTML = `
        <div class="sl-notif-header">
          <h4><i class="fa-solid fa-bell" style="color:var(--sukuma, #259e82);"></i> Notifications</h4>
          <button class="sl-btn-link" id="slClearNotifsBtn">Clear All</button>
        </div>
        <div class="sl-notif-list" id="slNotifList">
          <p style="text-align:center; padding:16px; font-size:0.85rem; color:var(--text-secondary,#64748b);">Loading notifications...</p>
        </div>
      `;
      // Position relative to parent or topbar
      if (notifBtn.parentElement) {
        notifBtn.parentElement.style.position = 'relative';
        notifBtn.parentElement.appendChild(notifPanel);
      } else {
        document.body.appendChild(notifPanel);
      }
    }

    // Toggle dropdown
    notifBtn.onclick = (e) => {
      e.stopPropagation();
      notifPanel.classList.toggle('active');
      if (notifPanel.classList.contains('active')) {
        loadNotifications();
      }
    };

    document.addEventListener('click', (e) => {
      if (!notifPanel.contains(e.target) && !notifBtn.contains(e.target)) {
        notifPanel.classList.remove('active');
      }
    });

    document.getElementById('slClearNotifsBtn').onclick = async () => {
      await api('/api/notifications/clear', { method: 'POST' });
      toast('Cleared all notifications');
      loadNotifications();
    };

    // Initial load
    loadNotifications();
  }

  // Load notifications from server
  async function loadNotifications() {
    const listEl = document.getElementById('slNotifList');
    const notifBtn = document.getElementById('notifBtn') || document.getElementById('notificationBtn');
    if (!listEl) return;

    const res = await api('/api/notifications');
    const notifs = res.data || [];

    const unreadCount = notifs.filter(n => !n.is_read).length;

    // Update Badge
    let badge = document.getElementById('notificationBadge') || notifBtn?.querySelector('.badge-count') || notifBtn?.querySelector('.dot');
    if (badge) {
      if (badge.classList.contains('dot')) {
        badge.style.display = unreadCount > 0 ? 'inline-block' : 'none';
      } else {
        badge.textContent = unreadCount;
        badge.style.display = unreadCount > 0 ? 'inline-block' : 'none';
      }
    }

    if (!notifs.length) {
      listEl.innerHTML = '<p style="text-align:center; padding:20px; font-size:0.85rem; color:var(--text-secondary,#64748b);">No notifications</p>';
      return;
    }

    listEl.innerHTML = notifs.map(n => {
      const icon = n.type === 'pro_invite' ? 'fa-user-doctor' : 
                   n.type === 'pro_message' ? 'fa-comment-dots' : 
                   n.type === 'pro_plan' ? 'fa-utensils' : 
                   n.type === 'pro_appointment' ? 'fa-calendar-check' : 
                   n.type === 'invite_accepted' ? 'fa-user-check' : 
                   n.type === 'invite_declined' ? 'fa-user-xmark' : 
                   n.type === 'broadcast' ? 'fa-bullhorn' : 
                   n.type === 'support_reply' ? 'fa-headset' : 'fa-bell';
      const timeStr = n.created_at ? new Date(n.created_at).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}) : '';

      if (n.type === 'pro_invite') {
        const isPending = !n.status || n.status === 'pending';
        return `
          <div class="sl-notif-item ${n.is_read ? '' : 'unread'}" style="flex-direction:column; align-items:flex-start; gap:10px; background: rgba(37,158,130,0.06); border: 1px solid rgba(37,158,130,0.25);">
            <div style="display:flex; gap:10px; align-items:flex-start; width:100%;">
              <div class="sl-notif-icon" style="background:rgba(37,158,130,0.18); color:var(--sukuma,#259e82);"><i class="fa-solid fa-user-doctor"></i></div>
              <div class="sl-notif-text" style="flex:1;">
                <strong style="color:var(--text-primary,#0f172a); font-size:0.88rem;">${n.title}</strong>
                <div style="margin-top:2px; font-size:0.8rem; color:var(--text-secondary,#475569); line-height:1.4;">${n.message}</div>
                <div class="sl-notif-time">${timeStr}</div>
              </div>
            </div>
            ${isPending ? `
              <div class="sl-invite-actions" style="display:flex; gap:8px; width:100%; margin-top:2px;">
                <button onclick="window.respondToProInvite('${n.id}', 'accept', event)" style="flex:1; padding:7px 12px; background:var(--sukuma,#259e82); color:#fff; border:none; border-radius:6px; font-weight:700; font-size:0.75rem; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:6px; transition:all 0.2s;"><i class="fa-solid fa-check"></i> Accept Invite</button>
                <button onclick="window.respondToProInvite('${n.id}', 'decline', event)" style="flex:1; padding:7px 12px; background:rgba(220,38,38,0.1); color:#dc2626; border:1px solid rgba(220,38,38,0.3); border-radius:6px; font-weight:700; font-size:0.75rem; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:6px; transition:all 0.2s;"><i class="fa-solid fa-xmark"></i> Decline</button>
              </div>
            ` : `
              <div style="font-size:0.78rem; font-weight:700; color:${n.status === 'accepted' ? 'var(--sukuma,#259e82)' : '#dc2626'}; display:flex; align-items:center; gap:6px; margin-top:2px;">
                <i class="fa-solid ${n.status === 'accepted' ? 'fa-circle-check' : 'fa-circle-xmark'}"></i>
                ${n.status === 'accepted' ? 'Joined & Connected to Professional' : 'Invitation Declined'}
              </div>
            `}
          </div>
        `;
      }

      const isProMsg = ['pro_message', 'pro_plan', 'pro_appointment'].includes(n.type);

      return `
        <div class="sl-notif-item ${n.is_read ? '' : 'unread'}" style="${isProMsg ? 'background:rgba(37,158,130,0.04); border-left:3px solid var(--sukuma,#259e82);' : ''}">
          <div class="sl-notif-icon" style="${isProMsg ? 'background:rgba(37,158,130,0.15); color:var(--sukuma,#259e82);' : ''}"><i class="fa-solid ${icon}"></i></div>
          <div class="sl-notif-text">
            <strong>${n.title}</strong>
            <div style="margin-top:2px; font-size:0.8rem;">${n.message}</div>
            <div class="sl-notif-time">${timeStr}</div>
          </div>
        </div>
      `;
    }).join('');
  }

  window.respondToProInvite = async function(notifId, action, event) {
    if (event) event.stopPropagation();
    try {
      const res = await api(`/api/user/invitations/${notifId}/respond`, {
        method: 'POST',
        body: JSON.stringify({ action })
      });
      toast(res.message || (action === 'accept' ? 'Invitation accepted!' : 'Invitation declined.'));
      loadNotifications();
    } catch (e) {
      toast('Failed to respond to invitation: ' + e.message);
    }
  };

  // Load and Render System Broadcast Banner
  async function setupBroadcastBanner() {
    const res = await api('/api/broadcast');
    const bc = res.data?.current || (res.data?.all && res.data.all[0]);
    if (!bc) return;

    // Check if dismissed in session
    if (sessionStorage.getItem(`dismiss_bc_${bc.id}`)) return;

    // Target container: inside dashboard content or body
    let container = document.querySelector('.dash-welcome') || document.querySelector('.page-inner') || document.querySelector('.main-content');
    if (!container) return;

    if (document.getElementById('slSystemBroadcastBanner')) return;

    const bannerTypeClass = bc.type || 'info';
    const bannerHtml = `
      <div class="sl-broadcast-banner ${bannerTypeClass}" id="slSystemBroadcastBanner">
        <div class="bc-icon"><i class="fa-solid fa-bullhorn"></i></div>
        <div class="bc-body">
          <div class="bc-title">📢 ${bc.title}</div>
          <div class="bc-text">${bc.message}</div>
        </div>
        <button class="bc-close" id="slCloseBcBtn" title="Dismiss Notice"><i class="fa-solid fa-xmark"></i></button>
      </div>
    `;

    container.insertAdjacentHTML('afterbegin', bannerHtml);

    document.getElementById('slCloseBcBtn').onclick = () => {
      sessionStorage.setItem(`dismiss_bc_${bc.id}`, 'true');
      document.getElementById('slSystemBroadcastBanner').remove();
    };
  }

  // Open Support Modal Globally
  window.openSupportModal = function(tab = 'submit') {
    injectSupportModal();
    const modal = document.getElementById('slSupportModal');
    modal.classList.add('active');
    if (tab === 'list') {
      document.getElementById('slTabList').click();
    } else {
      document.getElementById('slTabSubmit').click();
    }
  };

  // Bind all support buttons/links on the page
  function bindSupportTriggers() {
    document.querySelectorAll('[href*="support.html"], #supportToggle, .open-support-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        // If on user/client page (not admin/support.html itself), intercept click to open Support Modal!
        if (!window.location.pathname.includes('/admin/support.html')) {
          e.preventDefault();
          window.openSupportModal('submit');
        }
      });
    });
  }

  // Boot Engine
  document.addEventListener('DOMContentLoaded', () => {
    injectStyles();
    injectSupportModal();
    setupNotifications();
    setupBroadcastBanner();
    bindSupportTriggers();
  });

})();
