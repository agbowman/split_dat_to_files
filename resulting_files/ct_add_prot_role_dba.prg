CREATE PROGRAM ct_add_prot_role:dba
 RECORD reply(
   1 qual[*]
     2 id = f8
     2 debug = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE estring = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE ecode = i2 WITH protect, noconstant(0)
 DECLARE primary_id = f8 WITH protect, noconstant(0.0)
 DECLARE num_to_add = i2 WITH protect, noconstant(0)
 DECLARE personal_cd = f8 WITH protect, noconstant(0.0)
 DECLARE institution_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cur_updt_cnt = i2 WITH protect, noconstant(0)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE ctmsindvalue = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(17296,"PERSONAL",1,personal_cd)
 SET stat = uar_get_meaning_by_codeset(17296,"INSTITUTION",1,institution_cd)
 SET num_to_add = size(request->qual,5)
 FOR (i = 1 TO num_to_add)
   SET failed = "N"
   IF ((request->qual[i].prot_role_type="PERSONAL"))
    SET prot_role_type = personal_cd
   ELSEIF ((request->qual[i].prot_role_type="INSTITUTION"))
    SET prot_role_type = institution_cd
   ENDIF
   CALL echo(prot_role_type)
   IF ((request->qual[i].prot_role_id != 0))
    SELECT INTO "nl:"
     pr.*
     FROM prot_role pr
     WHERE (pr.prot_role_id=request->qual[i].prot_role_id)
     DETAIL
      cur_updt_cnt = pr.updt_cnt, ctmsindvalue = pr.created_by_ctms_ind
     WITH nocounter, forupdate(pr)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET stat = alterlist(reply->qual,i)
     SET reply->qual[i].id = ps.prot_role_id
     SET ecode = error(estring,1)
     SET reply->debug = build(estring," ; ")
    ENDIF
    IF ((cur_updt_cnt != request->qual[i].updt_cnt))
     SET failed = "T"
     SET stat = alterlist(reply->qual,i)
     SET reply->qual[i].id = ps.prot_role_id
     SET ecode = error(estring,1)
     SET reply->debug = build(estring," ; ")
    ENDIF
    CALL echo("before update")
    UPDATE  FROM prot_role pr
     SET pr.end_effective_dt_tm = cnvtdatetime(curdate,curtime), pr.updt_dt_tm = cnvtdatetime(sysdate
       ), pr.updt_id = reqinfo->updt_id,
      pr.updt_cnt = (pr.updt_cnt+ 1), pr.updt_applctx = reqinfo->updt_applctx, pr.updt_task = reqinfo
      ->updt_task,
      pr.primary_contact_rank_nbr = request->qual[i].primary_contact_rank_nbr
     WHERE (pr.prot_role_id=request->qual[i].prot_role_id)
     WITH nocounter
    ;end update
   ENDIF
   IF (failed != "T")
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)
     FROM dual
     DETAIL
      primary_id = cnvtreal(num)
     WITH format, counter
    ;end select
    CALL echo("before select")
    INSERT  FROM prot_role ro
     SET ro.prot_role_id = primary_id, ro.prot_amendment_id = request->qual[i].amendment_id, ro
      .prot_role_type_cd = prot_role_type,
      ro.person_id = request->qual[i].person_id, ro.organization_id = request->qual[i].
      organization_id, ro.prot_role_cd = request->qual[i].prot_role_cd,
      ro.beg_effective_dt_tm = cnvtdatetime(sysdate), ro.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), ro.updt_dt_tm = cnvtdatetime(sysdate),
      ro.updt_id = reqinfo->updt_id, ro.updt_applctx = reqinfo->updt_applctx, ro.updt_task = reqinfo
      ->updt_task,
      ro.updt_cnt = 0, ro.primary_contact_ind = request->qual[i].primary_ind, ro.position_cd =
      request->qual[i].position_cd,
      ro.primary_contact_rank_nbr = request->qual[i].primary_contact_rank_nbr, ro.created_by_ctms_ind
       = ctmsindvalue
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 CALL echo("after endfor")
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
  IF (failed="T")
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 CALL echo(build("Result:",reply->status_data.status))
 SET last_mod = "004"
 SET mod_date = "Feb 19, 2018"
END GO
