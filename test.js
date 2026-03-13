const square = require('./app');

function runTests() {

    const tests = [
        { input: 2, expected: 4 },
        { input: 3, expected: 9 },
        { input: 4, expected: 16 }
    ];

    tests.forEach(t => {
        const result = square(t.input);

        if (result === t.expected) {
            console.log(`PASS: ${t.input} -> ${result}`);
        } else {
            console.log(`FAIL: ${t.input} -> ${result}`);
            process.exit(1);
        }
    });

    console.log("All tests passed!");
}

runTests();