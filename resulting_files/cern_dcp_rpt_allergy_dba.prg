CREATE PROGRAM cern_dcp_rpt_allergy:dba
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 allergy = c20
     2 reaction_class = c14
     2 reaction = c55
     2 severity = c8
     2 reaction_status = c15
     2 onset_date = c10
     2 doc = vc
 )
 DECLARE name = vc
 DECLARE mrn = vc
 DECLARE fnbr = vc
 DECLARE attenddoc = vc
 DECLARE dob = vc
 DECLARE age = vc
 DECLARE sex = vc
 DECLARE admit_date = vc
 DECLARE unit = vc
 DECLARE room = vc
 DECLARE bed = vc
 DECLARE location = vc
 DECLARE person_id = f8
 DECLARE code_value = f8
 DECLARE code_set = f8
 DECLARE cdf_meaning = vc
 SET name = fillstring(50," ")
 SET mrn = fillstring(50," ")
 SET fnbr = fillstring(50," ")
 SET attenddoc = fillstring(50," ")
 SET dob = fillstring(50," ")
 SET age = fillstring(50," ")
 SET sex = fillstring(50," ")
 SET admit_date = fillstring(50," ")
 SET unit = fillstring(50," ")
 SET room = fillstring(50," ")
 SET bed = fillstring(50," ")
 SET location = fillstring(50," ")
 SET person_id = 0
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 DECLARE reg_tz = i4
 DECLARE printed_date = vc WITH constant(datetimezoneformat(cnvtdatetime(curdate,curtime3),
   curtimezoneapp,"MM/DD/YY HH:mm ZZZ"))
 SET code_set = 12025
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET fnbr_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attenddoc_cd = code_value
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
   encntr_alias ea2,
   (dummyt d2  WITH seq = 1),
   encntr_alias ea,
   (dummyt d3  WITH seq = 1),
   encntr_prsnl_reltn epr,
   prsnl pl
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=mrn_cd
    AND ea2.active_ind=1)
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=fnbr_cd
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
     .birth_dt_tm),curdate), mrn = cnvtalias(ea2.alias,ea2.alias_pool_cd),
   fnbr = cnvtalias(ea.alias,ea.alias_pool_cd), attenddoc = pl.name_full_formatted
  WITH nocounter, outerjoin = d1, dontcare = ea2,
   outerjoin = d2, dontcare = ea, outerjoin = d3,
   dontcare = epr
 ;end select
 SELECT INTO "nl:"
  FROM allergy a,
   prsnl p,
   (dummyt d1  WITH seq = 1),
   nomenclature n,
   (dummyt d2  WITH seq = 1),
   reaction r,
   (dummyt d3  WITH seq = 1),
   nomenclature n2
  PLAN (a
   WHERE a.person_id=person_id
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != canceled_cd)
   JOIN (p
   WHERE p.person_id=a.created_prsnl_id)
   JOIN (d1)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
   JOIN (d2)
   JOIN (r
   WHERE r.allergy_id=a.allergy_id
    AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (r.end_effective_dt_tm=null))
    AND r.active_ind=1)
   JOIN (d3)
   JOIN (n2
   WHERE n2.nomenclature_id=r.reaction_nom_id)
  ORDER BY a.allergy_id, cnvtdatetime(a.onset_dt_tm)
  HEAD REPORT
   temp->cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (a.substance_ftdesc > " ")) )
    temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].allergy
     = a.substance_ftdesc
    IF (n.source_string > " ")
     temp->qual[temp->cnt].allergy = n.source_string
    ENDIF
    IF (((r.reaction_ftdesc > " ") OR (n2.source_string > " ")) )
     temp->qual[temp->cnt].reaction = r.reaction_ftdesc
     IF (n2.source_string > " ")
      temp->qual[temp->cnt].reaction = n2.source_string
     ENDIF
    ENDIF
    temp->qual[temp->cnt].reaction_class = uar_get_code_display(a.reaction_class_cd), temp->qual[temp
    ->cnt].severity = uar_get_code_display(a.severity_cd), temp->qual[temp->cnt].reaction_status =
    uar_get_code_display(a.reaction_status_cd)
    IF (a.onset_tz > 0)
     temp->qual[temp->cnt].onset_date = datetimezoneformat(a.onset_dt_tm,a.onset_tz,"@SHORTDATE")
    ELSE
     temp->qual[temp->cnt].onset_date = datetimezoneformat(a.onset_dt_tm,curtimezoneapp,"@SHORTDATE")
    ENDIF
    temp->qual[temp->cnt].doc = p.name_full_formatted
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   outerjoin = d3
 ;end select
 SELECT INTO request->output_device
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   label_ind = 0
  HEAD PAGE
   "{ps/792 0 translate 90 rotate/}", row + 1, "{f/8}{cpi/14}",
   row + 1, "{pos/25/66}{b}Patient Name: ", name,
   row + 1, "{pos/25/76}{b}Med Rec #: ", mrn,
   row + 1, "{pos/25/86}{b}Financial #: {endb}", fnbr,
   row + 1, "{pos/25/96}{b}Attending Physician: {endb}", attenddoc,
   row + 1, "{pos/520/66}{b}DOB: {endb}", dob,
   row + 1, "{pos/620/66}{b}Age: {endb}", age,
   row + 1, "{pos/520/76}{b}Gender: {endb}", sex,
   row + 1, "{pos/520/86}{b}Admission Date: {endb}", admit_date,
   row + 1, "{pos/520/96}{b}Location: {endb}", location,
   row + 1, ycol = 125
   IF (label_ind=1)
    xcol = 25,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Allergy",
    row + 1, xcol = 130,
    CALL print(calcpos(xcol,ycol)),
    "{b}{u}Reaction Class", row + 1, xcol = 200,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Reaction", row + 1,
    xcol = 445,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Severity",
    row + 1, xcol = 490,
    CALL print(calcpos(xcol,ycol)),
    "{b}{u}Reaction Status", row + 1, xcol = 560,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Onset Date", row + 1,
    xcol = 620,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Documented by",
    row + 1, ycol = (ycol+ 12)
   ENDIF
  DETAIL
   IF ((temp->cnt > 0))
    label_ind = 1, xcol = 25,
    CALL print(calcpos(xcol,ycol)),
    "{cpi/12}{b}ACTIVE ALLERGIES", row + 1, "{cpi/14}",
    row + 1, ycol = (ycol+ 20), xcol = 25,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Allergy", row + 1,
    xcol = 130,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Reaction Class",
    row + 1, xcol = 200,
    CALL print(calcpos(xcol,ycol)),
    "{b}{u}Reaction", row + 1, xcol = 445,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Severity", row + 1,
    xcol = 490,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Reaction Status",
    row + 1, xcol = 560,
    CALL print(calcpos(xcol,ycol)),
    "{b}{u}Onset Date", row + 1, xcol = 620,
    CALL print(calcpos(xcol,ycol)), "{b}{u}Documented by", row + 1,
    ycol = (ycol+ 12)
   ENDIF
   FOR (x = 1 TO temp->cnt)
     xcol = 25,
     CALL print(calcpos(xcol,ycol)), temp->qual[x].allergy,
     row + 1, xcol = 130,
     CALL print(calcpos(xcol,ycol)),
     temp->qual[x].reaction_class, row + 1, xcol = 200,
     CALL print(calcpos(xcol,ycol)), temp->qual[x].reaction, row + 1,
     xcol = 445,
     CALL print(calcpos(xcol,ycol)), temp->qual[x].severity,
     row + 1, xcol = 490,
     CALL print(calcpos(xcol,ycol)),
     temp->qual[x].reaction_status, row + 1, xcol = 560,
     CALL print(calcpos(xcol,ycol)), temp->qual[x].onset_date, row + 1,
     xcol = 620,
     CALL print(calcpos(xcol,ycol)), temp->qual[x].doc,
     row + 1, ycol = (ycol+ 15)
     IF (ycol > 450)
      BREAK
     ENDIF
   ENDFOR
  FOOT PAGE
   "{pos/60/520}{b}Page ", curpage"##", row + 1,
   "{pos/335/520}{b}Print Date/Time: ", printed_date, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 800
 ;end select
#exit_script
END GO
