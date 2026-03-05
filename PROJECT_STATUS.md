# CommsHub - Project Status Assessment

**Date:** 2026-03-05
**Branch:** `claude/assess-project-status-P2ADt`

---

## Overview

CommsHub is a **Rails 8.1** multi-channel announcement platform that enables organizations to create, schedule, and deliver announcements via **Slack**, **Email**, and **WhatsApp**. It uses Devise for authentication, PostgreSQL for persistence, and Solid Queue/Cache/Cable for background processing.

**Tech stack:** Ruby 3.3.4, Rails 8.1, PostgreSQL, Hotwire (Turbo + Stimulus), React (selected components via importmap), Propshaft, Docker/Kamal, Devise, OpenAI API (AI rewriting).

---

## Architecture Summary

### Models (10 Active Record models)
| Model | Purpose |
|---|---|
| `User` | Devise-authenticated users with role-based access (admin/regular) |
| `Announcement` | Core entity - announcements with status workflow (draft > scheduled > sending > sent/failed) |
| `Audience` (STI base) | Polymorphic audience base with scope types: personal, role, system |
| `SlackAudience` | Slack channel audience (stores `slack_channel`) |
| `EmailAudience` | Email list audience (stores `email_recipients` as text) |
| `WhatsappAudience` | WhatsApp audience (stores `whatsapp_recipients` as text) |
| `AnnouncementAudience` | Join table: announcements <-> audiences |
| `DeliveryLog` | Per-recipient delivery tracking (channel, destination, status, details) |
| `IntegrationSetting` | Encrypted provider config (OpenAI, Slack, WhatsApp, Email/SMTP) |
| `Group` / `GroupMembership` | Legacy group model (appears unused in current flows) |

### Services (3)
- **`SlackAnnouncementSender`** - Posts to Slack via `slack-ruby-client`
- **`WhatsappAnnouncementSender`** - Sends via WhatsApp Cloud API (Meta Graph API v18.0)
- **`AnnouncementAiRewriter`** - Uses OpenAI to generate channel-tailored versions of announcements

### Jobs (1)
- **`SendAnnouncementJob`** - Orchestrates multi-channel delivery with per-recipient error handling and delivery logging

### Controllers (8)
- `AnnouncementsController` - Full CRUD + schedule/cancel/send_now actions
- `SlackAudiencesController`, `EmailAudiencesController`, `WhatsappAudiencesController` - Audience CRUD per channel type
- `IntegrationsController` - Provider config management with test-connection support
- `SettingsController`, `HelpController`, `HomeController` - Static/utility pages

### Frontend
- Server-rendered ERB views with Hotwire (Turbo + Stimulus)
- React components via importmap for interactive elements: `AiImproveButton`, `AudienceScopeToggle`, `AudienceTypeToggle`, `ChannelAudienceToggler`, `RoleSelector`, `TestConnectionButton`
- CSS + SVG icons (custom icon sprite)

---

## Feature Completeness

### Fully Implemented
- Announcement CRUD with draft/schedule/send workflow
- Multi-channel delivery (Slack, Email, WhatsApp) with per-recipient logging
- AI-powered announcement rewriting (OpenAI) that tailors content per channel
- Audience management with STI (Slack channels, email lists, WhatsApp lists)
- Role-based audience scoping (personal, role-based, system-wide)
- Admin authorization via `Authorizable` concern
- Integration settings management with encrypted config, test-connection, and masked secrets
- Delivery logging with unique constraint per announcement/channel/destination
- Scheduled announcements via Solid Queue delayed jobs
- Devise authentication with public sign-up disabled
- Bulk CSV user import for admins
- Docker deployment (Dockerfile + Kamal hooks)
- CI pipeline (GitHub Actions: security scans, linting, unit tests, system tests)

### Partially Implemented / Gaps
- **`Group` / `GroupMembership` models** exist with migrations but appear unused in current controllers/views - likely legacy or planned feature
- **`AnnouncementTarget`** (join to groups) exists but is not used in the delivery flow
- **README.md** is the default Rails scaffold - no project-specific documentation
- **`body` column** on announcements table appears unused (superseded by `base_body` + channel-specific bodies)
- **No pagination** on announcement or audience index pages
- **No email delivery test** in integration settings (Slack and WhatsApp have test endpoints; email has routes but unclear implementation)

---

## Test Coverage

**15 test files** across models, controllers, and services:
- 9 model tests (Announcement, Audience, User, Group, DeliveryLog, etc.)
- 5 controller tests (Announcements, Audiences per channel type)
- 1 service test (WhatsappAnnouncementSender)

**Missing test coverage:**
- `SlackAnnouncementSender` service
- `AnnouncementAiRewriter` service
- `IntegrationsController`
- `SendAnnouncementJob`
- `UsersController` (bulk import)
- System/integration tests (capybara configured but no test files found)

---

## CI/CD & Deployment

- **CI:** GitHub Actions with 4 jobs: Ruby security scan (Brakeman + bundler-audit), JS audit (importmap), RuboCop linting, unit + system tests against PostgreSQL
- **Deployment:** Docker-based with Kamal hooks. Dockerfile uses multi-stage build with Node.js for esbuild, jemalloc for memory optimization. Heroku container deployment also configured (`heroku.yml`)
- **SSL** forced in production

---

## Code Quality Observations

**Strengths:**
- Clean separation of concerns (controllers, services, jobs)
- Encrypted integration settings at rest (Active Record encryption)
- Per-recipient delivery logging with unique constraints prevents duplicates
- Authorization logic properly extracted to concern
- STI for audiences keeps the model hierarchy clean

**Areas for Improvement:**
- `SendAnnouncementJob` has a potential race condition: it marks status as "sent" even if some individual deliveries failed (only the rescue block marks "failed")
- `AnnouncementsController#create` saves with `validate: false` for AI improvement flow - could leave orphaned invalid records
- Integration routes could be refactored to use RESTful resources instead of manual route definitions
- The stale-scheduled-job guard in `SendAnnouncementJob` (lines 11-14) skips jobs that are still in the future, which is correct, but there's no mechanism to reschedule if a job fires early
- `Group`/`GroupMembership`/`AnnouncementTarget` models should either be completed or removed to reduce confusion

---

## Summary

CommsHub is a **functional multi-channel announcement platform** with core features working end-to-end. The main delivery pipeline (create > AI rewrite > schedule/send > Slack/Email/WhatsApp delivery > logging) is complete. The application has reasonable test coverage for core models and controllers, a working CI pipeline, and production deployment infrastructure.

**Recommended next steps:**
1. Clean up unused `Group`/`GroupMembership`/`AnnouncementTarget` models or implement group-based targeting
2. Add missing test coverage (services, jobs, integrations controller)
3. Fix `SendAnnouncementJob` to mark as "failed" when any delivery errors occur (partial failure handling)
4. Add pagination to index pages
5. Replace default README with project documentation
6. Remove unused `body` column from announcements table
