CREATE PROGRAM dcp_upd_dcp_activeind:dba
 RECORD reply(
   1 dcp_forms_ref_id = f8
   1 dcp_section_ref_id = f8
   1 form_ind = i2
   1 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 dcp_section_ref_id = f8
 )
 SET reply->status_data.status = "F"
 SET dcp_forms_ref_id = 0.0
 SET form_ind = 1
 SET dcp_section_ref_id = 0.0
 SET dcp_forms_ref_id = request->dcp_forms_ref_id
 SET active_ind = request->active_ind
 SET dcp_section_ref_id = request->dcp_section_ref_id
 SET count = 0
 IF ((request->beg_effective_dt_tm=null))
  SET request->beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 IF ((request->end_effective_dt_tm=null))
  SET request->end_effective_dt_tm = cnvtdatetime("31-Dec-2100")
 ENDIF
 CALL echo(request->dcp_forms_ref_id)
 IF ((request->dcp_forms_ref_id != 0))
  UPDATE  FROM dcp_forms_ref dfr
   SET dfr.active_ind = request->active_ind, dfr.beg_effective_dt_tm = cnvtdatetime(request->
     beg_effective_dt_tm), dfr.end_effective_dt_tm = cnvtdatetime(request->end_effective_dt_tm),
    dfr.updt_id = reqinfo->updt_id, dfr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (dfr.dcp_forms_ref_id=request->dcp_forms_ref_id)
   WITH nocounter
  ;end update
  IF ((request->active_ind=1))
   SELECT INTO "nl:"
    dfd.dcp_section_ref_id
    FROM dcp_forms_def dfd
    PLAN (dfd
     WHERE (dfd.dcp_forms_ref_id=request->dcp_forms_ref_id))
    HEAD REPORT
     count = 0
    DETAIL
     count = (count+ 1)
     IF (count > size(temp->qual,5))
      stat = alterlist(temp->qual,(count+ 5))
     ENDIF
     temp->qual[count].dcp_section_ref_id = dfd.dcp_section_ref_id,
     CALL echo(build("dcp_section_ref_id1:",temp->qual[count].dcp_section_ref_id))
    FOOT REPORT
     stat = alterlist(temp->qual,count)
    WITH nocounter
   ;end select
   FOR (x = 1 TO count)
     CALL echo(build("dcp_section_ref_id:",temp->qual[x].dcp_section_ref_id))
     CALL echo(build("x:",x))
     UPDATE  FROM dcp_section_ref dsr
      SET dsr.active_ind = request->active_ind, dsr.beg_effective_dt_tm = cnvtdatetime(request->
        beg_effective_dt_tm), dsr.end_effective_dt_tm = cnvtdatetime(request->end_effective_dt_tm),
       dsr.updt_id = reqinfo->updt_id, dsr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (dsr.dcp_section_ref_id=temp->qual[x].dcp_section_ref_id)
      WITH nocounter
     ;end update
   ENDFOR
  ENDIF
 ENDIF
 IF ((request->dcp_section_ref_id != 0))
  IF ((request->active_ind=0))
   SELECT INTO "nl:"
    FROM dcp_forms_def dfd,
     dcp_forms_ref dfr
    PLAN (dfd
     WHERE (dfd.dcp_section_ref_id=request->dcp_section_ref_id))
     JOIN (dfr
     WHERE dfr.dcp_forms_ref_id=dfd.dcp_forms_ref_id
      AND dfr.active_ind=1)
    DETAIL
     form_ind = 0
    WITH nocounter
   ;end select
  ENDIF
  IF (form_ind=1)
   UPDATE  FROM dcp_section_ref dsr
    SET dsr.active_ind = request->active_ind, dsr.beg_effective_dt_tm = cnvtdatetime(request->
      beg_effective_dt_tm), dsr.end_effective_dt_tm = cnvtdatetime(request->end_effective_dt_tm),
     dsr.updt_id = reqinfo->updt_id, dsr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (dsr.dcp_section_ref_id=request->dcp_section_ref_id)
    WITH nocounter
   ;end update
  ENDIF
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->dcp_forms_ref_id = dcp_forms_ref_id
  SET reply->dcp_section_ref_id = dcp_section_ref_id
  SET reply->active_ind = active_ind
  SET reply->form_ind = form_ind
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echo(build("status:",reply->status_data.status))
END GO
