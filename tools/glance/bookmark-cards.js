/*
 * Bookmark cards for unmodified Glance, loaded through document.head.
 * No widget options are required. Pair with the card styles in glance.css.
 * Independent of bookmark-search.js; either script can be loaded on its own.
 */
(() => {
    "use strict";
    if (window.__glanceBookmarkCards) return;
    window.__glanceBookmarkCards = true;

    const WIDGET = ".widget-type-bookmarks";
    let pendingFrame = 0;

    // Reuse the original anchors and icons, preserving targets, rel, colors and lazy loading.
    // Glance injects widgets after loading; repeated calls must leave converted cards alone.
    function setupCards() {
        document.querySelectorAll(`${WIDGET} .bookmarks-group`).forEach((group) => {
            const list = group.querySelector(":scope > ul.list");
            if (!list) return;
            const groups = group.parentElement;
            groups.classList.remove("dynamic-columns", "list-gap-24", "list-with-separator");
            groups.classList.add("bookmarks-cards-groups");
            const groupTitle = group.querySelector(":scope > .bookmarks-group-title");
            if (groupTitle) {
                groupTitle.classList.remove("margin-bottom-3");
                groupTitle.classList.add("margin-bottom-7");
            }
            const grid = document.createElement("div");
            grid.className = "bookmarks-cards";
            Array.from(list.children).forEach((item) => {
                const link = item.querySelector("a.bookmarks-link");
                if (!link) return;
                const header = document.createElement("div");
                header.className = "bookmarks-card-header";
                const icon = item.querySelector(".bookmarks-icon-container");
                if (icon) header.append(icon);
                const title = document.createElement("div");
                title.className = "bookmarks-card-title size-h4 color-highlight";
                title.append(...link.childNodes);
                header.append(title);
                if (!link.classList.contains("bookmarks-link-no-arrow")) {
                    const arrow = document.createElement("span");
                    arrow.className = "bookmarks-card-arrow";
                    arrow.textContent = "↗";
                    arrow.setAttribute("aria-hidden", "true");
                    header.append(arrow);
                }
                const description = item.querySelector(":scope > .margin-bottom-5");
                link.classList.remove("bookmarks-link", "bookmarks-link-no-arrow", "color-highlight", "size-h4");
                link.classList.add("bookmarks-card");
                link.replaceChildren(header);
                if (description) {
                    description.classList.remove("margin-bottom-5");
                    description.classList.add("bookmarks-card-description");
                    link.append(description);
                }
                grid.append(link);
            });
            list.replaceWith(grid);
        });
    }

    function scheduleRefresh() {
        if (pendingFrame) return;
        pendingFrame = requestAnimationFrame(() => {
            pendingFrame = 0;
            setupCards();
        });
    }

    function start() {
        setupCards();
        // Follow Glance's asynchronous page load and later bookmark DOM replacements.
        new MutationObserver((records) => {
            const relevant = records.some((record) => {
                if (record.target instanceof Element && record.target.closest(WIDGET)) return true;
                return Array.from(record.addedNodes).some((node) =>
                    node instanceof Element && (node.matches(WIDGET) || node.querySelector(WIDGET))
                );
            });
            if (relevant) scheduleRefresh();
        }).observe(document.body, { childList: true, subtree: true });
    }

    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", start, { once: true });
    else start();
})();
