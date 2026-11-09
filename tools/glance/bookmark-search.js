/*
 * Local !bm search for unmodified Glance, loaded through document.head.
 * No configured bang is required. Pair with the search-state styles in glance.css.
 * Matches bookmark titles only, in page order; URLs, descriptions and group names are excluded.
 * Supports native lists and cards without depending on bookmark-cards.js.
 * Plain text and other !bangs remain owned by Glance; Enter opens the selected bookmark.
 */
(() => {
    "use strict";
    if (window.__glanceBookmarkSearch) return;
    window.__glanceBookmarkSearch = true;

    const INPUT = ".search .search-input";
    const LINK = ".widget-type-bookmarks a.bookmarks-card, .widget-type-bookmarks a.bookmarks-link";
    const HIDDEN = "bookmark-search-hidden";
    const TARGET = "bookmark-search-target";
    const states = new WeakMap();
    const hiddenElements = new Set();
    let activeInput = null;
    let highlightedLink = null;
    let pendingFrame = 0;

    function normalize(value) {
        return value.normalize("NFKC").toLowerCase().replace(/\s+/g, " ").trim();
    }

    function mode(input) {
        const value = input.value.trim();
        if (/^!bm(?:\s|$)/.test(value)) return "local";
        return value ? "web" : "idle";
    }

    function bookmarkQuery(input) {
        return normalize(input.value.trim().replace(/^!bm(?:\s+|$)/, ""));
    }

    function syncBangLabel(input) {
        const search = input.closest(".search");
        const label = search?.querySelector(".search-bang");
        if (!label) return;
        const shortcut = input.value.trim().split(/\s+/)[0];
        const bang = Array.from(search.querySelectorAll(".search-bangs > input"))
            .findLast((element) => element.dataset.shortcut === shortcut);
        const title = mode(input) === "local" ? "Bookmarks" : bang?.dataset.title || "";
        if (label.textContent !== title) label.textContent = title;
    }

    function initialize() {
        document.querySelectorAll(INPUT).forEach((input) => {
            if (states.has(input)) return;
            states.set(input, { matches: [], index: 0, query: "" });
            syncBangLabel(input);
        });
    }

    function clearDecorations() {
        hiddenElements.forEach((element) => element.classList.remove(HIDDEN));
        hiddenElements.clear();
        document.documentElement.classList.remove("bookmark-search-filtering");
        if (highlightedLink) highlightedLink.classList.remove(TARGET);
        highlightedLink = null;
    }

    function hide(element) {
        element.classList.add(HIDDEN);
        hiddenElements.add(element);
    }

    function searchableTitle(link) {
        // Cards contain descriptions and arrows; native list anchors contain only the title.
        const title = link.querySelector(".bookmarks-card-title") || link;
        return normalize(title.textContent);
    }

    function reveal(link, keepVisible = null) {
        // Group widgets keep inactive tabs in the DOM. Activate ancestors from outside in.
        const panels = [];
        for (let parent = link.parentElement; parent; parent = parent.parentElement) {
            if (parent.matches(".widget-group-content")) panels.push(parent);
        }
        // Never hide the input's own tab while the user is still typing in it.
        if (keepVisible && panels.some((panel) => panel.parentElement.contains(keepVisible) && !panel.contains(keepVisible))) return;
        panels.reverse().forEach((panel) => {
            if (!panel.classList.contains("widget-group-content-current")) {
                document.getElementById(panel.getAttribute("aria-labelledby"))?.click();
            }
        });
    }

    function selectResult(state, scroll = false, focus = false) {
        if (highlightedLink) highlightedLink.classList.remove(TARGET);
        const link = state.matches[state.index];
        highlightedLink = link || null;
        if (!link) return;
        reveal(link, focus ? null : activeInput);
        link.classList.add(TARGET);
        if (focus) link.focus({ preventScroll: true });
        if (scroll) {
            link.scrollIntoView({
                block: "center",
                behavior: window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "instant" : "smooth",
            });
        }
    }

    function filter(input) {
        initialize();
        const state = states.get(input);
        if (!state) return;
        const wasActive = activeInput === input;
        activeInput = input;
        clearDecorations();
        syncBangLabel(input);
        if (mode(input) !== "local") {
            state.matches = [];
            state.query = "";
            return;
        }

        const query = bookmarkQuery(input);
        if (!query) {
            state.matches = [];
            state.query = "";
            return;
        }
        const terms = query.split(" ").filter(Boolean);
        const previousLink = wasActive && query === state.query ? state.matches[state.index] : null;
        const links = Array.from(document.querySelectorAll(LINK));
        state.matches = links.filter((link) => {
            const title = searchableTitle(link);
            return terms.every((term) => title.includes(term));
        });
        state.query = query;
        state.index = Math.max(0, state.matches.indexOf(previousLink));
        const matched = new Set(state.matches);
        document.documentElement.classList.add("bookmark-search-filtering");

        links.forEach((link) => {
            if (!matched.has(link)) hide(link.matches(".bookmarks-card") ? link : link.closest("li") || link);
        });
        document.querySelectorAll(".widget-type-bookmarks .bookmarks-group, .widget-type-bookmarks").forEach((container) => {
            const children = Array.from(container.querySelectorAll("a.bookmarks-card, a.bookmarks-link"));
            if (children.length > 0 && !children.some((link) => matched.has(link))) hide(container);
        });
        selectResult(state);
    }

    function reset(input) {
        input.value = "";
        reveal(input);
        // Focus first: Glance only attaches its input/bang listener while focused.
        input.focus({ preventScroll: true });
        input.dispatchEvent(new Event("input", { bubbles: true }));
    }

    document.addEventListener("input", (event) => {
        if (event.target instanceof Element && event.target.matches(INPUT) && !event.isComposing) {
            filter(event.target);
        }
    }, true);

    // Glance updates this label on document input; window bubbling runs afterwards.
    window.addEventListener("input", (event) => {
        if (event.target instanceof Element && event.target.matches(INPUT)) syncBangLabel(event.target);
    });

    document.addEventListener("compositionend", (event) => {
        if (event.target instanceof Element && event.target.matches(INPUT)) filter(event.target);
    }, true);

    document.addEventListener("focus", (event) => {
        if (event.target instanceof Element && event.target.matches(INPUT)) filter(event.target);
    }, true);

    // Capture before Glance's document-level handler so local Enter never launches a web search.
    document.addEventListener("keydown", (event) => {
        const target = event.target;
        if (!(target instanceof Element)) return;
        const input = target.matches(INPUT) ? target : (
            event.key === "Tab" && target === highlightedLink && activeInput?.isConnected ? activeInput : null
        );
        if (event.isComposing || event.keyCode === 229) {
            if (input && mode(input) === "local") event.stopImmediatePropagation();
            return;
        }
        if (event.key === "Escape" && activeInput?.isConnected && mode(activeInput) === "local" &&
            (input === activeInput || target === highlightedLink)) {
            event.preventDefault();
            event.stopImmediatePropagation();
            reset(activeInput);
            return;
        }
        if (!input || mode(input) !== "local") return;
        const isTab = event.key === "Tab";
        if (!["Enter", "ArrowDown", "ArrowUp", "Tab"].includes(event.key)) return;
        if (isTab) {
            // Keep browser shortcuts such as Ctrl+Tab untouched; Shift+Tab cycles backwards.
            if (event.ctrlKey || event.metaKey || event.altKey) return;
        } else if (event.key !== "Enter" && (event.ctrlKey || event.metaKey || event.altKey || event.shiftKey)) {
            return;
        }
        const focusResult = target === highlightedLink;
        filter(input);
        const state = states.get(input);
        // Only override Tab when there are multiple results to cycle through.
        if (isTab && state.matches.length < 2) return;
        event.preventDefault();
        event.stopImmediatePropagation();
        if (!state.query) return;
        if (event.key === "Enter") {
            // Native activation preserves same-tab, target and rel, as on camarayol.
            state.matches[state.index]?.click();
        } else if (state.matches.length) {
            const direction = isTab ? (event.shiftKey ? -1 : 1) : (event.key === "ArrowDown" ? 1 : -1);
            state.index = (state.index + direction + state.matches.length) % state.matches.length;
            // Keep input focus while typing; cycle focused links after normal Tab navigation.
            selectResult(state, true, focusResult);
        }
    }, true);

    function scheduleRefresh() {
        if (pendingFrame) return;
        pendingFrame = requestAnimationFrame(() => {
            pendingFrame = 0;
            initialize();
            if (activeInput?.isConnected) {
                filter(activeInput);
            } else {
                activeInput = null;
                clearDecorations();
            }
        });
    }

    function start() {
        initialize();
        // Glance injects page widgets asynchronously; follow later DOM replacements too.
        new MutationObserver((records) => {
            const relevant = records.some((record) => {
                const target = record.target instanceof Element ? record.target : record.target.parentElement;
                if (target?.closest(".widget-type-bookmarks")) return true;
                return [...record.addedNodes, ...record.removedNodes].some((node) =>
                    node instanceof Element && (
                        node.matches(".widget-type-search, .widget-type-bookmarks, .search-input") ||
                        node.querySelector(".widget-type-search, .widget-type-bookmarks, .search-input")
                    )
                );
            });
            if (relevant) scheduleRefresh();
        }).observe(document.body, {
            childList: true,
            subtree: true,
            characterData: true,
        });
    }

    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", start, { once: true });
    else start();
})();
