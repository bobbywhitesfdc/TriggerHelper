/**
 * Reads sf apex run test JSON output from stdin.
 * Exits 0 if all failures are outside the package test classes.
 * Exits 1 if any package-owned test class failed.
 * Prints a summary either way.
 */
const PACKAGE_TEST_CLASSES = [
  'AbstractBasePETriggerHelperTest',
  'AbstractBaseTriggerHandlerTest',
  'AbstractBaseTriggerHelperTest',
  'DesignByContractUtilTest',
  'LoggingUtilityTest',
  'LookupDataHandlerTest',
  'QueryTopicFactoryTest',
  'StandardPlatformEventTriggerHandlerTest',
  'StandardSObjectTriggerHandlerTest',
  'TestTriggerHelperHarnessTest',
  'TriggerDispatcherTest',
  'TriggerDMLHandlerTest',
  'TriggerHelperFactoryTest',
];

const raw = require('fs').readFileSync('/dev/stdin', 'utf8');
const results = JSON.parse(raw);

const tests = results?.result?.tests || [];
const failures = tests.filter(t => t.Outcome === 'Fail');

if (failures.length === 0) {
  console.log('✅ All tests passed.');
  process.exit(0);
}

const packageFailures = failures.filter(t =>
  PACKAGE_TEST_CLASSES.includes(t.ApexClass?.Name)
);
const externalFailures = failures.filter(t =>
  !PACKAGE_TEST_CLASSES.includes(t.ApexClass?.Name)
);

if (externalFailures.length > 0) {
  console.log(`ℹ️  ${externalFailures.length} failure(s) in non-package classes (ignored):`);
  externalFailures.forEach(t => console.log(`   ${t.ApexClass?.Name}.${t.MethodName}`));
}

if (packageFailures.length > 0) {
  console.log(`❌ ${packageFailures.length} failure(s) in package-owned test classes:`);
  packageFailures.forEach(t => {
    console.log(`   ${t.ApexClass?.Name}.${t.MethodName}`);
    console.log(`   ${t.Message}`);
  });
  process.exit(1);
}

console.log('✅ No package-owned test failures. External failures ignored.');
process.exit(0);
