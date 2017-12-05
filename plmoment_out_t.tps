create or replace type plmoment_out_t authid definer
as
  object
  (
    mean        number,
    variance_p  number,
    variance_s  number,
    stddev_p    number,
    stddev_s    number,
    skewness_p  number,
    skewness_s  number,
    kurtosis_p  number,
    kurtosis_s  number,
    excess_p    number,
    excess_s    number
  );
/