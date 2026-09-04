/* 価格調査ソフト Service Worker（公開版のみ）
   - アプリ本体(HTML)はネット優先＝更新をすぐ反映、切断時はキャッシュで起動
   - CDNライブラリ(React/Tailwind/xlsx/ExcelJS/pdf.js/tesseract)はキャッシュ優先＝2回目以降は高速・オフライン可
   - データはIndexedDB（端末内）。SWは触らない */
const CACHE = "kakaku-chousa-v1";
const SHELL = ["./", "./index.html", "./価格調査ソフト.html", "./manifest.webmanifest", "./icon-192.png", "./icon-512.png",
  // 起動に必須のCDNライブラリも初回インストール時に取り込む＝初回訪問の直後からオフライン起動できる（pdf.js/OCRは使用時にキャッシュ）
  "https://cdn.tailwindcss.com",
  "https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js",
  "https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.2.0/umd/react-dom.production.min.js",
  "https://cdnjs.cloudflare.com/ajax/libs/babel-standalone/7.23.5/babel.min.js",
  "https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js",
  "https://cdnjs.cloudflare.com/ajax/libs/exceljs/4.4.0/exceljs.min.js"];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => Promise.all(SHELL.map((u) => c.add(u).catch(() => {})))).then(() => self.skipWaiting()));
});
self.addEventListener("activate", (e) => {
  e.waitUntil(caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  const sameOrigin = url.origin === self.location.origin;
  const isHtml = req.mode === "navigate" || /\.html$/i.test(url.pathname) || url.pathname.endsWith("/");
  if (sameOrigin && isHtml) {
    // ネット優先（更新反映）→ 失敗時キャッシュ
    e.respondWith(fetch(req).then((res) => { const copy = res.clone(); caches.open(CACHE).then((c) => c.put(req, copy)).catch(() => {}); return res; })
      .catch(() => caches.match(req).then((hit) => hit || caches.match("./価格調査ソフト.html"))));
    return;
  }
  // 自サイトの資産・CDNライブラリ：キャッシュ優先 → 無ければ取得してキャッシュ
  e.respondWith(caches.match(req).then((hit) => hit || fetch(req).then((res) => {
    if (res && (res.ok || res.type === "opaque")) { const copy = res.clone(); caches.open(CACHE).then((c) => c.put(req, copy)).catch(() => {}); }
    return res;
  })));
});
