-- Teatro AlSaeed Digital Platform
-- Initial content schema. Apply only to project cusdjhfdhimoucjvxsmr.
-- All public content is read-only to anonymous users; editors are managed through admin_members.

create extension if not exists pgcrypto;

create table public.admin_members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'editor' check (role in ('owner','editor')),
  created_at timestamptz not null default now()
);
alter table public.admin_members enable row level security;
grant select on public.admin_members to authenticated;
create policy "Admins can read their own membership"
  on public.admin_members for select to authenticated
  using (user_id = (select auth.uid()));

create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;
create or replace function private.is_admin()
returns boolean language sql stable security invoker set search_path = ''
as $$
  select exists (
    select 1 from public.admin_members
    where user_id = (select auth.uid())
  );
$$;
grant execute on function private.is_admin() to authenticated;

create table public.news_posts (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title_ar text not null, title_en text,
  excerpt_ar text, excerpt_en text,
  body_ar text not null default '', body_en text not null default '',
  cover_image_url text,
  status text not null default 'draft' check (status in ('draft','published','archived')),
  featured boolean not null default false,
  published_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.productions (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title_ar text not null, title_en text,
  synopsis_ar text, synopsis_en text,
  production_year integer, director_ar text, director_en text,
  poster_url text, gallery_urls text[] not null default '{}', trailer_url text,
  status text not null default 'published' check (status in ('draft','published','archived')),
  featured boolean not null default false, sort_order integer not null default 0,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table public.festival_editions (
  id uuid primary key default gen_random_uuid(),
  edition_number integer not null unique, slug text not null unique,
  title_ar text not null, title_en text, year integer not null,
  slogan_ar text, slogan_en text, description_ar text, description_en text,
  starts_on date, ends_on date, venue_ar text, venue_en text, hero_image_url text,
  status text not null default 'draft' check (status in ('draft','published','archived')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check (ends_on is null or starts_on is null or ends_on >= starts_on)
);

create table public.festival_events (
  id uuid primary key default gen_random_uuid(),
  edition_id uuid not null references public.festival_editions(id) on delete cascade,
  event_type text not null default 'other' check (event_type in ('performance','workshop','opening','closing','talk','screening','other')),
  title_ar text not null, title_en text, description_ar text, description_en text,
  venue_ar text, venue_en text, starts_at timestamptz, ends_at timestamptz,
  cover_image_url text, is_published boolean not null default false,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check (ends_at is null or starts_at is null or ends_at >= starts_at)
);

create table public.workshops (
  id uuid primary key default gen_random_uuid(),
  festival_edition_id uuid references public.festival_editions(id) on delete set null,
  slug text not null unique, title_ar text not null, title_en text,
  trainer_ar text, trainer_en text, description_ar text, description_en text,
  starts_at timestamptz, ends_at timestamptz, venue_ar text, venue_en text,
  cover_image_url text, registration_url text,
  status text not null default 'draft' check (status in ('draft','published','closed')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check (ends_at is null or starts_at is null or ends_at >= starts_at)
);

create table public.open_calls (
  id uuid primary key default gen_random_uuid(),
  festival_edition_id uuid references public.festival_editions(id) on delete set null,
  slug text not null unique, title_ar text not null, title_en text,
  description_ar text, description_en text, opens_at timestamptz, closes_at timestamptz,
  application_url text,
  status text not null default 'draft' check (status in ('draft','published','closed')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check (closes_at is null or opens_at is null or closes_at >= opens_at)
);

create table public.app_announcements (
  id uuid primary key default gen_random_uuid(),
  title_ar text not null, title_en text, message_ar text not null, message_en text,
  target_url text, is_published boolean not null default false, publish_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path = ''
as $$ begin new.updated_at = now(); return new; end; $$;

create trigger news_posts_updated before update on public.news_posts for each row execute function public.set_updated_at();
create trigger productions_updated before update on public.productions for each row execute function public.set_updated_at();
create trigger festival_editions_updated before update on public.festival_editions for each row execute function public.set_updated_at();
create trigger festival_events_updated before update on public.festival_events for each row execute function public.set_updated_at();
create trigger workshops_updated before update on public.workshops for each row execute function public.set_updated_at();
create trigger open_calls_updated before update on public.open_calls for each row execute function public.set_updated_at();

create index news_posts_status_published_idx on public.news_posts(status, published_at desc);
create index productions_status_order_idx on public.productions(status, sort_order, production_year desc);
create index festival_events_edition_start_idx on public.festival_events(edition_id, starts_at);
create index workshops_status_start_idx on public.workshops(status, starts_at);
create index open_calls_status_close_idx on public.open_calls(status, closes_at);
create index app_announcements_publish_idx on public.app_announcements(is_published, publish_at desc);
create index news_posts_created_by_idx on public.news_posts(created_by);
create index app_announcements_created_by_idx on public.app_announcements(created_by);
create index open_calls_edition_idx on public.open_calls(festival_edition_id);
create index workshops_edition_idx on public.workshops(festival_edition_id);

alter table public.news_posts enable row level security;
alter table public.productions enable row level security;
alter table public.festival_editions enable row level security;
alter table public.festival_events enable row level security;
alter table public.workshops enable row level security;
alter table public.open_calls enable row level security;
alter table public.app_announcements enable row level security;

grant select on public.news_posts, public.productions, public.festival_editions,
  public.festival_events, public.workshops, public.open_calls, public.app_announcements to anon, authenticated;
grant insert, update, delete on public.news_posts, public.productions, public.festival_editions,
  public.festival_events, public.workshops, public.open_calls, public.app_announcements to authenticated;

-- Anonymous users see published rows only.
create policy "Public reads published news" on public.news_posts for select to anon using (status = 'published');
create policy "Public reads published productions" on public.productions for select to anon using (status = 'published');
create policy "Public reads published festival editions" on public.festival_editions for select to anon using (status = 'published');
create policy "Public reads published festival events" on public.festival_events for select to anon using (is_published);
create policy "Public reads published workshops" on public.workshops for select to anon using (status = 'published');
create policy "Public reads published open calls" on public.open_calls for select to anon using (status in ('published','closed'));
create policy "Public reads published announcements" on public.app_announcements for select to anon
  using (is_published and (publish_at is null or publish_at <= now()));

-- Authenticated admins can also see drafts and perform content management.
create policy "Authenticated reads news" on public.news_posts for select to authenticated
  using (status = 'published' or (select private.is_admin()));
create policy "Authenticated reads productions" on public.productions for select to authenticated
  using (status = 'published' or (select private.is_admin()));
create policy "Authenticated reads festival editions" on public.festival_editions for select to authenticated
  using (status = 'published' or (select private.is_admin()));
create policy "Authenticated reads festival events" on public.festival_events for select to authenticated
  using (is_published or (select private.is_admin()));
create policy "Authenticated reads workshops" on public.workshops for select to authenticated
  using (status = 'published' or (select private.is_admin()));
create policy "Authenticated reads open calls" on public.open_calls for select to authenticated
  using (status in ('published','closed') or (select private.is_admin()));
create policy "Authenticated reads announcements" on public.app_announcements for select to authenticated
  using ((is_published and (publish_at is null or publish_at <= now())) or (select private.is_admin()));

-- Insert/update/delete policies are intentionally admin-only.
create policy "Admins insert news" on public.news_posts for insert to authenticated with check ((select private.is_admin()));
create policy "Admins update news" on public.news_posts for update to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy "Admins delete news" on public.news_posts for delete to authenticated using ((select private.is_admin()));
create policy "Admins insert productions" on public.productions for insert to authenticated with check ((select private.is_admin()));
create policy "Admins update productions" on public.productions for update to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy "Admins delete productions" on public.productions for delete to authenticated using ((select private.is_admin()));
create policy "Admins insert festival editions" on public.festival_editions for insert to authenticated with check ((select private.is_admin()));
create policy "Admins update festival editions" on public.festival_editions for update to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy "Admins delete festival editions" on public.festival_editions for delete to authenticated using ((select private.is_admin()));
create policy "Admins insert festival events" on public.festival_events for insert to authenticated with check ((select private.is_admin()));
create policy "Admins update festival events" on public.festival_events for update to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy "Admins delete festival events" on public.festival_events for delete to authenticated using ((select private.is_admin()));
create policy "Admins insert workshops" on public.workshops for insert to authenticated with check ((select private.is_admin()));
create policy "Admins update workshops" on public.workshops for update to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy "Admins delete workshops" on public.workshops for delete to authenticated using ((select private.is_admin()));
create policy "Admins insert open calls" on public.open_calls for insert to authenticated with check ((select private.is_admin()));
create policy "Admins update open calls" on public.open_calls for update to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy "Admins delete open calls" on public.open_calls for delete to authenticated using ((select private.is_admin()));
create policy "Admins insert announcements" on public.app_announcements for insert to authenticated with check ((select private.is_admin()));
create policy "Admins update announcements" on public.app_announcements for update to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy "Admins delete announcements" on public.app_announcements for delete to authenticated using ((select private.is_admin()));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('public-media','public-media',true,10485760,array['image/jpeg','image/png','image/webp','image/avif'])
on conflict (id) do nothing;
create policy "Public reads published media" on storage.objects for select to anon, authenticated
  using (bucket_id = 'public-media');
create policy "Admins upload media" on storage.objects for insert to authenticated
  with check (bucket_id = 'public-media' and (select private.is_admin()));
create policy "Admins update media" on storage.objects for update to authenticated
  using (bucket_id = 'public-media' and (select private.is_admin()))
  with check (bucket_id = 'public-media' and (select private.is_admin()));
create policy "Admins delete media" on storage.objects for delete to authenticated
  using (bucket_id = 'public-media' and (select private.is_admin()));
