CREATE PROGRAM br_get_wizard_security:dba
 FREE SET reply
 RECORD reply(
   01 br_client_exists_ind = i2
   01 user_level_security_ind = i2
   01 sollist[*]
     02 solution_mean = vc
     02 all_wizard_ind = i2
     02 scslist[*]
       03 step_mean = vc
       03 step_mean_ind = i2
     02 solution_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->user_level_security_ind = 0
 SET error_flag = " "
 DECLARE error_msg = vc
 IF ((request->person_id > 0))
  SET error_flag = "N"
 ELSE
  SET error_flag = "F"
  SET error_msg = "Invalid request data, "
  GO TO exit_script
 ENDIF
 SET br_client_id = 0
 SELECT INTO "nl:"
  FROM br_client bc
  DETAIL
   br_client_id = bc.br_client_id
  WITH nocounter
 ;end select
 IF (br_client_id=0)
  SET error_msg = "BR Client ID not found, "
  SET reply->br_client_exists_ind = 0
  GO TO exit_script
 ELSE
  SET reply->br_client_exists_ind = 1
 ENDIF
 IF (validate(request->millennium_tools_ind))
  IF ((request->millennium_tools_ind=1))
   SELECT INTO "nl:"
    FROM br_name_value bnv
    PLAN (bnv
     WHERE bnv.br_nv_key1="MTOOLSSECURITY"
      AND bnv.br_name="USERLEVELSECIND")
    DETAIL
     IF (bnv.br_value="1")
      reply->user_level_security_ind = 1
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM br_name_value bnv
    PLAN (bnv
     WHERE bnv.br_nv_key1="SYSTEMPARAM"
      AND bnv.br_name="USERLEVELSECIND")
    DETAIL
     IF (bnv.br_value="1")
      reply->user_level_security_ind = 1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET scnt = 0
 SET scscnt = 0
 SELECT INTO "nl:"
  FROM br_client_item_reltn b,
   br_client_sol_step bcss,
   br_client_item_reltn bcir,
   br_step bs
  PLAN (b
   WHERE b.br_client_id=br_client_id
    AND b.item_type="SOLUTION")
   JOIN (bcss
   WHERE bcss.br_client_id=b.br_client_id
    AND bcss.solution_mean=b.item_mean)
   JOIN (bcir
   WHERE bcir.br_client_id=bcss.br_client_id
    AND bcir.item_type="STEP"
    AND bcir.item_mean=bcss.step_mean)
   JOIN (bs
   WHERE bs.step_mean=bcir.item_mean)
  ORDER BY b.solution_seq, bcss.sequence
  HEAD REPORT
   scnt = 0
  HEAD b.br_client_item_reltn_id
   scnt = (scnt+ 1), stat = alterlist(reply->sollist,scnt), reply->sollist[scnt].solution_mean = b
   .item_mean,
   reply->sollist[scnt].all_wizard_ind = 0, reply->sollist[scnt].solution_type_flag = b
   .solution_type_flag, scscnt = 0
  DETAIL
   scscnt = (scscnt+ 1), stat = alterlist(reply->sollist[scnt].scslist,scscnt), reply->sollist[scnt].
   scslist[scscnt].step_mean = bcss.step_mean,
   reply->sollist[scnt].scslist[scscnt].step_mean_ind = 0
  WITH nocounter, skipbedrock = 1
 ;end select
 IF (scnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = scnt),
   br_name_value bnv
  PLAN (d)
   JOIN (bnv
   WHERE bnv.br_nv_key1="WIZARDSECURITY"
    AND bnv.br_name=cnvtstring(request->person_id)
    AND (bnv.br_value=reply->sollist[d.seq].solution_mean))
  DETAIL
   reply->sollist[d.seq].all_wizard_ind = 1
  WITH nocounter
 ;end select
 SET epcspathcount = 0
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="PATHSECURITY"
    AND bnv.br_value IN ("EPCSNOMINATION", "EPCSAPPROVAL", "EPCSREVOCATION")
    AND bnv.br_name=cnvtstring(request->person_id))
  DETAIL
   epcspathcount = 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO scnt)
   SET scscnt = size(reply->sollist[x].scslist,5)
   IF ((reply->sollist[x].all_wizard_ind=1))
    FOR (y = 1 TO scscnt)
      SET reply->sollist[x].scslist[y].step_mean_ind = 1
    ENDFOR
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = scscnt),
      br_name_value bnv
     PLAN (d)
      JOIN (bnv
      WHERE bnv.br_nv_key1="WIZARDSECURITY"
       AND bnv.br_name=cnvtstring(request->person_id)
       AND (bnv.br_value=reply->sollist[x].scslist[d.seq].step_mean))
     DETAIL
      reply->sollist[x].scslist[d.seq].step_mean_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   FOR (y = 1 TO scscnt)
     IF ((reply->sollist[x].scslist[y].step_mean="EPCS"))
      SET reply->sollist[x].scslist[y].step_mean_ind = epcspathcount
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
