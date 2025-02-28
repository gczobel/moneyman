import "dotenv/config";
import { subDays } from "date-fns";
import { AccountConfig, ScraperConfig } from "./types.js";
import { createLogger, logToPublicLog } from "./utils/logger.js";

export const systemName = "moneyman";
const logger = createLogger("config");

logger("Parsing config");
logToPublicLog("Parsing config");

const {
  DAYS_BACK,
  ACCOUNTS_TO_SCRAPE = "",
  FUTURE_MONTHS = "",
  YNAB_TOKEN = "",
  YNAB_BUDGET_ID = "",
  YNAB_ACCOUNTS = "",
  BUXFER_USER_NAME = "",
  BUXFER_PASSWORD = "",
  BUXFER_ACCOUNTS = "",
  TRANSACTION_HASH_TYPE = "",
  WEB_POST_URL = "",
  MAX_PARALLEL_SCRAPERS = "",
} = process.env;

/**
 * Add default values in case the value is falsy (0 is not valid here) or an empty string
 */
export const daysBackToScrape = DAYS_BACK || 10;
export const worksheetName = WORKSHEET_NAME || "_moneyman";
export const futureMonthsToScrape = parseInt(FUTURE_MONTHS, 10);
export const systemTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
export const parallelScrapers = MAX_PARALLEL_SCRAPERS || 1;

logger("env vars", {
  DAYS_BACK,
  ACCOUNTS_TO_SCRAPE,
  FUTURE_MONTHS,
  MAX_PARALLEL_SCRAPERS,
});

function getAccounts(): Array<AccountConfig> {
  function parseAccounts(accountsJson?: string): Array<AccountConfig> {
    try {
      const parsed = JSON.parse(accountsJson!);
      if (Array.isArray(parsed)) {
        // TODO: Add schema validations?
        return parsed as Array<AccountConfig>;
      }
    } catch {}

    throw new TypeError("ACCOUNTS_JSON must be a valid array");
  }

  const allAccounts = parseAccounts(process.env.ACCOUNTS_JSON);
  const accountsToScrape = ACCOUNTS_TO_SCRAPE.split(",")
    .filter(Boolean)
    .map((a) => a.trim());

  return accountsToScrape.length == 0
    ? allAccounts
    : allAccounts.filter((account) =>
        accountsToScrape.includes(account.companyId),
      );
}

export const scraperConfig: ScraperConfig = {
  accounts: getAccounts(),
  startDate: subDays(Date.now(), Number(DAYS_BACK || 10)),
  parallelScrapers: Number(MAX_PARALLEL_SCRAPERS) || 1,
  futureMonthsToScrape: parseInt(FUTURE_MONTHS, 10),
};
