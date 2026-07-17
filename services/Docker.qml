pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

Singleton {
    id: root

    property int totalCount: 0
    property int runningCount: 0
    property list<string> containerNames: []

    function parseDockerPs(text) {
        let lines = text.split('\n');
        let total = 0;
        let running = 0;
        let names = [];
        
        for (let i = 0; i < lines.length; i++) {
            let line = lines[i].trim();
            if (line.length === 0) continue;
            
            try {
                let obj = JSON.parse(line);
                total++;
                if (obj.State === "running" || obj.State === "Up") {
                    running++;
                } else if (obj.Status && obj.Status.startsWith("Up")) {
                    // Sometimes docker outputs "Status": "Up 2 hours" instead of State in some versions/configurations, though format json usually has State
                    running++;
                }
                if (obj.Names) {
                    names.push(obj.Names);
                }
            } catch (e) {
                // Ignore parse errors for individual lines
            }
        }
        
        return {
            totalCount: total,
            runningCount: running,
            containerNames: names
        };
    }

    Process {
        id: dockerProc
        command: ["bash", "-c", "docker ps -a --format '{{json .}}' 2>/dev/null || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parsed = root.parseDockerPs(text);
                if (parsed !== null) {
                    root.totalCount = parsed.totalCount;
                    root.runningCount = parsed.runningCount;
                    root.containerNames = parsed.containerNames;
                }
            }
        }
    }

    Timer {
        interval: Config?.options?.resources?.updateInterval ?? 3000
        running: true
        repeat: true
        onTriggered: {
            dockerProc.running = false;
            dockerProc.running = true;
        }
    }
}
