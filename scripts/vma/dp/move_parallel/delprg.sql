def l_prg_name="&1."

exec sys.dbms_scheduler.drop_program( '&l_prg_name.')

undef l_prg_name
