create or replace function plmoment_f(
    x in number)
  return plmoment_out_t 
  authid definer parallel_enable aggregate using plmoment_t;
/