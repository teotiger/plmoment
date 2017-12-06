create or replace type plmoment_t authid definer
as
  object
  (
    n number,
    M1 number, 
    M2 number, 
    M3 number, 
    M4 number,
    ----------
    static function odciaggregateinitialize(
      sctx in out nocopy plmoment_t)
    return number,
    member function odciaggregateiterate(
      self in out nocopy plmoment_t,
      x    in            number)
    return number,
    member function odciaggregatemerge(
      self in out nocopy plmoment_t,
      ctx2 in            plmoment_t)
    return number,
    member function odciaggregateterminate(
      self  in            plmoment_t,
      o_val    out nocopy plmoment_out_t,
      flags in            number)
    return number
  );
/ 
