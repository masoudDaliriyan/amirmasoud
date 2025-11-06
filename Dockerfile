FROM nginx:alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Write HTML directly into container
RUN cat << 'EOF' > /usr/share/nginx/html/index.html
<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8">
<title>Transaction Notes</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
  body { margin: 0; padding: 20px; font-family: system-ui, sans-serif; background: #f4f4f6; }
  .wrap { max-width: 700px; margin: auto; }
  textarea { width: 100%; height: 50vh; font-size: 16px; padding: 12px; border-radius: 8px; border: 1px solid #ccc; resize: none; }
  button { margin-top: 10px; padding: 10px 14px; border: none; background: #2b6efd; color: #fff; border-radius: 8px; cursor: pointer; font-size: 15px; }
  #snackbar { visibility: hidden; min-width: 120px; background-color: #333; color: #fff; text-align: center; border-radius: 6px; padding: 10px; position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%); z-index: 100; font-size: 14px; }
  #snackbar.show { visibility: visible; animation: fadein 0.3s, fadeout 0.3s 1.5s; }
  @keyframes fadein { from {bottom: 0; opacity: 0;} to {bottom: 30px; opacity: 1;} }
  @keyframes fadeout { from {bottom: 30px; opacity: 1;} to {bottom: 0; opacity: 0;} }
</style>
<script defer data-domain="coffee-shelly-78.tiiny.site" src="https://analytics.tiiny.site/js/plausible.js"></script><script src="https://tiiny.host/ad-script.js"></script></head>
<body>
<div class="wrap">
  <h2>Transaction Notes</h2>
  <textarea id="note" placeholder="Write notes here..."></textarea>
  <button onclick="saveNote()">Save</button>
</div>
<div id="snackbar"></div>
<script>
const API_URL = 'https://amirmasoud.liara.run/note';
const noteEl = document.getElementById('note');
const snackbar = document.getElementById('snackbar');
function showMessage(msg) { snackbar.textContent = msg; snackbar.className = 'show'; setTimeout(() => { snackbar.className = snackbar.className.replace('show',''); }, 1800); }
async function loadNote() { try { const res = await fetch(API_URL); if (res.ok) { const data = await res.json(); noteEl.value = data.text || ''; } } catch {} }
loadNote();
setInterval(() => { if (noteEl.value.trim()) saveNote(false); }, 10000);
async function saveNote(showMsg = true) {
  const text = noteEl.value.trim();
  if (!text) return showMsg && showMessage('Empty note not saved');
  try {
    const res = await fetch(API_URL, { method:'POST', headers:{ 'Content-Type':'application/json' }, body: JSON.stringify({ text }) });
    if (res.ok) showMsg && showMessage('Saved'); else saveLocal(text, showMsg);
  } catch { saveLocal(text, showMsg); }
}
function saveLocal(text, showMsg) {
  const KEY = 'transaction_notes_v1';
  const list = JSON.parse(localStorage.getItem(KEY) || '[]');
  list.push({ text, time: Date.now() });
  localStorage.setItem(KEY, JSON.stringify(list));
  showMsg && showMessage('Saved locally');
}
</script>
</body></html>
EOF

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
