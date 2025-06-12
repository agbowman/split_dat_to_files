CREATE PROGRAM cdi_upd_forms:dba
 IF (validate(reply->status_data.status)=0)
  RECORD reply(
    1 forms[*]
      2 cdi_form_id = f8
      2 source_form_ident = vc
      2 fields[*]
        3 cdi_form_field_id = f8
        3 page_nbr = i4
        3 x_coord = i4
        3 y_coord = i4
        3 field_name = vc
      2 facilities[*]
        3 facility_cd = f8
        3 cdi_form_facility_reltn_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE req_size = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE reply_size = i4 WITH noconstant(0), protect
 DECLARE count = i4 WITH noconstant(1)
 DECLARE j = i4 WITH noconstant(0), protect
 DECLARE k = i4 WITH noconstant(0), protect
 DECLARE facility_add_cnt = i4 WITH noconstant(0), protect
 DECLARE facility_req_cnt = i4 WITH noconstant(0), protect
 DECLARE facility_del_cnt = i4 WITH noconstant(0), protect
 DECLARE reply_form_cnt = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_upd_forms"
 SET req_size = value(size(request->forms,5))
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 IF (req_size > 0)
  IF ((request->update_linked_variables_ind=0))
   SET ecode = 0
   SET emsg = fillstring(200," ")
   SET ecode = error(emsg,1)
   SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Failed to update form(s) - please update calling code."
   SET reply->status_data.subeventstatus[1].operationname = "INACTIVATE"
   GO TO exit_script
  ENDIF
  UPDATE  FROM cdi_form f
   SET f.active_ind = 0, f.updt_cnt = (f.updt_cnt+ 1), f.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    f.updt_task = reqinfo->updt_task, f.updt_id = reqinfo->updt_id, f.updt_applctx = reqinfo->
    updt_applctx
   WHERE expand(count,1,req_size,f.cdi_form_id,request->forms[count].cdi_form_id)
    AND f.active_ind=1
  ;end update
  IF (curqual < req_size)
   SET ecode = 0
   SET emsg = fillstring(200," ")
   SET ecode = error(emsg,1)
   SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to inactivate form(s)."
   SET reply->status_data.subeventstatus[1].operationname = "INACTIVATE"
   GO TO exit_script
  ENDIF
  RECORD update_forms(
    1 forms[*]
      2 old_cdi_form_id = f8
      2 new_cdi_form_id = f8
      2 source_form_ident = vc
  )
  RECORD update_facilities(
    1 add_facilities[*]
      2 facility_cd = f8
    1 delete_facilities[*]
      2 cdi_form_facility_reltn_id = f8
  )
  SET stat = alterlist(update_forms->forms,req_size)
  SET stat = alterlist(reply->forms,req_size)
  FOR (i = 1 TO req_size)
   SET update_forms->forms[i].old_cdi_form_id = request->forms[i].cdi_form_id
   SET update_forms->forms[i].source_form_ident = request->forms[i].source_form_ident
  ENDFOR
  FOR (i = 1 TO req_size)
    SET facility_add_cnt = 0
    SET facility_req_cnt = size(request->forms[i].facilities,5)
    SET stat = alterlist(update_facilities->add_facilities,facility_req_cnt)
    FOR (j = 1 TO facility_req_cnt)
      IF ((request->forms[i].facilities[j].delete_ind=0))
       SET facility_add_cnt = (facility_add_cnt+ 1)
       SET update_facilities->add_facilities[facility_add_cnt].facility_cd = request->forms[i].
       facilities[j].facility_cd
      ELSEIF ((request->forms[i].facilities[j].cdi_form_facility_reltn_id > 0))
       SET facility_del_cnt = (facility_del_cnt+ 1)
       IF (mod(facility_del_cnt,10)=1)
        SET stat = alterlist(update_facilities->delete_facilities,(facility_del_cnt+ 9))
       ENDIF
       SET update_facilities->delete_facilities[facility_del_cnt].cdi_form_facility_reltn_id =
       request->forms[i].facilities[j].cdi_form_facility_reltn_id
      ENDIF
    ENDFOR
    SET stat = alterlist(update_facilities->add_facilities,facility_add_cnt)
    SET stat = alterlist(request->forms[i].facilities,0)
    SET stat = alterlist(request->forms[i].facilities,facility_add_cnt)
    FOR (k = 1 TO facility_add_cnt)
      SET request->forms[i].facilities[k].facility_cd = update_facilities->add_facilities[k].
      facility_cd
    ENDFOR
  ENDFOR
  SET stat = alterlist(update_facilities->delete_facilities,facility_del_cnt)
  EXECUTE cdi_add_forms  WITH replace("REQUEST",request), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   GO TO exit_script
  ENDIF
  SET reply_size = value(size(reply->forms,5))
  DECLARE index = i4 WITH noconstant(2), public
  DECLARE start = i4 WITH noconstant(1), public
  FOR (i = 1 TO reply_size)
   SET pos = locateval(index,start,size(update_forms->forms,5),reply->forms[i].source_form_ident,
    update_forms->forms[index].source_form_ident)
   SET update_forms->forms[pos].new_cdi_form_id = request->forms[i].cdi_form_id
  ENDFOR
  UPDATE  FROM cdi_form_rule r,
    (dummyt d  WITH seq = req_size)
   SET r.cdi_form_id = update_forms->forms[d.seq].new_cdi_form_id
   PLAN (d)
    JOIN (r
    WHERE (r.cdi_form_id=update_forms->forms[d.seq].old_cdi_form_id))
  ;end update
  UPDATE  FROM cdi_form_facility_reltn ffr,
    (dummyt d  WITH seq = req_size)
   SET ffr.cdi_form_id = update_forms->forms[d.seq].new_cdi_form_id, ffr.updt_cnt = (ffr.updt_cnt+ 1),
    ffr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ffr.updt_task = reqinfo->updt_task, ffr.updt_id = reqinfo->updt_id, ffr.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (ffr
    WHERE (ffr.cdi_form_id=update_forms->forms[d.seq].old_cdi_form_id))
  ;end update
  IF (facility_del_cnt > 0)
   DELETE  FROM cdi_form_facility_reltn ffr,
     (dummyt d  WITH seq = value(facility_del_cnt))
    SET ffr.seq = 1
    PLAN (d)
     JOIN (ffr
     WHERE (ffr.cdi_form_facility_reltn_id=update_facilities->delete_facilities[d.seq].
     cdi_form_facility_reltn_id))
    WITH nocounter
   ;end delete
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
