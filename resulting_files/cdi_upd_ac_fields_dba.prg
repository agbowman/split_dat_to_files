CREATE PROGRAM cdi_upd_ac_fields:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD tempfields
 RECORD tempfields(
   1 fieldstoupdate[*]
     2 docclass_name = vc
     2 cdi_ac_field_id = f8
     2 field_name = vc
     2 alias_type_cd = f8
     2 alias_type_codeset = i4
     2 auto_search_ind = i2
     2 man_search_ind = i2
   1 fieldstoadd[*]
     2 docclass_name = vc
     2 cdi_ac_field_id = f8
     2 field_name = vc
     2 alias_type_cd = f8
     2 alias_type_codeset = i4
     2 auto_search_ind = i2
     2 man_search_ind = i2
 )
 FREE RECORD delfields
 RECORD delfields(
   1 field[*]
     2 cdi_ac_field_id = f8
 )
 DECLARE docclassfield_rows = i4 WITH noconstant(value(size(request->docclasses,5))), protect
 DECLARE field_rows = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE err_msg = vc WITH noconstant(" "), protect
 DECLARE rows_to_update_count = i4 WITH noconstant(0), public
 DECLARE count = i4 WITH noconstant(0), public
 DECLARE count2 = i4 WITH noconstant(0), public
 DECLARE updcnt = i4 WITH noconstant(1), public
 DECLARE addcnt = i4 WITH noconstant(1), public
 FOR (count = 1 TO docclassfield_rows)
  SET field_rows = value(size(request->docclasses[count].fields,5))
  FOR (count2 = 1 TO field_rows)
    IF ((request->docclasses[count].fields[count2].cdi_ac_field_id > 0))
     SET stat = alterlist(tempfields->fieldstoupdate,updcnt)
     SET tempfields->fieldstoupdate[updcnt].docclass_name = request->docclasses[count].doc_class_name
     SET tempfields->fieldstoupdate[updcnt].cdi_ac_field_id = request->docclasses[count].fields[
     count2].cdi_ac_field_id
     SET tempfields->fieldstoupdate[updcnt].field_name = request->docclasses[count].fields[count2].
     field_name
     SET tempfields->fieldstoupdate[updcnt].alias_type_cd = request->docclasses[count].fields[count2]
     .alias_type_cd
     SET tempfields->fieldstoupdate[updcnt].alias_type_codeset = request->docclasses[count].fields[
     count2].alias_type_codeset
     SET tempfields->fieldstoupdate[updcnt].auto_search_ind = request->docclasses[count].fields[
     count2].auto_search_ind
     SET tempfields->fieldstoupdate[updcnt].man_search_ind = request->docclasses[count].fields[count2
     ].man_search_ind
     SET updcnt = (updcnt+ 1)
    ELSE
     SET stat = alterlist(tempfields->fieldstoadd,addcnt)
     SET tempfields->fieldstoadd[addcnt].docclass_name = request->docclasses[count].doc_class_name
     SET tempfields->fieldstoadd[addcnt].cdi_ac_field_id = request->docclasses[count].fields[count2].
     cdi_ac_field_id
     SET tempfields->fieldstoadd[addcnt].field_name = request->docclasses[count].fields[count2].
     field_name
     SET tempfields->fieldstoadd[addcnt].alias_type_cd = request->docclasses[count].fields[count2].
     alias_type_cd
     SET tempfields->fieldstoadd[addcnt].alias_type_codeset = request->docclasses[count].fields[
     count2].alias_type_codeset
     SET tempfields->fieldstoadd[addcnt].auto_search_ind = request->docclasses[count].fields[count2].
     auto_search_ind
     SET tempfields->fieldstoadd[addcnt].man_search_ind = request->docclasses[count].fields[count2].
     man_search_ind
     SET addcnt = (addcnt+ 1)
    ENDIF
  ENDFOR
 ENDFOR
 SET updcnt = (updcnt - 1)
 SET addcnt = (addcnt - 1)
 SET reply->status_data.status = "F"
 IF (docclassfield_rows > 0)
  SELECT INTO "NL:"
   acf.updt_cnt
   FROM cdi_ac_field acf
   WHERE expand(num,1,updcnt,acf.cdi_ac_field_id,tempfields->fieldstoupdate[num].cdi_ac_field_id)
   DETAIL
    rows_to_update_count = (rows_to_update_count+ 1)
   WITH nocounter, forupdatewait(acf)
  ;end select
  IF (rows_to_update_count > 0)
   UPDATE  FROM cdi_ac_field acf,
     (dummyt d  WITH seq = updcnt)
    SET acf.doc_class_name = tempfields->fieldstoupdate[d.seq].docclass_name, acf.field_name =
     tempfields->fieldstoupdate[d.seq].field_name, acf.alias_type_cd = tempfields->fieldstoupdate[d
     .seq].alias_type_cd,
     acf.alias_type_codeset = tempfields->fieldstoupdate[d.seq].alias_type_codeset, acf
     .auto_search_ind = tempfields->fieldstoupdate[d.seq].auto_search_ind, acf.manual_search_ind =
     tempfields->fieldstoupdate[d.seq].man_search_ind,
     acf.updt_cnt = (acf.updt_cnt+ 1), acf.updt_dt_tm = cnvtdatetime(curdate,curtime3), acf.updt_task
      = reqinfo->updt_task,
     acf.updt_id = reqinfo->updt_id, acf.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (acf
     WHERE (acf.cdi_ac_field_id=tempfields->fieldstoupdate[d.seq].cdi_ac_field_id))
    WITH nocounter
   ;end update
  ENDIF
  IF (addcnt > 0)
   FOR (num = 1 TO addcnt)
     INSERT  FROM cdi_ac_field acf
      SET acf.cdi_ac_field_id = seq(cdi_seq,nextval), acf.doc_class_name = tempfields->fieldstoadd[
       num].docclass_name, acf.field_name = tempfields->fieldstoadd[num].field_name,
       acf.alias_type_cd = tempfields->fieldstoadd[num].alias_type_cd, acf.alias_type_codeset =
       tempfields->fieldstoadd[num].alias_type_codeset, acf.auto_search_ind = tempfields->
       fieldstoadd[num].auto_search_ind,
       acf.manual_search_ind = tempfields->fieldstoadd[num].man_search_ind, acf.updt_cnt = 0, acf
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       acf.updt_task = reqinfo->updt_task, acf.updt_id = reqinfo->updt_id, acf.updt_applctx = reqinfo
       ->updt_applctx
     ;end insert
   ENDFOR
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
