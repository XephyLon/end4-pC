pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    property bool loading: false
    property string errorMessage: ""
    property var rates: ({})
    property string baseCurrency: "USD"
    property string quote1: "EUR"
    property string quote2: "GBP"
    property string quote3: "JPY"
    property string quote4: "CAD"

    function refresh() {
        if (root.loading || !root.baseCurrency) return;
        root.loading = true;
        root.errorMessage = "";
        const base = root.baseCurrency.toLowerCase();
        const xhr = new XMLHttpRequest();
        xhr.open("GET", `https://latest.currency-api.pages.dev/v1/currencies/${encodeURIComponent(base)}.json`);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;
            root.loading = false;
            if (xhr.status !== 200) {
                root.errorMessage = xhr.status === 0 ? "No network" : `HTTP ${xhr.status}`;
                return;
            }
            try {
                const values = JSON.parse(xhr.responseText)[base] || {};
                const normalized = {};
                for (const key in values)
                    normalized[key.toUpperCase()] = values[key] ? 1 / values[key] : 0;
                root.rates = normalized;
            } catch (error) {
                root.errorMessage = "Parse error";
            }
        };
        xhr.send();
    }
}
