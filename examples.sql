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
  'PLMoment' as src,
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
  sub.src,
  sub.avg$,
  sub.var_samp$,
  sub.var_pop$,
  sub.stddev_samp$,
  sub.stddev_pop$,
  (sum(power(sub.x-sub.avg$,3)) over() / sub.count$) / power(stddev_pop$,3),
  null, 
  null
from (
  select
    'Oracle' as src,
    avg(ora.x) over() as avg$,
    var_samp(ora.x) over() as var_samp$,
    var_pop(ora.x) over() as var_pop$,
    stddev_samp(ora.x) over() as stddev_samp$,
    stddev_pop(ora.x) over() as stddev_pop$,
    count(ora.x) over () as count$,
    ora.x
  from testdata ora
) sub;
