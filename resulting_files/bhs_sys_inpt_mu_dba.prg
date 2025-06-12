CREATE PROGRAM bhs_sys_inpt_mu:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Input File:" = " ",
  "Input File:" = 10012010,
  "Input File:" = 10312010
  WITH outdev
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12030,"CANCELED"))
 DECLARE mf_order_canceled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "CANCELED"))
 DECLARE mf_order_discontinued_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "DISCONTINUED"))
 DECLARE mf_order_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "COMPLETED"))
 DECLARE mf_height_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 DECLARE md_start_dt_tm = dq8 WITH protect, constant(cnvtdatetime(cnvtdate( $3),0))
 DECLARE md_end_dt_tm = dq8 WITH protect, constant(cnvtdatetime(cnvtdate( $4),235959))
 DECLARE ms_output = vc WITH protect, constant(value( $1))
 DECLARE ms_input_file = vc WITH protect, constant(value( $2))
 DECLARE ms_output_file = vc WITH protect, constant(build(substring(1,findstring(".",ms_input_file),
    ms_input_file),"csv"))
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 line = vc
     2 fin = vc
     2 fname = vc
     2 lname = vc
     2 pid = f8
     2 eidlist[*]
       3 eid = f8
       3 reg = vc
       3 etype = vc
     2 probflag = i2
     2 diagflag = i2
     2 medflag = i2
     2 medallergyflag = i2
     2 cpoeflag = i2
     2 smokeflag = i2
     2 vitalheightflag = i2
     2 vitalencflag = i2
     2 vitalflag = i2
     2 ageless13 = i2
     2 fax_ind = i2
     2 print_ind = i2
     2 pos = c2
     2 age = vc
 )
 IF (findfile(ms_input_file)=0)
  CALL echo("###########################################")
  CALL echo(build('The input file "',ms_input_file,'" was not found.'))
  CALL echo("###########################################")
  GO TO exit_script
 ENDIF
 IF (((md_start_dt_tm < cnvtdatetime("01-JAN-2000")) OR (((md_end_dt_tm < cnvtdatetime("01-JAN-2000")
 ) OR (md_start_dt_tm > md_end_dt_tm)) )) )
  CALL echo("###########################################")
  CALL echo(build("Invalid date range."))
  CALL echo(build("Start Date:",format(md_start_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")))
  CALL echo(build("End Date  :",format(md_end_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")))
  CALL echo("###########################################")
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl
 DEFINE rtl value(ms_input_file)
 SELECT INTO "nl:"
  FROM rtlt r
  WHERE r.line > " "
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1), stat = alterlist(temp->qual,x), temp->qual[x].line = trim(r.line,3),
   temp->qual[x].fin = substring(8,9,r.line)
  WITH nocounter
 ;end select
 CALL echo(build("qualified:",size(temp->qual,5)))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   encntr_alias ea,
   encounter e,
   encounter e2,
   person p
  PLAN (d)
   JOIN (ea
   WHERE (ea.alias=temp->qual[d.seq].fin)
    AND ((ea.active_ind+ 0)=1)
    AND ((ea.end_effective_dt_tm+ 0) > sysdate))
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (e2
   WHERE e2.person_id=e.person_id
    AND e2.disch_dt_tm BETWEEN cnvtdatetime(md_start_dt_tm) AND cnvtdatetime(md_end_dt_tm)
    AND e2.encntr_class_cd IN (319455, 319456))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].pid = p.person_id, temp->qual[d.seq].fname = p.name_first_key, temp->qual[d.seq]
   .lname = p.name_last_key,
   cnt = 0, pos21 = 0, pos23 = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual[d.seq].eidlist,cnt), temp->qual[d.seq].eidlist[cnt].
   eid = e2.encntr_id,
   temp->qual[d.seq].eidlist[cnt].reg = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"), temp->qual[d.seq].
   eidlist[cnt].etype = uar_get_code_display(e.encntr_class_cd)
   IF (datetimecmp(cnvtdatetime(md_end_dt_tm),p.birth_dt_tm) < 4751)
    temp->qual[d.seq].ageless13 = 1
   ENDIF
   temp->qual[d.seq].age = cnvtage(p.birth_dt_tm,cnvtdatetime(md_end_dt_tm))
   IF (e.encntr_class_cd=319455)
    pos23 = 1
   ELSE
    pos21 = 1
   ENDIF
  FOOT  d.seq
   IF (pos21=1)
    temp->qual[d.seq].pos = "21"
   ELSE
    temp->qual[d.seq].pos = "23"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   problem p
  PLAN (d
   WHERE (temp->qual[d.seq].pid > 0))
   JOIN (p
   WHERE (p.person_id=temp->qual[d.seq].pid)
    AND p.nomenclature_id > 0
    AND p.life_cycle_status_cd != mf_canceled_cd)
  DETAIL
   temp->qual[d.seq].probflag = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   diagnosis dx
  PLAN (d
   WHERE (temp->qual[d.seq].pid > 0))
   JOIN (dx
   WHERE (dx.person_id=temp->qual[d.seq].pid)
    AND dx.nomenclature_id > 0
    AND dx.active_ind=1)
  DETAIL
   temp->qual[d.seq].diagflag = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   allergy a
  PLAN (d
   WHERE (temp->qual[d.seq].pid > 0))
   JOIN (a
   WHERE (a.person_id=temp->qual[d.seq].pid)
    AND a.reaction_status_cd != mf_canceled_cd)
  DETAIL
   temp->qual[d.seq].medallergyflag = 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(temp->qual,5))
  CALL echo(build("BMC LOOP:",x))
  IF ((temp->qual[x].pid > 0))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(temp->qual[x].eidlist,5))),
     orders o
    PLAN (d)
     JOIN (o
     WHERE (o.encntr_id=temp->qual[x].eidlist[d.seq].eid)
      AND o.orig_ord_as_flag IN (1, 2, 3)
      AND o.catalog_type_cd=2516
      AND  NOT (o.order_status_cd IN (mf_order_canceled_cd, mf_order_discontinued_cd,
     mf_order_completed_cd)))
    DETAIL
     temp->qual[x].medflag = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(temp->qual[x].eidlist,5))),
     orders o
    PLAN (d)
     JOIN (o
     WHERE (o.encntr_id=temp->qual[x].eidlist[d.seq].eid)
      AND o.med_order_type_cd > 0
      AND  EXISTS (
     (SELECT
      oa.order_id
      FROM order_action oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=1
       AND  EXISTS (
      (SELECT
       pr.person_id
       FROM prsnl pr
       WHERE pr.person_id=oa.action_personnel_id
        AND pr.physician_ind=1))))
      AND ((o.cki != "MUL.ORD!*") OR ( NOT ( EXISTS (
     (SELECT
      1
      FROM mltm_ndc_main_drug_code mnmdc
      WHERE mnmdc.drug_identifier=substring(9,6,o.cki)
       AND  NOT (mnmdc.csa_schedule IN (2, 3))))))) )
    DETAIL
     temp->qual[x].cpoeflag = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM clinical_event ce
    PLAN (ce
     WHERE (ce.person_id=temp->qual[x].pid)
      AND ce.event_cd=mf_height_cd)
    DETAIL
     temp->qual[x].vitalheightflag = 1
    WITH nocounter, maxrec = 1
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(temp->qual[x].eidlist,5))),
     clinical_event ce
    PLAN (d)
     JOIN (ce
     WHERE (ce.encntr_id=temp->qual[x].eidlist[d.seq].eid)
      AND  EXISTS (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_value=ce.event_cd
       AND cv.code_set=72
       AND ((cv.display_key="*SMOK*") OR (((cv.display_key="WEIGHT") OR (((cv.display_key=
      "BODYMASSINDEX*") OR (((cv.display_key="SYSTOLICBLOODPRESSURE*") OR (cv.display_key=
      "DIASTOLICBLOODPRESSURE*")) )) )) ))
       AND  NOT (cv.display_key IN ("ED Burn/ Smoke Inhalation",
      "Inform patient hospital is smoke free", "Patient informed smoke free hospital"))
       AND cv.code_set=72
       AND cv.active_ind=1)))
    ORDER BY d.seq
    HEAD d.seq
     bpd = 0, bps = 0, bmi = 0,
     wt = 0
    DETAIL
     CASE (cnvtupper(uar_get_code_display(ce.event_cd)))
      OF "WEIGHT":
       wt = 1
      OF "BODY MASS INDEX*":
       bmi = 1
      OF "SYSTOLIC BLOOD PRESSURE*":
       bps = 1
      OF "DIASTOLIC BLOOD PRESSURE*":
       bpd = 1
      OF "*SMOK*":
       temp->qual[x].smokeflag = 1
     ENDCASE
    FOOT  d.seq
     IF (wt=1
      AND bmi=1
      AND bps=1
      AND bpd=1)
      temp->qual[x].vitalencflag = 1
     ENDIF
    WITH nocounter
   ;end select
   IF ((temp->qual[x].vitalheightflag=1)
    AND (temp->qual[x].vitalencflag=1))
    SET temp->qual[x].vitalflag = 1
   ENDIF
   IF ((temp->qual[x].smokeflag != 1))
    SELECT INTO "nl:"
     FROM hm_expect_mod hem,
      hm_expect_sat hes,
      hm_expect he
     PLAN (hem
      WHERE (hem.person_id=temp->qual[x].pid)
       AND hem.active_ind=1
       AND hem.modifier_dt_tm BETWEEN cnvtdatetime(md_start_dt_tm) AND cnvtdatetime(md_end_dt_tm))
      JOIN (hes
      WHERE hes.expect_sat_id=hem.expect_sat_id
       AND hes.active_ind=1)
      JOIN (he
      WHERE hes.expect_id=he.expect_id
       AND he.expect_name="Tobacco*"
       AND he.active_ind=1)
     DETAIL
      temp->qual[x].smokeflag = 1
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDFOR
 SELECT INTO value(ms_output_file)
  fin = substring(1,10,temp->qual[d.seq].fin), first_name = substring(1,30,temp->qual[d.seq].fname),
  last_name = substring(1,30,temp->qual[d.seq].lname),
  person_id = substring(1,10,cnvtstring(temp->qual[d.seq].pid)), problem_flag = substring(1,1,
   cnvtstring(temp->qual[d.seq].probflag)), diagnosis_flag = substring(1,1,cnvtstring(temp->qual[d
    .seq].diagflag)),
  med_flag = substring(1,1,cnvtstring(temp->qual[d.seq].medflag)), allergy_flag = substring(1,1,
   cnvtstring(temp->qual[d.seq].medallergyflag)), smoke_flag = substring(1,1,cnvtstring(temp->qual[d
    .seq].smokeflag)),
  vital_flag = substring(1,1,cnvtstring(temp->qual[d.seq].vitalflag)), ag_less13_flag = substring(1,1,
   cnvtstring(temp->qual[d.seq].ageless13)), age = substring(1,20,temp->qual[d.seq].age),
  cpoe = substring(1,1,cnvtstring(temp->qual[d.seq].cpoeflag)), pos = substring(1,2,temp->qual[d.seq]
   .pos)
  FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
  WITH nocounter, format, separator = ","
 ;end select
 SELECT INTO value(ms_output)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   row 0, col 0, "The Meaningful Use output csv file was created.",
   row + 1, ms_line = build("Date range: ",format(md_start_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")," to ",
    format(md_end_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")), col 0,
   ms_line, row + 1, ms_line = build("Output file: ",ms_output_file),
   col 0, ms_line, row + 1,
   ms_line = build("Records: ",cnvtstring(size(temp->qual,5))), col 0, ms_line
  WITH nocounter
 ;end select
#exit_script
END GO
