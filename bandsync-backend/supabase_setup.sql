-- BandSync Database Setup for Supabase

-- 1. Create users profile table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  name TEXT,
  email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can read all profiles
CREATE POLICY "Users can view all profiles" ON public.users
  FOR SELECT USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- 2. Create bands table
CREATE TABLE IF NOT EXISTS public.bands (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  invite_code TEXT UNIQUE NOT NULL,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.bands ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view bands they're a member of" ON public.bands
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.band_members
      WHERE band_members.band_id = bands.id
      AND band_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Authenticated users can create bands" ON public.bands
  FOR INSERT WITH CHECK (auth.uid() = created_by);

-- 3. Create band_members table
CREATE TABLE IF NOT EXISTS public.band_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  band_id UUID REFERENCES public.bands(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member' CHECK (role IN ('admin', 'member')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(band_id, user_id)
);

ALTER TABLE public.band_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view members of their bands" ON public.band_members
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.band_members bm
      WHERE bm.band_id = band_members.band_id
      AND bm.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can join bands" ON public.band_members
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 4. Create function to auto-create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', SPLIT_PART(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Create songs table
CREATE TABLE IF NOT EXISTS public.songs (
  id TEXT PRIMARY KEY,
  band_id UUID REFERENCES public.bands(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  artist TEXT,
  album TEXT,
  lyrics TEXT,
  chords TEXT,
  key TEXT,
  tempo INTEGER,
  file_path TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

ALTER TABLE public.songs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view songs in their bands" ON public.songs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.band_members
      WHERE band_members.band_id = songs.band_id
      AND band_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can add songs to their bands" ON public.songs
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.band_members
      WHERE band_members.band_id = songs.band_id
      AND band_members.user_id = auth.uid()
    )
  );

-- 6. Create setlists table
CREATE TABLE IF NOT EXISTS public.setlists (
  id TEXT PRIMARY KEY,
  band_id UUID REFERENCES public.bands(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  song_ids TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

ALTER TABLE public.setlists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view setlists in their bands" ON public.setlists
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.band_members
      WHERE band_members.band_id = setlists.band_id
      AND band_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create setlists in their bands" ON public.setlists
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.band_members
      WHERE band_members.band_id = setlists.band_id
      AND band_members.user_id = auth.uid()
    )
  );

-- 7. Create events table
CREATE TABLE IF NOT EXISTS public.events (
  id TEXT PRIMARY KEY,
  band_id UUID REFERENCES public.bands(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  location TEXT,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,
  setlist_id TEXT REFERENCES public.setlists(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view events in their bands" ON public.events
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.band_members
      WHERE band_members.band_id = events.band_id
      AND band_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create events in their bands" ON public.events
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.band_members
      WHERE band_members.band_id = events.band_id
      AND band_members.user_id = auth.uid()
    )
  );

-- 8. Create band_messages table
CREATE TABLE IF NOT EXISTS public.band_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  band_id UUID REFERENCES public.bands(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.band_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view messages in their bands" ON public.band_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.band_members
      WHERE band_members.band_id = band_messages.band_id
      AND band_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can send messages in their bands" ON public.band_messages
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.band_members
      WHERE band_members.band_id = band_messages.band_id
      AND band_members.user_id = auth.uid()
    )
  );

-- Done! Your database is ready.
