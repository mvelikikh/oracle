@save_sqlplus_settings
col action for a30
col module for a30
col select_stmt nopri
col session_id for a10
col wiki_table nopri
select to_char(max(sample_time), 'hh24:mi') day_time,
       module,
       action,
       session_id||','||session_serial# session_id,
       ecid,
       sql_id,
       extract(hour from max(sample_time) - sql_exec_start)*60*60+extract(minute from max(sample_time) - sql_exec_start)*60+extract(second from max(sample_time) - sql_exec_start) duration,
       regexp_replace(regexp_replace('
        select ''select * from table(dbms_xplan.display_awr(''''''||ash.sql_id||'''''', ''||ash.sql_plan_hash_value||''));'' display_awr,
               ''select * from table(dbms_xplan.display_cursor(''''''||ash.sql_id||'''''', ''||ash.sql_child_number||'', ''''peeked_binds''''));'' display_cursor, 
               ash.* 
          from ashdump_vw ash
         where module='''||module||''' 
           and action='''||action||''' 
           and session_id='||session_id||'
           and session_serial#='||session_serial#||'
           and sql_id='''||sql_id||'''
           and sql_exec_id='||sql_exec_id||'
         order by sample_id;', '^'||chr(10), ''), '^        ', '', 1, 0, 'm')
         select_stmt,
       '| '||action||' | '||ecid||' | '||to_char(sql_exec_start, 'hh24:mi')||' | '||to_char(max(sample_time), 'hh24:mi')||' | '||
       (extract(hour from max(sample_time) - sql_exec_start)*60*60+extract(minute from max(sample_time) - sql_exec_start)*60+extract(second from max(sample_time) - sql_exec_start))||' | '||
       sql_id|| ' | | (?) | ' wiki_table
  from v$active_session_history ash
 where sql_exec_id is not null
   and not (module = 'QPI.PayMap' and action = 'QPI.PayMap')
   and not (module = 'QPAY.PayMap' and action = 'QPAY.PayMap')
   and not (module = 'QPI.OnlinePayMap' and action = 'QPAY.OnlinePayMap')
   and not (module = 'PAYMAP' and action in ('QPAY.PayMapCLOB', 'QPAY.PayMap'))
   and not (module like 'oracle@vulkan%')
   and not (module = 'SQL*Plus')
   and not (module = 'orecv@angel (TNS V1-V3)')
   and not (module in ('PL/SQL Developer', 'plsqldev.exe'))
   and not (sql_id in (
     '0b5j6cy00jqbv'/*KDP-514*/ 
     ,'fs51atycdtv8x'/*KDP-511*/
     ,'cccf20mk50h2y'/*KDP-506*/
     ,'96jj153tbqphx', 'bbha3zf5g7bfp', '774yp2ynw52y7', 'bzbd2fj1xn545', 'db9ru0h3znzmq'/*KDP-504*/
     ,'fa6km120pjmt3'/*KDP-621*/
     ,'f6yjwf674xgqa'/*KDP-629*/
     ,'fm25d8mwxs18n'/*KDP-549*/
     ,'1rjvmz0dbhd9s'/*KDP-492*/
     ,'47gs00kwhzup1'/*KDP-636*/
     ,'7pmamp7macpy3'/*KDP-625*/
     ,'2t9hft931rj42'/*KDP-630*/
     ,'f5dgjzn5nd996'/*KDP-650*/
     ,'8sm6sm6avanq9'/*KDP-643*/
     ,'b8w8ybrfw9kxr', 'gn6j73vyjh1vh'/*KDP-644*/
     ,'7c91kjbk5cnvw'/*KDP-645*/
     ,'4gqnr4b57jya4'/*KDP-649*/
     ,'3x3jc1c0j2j6m'/*enq:TX - row lock contention*/
     ,'gzs5pz4rp0tt9'/*KDP-654*/
     ,'332tk3c4xnnnf'/*KDP-655*/
     ,'9cd3nxwt7aym2'/*KDP-656*/
     ,'13fq8vvsuswx3', '2kw5h8pk7m1v5', '7wtbswhv14xhw'/*KDP-657*/
     ,'3t1wfwqb0gk69'/*KDP-658*/
     ,'gq4uuy2j8dprz'/*KDP-660*/
     ,'1394kmh4y29c9'/*KDP-670*/
     ,'a8tsgu3a58q43'/*KDP-748*/
     ,'52h5xr6m5n6c1'/*KDP-743*/
     ,'arasnw9jc1qx3'/*KDP-764*/
     ,'grpk3ra49n9qd'/*KDP-783*/
     ,'bm8jj1wwzr6z7'/*KDP-784*/
     ,'actwg3xgy77b8'/*KDP-793*/
     ,'5r2bs7m6kdu7j'/*KDP-814*/
     ,'a5sna0puwqk5u'/*KDP-839*/
     ,'51zcfaxcswym9'/*KDP-971*/
     ,'a8mssxvkx167g'/*KDP-1160*/
     ,'dypvb74q05wby'/*KDP-1207*/
     ,'d3qzuwvks55hp'/*KDP-1282*/
     ,'03xq575515b5m'/*KDP-1396*/
     ,'7fh0wz19fgyqz'/*KDP-1423,KDP-1441*/
     ,'4k08g04wbjwnw'/*KDP-1472*/
     ,'52w8u9pgx3pc8', '5smy17wyf87yz'/*KDP-1553*/
     ,'c65ar5tpc9cb1'/*KDP-1731*/
     ,'833hffdya5t3a'/*KDP-1936*/
     ,'dswxmu3pqwxa6'/*KDP-1939*/
     ,'950jm9cyca1tw'/*KDP-1965*/
     ,'491qmnt566xdu'/*KDP-1989*/
     ,'f0ag1pk68zvnm'/*MAINTENANCE-3069*/
     ,'7x71407dva7r6'/*KDP-2213*/
     ,'6bwqzryunxrmu'/*kdp-2136*/
     ,'dq3fcaxwhdymc'/*KDP-2372*/
     ,'2mhh3pt4pxh87'/*KDP-2377*/
     ,'1t8rq9k1htvfd','0fp7y3ks25au1'/*KDP-2451*/
     ,'b1hww3pxuus5j'/*KDP-2549*/
     , '8buf23wqd6mp7'/*KDP-2535*/
     ,'074bxprmjk9gc'/*KDP-2354*/
     , 'f3fj0tvfm1vy6'/*KDP-2452*/
     , 'gthk30pfxrpth'/*KDP-2611 KDP-2618*/
     ,'aq0cs866j23jt'/*KDP-2619*/
     ,'8zyztmc4tav5t'/*KDP-2636*/
     ,'fvm2asdzfa4mq'/*KDP-2669*/
     ,'cn9ff97ffam82'/*KDP-2683*/
     ,'4scu37mtg8dx8'/*KDP-2692*/
     ,'ca0rqcg34979j'/*KDP-2730*/
     ,'332tk3c4xnnnf'/*KDP-2731*/
     ,'b1ru8c1ma0r5c'/*KDP-2735*/
     ,'gffmba2015rtr'/*KDP-2739*/
     ,'9awfpajgz4g7u'/*KDP-2741*/
     ,'9urmyfz333zz6'/*KDP-2750*/
     ,'1gcbqaq4wygqr'/*KDP-2759*/
     ,'avm9zzcttyxf0'/*KDP-2764*/
     ,'g8fu5d4akq3v1'/*KDP-2793*/
     ,'56xkm4u95y5yz'/*KDP-2797*/
     ,'c33fz5tza4k18'/*KDP-2809*/
     ,'43z33vfuz4ca5'/*KDP-2811*/
     ,'3yk79z3ja54s5'/*KDP-2814*/
     ,'aw2zv0wab7zt7'/*KDP-2815*/
     ,'c7j7ddx70wrwc'/*KDP-2816*/
     ,'22jhjtksfm3xs'/*KDP-2828*/
     ,'4g1h5j9gqtm2y'/*KDP-2850*/
     ,'3g3jh2qj35mjp'/*KDP-2853*/
     ,'652r3rchy6f71'/*KDP-2855*/
     ,'1mpcnvqzf7acx'/*KDP-2857*/
     ,'c2uxhbfrqzndr'/*KDP-2867*/
     ,'12jxxc99b9rgj'/*KDP-2868*/
     ,'64snswvyksfcq'/*KDP-2869*/
     ,'80xw0as130nb9'/*KDP-3086*/
     ,'4uqdtyxx2h76u', '2ukvtwydjzsvb'/*KDP-3511*/
     ,'12c4t48v3gk23'/*KDP-3622*/
     ,'dugt48k2389tv'/*KDP-3649*/
     ,'bac5dvkunc6gd', 'a9qmrqg1y013w'/*KDP-3667*/
     , 'a9qmrqg1y013w'/*KDP-4234*/
     , '7gdar9pt0jx38'/*KDP-4334*/
     , '040zdppnq2zu4'/*KDP-4246*/
     , '7dbfg2vmn1s8k'/*KDP-4352*/
     , '60mwy2n95wjky'/*KDP-5105*/
     , '3rnzcs9zyjk49'/*KDP-5137*/
     , '8wt1qjrc33g37'/*KDP-5280*/
     , '00uws15vy4avc'/*KDP-5312*/
     , '03g8yn4ssqr71'/*KDP-5318*/
     , 'f5mmrx73y9pw4'/*KDP-5362*/
     , 'b757np8k3huk1'/*KDP-1567 KDP-5421*/
     , '4m5qsd99q0655'/*KDP-5432*/
     , '4h45hu7qxdd5b'/*KDP-5433*/
     , '98a7sd04d7ry1'/*KDP-5436*/
     , 'bczvjtw5xp0p7'/*KDP-5441*/
     , 'bk84pkpca4sgb'/*KDP-5450*/
     , '6f9t2tbpc2nr5'/*KDP-5452*/
     , '334zvzx4fd0gv'/*KDP-5601*/
     , '8ccx6xpaakpsf'/*KDP-5613*/
     , 'a17nn6rs7ttn9'/*KDP-5616*/
     , 'brxx5vwg2cwyh'/*KDP-5668*/
     , 'dah7jn10p1kdc'/*KDP-5686*/
     , '9bzywgy5kh1w6'/*KDP-5805*/
     , '0uf5kfddgw3x0'/*KDP-5808*/
     , 'f57dzsr3uakg5', 'g3781tua0mg9v'/*KDP-5814*/
     , 'bgcnbg3brsppm', '0wtu5x2c5mnhq', '6f7vfb434jhhy', '5y046mzzvwqzq'/*KDP-5820*/
     , '3pcj43tg94abq'/*KDP-5843*/
     , '198c26h3v7uua'/*KDP-5859*/
     , 'bmf60k5fgjvjt'/*KDP-6728*/
     , 'b960xyumczwyq'/*KDP-6730*/
     , 'dfky6bnv8psh4'/*KDP-6760*/
     , 'gby90u69a1avv'/*KDP-6772*/
     , '6jvtjgba8xn6g'/*KDP-6779*/
     , '9rbn27h2ty2ng'/*KDP-6797*/
     , 'f6yadg183n52x'/*KDP-6834*/
     , 'b1mh74uz49f8h'/*KDP-6974*/
     , '7gx7pg9mywyjy'/*KDP-6996*/
     , '6pns2brcu84xc'/*KDP-7165*/
     , '226pdmm8kb36v'/*KDP-7177*/
     , '3k1a904ryppa1'/*KDP-7185*/
     , '5wtqv99zm9my6'/*KDP-7253*/
     , 'bxya6qzvwssfj'/*KDP-7255*/
     , '0fj8k1m41jrav'/*KDP-7300*/
     , '491m7fd9wkfbt'/*KDP-7458 KDP-8870*/
     , '06mwvtfw7xg62'/*KDP-7552*/
     , 'f5b11cy5dg9su'/*KDP-7523*/
     , '554jsac5dyww9'/*KDP-7681*/
     , '20vx91gzcpbj6'/*KDP-7684*/
     , 'dhk4gh1p4hxa3'/*KDP-7694*/
     , 'c1gvvda9ua0cb'/*KDP-7850*/
     , '2uxskjsbhjm77'/*KDP-7852*/
     , 'c5132fx9nxpjh'/*KDP-7866*/
     , 'gcn7jp2vadx6q'/*KDP-7893*/
     , '7ppxtnu0sq6qc'/*KDP-7904*/
     , 'cf87qz1jxpms1'/*KDP-7950*/
     , '9zn6w2ju79qq8'/*KDP-7996*/
     -- closed, 'gyty25sguhj4t'/*KDP-8073*/
     , 'fbhuauc8jq452'/*KDP-8081*/
     , '223vu7jp2y76k'/*KDP-8089*/
     , 'f0yuzqas58njw'/*KDP-8120*/
     , '6a2ph7wwf2gas'/*KDP-8131*/
     , '1chx9nmh89j8m'/*KDP-8335*/
     , '44aj32x8xzzzk'/*KDP-8355 KDP-8357*/
     , '332fq4bn5cgya', '0rwt3w0gjkzch', '3tnf8psmrt3jp', 'aqankx4a9cx71'/*KDP-8517*/
     , '13981hxsr0w4v'/*KDP-8519*/
     , '6wggh4haqnkba'/*KDP-8571*/
     , '0hvc568u3z4wa'/*KDP-8574*/
     , 'ah167cjgq2bw1'/*KDP-8579*/
     , '26tqkkvw262a1'/*KDP-8581*/
     , '3t0hadunq5jru', '98vjds2nmh3v9'/*KDP-8689*/
     , 'cp3h8fnn3jvtr'/*KDP-8690*/
     , '5jr2rq4t85g7z'/*KDP-8694*/
     , '3bvv27frrn7jj'/*KDP-8708*/
     , '8c8wn871dn2gj'/*KDP-8765*/
     , '7ugtzts4yykxn'/*KDP-8866*/
     , '8mu105vrv82as'/*KDP-8870*/
     , '7fhhzp3qfbhd1'/*KDP-9006*/
     , '7nr4pah6vckud'/*KDP-9090*/
     , 'amvaa5g3h3nwq'/*KDP-9181*/
     , 'fjkarymw0xzm2'/*KDP-9184*/
     , '7pzf9wn3z7c33'/*KDP-9258*/
     , '5j9vunx7kujru'/*KDP-9358*/
     , 'f207hfk2wanh7'/*KDP-9359*/
     , '749xvs741zm05'/*KDP-9377*/
     , 'gncuyjy5fvsgr'/*KDP-9510*/
     , '68q7938pgbqdz'/*KDP-9599*/
     , '8ykrcr4ay17gj'/*KDP-9654*/
     , 'd19d9v00sufg6'/*KDP-9941*/
     , '5qm9fzv6xb5pg'/*KDP-10033*/
     , '3ytdxq8z541fr'/*KDP-10128*/
     , '117z65a5a5dwv'/*KDP-10128*/
     , 'c2p4c9jfa68my'/*KDP-10182*/
     , 'dtv3guuf8cnuk'/*KDP-10183*/
     , '6g26mn9pwkubt'/*KDP-10280*/
     , '8kbyvc15pzbnu'/*KDP-10382*/
     , '3rd19tvkvs4k4'/*KDP-10384*/
     , '67w2jyhuxrhd0'/*KDP-10391*/
     , '81v5kpbh8sqkq'/*KDP-10392*/
     , 'frq615n36pgy2'/*KDP-10465*/
     , '7vjyx9rkr281p'/*DP-165101*/
     , '0jxwyb7tutfzk'/*DP-221734*/
     , '2y3spq05fu1g2'/*DP-222808*/
     , '05k5qmsvff6kb'/*DP-222810*/
     , '1x1mh83guvpmr'/*DP-223118*/
     , '5gdtr2dtdcm3h'/*DP-224001*/
     , '22vsrnnp1vdwj'/*DP-224028*/
     , '7s17s3qw7kh32'/*DP-224451*/
     , '2dp2gwm493uvq'/*DP-225387*/
     , '94cw0ugpcf2xz'/*DP-225465*/
     , 'd0hvjy3yfy1h6', 'dfj0fffghb77t', '05d1tx96np6kj'/*DP-230202*/
     , '639n8pqdbu878', '77vb1yy5r6v07', '8r1z6ju4kz6nf'/*DP-230288*/
     , '6hgjcbuc9zd8y'/*DP-230791*/
     , 'gk3bzmzqtw4hr'/*DP-240509*/
     , '6057y90j9frbw'/*DP-244783*/
     --, '6dvbx9utkq6m4'/*DP-246557*/
     , 'fyguvh3ybf844'/*DP-251061*/
     , 'bxa3qwnmyrtm1', 'bjn4qbyp3m0bw'/*DP-252635*/
     , '8n2dsn2c6ysj7' /*DP-256564*/
     , '8z3dbzutmqmd4' /*DP-256581*/
     , 'gjh0vnf2va6v9' /*DP-267644*/
     , '5w4azvbcdcjf9' /*DP-267644*/
     , 'fcrqc1870k1yg', 'ftgqaxbmtdxd1' /*DP-269016*/
     , 'c0z2yaawxwgvv' /*DP-279581*/
     , '5nc963myjb9n7' /*DP-281550*/
     , '470sc24mm5a09' /*DP-284020*/
  ))
   and not (sql_opname in ('PL/SQL EXECUTE'))
   -- reports
   and not (module in ('TXREPORTDATA', 'JDBC Thin Client', 'QPAY.ReportData', 'REPORTDATA', 'TXLIST', 'FULLREPORT', 'FRAUDDATA', 'CARDTRANSFER','NEWCARDLIST', 'QPI.PayDocReport', 'OPERATORLIST', 'NEWCARDRETAILERLIST', 'QPI.CreditBankList') and action in ('QPAY.ReportData', 'QPAY.PayerSearch', 'QPAY.FullReport', 'QPAY.TxList', 'QPAY.FraudData', 'QPAY.CardTransfer', 'QPAY.NewCardList', 'QPI.PayDocReport', 'QPAY.OperatorList', 'QPAY.NewCardRetailerList', 'QPAY.TxReportData', 'QPAY.CreditBankList'))
   -- em
   and not (module = 'MMON_SLAVE' and action in ('Auto-Flush Slave Action', 'Auto-Purge Slave Action', 'Autotask Slave Action', 'Advisor Task Maintenance', 'Check SMB Size'))
   and not (module = 'Oracle Enterprise Manager.Metric' or module = 'Oracle Enterprise Manager.Metric Engine')
   and not (module='DBMS_SCHEDULER' and (action like 'ORA$AT_SA_SPC_SY_%' or action like 'ORA$AT_OS_OPT_SY_%' or action like 'ORA$AT_SQ_SQL_SW%' or action='PURGE_LOG' or action like 'MGMT_CONFIG_JOB_%'))
   and not (module = 'emagent@proton2 (TNS V1-V3)' and sql_id = '7105sy0u9jwzj')
   and not (sql_id = 'a4a1wsdq4z6ah') -- audit_session
   and not (module = 'Realtime Connection' and sql_id = 'b8b5jdj7khuaw')
   and not (module = 'emagent_SQL_oracle_database' and action in ('key_profiles', 'latest_hdm_findings', 'db_autotask_client', 'ha_backup', 'db_recSegmentSettings_sysseg', 'db_recSegmentSettings'))
   and not (module = 'emagent_SVRGENALRT_oracle_database' and action = 'SYS.ALERT_QUE')
   and not (module = 'Realtime Connection' and action in ('SQL_MONITOR', 'GENERAL_REGION_METRIC', 'MODULE_METRIC', 'DB_WAIT_CLASS', 'ASH_ROLLUP', 'DB_PQ', 'ASH_WAIT_EVENTS', 'HOME_SUMMARY', 'DB_HOST', 'SERVICE_METRIC'))
   and not (module = 'Admin Connection' and action in ('/database/instance/sqlDetail', '/database/instance/autoSqlTune', '/database/instance/autoTask', '/database/instance/sqlDetailsReport', '/database/instance/advisorTasks'))
   -- scj_ss_schedule
   and not (
         sql_id in ('4pw7hmu6c4pxc', '1y005tqnjrjvf', 'bq6fuas480h2d', 'ggw9rw2tucx8k', '06f7dqgu5qkq7', '4wphu4qg84bk6', '3327xa4z9tqw3', 'bw5zrddhpppqy', '06f7dqgu5qkq7') and
         action in ('SCJ_SS_SCHEDULE', 'SCJ_SS_SCHEDULE1')
       )
   and not (module = 'SUP_TEST_FRAUD' and action in ('FRAMOS_MONITOR', 'FRAUD_RULE_1', 'FRAUD_RULE_4', 'FRAUD_RULE_6', 'MFO_LIMIT_MON', 'FRAUD_RULE_RSK'))
   and not (module = 'SUP_TEST' and action in ('FRAUD_CARD', 'BONUS_SCORING', 'SUP_CUR_RNKO', 'CARD2TERROR', 'NEW_OPER_REG', 'ACTIVE_CREDIT_SERVICES', 'AZE_UNSUPPORT_ARM', 'REESTR_RNKO'))
   and not (module = 'BB_TEST' and action in ('LIFE_NO_NOTICE_RECEIVE', 'LIFE_NO_NOTICE_SEND', 'INVALID_OBJECTS', 'STATS_DP', 'SCHEDULER_ERRORS', 'PARAM_CHANGES', 'FRAUDRULES_P2P_GROW'))
   -- scj_arc
   and not (module = 'DBMS_SCHEDULER' and action = 'SCJ_ARC')
   -- SCJ_PROCESS_CANCELOUTERTRINTS
   and not (action = 'SCJ_PROCESS_CANCELOUTERTRINTS')
   -- SCJ_REMOVEEXPIREDLIMSHOWCASE
   and not (module = 'DBMS_SCHEDULER' and action = 'SCJ_REMOVEEXPIREDLIMSHOWCASE')
   -- mv refresh
   and not (
         module = 'DBMS_SCHEDULER'
         and
         action in ('SCJ_WH_BANK_TRANSFER_GROUP', 'SCJ_WH_OPER_REP_GROUP2', 'SCJ_WH$_DOC_PAY2', 'SCJ_ONLINEPAYMAP_MV_GROUP'))
   -- excluded jobs
   and not (
         module = 'DBMS_SCHEDULER'
         and
         action in ('SCJ_AUTORECEIVECHINATRANSFERS', 'SCJ_TRANSFER_PKG_PROCESSONTIME', 'SCJ_CTRL_ASYNC_PROCESSTX')
       )
   and not (
         module = 'DBMS_SCHEDULER'
         and
         action like 'SCJ_DOC_PROCESSING_%'
         and
         sql_id in ('8rrf22mgfc37v', '1jtt9kgkh0u15', '7wn2b8krpv7z0'))
   and not (
         module = 'DBMS_SCHEDULER'
         and
         action = 'SCJ_TNK_ACTIVATION_BLOCKING'
         and
         sql_id = '3bj58rv6afa5p')
   and not (module = 'DBMS_SCHEDULER' and action = 'SCJ_MGSUPPORT' and sql_id = 'dggs497mdb9n1')
   and not (module = 'DBMS_SCHEDULER' and action = 'SCJ_CHECK_REF_NUM_POOL' and sql_id = 'cpg71dhfsmh26')
   -- Perfdwh
   and not (user_id = 0 and module = 'Data Pump Worker' and action = 'SYS_EXPORT_TABLE_01' and extract(hour from sample_time)=4)
   -- ignore time after instance startup, prefetching and so on
   and sample_time > (select startup_time+interval '60' minute from v$instance)
 group by module,
       action,
       session_id,
       session_serial#,
       ecid,
       sql_id,
       sql_exec_id, 
       sql_exec_start
 having max(sample_time)-sql_exec_start>to_dsinterval('0 00:00:03') and count(1)>1
 order by duration desc nulls last;

col action cle
col module cle
col select_stmt cle
col session_id cle
col wiki_table cle

@restore_sqlplus_settings
