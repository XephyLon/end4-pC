import QtQuick
import QtTest
import qs.services

TestCase {
    name: "DockerServiceTest"

    function test_parseDockerPs() {
        var docker = Docker;
        verify(docker !== null);

        // docker ps -a --format '{{json .}}' sample output
        var dockerData = 
            '{"ID":"5adc504ae4dd","Names":"odysseus-odysseus-1","State":"exited","Status":"Exited (0) 2 weeks ago"}\n' +
            '{"ID":"ae5ebea00db2","Names":"odysseus-chromadb-1","State":"running","Status":"Up 3 weeks"}\n';

        var parsed = docker.parseDockerPs(dockerData);
        verify(parsed !== null);
        compare(parsed.totalCount, 2);
        compare(parsed.runningCount, 1);
        compare(parsed.containerNames.length, 2);
        compare(parsed.containerNames[0], "odysseus-odysseus-1");
        compare(parsed.containerNames[1], "odysseus-chromadb-1");

        // Test with empty/invalid data
        var invalidData = "invalid data\n{}\n";
        var parsedInvalid = docker.parseDockerPs(invalidData);
        verify(parsedInvalid !== null);
        compare(parsedInvalid.totalCount, 1);
        compare(parsedInvalid.runningCount, 0);
        compare(parsedInvalid.containerNames.length, 0);
    }
}
