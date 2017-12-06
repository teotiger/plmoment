--*****************************
-- PLMOMENT INSTALLATION SCRIPT
--*****************************
set scan off;
prompt => Start installation process
@@src/plmoment_out_t.tps
@@src/plmoment_t.tps
@@src/plmoment_t.tpb
@@src/plmoment_f.fnc
exit
