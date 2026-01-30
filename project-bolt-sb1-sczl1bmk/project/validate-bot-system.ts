/**
 * Bot System Validation Script
 *
 * Run this to check if your bot system is properly configured
 *
 * Usage: npx tsx validate-bot-system.ts
 */

import { createClient } from '@supabase/supabase-js';

const REQUIRED_ENV_VARS = [
  'VITE_SUPABASE_URL',
  'VITE_SUPABASE_ANON_KEY',
  'VITE_STRIPE_PRICE_STARTER',
  'VITE_STRIPE_PRICE_CORE',
  'VITE_STRIPE_PRICE_PRO',
];

const OPTIONAL_ENV_VARS = [
  'VITE_STRIPE_PRICE_DFY',
  'VITE_STRIPE_ADDON_WEBINAR',
  'VITE_STRIPE_ADDON_VOICE',
  'VITE_STRIPE_ADDON_SOCIAL',
];

interface ValidationResult {
  category: string;
  status: 'pass' | 'fail' | 'warning';
  message: string;
}

async function validateSystem(): Promise<ValidationResult[]> {
  const results: ValidationResult[] = [];

  console.log('🔍 Validating FrontDesk AI Pro Bot System...\n');

  // Check environment variables
  console.log('1. Checking Environment Variables...');
  for (const varName of REQUIRED_ENV_VARS) {
    if (process.env[varName]) {
      results.push({
        category: 'Environment',
        status: 'pass',
        message: `✅ ${varName} is set`,
      });
    } else {
      results.push({
        category: 'Environment',
        status: 'fail',
        message: `❌ ${varName} is missing`,
      });
    }
  }

  for (const varName of OPTIONAL_ENV_VARS) {
    if (process.env[varName]) {
      results.push({
        category: 'Environment',
        status: 'pass',
        message: `✅ ${varName} is set`,
      });
    } else {
      results.push({
        category: 'Environment',
        status: 'warning',
        message: `⚠️  ${varName} is missing (optional)`,
      });
    }
  }

  // Check Supabase connection
  console.log('\n2. Checking Supabase Connection...');
  try {
    const supabase = createClient(
      process.env.VITE_SUPABASE_URL!,
      process.env.VITE_SUPABASE_ANON_KEY!
    );

    const { data, error } = await supabase.from('workspaces').select('count').limit(1);

    if (error) {
      results.push({
        category: 'Database',
        status: 'fail',
        message: `❌ Supabase connection failed: ${error.message}`,
      });
    } else {
      results.push({
        category: 'Database',
        status: 'pass',
        message: '✅ Supabase connection successful',
      });
    }
  } catch (error: any) {
    results.push({
      category: 'Database',
      status: 'fail',
      message: `❌ Supabase connection error: ${error.message}`,
    });
  }

  // Check required tables
  console.log('\n3. Checking Database Tables...');
  const requiredTables = [
    'workspaces',
    'leads',
    'messages',
    'bot_types',
    'workspace_bots',
    'automation_jobs',
    'checkout_sessions',
  ];

  try {
    const supabase = createClient(
      process.env.VITE_SUPABASE_URL!,
      process.env.VITE_SUPABASE_ANON_KEY!
    );

    for (const table of requiredTables) {
      try {
        const { error } = await supabase.from(table).select('count').limit(1);
        if (error) {
          results.push({
            category: 'Database',
            status: 'fail',
            message: `❌ Table '${table}' not accessible: ${error.message}`,
          });
        } else {
          results.push({
            category: 'Database',
            status: 'pass',
            message: `✅ Table '${table}' exists and accessible`,
          });
        }
      } catch (err: any) {
        results.push({
          category: 'Database',
          status: 'fail',
          message: `❌ Table '${table}' check failed: ${err.message}`,
        });
      }
    }
  } catch (error: any) {
    results.push({
      category: 'Database',
      status: 'fail',
      message: `❌ Database validation error: ${error.message}`,
    });
  }

  // Check Edge Functions
  console.log('\n4. Checking Edge Functions...');
  const edgeFunctions = [
    'ai-chat',
    'bot-orchestrator',
    'stripe-webhook',
    'automation-runner',
  ];

  for (const func of edgeFunctions) {
    const url = `${process.env.VITE_SUPABASE_URL}/functions/v1/${func}`;
    try {
      const response = await fetch(url, {
        method: 'OPTIONS',
        headers: {
          'Authorization': `Bearer ${process.env.VITE_SUPABASE_ANON_KEY}`,
        },
      });

      if (response.ok || response.status === 200) {
        results.push({
          category: 'Edge Functions',
          status: 'pass',
          message: `✅ Function '${func}' is deployed`,
        });
      } else {
        results.push({
          category: 'Edge Functions',
          status: 'warning',
          message: `⚠️  Function '${func}' returned ${response.status}`,
        });
      }
    } catch (error: any) {
      results.push({
        category: 'Edge Functions',
        status: 'fail',
        message: `❌ Function '${func}' unreachable: ${error.message}`,
      });
    }
  }

  return results;
}

// Run validation
validateSystem().then((results) => {
  console.log('\n' + '='.repeat(60));
  console.log('VALIDATION SUMMARY');
  console.log('='.repeat(60) + '\n');

  const passed = results.filter(r => r.status === 'pass').length;
  const failed = results.filter(r => r.status === 'fail').length;
  const warnings = results.filter(r => r.status === 'warning').length;

  // Group by category
  const categories = ['Environment', 'Database', 'Edge Functions'];

  for (const category of categories) {
    const categoryResults = results.filter(r => r.category === category);
    if (categoryResults.length > 0) {
      console.log(`\n${category}:`);
      categoryResults.forEach(r => console.log(`  ${r.message}`));
    }
  }

  console.log('\n' + '='.repeat(60));
  console.log(`✅ Passed: ${passed}`);
  console.log(`⚠️  Warnings: ${warnings}`);
  console.log(`❌ Failed: ${failed}`);
  console.log('='.repeat(60));

  if (failed > 0) {
    console.log('\n❌ SYSTEM NOT READY - Fix errors above before going live');
    process.exit(1);
  } else if (warnings > 0) {
    console.log('\n⚠️  SYSTEM PARTIALLY READY - Some optional features missing');
    process.exit(0);
  } else {
    console.log('\n✅ SYSTEM READY - All checks passed!');
    process.exit(0);
  }
}).catch((error) => {
  console.error('\n❌ Validation script failed:', error);
  process.exit(1);
});
