CREATE PROGRAM bb_ref_add_code_set:dba
 RECORD reply(
   1 reccodes[*]
     2 dcode = f8
     2 sdisplay = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reccodes(
   1 codes[*]
     2 dvalues = f8
 )
 DECLARE nrequestsize = i4
 DECLARE nidx = i2
 SET nrequestsize = size(request->codes,5)
 SET stat = alterlist(reccodes->codes,nrequestsize)
 SET stat = alterlist(reply->reccodes,nrequestsize)
 SET nidx = 0
 SET reqinfo->commit_ind = 0
 SET serrormsg = fillstring(255," ")
 SET error_check = error(serrormsg,1)
 FOR (nidx = 1 TO nrequestsize)
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     reccodes->codes[nidx].dvalues = cnvtreal(y)
    WITH format, counter
   ;end select
 ENDFOR
 SET error_check = error(serrormsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
  GO TO exit_script
 ENDIF
 INSERT  FROM code_value c,
   (dummyt d  WITH seq = value(nrequestsize))
  SET c.code_value = reccodes->codes[d.seq].dvalues, c.code_set = request->ncodeset, c.cdf_meaning =
   request->codes[d.seq].scdfmeaning,
   c.display = request->codes[d.seq].sdisplay, c.display_key = cnvtupper(request->codes[d.seq].
    sdisplay), c.description = request->codes[d.seq].sdescription,
   c.definition = "", c.active_ind = 1, c.active_type_cd = reqdata->active_status_cd,
   c.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), c.end_effective_dt_tm = cnvtdatetime(
    "31 DEC 2100 00:00"), c.active_dt_tm = cnvtdatetime(curdate,curtime3),
   c.inactive_dt_tm = null, c.data_status_cd = reqdata->data_status_cd, c.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.updt_cnt = 0, c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task,
   c.updt_applctx = reqinfo->updt_applctx, reply->reccodes[d.seq].dcode = reccodes->codes[d.seq].
   dvalues, reply->reccodes[d.seq].sdisplay = request->codes[d.seq].sdisplay
  PLAN (d)
   JOIN (c)
  WITH nocounter
 ;end insert
 SET error_check = error(serrormsg,0)
 IF (error_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "CURQUAL = 0 on code_value table. BB_REF_ADD_CODE_SET"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
#exit_script
END GO
