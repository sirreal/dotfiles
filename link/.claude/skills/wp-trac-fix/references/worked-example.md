# Worked example — Trac #50040

A complete walkthrough of the workflow against ticket #50040 (Localize the jQuery datepicker when enqueued in the footer).

## Phase 0 — Setup

```bash
git fetch upstream
git worktree add ~/a8c/wordpress-develop/agent-fixes/50040 \
  -b fix/50040-datepicker-footer-l10n upstream/trunk
cd ~/a8c/wordpress-develop/agent-fixes/50040
php ~/a8c/wordpress-develop/add-envlite-tool/tools/local-env/envlite.php init --force
```

envlite init takes roughly 2–3 minutes on first run (npm ci + build:dev + composer install).

## Phase A — Read the ticket

**Description:** `wp_localize_jquery_ui_datepicker` was attached only to `wp_enqueue_scripts` / `admin_enqueue_scripts`. The reporter proposed also attaching it to `wp_print_footer_scripts:9` / `admin_print_footer_scripts:9`.

**Comments included two "reproduction reports" (#3 and #5) claiming the bug did NOT reproduce.** Critical reading: both commenters tested enqueueing during `wp_enqueue_scripts` with `in_footer=true`. That scenario works because the script is enqueued by the time priority 1000 fires. The real failure mode is **late enqueueing** during `wp_footer` callbacks, which neither commenter tested.

**Lesson:** do not trust commenter conclusions until verifying which scenario they tested.

## Phase B — Reproduce

Strategy from the matrix: `PHP API behavior` → phpunit.

The test reproduces the late-enqueue case by registering + enqueueing `jquery-ui-datepicker` without firing `wp_enqueue_scripts`, then capturing `wp_print_footer_scripts` output:

```php
/**
 * @ticket 50040
 *
 * @covers ::wp_localize_jquery_ui_datepicker
 */
public function test_wp_localize_jquery_ui_datepicker_when_enqueued_for_footer() {
    wp_register_script( 'jquery-ui-datepicker', '/jquery-ui-datepicker.js', array(), '1.13.3', true );
    wp_enqueue_script( 'jquery-ui-datepicker' );
    $output = get_echo( 'wp_print_footer_scripts' );
    $this->assertStringContainsString( 'jQuery.datepicker.setDefaults', $output );
}
```

Added to `tests/phpunit/tests/dependencies/scripts.php` (the class with `set_up()` that resets `$GLOBALS['wp_scripts']`).

Run:

```bash
vendor/bin/phpunit --filter test_wp_localize_jquery_ui_datepicker_when_enqueued_for_footer
```

Result: **FAIL** — the script tag prints in the footer, but no `jQuery.datepicker.setDefaults` inline.

**Repro evidence:** Ticket reports footer-enqueued datepicker not localized; my repro shows the script printed without the inline localization. Equivalent.

Classification: **REPRODUCED**.

## Phase C — Fix

Hook the localize function to the footer print actions in `src/wp-includes/default-filters.php`:

```php
add_action( 'wp_enqueue_scripts', 'wp_localize_jquery_ui_datepicker', 1000 );
add_action( 'wp_print_footer_scripts', 'wp_localize_jquery_ui_datepicker', 9 );  // NEW
add_action( 'wp_enqueue_scripts', 'wp_common_block_scripts_and_styles' );
add_action( 'wp_enqueue_scripts', 'wp_enqueue_classic_theme_styles' );
add_action( 'admin_enqueue_scripts', 'wp_localize_jquery_ui_datepicker', 1000 );
add_action( 'admin_print_footer_scripts', 'wp_localize_jquery_ui_datepicker', 9 );  // NEW
```

Priority 9 ensures the hook runs before `_wp_footer_scripts` at priority 10 (which prints the scripts), so `wp_add_inline_script` data is added to the buffer in time.

Re-run test: **PASS**.

Regression check: `vendor/bin/phpunit --group dependencies` → OK (353 tests, 929 assertions).

Diff: 26 lines (2 in source, 24 in test). Well under the 100-line cap.

## Phase D — Commit and report

Stage files explicitly:

```bash
git add src/wp-includes/default-filters.php tests/phpunit/tests/dependencies/scripts.php
```

Critically, `git add -A` would include `.envlite/`, which must not be committed.

Commit:

```
I18N: Localize jQuery UI datepicker when enqueued for the footer.

The wp_localize_jquery_ui_datepicker function was attached only to the
wp_enqueue_scripts and admin_enqueue_scripts actions. When a theme or
plugin enqueued jquery-ui-datepicker after those actions had already
fired (e.g. from a wp_footer callback), the script printed in the
footer but no localization was emitted.

Hook wp_localize_jquery_ui_datepicker to wp_print_footer_scripts:9
and admin_print_footer_scripts:9 as well, so late-enqueued datepicker
scripts get localized before the footer scripts print.

See #50040.
```

## Lessons captured

1. `envlite init` ran `npm ci` + `build:dev` for a phpunit-only ticket — minutes wasted. Future enhancement: a `--phpunit-only` envlite mode that skips Phases 2 and 3.
2. Trac comments must be read critically. "Reproduction reports" may have tested adjacent scenarios, not the actual bug.
3. The mandatory repro-evidence statement caught the real-vs-tested mismatch in recent comments.
4. Always `git add` files explicitly to avoid committing `.envlite/`.
