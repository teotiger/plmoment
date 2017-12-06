create or replace function kurtosis_helper (
  opt_in  in integer, -- 1=population_kurtosis, 2=sample_kurtosis,
  opt_out in integer, -- 3=population_excess_kurtosis, 4=sample_excess_kurtosis
  val     in number,
  n       in integer
) return number
  authid definer
is
  population_kurtosis          number;
  sample_kurtosis              number;
  population_excess_kurtosis   number;
  sample_excess_kurtosis       number;
  sample_excess_factor         number;
  sample_factor                number;
  subtype valid_vals is simple_integer range 1..4 not null;
  l_opt_in                     valid_vals := opt_in;
  l_opt_out                    valid_vals := opt_out;
  l_val                        number not null := val;
  l_n                          simple_integer := n;
begin
  sample_excess_factor := 3*(l_n - 1) * (l_n - 1) / ((l_n - 2) * (l_n - 3));
  sample_factor        := l_n *(l_n + 1) * (l_n - 1) / ((l_n - 2) * (l_n - 3));

  case
    l_opt_in
    when 1 then
      population_kurtosis := val;
      population_excess_kurtosis := val - 3;
      sample_kurtosis := ( population_kurtosis / n ) * sample_factor;
      sample_excess_kurtosis := sample_kurtosis - sample_excess_factor;
    when 2 then
      sample_kurtosis := val;
      sample_excess_kurtosis := sample_kurtosis - sample_excess_factor;
      population_excess_kurtosis
      := ((sample_excess_kurtosis*(l_n-2)*(l_n-3)/(l_n-1)) - 6) / (l_n+1);
      population_kurtosis := population_excess_kurtosis + 3;
    when 3 then
      population_excess_kurtosis := val;
      population_kurtosis := val + 3;
      sample_kurtosis := ( population_kurtosis / n ) * sample_factor;
      sample_excess_kurtosis := sample_kurtosis - sample_excess_factor;
    when 4 then
      sample_excess_kurtosis := val;
      sample_kurtosis := val + sample_excess_factor;
      population_excess_kurtosis
      := ((sample_excess_kurtosis*(l_n-2)*(l_n-3)/(l_n-1)) - 6) / (l_n+1);
      population_kurtosis := population_excess_kurtosis + 3;
  end case;
 
  return
    case l_opt_out
      when 1 then population_kurtosis
      when 2 then sample_kurtosis
      when 3 then population_excess_kurtosis
      when 4 then sample_excess_kurtosis
    end;
end;
