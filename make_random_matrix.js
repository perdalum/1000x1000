#!/usr/bin/env node

// Check arguments: N
if (process.argv.length < 3) {
    console.error('Usage: make-matrix.js <N>');
    process.exit(1);
}

const n = parseInt(process.argv[2], 10);

// Validate N
if (!Number.isInteger(n) || n <= 0) {
    console.error('N must be a positive integer.');
    process.exit(1);
}

console.error(`Creating random ${n} x ${n} matrix...`);

// Generate random matrix with uniform reals in [0,1]
for (let i = 0; i < n; i += 1) {
    const row = [];
    for (let j = 0; j < n; j += 1) {
        row.push(Math.random());
    }
    console.log(row.join(','));
}

