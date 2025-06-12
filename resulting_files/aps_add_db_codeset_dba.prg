CREATE PROGRAM aps_add_db_codeset:dba
 RECORD reply(
   1 qual[1]
     2 code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET specs_added = 0
 SET reply->status_data.status = "F"
 SET nbr_to_insert = cnvtint(size(request->qual,5))
 IF (nbr_to_insert > 1)
  SET stat = alter(reply->qual,nbr_to_insert)
 ENDIF
 FOR (x = 1 TO nbr_to_insert)
  SELECT INTO "nl:"
   seq_nbr = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    reply->qual[x].code_value = cnvtreal(seq_nbr)
   WITH format, counter
  ;end select
  IF (curqual=0)
   GO TO seq_failed
  ENDIF
 ENDFOR
 INSERT  FROM code_value c,
   (dummyt d  WITH seq = value(nbr_to_insert))
  SET c.code_value = reply->qual[d.seq].code_value, c.code_set = request->qual[d.seq].code_set, c
   .display = request->qual[d.seq].display,
   c.display_key = cnvtupper(cnvtalphanum(request->qual[d.seq].display)), c.description = request->
   qual[d.seq].description, c.cdf_meaning =
   IF (trim(request->qual[d.seq].cdf_meaning)="") null
   ELSE request->qual[d.seq].cdf_meaning
   ENDIF
   ,
   c.active_dt_tm = cnvtdatetime(curdate,curtime), c.active_ind = request->qual[d.seq].active_ind, c
   .active_type_cd =
   IF ((request->qual[d.seq].active_ind=1)) reqdata->active_status_cd
   ELSE reqdata->inactive_status_cd
   ENDIF
   ,
   c.data_status_cd = reqdata->data_status_cd, c.data_status_dt_tm = cnvtdatetime(curdate,curtime), c
   .data_status_prsnl_id = reqinfo->updt_id,
   c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo
   ->updt_task,
   c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0, c.collation_seq = request->qual[d.seq].
   collation_seq
  PLAN (d)
   JOIN (c)
  WITH nocounter
 ;end insert
 IF (curqual != nbr_to_insert)
  GO TO c_failed
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "NEXTVAL"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "SEQ"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "REFERENCE_SEQ"
 SET failed = "T"
 GO TO exit_script
#c_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 SET failed = "T"
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
