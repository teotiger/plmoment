--create type number# as table of number;
--/

with testdata as (
  -- https://support.office.com 
  select column_value as x
    from table(number#(3,4,5,2,3,4,5,6,4,7))
), 
plmoment as (
  select plmoment_f(x) moments 
    from testdata
)
select
  plm.moments.mean,
  plm.moments.variance_s,
  plm.moments.variance_p,
  plm.moments.stddev_s,
  plm.moments.stddev_p,
  plm.moments.skewness_s,
  plm.moments.kurtosis_s,
  plm.moments.excess_s
from plmoment plm
union
select
  avg(ora.x),
  variance(ora.x),
  null,
  stddev_samp(ora.x),
  stddev_pop(ora.x),
  null,--t.moments.skewness_s,
  null,--t.moments.kurtosis_s,
  null --t.moments.excess_s
from testdata ora;