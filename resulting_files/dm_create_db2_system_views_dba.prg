CREATE PROGRAM dm_create_db2_system_views:dba
 DECLARE err_message = vc
 DECLARE db2_errmsg = vc
 DECLARE db2_errcode = i4
 DECLARE current_status = c1
 DECLARE status_msg = vc
 DECLARE problem_view = c30
 DECLARE current_user = vc
 DECLARE ignore_errcode = i4
 DECLARE drop_cnt = i4
 DECLARE vname = vc
 DECLARE tabspace = vc
 SET current_status = "S"
 SET db2_errmsg = fillstring(132," ")
 SET db2_errcode = 0
 SET current_user = currdbuser
 IF (currdb != "DB2UDB")
  SET current_status = "O"
  GO TO exit_views
 ENDIF
 DROP TABLE tables
 DROP DDLRECORD tables FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD tables FROM DATABASE v500
 TABLE tables
  1 tabschema  = vc128 CCL(tabschema)
  1 tabname  = vc128 CCL(tabname)
  1 definer  = vc128 CCL(definer)
  1 type  = c1 CCL(type)
  1 status  = c1 CCL(status)
  1 base_tabschema  = vc128 CCL(base_tabschema)
  1 base_tabname  = vc128 CCL(base_tabname)
  1 rowtypeschema  = vc128 CCL(rowtypeschema)
  1 rowtypename  = c18 CCL(rowtypename)
  1 create_time  = di8 CCL(create_time)
  1 stats_time  = di8 CCL(stats_time)
  1 colcount  = i4 CCL(colcount)
  1 tableid  = i4 CCL(tableid)
  1 tbspaceid  = i4 CCL(tbspaceid)
  1 card  = i4 CCL(card)
  1 npages  = i4 CCL(npages)
  1 fpages  = i4 CCL(fpages)
  1 overflow  = i4 CCL(overflow)
  1 tbspace  = c18 CCL(tbspace)
  1 index_tbspace  = c18 CCL(index_tbspace)
  1 long_tbspace  = c18 CCL(long_tbspace)
  1 parents  = i4 CCL(parents)
  1 children  = i4 CCL(children)
  1 selfrefs  = i4 CCL(selfrefs)
  1 keycolumns  = i4 CCL(keycolumns)
  1 keyindexid  = i4 CCL(keyindexid)
  1 keyunique  = i4 CCL(keyunique)
  1 checkcount  = i4 CCL(checkcount)
  1 datacapture  = c1 CCL(datacapture)
  1 const_checked  = c32 CCL(const_checked)
  1 pmap_id  = f8 CCL(pmap_id)
  1 partition_mode  = c1 CCL(partition_mode)
  1 log_attribute  = c1 CCL(log_attribute)
  1 pctfree  = i4 CCL(pctfree)
  1 append_mode  = c1 CCL(append_mode)
  1 refresh  = c1 CCL(refresh)
  1 refresh_time  = di8 CCL(refresh_time)
  1 locksize  = c1 CCL(locksize)
  1 volatile  = c1 CCL(volatile)
  1 remarks  = vc254 CCL(remarks)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE tables
 SET db2_errcode = error(db2_errmsg,1)
 SELECT INTO "nl:"
  FROM (syscat.tables t)
  WHERE t.tabname="DBA_TABLES"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  RDB drop view dba_tables
  END ;Rdb
 ENDIF
 SELECT INTO "nl:"
  FROM (syscat.tables t)
  WHERE t.tabname="DBA_TAB_COLUMNS"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  RDB drop view dba_tab_columns
  END ;Rdb
 ENDIF
 RDB create view dba_tables ( owner , table_name , tablespace_name , cluster_name , pct_free ,
 pct_used , ini_trans , max_trans , initial_extent , next_extent , min_extents , max_extents ,
 pct_increase , freelists , freelist_groups , backed_up , num_rows , blocks , empty_blocks ,
 avg_space , chain_cnt , avg_row_len , degree , instances , cache , table_lock , index_tbspace ,
 long_tbspace ) as select tabschema , tabname , tbspace , "N/A" , pctfree , 0 , 0 , 0 , 0 , 0 , 0 , 0
  , 0 , 0 , 0 , "N" , card , npages , fpages - npages , 0 , overflow , 0 , "N/A" , "N/A" , "N/A" ,
 "N/A" , index_tbspace , long_tbspace from syscat . tables where type = "T"
 END ;Rdb
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "DBA_TABLES"
  GO TO exit_views
 ENDIF
 COMMIT
 DROP TABLE dba_tables
 DROP DDLRECORD dba_tables FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dba_tables FROM DATABASE v500
 TABLE dba_tables
  1 owner  = c30 CCL(owner)
  1 table_name  = c30 CCL(table_name)
  1 tablespace_name  = c30 CCL(tablespace_name)
  1 cluster_name  = c30 CCL(cluster_name)
  1 pct_free  = f8 CCL(pct_free)
  1 pct_used  = f8 CCL(pct_used)
  1 ini_trans  = f8 CCL(ini_trans)
  1 max_trans  = f8 CCL(max_trans)
  1 initial_extent  = f8 CCL(initial_extent)
  1 next_extent  = f8 CCL(next_extent)
  1 min_extents  = f8 CCL(min_extents)
  1 max_extents  = f8 CCL(max_extents)
  1 pct_increase  = f8 CCL(pct_increase)
  1 freelists  = f8 CCL(freelists)
  1 freelist_groups  = f8 CCL(freelist_groups)
  1 backed_up  = c1 CCL(backed_up)
  1 num_rows  = f8 CCL(num_rows)
  1 blocks  = f8 CCL(blocks)
  1 empty_blocks  = f8 CCL(empty_blocks)
  1 avg_space  = f8 CCL(avg_space)
  1 chain_cnt  = f8 CCL(chain_cnt)
  1 avg_row_len  = f8 CCL(avg_row_len)
  1 degree  = c10 CCL(degree)
  1 instances  = c10 CCL(instances)
  1 cache  = c5 CCL(cache)
  1 table_lock  = c8 CCL(table_lock)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dba_tables
 SET db2_errcode = error(db2_errmsg,1)
 RDB create view dba_tab_columns ( owner , table_name , column_name , data_type , data_length ,
 data_precision , data_scale , nullable , column_id , default_length , data_default , num_distinct ,
 low_value , high_value , density , num_nulls , num_buckets , last_analyzed , sample_size ) as select
  tabschema , tabname , colname , typename , length , 0 , scale , nulls , colno , length ( default )
 , default , colcard , low2key , high2key , nmostfreq , numnulls , nquantiles , current timestamp , 0
  from syscat . columns
 END ;Rdb
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "DBA_TAB_COLUMNS"
  GO TO exit_views
 ENDIF
 COMMIT
 DROP TABLE dba_tab_columns
 DROP DDLRECORD dba_tab_columns FROM DATABASE v500 WITH deps_deleted
 CREATE DDLRECORD dba_tab_columns FROM DATABASE v500
 TABLE dba_tab_columns
  1 owner  = c30 CCL(owner)
  1 table_name  = c30 CCL(table_name)
  1 column_name  = c30 CCL(column_name)
  1 data_type  = c9 CCL(data_type)
  1 data_length  = f8 CCL(data_length)
  1 data_precision  = f8 CCL(data_precision)
  1 data_scale  = f8 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 column_id  = f8 CCL(column_id)
  1 default_length  = f8 CCL(default_length)
  1 data_default  = vc2000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = di8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dba_tab_columns
 SET db2_errcode = error(db2_errmsg,1)
 CALL chk_drop_view("USER_TABLES")
 CALL chk_drop_view("USER_TAB_COLUMNS")
 CALL chk_drop_view("DBA_INDEXES")
 CALL chk_drop_view("USER_INDEXES")
 CALL chk_drop_view("DBA_IND_COLUMNS")
 CALL chk_drop_view("USER_IND_COLUMNS")
 CALL chk_drop_view("DBA_CONSTRAINTS")
 CALL chk_drop_view("USER_CONSTRAINTS")
 CALL chk_drop_view("DBA_CONS_COLUMNS")
 CALL chk_drop_view("USER_CONS_COLUMNS")
 CALL chk_drop_view("DBA_SEQUENCES")
 CALL chk_drop_view("USER_SEQUENCES")
 CALL chk_drop_view("DBA_VIEWS")
 CALL chk_drop_view("USER_VIEWS")
 CALL chk_drop_view("DBA_SYNONYMS")
 CALL chk_drop_view("USER_SYNONYMS")
 CALL chk_drop_view("DBA_TABLESPACES")
 CALL chk_drop_view("USER_TABLESPACES")
 CALL chk_drop_view("DBA_TRIGGERS")
 CALL chk_drop_view("USER_TRIGGERS")
 SUBROUTINE chk_drop_view(vname)
  SELECT INTO "nl:"
   FROM (syscat.tables t)
   WHERE t.tabname=vname
   WITH nocounter
  ;end select
  IF (curqual=1)
   CALL parser(concat("rdb drop view ",vname," go"))
  ENDIF
 END ;Subroutine
 CALL parser("rdb create view user_tables ( ")
 CALL parser("    TABLE_NAME,               ")
 CALL parser("    TABLESPACE_NAME,          ")
 CALL parser("    CLUSTER_NAME,             ")
 CALL parser("    PCT_FREE,                 ")
 CALL parser("    PCT_USED,                 ")
 CALL parser("    INI_TRANS,                ")
 CALL parser("    MAX_TRANS,                ")
 CALL parser("    INITIAL_EXTENT,           ")
 CALL parser("    NEXT_EXTENT,              ")
 CALL parser("    MIN_EXTENTS,              ")
 CALL parser("    MAX_EXTENTS,              ")
 CALL parser("    PCT_INCREASE,             ")
 CALL parser("    FREELISTS,                ")
 CALL parser("    FREELIST_GROUPS,          ")
 CALL parser("    BACKED_UP,                ")
 CALL parser("    NUM_ROWS,                 ")
 CALL parser("    BLOCKS,                   ")
 CALL parser("    EMPTY_BLOCKS,             ")
 CALL parser("    AVG_SPACE,                ")
 CALL parser("    CHAIN_CNT,                ")
 CALL parser("    AVG_ROW_LEN,              ")
 CALL parser("    DEGREE,                   ")
 CALL parser("    INSTANCES,                ")
 CALL parser("    CACHE,                    ")
 CALL parser("    TABLE_LOCK,               ")
 CALL parser("    INDEX_TBSPACE,            ")
 CALL parser("    LONG_TBSPACE              ")
 CALL parser(")  as select                  ")
 CALL parser("    TABLE_NAME,               ")
 CALL parser("    TABLESPACE_NAME,          ")
 CALL parser("    CLUSTER_NAME,             ")
 CALL parser("    PCT_FREE,                 ")
 CALL parser("    PCT_USED,                 ")
 CALL parser("    INI_TRANS,                ")
 CALL parser("    MAX_TRANS,                ")
 CALL parser("    INITIAL_EXTENT,           ")
 CALL parser("    NEXT_EXTENT,              ")
 CALL parser("    MIN_EXTENTS,              ")
 CALL parser("    MAX_EXTENTS,              ")
 CALL parser("    PCT_INCREASE,             ")
 CALL parser("    FREELISTS,                ")
 CALL parser("    FREELIST_GROUPS,          ")
 CALL parser("    BACKED_UP,                ")
 CALL parser("    NUM_ROWS,                 ")
 CALL parser("    BLOCKS,                   ")
 CALL parser("    EMPTY_BLOCKS,             ")
 CALL parser("    AVG_SPACE,                ")
 CALL parser("    CHAIN_CNT,                ")
 CALL parser("    AVG_ROW_LEN,              ")
 CALL parser("    DEGREE,                   ")
 CALL parser("    INSTANCES,                ")
 CALL parser("    CACHE,                    ")
 CALL parser("    TABLE_LOCK,               ")
 CALL parser("    INDEX_TBSPACE,            ")
 CALL parser("    LONG_TBSPACE              ")
 CALL parser("from dba_tables               ")
 CALL parser(concat("where owner = '",current_user,"'"))
 CALL parser("go                            ")
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "USER_TABLES"
  GO TO exit_views
 ENDIF
 COMMIT
 CALL parser("rdb create view user_tab_columns ( ")
 CALL parser("    TABLE_NAME,                    ")
 CALL parser("    COLUMN_NAME,                   ")
 CALL parser("    DATA_TYPE,                     ")
 CALL parser("    DATA_LENGTH,                   ")
 CALL parser("    DATA_PRECISION,                ")
 CALL parser("    DATA_SCALE,                    ")
 CALL parser("    NULLABLE,                      ")
 CALL parser("    COLUMN_ID,                     ")
 CALL parser("    DEFAULT_LENGTH,                ")
 CALL parser("    DATA_DEFAULT,                  ")
 CALL parser("    NUM_DISTINCT,                  ")
 CALL parser("    LOW_VALUE,                     ")
 CALL parser("    HIGH_VALUE,                    ")
 CALL parser("    DENSITY,                       ")
 CALL parser("    NUM_NULLS,                     ")
 CALL parser("    NUM_BUCKETS,                   ")
 CALL parser("    LAST_ANALYZED,                 ")
 CALL parser("    SAMPLE_SIZE                    ")
 CALL parser(") as select                        ")
 CALL parser("    TABLE_NAME,                    ")
 CALL parser("    COLUMN_NAME,                   ")
 CALL parser("    DATA_TYPE,                     ")
 CALL parser("    DATA_LENGTH,                   ")
 CALL parser("    DATA_PRECISION,                ")
 CALL parser("    DATA_SCALE,                    ")
 CALL parser("    NULLABLE,                      ")
 CALL parser("    COLUMN_ID,                     ")
 CALL parser("    DEFAULT_LENGTH,                ")
 CALL parser("    DATA_DEFAULT,                  ")
 CALL parser("    NUM_DISTINCT,                  ")
 CALL parser("    LOW_VALUE,                     ")
 CALL parser("    HIGH_VALUE,                    ")
 CALL parser("    DENSITY,                       ")
 CALL parser("    NUM_NULLS,                     ")
 CALL parser("    NUM_BUCKETS,                   ")
 CALL parser("    LAST_ANALYZED,                 ")
 CALL parser("    SAMPLE_SIZE                    ")
 CALL parser("from dba_tab_columns               ")
 CALL parser(concat("where owner = '",current_user,"'"))
 CALL parser("go                                 ")
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "USER_TAB_COLUMNS"
  GO TO exit_views
 ENDIF
 COMMIT
 RDB asis ( "create view dba_indexes (          " ) asis ( "    OWNER,                             "
 ) asis ( "    INDEX_NAME,                        " ) asis (
 "    FULL_INDEX_NAME,                   " ) asis ( "    TABLE_OWNER,                       " ) asis
 ( "    TABLE_NAME,                        " ) asis ( "    TABLE_TYPE,                        " )
 asis ( "    UNIQUENESS,                        " ) asis ( "    TABLESPACE_NAME,                   "
 ) asis ( "    INI_TRANS,                         " ) asis (
 "    MAX_TRANS,                         " ) asis ( "    INITIAL_EXTENT,                    " ) asis
 ( "    NEXT_EXTENT,                       " ) asis ( "    MIN_EXTENTS,                       " )
 asis ( "    MAX_EXTENTS,                       " ) asis ( "    PCT_INCREASE,                      "
 ) asis ( "    FREELISTS,                         " ) asis (
 "    FREELIST_GROUPS,                   " ) asis ( "    PCT_FREE,                          " ) asis
 ( "    BLEVEL,                            " ) asis ( "    LEAF_BLOCKS,                       " )
 asis ( "    DISTINCT_KEYS,                     " ) asis ( "    AVG_LEAF_BLOCKS_PER_KEY,           "
 ) asis ( "    AVG_DATA_BLOCKS_PER_KEY,           " ) asis (
 "    CLUSTERING_FACTOR,                 " ) asis ( "    STATUS                             " ) asis
 ( ") as select                            " ) asis ( "    i.indschema,                       " )
 asis ( "    i.indname,                         " ) asis ( "    i.remarks,                         "
 ) asis ( "    i.tabschema,                       " ) asis (
 "    i.tabname,                         " ) asis ( "    'TABLE',                           " ) asis
 ( "    CASE i.uniquerule                  " ) asis ( "       when 'D' then 'NONUNIQUE'       " )
 asis ( "       else 'UNIQUE'                   " ) asis ( "    END,                               "
 ) asis ( "    t.index_tbspace,                   " ) asis (
 "    0,                                 " ) asis ( "    0,                                 " ) asis
 ( "    0,                                 " ) asis ( "    0,                                 " )
 asis ( "    0,                                 " ) asis ( "    0,                                 "
 ) asis ( "    0,                                 " ) asis (
 "    0,                                 " ) asis ( "    0,                                 " ) asis
 ( "    0,                                 " ) asis ( "    i.nlevels,                         " )
 asis ( "    i.nleaf,                           " ) asis ( "    i.fullkeycard,                     "
 ) asis ( "    0,                                 " ) asis (
 "    0,                                 " ) asis ( "    0,                                 " ) asis
 ( "    'VALID'                            " ) asis ( "from syscat.indexes i, syscat.tables t " )
 asis ( "where i.tabname = t.tabname            " ) asis ( "  and i.tabschema = t.tabschema        "
 )
 END ;Rdb
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "DBA_INDEXES"
  GO TO exit_views
 ENDIF
 COMMIT
 CALL parser("rdb create view user_indexes (")
 CALL parser("    INDEX_NAME,               ")
 CALL parser("    FULL_INDEX_NAME,          ")
 CALL parser("    TABLE_OWNER,              ")
 CALL parser("    TABLE_NAME,               ")
 CALL parser("    TABLE_TYPE,               ")
 CALL parser("    UNIQUENESS,               ")
 CALL parser("    TABLESPACE_NAME,          ")
 CALL parser("    INI_TRANS,                ")
 CALL parser("    MAX_TRANS,                ")
 CALL parser("    INITIAL_EXTENT,           ")
 CALL parser("    NEXT_EXTENT,              ")
 CALL parser("    MIN_EXTENTS,              ")
 CALL parser("    MAX_EXTENTS,              ")
 CALL parser("    PCT_INCREASE,             ")
 CALL parser("    FREELISTS,                ")
 CALL parser("    FREELIST_GROUPS,          ")
 CALL parser("    PCT_FREE,                 ")
 CALL parser("    BLEVEL,                   ")
 CALL parser("    LEAF_BLOCKS,              ")
 CALL parser("    DISTINCT_KEYS,            ")
 CALL parser("    AVG_LEAF_BLOCKS_PER_KEY,  ")
 CALL parser("    AVG_DATA_BLOCKS_PER_KEY,  ")
 CALL parser("    CLUSTERING_FACTOR,        ")
 CALL parser("    STATUS                    ")
 CALL parser(") as select                   ")
 CALL parser("    INDEX_NAME,               ")
 CALL parser("    FULL_INDEX_NAME,          ")
 CALL parser("    TABLE_OWNER,              ")
 CALL parser("    TABLE_NAME,               ")
 CALL parser("    TABLE_TYPE,               ")
 CALL parser("    UNIQUENESS,               ")
 CALL parser("    TABLESPACE_NAME,          ")
 CALL parser("    INI_TRANS,                ")
 CALL parser("    MAX_TRANS,                ")
 CALL parser("    INITIAL_EXTENT,           ")
 CALL parser("    NEXT_EXTENT,              ")
 CALL parser("    MIN_EXTENTS,              ")
 CALL parser("    MAX_EXTENTS,              ")
 CALL parser("    PCT_INCREASE,             ")
 CALL parser("    FREELISTS,                ")
 CALL parser("    FREELIST_GROUPS,          ")
 CALL parser("    PCT_FREE,                 ")
 CALL parser("    BLEVEL,                   ")
 CALL parser("    LEAF_BLOCKS,              ")
 CALL parser("    DISTINCT_KEYS,            ")
 CALL parser("    AVG_LEAF_BLOCKS_PER_KEY,  ")
 CALL parser("    AVG_DATA_BLOCKS_PER_KEY,  ")
 CALL parser("    CLUSTERING_FACTOR,        ")
 CALL parser("    STATUS                    ")
 CALL parser("from dba_indexes              ")
 CALL parser(concat("where owner = '",current_user,"'"))
 CALL parser("go                            ")
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "USER_INDEXES"
  GO TO exit_views
 ENDIF
 COMMIT
 RDB create view dba_ind_columns ( index_owner , index_name , table_owner , table_name , column_name
 , column_position , column_length ) as select ic . indschema , ic . indname , i . tabschema , i .
 tabname , ic . colname , ic . colseq , c . length from syscat . indexcoluse ic , syscat . indexes i
 , syscat . columns c where i . indschema = ic . indschema and i . indname = ic . indname and i .
 tabschema = c . tabschema and i . tabname = c . tabname and ic . colname = c . colname
 END ;Rdb
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "DBA_IND_COLUMNS"
  GO TO exit_views
 ENDIF
 COMMIT
 CALL parser("rdb create view user_ind_columns ( ")
 CALL parser("    INDEX_NAME,                    ")
 CALL parser("    TABLE_NAME,                    ")
 CALL parser("    COLUMN_NAME,                   ")
 CALL parser("    COLUMN_POSITION,               ")
 CALL parser("    COLUMN_LENGTH                  ")
 CALL parser(") as select                        ")
 CALL parser("    INDEX_NAME,                    ")
 CALL parser("    TABLE_NAME,                    ")
 CALL parser("    COLUMN_NAME,                   ")
 CALL parser("    COLUMN_POSITION,               ")
 CALL parser("    COLUMN_LENGTH                  ")
 CALL parser("from dba_ind_columns               ")
 CALL parser(concat("where index_owner = '",current_user,"'"))
 CALL parser("go                                 ")
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "USER_IND_COLUMNS"
  GO TO exit_views
 ENDIF
 COMMIT
 RDB asis ( "create view dba_constraints (              " ) asis (
 "     OWNER,                                    " ) asis (
 "     CONSTRAINT_NAME,                          " ) asis (
 "     FULL_CONSTRAINT_NAME,                     " ) asis (
 "     CONSTRAINT_TYPE,                          " ) asis (
 "     TABLE_NAME,                               " ) asis (
 "     SEARCH_CONDITION,                         " ) asis (
 "     R_OWNER,                                  " ) asis (
 "     R_CONSTRAINT_NAME,                        " ) asis (
 "     DELETE_RULE,                              " ) asis (
 "     STATUS                                    " ) asis (
 ") as select                                    " ) asis (
 "     t.tabschema,                              " ) asis (
 "     t.constname,                              " ) asis (
 "     t.remarks,                                " ) asis (
 "     t.type,                                   " ) asis (
 "     t.tabname,                                " ) asis (
 "     'N/A',                                    " ) asis (
 "     CHAR(NULLIF(1,1)),                        " ) asis (
 "     CHAR(NULLIF(1,1)),                        " ) asis (
 "     CHAR(NULLIF(1,1)),                        " ) asis (
 "     'N/A'                                     " ) asis (
 "from syscat.tabconst t where t.type != 'F'     " ) asis (
 "union all                                      " ) asis (
 "select                                         " ) asis (
 "     t.tabschema,                              " ) asis (
 "     t.constname,                              " ) asis (
 "     t.remarks,                                " ) asis (
 "     'R',                                      " ) asis (
 "     t.tabname,                                " ) asis (
 "     'N/A',                                    " ) asis (
 "     r.reftabschema,                           " ) asis (
 "     r.refkeyname,                             " ) asis (
 "     r.deleterule,                             " ) asis (
 "     'N/A'                                     " ) asis (
 " from syscat.tabconst t,syscat.references r    " ) asis (
 "where t.constname = r.constname                " ) asis (
 "  and t.type = 'F'                             " )
 END ;Rdb
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "DBA_CONSTRAINTS"
  GO TO exit_views
 ENDIF
 COMMIT
 CALL parser("rdb create view user_constraints (")
 CALL parser("    OWNER,                        ")
 CALL parser("    CONSTRAINT_NAME,              ")
 CALL parser("    FULL_CONSTRAINT_NAME,         ")
 CALL parser("    CONSTRAINT_TYPE,              ")
 CALL parser("    TABLE_NAME,                   ")
 CALL parser("    SEARCH_CONDITION,             ")
 CALL parser("    R_OWNER,                      ")
 CALL parser("    R_CONSTRAINT_NAME,            ")
 CALL parser("    DELETE_RULE,                  ")
 CALL parser("    STATUS                        ")
 CALL parser(") as select                       ")
 CALL parser("    OWNER,                        ")
 CALL parser("    CONSTRAINT_NAME,              ")
 CALL parser("    FULL_CONSTRAINT_NAME,         ")
 CALL parser("    CONSTRAINT_TYPE,              ")
 CALL parser("    TABLE_NAME,                   ")
 CALL parser("    SEARCH_CONDITION,             ")
 CALL parser("    R_OWNER,                      ")
 CALL parser("    R_CONSTRAINT_NAME,            ")
 CALL parser("    DELETE_RULE,                  ")
 CALL parser("    STATUS                        ")
 CALL parser("from dba_constraints              ")
 CALL parser(concat("where owner = '",current_user,"'"))
 CALL parser("go                                ")
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "USER_CONSTRAINTS"
  GO TO exit_views
 ENDIF
 COMMIT
 RDB create view dba_cons_columns ( owner , constraint_name , table_name , column_name , position )
 as select tabschema , constname , tabname , colname , colseq from syscat . keycoluse
 END ;Rdb
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "DBA_CONS_COLUMNS"
  GO TO exit_views
 ENDIF
 COMMIT
 CALL parser("rdb create view user_cons_columns ( ")
 CALL parser("    OWNER,                          ")
 CALL parser("    CONSTRAINT_NAME,                ")
 CALL parser("    TABLE_NAME,                     ")
 CALL parser("    COLUMN_NAME,                    ")
 CALL parser("    POSITION                        ")
 CALL parser(") as select                         ")
 CALL parser("    OWNER,                          ")
 CALL parser("    CONSTRAINT_NAME,                ")
 CALL parser("    TABLE_NAME,                     ")
 CALL parser("    COLUMN_NAME,                    ")
 CALL parser("    POSITION                        ")
 CALL parser("from dba_cons_columns               ")
 CALL parser(concat("where owner = '",current_user,"'"))
 CALL parser("go                                  ")
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "USER_CONS_COLUMNS"
  GO TO exit_views
 ENDIF
 COMMIT
 RDB create view dba_sequences ( sequence_owner , sequence_name , min_value , max_value ,
 increment_by , cycle_flag , order_flag , cache_size , last_number ) as select seqschema , seqname ,
 minvalue , maxvalue , increment , cycle , order , cache , start from syscat . sequences
 END ;Rdb
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "DBA_SEQUENCES"
  GO TO exit_views
 ENDIF
 COMMIT
 CALL parser("rdb create view user_sequences (")
 CALL parser("    SEQUENCE_NAME,              ")
 CALL parser("    MIN_VALUE,                  ")
 CALL parser("    MAX_VALUE,                  ")
 CALL parser("    INCREMENT_BY,               ")
 CALL parser("    CYCLE_FLAG,                 ")
 CALL parser("    ORDER_FLAG,                 ")
 CALL parser("    CACHE_SIZE,                 ")
 CALL parser("    LAST_NUMBER                 ")
 CALL parser(") as select                     ")
 CALL parser("    SEQUENCE_NAME,              ")
 CALL parser("    MIN_VALUE,                  ")
 CALL parser("    MAX_VALUE,                  ")
 CALL parser("    INCREMENT_BY,               ")
 CALL parser("    CYCLE_FLAG,                 ")
 CALL parser("    ORDER_FLAG,                 ")
 CALL parser("    CACHE_SIZE,                 ")
 CALL parser("    LAST_NUMBER                 ")
 CALL parser("from dba_sequences              ")
 CALL parser(concat("where sequence_owner = '",current_user,"'"))
 CALL parser("go                              ")
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "USER_SEQUENCES"
  GO TO exit_views
 ENDIF
 COMMIT
 RDB create view dba_views ( owner , view_name , text_length , text ) as select viewschema , viewname
  , 0 , text from syscat . views
 END ;Rdb
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "DBA_VIEWS"
  GO TO exit_views
 ENDIF
 COMMIT
 CALL parser("rdb create view user_views (")
 CALL parser("    VIEW_NAME,              ")
 CALL parser("    TEXT_LENGTH,            ")
 CALL parser("    TEXT                    ")
 CALL parser(") as select                 ")
 CALL parser("    VIEW_NAME,              ")
 CALL parser("    TEXT_LENGTH,            ")
 CALL parser("    TEXT                    ")
 CALL parser("from dba_views              ")
 CALL parser(concat("where owner = '",current_user,"'"))
 CALL parser("go                          ")
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "USER_VIEWS"
  GO TO exit_views
 ENDIF
 COMMIT
 RDB asis ( "create view dba_synonyms (   " ) asis ( "    OWNER,                       " ) asis (
 "    SYNONYM_NAME,                " ) asis ( "    TABLE_OWNER,                 " ) asis (
 "    TABLE_NAME,                  " ) asis ( "    DB_LINK,                     " ) asis (
 "    TYPE                         " ) asis ( ") as select                      " ) asis (
 "    t.tabschema,                 " ) asis ( "    t.tabname,                   " ) asis (
 "    t.base_tabschema,            " ) asis ( "    t.base_tabname,              " ) asis (
 "    CHAR(NULLIF(1,1)),           " ) asis ( "    'A'                          " ) asis (
 "from syscat.tables t             " ) asis ( "where t.type = 'A'               " ) asis (
 "union                            " ) asis ( "select                           " ) asis (
 "    t1.tabschema,                " ) asis ( "    t1.tabname,                  " ) asis (
 "    t1.setting,                  " ) asis ( "    t2.setting,                  " ) asis (
 "    t3.setting,                  " ) asis ( "    'N'                          " ) asis (
 "from syscat.taboptions t1,       " ) asis ( "    syscat.taboptions t2,        " ) asis (
 "    syscat.taboptions t3,        " ) asis ( "    syscat.tables ta             " ) asis (
 "where ta.type = 'N'              " ) asis ( "  and t1.tabname = ta.tabname    " ) asis (
 "  and t1.tabschema = ta.tabschema" ) asis ( "  and t1.option = 'REMOTE_TABLE' " ) asis (
 "  and t2.tabname = t1.tabname    " ) asis ( "  and t2.tabschema = t1.tabschema" ) asis (
 "  and t2.option = 'REMOTE_SCHEMA'" ) asis ( "  and t3.tabname = t2.tabname    " ) asis (
 "  and t3.tabschema = t2.tabschema" ) asis ( "  and t3.option = 'SERVER'       " )
 END ;Rdb
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "DBA_SYNONYMS"
  GO TO exit_views
 ENDIF
 COMMIT
 CALL parser("rdb create view user_synonyms (")
 CALL parser("    SYNONYM_NAME,              ")
 CALL parser("    TABLE_OWNER,               ")
 CALL parser("    TABLE_NAME,                ")
 CALL parser("    DB_LINK,                   ")
 CALL parser("    TYPE                       ")
 CALL parser(") as select                    ")
 CALL parser("    SYNONYM_NAME,              ")
 CALL parser("    TABLE_OWNER,               ")
 CALL parser("    TABLE_NAME,                ")
 CALL parser("    DB_LINK,                   ")
 CALL parser("    TYPE                       ")
 CALL parser("from dba_synonyms              ")
 CALL parser(concat("where owner = '",current_user,"'"))
 CALL parser("go                             ")
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "USER_SYNONYMS"
  GO TO exit_views
 ENDIF
 COMMIT
 RDB create view dba_tablespaces ( tablespace_name , initial_extent , next_extent , min_extents ,
 max_extents , pct_increase , status , contents , tbspace_type , pagesize , ngname , bpname ) as
 select t . tbspace , t . extentsize , 0.0 , 0.0 , 0.0 , 0.0 , char ( nullif ( 1 , 1 ) ) , char (
 nullif ( 1 , 1 ) ) , t . tbspacetype , t . pagesize , t . ngname , b . bpname from syscat .
 tablespaces t , syscat . bufferpools b where t . bufferpoolid = b . bufferpoolid
 END ;Rdb
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "DBA_TABLESPACES"
  GO TO exit_views
 ENDIF
 COMMIT
 RDB create view user_tablespaces ( tablespace_name , initial_extent , next_extent , min_extents ,
 max_extents , pct_increase , status , contents , tbspace_type , pagesize , ngname , bpname ) as
 select tablespace_name , initial_extent , next_extent , min_extents , max_extents , pct_increase ,
 status , contents , tbspace_type , pagesize , ngname , bpname from dba_tablespaces
 END ;Rdb
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "USER_TABLESPACES"
  GO TO exit_views
 ENDIF
 COMMIT
 RDB asis ( "create view dba_triggers (                        " ) asis (
 "    OWNER,                                            " ) asis (
 "    TRIGGER_NAME,                                     " ) asis (
 "    TRIGGER_TYPE,                                     " ) asis (
 "    TRIGGERING_EVENT,                                 " ) asis (
 "    TABLE_OWNER,                                      " ) asis (
 "    TABLE_NAME,                                       " ) asis (
 "    REFERENCING_NAMES,                                " ) asis (
 "    WHEN_CLAUSE,                                      " ) asis (
 "    STATUS,                                           " ) asis (
 "    DESCRIPTION,                                      " ) asis (
 "    TRIGGER_BODY                                      " ) asis (
 ") as select                                           " ) asis (
 "    t.definer,                                        " ) asis (
 "    t.trigname,                                       " ) asis (
 "    CASE t.trigtime                                   " ) asis (
 "      when 'A' then CASE t.granularity                " ) asis (
 "                      when 'R' then 'AFTER EACH ROW'  " ) asis (
 "                      when 'S' then 'AFTER STATEMENT' " ) asis (
 "                    END                               " ) asis (
 "      when 'B' then CASE t.granularity                " ) asis (
 "                      when 'R' then 'BEFORE EACH ROW' " ) asis (
 "                      when 'S' then 'BEFORE STATEMENT'" ) asis (
 "                    END                               " ) asis (
 "    END,                                              " ) asis (
 "    CASE t.trigevent                                  " ) asis (
 "      when 'U' then 'UPDATE'                          " ) asis (
 "      when 'I' then 'INSERT'                          " ) asis (
 "      when 'D' then 'DELETE'                          " ) asis (
 "    END,                                              " ) asis (
 "    t.tabschema,                                      " ) asis (
 "    t.tabname,                                        " ) asis (
 "    CHAR(NULLIF(1,1)),                                " ) asis (
 "    CHAR(NULLIF(1,1)),                                " ) asis (
 "    CASE t.valid                                      " ) asis (
 "      when 'Y' then 'ENABLED'                         " ) asis (
 "      when 'X' then 'DISABLED'                        " ) asis (
 "    END,                                              " ) asis (
 "    t.remarks,                                        " ) asis (
 "    t.text                                            " ) asis (
 "from syscat.triggers t                                " )
 END ;Rdb
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "DBA_TRIGGERS"
  GO TO exit_views
 ENDIF
 COMMIT
 CALL parser("rdb create view user_triggers (         ")
 CALL parser("    TRIGGER_NAME,                       ")
 CALL parser("    TRIGGER_TYPE,                       ")
 CALL parser("    TRIGGERING_EVENT,                   ")
 CALL parser("    TABLE_OWNER,                        ")
 CALL parser("    TABLE_NAME,                         ")
 CALL parser("    REFERENCING_NAMES,                  ")
 CALL parser("    WHEN_CLAUSE,                        ")
 CALL parser("    STATUS,                             ")
 CALL parser("    DESCRIPTION,                        ")
 CALL parser("    TRIGGER_BODY                        ")
 CALL parser(") as select                             ")
 CALL parser("    TRIGGER_NAME,                       ")
 CALL parser("    TRIGGER_TYPE,                       ")
 CALL parser("    TRIGGERING_EVENT,                   ")
 CALL parser("    TABLE_OWNER,                        ")
 CALL parser("    TABLE_NAME,                         ")
 CALL parser("    REFERENCING_NAMES,                  ")
 CALL parser("    WHEN_CLAUSE,                        ")
 CALL parser("    STATUS,                             ")
 CALL parser("    DESCRIPTION,                        ")
 CALL parser("    TRIGGER_BODY                        ")
 CALL parser("from dba_triggers                       ")
 CALL parser(concat("where owner = '",current_user,"'"))
 CALL parser("go                                      ")
 SET db2_errcode = error(db2_errmsg,0)
 IF (db2_errcode > 0)
  ROLLBACK
  SET current_status = "F"
  SET problem_view = "USER_TRIGGERS"
  GO TO exit_views
 ENDIF
 COMMIT
 SELECT INTO "nl:"
  FROM (syscat.tables t)
  WHERE t.tabname="DUAL"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   FROM (syscat.tablespaces ts)
   WHERE ts.tbspace IN ("D_SYS_MGMT", "D_TOOLKIT", "D_R_SMALL")
   DETAIL
    tabspace = cnvtlower(ts.tbspace)
   WITH nocounter
  ;end select
  CALL parser("       rdb create table dual (    ")
  CALL parser("           dummy varchar(1)       ")
  CALL parser(concat(") in ",tabspace," go       "))
  SET db2_errcode = error(db2_errmsg,0)
  IF (db2_errcode > 0)
   ROLLBACK
   SET current_status = "F"
   SET problem_view = "DUAL TABLE"
   GO TO exit_views
  ENDIF
  EXECUTE oragen3 "dual"
  SET db2_errcode = error(db2_errmsg,1)
  INSERT  FROM dual
   SET dummy = "x"
   WITH nocounter
  ;end insert
  SET db2_errcode = error(db2_errmsg,0)
  IF (db2_errcode > 0)
   ROLLBACK
   SET current_status = "F"
   SET problem_view = "DUAL TABLE insert"
   GO TO exit_views
  ELSE
   COMMIT
  ENDIF
 ENDIF
 EXECUTE oragen3 "user_tables"
 EXECUTE oragen3 "user_tab_columns"
 EXECUTE oragen3 "dba_indexes"
 EXECUTE oragen3 "user_indexes"
 EXECUTE oragen3 "dba_ind_columns"
 EXECUTE oragen3 "user_ind_columns"
 EXECUTE oragen3 "dba_constraints"
 EXECUTE oragen3 "user_constraints"
 EXECUTE oragen3 "dba_cons_columns"
 EXECUTE oragen3 "user_cons_columns"
 EXECUTE oragen3 "dba_sequences"
 EXECUTE oragen3 "user_sequences"
 EXECUTE oragen3 "dba_views"
 EXECUTE oragen3 "user_views"
 EXECUTE oragen3 "dba_synonyms"
 EXECUTE oragen3 "user_synonyms"
 EXECUTE oragen3 "dba_tablespaces"
 EXECUTE oragen3 "user_tablespaces"
 EXECUTE oragen3 "dba_triggers"
 EXECUTE oragen3 "user_triggers"
 EXECUTE oragen3 "syscat.*"
#exit_views
 IF (current_status="O")
  SET status_msg = "Failed!"
  SET err_message = "Only for use on DB2 database."
 ELSEIF (current_status="F")
  SET status_msg = "Failed!"
  SET err_message = concat(trim(problem_view)," failed: ",db2_errmsg)
 ELSEIF (current_status="S")
  SET status_msg = "SUCCESS!"
  SET err_message = "ALL VIEWS SUCCESSFULLY CREATED."
 ENDIF
 CALL echo(status_msg)
 CALL echo(err_message)
END GO
