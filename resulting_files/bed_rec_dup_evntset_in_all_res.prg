CREATE PROGRAM bed_rec_dup_evntset_in_all_res
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD dups
 RECORD dups(
   1 event_sets[*]
     2 code_value = f8
     2 level = i4
 )
 FREE RECORD dups2
 RECORD dups2(
   1 event_sets[*]
     2 code_value = f8
 )
 FREE RECORD fin_dups
 RECORD fin_dups(
   1 event_sets[*]
     2 code_value = f8
 )
 DECLARE all_results_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM v500_event_set_code vsc
  WHERE vsc.event_set_name="ALL RESULT SECTIONS"
  DETAIL
   all_results_cd = vsc.event_set_cd
  WITH nocounter
 ;end select
 SET reply->run_status_flag = 1
 SET ecnt = 0
 SET ecnt2 = 0
 SELECT INTO "nl:"
  FROM v500_event_set_canon c
  PLAN (c
   WHERE c.parent_event_set_cd=all_results_cd)
  ORDER BY c.event_set_cd
  HEAD c.event_set_cd
   ecnt = (ecnt+ 1), stat = alterlist(dups->event_sets,ecnt), dups->event_sets[ecnt].code_value = c
   .event_set_cd,
   dups->event_sets[ecnt].level = 1
  WITH nocounter
 ;end select
 SET temp_level = 1
 SET found_ind = 1
 IF (ecnt > 0)
  WHILE (found_ind=1)
   SET found_ind = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ecnt)),
     v500_event_set_canon c
    PLAN (d
     WHERE (dups->event_sets[d.seq].level=temp_level))
     JOIN (c
     WHERE (c.parent_event_set_cd=dups->event_sets[d.seq].code_value))
    ORDER BY c.parent_event_set_cd
    DETAIL
     ecnt = (ecnt+ 1), stat = alterlist(dups->event_sets,ecnt), dups->event_sets[ecnt].code_value = c
     .event_set_cd,
     dups->event_sets[ecnt].level = (temp_level+ 1)
    FOOT REPORT
     temp_level = (temp_level+ 1), found_ind = 1
    WITH nocounter
   ;end select
  ENDWHILE
  SET fincount = 0
  SET ecnt3 = 0
  SELECT INTO "nl:"
   c = dups->event_sets[d.seq].code_value
   FROM (dummyt d  WITH seq = value(ecnt))
   PLAN (d)
   ORDER BY c
   HEAD c
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (cnt=2)
     ecnt3 = (ecnt3+ 1), stat = alterlist(fin_dups->event_sets,ecnt3), fin_dups->event_sets[ecnt3].
     code_value = c
    ENDIF
   WITH nocounter
  ;end select
  IF (ecnt3 > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = ecnt3),
     code_value cv
    PLAN (d)
     JOIN (cv
     WHERE (cv.code_value=fin_dups->event_sets[d.seq].code_value)
      AND  EXISTS (
     (SELECT
      e.event_set_cd
      FROM v500_event_set_explode e
      WHERE e.event_set_cd=cv.code_value
       AND e.event_set_level=0)))
    DETAIL
     reply->run_status_flag = 3
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
