CREATE PROGRAM cdi_ops_encntr_cover_page:dba
 FREE RECORD tdo_request_struct
 RECORD tdo_request_struct(
   1 encntr_qual[*]
     2 encntr_id = f8
 )
 FREE SET tdo_reply_struct
 RECORD tdo_reply_struct(
   1 encntr_qual[*]
     2 encntr_id = f8
     2 term_digit_nbr = i4
     2 term_digit_format = vc
 )
 SET organization_id = 0
 SET patient_type_cd = 0
 SET hours = 0
 SET a = findstring("^",request->batch_selection)
 SET b = size(request->batch_selection,1)
 SET c = findstring("^",request->batch_selection,(a+ 1))
 SET d = findstring("^",request->batch_selection,(c+ 1))
 SET organization_id = cnvtint(substring(1,(a - 1),request->batch_selection))
 SET patient_type_cd = cnvtint(substring((a+ 1),((c - a) - 1),request->batch_selection))
 IF (d > 0)
  SET hours = cnvtint(substring((c+ 1),((d - c) - 1),request->batch_selection))
 ELSE
  SET hours = cnvtint(substring((c+ 1),(b - c),request->batch_selection))
 ENDIF
 SET x = 0
 SELECT INTO "nl:"
  FROM encounter e
  WHERE e.encntr_type_cd=patient_type_cd
   AND e.disch_dt_tm > cnvtdatetime(cnvtlookbehind(build(hours,"H")))
   AND e.disch_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND e.organization_id=organization_id
  DETAIL
   x = (x+ 1)
   IF (x > size(tdo_request_struct->encntr_qual,5))
    stat = alterlist(tdo_request_struct->encntr_qual,(x+ 9))
   ENDIF
   tdo_request_struct->encntr_qual[x].encntr_id = e.encntr_id
  FOOT REPORT
   stat = alterlist(tdo_request_struct->encntr_qual,x)
  WITH nocounter
 ;end select
 IF (x > 0)
  EXECUTE him_get_terminal_digits
  SET x = 0
  SELECT INTO "nl:"
   tdo = tdo_reply_struct->encntr_qual[d.seq].term_digit_nbr
   FROM (dummyt d  WITH seq = value(size(tdo_reply_struct->encntr_qual,5)))
   ORDER BY tdo
   DETAIL
    x = (x+ 1)
    IF (x > size(request->encntr_qual,5))
     stat = alterlist(request->encntr_qual,(x+ 9))
    ENDIF
    request->encntr_qual[x].encntr_id = tdo_reply_struct->encntr_qual[d.seq].encntr_id
   FOOT REPORT
    stat = alterlist(request->encntr_qual,x)
   WITH nocounter
  ;end select
  EXECUTE cdi_mak_encntr_cover_page
 ENDIF
END GO
