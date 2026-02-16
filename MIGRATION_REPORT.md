# MIGRATION_REPORT

## 0. Scan conclusion for this repo (Phase 0)

### 0.1 Vue source availability
- Scanned paths in this repo:
  - `src/router/**`
  - `src/pages/**`
  - `src/api/**`
  - `src/services/**`
  - `src/utils/**`
- Result: **Vue source is not present in `E:\hls\Flutterdemo`**.
- Therefore this report is based on migration docs in repo root:
  - `FLUTTER_MIGRATION_PLAN.md`
  - `DETAILED_CODE_MIGRATION_GUIDE.md`
  - `QUICK_REFERENCE_AND_FEATURES.md`
  - `CONVERSION_SUMMARY.md`

### 0.2 Route/Page map (doc-derived)
From docs, key Vue route groups are:
- Home domain:
  - `/home`, `/home/music`, `/home/live`, `/home/search`
- Auth domain:
  - `/login`, `/login/password`, `/login/verification-code`
- Message domain:
  - `/message`, `/message/chat/:userid?`, `/message/group/:groupId`
- Profile domain:
  - `/me`, `/profile/:upid`
- Other domain:
  - `/shop`, `/publish`

### 0.3 API and transport behavior (doc-derived)
Base URLs (must be environment switchable):
- Main API: `http://192.168.0.107:8080`
- Algo API: `http://192.168.0.107:8083`
- Long video API: `http://192.168.0.107:8081`
- New/recommended content API: `http://192.168.0.107:8099`

Critical endpoint groups to preserve:
- Auth:
  - `POST /user/login` (fields: `uid`, `password`, `mode`, optional `did`)
  - `GET /user/userinfo`
- Feed/session:
  - `POST /api/next`
  - `POST /api/history`
  - `POST /api/session_state`
- Feedback:
  - `POST /api/ack`
  - `POST /api/action`
- Interaction:
  - `POST /video/like`
  - `POST /video/collect`
  - `GET /video/comments`
  - `POST /video/comments`

Headers/auth behavior to preserve:
- `X-Actor-ID`
- `X-DID`
- optional `Authorization` when logged in

Pagination/response compatibility to preserve:
- `offset/count` or `pageNo/pageSize` style from existing contracts
- feed index progression with `index/dir/step`
- response normalization from `code=0` or `code=200` to success

### 0.4 BaseVideo responsibilities (doc-derived)
From migration docs around `BaseVideo.vue`, Flutter implementation must preserve:
- Play URL cleanup/ad filtering:
  - filter domains: `mediav.com`, `live-s3m`, `doubleclick.net`, `ads.`, `ad.`, `adv.`, `beacon`, `tracking`
  - support `play_url` string or array
- Autoplay policy:
  - muted-first autoplay to satisfy mobile restrictions
  - fallback when autoplay blocked
- Progress/seek logic:
  - current time/duration tracking
  - seek by gesture and progress control
- Gesture interactions:
  - tap pause/resume
  - drag/touch seek
- Lifecycle safety:
  - active item play, inactive item pause/release
  - app pause/resume handling

### 0.5 Identity/session logic (doc-derived)
Identity model to preserve and enforce:
- `did`:
  - stable device id, generate once and persist
- `actor_id`:
  - stable actor identity, isolated key; never overwritten by `did/session_id`
- `session_id`:
  - short-lived with TTL, rotate on expiry

Storage keys and risks:
- keys include `did`, `hls_actor_id`, `hls_session_id`, `hls_session_created_at`
- overwrite risk: accidental mapping between `did` and `actor_id`
- mitigation: dedicated manager and key-level validation

---

## 1. Architecture map (Vue -> Flutter)

| Vue domain (doc-derived) | Flutter target module | Notes |
|---|---|---|
| router/routes | `lib/config/app_routes.dart` | GetX route table only |
| pinia/store | `lib/controllers/*` | GetxController for state |
| api/user/videos/message/group | `lib/services/*` + `lib/config/endpoints.dart` | Contract-preserving wrappers |
| utils/session/request | `lib/services/identity_manager.dart`, `lib/services/api_client.dart` | header+ttl+base routing |
| BaseVideo.vue | `lib/widgets/feed_video_player.dart`, `lib/services/video_controller_pool.dart` | lifecycle-safe playback |
| pages/home/login/message/me | `lib/views/*` | incremental milestone delivery |

---

## 2. Dependency decisions and rationale

Selected:
- `get`:
  - one framework for routing + DI + state, avoids mixed architecture
- `dio`:
  - interceptors, dynamic base-url switching, header injection, robust error mapping
- `shared_preferences`:
  - lightweight persistent storage for identity/session/auth keys
- `video_player`:
  - stable core playback API with lifecycle control
- `uuid`:
  - deterministic id generation for `did/session_id`

Not selected (for now):
- `go_router` (explicitly avoided by constraint)
- heavy storage/database layers before required by milestones

---

## 3. Risks and mitigations

1) Video lifecycle instability
- Risk: multiple active controllers/audio overlap, resume mismatch
- Mitigation: controller pool keeps current+next, releases previous, app lifecycle observer

2) Identity drift (`did/actor_id/session_id`)
- Risk: incorrect overwrite breaks recommendation/session continuity
- Mitigation: dedicated `IdentityManager` + strict key isolation + TTL rotation

3) Pagination duplicates/order drift
- Risk: duplicated items or index mismatch in infinite feed
- Mitigation: index-based progression and de-dup strategy in feed controller/service

4) API contract drift
- Risk: endpoint/params/headers mismatch with legacy behavior
- Mitigation: centralized endpoint constants + request contract checklist + CI analyze/test gate

---

## 4. Milestones and acceptance criteria

### M0: Skeleton + env + logging
Scope:
- Flutter skeleton with folders:
  - `lib/config`, `lib/models`, `lib/services`, `lib/controllers`, `lib/views`, `lib/widgets`, `lib/utils`
- Environment switching for dev/staging/prod
- Structured logger with tags
- GetX routing flow: Splash -> Home placeholder (with env label)
- No runtime API flow in entry path

Acceptance:
- `cd flutter_app && flutter pub get`
- `cd flutter_app && dart format -o none --set-exit-if-changed .`
- `cd flutter_app && flutter analyze` -> 0 issues
- `cd flutter_app && flutter test` passes
- app starts and shows home placeholder + env label

### M1: API client + auth + storage + error mapping
Scope:
- `ApiClient(dio)` with base-url routing and headers
- auth request compatibility for `/user/login`
- identity/session manager with TTL
- unified app error mapping

Acceptance:
- request/headers/params match contract checklist
- identity keys stable and isolated
- network/auth/server errors mapped to safe UI message

### M2: Feed + playback core + lifecycle safety
Scope:
- vertical page feed
- controller pool (current+next preload, previous release)
- app lifecycle pause/resume
- ad URL filtering and error fallback UI

Acceptance:
- one active player at a time
- swipe flow stable without memory/audio leak symptoms
- invalid/ad URLs filtered without crash

---

## 5. API contract checklist

Auth/User:
- [ ] `POST /user/login`
  - [ ] fields: `uid,password,mode,did`
  - [ ] form-like payload compatibility
- [ ] `GET /user/userinfo`

Headers:
- [ ] `X-Actor-ID`
- [ ] `X-DID`
- [ ] `Authorization` (if token exists)

Feed/session/feedback:
- [ ] `POST /api/next` with `actor_id,session_id,index,dir,step,device_id`
- [ ] `POST /api/history`
- [ ] `POST /api/session_state`
- [ ] `POST /api/ack`
- [ ] `POST /api/action`

Interaction:
- [ ] `POST /video/like`
- [ ] `POST /video/collect`
- [ ] `GET /video/comments`
- [ ] `POST /video/comments`

Pagination/response fields:
- [ ] preserve offset/count or pageNo/pageSize semantics
- [ ] preserve index/dir/step feed semantics
- [ ] normalize `code=0/200` success behavior consistently
