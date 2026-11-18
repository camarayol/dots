/* Prevent Glance's document-level search handler from treating IME confirmation as Enter. */
(() => {
    "use strict";

    document.addEventListener("keydown", (event) => {
        if (!(event.target instanceof Element) || !event.target.matches(".search .search-input")) return;
        if (!event.isComposing && event.keyCode !== 229) return;

        // Preserve the browser's IME behavior; only stop Glance's search shortcut handler.
        event.stopImmediatePropagation();
    }, true);
})();
