CREATE PROGRAM ct_get_type_committee_reltn:dba
 RECORD reply(
   1 committees[*]
     2 committee_id = f8
     2 amd_validate_ind = i2
     2 rev_validate_ind = i2
     2 edit_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE com_cnt = i2 WITH protect, noconstant(0)
 DECLARE bfound = i2 WITH protect, noconstant(0)
 DECLARE cur_committee_cnt = i2 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(1)
 DECLARE batch_size = i2 WITH protect, noconstant(20)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE new_committee_cnt = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET cur_committee_cnt = size(request->committees,5)
 SET loop_cnt = ceil((cnvtreal(cur_committee_cnt)/ batch_size))
 SET new_committee_cnt = (batch_size * loop_cnt)
 SET stat = alterlist(request->committees,new_committee_cnt)
 IF (cur_committee_cnt=0)
  SELECT INTO "nl:"
   ctcr.committee_id
   FROM ct_type_committee_reltn ctcr,
    committee c,
    organization o
   PLAN (ctcr
    WHERE (ctcr.participation_type_cd=request->participation_type_cd)
     AND ctcr.active_ind=1)
    JOIN (c
    WHERE c.committee_id=ctcr.committee_id)
    JOIN (o
    WHERE o.organization_id=c.sponsoring_org_id
     AND (o.logical_domain_id=domain_reply->logical_domain_id))
   HEAD REPORT
    com_cnt = 0
   DETAIL
    com_cnt += 1
    IF (com_cnt > size(reply->committees,5))
     stat = alterlist(reply->committees,(com_cnt+ 5))
    ENDIF
    reply->committees[com_cnt].committee_id = ctcr.committee_id, reply->committees[com_cnt].
    amd_validate_ind = ctcr.amd_validate_ind, reply->committees[com_cnt].rev_validate_ind = ctcr
    .rev_validate_ind,
    reply->committees[com_cnt].edit_ind = ctcr.edit_ind
   FOOT REPORT
    stat = alterlist(reply->committees,com_cnt)
   WITH nocounter
  ;end select
  IF (curqual=0
   AND com_cnt > 1)
   CALL report_failure("SELECT","F","CT_GET_TYPE_COMMITTEE_RELTN",
    "Error finding committee/type relationships.")
   GO TO exit_script
  ELSEIF (com_cnt=0)
   CALL report_failure("SELECT","Z","CT_GET_TYPE_COMMITTEE_RELTN",
    "No committee/type relationships found.")
   GO TO exit_script
  ENDIF
 ELSE
  FOR (i = (cur_committee_cnt+ 1) TO new_committee_cnt)
    SET request->committees[i].committee_id = request->committees[cur_committee_cnt].committee_id
  ENDFOR
  SELECT INTO "nl:"
   FROM ct_type_committee_reltn ctcr,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (ctcr
    WHERE expand(num,nstart,((nstart+ batch_size) - 1),ctcr.committee_id,request->committees[num].
     committee_id)
     AND (ctcr.participation_type_cd=request->participation_type_cd)
     AND ctcr.active_ind=1)
   HEAD REPORT
    com_cnt = 0
   DETAIL
    com_cnt += 1
    IF (com_cnt > size(reply->committees,5))
     stat = alterlist(reply->committees,(com_cnt+ 5))
    ENDIF
    reply->committees[com_cnt].committee_id = ctcr.committee_id, reply->committees[com_cnt].
    amd_validate_ind = ctcr.amd_validate_ind, reply->committees[com_cnt].rev_validate_ind = ctcr
    .rev_validate_ind,
    reply->committees[com_cnt].edit_ind = ctcr.edit_ind
   FOOT REPORT
    stat = alterlist(reply->committees,com_cnt)
   WITH nocounter
  ;end select
  SET stat = alterlist(request->committees,cur_committee_cnt)
  IF (curqual=0
   AND com_cnt > 1)
   CALL report_failure("SELECT","F","CT_GET_TYPE_COMMITTEE_RELTN",
    "Error finding committee/type relationships by committee.")
   GO TO exit_script
  ELSEIF (com_cnt=0)
   CALL report_failure("SELECT","Z","CT_GET_TYPE_COMMITTEE_RELTN",
    "No committee/type relationships found.")
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   IF (opstatus="F")
    SET failed = "T"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "003"
 SET mod_date = "April 04, 2019"
END GO
