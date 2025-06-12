CREATE PROGRAM dm_drop_obsolete_objects:dba
 DECLARE rowcount = i4
 DECLARE rdm_in_house = c1
 DECLARE do_full_col_exists = i2
 DECLARE do_column_exists = i2
 DECLARE do_ora_version = i2
 DECLARE parent_finder_iter = i4 WITH protect, noconstant(0)
 DECLARE drp_cln_iter = i4 WITH protect, noconstant(0)
 DECLARE insert_iter = i4 WITH protect, noconstant(0)
 DECLARE ixtc = i4 WITH protect, noconstant(0)
 DECLARE itxc = i4 WITH protect, noconstant(0)
 DECLARE doxt = i4 WITH protect, noconstant(0)
 DECLARE doxtz = i4 WITH protect, noconstant(0)
 DECLARE v_ccldiraccessval = vc WITH public, constant(logical("CCLDIRACCESS"))
 FREE RECORD drp_cln
 RECORD drp_cln(
   1 qual[*]
     2 child_table = vc
     2 parent_table = vc
     2 child_column = vc
 )
 SET width = 132
 SET reqinfo->updt_task = 15301
 SET header_str = fillstring(5,"-")
 SET drop_str = fillstring(200,"")
 SET do_full_col_exists = 1
 IF (validate(errcode,0)=0)
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  SET errcode = error(errmsg,1)
 ENDIF
 SET do_ora_version = 0
 SELECT INTO "nl:"
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   do_ora_version = cnvtint(substring(1,findstring(".",p.version,1,0),p.version)),
   CALL echo(build("ORACLE_VERSION:",do_ora_version))
  WITH nocounter
 ;end select
 RANGE OF a IS dm_tables_doc
 IF (validate(a.full_table_name,"BARTXYZ")="BARTXYZ")
  SET do_full_col_exists = 0
 ENDIF
 FREE RANGE a
 FREE RECORD drp_obj
 RECORD drp_obj(
   1 db_object_name = vc
   1 db_object_rename = vc
   1 db_object_dropped = i2
   1 db_ccldef_exists = i2
   1 db_object_type = vc
   1 db_found_ind = i2
   1 db_drop_ind = i2
   1 db_tblspace_name = vc
   1 tmp_db_object_name = vc
   1 packaging_flag = i2
   1 inhouse_flag = i2
   1 icnt = i4
   1 tmp_count = i4
   1 index_count = i4
   1 tmp_parse_str = vc
   1 tmp_str = vc
   1 iqual[*]
     2 ind_name = vc
     2 tbl_name = vc
   1 i_tcnt = i4
   1 i_tqual[*]
     2 tblspace_name = vc
   1 constraint_table = vc
   1 constraint_name = vc
   1 constraint_type = c1
   1 constraint_column = vc
   1 cons[*]
     2 constraint_name = vc
     2 constraint_table = vc
 )
 SET drp_obj->icnt = 0
 SET stat = alterlist(drp_obj->iqual,drp_obj->icnt)
 SET drp_obj->i_tcnt = 0
 SET stat = alterlist(drp_obj->i_tqual,drp_obj->i_tcnt)
 SET db_object_desc = "The Object has been Dropped."
 SET drp_obj->db_object_name = cnvtupper( $1)
 SET drp_obj->db_object_type = cnvtupper( $2)
 SET drp_obj->db_drop_ind = cnvtint( $3)
 SET drp_obj->packaging_flag = 0
 SET drp_obj->inhouse_flag = 0
 SET drp_obj->db_found_ind = 0
 IF ((drp_obj->db_object_type="CONSTRAINT"))
  DECLARE i_domain = c19
  SET i_domain = "OBSOLETE_CONSTRAINT"
 ELSE
  DECLARE i_domain = c15
  SET i_domain = "OBSOLETE_OBJECT"
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND ((di.info_name="PACKAGING DOMAIN") OR (di.info_name="INHOUSE DOMAIN"))
  DETAIL
   IF (di.info_name="INHOUSE DOMAIN")
    drp_obj->inhouse_flag = 1
   ENDIF
   IF (di.info_name="PACKAGING DOMAIN")
    drp_obj->packaging_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE do_display(s_str,s_err)
   CALL echo(header_str)
   CALL echo(s_str)
   IF (s_err=1)
    SET errcode = s_err
    SET errmsg = s_str
   ENDIF
 END ;Subroutine
 SUBROUTINE exists_dm_info(indomain,inname,inchar)
  SELECT INTO "nl:"
   d.*
   FROM dm_info d
   WHERE d.info_domain=indomain
    AND d.info_name=inname
    AND d.info_char=inchar
   WITH nocounter
  ;end select
  IF (curqual=0)
   RETURN(false)
  ELSE
   RETURN(true)
  ENDIF
 END ;Subroutine
 SUBROUTINE write_dm_info(indomain,inname,inchar)
   CALL echo("Updating DM_INFO table...")
   IF (indomain="OBSOLETE_OBJECT"
    AND inchar="TABLE"
    AND build(drp_obj->db_object_rename) > " ")
    SET concat_indomain = concat(indomain,"_RENAMED")
    SET concat_inchar = concat(inchar,"|",build(drp_obj->db_object_name))
    SET rename = build(drp_obj->db_object_rename)
    IF (exists_dm_info(concat_indomain,rename,concat_inchar)=false)
     INSERT  FROM dm_info d
      SET d.info_domain = concat_indomain, d.info_name = rename, d.info_char = concat_inchar,
       d.info_date = cnvtdatetime(curdate,curtime3), d.updt_applctx = 1676, d.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       d.updt_cnt = 0, d.updt_id = 1676, d.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
    ELSE
     UPDATE  FROM dm_info d
      SET d.info_date = cnvtdatetime(curdate,curtime3), d.updt_applctx = 1676, d.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = 1676, d.updt_task = reqinfo->updt_task
      WHERE d.info_domain=concat_indomain
       AND d.info_name=rename
       AND d.info_char=inchar
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
   IF (exists_dm_info(indomain,inname,inchar)=false)
    INSERT  FROM dm_info d
     SET d.info_domain = indomain, d.info_name = inname, d.info_char = inchar,
      d.info_date = cnvtdatetime(curdate,curtime3), d.updt_applctx = 1676, d.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      d.updt_cnt = 0, d.updt_id = 1676, d.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_date = cnvtdatetime(curdate,curtime3), d.updt_applctx = 1676, d.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = 1676, d.updt_task = reqinfo->updt_task
     WHERE d.info_domain=indomain
      AND d.info_name=inname
      AND d.info_char=inchar
     WITH nocounter
    ;end update
   ENDIF
   IF (curqual=0)
    RETURN(false)
   ELSE
    RETURN(true)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE do_drop_object(s_drop_str,s_type,s_action)
   SET errcode = error(errmsg,1)
   IF (s_action="DROP"
    AND s_type="TABLE")
    IF (checkdic(drp_obj->db_object_name,"T",0)=2)
     SET drp_obj->db_ccldef_exists = 1
    ELSE
     SET drp_obj->db_ccldef_exists = 0
    ENDIF
    IF ((drp_obj->db_ccldef_exists=1))
     DECLARE ltablerowcnt = i2 WITH noconstant(0)
     SELECT INTO "nl:"
      FROM (parser(drp_obj->db_object_name) tblal)
      DETAIL
       ltablerowcnt = (ltablerowcnt+ 1)
      WITH nocounter, maxqual(tblal,5)
     ;end select
     SET errcode = error(errmsg,0)
     IF (((errcode=0) OR (errcode=18)) )
      IF (ltablerowcnt < 2)
       CALL parser(s_drop_str,1)
       SET drp_obj->db_object_dropped = 1
       CALL do_display(concat("Fewer than 2 rows; dropping table ",drp_obj->db_object_name),1)
      ELSE
       IF (substring((textlen(build(drp_obj->db_object_name)) - 1),2,drp_obj->db_object_name)="$O")
        SET drp_obj->db_object_dropped = 1
        CALL do_display(concat("Dropping $O Table..."),1)
        CALL parser(drop_str,1)
       ELSE
        SET drp_obj->db_object_dropped = 0
        SET drp_obj->db_object_rename = concat(build(substring(1,28,drp_obj->db_object_name)),"$O")
        SET drop_str = concat("rdb alter TABLE ",drp_obj->db_object_name," rename to ",drp_obj->
         db_object_rename," go")
        CALL do_display(concat("Renamed table ",drp_obj->db_object_name," to ",drp_obj->
          db_object_rename),1)
        CALL parser(drop_str,1)
       ENDIF
      ENDIF
     ENDIF
    ELSE
     CALL do_display("CCL Definition is not present.",0)
     CALL parser(s_drop_str,1)
    ENDIF
   ELSE
    CALL parser(s_drop_str,1)
   ENDIF
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    IF (errcode=284
     AND findstring("ORA-02429",errmsg) > 0)
     CALL do_display(concat("Dropping index '",drp_obj->db_object_name,
       "'.  You can ignore the error message, ORA-2429, if displayed."),0)
    ELSE
     CALL do_display(concat(s_action,"-",s_type,"-",drp_obj->db_object_name,
       "- could NOT be Performed !!!"),1)
     GO TO end_program
    ENDIF
   ELSE
    IF (s_type="CONSTRAINT")
     SELECT INTO "nl:"
      FROM user_constraints uc
      WHERE (uc.constraint_name=drp_obj->db_object_name)
       AND uc.owner=currdbuser
     ;end select
     IF (curqual=0
      AND s_action="DROP")
      CALL do_display(concat(drp_obj->db_object_name," (",s_type,") was Successfully Dropped."),0)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM dba_objects do
      WHERE (do.object_name=drp_obj->db_object_name)
       AND do.object_type=s_type
       AND ((do.owner=currdbuser) OR (do.owner="PUBLIC"))
      WITH nocounter
     ;end select
     IF (curqual=0
      AND s_action="DROP")
      CALL do_display(concat(drp_obj->db_object_name," (",s_type,") Object was Successfully Dropped."
        ),0)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE clean_cmb_children(child_tbl,child_const,child_col)
   IF ((drp_obj->db_object_type="CONSTRAINT")
    AND (drp_obj->constraint_type="R"))
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CMB_LAST_UPDT"
     WITH forupdatewait(d)
    ;end select
    SET errcode = error(errmsg,0)
    IF (errcode != 0)
     CALL do_display(" DM_CMB_CHILDREN clean FAILED.  Unable to obtain CMB DM_INFO lock.",1)
     GO TO end_program
    ENDIF
    CALL do_display("Looking for rows on DM_CMB_CHILDREN that correspond to the obsolete constraint.",
     0)
    SET rowcnt = 0
    SELECT DISTINCT INTO "NL:"
     dm.child_table, dm.child_column
     FROM dm_cmb_children dm
     WHERE dm.child_table=child_tbl
      AND dm.child_column=child_col
     DETAIL
      rowcnt = (rowcnt+ 1), stat = alterlist(drp_cln->qual,rowcnt), drp_cln->qual[rowcnt].child_table
       = dm.child_table,
      drp_cln->qual[rowcnt].child_column = dm.child_column
     WITH nocounter
    ;end select
    IF (rowcnt > 0)
     CALL do_display("Attempting to delete from DM_CMB_CHILDREN...",0)
     SET errcode = error(errmsg,1)
     DELETE  FROM dm_cmb_children dm,
       (dummyt d  WITH seq = rowcnt)
      SET dm.seq = 1
      PLAN (d)
       JOIN (dm
       WHERE (dm.child_table=drp_cln->qual[d.seq].child_table)
        AND (dm.child_column=drp_cln->qual[d.seq].child_column))
      WITH nocounter
     ;end delete
     SET errcode = error(errmsg,0)
     IF (errcode=0)
      IF (curqual >= rowcnt)
       COMMIT
       CALL do_display(" DM_CMB_CHILDREN clean SUCCESS.  COMMIT executed.",0)
      ELSE
       ROLLBACK
       CALL do_display(" DM_CMB_CHILDREN clean FAILED.  ROLLBACK executed.",1)
       GO TO end_program
      ENDIF
     ELSE
      ROLLBACK
      CALL do_display(" DM_CMB_CHILDREN clean FAILED.  ROLLBACK executed.",1)
      GO TO end_program
     ENDIF
    ELSE
     ROLLBACK
     CALL do_display("No rows found on DM_CMB_CHILDREN.  Checking for DM_CMB_CHILDREN2.",0)
     IF (checkdic("DM_CMB_CHILDREN2","T",0)=2)
      SELECT INTO "nl:"
       FROM dm_info d
       WHERE d.info_domain="DATA MANAGEMENT"
        AND d.info_name="CMB_LAST_UPDT2"
       WITH forupdatewait(d)
      ;end select
      SET errcode = error(errmsg,0)
      IF (errcode != 0)
       ROLLBACK
       CALL do_display(" DM_CMB_CHILDREN(2/PK) clean FAILED.  Unable to obtain CMB2 DM_INFO lock.",1)
       GO TO end_program
      ENDIF
      SELECT DISTINCT INTO "NL:"
       dmt.child_table, dmt.child_column
       FROM dm_cmb_children2 dmt
       WHERE dmt.child_table=child_tbl
        AND dmt.child_column=child_col
       DETAIL
        rowcnt = (rowcnt+ 1), stat = alterlist(drp_cln->qual,rowcnt), drp_cln->qual[rowcnt].
        child_table = dmt.child_table,
        drp_cln->qual[rowcnt].child_column = dmt.child_column
       WITH nocounter
      ;end select
      IF (rowcnt > 0)
       SET errcode = error(errmsg,1)
       DELETE  FROM dm_cmb_children2 dmt,
         (dummyt d  WITH seq = rowcnt)
        SET dmt.seq = 1
        PLAN (d)
         JOIN (dmt
         WHERE (dmt.child_table=drp_cln->qual[d.seq].child_table)
          AND (dmt.child_column=drp_cln->qual[d.seq].child_column))
        WITH nocounter
       ;end delete
       SET errcode = error(errmsg,0)
       IF (errcode=0)
        IF (curqual >= rowcnt)
         CALL do_display(" DM_CMB_CHILDREN2 clean SUCCESS.  COMMIT executed.",0)
        ELSE
         ROLLBACK
         CALL do_display(" DM_CMB_CHILDREN2 clean FAILED.  ROLLBACK executed.",1)
         GO TO end_program
        ENDIF
       ELSE
        ROLLBACK
        CALL do_display(" DM_CMB_CHILDREN2 clean FAILED.  ROLLBACK executed.",1)
        GO TO end_program
       ENDIF
      ELSE
       CALL do_display("No rows found on DM_CMB_CHILDREN2.",0)
      ENDIF
      CALL do_display("Checking for orphaned DM_CMB_CHILDREN_PK rows.",0)
      SELECT INTO "NL:"
       dccpk.child_table
       FROM dm_cmb_children_pk dccpk
       WHERE  NOT ( EXISTS (
       (SELECT
        "x"
        FROM dm_cmb_children2 dcc2
        WHERE dccpk.child_table=dcc2.child_table)))
       WITH nocounter
      ;end select
      SET errcode = error(errmsg,0)
      IF (errcode != 0)
       COMMIT
       CALL do_display("SELECT FROM DM_CMB_CHILDREN_PK FAILED.",1)
       GO TO end_program
      ENDIF
      SET rowcnt = curqual
      IF (rowcnt > 0)
       SET errcode = error(errmsg,1)
       DELETE  FROM dm_cmb_children_pk dccpk
        WHERE dccpk.child_table IN (
        (SELECT
         dccpk2.child_table
         FROM dm_cmb_children_pk dccpk2
         WHERE  NOT ( EXISTS (
         (SELECT
          "x"
          FROM dm_cmb_children2 dcc2
          WHERE dccpk2.child_table=dcc2.child_table)))))
        WITH nocounter
       ;end delete
       SET errcode = error(errmsg,0)
       COMMIT
       IF (errcode=0)
        IF (curqual >= rowcnt)
         CALL do_display(" DM_CMB_CHILDREN_PK clean SUCCESS.  COMMIT executed.",0)
        ELSE
         CALL do_display(" DM_CMB_CHILDREN_PK clean FAILED.",1)
         GO TO end_program
        ENDIF
       ELSE
        CALL do_display(" DM_CMB_CHILDREN_PK clean FAILED. ",1)
        GO TO end_program
       ENDIF
      ENDIF
     ELSE
      CALL do_display("Table DM_CMB_CHILDREN2 NOT found.  DM_CMB_CHILDREN2 clean NOT required.",0)
     ENDIF
    ENDIF
   ELSEIF ((drp_obj->db_object_type="CONSTRAINT")
    AND (drp_obj->db_found_ind=0))
    CALL do_display("Checking cleanup for DM_CMB_CHILDREN by constraint name.",0)
    RANGE OF doo IS dm_cmb_children
    IF (validate(doo.child_cons_name,"Y")="Y"
     AND validate(doo.child_cons_name,"N")="N")
     SET do_column_exists = 0
    ELSE
     SET do_column_exists = 1
    ENDIF
    FREE RANGE doo
    IF (do_column_exists=1)
     SELECT INTO "nl:"
      FROM dm_info d
      WHERE d.info_domain="DATA MANAGEMENT"
       AND d.info_name="CMB_LAST_UPDT"
      WITH forupdatewait(d)
     ;end select
     SET errcode = error(errmsg,0)
     IF (errcode != 0)
      ROLLBACK
      CALL do_display(" DM_CMB_CHILDREN clean FAILED.  Unable to obtain CMB DM_INFO lock.",1)
      GO TO end_program
     ENDIF
     SELECT INTO "NL:"
      dmt.child_cons_name
      FROM dm_cmb_children dmt
      WHERE ((dmt.child_cons_name=child_const) OR (dmt.child_cons_name=concat(trim(substring(1,28,
         child_const)),"$C")))
      WITH nocounter
     ;end select
     SET errcode = error(errmsg,0)
     IF (errcode != 0)
      ROLLBACK
      CALL do_display("SELECT FROM DM_CMB_CHILDREN FAILED.",1)
      GO TO end_program
     ENDIF
     SET rowcnt = curqual
     IF (rowcnt > 0)
      SET errcode = error(errmsg,1)
      DELETE  FROM dm_cmb_children dmt
       WHERE ((dmt.child_cons_name=child_const) OR (dmt.child_cons_name=concat(trim(substring(1,28,
          child_const)),"$C")))
       WITH nocounter
      ;end delete
      SET errcode = error(errmsg,0)
      IF (errcode=0)
       IF (curqual >= rowcnt)
        COMMIT
        CALL do_display(" DM_CMB_CHILDREN clean SUCCESS.  COMMIT executed.",0)
       ELSE
        ROLLBACK
        CALL do_display(" DM_CMB_CHILDREN clean FAILED.  ROLLBACK executed.",1)
        GO TO end_program
       ENDIF
      ELSE
       ROLLBACK
       CALL do_display(" DM_CMB_CHILDREN clean FAILED.  ROLLBACK executed.",1)
       GO TO end_program
      ENDIF
     ELSE
      ROLLBACK
      CALL do_display("No rows found on DM_CMB_CHILDREN.",0)
     ENDIF
    ENDIF
    CALL do_display("Checking on DM_CMB_CHILDREN2 by constraint name.",0)
    IF (checkdic("DM_CMB_CHILDREN2","T",0)=2)
     SELECT INTO "nl:"
      FROM dm_info d
      WHERE d.info_domain="DATA MANAGEMENT"
       AND d.info_name="CMB_LAST_UPDT2"
      WITH forupdatewait(d)
     ;end select
     SET errcode = error(errmsg,0)
     IF (errcode != 0)
      ROLLBACK
      CALL do_display(" DM_CMB_CHILDREN(2/PK) clean FAILED.  Unable to obtain CMB2 DM_INFO lock.",1)
      GO TO end_program
     ENDIF
     SET errcode = error(errmsg,1)
     SELECT INTO "NL:"
      dmt.child_cons_name
      FROM dm_cmb_children2 dmt
      WHERE ((dmt.child_cons_name=child_const) OR (dmt.child_cons_name=concat(trim(substring(1,28,
         child_const)),"$C")))
      WITH nocounter
     ;end select
     SET errcode = error(errmsg,0)
     IF (errcode != 0)
      ROLLBACK
      CALL do_display("SELECT FROM DM_CMB_CHILDREN2 FAILED.",1)
      GO TO end_program
     ENDIF
     SET rowcnt = curqual
     IF (rowcnt > 0)
      SET errcode = error(errmsg,1)
      DELETE  FROM dm_cmb_children2 dmt
       WHERE ((dmt.child_cons_name=child_const) OR (dmt.child_cons_name=concat(trim(substring(1,28,
          child_const)),"$C")))
       WITH nocounter
      ;end delete
      SET errcode = error(errmsg,0)
      IF (errcode=0)
       IF (curqual < rowcnt)
        ROLLBACK
        CALL do_display(" DM_CMB_CHILDREN2 clean FAILED.  ROLLBACK executed.",1)
        GO TO end_program
       ENDIF
      ELSE
       ROLLBACK
       CALL do_display(" DM_CMB_CHILDREN2 clean FAILED.  ROLLBACK executed.",1)
       GO TO end_program
      ENDIF
     ELSE
      ROLLBACK
      CALL do_display("No rows found on DM_CMB_CHILDREN2.",0)
     ENDIF
    ENDIF
    CALL do_display("Checking for orphaned DM_CMB_CHILDREN_PK rows.",0)
    SELECT INTO "NL:"
     dccpk.child_table
     FROM dm_cmb_children_pk dccpk
     WHERE  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_cmb_children2 dcc2
      WHERE dccpk.child_table=dcc2.child_table)))
     WITH nocounter
    ;end select
    SET errcode = error(errmsg,0)
    IF (errcode != 0)
     COMMIT
     CALL do_display("SELECT FROM DM_CMB_CHILDREN_PK FAILED.",1)
     GO TO end_program
    ENDIF
    SET rowcnt = curqual
    IF (rowcnt > 0)
     SET errcode = error(errmsg,1)
     DELETE  FROM dm_cmb_children_pk dccpk
      WHERE dccpk.child_table IN (
      (SELECT
       dccpk2.child_table
       FROM dm_cmb_children_pk dccpk2
       WHERE  NOT ( EXISTS (
       (SELECT
        "x"
        FROM dm_cmb_children2 dcc2
        WHERE dccpk2.child_table=dcc2.child_table)))))
      WITH nocounter
     ;end delete
     SET errcode = error(errmsg,0)
     COMMIT
     IF (errcode=0)
      IF (curqual >= rowcnt)
       CALL do_display(" DM_CMB_CHILDREN_PK clean SUCCESS.  COMMIT executed.",0)
      ELSE
       CALL do_display(" DM_CMB_CHILDREN_PK clean FAILED. ",1)
       GO TO end_program
      ENDIF
     ELSE
      CALL do_display(" DM_CMB_CHILDREN_PK clean FAILED. ",1)
      GO TO end_program
     ENDIF
    ELSE
     COMMIT
    ENDIF
   ELSEIF ((drp_obj->db_object_type="TABLE"))
    CALL do_display(concat(" +++ ~",drp_obj->db_object_name,"~ cleanup START."),0)
    SET rowcount = 0
    CALL do_display("Cleaning DM_CMB_CHILDREN...",0)
    SELECT DISTINCT INTO "nl:"
     dm.parent_table
     FROM dm_cmb_children dm
     WHERE (dm.child_table=drp_obj->db_object_name)
     DETAIL
      rowcount = (rowcount+ 1), stat = alterlist(drp_cln->qual,rowcount), drp_cln->qual[rowcount].
      child_table = dm.child_table,
      drp_cln->qual[rowcount].parent_table = dm.parent_table
     WITH nocounter
    ;end select
    IF (rowcount > 0)
     SET errcode = error(errmsg,1)
     DELETE  FROM dm_cmb_children dm
      WHERE (dm.child_table=drp_obj->db_object_name)
      WITH nocounter
     ;end delete
     SET errcode = error(errmsg,0)
     IF (errcode=0)
      IF (curqual >= rowcount)
       COMMIT
       CALL do_display(" DM_CMB_CHILDREN clean SUCCESS.  COMMIT executed.",0)
      ELSE
       ROLLBACK
       CALL do_display(" DM_CMB_CHILDREN cleaned FAILED.  ROLLBACK executed.",1)
       GO TO end_program
      ENDIF
     ELSE
      ROLLBACK
      CALL do_display(" DM_CMB_CHILDREN cleaned FAILED.  ROLLBACK executed.",1)
      GO TO end_program
     ENDIF
    ELSE
     CALL do_display("No rows found.  DM_CMB_CHILDREN clean NOT required.",0)
    ENDIF
    CALL do_display("Checking for the existence of DM_CMB_CHILDREN2...",0)
    IF (checkdic("DM_CMB_CHILDREN2","T",0)=2)
     CALL do_display("Checking for rows on DM_CMB_CHILDREN2...",0)
     DECLARE dcc2_cnt = i4
     SET dcc2_cnt = 0
     SELECT DISTINCT INTO "nl:"
      dmt.parent_table
      FROM dm_cmb_children2 dmt
      WHERE dmt.child_table IN (drp_obj->db_object_name, drp_obj->tmp_db_object_name)
      DETAIL
       dcc2_cnt = (dcc2_cnt+ 1), rowcount = (rowcount+ 1), stat = alterlist(drp_cln->qual,rowcount),
       drp_cln->qual[rowcount].child_table = dmt.child_table, drp_cln->qual[rowcount].parent_table =
       dmt.parent_table
      WITH nocounter
     ;end select
     IF (curqual)
      CALL do_display("Cleaning up DM_CMB_CHILDREN2...",0)
      SET errcode = error(errmsg,1)
      DELETE  FROM dm_cmb_children2 dmt
       WHERE dmt.child_table IN (drp_obj->db_object_name, drp_obj->tmp_db_object_name)
       WITH nocounter
      ;end delete
      SET errcode = error(errmsg,0)
      IF (errcode=0)
       IF (curqual >= dcc2_cnt)
        COMMIT
        CALL do_display(" DM_CMB_CHILDREN2 clean SUCCESS.  COMMIT executed.",0)
       ELSE
        ROLLBACK
        CALL do_display(" DM_CMB_CHILDREN2 clean FAILED.  ROLLBACK executed.",1)
        GO TO end_program
       ENDIF
      ELSE
       ROLLBACK
       CALL do_display(" DM_CMB_CHILDREN2 clean FAILED.  ROLLBACK executed.",1)
       GO TO end_program
      ENDIF
     ELSE
      CALL do_display("No rows found on DM_CMB_CHILDREN2.  Cleanup not required.",0)
     ENDIF
    ELSE
     CALL do_display("Table DM_CMB_CHILDREN2 NOT found.  Cleanup not required.",0)
    ENDIF
    CALL do_display("Cleaning DM_CMB_EXCEPTION...",0)
    SELECT DISTINCT INTO "nl:"
     dme.parent_entity
     FROM dm_cmb_exception dme
     WHERE dme.child_entity IN (drp_obj->db_object_name, drp_obj->tmp_db_object_name)
     HEAD dme.child_entity
      found_parent = 0
     DETAIL
      FOR (parent_finder_iter = 1 TO rowcount)
        IF ((dme.parent_entity=drp_cln->qual[parent_finder_iter].parent_table))
         found_parent = 1
        ENDIF
      ENDFOR
      IF (found_parent=0)
       rowcount = (rowcount+ 1), stat = alterlist(drp_cln->qual,rowcount), drp_cln->qual[rowcount].
       child_table = dme.child_entity,
       drp_cln->qual[rowcount].parent_table = dme.parent_entity
      ENDIF
     WITH nocounter
    ;end select
    DECLARE match_count = i4
    SET errcode = error(errmsg,1)
    FOR (drp_cln_iter = 1 TO value(size(drp_cln->qual,5)))
      SET match_count = 0
      SELECT INTO "nl:"
       dme.seq
       FROM dm_cmb_exception dme
       WHERE dme.child_entity IN (drp_obj->db_object_name, drp_obj->tmp_db_object_name)
        AND (dme.parent_entity=drp_cln->qual[drp_cln_iter].parent_table)
        AND dme.operation_type IN ("COMBINE", "UNCOMBINE")
       DETAIL
        match_count = (match_count+ 1)
       WITH nocounter
      ;end select
      IF (match_count > 0)
       CALL do_display(concat(" Updating DM_CMB_EXCEPTION rows for <",drp_obj->tmp_db_object_name,
         ">..."),0)
       UPDATE  FROM dm_cmb_exception dme
        SET dme.script_name = "NONE", dme.script_run_order = 0, dme.updt_task = reqinfo->updt_task,
         dme.updt_dt_tm = cnvtdatetime(curdate,curtime3)
        WHERE (dme.child_entity=drp_obj->tmp_db_object_name)
         AND (dme.parent_entity=drp_cln->qual[drp_cln_iter].parent_table)
         AND dme.operation_type IN ("COMBINE", "UNCOMBINE")
        WITH nocounter
       ;end update
       SET errcode = error(errmsg,0)
       IF (errcode=0)
        IF (curqual >= match_count)
         CALL do_display(concat(" DM_CMB_EXCEPTION updated for parent entity <",drp_cln->qual[
           drp_cln_iter].parent_table,">."),0)
        ELSE
         ROLLBACK
         CALL do_display(" DM_CMB_EXCEPTION clean FAILED for parent entity <",drp_cln->qual[
          drp_cln_iter].parent_table,">.  ROLLBACK executed.",1)
         GO TO end_program
        ENDIF
       ELSE
        ROLLBACK
        CALL do_display(" DM_CMB_EXCEPTION clean FAILED for parent entity <",drp_cln->qual[
         drp_cln_iter].parent_table,">.  ROLLBACK executed.",1)
        GO TO end_program
       ENDIF
      ELSE
       DECLARE optype = vc
       FOR (insert_iter = 1 TO 2)
         IF (insert_iter=1)
          SET optype = "COMBINE"
         ELSE
          SET optype = "UNCOMBINE"
         ENDIF
         CALL do_display(concat("Attempting insert in DM_CMB_EXCEPTION for parent entity <",drp_cln->
           qual[drp_cln_iter].parent_table,">..."),0)
         INSERT  FROM dm_cmb_exception d
          SET d.operation_type = optype, d.parent_entity = drp_cln->qual[drp_cln_iter].parent_table,
           d.child_entity = drp_obj->tmp_db_object_name,
           d.script_name = "NONE", d.single_encntr_ind = 0, d.script_run_order = 0,
           d.del_chg_id_ind = 0, d.updt_cnt = 0, d.updt_id = 0,
           d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = 0, d.updt_task = reqinfo->
           updt_task
          WITH nocounter
         ;end insert
         SET errcode = error(errmsg,0)
         IF (errcode=0)
          IF (curqual)
           CALL do_display(concat(optype," row inserted in DM_CMB_EXCEPTION for parent entity <",
             drp_cln->qual[drp_cln_iter].parent_table,">."),0)
          ELSE
           ROLLBACK
           CALL do_display(concat(
             "ERROR: Failed to insert rows in DM_CMB_EXCEPTION for parent entity <",drp_cln->qual[
             drp_cln_iter].parent_table,">.  Rollback executed."),1)
           GO TO end_program
          ENDIF
         ELSE
          CALL do_display(concat(
            "ERROR: Failed to insert rows in DM_CMB_EXCEPTION for parent entity <",drp_cln->qual[
            drp_cln_iter].parent_table,">.  Rollback executed."),1)
          CALL echo(errmsg)
          GO TO end_program
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
    SET errcode = error(errmsg,0)
    IF (errcode=0)
     COMMIT
     CALL do_display("DM_CMB_EXCEPTION Cleanup Successful.  COMMIT Executed.",0)
    ELSE
     ROLLBACK
     CALL do_display("DM_CMB_EXCEPTION Cleanup Failed.  ROLLBACK Executed.",1)
     GO TO end_program
    ENDIF
    CALL do_display(concat(" +++ ~",drp_obj->db_object_name,"~ cleanup END."),0)
    FREE RECORD drp_cln
   ENDIF
 END ;Subroutine
 IF (currdb="DB2UDB")
  SET errcode = 0
  CALL do_display("The operation succeeded.",0)
  GO TO exit_now
 ENDIF
 IF (findstring("$C",drp_obj->db_object_name) > 0)
  CALL do_display("ABORTED:  $C found in object name supplied.  Supply original object name instead.",
   1)
  GO TO end_program
 ENDIF
 IF ((drp_obj->inhouse_flag=1))
  SET rdm_in_house = "Y"
  GO TO start_process
 ENDIF
 IF (validate(readme_data->readme_id,2)=2)
  CALL do_display("ABORTED:  This program must be executed from OCD_INCL_SCHEMA!",1)
  GO TO end_program
 ENDIF
#start_process
 IF ((((drp_obj->db_object_name="")) OR ((drp_obj->db_object_type=""))) )
  CALL do_display("NOT a Valid Object Name or Object Type !!!",1)
  GO TO end_program
 ENDIF
 IF ((((drp_obj->db_object_name="\*")) OR ((drp_obj->db_object_type="\*")))
  AND (drp_obj->db_drop_ind=1))
  CALL do_display("NO Wild Cards Allowed for Object Name or Object Type with a Drop !!!",1)
  GO TO end_program
 ENDIF
 IF ( NOT ((drp_obj->db_drop_ind IN (0, 1, 2))))
  CALL do_display("NOT a Valid Input to Determine if Drop is Required or Not !!!",1)
  GO TO end_program
 ENDIF
 IF ((drp_obj->db_drop_ind=0))
  IF ((drp_obj->db_object_type="CONSTRAINT"))
   SELECT
    uc.constraint_name, uc.constraint_type, uc.table_name
    FROM user_constraints dbac
    WHERE (((uc.constraint_name=drp_obj->db_object_name)) OR (uc.constraint_name=concat(trim(
      substring(1,28,drp_obj->db_object_name)),"$C")))
     AND uc.owner=currdbuser
    ORDER BY uc.constraint_name
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL do_display("The CONSTRAINT was not found in USER_CONSTRAINTS table!!!",0)
   ENDIF
  ELSE
   SELECT
    do.object_id, do.status, do.object_type,
    object_name = substring(1,30,do.object_name), do.owner, do.created,
    do.last_ddl_time, do.timestamp
    FROM dba_objects do
    WHERE (((do.object_name=drp_obj->db_object_name)) OR (do.object_name=concat(trim(substring(1,28,
       drp_obj->db_object_name)),"$C")))
     AND do.object_type=patstring(drp_obj->db_object_type)
     AND ((do.owner=currdbuser) OR (do.owner="PUBLIC"))
    ORDER BY do.object_name
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL do_display("Object NOT Found in DBA_OBJECTS table !!!",0)
   ENDIF
  ENDIF
  GO TO end_program
 ENDIF
 IF ((drp_obj->db_drop_ind=2))
  CASE (drp_obj->db_object_type)
   OF "TABLE":
    SELECT
     *
     FROM dm_tables_doc dtd
     WHERE dtd.table_name=patstring(drp_obj->db_object_name)
      AND dtd.drop_ind=1
     ORDER BY dtd.table_name
     WITH nocounter
    ;end select
   OF "INDEX":
    SELECT
     *
     FROM dm_indexes_doc did
     WHERE did.index_name=patstring(drp_obj->db_object_name)
      AND did.drop_ind=1
     ORDER BY did.index_name
     WITH nocounter
    ;end select
   OF "CONSTRAINT":
    SELECT
     d.*
     FROM dm_info d
     WHERE d.info_domain=i_domain
      AND (d.info_name=drp_obj->db_object_name)
      AND d.info_char="CONSTRAINT"
     WITH nocounter
    ;end select
   ELSE
    CALL do_display("Not a Valid Object Name !!!",1)
  ENDCASE
  GO TO end_program
 ENDIF
 SET drp_obj->tmp_db_object_name = drp_obj->db_object_name
 SELECT
  IF ((drp_obj->db_object_type="CONSTRAINT"))
   WHERE (((do.object_name=drp_obj->db_object_name)) OR (do.object_name=concat(trim(substring(1,28,
      drp_obj->db_object_name)),"$C")))
    AND do.object_type="INDEX"
    AND ((do.owner=currdbuser) OR (do.owner="PUBLIC"))
  ELSE
  ENDIF
  INTO "nl:"
  do.object_id, do.status, do.object_type,
  object_name = substring(1,30,do.object_name), do.owner, do.created,
  do.last_ddl_time, do.timestamp
  FROM dba_objects do
  WHERE (((do.object_name=drp_obj->db_object_name)) OR (do.object_name=concat(trim(substring(1,28,
     drp_obj->db_object_name)),"$C")))
   AND (do.object_type=drp_obj->db_object_type)
   AND ((do.owner=currdbuser) OR (do.owner="PUBLIC"))
  DETAIL
   drp_obj->db_object_name = do.object_name
  WITH nocounter
 ;end select
 DECLARE ifound_ind = i2
 SET ifound_ind = 0
 IF (curqual)
  IF ((drp_obj->db_object_type="CONSTRAINT"))
   SET ifound_ind = 1
  ELSE
   SET drp_obj->db_found_ind = 1
  ENDIF
 ELSE
  CALL do_display("Object NOT Found in DBA_OBJECTS table...",0)
 ENDIF
 IF ((drp_obj->db_object_type="CONSTRAINT"))
  CALL do_display("Searching for constraint...",0)
  SELECT INTO "NL:"
   uc.table_name, uc.constraint_name, ucc.column_name
   FROM user_constraints uc,
    user_cons_columns ucc
   WHERE uc.owner=ucc.owner
    AND uc.constraint_name=ucc.constraint_name
    AND uc.table_name=ucc.table_name
    AND uc.owner=currdbuser
    AND ((ucc.position = null) OR (ucc.position=1))
    AND (((uc.constraint_name=drp_obj->db_object_name)) OR (uc.constraint_name=concat(trim(substring(
      1,28,drp_obj->db_object_name)),"$C")))
   DETAIL
    drp_obj->db_object_name = uc.constraint_name, drp_obj->constraint_type = uc.constraint_type,
    drp_obj->constraint_table = uc.table_name,
    drp_obj->constraint_column = ucc.column_name
   WITH nocounter
  ;end select
  IF (curqual)
   IF (ifound_ind=0)
    IF ((((drp_obj->constraint_type="U")) OR ((drp_obj->constraint_type="R"))) )
     CALL do_display("Constraint found.  Preparing to drop the constraint...",0)
     SET drp_obj->db_found_ind = 1
     GO TO process_object
    ELSE
     CALL do_display(
      "Constraint was not Unique or Referential.  Other constraint types not supported.",1)
     GO TO end_program
    ENDIF
   ELSE
    CALL do_display(concat("Found an Index Matching the Constraint Name <",drp_obj->db_object_name,
      ">.  Cannot drop constraint."),1)
    GO TO end_program
   ENDIF
  ELSE
   CALL do_display("Constraint NOT Found in USER_CONSTRAINTS table...",0)
   GO TO process_object
  ENDIF
 ENDIF
#process_object
 CASE (drp_obj->db_object_type)
  OF "CONSTRAINT":
   IF ((drp_obj->db_found_ind=1))
    SET drop_str = concat("rdb alter TABLE ",drp_obj->constraint_table," drop CONSTRAINT ",drp_obj->
     db_object_name," go")
    CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
   ENDIF
   IF (errcode=0)
    CALL clean_cmb_children(drp_obj->constraint_table,drp_obj->db_object_name,drp_obj->
     constraint_column)
   ENDIF
   GO TO end_program
  OF "DATABASE LINK":
   IF ((drp_obj->db_found_ind=1))
    SET drop_str = concat("rdb drop public ",drp_obj->db_object_type," ",drp_obj->db_object_name,
     " go")
    CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
   ENDIF
   GO TO end_program
  OF "FUNCTION":
   IF ((drp_obj->db_found_ind=1))
    SET drop_str = concat("rdb drop ",drp_obj->db_object_type," ",drp_obj->db_object_name," go")
    CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
   ENDIF
   GO TO end_program
  OF "INDEX":
   IF ((drp_obj->db_found_ind=1))
    CALL do_display("Determine Tablespace for Index ...",0)
    SELECT INTO "nl:"
     FROM user_indexes ui
     WHERE (ui.index_name=drp_obj->db_object_name)
     DETAIL
      drp_obj->db_tblspace_name = trim(ui.tablespace_name), drp_obj->constraint_table = trim(ui
       .table_name)
     WITH nocounter
    ;end select
    CALL do_display("Determine if Index has a Corresponding Constraint ...",0)
    SELECT INTO "NL:"
     uc.constraint_name
     FROM user_constraints uc
     WHERE (uc.constraint_name=drp_obj->db_object_name)
      AND (uc.table_name=drp_obj->constraint_table)
      AND uc.constraint_type IN ("P", "U")
     DETAIL
      drp_obj->constraint_name = trim(uc.constraint_name)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET drop_str = concat("rdb drop ",drp_obj->db_object_type," ",drp_obj->db_object_name," go")
    ELSE
     IF (do_ora_version >= 10)
      SET drop_str = concat("rdb alter TABLE ",drp_obj->constraint_table," drop CONSTRAINT ",drp_obj
       ->constraint_name," drop index go")
     ELSE
      SET drop_str = concat("rdb alter TABLE ",drp_obj->constraint_table," drop CONSTRAINT ",drp_obj
       ->constraint_name," go")
     ENDIF
    ENDIF
    CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
    IF (errcode=284
     AND findstring("ORA-02429",errmsg) > 0)
     CALL do_display("Loading the unique constraints...",0)
     SELECT INTO "nl:"
      c.constraint_name, c.table_name
      FROM user_constraints c
      WHERE (c.table_name=drp_obj->constraint_table)
       AND c.constraint_type="U"
      HEAD REPORT
       drp_obj->tmp_count = 0
      DETAIL
       drp_obj->tmp_count = (drp_obj->tmp_count+ 1), stat = alterlist(drp_obj->cons,drp_obj->
        tmp_count), drp_obj->cons[drp_obj->tmp_count].constraint_name = c.constraint_name,
       drp_obj->cons[drp_obj->tmp_count].constraint_table = c.table_name
      WITH nocounter
     ;end select
     CALL do_display("Dropping the unique constraints...",0)
     FOR (ixtc = 1 TO drp_obj->tmp_count)
       SET drp_obj->tmp_parse_str = concat("rdb alter table ",drp_obj->cons[ixtc].constraint_table,
        " drop constraint ",drp_obj->cons[ixtc].constraint_name," go")
       SET errcode = error(errmsg,1)
       CALL parser(drp_obj->tmp_parse_str)
       SET errcode = error(errmsg,0)
       IF (errcode != 0)
        CALL do_display(errmsg,0)
        GO TO end_program
       ENDIF
     ENDFOR
     CALL do_display("Checking for existence of Index..",0)
     SET drp_obj->index_count = 0
     SELECT INTO "nl:"
      i.index_name
      FROM user_indexes i
      WHERE (i.index_name=drp_obj->db_object_name)
      DETAIL
       drp_obj->index_count = 1
      WITH nocounter
     ;end select
     IF ((drp_obj->index_count=0))
      CALL do_display("Index dropped by unique constraint.",0)
     ELSE
      CALL do_display("Retrying drop of index...",0)
      CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
      IF (errcode=284
       AND findstring("ORA-02429",errmsg) > 0)
       CALL do_display("Determining PK constraint name...",0)
       SELECT INTO "nl:"
        c.constraint_name
        FROM user_constraints c
        WHERE (c.table_name=drp_obj->constraint_table)
         AND c.constraint_type="P"
        DETAIL
         drp_obj->tmp_str = c.constraint_name
        WITH nocounter
       ;end select
       SET drp_obj->tmp_count = 0
       CALL do_display("Grabbing list of FKs who reference PK...",0)
       SELECT INTO "nl:"
        c.constraint_name
        FROM user_constraints c
        WHERE (c.r_constraint_name=drp_obj->tmp_str)
         AND c.constraint_type="R"
        DETAIL
         drp_obj->tmp_count = (drp_obj->tmp_count+ 1), stat = alterlist(drp_obj->cons,drp_obj->
          tmp_count), drp_obj->cons[drp_obj->tmp_count].constraint_name = c.constraint_name,
         drp_obj->cons[drp_obj->tmp_count].constraint_table = c.table_name
        WITH nocounter
       ;end select
       CALL do_display("Disabling FKs...",0)
       FOR (itxc = 1 TO drp_obj->tmp_count)
         SET drp_obj->tmp_parse_str = concat("rdb alter table ",drp_obj->cons[itxc].constraint_table,
          " disable constraint ",drp_obj->cons[itxc].constraint_name," go")
         SET errcode = error(errmsg,1)
         CALL parser(drp_obj->tmp_parse_str)
         SET errcode = error(errmsg,0)
         IF (errcode != 0)
          CALL do_display(errmsg,0)
          GO TO end_program
         ENDIF
       ENDFOR
       CALL do_display("Disabling primary key...",0)
       SET drp_obj->tmp_parse_str = concat("rdb alter TABLE ",drp_obj->constraint_table,
        " disable primary key go")
       SET errcode = error(errmsg,1)
       CALL parser(drp_obj->tmp_parse_str)
       SET errcode = error(errmsg,0)
       IF (errcode != 0)
        CALL do_display(errmsg,0)
        GO TO end_program
       ENDIF
       CALL do_display("Checking for existence of Index..",0)
       SET drp_obj->index_count = 0
       SELECT INTO "nl:"
        i.index_name
        FROM user_indexes i
        WHERE (i.index_name=drp_obj->db_object_name)
        DETAIL
         drp_obj->index_count = 1
        WITH nocounter
       ;end select
       IF (curqual > 0)
        CALL do_display("Retrying drop of index...",0)
        CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
       ENDIF
       CALL do_display("Enabling primary key...",0)
       SET drp_obj->tmp_parse_str = concat("rdb alter TABLE ",drp_obj->constraint_table,
        " enable primary key go")
       SET errcode = error(errmsg,1)
       CALL parser(drp_obj->tmp_parse_str)
       SET errcode = error(errmsg,0)
       IF (errcode != 0)
        CALL do_display(errmsg,0)
        GO TO end_program
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    CALL do_display("Coalesce Tablespace for Index ...",0)
    SET drop_str = concat("rdb alter TABLESPACE ",trim(drp_obj->db_tblspace_name)," coalesce go")
    CALL do_drop_object(drop_str,"TABLESPACE","COALESCE")
   ENDIF
   SELECT INTO "NL:"
    dic.index_name, dic.updt_dt_tm
    FROM dm_indexes_doc dic
    WHERE (dic.index_name=drp_obj->tmp_db_object_name)
    WITH nocounter
   ;end select
   IF ((((drp_obj->packaging_flag=1)) OR ((drp_obj->inhouse_flag=0))) )
    IF (curqual)
     CALL do_display(concat("Update DM_INDEXES_DOC with the Dropped Object <",drp_obj->
       tmp_db_object_name,"> ..."),0)
     UPDATE  FROM dm_indexes_doc dic
      SET dic.updt_dt_tm = cnvtdatetime(curdate,curtime3), dic.updt_task = reqinfo->updt_task, dic
       .drop_ind = 1
      WHERE (dic.index_name=drp_obj->tmp_db_object_name)
      WITH nocounter
     ;end update
    ELSE
     CALL do_display(concat("No entry <",drp_obj->tmp_db_object_name,
       "> exists in the DM_INDEXES_DOC table."),0)
     INSERT  FROM dm_indexes_doc dic
      SET dic.index_name = drp_obj->tmp_db_object_name, dic.updt_applctx = 0, dic.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       dic.updt_cnt = 1, dic.updt_id = 0, dic.updt_task = reqinfo->updt_task,
       dic.drop_ind = 1
      WITH nocounter
     ;end insert
    ENDIF
    COMMIT
   ENDIF
   GO TO end_program
  OF "PACKAGE":
   IF ((drp_obj->db_found_ind=1))
    SET drop_str = concat("rdb drop ",drp_obj->db_object_type," ",drp_obj->db_object_name," go")
    CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
   ENDIF
   GO TO end_program
  OF "PACKAGE BODY":
   IF ((drp_obj->db_found_ind=1))
    SET drop_str = concat("rdb drop ",drp_obj->db_object_type," ",drp_obj->db_object_name," go")
    CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
   ENDIF
   GO TO end_program
  OF "PROCEDURE":
   IF ((drp_obj->db_found_ind=1))
    SET drop_str = concat("rdb drop ",drp_obj->db_object_type," ",drp_obj->db_object_name," go")
    CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
   ENDIF
   GO TO end_program
  OF "SEQUENCE":
   IF ((drp_obj->db_found_ind=1))
    SET drop_str = concat("rdb drop ",drp_obj->db_object_type," ",drp_obj->db_object_name," go")
    CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
   ENDIF
   GO TO end_program
  OF "SYNONYM":
   IF ((drp_obj->db_found_ind=1))
    SET drop_str = concat("rdb drop public ",drp_obj->db_object_type," ",drp_obj->db_object_name,
     " go")
    CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
   ENDIF
   GO TO end_program
  OF "TABLE":
   IF ((drp_obj->db_found_ind=1))
    CALL do_display("Determine Foreign Keys Associated with the Table to be Dropped ...",0)
    SET drp_obj->tmp_count = 0
    SELECT INTO "nl:"
     c.constraint_name
     FROM user_constraints c
     WHERE (c.table_name=drp_obj->db_object_name)
      AND c.constraint_type="R"
     DETAIL
      drp_obj->tmp_count = (drp_obj->tmp_count+ 1), stat = alterlist(drp_obj->cons,drp_obj->tmp_count
       ), drp_obj->cons[drp_obj->tmp_count].constraint_name = c.constraint_name
     WITH nocounter
    ;end select
    FOR (itxc = 1 TO drp_obj->tmp_count)
      SET drp_obj->tmp_parse_str = concat("rdb alter table ",drp_obj->db_object_name,
       " drop constraint ",drp_obj->cons[itxc].constraint_name," go")
      SET errcode = error(errmsg,1)
      CALL parser(drp_obj->tmp_parse_str)
      SET errcode = error(errmsg,0)
      IF (errcode != 0)
       CALL do_display(concat(drp_obj->cons[itxc].constraint_name,
         " Constraint was not Successfully Dropped."),1)
       GO TO end_program
      ELSE
       SELECT INTO "nl:"
        FROM user_constraints c
        WHERE (c.table_name=drp_obj->db_object_name)
         AND (c.constraint_name=drp_obj->cons[itxc].constraint_name)
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET stat = write_dm_info("OBSOLETE_CONSTRAINT",drp_obj->cons[itxc].constraint_name,
         "CONSTRAINT")
        IF (stat=true)
         COMMIT
        ENDIF
        CALL do_display(concat(drp_obj->cons[itxc].constraint_name,
          " Constraint was Successfully Dropped."),0)
       ELSE
        CALL do_display(concat(drp_obj->cons[itxc].constraint_name,
          " Constraint was not Successfully Dropped."),1)
        GO TO end_program
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   CALL do_display("Determine Synonym Associated with the Table to be Dropped ...",0)
   SELECT INTO "nl:"
    FROM dba_synonyms ds
    WHERE (ds.synonym_name=drp_obj->db_object_name)
     AND ds.owner="PUBLIC"
    ORDER BY ds.synonym_name
    WITH nocounter
   ;end select
   IF (curqual)
    SET drop_str = concat("rdb drop public SYNONYM ",drp_obj->db_object_name," go")
    CALL do_drop_object(drop_str,"SYNONYM","DROP")
   ENDIF
   IF ((drp_obj->db_found_ind=1))
    CALL do_display("Determine Indexes Associated with the Table to be Dropped ...",0)
    SELECT INTO "nl:"
     FROM user_indexes ui
     WHERE (ui.table_name=drp_obj->db_object_name)
     ORDER BY ui.index_name
     DETAIL
      drp_obj->icnt = (drp_obj->icnt+ 1), stat = alterlist(drp_obj->iqual,drp_obj->icnt), drp_obj->
      iqual[drp_obj->icnt].ind_name = trim(ui.index_name),
      drp_obj->iqual[drp_obj->icnt].tbl_name = drp_obj->db_object_name
      IF ((drp_obj->icnt=1))
       drp_obj->i_tcnt = (drp_obj->i_tcnt+ 1), stat = alterlist(drp_obj->i_tqual,drp_obj->i_tcnt),
       drp_obj->i_tqual[drp_obj->i_tcnt].tblspace_name = trim(ui.tablespace_name)
      ELSEIF ((drp_obj->i_tqual[drp_obj->i_tcnt].tblspace_name != ui.tablespace_name))
       drp_obj->i_tcnt = (drp_obj->i_tcnt+ 1), stat = alterlist(drp_obj->i_tqual,drp_obj->i_tcnt),
       drp_obj->i_tqual[drp_obj->i_tcnt].tblspace_name = trim(ui.tablespace_name)
      ENDIF
     WITH nocounter
    ;end select
    CALL do_display("Determine Tablespace for Table ...",0)
    SELECT INTO "nl:"
     FROM user_tables ut
     WHERE (ut.table_name=drp_obj->db_object_name)
     DETAIL
      drp_obj->db_tblspace_name = trim(ut.tablespace_name)
     WITH nocounter
    ;end select
    IF (do_ora_version >= 10)
     SET drop_str = concat("rdb drop ",drp_obj->db_object_type," ",drp_obj->db_object_name,
      " cascade constraints purge go")
    ELSE
     SET drop_str = concat("rdb drop ",drp_obj->db_object_type," ",drp_obj->db_object_name,
      " cascade constraints go")
    ENDIF
    CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
   ENDIF
   CALL do_display("Deteremine CCL Definition for Table ...",0)
   IF ((drp_obj->db_ccldef_exists=1))
    IF (v_ccldiraccessval="*READ*")
     CALL do_display(
      "Skipping dropping ccl definition for table, due to dictionary in read-only mode.",0)
    ELSE
     SET drop_str = concat("drop ",drp_obj->db_object_type," ",drp_obj->db_object_name," go")
     CALL do_drop_object(drop_str,"CCL DEF","DROP")
    ENDIF
   ELSE
    CALL do_display("Skipping drop of ccl definition for table, due to missing definition.",0)
   ENDIF
   IF ((drp_obj->db_found_ind=1))
    CALL do_display("Coalesce Tablespace for Table ...",0)
    SET drop_str = concat("rdb alter TABLESPACE ",trim(drp_obj->db_tblspace_name)," coalesce go")
    CALL do_drop_object(drop_str,"TABLESPACE","COALESCE")
    CALL do_display("Coalesce Tablespace for Index ...",0)
    FOR (itxc = 1 TO value(drp_obj->i_tcnt))
     SET drop_str = concat("rdb alter TABLESPACE ",trim(drp_obj->i_tqual[itxc].tblspace_name),
      " coalesce go")
     CALL do_drop_object(drop_str,"TABLESPACE","COALESCE")
    ENDFOR
   ENDIF
   SELECT INTO "NL:"
    dtc.table_name, dtc.description, dtc.updt_dt_tm
    FROM dm_tables_doc dtc
    WHERE (dtc.table_name=drp_obj->tmp_db_object_name)
    WITH nocounter
   ;end select
   IF ((((drp_obj->packaging_flag=1)) OR ((drp_obj->inhouse_flag=0))) )
    IF (curqual)
     CALL do_display(concat("Update DM_TABLES_DOC with the dropped object <",drp_obj->db_object_name,
       "> ..."),0)
     IF ((((drp_obj->inhouse_flag=0)) OR ((drp_obj->packaging_flag=1))) )
      IF (do_full_col_exists=1)
       UPDATE  FROM dm_tables_doc dtc
        SET dtc.description = db_object_desc, dtc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dtc
         .updt_task = reqinfo->updt_task,
         dtc.drop_ind = 1
        WHERE (dtc.full_table_name=drp_obj->tmp_db_object_name)
        WITH nocounter
       ;end update
      ELSEIF (do_full_col_exists=0)
       UPDATE  FROM dm_tables_doc dtc
        SET dtc.description = db_object_desc, dtc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dtc
         .updt_task = reqinfo->updt_task,
         dtc.drop_ind = 1
        WHERE (dtc.table_name=drp_obj->tmp_db_object_name)
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
     COMMIT
    ELSE
     CALL do_display(concat("No entry <",drp_obj->db_object_name,
       "> exists in the DM_TABLES_DOC table."),0)
    ENDIF
   ENDIF
   IF ((drp_obj->icnt != 0)
    AND (((drp_obj->packaging_flag=1)) OR ((drp_obj->inhouse_flag=0))) )
    FOR (doxt = 1 TO value(drp_obj->icnt))
      CALL do_display(concat("Update DM_INDEXES_DOC with the dropped object <",drp_obj->iqual[doxt].
        ind_name,"> ..."),0)
      UPDATE  FROM dm_indexes_doc dic
       SET dic.updt_dt_tm = cnvtdatetime(curdate,curtime3), dic.updt_task = reqinfo->updt_task, dic
        .drop_ind = 1
       WHERE (dic.index_name=drp_obj->iqual[doxt].ind_name)
       WITH nocounter
      ;end update
      IF ( NOT (curqual))
       CALL do_display(concat("No entry <",drp_obj->iqual[doxt].ind_name,
         "> exists in the DM_INDEXES_DOC table - Initiate."),0)
       INSERT  FROM dm_indexes_doc dic
        SET dic.index_name = drp_obj->iqual[doxt].ind_name, dic.updt_applctx = 0, dic.updt_dt_tm =
         cnvtdatetime(curdate,curtime3),
         dic.updt_cnt = 1, dic.updt_id = 0, dic.updt_task = reqinfo->updt_task,
         dic.drop_ind = 1
        WITH nocounter
       ;end insert
      ENDIF
      COMMIT
    ENDFOR
   ENDIF
   IF ((drp_obj->icnt != 0))
    FOR (doxtz = 1 TO value(drp_obj->icnt))
     IF ( NOT (write_dm_info(i_domain,drp_obj->iqual[doxtz].ind_name,"INDEX")))
      CALL do_display(concat("Unable to write <",drp_obj->iqual[doxtz].ind_name,"> to DM_INFO table"),
       1)
     ENDIF
     COMMIT
    ENDFOR
   ENDIF
   CALL clean_cmb_children("","","")
   GO TO end_program
  OF "TRIGGER":
   IF ((drp_obj->db_found_ind=1))
    SET drop_str = concat("rdb drop ",drp_obj->db_object_type," ",drp_obj->db_object_name," go")
    CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
   ENDIF
   GO TO end_program
  OF "VIEW":
   IF ((drp_obj->db_found_ind=1))
    SET drop_str = concat("rdb drop ",drp_obj->db_object_type," ",drp_obj->db_object_name," go")
    CALL do_drop_object(drop_str,drp_obj->db_object_type,"DROP")
   ENDIF
   CALL do_display("Deteremine CCL Definition for View ...",0)
   IF (checkdic(drp_obj->db_object_name,"T",0)=2)
    SET drop_str = concat("drop TABLE ",drp_obj->db_object_name," go")
    CALL do_drop_object(drop_str,"CCL DEF","DROP")
   ENDIF
   GO TO end_program
  ELSE
   CALL do_display("NOT a Valid Object Type !!!",1)
   GO TO end_program
 ENDCASE
#end_program
 ROLLBACK
 IF (errcode=0)
  IF (build(drp_obj->db_object_rename) > " "
   AND (drp_obj->db_object_dropped=0))
   SET stat = write_dm_info(i_domain,drp_obj->db_object_name,drp_obj->db_object_type)
  ELSEIF (substring((textlen(build(drp_obj->db_object_name)) - 1),2,drp_obj->db_object_name) != "$O")
   SET stat = write_dm_info(i_domain,drp_obj->tmp_db_object_name,drp_obj->db_object_type)
  ENDIF
  IF (stat=true)
   COMMIT
  ENDIF
  CALL do_display("Executing DM_USER_LAST_UPDT...",0)
  EXECUTE dm_user_last_updt
 ENDIF
#exit_now
 ROLLBACK
END GO
