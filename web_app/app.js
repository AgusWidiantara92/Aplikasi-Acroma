// ================= STATE MANAGEMENT =================
const AppState = {
  isAuthenticated: false,
  rememberMe: false,
  
  // Router Config
  router: {
    name: 'Router Mikrotik A',
    model: 'MikroTik hap ac²',
    ip: '192.168.88.1',
    port: 8728,
    user: 'admin',
    pass: 'password',
    uptimeSeconds: 1322600, // ~15d 7h 23m
  },

  // Active Metrics
  metrics: {
    cpu: 12,
    ram: 45,
    temp: 41,
    bandwidth: 128.5,
    totalData: 245.8,
    signal: 'Bagus',
    signalPercent: 92
  },

  // DHCP Client Leases
  devices: [
    { hostname: 'Admin-MacBook-Pro', ip: '192.168.88.10', mac: 'BC:D0:74:11:AB:23', isBlocked: false, limit: 'unlimited' },
    { hostname: 'SmartTV-4K', ip: '192.168.88.15', mac: 'D4:A3:3D:55:01:FF', isBlocked: false, limit: '2M' },
    { hostname: 'iPhone-Admin', ip: '192.168.88.22', mac: 'AA:11:BB:22:CC:33', isBlocked: false, limit: 'unlimited' },
    { hostname: 'Guest-Android', ip: '192.168.88.104', mac: 'F8:E9:D0:C1:B2:A3', isBlocked: true, limit: '512k' }
  ],

  // Recommendations
  recommendations: [
    { id: 'rec_cpu', title: 'Aksi Cepat', severity: 'critical', desc: 'Terdeteksi penggunaan bandwidth tinggi pada jam 14.00-17.00. Rekomendasi: Aktifkan QoS untuk prioritas traffic.', actionText: 'Terapkan' },
    { id: 'rec_sec', title: 'Security Enhancement', severity: 'warning', desc: 'Sistem mendeteksi 5 percobaan login gagal. Rekomendasi: Aktifkan firewall rule tambahan.', actionText: 'Review' }
  ],

  // Activity Logs
  logs: [
    { id: 1, message: 'Router rebooted by admin', topic: 'system', severity: 'info', time: '10:45:12' },
    { id: 2, message: 'DHCP lease assigned to 192.168.88.10', topic: 'dhcp', severity: 'info', time: '10:46:01' },
    { id: 3, message: 'Unauthorized SSH login attempt from 185.220.101.5 blocked', topic: 'firewall', severity: 'error', time: '10:50:33' },
    { id: 4, message: 'Interface ether1-wan link up (1Gbps)', topic: 'interface', severity: 'info', time: '10:51:00' }
  ]
};

// Selected client for bandwidth limit modal
let activeClientMac = null;

// ================= INITIALIZATION & LOCAL STORAGE =================
document.addEventListener('DOMContentLoaded', () => {
  loadSavedCredentials();
  setupEventListeners();
  startMetricPolling();
});

// Load credentials if Remember Me was checked
function loadSavedCredentials() {
  const remember = localStorage.getItem('acroma_remember') === 'true';
  if (remember) {
    document.getElementById('remember-me').checked = true;
    document.getElementById('email').value = localStorage.getItem('acroma_email') || '';
    document.getElementById('password').value = localStorage.getItem('acroma_pass') || '';
    AppState.rememberMe = true;
  }
}

// Save or remove credentials
function saveCredentials() {
  const remember = document.getElementById('remember-me').checked;
  if (remember) {
    localStorage.setItem('acroma_remember', 'true');
    localStorage.setItem('acroma_email', document.getElementById('email').value);
    localStorage.setItem('acroma_pass', document.getElementById('password').value);
  } else {
    localStorage.removeItem('acroma_remember');
    localStorage.removeItem('acroma_email');
    localStorage.removeItem('acroma_pass');
  }
}

// ================= EVENT LISTENERS SETUP =================
function setupEventListeners() {
  // Login Form
  document.getElementById('login-form').addEventListener('submit', (e) => {
    e.preventDefault();
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    
    // Simulate Authentication
    if (email.startsWith('demo') || (email === 'admin@acroma.net' && password === 'admin123')) {
      saveCredentials();
      loginSuccess();
    } else {
      const errorMsg = document.getElementById('error-message');
      errorMsg.classList.remove('hide');
    }
  });

  // Demo Mode Access
  document.getElementById('btn-demo').addEventListener('click', () => {
    loginSuccess();
  });

  // Forgot Password Link
  document.getElementById('forgot-password').addEventListener('click', (e) => {
    e.preventDefault();
    showModal('reset-password-modal');
  });

  // Forgot Password Send Button
  document.getElementById('btn-reset-send').addEventListener('click', () => {
    const email = document.getElementById('reset-email').value;
    if (email) {
      alert(`Link reset password telah dikirim ke: ${email}`);
      hideModal('reset-password-modal');
    }
  });

  // Cancel Forgot Password
  document.getElementById('btn-reset-cancel').addEventListener('click', () => {
    hideModal('reset-password-modal');
  });

  // Logout Button
  document.getElementById('btn-logout').addEventListener('click', () => {
    AppState.isAuthenticated = false;
    document.getElementById('dashboard-container').classList.add('hide');
    document.getElementById('auth-container').classList.add('active');
  });

  // Horizontal Navigation Tabs
  const tabs = document.querySelectorAll('.tab-btn');
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      
      const targetView = tab.getAttribute('data-tab');
      const views = document.querySelectorAll('.tab-view');
      views.forEach(v => v.classList.remove('active'));
      document.getElementById(targetView).classList.add('active');
    });
  });

  // Edit Router Top Icon
  document.getElementById('btn-edit-router').addEventListener('click', () => {
    openEditRouterModal();
  });

  // Edit Router Settings Tab Button
  document.getElementById('btn-edit-router-settings').addEventListener('click', () => {
    openEditRouterModal();
  });

  // Save Router Modal Button
  document.getElementById('btn-modal-save').addEventListener('click', () => {
    AppState.router.name = document.getElementById('edit-name').value;
    AppState.router.ip = document.getElementById('edit-host').value;
    AppState.router.port = parseInt(document.getElementById('edit-port').value) || 8728;
    AppState.router.user = document.getElementById('edit-user').value;
    AppState.router.pass = document.getElementById('edit-pass').value;
    
    updateUIElements();
    hideModal('edit-router-modal');
  });

  // Cancel Router Modal Button
  document.getElementById('btn-modal-cancel').addEventListener('click', () => {
    hideModal('edit-router-modal');
  });

  // Limit Bandwidth Modal Buttons
  document.getElementById('btn-limit-cancel').addEventListener('click', () => {
    hideModal('limit-client-modal');
  });
  
  document.getElementById('btn-limit-save').addEventListener('click', () => {
    const limitVal = document.getElementById('limit-download').value;
    const device = AppState.devices.find(d => d.mac === activeClientMac);
    if (device) {
      device.limit = limitVal;
      
      // Log limit event
      addLogEntry(`Bandwidth limit applied for ${device.hostname}: Max ${limitVal}`, 'firewall', 'info');
      
      renderDevicesList();
      hideModal('limit-client-modal');
    }
  });
}

// ================= CONTROLLER FLOWS =================
function loginSuccess() {
  AppState.isAuthenticated = true;
  document.getElementById('auth-container').classList.remove('active');
  document.getElementById('dashboard-container').classList.remove('hide');
  updateUIElements();
  renderDevicesList();
  renderRecommendations();
  renderLogs();
}

function openEditRouterModal() {
  document.getElementById('edit-name').value = AppState.router.name;
  document.getElementById('edit-host').value = AppState.router.ip;
  document.getElementById('edit-port').value = AppState.router.port;
  document.getElementById('edit-user').value = AppState.router.user;
  document.getElementById('edit-pass').value = AppState.router.pass;
  showModal('edit-router-modal');
}

function showModal(id) {
  document.getElementById(id).classList.remove('hide');
}

function hideModal(id) {
  document.getElementById(id).classList.add('hide');
}

// Add logs dynamically
function addLogEntry(message, topic, severity) {
  const now = new Date();
  const timeStr = `${now.getHours().toString().padLeft()}:${now.getMinutes().toString().padLeft()}:${now.getSeconds().toString().padLeft()}`;
  AppState.logs.unshift({
    id: Date.now(),
    message: message,
    topic: topic,
    severity: severity,
    time: timeStr
  });
  renderLogs();
}

String.prototype.padLeft = function() {
  return this.length < 2 ? '0' + this : this;
};

// ================= RENDER DYNAMIC DOM VIEWS =================
function updateUIElements() {
  // Router Info Card
  document.getElementById('router-name').innerText = AppState.router.name;
  document.getElementById('router-ip').innerText = `IP: ${AppState.router.ip}`;
  
  // Settings Tab
  document.getElementById('settings-name').innerText = AppState.router.name;
  document.getElementById('settings-ip').innerText = AppState.router.ip;
  
  // Overview Tab Indicators
  document.getElementById('view-devices-count').innerText = AppState.devices.filter(d => !d.isBlocked).length;
  document.getElementById('view-bandwidth').innerText = AppState.metrics.bandwidth.toFixed(1);
  document.getElementById('view-data-used').innerText = `${AppState.metrics.totalData.toFixed(1)} GB`;
  document.getElementById('view-signal').innerText = AppState.metrics.signal;
}

// Render connected devices list
function renderDevicesList() {
  const container = document.getElementById('devices-list');
  container.innerHTML = '';
  
  document.getElementById('devices-badge').innerText = `Total: ${AppState.devices.length}`;

  AppState.devices.forEach(device => {
    const card = document.createElement('div');
    card.className = 'client-card';
    
    card.innerHTML = `
      <div class="client-details">
        <span class="client-name">${device.hostname}</span>
        <span class="client-ip">IP: ${device.ip}</span>
        <span class="client-mac">MAC: ${device.mac}</span>
        ${device.isBlocked ? '<span style="color:red; font-size:10px; font-weight:bold; margin-top:2px;">BLOCKED</span>' : ''}
        ${!device.isBlocked && device.limit !== 'unlimited' ? `<span style="color:#1D4ED8; font-size:10px; font-weight:bold; margin-top:2px;">Limit: ${device.limit}</span>` : ''}
      </div>
      <div class="client-actions">
        <button class="btn-sm btn-limit" onclick="openLimiterModal('${device.mac}')">Batasi</button>
        <button class="btn-sm ${device.isBlocked ? 'btn-unblock' : 'btn-block'}" onclick="toggleBlockClient('${device.mac}')">
          ${device.isBlocked ? 'Unblock' : 'Block'}
        </button>
      </div>
    `;
    container.appendChild(card);
  });
}

// Global functions linked to generated buttons
window.openLimiterModal = (mac) => {
  activeClientMac = mac;
  const device = AppState.devices.find(d => d.mac === mac);
  if (device) {
    document.getElementById('limit-client-name').innerText = `Batasi bandwidth untuk perangkat: ${device.hostname}`;
    document.getElementById('limit-download').value = device.limit;
    showModal('limit-client-modal');
  }
};

window.toggleBlockClient = (mac) => {
  const device = AppState.devices.find(d => d.mac === mac);
  if (device) {
    device.isBlocked = !device.isBlocked;
    
    // Log Block/Unblock event
    const logMsg = device.isBlocked
      ? `firewall: client ${device.hostname} (${device.mac}) blocked by admin`
      : `firewall: client ${device.hostname} (${device.mac}) unblocked by admin`;
    addLogEntry(logMsg, 'firewall', device.isBlocked ? 'warning' : 'info');
    
    renderDevicesList();
    updateUIElements();
  }
};

// Render AI Recommendations list
function renderRecommendations() {
  const container = document.getElementById('ai-recs-list');
  container.innerHTML = '';
  
  AppState.recommendations.forEach(rec => {
    const card = document.createElement('div');
    card.className = 'ai-card';
    
    const isHigh = rec.severity === 'critical';
    const badgeClass = isHigh ? 'badge-high' : 'badge-medium';
    const labelText = isHigh ? 'Prioritas Tinggi' : 'Medium';
    const icon = isHigh ? 'warning' : 'security';
    const color = isHigh ? '#DC2626' : '#D97706';

    card.innerHTML = `
      <div class="ai-card-header">
        <div class="ai-title-row">
          <span class="material-icons-outlined" style="color: ${color}; font-size: 20px;">${icon}</span>
          <span class="ai-card-title" style="color: ${color};">${rec.title}</span>
        </div>
        <span class="ai-priority-badge ${badgeClass}">${labelText}</span>
      </div>
      <p class="ai-card-desc">${rec.desc}</p>
      <button class="ai-action-btn" onclick="applyRecommendation('${rec.id}')">${rec.actionText}</button>
    `;
    container.appendChild(card);
  });
}

window.applyRecommendation = (id) => {
  alert(`Rekomendasi diterapkan: ${id}`);
  AppState.recommendations = AppState.recommendations.filter(r => r.id !== id);
  renderRecommendations();
};

// Render Log list
function renderLogs() {
  const container = document.getElementById('logs-list');
  container.innerHTML = '';
  
  AppState.logs.forEach(log => {
    const card = document.createElement('div');
    card.className = 'log-item';
    
    let icon = 'info_outline';
    let color = '#059669'; // Green Info
    let bgColor = 'rgba(5, 150, 105, 0.1)';
    
    if (log.severity === 'warning') {
      icon = 'lock';
      color = '#7C3AED'; // Purple
      bgColor = 'rgba(124, 58, 237, 0.1)';
    } else if (log.severity === 'error') {
      icon = 'warning_amber';
      color = '#D97706'; // Orange Warning
      bgColor = 'rgba(217, 119, 6, 0.1)';
    }

    card.innerHTML = `
      <div class="log-avatar" style="background-color: ${bgColor}; color: ${color};">
        <span class="material-icons-outlined">${icon}</span>
      </div>
      <div class="log-details">
        <p class="log-text">${log.message}</p>
        <span class="log-sub">${log.topic.toUpperCase()} • ${log.time}</span>
      </div>
    `;
    container.appendChild(card);
  });
}

// ================= POLLING SIMULATION TELEMETRY =================
function startMetricPolling() {
  setInterval(() => {
    if (!AppState.isAuthenticated) return;
    
    // Uptime tick
    AppState.router.uptimeSeconds += 2;
    document.getElementById('router-uptime').innerText = formatUptime(AppState.router.uptimeSeconds);
    document.getElementById('settings-uptime').innerText = formatUptime(AppState.router.uptimeSeconds);

    // Fluctuate CPU
    AppState.metrics.cpu = Math.max(2, Math.min(98, AppState.metrics.cpu + (Math.random() * 6 - 3)));
    document.getElementById('metric-cpu').innerText = `${AppState.metrics.cpu.toFixed(0)}%`;
    
    // Fluctuate RAM
    AppState.metrics.ram = Math.max(30, Math.min(95, AppState.metrics.ram + (Math.random() * 2 - 1)));
    document.getElementById('metric-ram').innerText = `${AppState.metrics.ram.toFixed(0)}%`;

    // Fluctuate Temp
    AppState.metrics.temp = Math.max(35, Math.min(52, AppState.metrics.temp + (Math.random() * 0.4 - 0.2)));
    document.getElementById('metric-temp').innerText = `${AppState.metrics.temp.toFixed(0)}°C`;

    // Fluctuate Bandwidth download rate
    AppState.metrics.bandwidth = Math.max(10, AppState.metrics.bandwidth + (Math.random() * 20 - 10));
    AppState.metrics.totalData += 0.0001; // Data usage ticks
    
    updateUIElements();
  }, 2000);
}

function formatUptime(totalSecs) {
  const days = Math.floor(totalSecs / 86400);
  const hours = Math.floor((totalSecs % 86400) / 3600);
  const mins = Math.floor((totalSecs % 3600) / 60);
  
  let daysStr = days > 0 ? `${days}d ` : '';
  return `${daysStr}${hours}h ${mins}m`;
}
