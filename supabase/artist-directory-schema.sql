-- Arts of Upper Egypt: initial schema
-- Run in Supabase SQL Editor only after creating a project and reviewing this migration.
create extension if not exists pgcrypto;

create table if not exists public.artist_submissions (
 id uuid primary key default gen_random_uuid(),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 status text not null default 'pending' check (status in ('pending','needs_changes','approved','rejected')),
 full_name text not null check (char_length(full_name) between 2 and 120),
 artist_name text,
 email text not null,
 governorate text not null,
 disciplines text[] not null default '{}',
 bio text not null check (char_length(bio) between 20 and 1800),
 portfolio_url text,
 social_url text,
 work_links text[] not null default '{}',
 cv_path text,
 portrait_path text,
 consent_at timestamptz not null default now(),
 admin_notes text
);

alter table public.artist_submissions enable row level security;
revoke all on public.artist_submissions from anon, authenticated;
grant insert on public.artist_submissions to anon;
grant select on public.artist_submissions to anon;
-- Public can insert applications; public reads only approved profiles.
create policy "Public can submit artist applications"
 on public.artist_submissions for insert to anon
 with check (status = 'pending' and admin_notes is null);
create policy "Public can view approved artist profiles"
 on public.artist_submissions for select to anon
 using (status = 'approved');

-- IMPORTANT: do not enable public update/delete policies.
-- Admin review requires authenticated users whose auth.uid() is listed in this table.
create table if not exists public.artist_directory_admins (
 user_id uuid primary key references auth.users(id) on delete cascade,
 created_at timestamptz not null default now()
);
alter table public.artist_directory_admins enable row level security;
revoke all on public.artist_directory_admins from anon, authenticated;
grant select on public.artist_directory_admins to authenticated;
create policy "Admins can see their own admin record"
 on public.artist_directory_admins for select to authenticated
 using (user_id = auth.uid());

grant select, update on public.artist_submissions to authenticated;
create policy "Admins can review submissions"
 on public.artist_submissions for select to authenticated
 using (exists (select 1 from public.artist_directory_admins a where a.user_id = auth.uid()));
create policy "Admins can update submissions"
 on public.artist_submissions for update to authenticated
 using (exists (select 1 from public.artist_directory_admins a where a.user_id = auth.uid()))
 with check (exists (select 1 from public.artist_directory_admins a where a.user_id = auth.uid()));

-- Configure a PRIVATE storage bucket named artist-submissions in Supabase Dashboard.
-- Keep uploads private until reviewed. Do not make CV files public.
