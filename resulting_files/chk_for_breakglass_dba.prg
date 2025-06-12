CREATE PROGRAM chk_for_breakglass:dba
 DECLARE found = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(1)
 DECLARE j = i4 WITH noconstant(1)
 DECLARE k = i4 WITH noconstant(1)
 DECLARE valid_encntr_list_size = i4 WITH noconstant(0)
 RECORD reply(
   1 break_glass = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->break_glass = 0
 SET found = 0
 SET k = 1
 SET j = 1
 SET valid_encntr_list_size = size(request->valid_encntr_list_sorted,5)
 SUBROUTINE determineconfidlevel(confid_cd)
   DECLARE retval = i4 WITH noconstant(uar_get_collation_seq(confid_cd))
   IF (retval < 0)
    SET retval = 0
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SELECT INTO "nl:"
  FROM encounter e,
   organization o
  PLAN (e
   WHERE (e.person_id=request->person_id)
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND e.active_ind=1)
   JOIN (o
   WHERE o.organization_id=e.organization_id
    AND o.active_ind=1
    AND  NOT (e.organization_id IN (
   (SELECT
    por.organization_id
    FROM prsnl_org_reltn por,
     organization o
    WHERE (por.person_id=request->prsnl_id)
     AND o.organization_id=por.organization_id
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND o.active_ind=1))))
  ORDER BY e.encntr_id
  HEAD REPORT
   IF (valid_encntr_list_size=0)
    reply->break_glass = 1
   ELSE
    reply->break_glass = 0
   ENDIF
  DETAIL
   IF ((reply->break_glass=0)
    AND valid_encntr_list_size > 0)
    IF ((e.encntr_id >= request->valid_encntr_list_sorted[1].encntr_id)
     AND (e.encntr_id <= request->valid_encntr_list_sorted[valid_encntr_list_size].encntr_id))
     FOR (j = k TO valid_encntr_list_size)
       IF ((e.encntr_id=request->valid_encntr_list_sorted[j].encntr_id))
        k = (j+ 1), found = 1
       ENDIF
     ENDFOR
     IF (found=0)
      reply->break_glass = 1
     ENDIF
    ELSE
     reply->break_glass = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->break_glass=0))
  SELECT INTO "nl:"
   FROM encounter e,
    organization o,
    prsnl_org_reltn por
   PLAN (e
    WHERE (e.person_id=request->person_id)
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND e.active_ind=1)
    JOIN (o
    WHERE o.organization_id=e.organization_id
     AND o.active_ind=1)
    JOIN (por
    WHERE (por.person_id=request->prsnl_id)
     AND por.organization_id=o.organization_id
     AND por.organization_id=e.organization_id
     AND por.active_ind=1
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY e.encntr_id
   HEAD REPORT
    reply->break_glass = 0, found = 0, k = 1,
    j = 1
   DETAIL
    IF ((reply->break_glass=0))
     found = 0
     IF (valid_encntr_list_size > 0
      AND (e.encntr_id >= request->valid_encntr_list_sorted[1].encntr_id)
      AND (e.encntr_id <= request->valid_encntr_list_sorted[valid_encntr_list_size].encntr_id))
      FOR (j = k TO valid_encntr_list_size)
        IF ((e.encntr_id=request->valid_encntr_list_sorted[j].encntr_id))
         k = (j+ 1), found = 1, BREAK
        ELSEIF ((e.encntr_id < request->valid_encntr_list_sorted[j].encntr_id))
         k = j, found = 0, BREAK
        ENDIF
      ENDFOR
     ENDIF
     IF (found=0
      AND determineconfidlevel(e.confid_level_cd) > determineconfidlevel(por.confid_level_cd))
      reply->break_glass = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
END GO
