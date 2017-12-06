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
  term2 number;
begin
  self.n:=self.n+1;

  delta:=x-self.M1;
  delta_n:=delta/self.n;
  delta_n2:=delta_n*delta_n;
  term1:=delta*delta_n*(self.n-1);
  term2:=(self.n*self.n) - (3*self.n) + 3;
  
  self.M4:=self.M4 + (term1*delta_n2*term2) + (6*delta_n2*self.M2)
                   - (4*delta_n*self.M3);
  self.M3:=self.M3 + ( (term1*delta_n*(self.n-2)) - (3*delta_n*self.M2) );
  self.M2:=self.M2 + term1;
  self.M1:=self.M1 + delta_n;

  return odciconst.success;
end;
--------------------------------------------------------------------------------
member function odciaggregatemerge(
    self in out nocopy plmoment_t,
    ctx2 in            plmoment_t)
  return number
is
  total number;
  total2 number;
  total3 number;
  delta number;
  delta2 number;
  delta3 number;
  delta4 number;
  sn2 number;
  cn2 number;
begin
  dbms_output.put_line('=> Parallel Execution with n='||ctx2.n);

  if self.n=0 then
    self.n:=ctx2.n;
    self.M1:=ctx2.M1;
    self.M2:=ctx2.M2;
    self.M3:=ctx2.M3;
    self.M4:=ctx2.M4;    
  else
    total:=self.n+ctx2.n;
    total2:=total*total;
    total3:=total*total2;
    delta:=ctx2.M1-self.M1;
    delta2:=delta*delta;
    delta3:=delta*delta2;
    delta4:=delta2*delta2;
    sn2:=self.n*self.n;
    cn2:=ctx2.n*ctx2.n;

    self.M4:=1;--self.M4+ctx2.M4
--             +(delta4*self.n*ctx2.n*(sn2 - self.n*ctx2.n + cn2) / total3)
--             +(6*delta2*(sn2*ctx2.M2 + cn2*self.M2) / total2)
--             +(4*delta*(self.n*ctx2.M3 - ctx2.n*self.M3) / total);
    self.M3:=self.M3+ctx2.M3
             +(self.n*ctx2.n*(self.n-ctx2.n)/total2*delta3)
             +(3.0*(self.n*ctx2.M2 - ctx2.n*self.M2)/total*delta);    
    self.M2:=self.M2 + ctx2.M2 + (delta2*self.n*ctx2.n / total);
    self.M1:=(self.n*self.M1 + ctx2.n*ctx2.M1) / total;
    self.n:=total;
  end if;

  return odciconst.success;
end;
--------------------------------------------------------------------------------
member function odciaggregateterminate(
    self  in            plmoment_t,
    o_val    out nocopy plmoment_out_t,
    flags in            number)
  return number
is
  skewness_p number;
  kurt_p number;
begin
  skewness_p:=sqrt(self.n) * self.M3 / power(self.M2,1.5);
  kurt_p:=(self.n*self.M4) / (self.M2*self.M2);
  
  o_val:=plmoment_out_t(
    --mean
    self.M1,
    --variance_p
    self.M2 / (self.n),
    --variance_s
    self.M2 / (self.n-1),
    --stddev_p
    sqrt(self.M2 / (self.n)),
    --stddev_s
    sqrt(self.M2 / (self.n-1)),
    --skewness_p
    skewness_p,
    --skewness_s
    skewness_p * sqrt(self.n * (self.n-1)) / (self.n-2),
    --kurtosis_p
    kurt_p,
    --kurtosis_s
    ((kurt_p/self.n)*self.n*(self.n+1)*(self.n-1)) / ((self.n-2)*(self.n-3)),
    --excess_p
    kurt_p-3,
    --excess_s
    (((kurt_p/self.n)*self.n*(self.n+1)*(self.n-1)) / ((self.n-2)*(self.n-3)))
      -(3*(self.n-1)*(self.n-1) / ((self.n-2)*(self.n-3)))
  );

  return odciconst.success;
end;
--------------------------------------------------------------------------------
end;
/