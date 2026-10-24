/*
 * Step-by-step SVG animations for the course website.
 *
 * Markup (works as a static image + numbered list on GitHub):
 *
 *   <figure class="el-anim">
 *     <img src="boot-chain.svg" alt="...">
 *     <ol class="el-anim-steps">
 *       <li>First step caption</li>
 *       <li>Second step caption</li>
 *     </ol>
 *   </figure>
 *
 * The script inlines the SVG and steps through the list. Elements inside the
 * SVG react to the current step (steps are numbered from 1):
 *
 *   data-from="3"            hidden before step 3
 *   data-until="4"           hidden after step 4
 *   data-active="2,5-6"      highlighted (class is-active) at those steps
 *   data-move="2:120,0 4:240,40"
 *                            translated by (x,y) from that step on
 */
(function () {
  "use strict";

  var PLAY_MS = 2600;

  function parseSet(value) {
    var set = {};
    value.split(",").forEach(function (part) {
      var range = part.trim().split("-");
      var from = parseInt(range[0], 10);
      var to = range.length > 1 ? parseInt(range[1], 10) : from;
      for (var i = from; i <= to; i++) set[i] = true;
    });
    return set;
  }

  function parseMoves(value) {
    return value.trim().split(/\s+/).map(function (part) {
      var kv = part.split(":");
      var xy = kv[1].split(",");
      return { step: parseInt(kv[0], 10), x: parseFloat(xy[0]), y: parseFloat(xy[1]) };
    }).sort(function (a, b) { return a.step - b.step; });
  }

  function button(label, title, onClick) {
    var b = document.createElement("button");
    b.type = "button";
    b.className = "el-anim-btn";
    b.textContent = label;
    b.title = title;
    b.setAttribute("aria-label", title);
    b.addEventListener("click", onClick);
    return b;
  }

  function setup(figure, svg) {
    var items = Array.prototype.slice.call(figure.querySelectorAll(".el-anim-steps > li"));
    var total = items.length;
    if (!total) return;

    svg.classList.add("el-inline");
    svg.removeAttribute("width");
    svg.removeAttribute("height");

    var froms = Array.prototype.slice.call(svg.querySelectorAll("[data-from],[data-until]"));
    var actives = Array.prototype.slice.call(svg.querySelectorAll("[data-active]")).map(function (el) {
      return { el: el, set: parseSet(el.getAttribute("data-active")) };
    });
    var movers = Array.prototype.slice.call(svg.querySelectorAll("[data-move]")).map(function (el) {
      return { el: el, moves: parseMoves(el.getAttribute("data-move")) };
    });

    // controls and caption
    var caption = document.createElement("div");
    caption.className = "el-anim-caption";
    caption.setAttribute("aria-live", "polite");

    var counter = document.createElement("span");
    counter.className = "el-anim-counter";

    var dots = document.createElement("div");
    dots.className = "el-anim-dots";
    items.forEach(function (_, i) {
      var d = document.createElement("button");
      d.type = "button";
      d.className = "el-anim-dot";
      d.setAttribute("aria-label", "Step " + (i + 1));
      d.addEventListener("click", function () { stop(); go(i + 1); });
      dots.appendChild(d);
    });

    var current = 1;
    var timer = null;

    var prev = button("◀", "Previous step", function () { stop(); go(current - 1); });
    var play = button("▶ Play", "Play", function () { timer ? stop() : start(); });
    var next = button("▶", "Next step", function () { stop(); go(current + 1); });
    var restart = button("↺", "Restart", function () { stop(); go(1); });

    var bar = document.createElement("div");
    bar.className = "el-anim-bar";
    [restart, prev, play, next].forEach(function (b) { bar.appendChild(b); });
    bar.appendChild(dots);
    bar.appendChild(counter);

    figure.appendChild(caption);
    figure.appendChild(bar);
    figure.classList.add("el-anim-ready");

    function go(step) {
      current = Math.max(1, Math.min(total, step));

      froms.forEach(function (el) {
        var from = el.hasAttribute("data-from") ? parseInt(el.getAttribute("data-from"), 10) : 1;
        var until = el.hasAttribute("data-until") ? parseInt(el.getAttribute("data-until"), 10) : total;
        el.classList.toggle("is-hidden", current < from || current > until);
      });
      actives.forEach(function (a) { a.el.classList.toggle("is-active", !!a.set[current]); });
      movers.forEach(function (m) {
        var x = 0, y = 0;
        m.moves.forEach(function (mv) { if (current >= mv.step) { x = mv.x; y = mv.y; } });
        m.el.style.transform = "translate(" + x + "px," + y + "px)";
      });

      caption.innerHTML = items[current - 1].innerHTML;
      counter.textContent = current + " / " + total;
      Array.prototype.forEach.call(dots.children, function (d, i) {
        d.classList.toggle("is-current", i + 1 === current);
        d.classList.toggle("is-done", i + 1 < current);
      });
      prev.disabled = current === 1;
      next.disabled = current === total;
    }

    function start() {
      if (current === total) go(1);
      play.textContent = "❚❚ Pause";
      play.title = "Pause";
      timer = setInterval(function () {
        if (current >= total) { stop(); return; }
        go(current + 1);
      }, PLAY_MS);
    }

    function stop() {
      if (timer) clearInterval(timer);
      timer = null;
      play.textContent = "▶ Play";
      play.title = "Play";
    }

    go(1);
  }

  function init(root) {
    // el-anim-loading guards against init() running twice before the fetch completes
    var figures = (root || document).querySelectorAll("figure.el-anim:not(.el-anim-ready):not(.el-anim-loading)");
    Array.prototype.forEach.call(figures, function (figure) {
      var img = figure.querySelector("img");
      if (!img || !window.fetch) return;
      figure.classList.add("el-anim-loading");
      fetch(img.src)
        .then(function (r) { if (!r.ok) throw new Error(r.status); return r.text(); })
        .then(function (text) {
          var doc = new DOMParser().parseFromString(text, "image/svg+xml");
          var svg = doc.documentElement;
          if (!svg || svg.nodeName.toLowerCase() !== "svg") return;
          svg = document.importNode(svg, true);
          svg.setAttribute("role", "img");
          svg.setAttribute("aria-label", img.alt || "");
          img.replaceWith(svg);
          setup(figure, svg);
        })
        .catch(function () { /* keep the static image */ })
        .then(function () { figure.classList.remove("el-anim-loading"); });
    });
  }

  // Material's instant navigation exposes document$; plain pages use DOMContentLoaded
  if (window.document$ && window.document$.subscribe) {
    window.document$.subscribe(function () { init(); });
  } else if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", function () { init(); });
  } else {
    init();
  }
})();
