# Fix visaCal change password detection

## Problem

When a visaCal user's password needs to be changed, the Cal website shows an error popup after login with the message:

> לא נוכל להמשיך
> כדי להחליף סיסמה יש ללחוץ על 'שכחתי שם משתמש / סיסמה' במסך הכניסה

The scraper fails to detect this and returns a `TIMEOUT` error instead of the expected `CHANGE_PASSWORD` error.

## Root cause

The `hasChangePasswordForm()` function in `src/scrapers/visa-cal.ts` checks for the CSS selector `.change-password-subtitle`, which no longer exists in Cal's login page. The password change prompt now uses a different UI — an `<error>` component with the class `.err-desc` containing the password change message.

## Changes

In `src/scrapers/visa-cal.ts`:

### 1. Add a constant for the change password message

```typescript
const ChangePasswordMessage = "להחליף סיסמה";
```

Add it next to the existing `InvalidPasswordMessage` constant.

### 2. Update `hasChangePasswordForm()`

Replace:

```typescript
async function hasChangePasswordForm(page: Page) {
  const frame = await getLoginFrame(page);
  const errorFound = await elementPresentOnPage(
    frame,
    ".change-password-subtitle",
  );
  return errorFound;
}
```

With:

```typescript
async function hasChangePasswordForm(page: Page) {
  const frame = await getLoginFrame(page);
  // "כדי להחליף סיסמה יש ללחוץ על 'שכחתי שם משתמש / סיסמה' במסך הכניסה"
  const errorFound = await elementPresentOnPage(frame, ".err-desc");
  if (errorFound) {
    const errText = await pageEval(frame, ".err-desc", "", (item) => {
      return (item as HTMLElement).innerText.trim();
    });
    return errText.includes(ChangePasswordMessage);
  }
  return false;
}
```

## Why check the text content

The `.err-desc` selector is a generic error description element. To avoid false positives from other error types, we check that the text includes "להחליף סיסמה" (to change password) before returning `CHANGE_PASSWORD`.

## Reference: error popup HTML

```html
<error _nghost-goo-c86="" class="ng-star-inserted">
  <div _ngcontent-goo-c86="" class="err-wrapper">
    <img
      _ngcontent-goo-c86=""
      alt=""
      class="err-img"
      src="./assets/images/konus.svg"
    />
    <div _ngcontent-goo-c86="" class="err-title">לא נוכל להמשיך</div>
    <div _ngcontent-goo-c86="" class="err-desc">
      כדי להחליף סיסמה יש ללחוץ על 'שכחתי שם משתמש / סיסמה' במסך הכניסה
    </div>
    <div _ngcontent-goo-c86="">
      <button
        _ngcontent-goo-c86=""
        mat-raised-button=""
        color="accent"
        class="mat-focus-indicator err-btn mat-raised-button mat-button-base mat-accent"
      >
        <span class="mat-button-wrapper"
          ><span _ngcontent-goo-c86="">הבנתי, תודה</span></span
        >
      </button>
    </div>
  </div>
</error>
```

## Tested

Verified with a real visaCal account that requires a password change. Before the fix, the scraper returned `TIMEOUT`. After the fix, it correctly returns `CHANGE_PASSWORD`.
