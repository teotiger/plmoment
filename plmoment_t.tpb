create or replace type body plmoment_t
is
--------------------------------------------------------------------------------
static function odciaggregateinitialize(
    sctx  in out nocopy plmoment_t)
  return number
is
begin
  dbms_output.put_line('init');
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
  n1 integer;
  delta number;
  delta_n number;
  delta_n2 number;
  term1 number;
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
  n number;
  f number;
  delta number;
  delta2 number;
  delta3 number;
  delta4 number;
begin
  dbms_output.put_line('Cnt '||self.n);
  if self.n=0 then
    self.n:=ctx2.n;
    self.M1:=ctx2.M1;
    self.M2:=ctx2.M2;
    self.M3:=ctx2.M3;
    self.M4:=ctx2.M4;    
  else
    n:=self.n+ctx2.n;
f:=self.n+ctx2.n;

    delta:=ctx2.M1-self.M1;
    delta2:=delta*delta;
    delta3:=delta*delta2;
    delta4:=delta2*delta2;

dbms_output.put_line(self.M3);
dbms_output.put_line(ctx2.M3);

    self.M1:=(self.n*self.M1 + ctx2.n*ctx2.M1) / n;
    self.M4:=self.M4+ctx2.M4
            +(self.n*ctx2.n*(self.n*self.n - self.n*ctx2.n + ctx2.n*ctx2.n)/n*n*n*delta4)
            +(6*(self.n*self.n*ctx2.M2 + ctx2.n*ctx2.n*self.M2)/n*n*delta2)
            +(4*(self.n*ctx2.M3 - ctx2.n*self.M3)/n*delta);
    self.M3:=self.M3+ctx2.M3
            +(self.n*ctx2.n*(self.n-ctx2.n)/(f*f)*delta3)
            +(3.0*(self.n*ctx2.M2 - ctx2.n*self.M2)/f*delta);
    
    self.M2:=self.M2 + ctx2.M2 + (delta2*self.n*ctx2.n / n);
    
    
--    M3:=self.M3 + ctx2.M3 + (delta3*self.n*ctx2.n*(self.n-ctx2.n) / (n*n));
--    M3:=M3 + (3.0*delta*(self.n*ctx2.M2 - ctx2.n*self.M2) / n);


    self.n:=n;
  end if;
/*
    combined.M3 = a.M3 + b.M3 + 
                  delta3 * a.n * b.n * (a.n - b.n)/(combined.n*combined.n);
    combined.M3 += 3.0*delta * (a.n*b.M2 - b.n*a.M2) / combined.n;
     
    combined.M4 = a.M4 + b.M4 + delta4*a.n*b.n * (a.n*a.n - a.n*b.n + b.n*b.n) / 
                  (combined.n*combined.n*combined.n);
    combined.M4 += 6.0*delta2 * (a.n*a.n*b.M2 + b.n*b.n*a.M2)/(combined.n*combined.n) + 
                  4.0*delta*(a.n*b.M3 - b.n*a.M3) / combined.n;
  */   
  return odciconst.success;
end;
--------------------------------------------------------------------------------
member function odciaggregateterminate(
    self  in            plmoment_t,
    o_val    out nocopy plmoment_out_t,
    flags in            number)
  return number
is
  l_skewness_p number;
  l_kurt_p number;
begin
  l_skewness_p:=sqrt(self.n) * self.M3 / power(self.M2,1.5);
  l_kurt_p:=(self.n*self.M4) / (self.M2*self.M2);
  
  o_val:=plmoment_out_t(
    --mean
    self.M1,
    --variance_p
    self.M2 / (self.n),
    --variance_s
    self.M2 / (self.n-1.0),
    --stddev_p
    sqrt(self.M2 / (self.n)),
    --stddev_s
    sqrt(self.M2 / (self.n-1.0)),
    --skewness_p
    l_skewness_p,
    --skewness_s
    l_skewness_p * sqrt(self.n * (self.n-1)) / (self.n-2),
    --kurtosis_p
    l_kurt_p,
    --kurtosis_s
    ((l_kurt_p/self.n)*self.n*(self.n+1)*(self.n-1)) / ((self.n-2)*(self.n-3)),
    --excess_p
    l_kurt_p-3,
    --excess_s
    (((l_kurt_p/self.n)*self.n*(self.n+1)*(self.n-1)) / ((self.n-2)*(self.n-3)))
      -(3*(self.n-1)*(self.n-1) / ((self.n-2)*(self.n-3)))
  );

  return odciconst.success;
end;
--------------------------------------------------------------------------------
end;
/