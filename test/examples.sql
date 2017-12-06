--------------------------------------------------------------------------------
with testdata as (
  select test_id, x 
    from plmoment_testdata
),
plmoment as (
  select /*+PARALLEL(3, q)*/
         test_id, 
         plmoment_f(x) moments 
    from testdata q
group by test_id
)
  select 'PLMoment' as src,
         plm.test_id,
         plm.moments.mean,
         plm.moments.variance_p,
         plm.moments.variance_s,
         plm.moments.stddev_p,
         plm.moments.stddev_s,
         plm.moments.skewness_p,
         plm.moments.skewness_s,
         plm.moments.kurtosis_p,
         plm.moments.kurtosis_s,
         plm.moments.excess_p,
         plm.moments.excess_s
    from plmoment plm
union
  select 'Oracle' as src,
         sub.test_id,
         sub.avg$,
         sub.var_pop$,
         sub.var_samp$,
         sub.stddev_pop$,
         sub.stddev_samp$,
  (sum(power(sub.x-sub.avg$,3)) over(partition by test_id) / sub.count$) / power(stddev_pop$,3),
  (sum(power(sub.x-sub.avg$,3)) over(partition by test_id) / sub.count$) / power(stddev_pop$,3)
    * sqrt(sub.count$*(sub.count$-1))/(sub.count$-2),  
  (sum(power(sub.x-sub.avg$,4)) over(partition by test_id) / sub.count$) / power(stddev_pop$,4),
  (count$*(count$+1)/((count$-1)*(count$-2)*(count$-3)))*
    (sum(power(sub.x-sub.avg$,4)) over(partition by test_id) / power(stddev_samp$,4)),
  (sum(power(sub.x-sub.avg$,4)) over(partition by test_id) / sub.count$) / power(stddev_pop$,4)-3,
  (
    (count$*(count$+1)/((count$-1)*(count$-2)*(count$-3)))*
    (sum(power(sub.x-sub.avg$,4)) over(partition by test_id) / power(stddev_samp$,4))
  )-(3*(count$-1)*(count$-1)/((count$-2)*(count$-3)))
    from (
      select avg(ora.x)         over(partition by test_id) as avg$,
             var_samp(ora.x)    over(partition by test_id) as var_samp$,
             var_pop(ora.x)     over(partition by test_id) as var_pop$,
             stddev_samp(ora.x) over(partition by test_id) as stddev_samp$,
             stddev_pop(ora.x)  over(partition by test_id) as stddev_pop$,
             count(ora.x)       over(partition by test_id) as count$,
             ora.*
        from testdata ora
    ) sub
order by test_id asc, src desc;
--------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------
