/** 

create table plmoment_testdata (
  test_id     integer,
  x           number,
  description varchar2(255)
);
-- microsoft office/excel examples
insert into plmoment_testdata
     values (1, 3, 'https://support.office.com (SKEW, SKEW.P etc.)');
insert into plmoment_testdata
     values (1, 4, 'https://support.office.com (SKEW, SKEW.P etc.)');
insert into plmoment_testdata
     values (1, 5, 'https://support.office.com (SKEW, SKEW.P etc.)');
insert into plmoment_testdata
     values (1, 2, 'https://support.office.com (SKEW, SKEW.P etc.)');
insert into plmoment_testdata
     values (1, 3, 'https://support.office.com (SKEW, SKEW.P etc.)');
insert into plmoment_testdata
     values (1, 4, 'https://support.office.com (SKEW, SKEW.P etc.)');
insert into plmoment_testdata
     values (1, 5, 'https://support.office.com (SKEW, SKEW.P etc.)');
insert into plmoment_testdata
     values (1, 6, 'https://support.office.com (SKEW, SKEW.P etc.)');
insert into plmoment_testdata
     values (1, 4, 'https://support.office.com (SKEW, SKEW.P etc.)');
insert into plmoment_testdata
     values (1, 7, 'https://support.office.com (SKEW, SKEW.P etc.)');
-- large amount of data for testing parallel query
insert into plmoment_testdata
  select 2                           as test_id,
         dbms_random.value(0.95,1.5) as x, 
         'random values'             as description
    from dual connect by level<=10000;    
commit;
/

**/

with testdata as (
  select test_id, x 
    from plmoment_testdata
),
plmoment as (
  select test_id, 
         plmoment_f(x) over(partition by test_id) moments 
    from testdata
)
  select /*+PARALLEL(3)*/
         'PLMoment' as src,
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
  select sub.src,
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
      select 'Oracle' as src,
             ora.test_id as test_id,
             ora.x as x,
             avg(ora.x) over(partition by test_id) as avg$,
             var_samp(ora.x) over(partition by test_id) as var_samp$,
             var_pop(ora.x) over(partition by test_id) as var_pop$,
             stddev_samp(ora.x) over(partition by test_id) as stddev_samp$,
             stddev_pop(ora.x) over(partition by test_id) as stddev_pop$,
             count(ora.x) over (partition by test_id) as count$
        from testdata ora
    ) sub
order by test_id asc, src desc;