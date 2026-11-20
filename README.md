# Habit Tracker

A quest-style daily habit tracker with streaks, XP levels and a weekly activity chart. Dark plum-and-purple "quest log" design, built as a single HTML file.

**Live demo: https://nafiz-xd.github.io/habit-tracker/**

## Features

- **Create & delete habits** — name plus a colour for each habit ("quest")
- **Daily check-off** — one tap per habit per day, with a +10 XP reward animation
- **Streaks** — current streak and best streak per habit (a streak stays alive if yesterday was completed)
- **Weekly activity chart** — animated bars showing the share of habits completed on each of the last 7 days
- **Overall summary** — today's completion %, best current streak, total check-ins, and an XP progress bar with levels
- **Local persistence** — everything is saved in the browser's `localStorage`, so it works fully offline with no account
- **Mobile-responsive** layout

## How it works

Open `index.html` (or the live demo), add a habit, and tap **Mark done today** each day you complete it. Streaks, the weekly chart, XP and your level all update instantly. Three sample habits are pre-loaded the first time so you can see it in action — delete them whenever you like.

## Going live with Supabase (optional)

By default the app is **local-only**. To sync habits across devices with your own free [Supabase](https://supabase.com) project:

1. Create a project at supabase.com.
2. Open the project's **SQL Editor** and run [`supabase-schema.sql`](supabase-schema.sql). It creates two tables — `habits` and `habit_logs` — with **Row Level Security enabled** and policies keyed to `auth.uid()`, so every user can only ever read or write their own rows.
3. In `index.html`, fill in the clearly-marked `SUPABASE_CONFIG` block near the top of the script with your project URL and **publishable key** (`sb_publishable_...`).

> ⚠️ Only the publishable key belongs in browser code. Never put the secret service-role key in the app — it bypasses Row Level Security completely.

The cloud bootstrap uses the current `@supabase/supabase-js` API (verified against the latest docs): `createClient(url, publishableKey, { auth: { persistSession, autoRefreshToken, detectSessionInUrl, storageKey } })`, with session state driven by `onAuthStateChange`.

## Tech

Single-file HTML/CSS/JavaScript · localStorage · optional Supabase (Postgres + Auth + RLS)

---

Built by Nafiz Bin Azad
