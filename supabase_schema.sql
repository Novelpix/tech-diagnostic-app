create extension if not exists "uuid-ossp";
create table if not exists equipements (
    id uuid primary key default uuid_generate_v4(),
    code text,
    lot text,
    niveau text,
    local text,
    date_visite text,
    heure_debut text,
    heure_fin text,
    technicien text,
    entreprise text,
    ev int,
    criticite text,
    type_anomalie text,
    budget text,
    remarques text,
    latitude text,
    longitude text,
    data jsonb,
    created_at timestamp default now()
);
create table if not exists photos (
    id uuid primary key default uuid_generate_v4(),
    equipement_id uuid references equipements(id) on delete cascade,
    url text,
    created_at timestamp default now()
);

-- Activer RLS (Row Level Security)
alter table equipements enable row level security;
alter table photos enable row level security;

-- Politiques pour la table equipements
-- ⚠️ ATTENTION : Ces politiques sont permissives (publiques) pour le développement.
-- Pour la production, remplacez "using (true)" par "using (auth.uid() = user_id)" ou similaire.

create policy "public select" on equipements for select using (true);
create policy "public insert" on equipements for insert with check (true);
create policy "public update" on equipements for update using (true);
create policy "public delete" on equipements for delete using (true);

-- Politiques pour la table photos
create policy "public select" on photos for select using (true);
create policy "public insert" on photos for insert with check (true);
create policy "public update" on photos for update using (true);
create policy "public delete" on photos for delete using (true);
