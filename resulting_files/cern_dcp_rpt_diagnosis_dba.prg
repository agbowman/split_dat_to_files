CREATE PROGRAM cern_dcp_rpt_diagnosis:dba
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 diagnosis = c255
     2 diag_cnt = i2
     2 diag_qual[*]
       3 diag_line = vc
     2 diag_type = c10
     2 diag_dt = c10
     2 category = c10
     2 priority = i4
     2 class = c10
     2 active_status = c10
     2 documented_by = vc
 )
 EXECUTE dcp_gen_valid_encounters_recs
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET modify = predeclare
 DECLARE name = vc WITH noconstant(fillstring(50," "))
 DECLARE mrn = vc WITH noconstant(fillstring(50," "))
 DECLARE fnbr = vc WITH noconstant(fillstring(50," "))
 DECLARE attenddoc = vc WITH noconstant(fillstring(50," "))
 DECLARE dob = vc WITH noconstant(fillstring(50," "))
 DECLARE age = vc WITH noconstant(fillstring(50," "))
 DECLARE sex = vc WITH noconstant(fillstring(50," "))
 DECLARE admit_date = vc WITH noconstant(fillstring(50," "))
 DECLARE unit = vc WITH noconstant(fillstring(50," "))
 DECLARE room = vc WITH noconstant(fillstring(50," "))
 DECLARE bed = vc WITH noconstant(fillstring(50," "))
 DECLARE location = vc WITH noconstant(fillstring(50," "))
 DECLARE person_id = i4 WITH noconstant(0)
 DECLARE canceled_cd = f8 WITH noconstant(0.0)
 DECLARE encntr_mrn_cd = f8 WITH noconstant(0.0)
 DECLARE person_mrn_cd = f8 WITH noconstant(0.0)
 DECLARE fnbr_cd = f8 WITH noconstant(0.0)
 DECLARE attenddoc_cd = f8 WITH noconstant(0.0)
 DECLARE max_length = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE error_cd = i2 WITH noconstant(0)
 DECLARE reply_cnt = i2 WITH noconstant(0)
 DECLARE reg_tz = i4 WITH noconstant(0)
 DECLARE printed_date = vc WITH constant(datetimezoneformat(cnvtdatetime(curdate,curtime3),
   curtimezoneapp,"MM/DD/YY HH:mm ZZZ"))
 SET canceled_cd = uar_get_code_by("MEANING",12025,"CANCELED")
 SET person_mrn_cd = uar_get_code_by("MEANING",4,"MRN")
 SET encntr_mrn_cd = uar_get_code_by("MEANING",319,"MRN")
 SET fnbr_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET attenddoc_cd = uar_get_code_by("MEANING",333,"ATTENDDOC")
 IF ((request->visit[1].encntr_id <= 0))
  SET error_cd = 1
  GO TO report_failed
 ENDIF
 FREE RECORD treq
 RECORD treq(
   1 encntrs[*]
     2 encntr_id = f8
     2 transaction_dt_tm = dq8
   1 facilities[*]
     2 loc_facility_cd = f8
 )
 FREE RECORD trep
 RECORD trep(
   1 encntrs_qual_cnt = i4
   1 encntrs[*]
     2 encntr_id = f8
     2 time_zone_indx = i4
     2 time_zone = vc
     2 transaction_dt_tm = dq8
     2 check = i2
     2 status = i2
     2 loc_fac_cd = f8
   1 facilities_qual_cnt = i4
   1 facilities[*]
     2 loc_facility_cd = f8
     2 time_zone_indx = i4
     2 time_zone = vc
     2 status = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(treq->encntrs,1)
 SET treq->encntrs[1].encntr_id = request->visit[1].encntr_id
 EXECUTE pm_get_encntr_loc_tz  WITH replace("REQUEST","TREQ"), replace("REPLY","TREP")
 FREE RECORD treq
 IF ((trep->status_data.status != "F"))
  IF (size(trep->encntrs,5) > 0)
   IF ((trep->encntrs[1].status=1))
    SET reg_tz = trep->encntrs[1].time_zone_indx
   ELSE
    SET reg_tz = curtimezoneapp
   ENDIF
  ELSE
   SET reg_tz = curtimezoneapp
  ENDIF
 ELSE
  CALL echo("***")
  CALL echo("***   Failed to find patient timezone")
  CALL echo("***")
  FREE RECORD trep
  GO TO exit_script
 ENDIF
 FREE RECORD trep
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   (dummyt d1  WITH seq = 1),
   encntr_alias ea,
   (dummyt d3  WITH seq = 1),
   encntr_prsnl_reltn epr,
   prsnl pl
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd IN (fnbr_cd, encntr_mrn_cd)
    AND ea.active_ind=1)
   JOIN (d3)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attenddoc_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  DETAIL
   person_id = e.person_id, facility_cd = e.loc_facility_cd, name = cnvtupper(p.name_full_formatted),
   sex = uar_get_code_display(p.sex_cd), unit = uar_get_code_display(e.loc_nurse_unit_cd), room =
   uar_get_code_display(e.loc_room_cd),
   bed = uar_get_code_display(e.loc_bed_cd), location = concat(trim(unit),"/",trim(room),"/",trim(bed
     )), admit_date = datetimezoneformat(e.reg_dt_tm,reg_tz,"@SHORTDATE"),
   dob = datetimezoneformat(p.birth_dt_tm,p.birth_tz,"@SHORTDATE"), age = cnvtage(cnvtdate(p
     .birth_dt_tm),curdate)
   IF (ea.encntr_alias_type_cd=fnbr_cd)
    fnbr = cnvtalias(ea.alias,ea.alias_pool_cd)
   ELSEIF (ea.encntr_alias_type_cd=encntr_mrn_cd)
    mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
   ENDIF
   attenddoc = pl.name_full_formatted
  WITH nocounter, outerjoin = d1, dontcare = ea,
   outerjoin = d3, dontcare = epr
 ;end select
 IF (mrn <= " ")
  SELECT INTO "nl"
   FROM person_alias pa
   WHERE pa.person_id=person_id
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
   ORDER BY pa.beg_effective_dt_tm DESC
   HEAD REPORT
    mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
   WITH nocounter
  ;end select
 ENDIF
 SET modify = nopredeclare
 SET gve_request->prsnl_id = reqinfo->updt_id
 SET stat = alterlist(gve_request->persons,1)
 SET gve_request->persons[1].person_id = person_id
 SET gve_request->force_encntrs_ind = 1
 EXECUTE dcp_get_valid_encounters  WITH replace(request,gve_request), replace(reply,gve_reply)
 SET modify = predeclare
 IF (size(gve_reply->persons,5)=0)
  SET error_cd = 2
  GO TO report_failed
 ENDIF
 SET reply_cnt = size(gve_reply->persons[1].encntrs,5)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(reply_cnt)),
   diagnosis a,
   prsnl p,
   (dummyt d2  WITH seq = 1),
   nomenclature n
  PLAN (d1)
   JOIN (a
   WHERE (a.encntr_id=gve_reply->persons[1].encntrs[d1.seq].encntr_id))
   JOIN (p
   WHERE p.person_id=a.active_status_prsnl_id)
   JOIN (d2)
   JOIN (n
   WHERE n.nomenclature_id=a.nomenclature_id)
  ORDER BY cnvtdatetime(a.diag_dt_tm)
  HEAD REPORT
   temp->cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (a.diag_ftdesc > " ")) )
    temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].
    diagnosis = a.diag_ftdesc
    IF (n.source_string > " ")
     temp->qual[temp->cnt].diagnosis = n.source_string
    ENDIF
    temp->qual[temp->cnt].diag_dt = datetimezoneformat(a.diag_dt_tm,curtimezoneapp,"@SHORTDATE"),
    temp->qual[temp->cnt].category = uar_get_code_display(a.diagnostic_category_cd), temp->qual[temp
    ->cnt].priority = a.diag_priority,
    temp->qual[temp->cnt].diag_type = uar_get_code_display(a.diag_type_cd), temp->qual[temp->cnt].
    class = uar_get_code_display(a.diag_class_cd), temp->qual[temp->cnt].active_status =
    uar_get_code_display(a.active_status_cd),
    temp->qual[temp->cnt].documented_by = p.name_full_formatted
   ENDIF
  WITH nocounter, outerjoin = d2, dontcare = n
 ;end select
 FOR (y = 1 TO temp->cnt)
   SET pt->line_cnt = 0
   SET max_length = 50
   SET modify = nopredeclare
   EXECUTE dcp_parse_text value(temp->qual[y].diagnosis), value(max_length)
   SET modify = predeclare
   SET stat = alterlist(temp->qual[y].diag_qual,pt->line_cnt)
   SET temp->qual[y].diag_cnt = pt->line_cnt
   FOR (x = 1 TO pt->line_cnt)
     SET temp->qual[y].diag_qual[x].diag_line = pt->lns[x].line
   ENDFOR
 ENDFOR
 SELECT INTO request->output_device
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   label_ind = 0
  HEAD PAGE
   "{ps/792 0 translate 90 rotate/}", row + 1, "{f/12}{cpi/10}{pos/335/40}{b}DIAGNOSIS",
   row + 1, "{f/8}{cpi/14}", row + 1,
   "{pos/25/66}{b}Patient Name: {endb}", name, row + 1,
   "{pos/25/76}{b}Med Rec #: {endb}", mrn, row + 1,
   "{pos/25/86}{b}Financial #: {endb}", fnbr, row + 1,
   "{pos/25/96}{b}Attending Physician: {endb}", attenddoc, row + 1,
   "{pos/520/66}{b}DOB: {endb}", dob, row + 1,
   "{pos/620/66}{b}Age: {endb}", age, row + 1,
   "{pos/520/76}{b}Gender: {endb}", sex, row + 1,
   "{pos/520/86}{b}Admission Date: {endb}", admit_date, row + 1,
   "{pos/520/96}{b}Location: {endb}", location, row + 1,
   ycol = 125
   IF (label_ind=1)
    xcol = 25,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Diagnosis",
    row + 1, xcol = 320,
    CALL print(calcpos(xcol,ycol)),
    "{b}{u}Status", row + 1, xcol = 370,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Diagnosis Date", row + 1,
    xcol = 450,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Documented by",
    row + 1, ycol = (ycol+ 12)
   ENDIF
  DETAIL
   IF ((temp->cnt > 0))
    label_ind = 1, xcol = 25,
    CALL print(calcpos(xcol,ycol)),
    "{cpi/12}{b}DIAGNOSES", row + 1, "{cpi/14}",
    row + 1, ycol = (ycol+ 20), xcol = 25,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Diagnosis", row + 1,
    xcol = 320,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Status",
    row + 1, xcol = 370,
    CALL print(calcpos(xcol,ycol)),
    "{b}{u}Diagnosis Date", row + 1, xcol = 450,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Documented by", row + 1,
    ycol = (ycol+ 12)
   ENDIF
   FOR (x = 1 TO temp->cnt)
     xcol = 25, start_col = ycol, end_col = ycol
     FOR (y = 1 TO temp->qual[x].diag_cnt)
       CALL print(calcpos(xcol,ycol)), temp->qual[x].diag_qual[y].diag_line, row + 1,
       ycol = (ycol+ 10), endcol = ycol
     ENDFOR
     ycol = start_col, xcol = 320,
     CALL print(calcpos(xcol,ycol)),
     temp->qual[x].active_status, row + 1, xcol = 370,
     CALL print(calcpos(xcol,ycol)), temp->qual[x].diag_dt, row + 1,
     xcol = 450,
     CALL print(calcpos(xcol,ycol)), temp->qual[x].documented_by,
     row + 1
     IF ((temp->qual[x].diag_cnt > 1))
      ycol = (endcol+ 5)
     ELSE
      ycol = (ycol+ 15)
     ENDIF
     IF ((x != temp->cnt)
      AND ycol > 450)
      BREAK
     ENDIF
   ENDFOR
  FOOT PAGE
   "{pos/60/520}{b}Page ", curpage"##", row + 1,
   "{pos/335/520}{b}Print Date/Time: ", curdate, " ",
   curtime, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 800
 ;end select
 GO TO exit_script
#report_failed
 SELECT INTO request->output_device
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   label_ind = 0
  HEAD PAGE
   "{ps/792 0 translate 90 rotate/}", row + 1, "{f/12}{cpi/10}{pos/335/40}{b}DIAGNOSIS",
   row + 1, "{f/8}{cpi/14}", row + 1
   IF (error_cd=1)
    "{pos/25/66}Report Failed: Invalid encounter Id used (", request->visit[1].encntr_id, ").",
    row + 1
   ELSEIF (error_cd=2)
    "{pos/25/66}Org security: No encounters qualified for data display.", row + 1
   ELSE
    "{pos/25/66}Unkown error occured.", row + 1
   ENDIF
  FOOT PAGE
   "{pos/60/520}{b}Page ", curpage"##", row + 1,
   "{pos/335/520}{b}Print Date/Time: ", printed_date, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 800
 ;end select
#exit_script
 FREE RECORD gve_reply
 FREE RECORD gve_request
END GO
