create or replace type plmoment_out_t authid definer
as
  object
  (
    mean        number,
    variance_s  number,
    variance_p  number,
    stddev_s    number,
    stddev_p    number,
    skewness_s  number,
    kurtosis_s  number,
    excess_s    number
  );
/