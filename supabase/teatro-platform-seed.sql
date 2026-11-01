-- Verified content seed from festival-2027.html
-- Safe to re-run: the edition_number is unique and is upserted.
insert into public.festival_editions
  (edition_number, slug, title_ar, title_en, year, slogan_ar, slogan_en,
   description_ar, description_en, starts_on, ends_on, venue_ar, venue_en,
   hero_image_url, status)
values
  (4, 'mitf-2027',
   'الدورة الرابعة – مهرجان المنيا المسرحي الدولي',
   '4th Edition – Minya International Theatre Festival',
   2027, 'أبعد من الحدود', 'Beyond the Borders',
   'الدورة الرابعة من مهرجان المنيا المسرحي الدولي تنطلق من المنيا إلى العالم، وتفتح أبوابها لفرق وفنانين ومدربين من مختلف أنحاء العالم.',
   'The fourth edition of the Minya International Theatre Festival sets out from Minya to the world, opening its doors to troupes, artists and trainers from across the globe.',
   date '2027-04-05', date '2027-04-12',
   'المنيا، مصر', 'Minya, Egypt',
   'https://teatroalsaeed.org/images/festival/2027/festival-2027-hero.jpg',
   'published')
on conflict (edition_number) do update set
  slug = excluded.slug,
  title_ar = excluded.title_ar,
  title_en = excluded.title_en,
  year = excluded.year,
  slogan_ar = excluded.slogan_ar,
  slogan_en = excluded.slogan_en,
  description_ar = excluded.description_ar,
  description_en = excluded.description_en,
  starts_on = excluded.starts_on,
  ends_on = excluded.ends_on,
  venue_ar = excluded.venue_ar,
  venue_en = excluded.venue_en,
  hero_image_url = excluded.hero_image_url,
  status = excluded.status;
