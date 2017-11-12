create or replace type body plmoment_t
is
--------------------------------------------------------------------------------
static function odciaggregateinitialize(
    sctx  in out nocopy plmoment_t)
  return number
is
begin
  sctx:=plmoment_t(0,                   -- n
                   0.0, 0.0, 0.0, 0.0); -- M1-M4
  return odciconst.success;
end;
--------------------------------------------------------------------------------
member function odciaggregateiterate(
    self  in out nocopy plmoment_t,
    x     in            number)
  return number
is
  delta number;
  delta_n number;
  delta_n2 number;
  term1 number;
  n1 integer;
begin
  n1:=self.n;
  self.n:=self.n+1;
  delta:=x-self.M1;
  delta_n:=delta/self.n;
  delta_n2:=delta_n*delta_n;
  term1:=delta*delta_n*n1;
  
  self.M1:=self.M1 + delta_n;
  self.M4:=self.M4 + (term1 * delta_n2 * (n*n - 3*n + 3) + 6 * delta_n2 * M2 - 4 * delta_n * M3);
  self.M3:=self.M3 + ( (term1*delta_n*(n-2)) - (3*delta_n*self.M2) );
  self.M2:=self.M2 + term1;
return odciconst.success;
end;
--------------------------------------------------------------------------------
member function odciaggregatemerge(
    self in out nocopy plmoment_t,
    ctx2 in            plmoment_t)
  return number
is
begin
  return odciconst.success;
end;
--------------------------------------------------------------------------------
member function odciaggregateterminate(
    self  in            plmoment_t,
    o_val    out nocopy plmoment_out_t,
    flags in            number)
  return number
is
begin
  o_val:=plmoment_out_t(
    --mean
    self.M1,
    --variance_s
    self.M2/(self.n-1.0),
    --variance_p
    self.M2/(self.n),
    --stddev_s
    sqrt( self.M2/(self.n-1.0) ),
    --stddev_p
    sqrt( self.M2/(self.n) ),
    --skewness_s
    sqrt(self.n) * self.M3/ power(self.M2,1.5),
    --kurtosis_s
    to_number(null),
    --excess_s 
    to_number(null)
  );
  return odciconst.success;
end;
--------------------------------------------------------------------------------
end;
/