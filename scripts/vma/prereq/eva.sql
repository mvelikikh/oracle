--------------------------------------------------------------------------------
--
-- Script:      eva.sql (Extract VAriable)
--
-- Purpose:     Extract variable from command line in format var1=val1,var2=val2.
--              Extracted values assigned to given variables.
--              Up to 16 variables supported
--              save/loadseteva used for saving user environment
--
-- Copyright:   (c) FTC LLC
--
-- Author:      Velikikh Mikhail
--
-- Usage:       @eva <input> <var1> ... <varN>
--              @eva "owner=SYS,table_name=DUAL" owner table_name - assign SYS to owner, DUAL to table_name
--
-- Versions:
--              Vers:   1.0.2.2
--                Auth: Velikikh M.
--                Date: 2014/04/23 11:11
--                Desc: Documentation
--              Vers:   1.0.1.1
--                Auth: Velikikh M.
--                Date: 2013/12/03 14:03
--                Desc: rewritten with alternative quoting mechanism
--              Vers:   1.0.0.0
--                Auth: Velikikh M.
--                Date: 2013/07/24 09:25
--                Desc: Creation
--
--------------------------------------------------------------------------------
@@saveseteva
set feed off hea off timi off ver off term off
def eva_input="dummy=dummy,&1.,dummy=dummy"

col 2 nopri new_v 2
col 3 nopri new_v 3
col 4 nopri new_v 4
col 5 nopri new_v 5
col 6 nopri new_v 6
col 7 nopri new_v 7
col 8 nopri new_v 8
col 9 nopri new_v 9
col 10 nopri new_v 10
col 11 nopri new_v 11
col 12 nopri new_v 12
col 13 nopri new_v 13
col 14 nopri new_v 14
col 15 nopri new_v 15
col 16 nopri new_v 16
col 17 nopri new_v 17

select 'var2' "2", 'var3' "3", 'var4' "4", 'var5' "5", 'var6' "6", 'var7' "7", 'var8' "8", 'var9' "9", 'var10' "10",
       'var11' "11", 'var12' "12", 'var13' "13", 'var14' "14", 'var15' "15", 'var16' "16", 'var17' "17"
  from dual where null^=null;

select '&2.' "2", nvl('&3.', 'x') "3", nvl('&4.', 'x') "4", nvl('&5.', 'x') "5", nvl('&6.', 'x') "6", nvl('&7.', 'x') "7", nvl('&8.', 'x') "8", nvl('&9.', 'x') "9", nvl('&10.', 'x') "10",
       nvl('&11.', 'x') "11", nvl('&12.', 'x') "12", nvl('&13.', 'x') "13", nvl('&14.', 'x') "14", nvl('&15.', 'x') "15", nvl('&16.', 'x') "16", nvl('&17.', 'x') "17"
  from dual;

col var2 nopri new_v &2.
col var3 nopri new_v &3.
col var4 nopri new_v &4.
col var5 nopri new_v &5.
col var6 nopri new_v &6.
col var7 nopri new_v &7.
col var8 nopri new_v &8.
col var9 nopri new_v &9.
col var10 nopri new_v &10.
col var11 nopri new_v &11.
col var12 nopri new_v &12.
col var13 nopri new_v &13.
col var14 nopri new_v &14.
col var15 nopri new_v &15.
col var16 nopri new_v &16.
col var17 nopri new_v &17.

select regexp_substr(q'[&eva_input.]', ',&2.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var2,
       regexp_substr(q'[&eva_input.]', ',&3.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var3,
       regexp_substr(q'[&eva_input.]', ',&4.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var4,
       regexp_substr(q'[&eva_input.]', ',&5.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var5,
       regexp_substr(q'[&eva_input.]', ',&6.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var6,
       regexp_substr(q'[&eva_input.]', ',&7.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var7,
       regexp_substr(q'[&eva_input.]', ',&8.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var8,
       regexp_substr(q'[&eva_input.]', ',&9.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var9,
       regexp_substr(q'[&eva_input.]', ',&10.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var10,
       regexp_substr(q'[&eva_input.]', ',&11.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var11,
       regexp_substr(q'[&eva_input.]', ',&12.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var12,
       regexp_substr(q'[&eva_input.]', ',&13.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var13,
       regexp_substr(q'[&eva_input.]', ',&14.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var14,
       regexp_substr(q'[&eva_input.]', ',&15.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var15,
       regexp_substr(q'[&eva_input.]', ',&16.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var16,
       regexp_substr(q'[&eva_input.]', ',&17.=([^=]+)(,[^,]+=)', 1, 1, 'c', 1) var17
  from dual;

undef 1
undef 2
undef 3
undef 4
undef 5
undef 6
undef 7
undef 8
undef 9
undef 10
undef 11
undef 12
undef 13
undef 14
undef 15
undef 16
undef 17

undef eva_input

undef nopri

col 2 cle
col 3 cle
col 4 cle
col 5 cle
col 6 cle
col 7 cle
col 8 cle
col 9 cle
col 10 cle
col 11 cle
col 12 cle
col 13 cle
col 14 cle
col 15 cle
col 16 cle
col 17 cle

col var2 cle
col var3 cle
col var4 cle
col var5 cle
col var6 cle
col var7 cle
col var8 cle
col var9 cle
col var10 cle
col var11 cle
col var12 cle
col var13 cle
col var14 cle
col var15 cle
col var16 cle
col var17 cle

@@loadseteva
