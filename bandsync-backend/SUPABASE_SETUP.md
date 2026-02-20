# BandSync - Supabase Backend Setup

## Step 1: Create Supabase Project

1. Go to https://supabase.com
2. Sign up (FREE - no credit card)
3. Create new project
4. Save your project URL and anon key

## Step 2: Run SQL Schema

Go to SQL Editor in Supabase Dashboard and run this:

```sql
-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Users table
create table if not exists public.users (
  id uuid references auth.users primary key,
  name text not null,
  email text not null,
  created_at timestamp with time zone default now()
);

-- Bands table
create table public.bands (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  invite_code text unique not null,
  created_by uuid references public.users not null,
  created_at timestamp with time zone default now()
);

-- Band members table
create table public.band_members (
  id uuid default uuid_generate_v4() primary key,
  band_id uuid references public.bands on delete cascade not null,
  user_id uuid references public.users on delete cascade not null,
  role text default 'member',
  joined_at timestamp with time zone default now(),
  unique(band_id, user_id)
);

-- Songs table (now linked to bands)
create table public.songs (
  id text primary key,
  band_id uuid references public.bands on delete cascade not null,
  title text not null,
  artist text not null,
  album text,
  lyrics text not null,
  chords text,
  key text default 'C',
  tempo integer default 120,
  file_path text,
  created_at text not null,
  created_by uuid references public.users not null
);

-- Setlists table (now linked to bands)
create table public.setlists (
  id text primary key,
  band_id uuid references public.bands on delete cascade not null,
  name text not null,
  song_ids text[] default '{}',
  created_at text not null,
  created_by uuid references public.users not null
);

-- Events table (now linked to bands)
create table public.events (
  id uuid default uuid_generate_v4() primary key,
  band_id uuid references public.bands on delete cascade not null,
  title text not null,
  type text not null,
  date_time text not null,
  location text not null,
  notify_before boolean default true,
  created_by uuid references public.users not null
);

-- Enable Row Level Security
alter table public.users enable row level security;
alter table public.bands enable row level security;
alter table public.band_members enable row level security;
alter table public.songs enable row level security;
alter table public.setlists enable row level security;
alter table public.events enable row level security;

-- Users policies
create policy "Users can view own profile"
  on public.users for select using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.users for insert with check (auth.uid() = id);

create policy "Users can update own profile"
  on public.users for update using (auth.uid() = id);

-- Bands policies
create policy "Users can view bands they are members of"
  on public.bands for select
  using (exists (
    select 1 from public.band_members
    where band_id = id and user_id = auth.uid()
  ));

create policy "Users can create bands"
  on public.bands for insert
  with check (auth.uid() = created_by);

create policy "Band creators can update their bands"
  on public.bands for update
  using (auth.uid() = created_by);

create policy "Band creators can delete their bands"
  on public.bands for delete
  using (auth.uid() = created_by);

-- Band members policies
create policy "Users can view members of their bands"
  on public.band_members for select
  using (exists (
    select 1 from public.band_members bm
    where bm.band_id = band_id and bm.user_id = auth.uid()
  ));

create policy "Users can join bands"
  on public.band_members for insert
  with check (auth.uid() = user_id);

create policy "Users can leave bands"
  on public.band_members for delete
  using (auth.uid() = user_id);

-- Songs policies
create policy "Band members can view band songs"
  on public.songs for select
  using (exists (
    select 1 from public.band_members
    where band_id = songs.band_id and user_id = auth.uid()
  ));

create policy "Band members can add songs"
  on public.songs for insert
  with check (exists (
    select 1 from public.band_members
    where band_id = songs.band_id and user_id = auth.uid()
  ));

create policy "Band members can update songs"
  on public.songs for update
  using (exists (
    select 1 from public.band_members
    where band_id = songs.band_id and user_id = auth.uid()
  ));

create policy "Band members can delete songs"
  on public.songs for delete
  using (exists (
    select 1 from public.band_members
    where band_id = songs.band_id and user_id = auth.uid()
  ));

-- Setlists policies
create policy "Band members can view band setlists"
  on public.setlists for select
  using (exists (
    select 1 from public.band_members
    where band_id = setlists.band_id and user_id = auth.uid()
  ));

create policy "Band members can add setlists"
  on public.setlists for insert
  with check (exists (
    select 1 from public.band_members
    where band_id = setlists.band_id and user_id = auth.uid()
  ));

create policy "Band members can update setlists"
  on public.setlists for update
  using (exists (
    select 1 from public.band_members
    where band_id = setlists.band_id and user_id = auth.uid()
  ));

create policy "Band members can delete setlists"
  on public.setlists for delete
  using (exists (
    select 1 from public.band_members
    where band_id = setlists.band_id and user_id = auth.uid()
  ));

-- Events policies
create policy "Band members can view band events"
  on public.events for select
  using (exists (
    select 1 from public.band_members
    where band_id = events.band_id and user_id = auth.uid()
  ));

create policy "Band members can add events"
  on public.events for insert
  with check (exists (
    select 1 from public.band_members
    where band_id = events.band_id and user_id = auth.uid()
  ));

create policy "Band members can update events"
  on public.events for update
  using (exists (
    select 1 from public.band_members
    where band_id = events.band_id and user_id = auth.uid()
  ));

create policy "Band members can delete events"
  on public.events for delete
  using (exists (
    select 1 from public.band_members
    where band_id = events.band_id and user_id = auth.uid()
  ));

-- Enable realtime
alter publication supabase_realtime add table public.bands;
alter publication supabase_realtime add table public.band_members;
alter publication supabase_realtime add table public.songs;
alter publication supabase_realtime add table public.setlists;
alter publication supabase_realtime add table public.events;
```

## Step 3: Enable Email Auth

1. Go to Authentication → Providers
2. Enable Email provider
3. Disable email confirmation (for testing)

## Step 4: Update Flutter App

In `lib/main.dart`, replace:
```dart
url: 'YOUR_SUPABASE_URL',
anonKey: 'YOUR_SUPABASE_ANON_KEY',
```

With your actual Supabase URL and anon key from Settings → API

## Step 5: Install Dependencies

```bash
cd bandsync
flutter pub get
```

## Done!

Your app now has:
- ✅ Real-time sync across devices
- ✅ User authentication
- ✅ PostgreSQL database
- ✅ Row-level security
- ✅ 100% FREE (no credit card)

## Python Audio Analysis Service

The Python service remains the same. Run it separately:

```bash
cd bandsync-backend/python-service
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python app.py
```
