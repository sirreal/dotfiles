# Repro strategies (detailed)

## phpunit

The default and fastest WP test runner. Located at `vendor/bin/phpunit` after envlite init.

### Running

- All tests in a class: `vendor/bin/phpunit tests/phpunit/tests/dependencies/scripts.php`
- Filter by test name: `vendor/bin/phpunit --filter METHOD_NAME`
- By group: `vendor/bin/phpunit --group GROUP_NAME` (e.g. `dependencies`, `scripts`, `multisite`)
- Multisite: `vendor/bin/phpunit -c tests/phpunit/multisite.xml`

### Writing tests

Conventions:
- Class extends `WP_UnitTestCase`.
- Method names start with `test_`.
- Use `@ticket NNNNN` and `@covers ::function_name` PHPDoc tags.
- Tests live in `tests/phpunit/tests/AREA/TOPIC.php`.

### Output capture

Use the `get_echo()` helper from `tests/phpunit/includes/utils.php`:

```php
$output = get_echo( 'wp_print_footer_scripts' );
```

`get_echo( $callable )` calls the function and captures its echoed output via output buffering.

### WP_Scripts test isolation

The `Tests_Dependencies_Scripts` class in `tests/phpunit/tests/dependencies/scripts.php` has a `set_up()` that:
- Resets `$GLOBALS['wp_scripts']` to a fresh `WP_Scripts()` instance.
- Removes the `wp_default_scripts` action (so default handles are NOT registered automatically).

For tests that exercise script-loader behavior, place them in this class — and register handles explicitly:

```php
wp_register_script( 'jquery-ui-datepicker', '/handle.js', array(), '1.13.3', true );
```

The 5th argument `true` (or `array( 'in_footer' => true )`) places the handle in the footer group.

## qunit

WordPress JS test runner.

### Running

From the worktree root:

```bash
grunt qunit:compiled
```

For specific test files, consult `Gruntfile.js` qunit targets.

In the browser (for interactive debugging): after `envlite up`, navigate via a browser MCP to `http://127.0.0.1:PORT/tests/qunit/index.html`.

qunit tests live in `tests/qunit/`. They use jQuery QUnit conventions: `QUnit.test(...)`, `QUnit.module(...)`.

## Browser MCP

For browser-driven repro of UI behavior. Any MCP that drives a real browser works (Playwright MCP is one such tool); pick whichever is available in the session. The exact tool names below are capabilities, not specific MCP function names — map them to whatever the active browser MCP exposes.

### Setup

1. Start envlite dev server backgrounded:

```bash
php ~/a8c/wordpress-develop/add-envlite-tool/tools/local-env/envlite.php up --force
```

Run via the Bash tool with `run_in_background: true`.

2. Read the port:

```bash
cat .envlite/port
```

3. Navigate to `http://127.0.0.1:PORT/` via the browser MCP's navigate capability.
4. Admin login (`admin` / `password`) at `/wp-login.php` when admin UI is needed.

### Observe before inspecting

The ticket's symptom is what a user sees. Reproduce that user-visible artifact first — the rendered text, layout, option list, focus state, or screenshot the ticket describes. Capture it with the browser MCP's accessibility-snapshot and screenshot capabilities. Only after the symptom is reproduced should JS-evaluation or console-message capabilities be used, and then only to diagnose *why*.

Reading internal framework state (e.g. `wp.data.select('core/editor').getEditorSettings().availableTemplates`, a Redux store) to argue what the user *would* see is not a substitute for observation. The repro-evidence rule is "X ≈ Y because Z," where X is the ticket's claim about user-visible behavior. If Y is internal state and Z is "source code says it renders unchanged," the chain has a hidden link — the rendering pipeline — that may transform the data in ways the source-skim missed.

Concrete check: before any JS evaluation against a framework store, confirm at least one accessibility snapshot or screenshot of the specific UI surface the ticket describes has been taken. If not, finish the UI interaction first. A failed attempt to find the right UI control (e.g. scanning `document.querySelectorAll('button')` and not finding the right text) is a signal to keep navigating — open the right panel, scroll, take an accessibility snapshot — not to pivot to data inspection.

### Browser MCP capabilities, ordered by purpose

Every browser MCP exposes roughly the same surface; tool names vary. Map these capabilities to whatever functions the active MCP provides.

**Observation (use these first):**
- Accessibility snapshot — structured UI tree; primary observation tool.
- Screenshot — visual capture at decision points.

**Interaction:**
- Navigate to URL.
- Click / fill form / press key — drive the UI to the state the ticket describes.

**Diagnosis (after the symptom has been observed):**
- Console messages — read browser console output.
- Network requests — read network activity.
- Evaluate JS in page — inspect framework state and DOM.

When repro is complete via the browser MCP, the captured manual recipe (URLs + click sequence + observed behavior, with screenshot or accessibility-snapshot evidence) becomes the report's `verification` field.

## Reproducing from ticket snippets

When a ticket includes PHP code meant to reproduce the bug (typically to drop into a plugin or mu-plugin), treat it as suspect input, not a working recipe. If the snippet throws a fatal error or has no visible effect, fix it first. **A broken snippet is not evidence the bug is absent.** Only after the snippet runs cleanly can its output be compared against the ticket's claim.

When the bug is surfaced through a concrete admin URL or front-end request:

1. Drop the sanity-checked snippet into `src/wp-content/mu-plugins/trac-<ticket>-repro.php` (gitignored — won't be committed).
2. Force any required theme/state via `pre_option_*` filters in the same mu-plugin (e.g. `pre_option_stylesheet`, `pre_option_template`) to avoid navigating through admin screens.
3. Drive the URL via the browser MCP. Observe the rendered UI through an accessibility snapshot or screenshot of the surface the ticket describes; querying specific elements / inline styles / network requests is fine for diagnosis but does not substitute for that observation. See "Observe before inspecting" above.
4. Compare against the ticket's claim. This is the strongest form of `repro evidence` because it goes through the real codepath rather than a synthesized call sequence.

## Escalation

Escalate from cheaper strategies only when the ticket signal is ambiguous:

- phpunit returned no failure AND the ticket signal was ambiguous → try qunit (if JS-adjacent) or a browser MCP (if UI-adjacent).
- phpunit returned no failure AND the ticket signal pointed clearly at PHP → this is strong NOT-REPRODUCIBLE evidence; do not fishing-expedition. Add a probe to the codepath the ticket describes and confirm execution.

## Probes (for NOT-REPRODUCIBLE evidence)

To gather affirmative evidence the bug is absent, instrument the codepath the ticket describes:

```php
// Temporary, before committing — remove before commit.
error_log( 'PROBE_50040: reached ' . __LINE__ . ' with $var=' . var_export( $var, true ) );
```

Then trigger the conditions in the ticket. Read `wp-content/debug.log` (after `define( 'WP_DEBUG', true )` and `define( 'WP_DEBUG_LOG', true )`) or the PHP error log. If the probe fires and the surrounding logic produced the expected output, NOT-REPRODUCIBLE is justified.

Remove all probes before committing the fix branch.
