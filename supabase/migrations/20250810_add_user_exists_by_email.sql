-- Migration: Add RPC to check if a user exists by email in auth.users
-- Date: 2025-08-10

-- Create a SECURITY DEFINER function in public schema that queries auth.users
create or replace function public.user_exists_by_email(p_email text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  _exists boolean;
begin
  select exists(
    select 1 from auth.users u
    where lower(u.email) = lower(p_email)
  ) into _exists;

  return _exists;
end;
$$;

-- Ensure only execute permission is granted to anon and authenticated
revoke all on function public.user_exists_by_email(text) from public;
grant execute on function public.user_exists_by_email(text) to anon;
grant execute on function public.user_exists_by_email(text) to authenticated;

-- Optional: comment for documentation
comment on function public.user_exists_by_email(text) is 'Returns true if an auth user with the given email exists.';
