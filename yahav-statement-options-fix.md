# Fix: Yahav `fetchData` page-ready sentinel

## What was broken

`fetchData()` in the published package (`israeli-bank-scrapers@6.7.3`) used
`.statement-options .selected-item-top` as a page-ready sentinel after clicking
`.account-details`:

```js
await clickButton(this.page, ACCOUNT_DETAILS_SELECTOR);
await waitUntilElementFound(
  this.page,
  ".statement-options .selected-item-top",
  true,
); // timed out
```

moneyman reported: `Waiting for selector '.statement-options .selected-item-top' failed`.

## Wrong initial analysis

An earlier investigation hypothesized that the selector failed because the scraper
blocks `detector-dom.min.js` (bot-detection), which prevents an Angular component
from initializing, which in turn prevents `.statement-options` from rendering.

**This was wrong.** Live testing with Puppeteer showed:

- The `Cannot read properties of null (reading 'querySelector')` console error
  appears in a real browser too — it is a pre-existing Yahav bug unrelated to
  bot-detection blocking.
- Despite the error, `.statement-options .selected-item-top` **does** appear in
  the DOM (count: 1, visible: true) within a few seconds of navigation.

## Actual root cause

The published `fetchData` in 6.7.3 calls `waitUntilElementFound` immediately after
`clickButton`, before Angular has navigated to the accounts page and rendered the
template. The selector simply does not exist yet when the wait starts. Whether it
eventually appears depends on timing and environment — fast enough locally, but
reliably too slow in moneyman's environment.

`FROM_PICKER` (`date-picker-access[btn-label="from"] a.datepicker-button`) is
rendered earlier in the page lifecycle (it is a standalone Angular directive,
compiled independently of the accounts component), making it a more reliable
sentinel.

## The fix

```js
// Before
await waitUntilElementFound(
  this.page,
  ".statement-options .selected-item-top",
  true,
);

// After
await waitUntilElementFound(
  this.page,
  `${FROM_PICKER} a.datepicker-button`,
  true,
);
```

`FROM_PICKER` is already defined in 6.7.3 and used in `searchByDates`, so no
additional constant is needed.

## What was applied to the patch file

`patches/israeli-bank-scrapers+6.7.3.patch` in moneyman is a cumulative patch
against the clean 6.7.3 package. It includes:

- **Previous patch** — account ID selector hardening, full `searchByDates`
  rewrite (replaced the old `.pmu-*` calendar selectors with the current
  `date-picker-access` directive), `startMoment` clamping to today, and an
  unrelated `base-isracard-amex.js` random login delay.
- **This fix** — the one-line sentinel change in `fetchData` described above.

The new patch file supersedes the old one.
