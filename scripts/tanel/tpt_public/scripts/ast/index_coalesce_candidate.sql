COL owner FOR A15
COL object_name FOR A30

WITH trends AS (
    SELECT
        o.owner
      , o.object_name
      , o.subobject_name
      , o.object_type
      , REGR_SLOPE(ih.rowcnt / NULLIF(ih.leafcnt,0), (SYSDATE-CAST(ih.savtime AS DATE)) ) regr1
      , REGR_SLOPE(ih.rowcnt, ih.leafcnt) regr2
    --  , ROUND(ih.rowcnt / NULLIF(ih.leafcnt,0)) avg_rows_per_block
    --  , ih.rowcnt
    --  , ih.leafcnt
    --  , ih.lblkkey
    --  , ih.dblkkey
      , MAX(ih.blevel)+1 max_height
      , MIN(ih.blevel)+1 min_height
    FROM
        dba_objects o
      , sys.wri$_optstat_ind_history ih
    WHERE
        o.object_id       = ih.obj#
    AND o.object_type     LIKE 'INDEX%'
    AND (
        UPPER(o.object_name) LIKE
                    UPPER(CASE
                        WHEN INSTR('&1','.') > 0 THEN
                            SUBSTR('&1',INSTR('&1','.')+1)
                        ELSE
                            '&1'
                        END
                         )
    AND UPPER(o.owner) LIKE
            CASE WHEN INSTR('&1','.') > 0 THEN
                UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
            ELSE
                user
            END
    )
    GROUP BY
        o.owner
      , o.object_name
      , o.subobject_name
      , o.object_type
    ORDER BY
    --    ih.savtime
        regr1 DESC NULLS LAST
)
SELECT * FROM (
    SELECT
        t.owner
      , t.object_name
      , t.subobject_name partition_name
      , t.object_type
      , ROUND(s.bytes / 1048576) mb
      , t.regr1
      , t.regr2
      --, ROUND(SUM(s.bytes) / 1048576) mb_sum
      --, COUNT(*)
    FROM
        trends t
      , dba_segments s
    WHERE
        t.owner           = s.owner
    AND t.object_name     = s.segment_name
    AND t.object_type     = s.segment_type
    AND (t.subobject_name = s.partition_name OR (t.subobject_name IS NULL AND s.partition_name IS NULL))
    --GROUP BY
    --    t.owner
    --  , t.object_name
    --  , t.object_type
    --  , t.subobject_name
    ORDER BY regr1 DESC NULLS LAST
)
WHERE
    ROWNUM<=20
/ 
