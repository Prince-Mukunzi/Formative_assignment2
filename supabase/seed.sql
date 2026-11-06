insert into public.departments (id, label, categories) values
  ('facilities', 'Facilities', '{facilities}'),
  ('plumbing', 'Plumbing', '{water}'),
  ('electrical', 'Electrical', '{electricity}'),
  ('furniture', 'Furniture', '{furniture}'),
  ('sanitation', 'Sanitation', '{sanitation}'),
  ('safety', 'Safety', '{safety}')
on conflict (id) do nothing;

insert into public.locations (name) values
  ('Block A'), ('Block B'), ('Block C'), ('Dorm A'), ('Dorm B'), ('Dorm C'),
  ('East Wing'), ('Library'), ('Main Hall'), ('Science Block')
on conflict do nothing;

insert into public.invites (email, role) values ('admin@test.dev', 'admin')
on conflict do nothing;
