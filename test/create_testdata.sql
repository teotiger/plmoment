create table plmoment_testdata (
  test_id     integer,
  x           number,
  description varchar2(255)
);
/
-- microsoft office/excel examples
insert into plmoment_testdata
     values (1, 3, 'https://support.office.com (SKEW, SKEW.P, KURT etc.)');
insert into plmoment_testdata
     values (1, 4, 'https://support.office.com (SKEW, SKEW.P, KURT etc.)');
insert into plmoment_testdata
     values (1, 5, 'https://support.office.com (SKEW, SKEW.P, KURT etc.)');
insert into plmoment_testdata
     values (1, 2, 'https://support.office.com (SKEW, SKEW.P, KURT etc.)');
insert into plmoment_testdata
     values (1, 3, 'https://support.office.com (SKEW, SKEW.P, KURT etc.)');
insert into plmoment_testdata
     values (1, 4, 'https://support.office.com (SKEW, SKEW.P, KURT etc.)');
insert into plmoment_testdata
     values (1, 5, 'https://support.office.com (SKEW, SKEW.P, KURT etc.)');
insert into plmoment_testdata
     values (1, 6, 'https://support.office.com (SKEW, SKEW.P, KURT etc.)');
insert into plmoment_testdata
     values (1, 4, 'https://support.office.com (SKEW, SKEW.P, KURT etc.)');
insert into plmoment_testdata
     values (1, 7, 'https://support.office.com (SKEW, SKEW.P, KURT etc.)');
-- large amount of data for testing parallel query
insert into plmoment_testdata
  select 2                           as test_id,
         dbms_random.value(0.95,1.5) as x, 
         'random values'             as description
    from dual connect by level<=10000;    
commit;
/