alter table clients drop constraint if exists clients_age_check;
alter table clients add constraint clients_age_check check (age > 0 and age <= 150);