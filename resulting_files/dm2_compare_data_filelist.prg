CREATE PROGRAM dm2_compare_data_filelist
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
 IF (check_logfile("dm2_compare_filelist",".log","dm2_compare_filelist LOGFILE")=0)
  GO TO exit_script
 ENDIF
 DECLARE dcdf_file_name = vc WITH protect, noconstant("cer_install:dm2_mig_compare_data.csv")
 SET dcdf_file_name =  $1
 IF (check_error(dm_err->eproc) != 0)
  SET dm_err->emsg = "Parameter usage: dm2_compare_data_filelist <filelist>"
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Loading input file from disk."
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 IF (findfile(dcdf_file_name) != 1)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("Could not locate the input file! (",dcdf_file_name,")")
  GO TO exit_script
 ELSE
  SET logical inputfile1 value(dcdf_file_name)
  FREE DEFINE rtl2
  DEFINE rtl2 "InputFile1"
  SELECT INTO "nl:"
   r.line
   FROM rtl2t r
   HEAD REPORT
    tmp = 0, begin_ptr = 0, end_ptr = 0
   DETAIL
    IF (trim(r.line) != "")
     dm2_compare_rec->tbl_cnt = (dm2_compare_rec->tbl_cnt+ 1)
     IF ((dm2_compare_rec->tbl_cnt > tmp))
      tmp = (tmp+ 20), stat = alterlist(dm2_compare_rec->tab,tmp)
     ENDIF
     begin_ptr = findstring(",",r.line), end_ptr = findstring(",",r.line,(begin_ptr+ 1)),
     dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].owner = trim(substring(1,(begin_ptr - 1),r.line)),
     dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].table_name = trim(substring((begin_ptr+ 1),((
       end_ptr - begin_ptr) - 1),r.line)), dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].datecol =
     trim(substring((end_ptr+ 1),(textlen(r.line) - end_ptr),r.line)), dm2_compare_rec->tab[
     dm2_compare_rec->tbl_cnt].nkeycol_cnt = - (1)
    ENDIF
   FOOT REPORT
    stat = alterlist(dm2_compare_rec->tab,dm2_compare_rec->tbl_cnt)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   GO TO exit_script
  ELSEIF ((dm2_compare_rec->tbl_cnt=0))
   SET dm_err->emsg = "The input file is empty!"
   SET dm_err->err_ind = 1
   GO TO exit_script
  ENDIF
  IF (dcd_get_input_data(null) < 0)
   GO TO exit_script
  ENDIF
  IF (dcd_validate_datecols(null) < 0)
   GO TO exit_script
  ENDIF
  SET message = nowindow
  IF (dcd_validate_uniqueidx(null) < 0)
   GO TO exit_script
  ENDIF
  SET message = nowindow
  EXECUTE dm2_compare_data value(dcdf_file_name)
#exit_script
  IF ((dm_err->err_ind=0))
   SET dm_err->eproc = "Dm2_validate_data completed succesfully."
  ELSE
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
  CALL final_disp_msg("dm2_compare_filelist")
 ENDIF
END GO
