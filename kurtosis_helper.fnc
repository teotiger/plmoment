create or replace function kurtosis_helper (
  opt_in  in integer, -- 1=population_kurtosis, 2=sample_kurtosis,
  opt_out in integer, -- 3=population_excess_kurtosis, 4=sample_excess_kurtosis
  val     in number,
  n       in integer
) return number
  authid definer
is
  population_kurtosis          number;
  sample_kurtosis              number;
  population_excess_kurtosis   number;
  sample_excess_kurtosis       number;
  sample_excess_factor         number;
  sample_factor                number;
  subtype valid_vals is simple_integer range 1..4 not null;
  l_opt_in                     valid_vals := opt_in;
  l_opt_out                    valid_vals := opt_out;
  l_val                        number not null := val;
  l_n                          simple_integer := n;
begin
  sample_excess_factor := 3*(l_n - 1) * (l_n - 1) / ((l_n - 2) * (l_n - 3));
  sample_factor :=     l_n *(l_n + 1) * (l_n - 1) / ((l_n - 2) * (l_n - 3));

  case
    l_opt_in
    when 1 then
      population_kurtosis := val;
      population_excess_kurtosis := val - 3;
      sample_kurtosis := ( population_kurtosis / n ) * sample_factor;
      sample_excess_kurtosis := sample_kurtosis - sample_excess_factor;
    when 2 then
      sample_kurtosis := val;
      sample_excess_kurtosis := sample_kurtosis - sample_excess_factor;
      population_excess_kurtosis
      := ((sample_excess_kurtosis*(l_n-2)*(l_n-3)/(l_n-1)) - 6) / (l_n+1);
      population_kurtosis := population_excess_kurtosis + 3;
    when 3 then
      population_excess_kurtosis := val;
      population_kurtosis := val + 3;
      sample_kurtosis := ( population_kurtosis / n ) * sample_factor;
      sample_excess_kurtosis := sample_kurtosis - sample_excess_factor;
    when 4 then
      sample_excess_kurtosis := val;
      sample_kurtosis := val + sample_excess_factor;
      population_excess_kurtosis
      := ((sample_excess_kurtosis*(l_n-2)*(l_n-3)/(l_n-1)) - 6) / (l_n+1);
      population_kurtosis := population_excess_kurtosis + 3;
  end case;
 
  return
    case l_opt_out
      when 1 then population_kurtosis
      when 2 then sample_kurtosis
      when 3 then population_excess_kurtosis
      when 4 then sample_excess_kurtosis
    end;
end;
/*
**

with testdata as (
  select
    2.368678993094230 as kurt_pop,
    4.187486077077300 as kurt_samp,
   -0.631321006905771 as exc_pop,
   -0.151799637208416 as exc_samp,
    12                as max_round
  from dual
)
select
  round( kurtosis_helper(1,1,t.kurt_pop,10) ,t.max_round) as kp,
  round( kurtosis_helper(1,2,t.kurt_pop,10) ,t.max_round) as ks,
  round( kurtosis_helper(1,3,t.kurt_pop,10) ,t.max_round) as ep,
  round( kurtosis_helper(1,4,t.kurt_pop,10) ,t.max_round) as es
from testdata t
  union all
select
  round( kurtosis_helper(2,1,t.kurt_samp,10) ,t.max_round) as kp,
  round( kurtosis_helper(2,2,t.kurt_samp,10) ,t.max_round) as ks,
  round( kurtosis_helper(2,3,t.kurt_samp,10) ,t.max_round) as ep,
  round( kurtosis_helper(2,4,t.kurt_samp,10) ,t.max_round) as es
from testdata t
  union all
select
  round( kurtosis_helper(3,1,t.exc_pop,10) ,t.max_round) as kp,
  round( kurtosis_helper(3,2,t.exc_pop,10) ,t.max_round) as ks,
  round( kurtosis_helper(3,3,t.exc_pop,10) ,t.max_round) as ep,
  round( kurtosis_helper(3,4,t.exc_pop,10) ,t.max_round) as es
from testdata t
  union all
select
  round( kurtosis_helper(4,1,t.exc_samp,10) ,t.max_round) as kp,
  round( kurtosis_helper(4,2,t.exc_samp,10) ,t.max_round) as ks,
  round( kurtosis_helper(4,3,t.exc_samp,10) ,t.max_round) as ep,
  round( kurtosis_helper(4,4,t.exc_samp,10) ,t.max_round) as es
from testdata t;

**
*/
/
