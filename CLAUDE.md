# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Moneyman is a TypeScript application that automatically scrapes transactions from Israeli banks and credit card companies, then exports them to various storage systems (Google Sheets, Azure Data Explorer, YNAB, Buxfer, Actual Budget, and more). It uses the `israeli-bank-scrapers` library for data extraction and runs on Node.js 20+.

## Development Commands

### Build and Development

- `npm run build` - Compile TypeScript to JavaScript (outputs to `dst/`)
- `npm start` - Run the compiled application
- `npm run start:container` - Run using Docker Compose

### Code Quality

- `npm run lint` - Check code formatting with Prettier
- `npm run lint:fix` - Fix code formatting issues
- `npm test` - Run Jest unit tests
- `npm test:scraper-access` - Run scraper access tests (separate config)

### Other

- `npm run postinstall` - Apply patches (runs automatically after install)

## Architecture Overview

### Core Flow

1. **Entry Point** (`src/index.ts`): Main orchestrator that handles uncaught exceptions and coordinates the scraping process
2. **Configuration** (`src/config.ts`): Parses environment variables and account configurations
3. **Scraper** (`src/scraper/`): Manages browser instances and coordinates parallel account scraping
4. **Storage** (`src/bot/storage/`): Handles saving transactions to various external services
5. **Bot Integration** (`src/bot/`): Telegram notifications and progress reporting

### Key Components

#### Scraper Architecture

- Uses Puppeteer with secure browser contexts per company
- Supports parallel scraping (configurable via `MAX_PARALLEL_SCRAPERS`)
- Implements security features like domain whitelisting and connection monitoring
- Handles failure screenshots and retry logic

#### Storage System

- Modular storage adapters in `src/bot/storage/` (each implements `TransactionStorage` interface)
- Parallel saving to all configured storages
- Progress tracking with Telegram notifications
- Built-in storage types: JSON, Google Sheets, Azure Data Explorer, YNAB, Buxfer, Web POST, Telegram, Actual Budget

#### Security Features

- Domain tracking and whitelisting (`src/security/`)
- Firewall rules per company/scraper
- Connection monitoring for suspicious activity
- Secure credential handling through environment variables

### Data Flow

1. Parse account configs from `ACCOUNTS_JSON` environment variable
2. Create secure browser contexts per company
3. Scrape transactions using israeli-bank-scrapers
4. Transform to internal `TransactionRow` format with hashing
5. Save to all configured storage systems in parallel
6. Report progress via Telegram

## Configuration

### Required Environment Variables

- `ACCOUNTS_JSON`: Array of account configurations with credentials
- Storage-specific vars (e.g., `GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY`, `YNAB_TOKEN`)
- `TELEGRAM_API_KEY` & `TELEGRAM_CHAT_ID` for notifications

### Optional Configuration

- `DAYS_BACK`: Days to scrape (default: 10)
- `FUTURE_MONTHS`: Months ahead to scrape
- `MAX_PARALLEL_SCRAPERS`: Parallel scraper limit (default: 1)
- `FIREWALL_SETTINGS`: Domain whitelisting rules
- `DOMAIN_TRACKING_ENABLED`: Enable domain access tracking

## Testing

- Unit tests use Jest with ts-jest preset
- Separate test config for scraper access tests (`jest.scraper-access.config.js`)
- Tests located in `src/` alongside source files
- Snapshots stored in `__snapshots__/` directories

## TypeScript Configuration

- Targets ES2022 with ESNext modules
- Outputs to `dst/` directory with source maps
- Strict null checks enabled
- Uses Node module resolution

## Important Notes

- This application handles sensitive financial data and credentials
- Always use proper secret management for environment variables
- The codebase assumes secure, trusted execution environments
- Domain security features should be enabled in production
- Husky pre-commit hooks run prettier for code formatting
