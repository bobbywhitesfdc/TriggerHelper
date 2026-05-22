const fs = require('fs');
const path = require('path');

const proj = JSON.parse(fs.readFileSync(path.join(__dirname, 'sfdx-project.json'), 'utf8'));
const aliases = proj.packageAliases || {};

const versions = Object.keys(aliases)
  .filter(k => /^TriggerHelperFramework@\d/.test(k))
  .sort((a, b) => {
    const parse = s => {
      const m = s.match(/@(\d+)\.(\d+)\.(\d+)-(\d+)$/);
      return m ? [+m[1], +m[2], +m[3], +m[4]] : [0, 0, 0, 0];
    };
    const va = parse(a);
    const vb = parse(b);
    for (let i = 0; i < 4; i++) {
      if (va[i] !== vb[i]) return va[i] - vb[i];
    }
    return 0;
  });

if (versions.length === 0) {
  process.stderr.write('No published TriggerHelperFramework versions found in sfdx-project.json\n');
  process.exit(1);
}

const latestAlias = versions[versions.length - 1];

if (process.argv[2] === '--id') {
  process.stdout.write(aliases[latestAlias] + '\n');
} else {
  process.stdout.write(latestAlias + '\n');
}
