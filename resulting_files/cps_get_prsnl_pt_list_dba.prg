CREATE PROGRAM cps_get_prsnl_pt_list:dba
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD reply
 RECORD reply(
   1 person_qual = i4
   1 person[*]
     2 person_id = f8
     2 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp
 RECORD temp(
   1 person_qual = i4
   1 person[*]
     2 person_id = f8
     2 does_exist = i2
     2 name_full_formatted = vc
 )
 DECLARE idx = i4 WITH noconstant(0), public
 DECLARE idx2 = i4 WITH noconstant(0), public
 DECLARE idx3 = i4 WITH noconstant(0), public
 DECLARE idx4 = i4 WITH noconstant(0), public
 DECLARE idx5 = i4 WITH noconstant(0), public
 DECLARE idx6 = i4 WITH noconstant(0), public
 DECLARE gidx = i4 WITH noconstant(0), public
 DECLARE i_pos = i4 WITH noconstant(0), public
 IF ((request->ppr_qual > 0))
  CALL echo("***")
  CALL echo("***   request->ppr_qual > 0")
  CALL echo("***")
  SET ierrcode = 0
  SELECT INTO "nl:"
   ppr.person_id
   FROM person_prsnl_reltn ppr,
    person p
   PLAN (ppr
    WHERE expand(idx,1,request->prsnl_qual,ppr.prsnl_person_id,request->prsnl[idx].prsnl_id)
     AND expand(idx2,1,request->ppr_qual,(ppr.person_prsnl_r_cd+ 0),request->ppr[idx2].ppr_cd)
     AND ((ppr.person_id+ 0) > 0)
     AND ((ppr.active_ind+ 0)=1)
     AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=ppr.person_id)
   ORDER BY ppr.person_id
   HEAD REPORT
    pknt = 0, stat = alterlist(reply->person,10)
   HEAD p.person_id
    pknt += 1
    IF (mod(pknt,10)=1
     AND pknt != 1)
     stat = alterlist(reply->person,(pknt+ 9))
    ENDIF
    reply->person[pknt].person_id = ppr.person_id, reply->person[pknt].name_full_formatted = p
    .name_full_formatted
   FOOT REPORT
    reply->person_qual = pknt, stat = alterlist(reply->person,pknt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_PRSNL_RELTN"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ELSEIF ((reply->person_qual < 1))
   CALL echo("***")
   CALL echo("***   reply->person_qual < 1")
   CALL echo("***")
   SET ierrcode = 0
   SELECT INTO "nl:"
    e.person_id
    FROM encntr_prsnl_reltn epr,
     encounter e,
     person p
    PLAN (epr
     WHERE expand(idx3,1,request->prsnl_qual,epr.prsnl_person_id,request->prsnl[idx3].prsnl_id)
      AND epr.expiration_ind=0
      AND expand(idx4,1,request->ppr_qual,(epr.encntr_prsnl_r_cd+ 0),request->ppr[idx4].ppr_cd)
      AND ((epr.encntr_id+ 0) > 0)
      AND ((epr.active_ind+ 0)=1)
      AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (e
     WHERE e.encntr_id=epr.encntr_id
      AND ((e.person_id+ 0) > 0)
      AND ((e.active_ind+ 0)=1)
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (p
     WHERE p.person_id=e.person_id)
    ORDER BY e.person_id
    HEAD REPORT
     pknt = 0, stat = alterlist(reply->person,10)
    HEAD p.person_id
     pknt += 1
     IF (mod(pknt,10)=1
      AND pknt != 1)
      stat = alterlist(reply->person,(pknt+ 9))
     ENDIF
     reply->person[pknt].person_id = e.person_id, reply->person[pknt].name_full_formatted = p
     .name_full_formatted
    FOOT REPORT
     reply->person_qual = pknt, stat = alterlist(reply->person,pknt)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "ENCNTR_PRSNL_RELTN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
  ELSE
   CALL echo("***")
   CALL echo("***   reply->person_qual >= 1")
   CALL echo("***")
   SET ierrcode = 0
   SELECT INTO "nl:"
    e.person_id
    FROM encntr_prsnl_reltn epr,
     encounter e,
     person p
    PLAN (epr
     WHERE expand(idx3,1,request->prsnl_qual,epr.prsnl_person_id,request->prsnl[idx3].prsnl_id)
      AND epr.expiration_ind=0
      AND expand(idx4,1,request->ppr_qual,(epr.encntr_prsnl_r_cd+ 0),request->ppr[idx4].ppr_cd)
      AND ((epr.encntr_id+ 0) > 0)
      AND ((epr.active_ind+ 0)=1)
      AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (e
     WHERE e.encntr_id=epr.encntr_id
      AND ((e.person_id+ 0) > 0)
      AND ((e.active_ind+ 0)=1)
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (p
     WHERE p.person_id=e.person_id)
    ORDER BY e.person_id
    HEAD REPORT
     pknt = 0, stat = alterlist(temp->person,10)
    HEAD p.person_id
     pknt += 1
     IF (mod(pknt,10)=1
      AND pknt != 1)
      stat = alterlist(temp->person,(pknt+ 9))
     ENDIF
     temp->person[pknt].person_id = e.person_id, temp->person[pknt].name_full_formatted = p
     .name_full_formatted
    FOOT REPORT
     temp->person_qual = pknt, stat = alterlist(temp->person,pknt)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "ENCNTR_PRSNL_RELTN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
   IF ((temp->person_qual > 0))
    CALL echo("***")
    CALL echo("***   select relationships temp->person_qual > 0")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SET find_knt = 0
    FOR (gidx = 1 TO temp->person_qual)
     SET i_pos = locateval(i_pos,1,reply->person_qual,temp->person[gidx].person_id,reply->person[
      i_pos].person_id)
     IF (i_pos > 0)
      SET find_knt += 1
      SET temp->person[gidx].does_exist = true
     ENDIF
    ENDFOR
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CHECK_FOR_DUPS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    IF ((find_knt < temp->person_qual))
     CALL echo("***")
     CALL echo("***   select relationships find_knt < temp->person_qual")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(temp->person_qual))
      PLAN (d
       WHERE (temp->person[d.seq].does_exist=false))
      HEAD REPORT
       pknt = reply->person_qual, stat = alterlist(reply->person,(pknt+ 10))
      DETAIL
       pknt += 1
       IF (mod(pknt,10)=1
        AND pknt != 1)
        stat = alterlist(reply->person,(pknt+ 9))
       ENDIF
       reply->person[pknt].person_id = temp->person[d.seq].person_id, reply->person[pknt].
       name_full_formatted = temp->person[d.seq].name_full_formatted
      FOOT REPORT
       reply->person_qual = pknt, stat = alterlist(reply->person,pknt)
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "ADD_NON_DUPS"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ELSE
  CALL echo("***")
  CALL echo("***   request->ppr_qual <= 0")
  CALL echo("***")
  SET ierrcode = 0
  SELECT INTO "nl:"
   ppr.person_id
   FROM person_prsnl_reltn ppr,
    person p
   PLAN (ppr
    WHERE expand(idx,1,request->prsnl_qual,ppr.prsnl_person_id,request->prsnl[idx].prsnl_id)
     AND ((ppr.person_id+ 0) > 0)
     AND ((ppr.active_ind+ 0)=1)
     AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=ppr.person_id)
   ORDER BY ppr.person_id
   HEAD REPORT
    pknt = 0, stat = alterlist(reply->person,10)
   HEAD p.person_id
    pknt += 1
    IF (mod(pknt,10)=1
     AND pknt != 1)
     stat = alterlist(reply->person,(pknt+ 9))
    ENDIF
    reply->person[pknt].person_id = ppr.person_id, reply->person[pknt].name_full_formatted = p
    .name_full_formatted
   FOOT REPORT
    reply->person_qual = pknt, stat = alterlist(reply->person,pknt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_PRSNL_RELTN"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ELSEIF ((reply->person_qual < 1))
   CALL echo("***")
   CALL echo("***   Hitting ENCNTR_PRSNL_RELTN table Number B-1")
   CALL echo("***")
   SET ierrcode = 0
   SELECT INTO "nl:"
    e.person_id
    FROM encntr_prsnl_reltn epr,
     encounter e,
     person p
    PLAN (epr
     WHERE expand(idx,1,request->prsnl_qual,epr.prsnl_person_id,request->prsnl[idx].prsnl_id)
      AND epr.expiration_ind=0
      AND ((epr.encntr_id+ 0) > 0)
      AND ((epr.active_ind+ 0)=1)
      AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (e
     WHERE e.encntr_id=epr.encntr_id
      AND ((e.person_id+ 0) > 0)
      AND ((e.active_ind+ 0)=1)
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (p
     WHERE p.person_id=e.person_id)
    ORDER BY e.person_id
    HEAD REPORT
     pknt = 0, stat = alterlist(reply->person,10)
    HEAD p.person_id
     pknt += 1
     IF (mod(pknt,10)=1
      AND pknt != 1)
      stat = alterlist(reply->person,(pknt+ 9))
     ENDIF
     reply->person[pknt].person_id = e.person_id, reply->person[pknt].name_full_formatted = p
     .name_full_formatted
    FOOT REPORT
     reply->person_qual = pknt, stat = alterlist(reply->person,pknt)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "ENCNTR_PRSNL_RELTN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
  ELSE
   CALL echo("***")
   CALL echo("***   Hitting ENCNTR_PRSNL_RELTN table Number B-2")
   CALL echo("***")
   SET ierrcode = 0
   SELECT INTO "nl:"
    e.person_id
    FROM encntr_prsnl_reltn epr,
     encounter e,
     person p
    PLAN (epr
     WHERE expand(idx,1,request->prsnl_qual,epr.prsnl_person_id,request->prsnl[idx].prsnl_id)
      AND epr.expiration_ind=0
      AND ((epr.encntr_id+ 0) > 0)
      AND ((epr.active_ind+ 0)=1)
      AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (e
     WHERE e.encntr_id=epr.encntr_id
      AND ((e.person_id+ 0) > 0)
      AND ((e.active_ind+ 0)=1)
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (p
     WHERE p.person_id=e.person_id)
    ORDER BY e.person_id
    HEAD REPORT
     pknt = 0, stat = alterlist(temp->person,10)
    HEAD p.person_id
     pknt += 1
     IF (mod(pknt,10)=1
      AND pknt != 1)
      stat = alterlist(temp->person,(pknt+ 9))
     ENDIF
     temp->person[pknt].person_id = e.person_id, temp->person[pknt].name_full_formatted = p
     .name_full_formatted
    FOOT REPORT
     temp->person_qual = pknt, stat = alterlist(temp->person,pknt)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "ENCNTR_PRSNL_RELTN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
   IF ((temp->person_qual > 0))
    CALL echo("***")
    CALL echo("***   all relationships temp->person_qual > 0")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SET find_knt = 0
    FOR (gidx = 1 TO temp->person_qual)
     SET i_pos = locateval(i_pos,1,reply->person_qual,temp->person[gidx].person_id,reply->person[
      i_pos].person_id)
     IF (i_pos > 0)
      SET find_knt += 1
      SET temp->person[gidx].does_exist = true
     ENDIF
    ENDFOR
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CHECK_FOR_DUPS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    IF ((find_knt < temp->person_qual))
     CALL echo("***")
     CALL echo("***   all relationships find_knt < temp_person_qual")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(temp->person_qual))
      PLAN (d
       WHERE (temp->person[d.seq].does_exist=false))
      HEAD REPORT
       pknt = reply->person_qual, stat = alterlist(reply->person,(pknt+ 10))
      DETAIL
       pknt += 1
       IF (mod(pknt,10)=1
        AND pknt != 1)
        stat = alterlist(reply->person,(pknt+ 9))
       ENDIF
       reply->person[pknt].person_id = temp->person[d.seq].person_id, reply->person[pknt].
       name_full_formatted = temp->person[d.seq].name_full_formatted
      FOOT REPORT
       reply->person_qual = pknt, stat = alterlist(reply->person,pknt)
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "ADD_NON_DUPS"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (failed=false)
  IF ((reply->person_qual > 0))
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 SET mod_version = "006 01/04/05 AW9942"
END GO
