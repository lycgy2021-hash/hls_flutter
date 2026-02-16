# MIGRATION_REPORT

## 1) Scope and baseline
- Source app: Vue3 + Vite + Pinia + TypeScript short-video app in `src/`.
- Target app: Flutter (GetX only for state + DI + routing), production-oriented M0-M2 deliverable.
- Date: 2026-02-17.
- Mandatory constraints applied:
  - API compatibility first (endpoint/path/params/pagination/header/response fields).
  - Stable identity separation: `did` / `actor_id` / `session_id`.
  - Video feed lifecycle safety (preload current/next, release previous, single active controller, app pause/resume handling).
  - No compile-by-deletion; non-implemented features keep explicit TODO + safe fallback.

## 2) Scan results (before coding)

### 2.1 Vue routes/pages inventory
Primary route source: `src/router/routes.ts`.

High-priority mapped routes:
- `/login`, `/login/password`, `/login/verification-code`
- `/home`
- `/message`, `/message/chat/:userid?`, `/message/group/:groupId`
- `/me`, `/profile/:upid`

Main route groups discovered:
- Home/video/music/live/search/report
- Message/chat/group/notice/fans/visitors
- Me/profile/userinfo/edit/settings/collections
- Shop
- Login

### 2.2 API modules/endpoints inventory
Scanned modules:
- `src/api/user.ts`
- `src/api/videos.ts`
- `src/api/message.ts`
- `src/api/group.ts`
- `src/api/pictures.ts`
- `src/api/feedback.ts`

Critical endpoints for M0-M2:
- Auth/user:
  - `POST /user/login` (form fields: `uid`, `password`, `mode`, optional `did`)
  - `GET /user/userinfo`
- Feed/interaction:
  - `POST /api/next`
  - `POST /api/history`
  - `POST /api/session_state`
  - `POST /api/ack`
  - `POST /api/action`
  - `POST /video/like`
  - `POST /video/collect`
  - `GET /video/comments`
  - `POST /video/comments`

Backend base routing behavior (must preserve):
- Default old backend: `VITE_API_BASE` (8080)
- Algo backend: `VITE_ALGO_BASE` (8083) for `/api/*` feedback/reco/session calls
- Long-video backend: `VITE_LONG_VIDEO_BASE` (8081) for long video / `video_list_by_upid`
- New-content backend: `VITE_API_NEW_BASE` (8099) for `/post/recommended*`

### 2.3 BaseVideo responsibilities extraction
Source: `src/components/slide/BaseVideo.vue`.

Extracted responsibilities to preserve:
1. **Play URL cleaning/ad filtering**
   - Filters `mediav.com`, `live-s3m`, `doubleclick.net`, `ads.`, `ad.*`, `beacon`, `tracking`.
   - Accepts `play_url` as string or array; selects first non-ad URL.
2. **Autoplay policy**
   - Autoplay while muted first; if user preference is unmuted, tries to unmute after successful start.
   - Handles `NotAllowedError` fallback to muted playback.
3. **Progress/seek logic**
   - Tracks playback progress/time updates.
   - Supports horizontal drag seek and explicit progress ack/action reporting.
4. **Lifecycle/event safety**
   - Mount/unmount binds/unbinds listeners.
   - Page visibility handling.
   - Active item plays; others hard-stop/release to avoid multi-audio/black frame issues.
5. **Interaction hooks**
   - Like/skip/report actions.
   - Comment UI open/close transitions.

### 2.4 did/actor_id/session_id logic extraction
Source: `src/utils/session.ts`.

Observed behavior:
- `did`: stable device id in storage/cookie/memory; generated once and reused.
- `actor_id`: stable app actor identity (prefix `a_`); repaired if polluted.
- `session_id`: generated with TTL and rotated when expired.
- Headers in requests include `X-Actor-ID` and `X-DID`; session state tracked with created timestamp.

Flutter migration rule implemented:
- `did`: generated once, persisted and reused.
- `actor_id`: separate key; never overwritten by `did`/`session_id`.
- `session_id`: short-lived with explicit TTL check; expired sessions are rotated/cleared.

---

## 3) Architecture map (Vue -> Flutter)

| Vue module | Flutter module | Notes |
|---|---|---|
| `src/router/*` | `lib/config/app_routes.dart` + GetX `GetPage` | GetX-only routing |
| `src/store/pinia.ts` | `lib/controllers/*` (GetxController) | State + DI unified |
| `src/api/*.ts` | `lib/services/api_client.dart` + `auth_service.dart` + `feed_service.dart` | Preserve endpoint/param contracts |
| `src/utils/session.ts` | `lib/services/identity_manager.dart` | Stable DID/actor/session isolation |
| `src/components/slide/BaseVideo.vue` | `lib/widgets/feed_video_player.dart` + `video_controller_pool.dart` | Lifecycle-safe player pool |
| `src/pages/login/*` | `lib/views/login_page.dart` | M1 login flow |
| `src/pages/home/*` | `lib/views/feed_page.dart` + `feed_controller.dart` | M2 vertical feed |
| message/group services | `lib/services/message_service.dart` (TODO-safe stub) | M4 deferred |

---

## 4) Dependency decisions

Chosen stack:
- `get`: Controllers + dependency injection + routing (single approach)
- `dio`: HTTP client + interceptors + base routing
- `shared_preferences`: persistent identity/session/auth storage
- `video_player`: native video playback core
- `uuid`: stable id generation

Why:
- Matches constraints: GetX-only app architecture.
- `dio` supports Vue-like interceptor behavior and backend switching.
- `shared_preferences` is enough for stable identity/session TTL and token persistence.
- `video_player` supports controlled lifecycle + preloading strategy.

---

## 5) Risks and mitigations

1. **Video lifecycle instability (highest risk)**
- Risk: multiple active decoders/audio overlap; background resume glitches.
- Mitigation: controller pool (keep current+next), release previous, app lifecycle pause/resume hooks.

2. **Identity pollution (`did`/`actor_id`/`session_id`)**
- Risk: wrong id mapped to wrong field breaks recommendations/auth tracking.
- Mitigation: dedicated identity manager keys and validation prefixes + explicit TTL rotation.

3. **API drift from Vue behavior**
- Risk: param/header mismatch breaks backend integration.
- Mitigation: endpoint constants + contract checklist + service-level wrappers mirroring Vue payload shape.

4. **Algo backend transient failures**
- Risk: feed unavailable due to 8083 errors.
- Mitigation: explicit network error mapping and safe fallback UI state.

---

## 6) Milestones and acceptance criteria

### M0: Skeleton + env + logging
Acceptance criteria:
- Flutter app starts with GetX router and bindings.
- Environment supports base URL switching (`dart-define`).
- Logging utility available in all services.

### M1: ApiClient + Auth + Storage + error mapping
Acceptance criteria:
- `POST /user/login` uses form fields matching Vue.
- Interceptor injects `X-Actor-ID` and `X-DID`.
- Identity manager ensures `did` stable, `actor_id` isolated, `session_id` TTL-rotated.
- Network/server/auth errors mapped to user-safe messages.

### M2: Vertical feed + playback core + pool + lifecycle
Acceptance criteria:
- Vertical `PageView` feed loads videos via `/api/next` batch flow.
- Player pool keeps `current + next`, releases previous.
- Only one active controller plays at a time.
- App pause -> player paused; app resume -> current item restored.
- Invalid/ad URLs are filtered; error state UI shown for failures.

### M3 (deferred): like/favorite/comment minimal flow
Acceptance criteria (planned):
- Like/collect/comment endpoints callable with minimal UI and optimistic update.

### M4 (deferred): WebSocket messaging minimal flow
Acceptance criteria (planned):
- Basic connect/send/receive list with reconnect and error indicator.

---

## 7) API contract checklist (M0-M2 implemented scope)

- [x] `POST /user/login`
  - [x] form fields: `uid,password,mode,did`
  - [x] content-type form urlencoded/form-data compatible
- [x] Header injection
  - [x] `X-Actor-ID`
  - [x] `X-DID`
- [x] Algo feed calls
  - [x] `POST /api/next` with `actor_id,session_id,index,dir,step,device_id`
  - [x] supports paging via index progression
- [x] Session call
  - [x] `POST /api/session_state`
- [x] Feedback calls
  - [x] `POST /api/ack`
  - [x] `POST /api/action`
- [x] URL cleaning/ad filtering for play URL before playback
- [x] Error mapping and safe UI fallback for network/video failures

---

## 8) Deferred items policy
- M3/M4 remain explicitly marked TODO in code and runbook.
- UI falls back to non-crashing disabled controls with explanatory text.
- No feature deletion used as compile workaround.
