CREATE PROGRAM bed_ens_pharm_dup_ndc_flag:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 INSERT  FROM br_name_value bnv
  SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "PHARM_DUP_QUESTION", bnv
   .br_name = " ",
   bnv.br_value = cnvtstring(request->dup_ndc_flag), bnv.updt_cnt = 0, bnv.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo->
   updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = "Unable to update into br_name_value"
  GO TO exit_script
 ENDIF
 IF ((request->dup_ndc_flag=0))
  DECLARE save_desc = vc
  RECORD temp(
    1 legacy[*]
      2 ndc = vc
      2 count = f8
  )
  SET tcnt = 0
  SET alterlist_tcnt = 0
  SET stat = alterlist(temp->legacy,100)
  SELECT INTO "NL:"
   b.ndc, x = count(*)
   FROM br_pharm_product_work b
   PLAN (b)
   GROUP BY b.ndc
   HAVING count(*) > 1
   DETAIL
    tcnt = (tcnt+ 1), alterlist_tcnt = (alterlist_tcnt+ 1)
    IF (alterlist_tcnt > 100)
     stat = alterlist(temp->legacy,(tcnt+ 100)), alterlist_tcnt = 1
    ENDIF
    temp->legacy[tcnt].ndc = b.ndc, temp->legacy[tcnt].count = x
   WITH nocounter
  ;end select
  SET stat = alterlist(temp->legacy,tcnt)
  IF (tcnt > 0)
   FOR (t = 1 TO tcnt)
     SET save_desc = " "
     SELECT INTO "NL:"
      FROM br_pharm_product_work b
      WHERE (b.ndc=temp->legacy[t].ndc)
      DETAIL
       save_desc = b.description
      WITH nocounter, maxqual = 1
     ;end select
     UPDATE  FROM br_pharm_product_work b
      SET b.match_ind = 9, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime3
        ),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
       updt_applctx
      WHERE (b.ndc=temp->legacy[t].ndc)
       AND b.description != save_desc
      WITH nocounter, maxrow = 1
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = "Unable to update into br_pharm_product_work"
      GO TO exit_script
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_PHARM_DUP_NDC_FLAG","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
