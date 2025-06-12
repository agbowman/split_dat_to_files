CREATE PROGRAM agc_pat_disc:dba
 SELECT INTO "nl:"
  e.seq
  FROM encounter e
  WHERE (e.encntr_id=request->visit[x].encntr_id)
  DETAIL
   person_id = e.person_id
  WITH nocounter
 ;end select
 SELECT INTO request->output_device
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   thead = "                                                  "
  HEAD PAGE
   "{pos/60/55}{f/12}Patient Name:  ", name, row + 1,
   "{pos/60/67}Date of Birth:  ", dob, row + 1,
   "{pos/60/79}Admitting Physician:  ", admitdoc, row + 1,
   xxx = concat(trim(unit)," ; ",trim(room)," ; ",trim(bed)), "{pos/320/55}Med Rec Num:  ", mrn,
   row + 1, "{pos/320/67}Age:  ", age,
   row + 1, "{pos/320/79}Location:  ", xxx,
   row + 1, "{pos/320/91}Financial Num: ", finnbr,
   row + 1, "{pos/260/120}{f/13}{u}KARDEX SUMMARY", row + 1
   IF (thead > " ")
    "{pos/65/140}{f/9}{u}", thead, row + 1
   ENDIF
   xcol = 65, ycol = 140
  DETAIL
   xcol = 65, ycol = 140,
   CALL print(calcpos(xcol,ycol)),
   "{f/9}{cpi/16}PATIENT INFORMATION", row + 1, ycol = (ycol+ 12),
   xcol = 65
 ;end select
END GO
