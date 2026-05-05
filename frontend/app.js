const backendUrl = 'REPLACE_WITH_BACKEND_API_URL';
const healthOutput = document.getElementById('health-output');
const visitorsOutput = document.getElementById('visitors-output');
const backendUrlElement = document.getElementById('backend-url');
backendUrlElement.textContent = backendUrl;

async function checkHealth() {
  if (backendUrl.includes('REPLACE_WITH_BACKEND_API_URL')) {
    healthOutput.textContent = 'Please replace the backend URL in frontend/app.js with the deployed API URL.';
    return;
  }

  try {
    const response = await fetch(`${backendUrl}/api/health`);
    const data = await response.json();
    healthOutput.textContent = `Status: ${data.status}\nServer Time: ${data.time}`;
  } catch (error) {
    healthOutput.textContent = `Error fetching backend health: ${error.message}`;
  }
}

async function loadVisitors() {
  if (backendUrl.includes('REPLACE_WITH_BACKEND_API_URL')) {
    visitorsOutput.textContent = 'Please replace the backend URL in frontend/app.js with the deployed API URL.';
    return;
  }

  try {
    const response = await fetch(`${backendUrl}/api/visitors`);
    const data = await response.json();
    const visitors = data.visitors || [];
    if (visitors.length === 0) {
      visitorsOutput.textContent = 'No visitors recorded yet.';
    } else {
      const visitorList = visitors.map(v =>
        `ID: ${v.id} - Visited: ${new Date(v.visited_at).toLocaleString()}`
      ).join('\n');
      visitorsOutput.textContent = `Recent Visitors:\n${visitorList}`;
    }
  } catch (error) {
    visitorsOutput.textContent = `Error loading visitors: ${error.message}`;
  }
}

document.getElementById('health-check').addEventListener('click', checkHealth);
document.getElementById('load-visitors').addEventListener('click', loadVisitors);

// Auto-load visitors on page load
document.addEventListener('DOMContentLoaded', () => {
  if (!backendUrl.includes('REPLACE_WITH_BACKEND_API_URL')) {
    loadVisitors();
  }
});
