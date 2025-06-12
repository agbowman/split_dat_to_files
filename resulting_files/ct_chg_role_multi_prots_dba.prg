CREATE PROGRAM ct_chg_role_multi_prots:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD replaceroles(
   1 prev_role_list[*]
     2 prot_role_id = f8
 )
 RECORD inactivaterequest(
   1 person_list[*]
     2 person_id = f8
     2 protocols[*]
       3 prot_master_id = f8
       3 prot_role_cd = f8
 )
 RECORD inactivatereply(
   1 person_access_list[*]
     2 person_id = f8
     2 entity_access_list[*]
       3 entity_access_id = f8
       3 prot_amendment_id = f8
       3 functionality_cd = f8
       3 access_mask = c5
   1 role_list[*]
     2 prot_role_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE inactivate_fail = i4 WITH private, constant(1)
 DECLARE insert_role_fail = i4 WITH private, constant(2)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE failure_flag = i2 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE duplicate = i2 WITH protect, noconstant(0)
 DECLARE role_cnt = i4 WITH protect, noconstant(0)
 SET stat = alterlist(inactivaterequest->person_list,1)
 SET inactivaterequest->person_list[1].person_id = request->del_person_id
 SET stat = alterlist(inactivaterequest->person_list[i].protocols,size(request->protocols,5))
 FOR (i = 1 TO size(request->protocols,5))
  SET inactivaterequest->person_list[1].protocols[i].prot_master_id = request->protocols[i].
  prot_master_id
  SET inactivaterequest->person_list[1].protocols[i].prot_role_cd = request->prot_role_cd
 ENDFOR
 EXECUTE ct_del_role_multi_prots  WITH replace("REQUEST","INACTIVATEREQUEST"), replace("REPLY",
  "INACTIVATEREPLY")
 IF ((inactivatereply->status_data.status="F"))
  SET failure_flag = inactivate_fail
  GO TO exit_script
 ENDIF
 IF (size(inactivatereply->role_list,5) > 0)
  SELECT INTO "nl:"
   pr.*
   FROM prot_role pr,
    prot_role pr1,
    (dummyt d1  WITH seq = size(inactivatereply->role_list,5)),
    dummyt d2,
    dummyt d3
   PLAN (d1)
    JOIN (pr
    WHERE (pr.prot_role_id=inactivatereply->role_list[d1.seq].prot_role_id))
    JOIN (d2)
    JOIN (pr1
    WHERE pr1.prot_amendment_id=pr.prot_amendment_id
     AND pr1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND (pr1.person_id=request->new_person_id)
     AND pr1.organization_id=pr.organization_id
     AND pr1.prot_role_cd=pr.prot_role_cd
     AND pr1.prot_role_type_cd=pr.prot_role_type_cd)
    JOIN (d3)
   ORDER BY pr.prot_role_id, pr1.prot_role_id
   HEAD pr.prot_role_id
    duplicate = 0
   DETAIL
    IF (pr1.prot_role_id > 0.0)
     duplicate = 1
    ENDIF
   FOOT  pr.prot_role_id
    IF (duplicate=0)
     role_cnt = (role_cnt+ 1)
     IF (mod(role_cnt,10)=1)
      stat = alterlist(replaceroles->prev_role_list,(role_cnt+ 9))
     ENDIF
     replaceroles->prev_role_list[role_cnt].prot_role_id = pr.prot_role_id
    ENDIF
   FOOT REPORT
    stat = alterlist(replaceroles->prev_role_list,role_cnt)
   WITH nocounter, dontcare = pr1
  ;end select
  IF (role_cnt > 0)
   FOR (i = 1 TO role_cnt)
    INSERT  FROM prot_role pr
     (pr.beg_effective_dt_tm, pr.end_effective_dt_tm, pr.organization_id,
     pr.person_id, pr.position_cd, pr.primary_contact_ind,
     pr.prot_amendment_id, pr.prot_role_cd, pr.prot_role_id,
     pr.prot_role_type_cd, pr.updt_applctx, pr.updt_cnt,
     pr.updt_dt_tm, pr.updt_id, pr.updt_task)(SELECT
      cnvtdatetime(curdate,curtime3), cnvtdatetime("31-DEC-2100 00:00:00"), pr.organization_id,
      request->new_person_id, pr.position_cd, pr.primary_contact_ind,
      pr.prot_amendment_id, pr.prot_role_cd, cnvtint(seq(protocol_def_seq,nextval)),
      pr.prot_role_type_cd, reqinfo->updt_applctx, 0,
      cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task
      FROM prot_role pr
      WHERE (pr.prot_role_id=replaceroles->prev_role_list[i].prot_role_id))
    ;end insert
    IF (curqual=0)
     SET failure_flag = insert_role_fail
     GO TO exit_script
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
#exit_script
 IF (failure_flag > 0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  IF (failure_flag=inactivate_fail)
   SET reply->status_data.subeventstatus[1].operationname = "INACTIVATE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Failure in executing ct_del_role_multi_prots."
  ELSEIF (failure_flag=insert_role_fail)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Failure to insert replacement roles."
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown failure."
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ENDIF
 SET last_mod = "000"
 SET mod_date = "August 10, 2009"
END GO
