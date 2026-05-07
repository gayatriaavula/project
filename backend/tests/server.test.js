const { test } = require('node:test');
const assert = require('node:assert');

test('express dependency is available', () => {
  const express = require('express');
  assert.strictEqual(typeof express, 'function');
});

test('mysql2 dependency is available', () => {
  const mysql = require('mysql2');
  assert.ok(mysql);
});
