CREATE PROGRAM dm2_verify_purge_tables:dba
 IF ((validate(request->template_nbr,- (1))=- (1)))
  RECORD request(
    1 template_nbr = i4
  )
 ENDIF
 IF (validate(reply->status_data.status,"NONE")="NONE")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD dvpt_tables
 RECORD dvpt_tables(
   1 qual_cnt = i4
   1 qual[*]
     2 table_name = vc
     2 table_exists_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE dvpt_errmsg = vc WITH protect, noconstant("")
 DECLARE dvpt_table_list = vc WITH protect, noconstant("")
 DECLARE dvpt_table_name = vc WITH protect, noconstant("")
 DECLARE dvpt_missing_tbl_ind = i2 WITH protect, noconstant(0)
 DECLARE dvpt_loop = i4 WITH protect, noconstant(0)
 DECLARE dvpt_lval_idx = i4 WITH protect, noconstant(0)
 DECLARE dvpt_i18nhandle = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(dvpt_i18nhandle,curprog,"",curcclrev)
 IF ((request->template_nbr=0))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "verifying template number"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = curprog
  SET reply->status_data.subeventstatus.targetobjectvalue = uar_i18ngetmessage(dvpt_i18nhandle,
   "BADNUMBER","An invalid template number was given")
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  dpt.parent_table
  FROM dm_purge_table dpt
  WHERE (dpt.template_nbr=request->template_nbr)
   AND (dpt.schema_dt_tm=
  (SELECT
   max(dpt2.schema_dt_tm)
   FROM dm_purge_table dpt2
   WHERE dpt2.template_nbr=dpt.template_nbr))
  DETAIL
   dvpt_table_name = cnvtupper(dpt.parent_table)
   IF (locateval(dvpt_lval_idx,1,dvpt_tables->qual_cnt,dvpt_table_name,dvpt_tables->qual[
    dvpt_lval_idx].table_name)=0)
    dvpt_tables->qual_cnt = (dvpt_tables->qual_cnt+ 1), stat = alterlist(dvpt_tables->qual,
     dvpt_tables->qual_cnt), dvpt_tables->qual[dvpt_tables->qual_cnt].table_name = dvpt_table_name
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  dpt.child_table
  FROM dm_purge_table dpt
  WHERE (dpt.template_nbr=request->template_nbr)
   AND (dpt.schema_dt_tm=
  (SELECT
   max(dpt2.schema_dt_tm)
   FROM dm_purge_table dpt2
   WHERE dpt2.template_nbr=dpt.template_nbr))
   AND dpt.child_table IS NOT null
   AND dpt.child_table > " "
  DETAIL
   dvpt_table_name = cnvtupper(dpt.child_table)
   IF (locateval(dvpt_lval_idx,1,dvpt_tables->qual_cnt,dvpt_table_name,dvpt_tables->qual[
    dvpt_lval_idx].table_name)=0)
    dvpt_tables->qual_cnt = (dvpt_tables->qual_cnt+ 1), stat = alterlist(dvpt_tables->qual,
     dvpt_tables->qual_cnt), dvpt_tables->qual[dvpt_tables->qual_cnt].table_name = dvpt_table_name
   ENDIF
  WITH nocounter
 ;end select
 FOR (dvpt_loop = 1 TO dvpt_tables->qual_cnt)
   SELECT INTO "nl:"
    FROM dtableattr dt
    PLAN (dt
     WHERE (dt.table_name=dvpt_tables->qual[dvpt_loop].table_name))
    DETAIL
     dvpt_tables->qual[dvpt_loop].table_exists_ind = 1
    WITH nocounter
   ;end select
 ENDFOR
 IF (error(dvpt_errmsg,0) > 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "building list of tables"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(dvpt_i18nhandle,
   "LISTBUILD","Failed while building a list of tables: %1","s",nullterm(dvpt_errmsg))
  GO TO exit_script
 ENDIF
 SET dvpt_errmsg = ""
 FOR (dvpt_loop = 1 TO dvpt_tables->qual_cnt)
   IF ((dvpt_tables->qual[dvpt_loop].table_exists_ind=0))
    IF (dvpt_missing_tbl_ind=0)
     SET dvpt_table_list = dvpt_tables->qual[dvpt_loop].table_name
    ELSE
     SET dvpt_table_list = concat(dvpt_table_list,", ",dvpt_tables->qual[dvpt_loop].table_name)
    ENDIF
    SET dvpt_missing_tbl_ind = 1
   ENDIF
 ENDFOR
 IF (dvpt_missing_tbl_ind=1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "verifying tables"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_i18nbuildmessage(dvpt_i18nhandle,
   "TABLEEXIST","One or more tables could not be found: %1","s",nullterm(dvpt_table_list))
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 FREE RECORD dvpt_tables
END GO
