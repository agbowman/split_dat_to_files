CREATE PROGRAM dcp_purge_forms:dba
 IF (validate(reply,"0")="0")
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
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 FREE SET temp
 RECORD temp(
   1 forms[*]
     2 dcp_form_instance_id = f8
     2 dcp_forms_ref_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 activity = i2
 )
 SET modify = predeclare
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE delete_ind = i2 WITH protect, noconstant(false)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  WHERE dfr.active_ind=0
   AND dfr.dcp_forms_ref_id > 0
  ORDER BY dfr.dcp_form_instance_id
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->forms,cnt), temp->forms[cnt].dcp_form_instance_id = dfr
   .dcp_form_instance_id,
   temp->forms[cnt].dcp_forms_ref_id = dfr.dcp_forms_ref_id, temp->forms[cnt].beg_effective_dt_tm =
   dfr.beg_effective_dt_tm, temp->forms[cnt].end_effective_dt_tm = dfr.end_effective_dt_tm,
   temp->forms[cnt].activity = 0
  WITH nocounter
 ;end select
 CALL echo(build("Count:",cnt))
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   dcp_forms_activity dfa
  PLAN (d)
   JOIN (dfa
   WHERE (dfa.dcp_forms_ref_id=temp->forms[d.seq].dcp_forms_ref_id)
    AND ((dfa.version_dt_tm > cnvtdatetime(temp->forms[d.seq].beg_effective_dt_tm)
    AND dfa.version_dt_tm <= cnvtdatetime(temp->forms[d.seq].end_effective_dt_tm)) OR (dfa
   .version_dt_tm=null
    AND dfa.beg_activity_dt_tm > cnvtdatetime(temp->forms[d.seq].beg_effective_dt_tm)
    AND dfa.beg_activity_dt_tm <= cnvtdatetime(temp->forms[d.seq].end_effective_dt_tm))) )
  DETAIL
   temp->forms[d.seq].activity = 1
  WITH nocounter
 ;end select
 FOR (i = 1 TO cnt)
   IF ((temp->forms[i].activity=0))
    SET delete_ind = true
    DELETE  FROM dcp_forms_def
     WHERE (dcp_form_instance_id=temp->forms[i].dcp_form_instance_id)
     WITH nocounter
    ;end delete
    DELETE  FROM dcp_forms_ref
     WHERE (dcp_form_instance_id=temp->forms[i].dcp_form_instance_id)
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
#exit_script
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL reportfailure("ERROR","F","DCP_PURGE_FORMS",serrormsg)
  ROLLBACK
 ELSEIF (delete_ind=false)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET modify = nopredeclare
END GO
