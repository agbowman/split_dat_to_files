CREATE PROGRAM bhs_eks_adt_er_notc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person ID:" = 0
  WITH outdev, personid
 SET retval = 0
 DECLARE person_id = f8
 DECLARE one_time_op = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"ONETIMEOP")), protect
 DECLARE rec_op = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"RECURRINGOP")), protect
 DECLARE off_visit = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OFFICEVISIT")), protect
 DECLARE disch_rec_op = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHRECURRINGOP")),
 protect
 DECLARE disch_rec_off_visit = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHRECUROFFICEVISIT")), protect
 DECLARE rec_off_visit = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"RECUROFFICEVISIT")),
 protect
 FREE RECORD locations
 RECORD locations(
   1 locqual[*]
     2 desc = vc
     2 qual[*]
       3 displaykey = vc
 )
 DECLARE qualifyinglocations = vc
 DECLARE log_misc1 = vc WITH noconstant(" ")
 SET stat = alterlist(locations->locqual,8)
 SET locations->locqual[1].desc = "BAYSTATEMASONSQ"
 SET stat = alterlist(locations->locqual[1].qual,5)
 SET locations->locqual[1].qual[1].displaykey = "BAYSTATEMASONSQ"
 SET locations->locqual[1].qual[2].displaykey = "MASONSQUARE"
 SET locations->locqual[1].qual[3].displaykey = "BAYSTATEMASONSQ"
 SET locations->locqual[1].qual[4].displaykey = "BAYSTATEMASONSQ"
 SET locations->locqual[1].qual[5].displaykey = "BAYSTATEMASONSQUARE"
 SET stat = alterlist(locations->locqual[2].qual,6)
 SET locations->locqual[2].desc = "BAYSTHIGHSTADLT"
 SET locations->locqual[2].qual[1].displaykey = "BAYSTATEHIGHSTADULT"
 SET locations->locqual[2].qual[2].displaykey = "BAYSTHIGHSTADLT"
 SET locations->locqual[2].qual[3].displaykey = "BAYSTHIGHSTADULTPODB"
 SET locations->locqual[2].qual[4].displaykey = "BAYSTHIGHSTADULTTRIAGE"
 SET locations->locqual[2].qual[5].displaykey = "BAYSTHIGHSTADLTMD"
 SET locations->locqual[2].qual[6].displaykey = "BAYSTHIGHSTADLT"
 SET stat = alterlist(locations->locqual[3].qual,4)
 SET locations->locqual[3].desc = "BAYSTHIGHSTPEDI"
 SET locations->locqual[3].qual[1].displaykey = "BAYSTHIGHSTPEDIPODB"
 SET locations->locqual[3].qual[2].displaykey = "BAYSTHIGHSTPEDIURGENTCARE"
 SET locations->locqual[3].qual[3].displaykey = "BAYSTHIGHSTPEDI"
 SET locations->locqual[3].qual[4].displaykey = "BAYSTATEHIGHSTPEDS"
 SET stat = alterlist(locations->locqual[4].qual,1)
 SET locations->locqual[4].desc = "HPAHOLYOKE"
 SET locations->locqual[4].qual[1].displaykey = "HPAHOLYOKE"
 SET stat = alterlist(locations->locqual[5].qual,1)
 SET locations->locqual[5].desc = "HPASOHADLEY"
 SET locations->locqual[5].qual[1].displaykey = "HPASOHADLEY"
 SET stat = alterlist(locations->locqual[6].qual,1)
 SET locations->locqual[6].desc = "PVPEDILONG"
 SET locations->locqual[6].qual[1].displaykey = "PVPEDILONG"
 SET stat = alterlist(locations->locqual[7].qual,5)
 SET locations->locqual[7].desc = "BAYSTATEADOLESMED"
 SET locations->locqual[7].qual[1].displaykey = "ADOLMEDWASON"
 SET locations->locqual[7].qual[2].displaykey = "BAYSTADOLMED"
 SET locations->locqual[7].qual[3].displaykey = "BAYSTADOLESMED"
 SET locations->locqual[7].qual[4].displaykey = "BAYSTATEADOLMED"
 SET locations->locqual[7].qual[5].displaykey = "BAYSTADOLESCENTMED"
 SET stat = alterlist(locations->locqual[8].qual,2)
 SET locations->locqual[8].desc = "BAYSTATEGENPEDS"
 SET locations->locqual[8].qual[1].displaykey = "BAYSTATEGENPEDS"
 SET locations->locqual[8].qual[2].displaykey = "GENPEDIWASON"
 SET lookback = cnvtlookbehind("2,Y",cnvtdatetime(curdate,curtime3))
 IF (validate(trigger_personid)=1)
  SET person_id = trigger_personid
 ELSE
  SET person_id =  $PERSONID
 ENDIF
 SELECT INTO  $OUTDEV
  location =
  IF (e.loc_facility_cd=cv.code_value) e.loc_facility_cd
  ELSE e.loc_nurse_unit_cd
  ENDIF
  FROM code_value cv,
   encounter e,
   (dummyt d1  WITH seq = value(size(locations->locqual,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(locations->locqual[d1.seq].qual,5)))
   JOIN (d2)
   JOIN (cv
   WHERE cv.code_set=220
    AND (cv.display_key=locations->locqual[d1.seq].qual[d2.seq].displaykey))
   JOIN (e
   WHERE e.person_id=person_id
    AND ((e.loc_facility_cd=cv.code_value) OR (e.loc_nurse_unit_cd=cv.code_value))
    AND e.end_effective_dt_tm >= cnvtdatetime(lookback)
    AND e.disch_dt_tm >= cnvtdatetime(lookback))
  ORDER BY location
  HEAD location
   IF (textlen(qualifyinglocations) > 0)
    qualifyinglocations = build(qualifyinglocations,",",locations->locqual[d1.seq].desc)
   ELSE
    qualifyinglocations = locations->locqual[d1.seq].desc
   ENDIF
   CALL echo(build("loc = ",locations->locqual[d1.seq].desc)),
   CALL echo(build("loc1 = ",locations->locqual[d1.seq].qual[d2.seq].displaykey))
  WITH nocounter, separator = " ", format
 ;end select
 CALL echo(build("qualifyingLocations = ",qualifyinglocations))
 CALL echo("Check encntr_loc_hist")
 SELECT INTO  $OUTDEV
  location =
  IF (elh.loc_facility_cd=cv.code_value) elh.loc_facility_cd
  ELSE elh.loc_nurse_unit_cd
  ENDIF
  FROM code_value cv,
   encounter e,
   encntr_loc_hist elh,
   (dummyt d1  WITH seq = value(size(locations->locqual,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(locations->locqual[d1.seq].qual,5)))
   JOIN (d2)
   JOIN (cv
   WHERE cv.code_set=220
    AND (cv.display_key=locations->locqual[d1.seq].qual[d2.seq].displaykey))
   JOIN (e
   WHERE e.person_id=person_id)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND ((elh.loc_facility_cd=cv.code_value) OR (elh.loc_nurse_unit_cd=cv.code_value))
    AND elh.end_effective_dt_tm >= cnvtdatetime(lookback))
  ORDER BY location
  HEAD location
   IF (findstring(locations->locqual[d1.seq].desc,qualifyinglocations,1,1)=0)
    IF (textlen(qualifyinglocations) > 0)
     qualifyinglocations = build(qualifyinglocations,",",locations->locqual[d1.seq].desc)
    ELSE
     qualifyinglocations = locations->locqual[d1.seq].desc
    ENDIF
   ELSE
    CALL echo("already found")
   ENDIF
  WITH nocounter, separator = " ", format
 ;end select
 CALL echo(build("qualifyingLocations1 = ",qualifyinglocations))
 IF (textlen(qualifyinglocations) > 0)
  SET retval = 100
  SET log_misc1 = qualifyinglocations
  SET log_message = build("Found the following prev. loc for this patient:",log_misc1)
 ELSE
  SET retval = 0
  SET log_message = build("No location found for this patient")
 ENDIF
 CALL echo(log_message)
 CALL echo(build("retval:",retval))
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   msg1 =
   IF (textlen(log_misc1) > 0) build("Location(s):",log_misc1)
   ELSE "No qualifying location found"
   ENDIF
   , col 0, "{PS/792 0 translate 90 rotate/}",
   y_pos = 18, row + 1, "{F/1}{CPI/7}",
   CALL print(calcpos(36,(y_pos+ 0))), msg1, row + 2
  WITH dio = 08
 ;end select
END GO
