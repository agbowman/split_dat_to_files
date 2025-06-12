CREATE PROGRAM dm2_compare_data
 IF ((validate(dm2_compare_rec->tbl_cnt,- (1))=- (1))
  AND (validate(dm2_compare_rec->tbl_cnt,- (2))=- (2)))
  RECORD dm2_compare_rec(
    1 chkpt_1_setup_dt = dq8
    1 chkpt_2_arch_dt = dq8
    1 src_data_link = vc
    1 hrsback = f8
    1 v500_views_ind = i2
    1 max_mm_rows = i4
    1 max_retry_secs = i4
    1 mm_retry_secs = i4
    1 rows_to_sample = i4
    1 restart_compare_ind = i2
    1 tbl_cnt = i4
    1 tab[*]
      2 owner = vc
      2 table_name = vc
      2 compare_table = i2
      2 table_exists_ind = i2
      2 tbl_chkpt_dminfo_dt = dq8
      2 ora_mod_dt = dq8
      2 last_analyzed = dq8
      2 tbl_monitoring = i2
      2 matched_ind = i2
      2 datecol = vc
      2 cmp_dt_tm = dq8
      2 cmp_cnt = i4
      2 object_id = vc
      2 skip_reason = vc
      2 src_view_name = vc
      2 tgt_view_name = vc
      2 cmp_view_name = vc
      2 union_view_name = vc
      2 nkeycol_cnt = i2
      2 nkeycols[*]
        3 column_name = vc
        3 data_type = vc
      2 keycol_cnt = i2
      2 keycols[*]
        3 column_name = vc
        3 data_type = vc
      2 orig_mm_cnt = i4
      2 curr_mm_cnt = i4
      2 mm_rec[*]
        3 recrow_match_ind = i2
        3 reccol[*]
          4 colval_char = vc
          4 colval_num = f8
          4 colval_dt = dq8
      2 chosen_key_column = vc
      2 row_cnt = i4
      2 rows[*]
        3 unique_id = f8
        3 match_ind = i2
      2 match_row_cnt = i4
      2 bottom_ptr = f8
      2 top_ptr = f8
    1 max_row_cnt = i4
    1 total_row_cnt = i4
  )
  SET dm2_compare_rec->src_data_link = "DM2NOTSET"
  SET dm2_compare_rec->hrsback = - (1)
  SET dm2_compare_rec->max_mm_rows = 20
  SET dm2_compare_rec->max_retry_secs = 180
 ENDIF
 DECLARE dcd_num = i4 WITH protect, noconstant(0)
 DECLARE dcd_get_input_data(null) = i2
 DECLARE dcd_validate_datecols(null) = i2
 DECLARE dcd_validate_uniqueidx(notnull_ind=i2) = i2
 DECLARE dcd_generate_mig_views(null) = i2
 DECLARE dcd_validate_prompt(null) = i2
 SUBROUTINE dcd_get_input_data(null)
   DECLARE done = i2 WITH protect, noconstant(0)
   DECLARE dcd_acceptdefault = vc WITH protect, noconstant("M")
   SET width = 132
   SET message = window
   IF ((dm2_compare_rec->src_data_link="DM2NOTSET"))
    DECLARE dcd_dblink = vc WITH protect, noconstant("DM2NOTSET")
    WHILE ( NOT (done))
      CALL clear(1,1)
      CALL box(1,1,5,131)
      CALL text(2,2,"Please provide the database link for the source database:")
      IF (dcd_dblink != "DM2NOTSET")
       CALL text(2,60,dcd_dblink)
      ENDIF
      CALL text(4,2,"(M)odify, (C)ontinue, (Q)uit: ")
      CALL accept(4,33,"A;CU",dcd_acceptdefault
       WHERE curaccept IN ("M", "C", "Q"))
      CASE (curaccept)
       OF "M":
        CALL accept(2,60,"P(15);CU")
        SET dm_err->eproc = "Verifying DB LINK exists"
        SELECT INTO "nl:"
         FROM dba_db_links ddl
         WHERE ddl.db_link=patstring(concat(trim(curaccept),"*"))
        ;end select
        IF (check_error(dm_err->eproc) != 0)
         RETURN(0)
        ENDIF
        IF (curqual=0)
         CALL clear(1,1)
         CALL box(1,1,5,131)
         CALL text(2,2,"The database link given was not found.")
         CALL text(4,2,"(R)etry,(Q)uit: ")
         CALL accept(4,18,"A;cu","R"
          WHERE curaccept IN ("R", "Q"))
         IF (curaccept="Q")
          RETURN(0)
         ENDIF
        ELSE
         SET dcd_dblink = trim(curaccept)
         SET dcd_acceptdefault = "C"
        ENDIF
       OF "C":
        IF (dcd_dblink="DM2NOTSET")
         CALL clear(1,1)
         CALL box(1,1,5,131)
         CALL text(2,2,"You must enter a value for the source database link.")
         CALL text(4,2,"(R)etry,(Q)uit: ")
         CALL accept(4,18,"A;cu","R"
          WHERE curaccept IN ("R", "Q"))
         IF (curaccept="Q")
          RETURN(0)
         ENDIF
        ELSE
         SET dm2_compare_rec->src_data_link = dcd_dblink
         SET done = true
        ENDIF
       OF "Q":
        RETURN(0)
      ENDCASE
    ENDWHILE
   ENDIF
   SET done = false
   SET dcd_acceptdefault = "M"
   IF ((dm2_compare_rec->hrsback=- (1)))
    DECLARE dcd_hrsback = i4 WITH protect, noconstant(- (1))
    WHILE ( NOT (done))
      CALL clear(1,1)
      CALL box(1,1,7,131)
      CALL text(2,2,
       "Please provide the number of hours back the comparison process should look for recently updated data."
       )
      CALL text(4,2,"Hours Back:")
      IF ((dcd_hrsback != - (1)))
       CALL text(4,14,cnvtstring(dcd_hrsback))
      ENDIF
      CALL text(6,2,"(M)odify, (C)ontinue, (Q)uit: ")
      CALL accept(6,33,"A;CU",dcd_acceptdefault
       WHERE curaccept IN ("M", "C", "Q"))
      CASE (curaccept)
       OF "M":
        CALL accept(4,14,"9(4);",1
         WHERE curaccept > 0)
        SET dcd_hrsback = curaccept
        SET dcd_acceptdefault = "C"
       OF "C":
        SET dm2_compare_rec->hrsback = dcd_hrsback
        SET done = true
       OF "Q":
        RETURN(0)
      ENDCASE
    ENDWHILE
   ENDIF
   SET done = false
   SET dcd_acceptdefault = "M"
   IF ((dm2_compare_rec->tbl_cnt=0))
    DECLARE dcd_own_name = vc WITH protect, noconstant("")
    DECLARE dcd_tbl_name = vc WITH protect, noconstant("")
    WHILE ( NOT (done))
      CALL clear(1,1)
      CALL box(1,1,8,131)
      CALL text(2,2,"Please provide the owner and table name that should be compared.")
      CALL text(4,2,"Owner Name:")
      CALL text(4,14,dcd_own_name)
      CALL text(5,2,"Table Name:")
      CALL text(5,14,dcd_tbl_name)
      CALL text(7,2,"(M)odify, (C)ontinue, (Q)uit: ")
      CALL accept(7,33,"A;CU",dcd_acceptdefault
       WHERE curaccept IN ("M", "C", "Q"))
      CASE (curaccept)
       OF "M":
        CALL accept(4,14,"P(20);cu")
        SET dcd_own_name = curaccept
        CALL accept(5,14,"P(20);cu")
        SET dcd_tbl_name = curaccept
        SET dcd_acceptdefault = "C"
       OF "C":
        SET stat = alterlist(dm2_compare_rec->tab,1)
        SET dm2_compare_rec->tbl_cnt = 1
        SET dm2_compare_rec->tab[1].owner = dcd_own_name
        SET dm2_compare_rec->tab[1].table_name = dcd_tbl_name
        SET dm2_compare_rec->tab[1].datecol = "DM2NOTSET"
        SET dm2_compare_rec->tab[1].nkeycol_cnt = - (1)
        SET done = true
       OF "Q":
        RETURN(0)
      ENDCASE
    ENDWHILE
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_validate_datecols(null)
   SET width = 132
   SET message = window
   RECORD dcd_datecols(
     1 list[*]
       2 columns = vc
   )
   DECLARE done = i2 WITH protect, noconstant(0)
   DECLARE dcd_acceptdefault = vc WITH protect, noconstant("M")
   FOR (i = 1 TO dm2_compare_rec->tbl_cnt)
     IF ((dm2_compare_rec->tab[i].datecol="DM2NOTSET"))
      SET stat = initrec(dcd_datecols)
      SET dm_err->eproc = concat("Validating Date Columns for ",dm2_compare_rec->tab[i].table_name)
      SELECT INTO "nl:"
       dtc.column_name
       FROM dba_tab_columns dtc
       WHERE (dtc.table_name=dm2_compare_rec->tab[i].table_name)
        AND (dtc.owner=dm2_compare_rec->tab[i].owner)
        AND dtc.data_type="DATE"
        AND  EXISTS (
       (SELECT
        1
        FROM dba_ind_columns dic
        WHERE dic.column_name=dtc.column_name
         AND dic.table_owner=dtc.owner
         AND dic.table_name=dtc.table_name
         AND dic.column_position=1))
       HEAD REPORT
        tmp = 0, cnt = 0
       DETAIL
        cnt = (cnt+ 1)
        IF (cnt > tmp)
         tmp = (tmp+ 10), stat = alterlist(dcd_datecols->list,tmp)
        ENDIF
        dcd_datecols->list[cnt].columns = dtc.column_name
       FOOT REPORT
        stat = alterlist(dcd_datecols->list,cnt)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc) != 0)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       SET dm2_compare_rec->tab[i].skip_reason = "Indexed date column not specified for table."
      ELSE
       SET done = false
       SET dcd_acceptdefault = "M"
       SET help =
       SELECT
        column = substring(1,30,dcd_datecols->list[d.seq].columns)
        FROM (dummyt d  WITH seq = value(size(dcd_datecols->list,5)))
       ;end select
       DECLARE dcd_datecol = vc WITH protect, noconstant("DM2NOTSET")
       WHILE ( NOT (done))
         CALL clear(1,1)
         CALL box(1,1,7,131)
         CALL text(2,2,concat("Please provide the driver date column for ",dm2_compare_rec->tab[i].
           owner,".",dm2_compare_rec->tab[i].table_name,":"))
         CALL text(4,2,"Column Name:")
         IF (dcd_datecol != "DM2NOTSET")
          CALL text(4,14,dcd_datecol)
         ENDIF
         CALL text(6,2,"(M)odify, (C)ontinue, (Q)uit: ")
         CALL accept(6,33,"A;CU",dcd_acceptdefault
          WHERE curaccept IN ("M", "C", "Q"))
         CASE (curaccept)
          OF "M":
           CALL accept(4,14,"P(30);CF")
           SET dcd_datecol = curaccept
           SET dcd_acceptdefault = "C"
          OF "C":
           SET dm2_compare_rec->tab[i].datecol = dcd_datecol
           SET done = true
          OF "Q":
           RETURN(0)
         ENDCASE
       ENDWHILE
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_validate_uniqueidx(notnull_ind)
   RECORD dcd_ind_cols(
     1 col_cnt = i2
     1 columns[*]
       2 col_name = vc
       2 data_type = vc
   )
   SET dm_err->eproc = "Getting Unique Key Columns"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT
    IF (notnull_ind=1)
     PLAN (d
      WHERE (dm2_compare_rec->tab[d.seq].nkeycol_cnt=- (1)))
      JOIN (dic
      WHERE (dic.table_owner=dm2_compare_rec->tab[d.seq].owner)
       AND (dic.table_name=dm2_compare_rec->tab[d.seq].table_name)
       AND ((dic.index_name IN (
      (SELECT
       di.index_name
       FROM dba_indexes di
       WHERE di.uniqueness="UNIQUE"
        AND (di.owner=dm2_compare_rec->tab[d.seq].owner)
        AND (di.table_name=dm2_compare_rec->tab[d.seq].table_name)
        AND  EXISTS (
       (SELECT
        1
        FROM dba_ind_columns dic2,
         dm2_dba_notnull_cols ddnc
        WHERE dic2.index_name=di.index_name
         AND dic2.index_owner=di.owner
         AND ddnc.column_name=dic2.column_name
         AND ddnc.owner=dic2.table_owner
         AND ddnc.table_name=dic2.table_name))))) OR (dic.column_name="DM2_MIG_SEQ_ID")) )
      JOIN (dtc
      WHERE dtc.table_name=dic.table_name
       AND dtc.column_name=dic.column_name
       AND dtc.owner=dic.table_owner
       AND (dtc.table_name=dm2_compare_rec->tab[d.seq].table_name)
       AND (dtc.owner=dm2_compare_rec->tab[d.seq].owner))
      JOIN (ao
      WHERE ao.object_name=dtc.table_name
       AND ao.object_type="TABLE"
       AND ao.owner=dtc.owner)
    ELSE
     PLAN (d
      WHERE (dm2_compare_rec->tab[d.seq].nkeycol_cnt=- (1)))
      JOIN (dic
      WHERE (dic.table_owner=dm2_compare_rec->tab[d.seq].owner)
       AND (dic.table_name=dm2_compare_rec->tab[d.seq].table_name)
       AND dic.index_name IN (
      (SELECT
       di.index_name
       FROM dba_indexes di
       WHERE di.uniqueness="UNIQUE"
        AND (di.owner=dm2_compare_rec->tab[d.seq].owner)
        AND (di.table_name=dm2_compare_rec->tab[d.seq].table_name))))
      JOIN (dtc
      WHERE dtc.table_name=dic.table_name
       AND dtc.column_name=dic.column_name
       AND dtc.owner=dic.table_owner
       AND (dtc.table_name=dm2_compare_rec->tab[d.seq].table_name)
       AND (dtc.owner=dm2_compare_rec->tab[d.seq].owner))
      JOIN (ao
      WHERE ao.object_name=dtc.table_name
       AND ao.object_type="TABLE"
       AND ao.owner=dtc.owner)
    ENDIF
    INTO "nl:"
    FROM dba_tab_columns dtc,
     dba_ind_columns dic,
     all_objects ao,
     (dummyt d  WITH seq = value(dm2_compare_rec->tbl_cnt))
    ORDER BY dic.table_owner, dic.table_name, dic.index_name DESC,
     dic.column_position
    HEAD dic.table_owner
     row + 0
    HEAD dic.table_name
     dm2_compare_rec->tab[d.seq].keycol_cnt = 9999, dm2_compare_rec->tab[d.seq].object_id =
     cnvtstring(ao.object_id)
    HEAD dic.index_name
     tmp = 0, stat = initrec(dcd_ind_cols)
    DETAIL
     dcd_ind_cols->col_cnt = (dcd_ind_cols->col_cnt+ 1)
     IF ((dcd_ind_cols->col_cnt > tmp))
      tmp = (tmp+ 10), stat = alterlist(dcd_ind_cols->columns,tmp)
     ENDIF
     dcd_ind_cols->columns[dcd_ind_cols->col_cnt].col_name = dic.column_name, dcd_ind_cols->columns[
     dcd_ind_cols->col_cnt].data_type = dtc.data_type
    FOOT  dic.index_name
     IF ((dcd_ind_cols->col_cnt < dm2_compare_rec->tab[d.seq].keycol_cnt))
      stat = alterlist(dm2_compare_rec->tab[d.seq].keycols,dcd_ind_cols->col_cnt), dm2_compare_rec->
      tab[d.seq].keycol_cnt = dcd_ind_cols->col_cnt
      FOR (i = 1 TO dcd_ind_cols->col_cnt)
       dm2_compare_rec->tab[d.seq].keycols[i].column_name = dcd_ind_cols->columns[i].col_name,
       dm2_compare_rec->tab[d.seq].keycols[i].data_type = dcd_ind_cols->columns[i].data_type
      ENDFOR
     ENDIF
    FOOT  dic.table_name
     IF ((dm2_compare_rec->tab[d.seq].keycol_cnt=9999))
      dm2_compare_rec->tab[d.seq].keycol_cnt = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    RETURN(0)
   ENDIF
   FOR (i = 1 TO dm2_compare_rec->tbl_cnt)
     IF ((dm2_compare_rec->tab[i].keycol_cnt=0))
      SET dm2_compare_rec->tab[i].skip_reason = "A valid unique index was not found."
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Populating column list."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   DECLARE dcd_start = i4 WITH protect, noconstant(1)
   DECLARE dcd_top = i4 WITH protect, noconstant(0)
   SET dcd_top = (ceil((cnvtreal(dm2_compare_rec->tbl_cnt)/ 50)) * 50)
   SET stat = alterlist(dm2_compare_rec->tab,dcd_top)
   FOR (i = (dm2_compare_rec->tbl_cnt+ 1) TO dcd_top)
    SET dm2_compare_rec->tab[i].table_name = dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].
    table_name
    SET dm2_compare_rec->tab[i].owner = dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].owner
   ENDFOR
   SELECT INTO "nl:"
    FROM dba_tab_columns dtc,
     (dummyt d  WITH seq = value((dcd_top/ 50)))
    PLAN (d
     WHERE (dm2_compare_rec->tbl_cnt > 0)
      AND assign(dcd_start,evaluate(d.seq,1,1,(dcd_start+ 50))))
     JOIN (dtc
     WHERE expand(dcd_num,dcd_start,(dcd_start+ 49),dtc.table_name,dm2_compare_rec->tab[dcd_num].
      table_name,
      dtc.owner,dm2_compare_rec->tab[dcd_num].owner)
      AND  NOT (dtc.data_type IN ("LONG", "CLOB", "BLOB", "LONG RAW", "RAW")))
    ORDER BY dtc.owner, dtc.table_name
    HEAD dtc.owner
     row + 0
    HEAD dtc.table_name
     tmp = 0, x = locateval(dcd_num,1,dm2_compare_rec->tbl_cnt,dtc.table_name,dm2_compare_rec->tab[
      dcd_num].table_name,
      dtc.owner,dm2_compare_rec->tab[dcd_num].owner), dm2_compare_rec->tab[x].nkeycol_cnt = 0
    DETAIL
     IF (locateval(dcd_num,1,dm2_compare_rec->tab[x].keycol_cnt,dtc.column_name,dm2_compare_rec->tab[
      x].keycols[dcd_num].column_name)=0)
      dm2_compare_rec->tab[x].nkeycol_cnt = (dm2_compare_rec->tab[x].nkeycol_cnt+ 1)
      IF ((dm2_compare_rec->tab[x].nkeycol_cnt > tmp))
       tmp = (tmp+ 10), stat = alterlist(dm2_compare_rec->tab[x].nkeycols,tmp)
      ENDIF
      dm2_compare_rec->tab[x].nkeycols[dm2_compare_rec->tab[x].nkeycol_cnt].column_name = dtc
      .column_name, dm2_compare_rec->tab[x].nkeycols[dm2_compare_rec->tab[x].nkeycol_cnt].data_type
       = dtc.data_type
     ENDIF
    FOOT  dtc.table_name
     stat = alterlist(dm2_compare_rec->tab[x].nkeycols,dm2_compare_rec->tab[x].nkeycol_cnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(dm2_compare_rec->tab,dm2_compare_rec->tbl_cnt)
   IF (check_error(dm_err->eproc) != 0)
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Error retrieving column info."
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_generate_mig_views(null)
   DECLARE dcd_key_columns = vc WITH protect, noconstant("")
   DECLARE dcd_nkey_columns = vc WITH protect, noconstant("")
   DECLARE dcd_null_keys = vc WITH protect, noconstant("")
   DECLARE dcd_null_nkeys = vc WITH protect, noconstant("")
   FOR (i = 1 TO dm2_compare_rec->tbl_cnt)
     IF ((((dm2_compare_rec->tab[i].owner != "V500")) OR ((dm2_compare_rec->v500_views_ind=1)))
      AND (dm2_compare_rec->tab[i].skip_reason=""))
      IF (textlen(dm2_compare_rec->tab[i].object_id) > 13)
       SET dm2_compare_rec->tab[i].skip_reason = "Object_id too long to create view"
      ELSE
       SET dcd_key_columns = dm2_compare_rec->tab[i].keycols[1].column_name
       SET dcd_null_keys = concat("null as ",dm2_compare_rec->tab[i].keycols[1].column_name)
       FOR (j = 2 TO dm2_compare_rec->tab[i].keycol_cnt)
        SET dcd_key_columns = concat(dcd_key_columns,", ",dm2_compare_rec->tab[i].keycols[j].
         column_name)
        SET dcd_null_keys = concat(dcd_null_keys,", null as ",dm2_compare_rec->tab[i].keycols[j].
         column_name)
       ENDFOR
       IF ((dm2_compare_rec->tab[1].nkeycol_cnt > 0))
        SET dcd_nkey_columns = dm2_compare_rec->tab[i].nkeycols[1].column_name
        SET dcd_null_nkeys = concat("null as ",dm2_compare_rec->tab[i].nkeycols[1].column_name)
        FOR (j = 2 TO dm2_compare_rec->tab[i].nkeycol_cnt)
         SET dcd_nkey_columns = concat(dcd_nkey_columns,", ",dm2_compare_rec->tab[i].nkeycols[j].
          column_name)
         SET dcd_null_nkeys = concat(dcd_null_nkeys,", null as ",dm2_compare_rec->tab[i].nkeycols[j].
          column_name)
        ENDFOR
       ENDIF
       SET dm_err->eproc = concat("Creating dm2migc",dm2_compare_rec->tab[i].object_id)
       CALL dm2_push_cmd(concat("rdb asis(^CREATE OR REPLACE VIEW DM2MIGC",dm2_compare_rec->tab[i].
         object_id," AS SELECT ^)"),0)
       CALL dm2_push_cmd(concat("asis(^ ",dcd_key_columns,", ",dcd_nkey_columns,
         ", -1 as dm2migrectype ^)"),0)
       CALL dm2_push_cmd(concat("asis(^FROM ",dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[
         i].table_name,"@",
         dm2_compare_rec->src_data_link," ^)"),0)
       IF ((dm2_compare_rec->tab[i].datecol != ""))
        CALL dm2_push_cmd(concat("asis(^ WHERE ",dm2_compare_rec->tab[i].datecol," >   ^)"),0)
        CALL dm2_push_cmd(concat("asis(^( (SYSDATE - INTERVAL '",trim(cnvtstring(curutcdiff)),
          "' second) - INTERVAL '",trim(cnvtstring(dm2_compare_rec->hrsback)),"' HOUR )^)"),0)
       ENDIF
       CALL dm2_push_cmd("asis(^MINUS^)",0)
       CALL dm2_push_cmd(concat("asis(^SELECT ",dcd_key_columns,", ",dcd_nkey_columns,
         ", -1 as dm2migrectype ^)"),0)
       CALL dm2_push_cmd(concat("asis(^FROM ",dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[
         i].table_name,"^)"),0)
       IF ((dm2_compare_rec->tab[i].datecol != ""))
        CALL dm2_push_cmd(concat("asis(^ WHERE ",dm2_compare_rec->tab[i].datecol," > ^)"),0)
        CALL dm2_push_cmd(concat("asis(^((SYSDATE - INTERVAL '",trim(cnvtstring(curutcdiff)),
          "' second) - INTERVAL '",trim(cnvtstring(dm2_compare_rec->hrsback)),"' HOUR )^)"),0)
       ENDIF
       CALL dm2_push_cmd("asis(^ UNION^)",0)
       CALL dm2_push_cmd(concat("asis(^ select ",dcd_null_keys,", ",dcd_null_nkeys,
         ", count(1) as dm2migrectype ^)"),0)
       CALL dm2_push_cmd(concat("asis(^FROM ",dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[
         i].table_name,"@",
         dm2_compare_rec->src_data_link," ^)"),0)
       IF ((dm2_compare_rec->tab[i].datecol != ""))
        CALL dm2_push_cmd(concat("asis(^WHERE ",dm2_compare_rec->tab[i].datecol," >^)"),0)
        CALL dm2_push_cmd(concat("asis(^ ((SYSDATE - INTERVAL '",trim(cnvtstring(curutcdiff)),
          "' second) - INTERVAL '",trim(cnvtstring(dm2_compare_rec->hrsback)),"' HOUR ) ^) "),0)
       ENDIF
       CALL dm2_push_cmd(asis("go"),1)
       SET dm2_compare_rec->tab[i].cmp_view_name = concat("DM2MIGC",dm2_compare_rec->tab[i].object_id
        )
       IF (check_error(dm_err->eproc) != 0)
        RETURN(0)
       ENDIF
       SET dm_err->eproc = concat("Creating dm2migs",dm2_compare_rec->tab[i].object_id)
       CALL dm2_push_cmd(concat("rdb asis(^CREATE OR REPLACE VIEW DM2MIGS",dm2_compare_rec->tab[i].
         object_id," AS ^)"),0)
       CALL dm2_push_cmd(concat("asis(^ SELECT ",dcd_key_columns,", ",dcd_nkey_columns," FROM ",
         dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[i].table_name,"@",dm2_compare_rec->
         src_data_link,
         "^) go"),1)
       SET dm2_compare_rec->tab[i].src_view_name = concat("DM2MIGS",dm2_compare_rec->tab[i].object_id
        )
       IF (check_error(dm_err->eproc) != 0)
        RETURN(0)
       ENDIF
       SET dm_err->eproc = concat("Creating dm2migt",dm2_compare_rec->tab[i].object_id)
       CALL dm2_push_cmd(concat("rdb asis(^CREATE OR REPLACE VIEW DM2MIGT",dm2_compare_rec->tab[i].
         object_id," AS ^)"),0)
       CALL dm2_push_cmd(concat("asis(^ SELECT ",dcd_key_columns,", ",dcd_nkey_columns," FROM ",
         dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[i].table_name,"^) go"),1)
       SET dm2_compare_rec->tab[i].tgt_view_name = concat("DM2MIGT",dm2_compare_rec->tab[i].object_id
        )
       IF (check_error(dm_err->eproc) != 0)
        RETURN(0)
       ENDIF
       SET dm_err->eproc = concat("Creating dm2migu",dm2_compare_rec->tab[i].object_id)
       CALL dm2_push_cmd(concat("rdb asis(^CREATE OR REPLACE VIEW DM2MIGU",dm2_compare_rec->tab[i].
         object_id," AS ^)"),0)
       CALL dm2_push_cmd(concat("asis(^ SELECT 'SOURCE' AS SOURCE, A.* FROM ",dm2_compare_rec->tab[i]
         .src_view_name," A"," UNION ALL SELECT 'TARGET' AS TARGET, B.* FROM ",dm2_compare_rec->tab[i
         ].tgt_view_name,
         " B^) go"),1)
       SET dm2_compare_rec->tab[i].union_view_name = concat("DM2MIGU",dm2_compare_rec->tab[i].
        object_id)
       IF (check_error(dm_err->eproc) != 0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   EXECUTE oragen3 "DM2MIG*"
   IF ((dm_err->err_ind != 0))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_validate_prompt(null)
   DECLARE dvp_sample_exists_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Determining if mismatch sample exists from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_MISMATCH"
    DETAIL
     dvp_sample_exists_ind = 1
    WITH nocounter, maxqual(di,1)
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,2,"Data Validation")
   IF (dvp_sample_exists_ind)
    CALL text(4,2,"Mismatched row data was found from a previous comparison.")
    CALL text(5,2,"(C)ontinue with previous sample, (R)estart with new sample, or (Q)uit: ")
    CALL accept(5,73,"A;CU","C"
     WHERE curaccept IN ("R", "C", "Q"))
    IF (curaccept="Q")
     SET message = nowindow
     CALL clear(1,1)
     RETURN(0)
    ENDIF
    SET dm2_compare_rec->restart_compare_ind = evaluate(curaccept,"R",1,0)
   ENDIF
   IF (((dm2_compare_rec->restart_compare_ind) OR ( NOT (dvp_sample_exists_ind))) )
    CALL text(7,2,"How many rows would you like to compare?")
    CALL accept(7,43,"99999999;",1000
     WHERE curaccept > 0)
    SET dm2_compare_rec->rows_to_sample = curaccept
   ENDIF
   SET message = nowindow
   CALL clear(1,1)
   RETURN(1)
 END ;Subroutine
 IF (check_logfile("dm2_compare_data",".log","dm2_compare_data LOGFILE")=0)
  GO TO exit_script
 ENDIF
 DECLARE dcd_tdb_name = vc WITH protect, noconstant("")
 DECLARE dcd_sdb_name = vc WITH protect, noconstant("")
 DECLARE dcd_done = i2 WITH protect, noconstant(false)
 DECLARE dcd_where_clause = vc WITH protect, noconstant("")
 DECLARE dcd_mismatches = i4 WITH protect, noconstant(0)
 DECLARE dcd_keycols = vc WITH protect, noconstant("")
 DECLARE dcd_filler = vc WITH protect, noconstant("(")
 DECLARE dcd_tab_iterator = i4 WITH protect, noconstant(0)
 DECLARE dcd_col_iter = i4 WITH protect, noconstant(0)
 DECLARE dcd_col_iter2 = i4 WITH protect, noconstant(0)
 DECLARE dcd_mismatched = i2 WITH protect, noconstant(false)
 DECLARE dcd_row_iter = i4 WITH protect, noconstant(0)
 DECLARE dcd_column_value = vc WITH protect, noconstant("")
 DECLARE dcd_iterator = i4 WITH protect, noconstant(0)
 DECLARE dcd_detail_file_name = vc WITH protect, noconstant("")
 SET dm_err->eproc = "Gathering inputs"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 IF ((dm2_compare_rec->tbl_cnt=0))
  IF (dcd_get_input_data(null) <= 0)
   GO TO exit_script
  ENDIF
  IF (dcd_validate_datecols(null) <= 0)
   GO TO exit_script
  ENDIF
  IF (dcd_validate_uniqueidx(1) <= 0)
   GO TO exit_script
  ENDIF
  SET message = nowindow
 ENDIF
 SET dm_err->eproc = "Calling dcd_generate_mig_views"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 SET dm2_compare_rec->v500_views_ind = 1
 IF (dcd_generate_mig_views(null) <= 0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Acquiring defaults"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM2_COMPARE_DATA"
   AND di.info_name IN ("MAX_MISMATCH_ROWS", "MAX_RETRY_SECS")
  DETAIL
   IF (di.info_name="MAX_MISMATCH_ROWS")
    dm2_compare_rec->max_mm_rows = di.info_number
   ELSEIF (di.info_name="MAX_RETRY_SECS")
    dm2_compare_rec->max_retry_secs = di.info_number
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Checking for mismatched rows"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 FOR (dcd_tab_iterator = 1 TO dm2_compare_rec->tbl_cnt)
   IF ((dm2_compare_rec->tab[dcd_tab_iterator].skip_reason=""))
    CALL dm2_push_cmd("select into 'nl:' ",0)
    CALL dm2_push_cmd(concat("  from ",dm2_compare_rec->tab[dcd_tab_iterator].cmp_view_name," a "),0)
    CALL dm2_push_cmd(" order by a.dm2migrectype desc ",0)
    CALL dm2_push_cmd("  head report  ",0)
    CALL dm2_push_cmd(
     "   dm2_compare_rec->tab[dcd_tab_iterator].cmp_dt_tm = cnvtdatetime(curdate, curtime3) ",0)
    CALL dm2_push_cmd("   dm2_compare_rec->tab[dcd_tab_iterator].cmp_cnt = a.dm2migrectype ",0)
    CALL dm2_push_cmd(
     "    stat = alterlist(dm2_compare_rec->tab[dcd_tab_iterator].mm_rec, dm2_compare_rec->max_mm_rows) ",
     0)
    CALL dm2_push_cmd("detail ",0)
    CALL dm2_push_cmd(
     " if(a.dm2migrectype <0 and dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt <dm2_compare_rec->max_mm_rows)",
     0)
    CALL dm2_push_cmd(
     "  dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt = dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt + 1",
     0)
    CALL dm2_push_cmd("         stat =  alterlist(",0)
    CALL dm2_push_cmd(
     "   dm2_compare_rec->tab[dcd_tab_iterator].mm_rec[dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt].reccol,",
     0)
    CALL dm2_push_cmd("           dm2_compare_rec->tab[dcd_tab_iterator].keycol_cnt) ",0)
    FOR (dcd_iterator = 1 TO dm2_compare_rec->tab[dcd_tab_iterator].keycol_cnt)
      IF ((dm2_compare_rec->tab[dcd_tab_iterator].keycols[dcd_iterator].data_type IN ("NUMBER",
      "FLOAT")))
       CALL dm2_push_cmd(
        "dm2_compare_rec->tab[dcd_tab_iterator].mm_rec[dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt].reccol[",
        0)
       CALL dm2_push_cmd(build(dcd_iterator,"].colval_num ="),0)
       CALL dm2_push_cmd(concat("A.",dm2_compare_rec->tab[dcd_tab_iterator].keycols[dcd_iterator].
         column_name," "),0)
      ELSEIF ((dm2_compare_rec->tab[dcd_tab_iterator].keycols[dcd_iterator].data_type="DATE"))
       CALL dm2_push_cmd(
        "dm2_compare_rec->tab[dcd_tab_iterator].mm_rec[dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt].reccol[",
        0)
       CALL dm2_push_cmd(build(dcd_iterator,"].colval_dt ="),0)
       CALL dm2_push_cmd(concat("cnvtdatetime(A.",dm2_compare_rec->tab[dcd_tab_iterator].keycols[
         dcd_iterator].column_name,") "),0)
      ELSE
       CALL dm2_push_cmd(
        "dm2_compare_rec->tab[dcd_tab_iterator].mm_rec[dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt].reccol[",
        0)
       CALL dm2_push_cmd(build(dcd_iterator,"].colval_char ="),0)
       CALL dm2_push_cmd(concat("A.",dm2_compare_rec->tab[dcd_tab_iterator].keycols[dcd_iterator].
         column_name," "),0)
      ENDIF
    ENDFOR
    CALL dm2_push_cmd("       endif",0)
    CALL dm2_push_cmd("foot report ",0)
    CALL dm2_push_cmd("  stat = alterlist(",0)
    CALL dm2_push_cmd(
     "dm2_compare_rec->tab[dcd_tab_iterator].mm_rec, dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt)",
     0)
    CALL dm2_push_cmd(
     "  dm2_compare_rec->tab[dcd_tab_iterator].orig_mm_cnt = dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt",
     0)
    CALL dm2_push_cmd(" if(dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt > 0) ",0)
    CALL dm2_push_cmd("   dcd_mismatched = true ",0)
    CALL dm2_push_cmd(" endif",0)
    CALL dm2_push_cmd("with nocounter go",1)
    IF (check_error(dm_err->eproc) != 0)
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET dm_err->eproc = "Retrying compare logic"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 WHILE (dcd_done=false
  AND dcd_mismatched=true)
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,8,131)
   CALL text(2,2,"Row mismatches were found.")
   CALL text(4,2,
    "Waiting 15 seconds for data syncronization to catch up before recompare of mismatched rows.")
   CALL text(5,2,concat("If the initial mismatched rows are not resolved in ",trim(cnvtstring(((
       dm2_compare_rec->max_retry_secs - dm2_compare_rec->mm_retry_secs)/ 60))),
     " minutes, they will be considered persistent mismatches."))
   CALL text(7,2,"(Q)uit, (R)ecompare now:")
   SET accept = time(15)
   CALL accept(7,26,"A;CU","R")
   SET message = nowindow
   CALL clear(1,1)
   IF (curaccept="Q")
    GO TO exit_script
   ENDIF
   SET dm2_compare_rec->mm_retry_secs = (dm2_compare_rec->mm_retry_secs+ 15)
   SET dcd_mismatched = false
   FOR (dcd_tab_iterator = 1 TO dm2_compare_rec->tbl_cnt)
     SET dm_err->eproc = concat("Re-querying for column mismatches for ",dm2_compare_rec->tab[
      dcd_tab_iterator].owner,".",dm2_compare_rec->tab[dcd_tab_iterator].table_name)
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     FOR (dcd_row_iter = 1 TO dm2_compare_rec->tab[dcd_tab_iterator].orig_mm_cnt)
       IF ((dm2_compare_rec->tab[dcd_tab_iterator].mm_rec[dcd_row_iter].recrow_match_ind=0))
        SET dcd_where_clause = " "
        FOR (dcd_col_iter = 1 TO dm2_compare_rec->tab[dcd_tab_iterator].keycol_cnt)
         CASE (dm2_compare_rec->tab[dcd_tab_iterator].keycols[dcd_col_iter].data_type)
          OF "FLOAT":
          OF "NUMBER":
           SET dcd_where_clause = concat(dcd_where_clause,dm2_compare_rec->tab[dcd_tab_iterator].
            keycols[dcd_col_iter].column_name," = ",build(dm2_compare_rec->tab[dcd_tab_iterator].
             mm_rec[dcd_row_iter].reccol[dcd_col_iter].colval_num))
          OF "DATE":
           SET dcd_where_clause = concat(dcd_where_clause,dm2_compare_rec->tab[dcd_tab_iterator].
            keycols[dcd_col_iter].column_name," = cnvtdatetime(",build(dm2_compare_rec->tab[
             dcd_tab_iterator].mm_rec[dcd_row_iter].reccol[dcd_col_iter].colval_dt),")")
          ELSE
           SET dcd_where_clause = concat(dcd_where_clause,dm2_compare_rec->tab[dcd_tab_iterator].
            keycols[dcd_col_iter].column_name," = '",dm2_compare_rec->tab[dcd_tab_iterator].mm_rec[
            dcd_row_iter].reccol[dcd_col_iter].colval_char,"'")
         ENDCASE
         IF ((dcd_col_iter < dm2_compare_rec->tab[dcd_tab_iterator].keycol_cnt))
          SET dcd_where_clause = notrim(concat(dcd_where_clause," AND "))
         ENDIF
        ENDFOR
        SELECT INTO "nl:"
         FROM (value(dm2_compare_rec->tab[dcd_tab_iterator].cmp_view_name) a)
         WHERE parser(dcd_where_clause)
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc) != 0)
         GO TO exit_script
        ENDIF
        IF (curqual=0)
         SET dm2_compare_rec->tab[dcd_tab_iterator].mm_rec[dcd_row_iter].recrow_match_ind = 1
        ENDIF
       ENDIF
     ENDFOR
     SET dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt = 0
     FOR (dcd_col_iter = 1 TO dm2_compare_rec->tab[dcd_tab_iterator].orig_mm_cnt)
       IF ((dm2_compare_rec->tab[dcd_tab_iterator].mm_rec[dcd_col_iter].recrow_match_ind=0))
        SET dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt = (dm2_compare_rec->tab[
        dcd_tab_iterator].curr_mm_cnt+ 1)
        SET dcd_mismatched = true
       ENDIF
     ENDFOR
   ENDFOR
   IF ((dm2_compare_rec->mm_retry_secs >= dm2_compare_rec->max_retry_secs))
    SET dcd_done = true
   ENDIF
 ENDWHILE
 SET dm_err->eproc = "Getting target database name"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM v$database vdb
  DETAIL
   dcd_tdb_name = trim(vdb.name)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->logfile) != 0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Getting source database name"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM (value(concat("V$DATABASE@",dm2_compare_rec->src_data_link)) vdb)
  DETAIL
   dcd_sdb_name = concat(trim(vdb.name),"@",dm2_compare_rec->src_data_link)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->logfile) != 0)
  GO TO exit_script
 ENDIF
 IF (dcd_mismatched=true)
  IF (get_unique_file("dm2compdatd",".rpt")=0)
   GO TO exit_script
  ENDIF
  SET dcd_detail_file_name = dm_err->unique_fname
  SELECT INTO value(dcd_detail_file_name)
   FROM dummyt d
   HEAD REPORT
    col 0, row 0, x = fillstring(129,"*"),
    x, row + 1, col 1,
    "DM2_COMPARE DATA (Detail)", col 90, "REPORT DATE:",
    y = format(cnvtdatetime(curdate,curtime3),";;q"), col 102, y,
    row + 1, x, row + 2,
    "Criteria:", row + 1, "_________",
    row + 1, "Source Database      :", col + 1,
    dcd_sdb_name, row + 1, "Target Database      :",
    col + 1, dcd_tdb_name, row + 1,
    "Hours back           :", col + 1
    IF ((dm2_compare_rec->hrsback > 48))
     z = concat(cnvtstring((cnvtreal(dm2_compare_rec->hrsback)/ 24))," days.")
    ELSE
     z = concat(cnvtstring(dm2_compare_rec->hrsback)," hours.")
    ENDIF
    z, row + 1, "TABLE_NAME:"
    FOR (dcd_iterator = 1 TO dm2_compare_rec->tbl_cnt)
      col 21, dm2_compare_rec->tab[dcd_iterator].keycols[1].column_name
      FOR (dcd_col_iter = 2 TO dm2_compare_rec->tab[dcd_iterator].keycol_cnt)
       call reportmove('COL',(21+ (31 * (dcd_col_iter - 1))),0),dm2_compare_rec->tab[dcd_iterator].
       keycols[dcd_col_iter].column_name
      ENDFOR
      row + 1, col 0, "******************** ******************************"
      FOR (dcd_col_iter = 2 TO dm2_compare_rec->tab[dcd_iterator].keycol_cnt)
       col + 1"******************************"
      ENDFOR
      row + 1, col 1, dm2_compare_rec->tab[dcd_iterator].table_name
      FOR (dcd_row_iter = 1 TO dm2_compare_rec->tab[dcd_iterator].orig_mm_cnt)
        IF ((dm2_compare_rec->tab[dcd_iterator].mm_rec[dcd_row_iter].recrow_match_ind=0))
         FOR (dcd_col_iter = 1 TO dm2_compare_rec->tab[dcd_iterator].keycol_cnt)
          IF (dcd_col_iter=1)
           col 21
          ELSE
           call reportmove('COL',(21+ (31 * (dcd_col_iter - 1))),0)
          ENDIF
          ,
          CASE (dm2_compare_rec->tab[dcd_iterator].keycols[dcd_col_iter].data_type)
           OF "FLOAT":
           OF "NUMBER":
            z = substring(1,30,cnvtstring(dm2_compare_rec->tab[dcd_iterator].mm_rec[dcd_row_iter].
              reccol[dcd_col_iter].colval_num)),z
           OF "DATE":
            y = substring(1,30,format(dm2_compare_rec->tab[dcd_iterator].mm_rec[dcd_row_iter].reccol[
              dcd_col_iter].colval_dt,";;q")),y
           ELSE
            z = substring(1,30,dm2_compare_rec->tab[dcd_iterator].mm_rec[dcd_row_iter].reccol[
             dcd_col_iter].colval_char),z
          ENDCASE
         ENDFOR
         row + 1
        ENDIF
      ENDFOR
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
 IF (get_unique_file("dm2compdats",".rpt")=0)
  GO TO exit_script
 ENDIF
 SELECT INTO dm_err->unique_fname
  FROM dummyt d
  HEAD REPORT
   dcd_match_tables = 0, dcd_mismatch_tables = 0, dcd_mismatch_percent = 0.0,
   dcd_nocompare_ind = 0, col 0, row 0,
   x = fillstring(129,"*"), x, row + 1,
   col 1, "DM2_COMPARE DATA", col 90,
   "REPORT DATE:", y = format(cnvtdatetime(curdate,curtime3),";;q"), col 102,
   y, row + 1, x,
   row + 2, "Summary File Name:", col + 1,
   dm_err->unique_fname, row + 2, "Criteria:",
   row + 1, "_________", row + 1,
   "Source Database      :", col + 1, dcd_sdb_name,
   row + 1, "Target Database      :", col + 1,
   dcd_tdb_name, row + 1, "Hours back           :",
   col + 1
   IF ((dm2_compare_rec->hrsback > 48))
    z = concat(cnvtstring((cnvtreal(dm2_compare_rec->hrsback)/ 24))," days.")
   ELSE
    z = concat(cnvtstring(dm2_compare_rec->hrsback)," hours.")
   ENDIF
   z, row + 2, "Summary:",
   row + 1, "----------", row + 1,
   "Tables compared:     ", col + 1, dm2_compare_rec->tbl_cnt,
   row + 1
   FOR (dcd_tab_iterator = 1 TO dm2_compare_rec->tbl_cnt)
     IF ((dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt=0)
      AND (dm2_compare_rec->tab[dcd_tab_iterator].skip_reason=""))
      dcd_match_tables = (dcd_match_tables+ 1)
     ELSEIF ((dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt > 0))
      dcd_mismatch_tables = (dcd_mismatch_tables+ 1)
     ENDIF
   ENDFOR
   "Tables matched:      ", col + 1, dcd_match_tables,
   row + 1, "Tables mismatched:   ", col + 1,
   dcd_mismatch_tables, row + 1, j = (dm2_compare_rec->tbl_cnt - (dcd_match_tables+
   dcd_mismatch_tables)),
   "Tables not compared: ", col + 1, j,
   row + 1, dcd_mismatch_percent = ((cnvtreal(dcd_match_tables)/ (dcd_match_tables+
   dcd_mismatch_tables)) * 100), "Table match percent: ",
   col + 1, dcd_mismatch_percent, row + 2
   IF (dcd_mismatch_tables > 0)
    "Detail File Name:", col + 1, dcd_detail_file_name,
    row + 2
   ENDIF
   x, row + 1, col 96,
   "PERSISTENT", row + 1, col 25,
   "DATE", col 55, "DATA COMPARED",
   col 77, "ROWS", col 96,
   "ROW", col 117, "MATCH",
   row + 1, "TABLE_NAME", col 25,
   "COLUMN", col 55, "AS OF DT/TM",
   col 77, "COMPARED", col 96,
   "MISMATCHES", col 117, "PERCENT",
   row + 1
   IF (dcd_mismatch_tables > 0)
    x, row + 1, "Mismatched Tables",
    row + 1, x, row + 1
    FOR (dcd_tab_iterator = 1 TO dm2_compare_rec->tbl_cnt)
      IF ((dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt > 0))
       col 1, dm2_compare_rec->tab[dcd_tab_iterator].table_name, col 25,
       dm2_compare_rec->tab[dcd_tab_iterator].datecol, col 55, y = format(cnvtdatetime(
         dm2_compare_rec->tab[dcd_tab_iterator].cmp_dt_tm),";;Q"),
       y, col 75, dm2_compare_rec->tab[dcd_tab_iterator].cmp_cnt,
       col 92, dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt, col 109,
       dcd_mismatch_percent = ((1.0 - (cnvtreal(dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt)/
       dm2_compare_rec->tab[dcd_tab_iterator].cmp_cnt)) * 100), dcd_mismatch_percent, row + 1
      ENDIF
    ENDFOR
   ENDIF
   IF (dcd_match_tables > 0)
    x, row + 1, "Matched Tables",
    row + 1, x, row + 1
    FOR (dcd_tab_iterator = 1 TO dm2_compare_rec->tbl_cnt)
      IF ((dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt=0)
       AND (dm2_compare_rec->tab[dcd_tab_iterator].skip_reason=""))
       col 1, dm2_compare_rec->tab[dcd_tab_iterator].table_name, col 25,
       dm2_compare_rec->tab[dcd_tab_iterator].datecol, col 55, y = format(cnvtdatetime(
         dm2_compare_rec->tab[dcd_tab_iterator].cmp_dt_tm),";;Q"),
       y, col 75, dm2_compare_rec->tab[dcd_tab_iterator].cmp_cnt,
       col 92, dm2_compare_rec->tab[dcd_tab_iterator].curr_mm_cnt, col 109,
       dcd_mismatch_percent = 100, dcd_mismatch_percent, row + 1
      ENDIF
    ENDFOR
   ENDIF
   FOR (dcd_tab_iterator = 1 TO dm2_compare_rec->tbl_cnt)
     IF ((dm2_compare_rec->tab[dcd_tab_iterator].skip_reason != ""))
      dcd_nocompare_ind = 1
     ENDIF
   ENDFOR
   IF (dcd_nocompare_ind=1)
    x, row + 1, "Tables not compared",
    row + 1, x, row + 1
    FOR (dcd_tab_iterator = 1 TO dm2_compare_rec->tbl_cnt)
      IF ((dm2_compare_rec->tab[dcd_tab_iterator].skip_reason != ""))
       col 1, dm2_compare_rec->tab[dcd_tab_iterator].table_name, col 25,
       dm2_compare_rec->tab[dcd_tab_iterator].skip_reason, row + 1
      ENDIF
    ENDFOR
   ENDIF
  WITH nocounter, nullreport, maxcol = 500
 ;end select
 IF (dm2_disp_file(dm_err->unique_fname,"Summary Report")=0)
  GO TO exit_script
 ENDIF
#exit_script
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "Dm2_compare_data completed succesfully."
 ELSE
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 CALL final_disp_msg("dm2_compare_data")
END GO
