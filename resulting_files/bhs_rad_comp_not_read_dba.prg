CREATE PROGRAM bhs_rad_comp_not_read:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Location:" = 0,
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, mf_location, md_startdate,
  md_enddate
 FREE RECORD rec_str
 RECORD rec_str(
   1 location[*]
     2 s_complete_locn_disp = vc
     2 person[*]
       3 s_name_full_formatted = vc
       3 orders[*]
         4 ml_ord_cnt = i4
         4 f_encntr_id = f8
         4 s_mrn = vc
         4 s_complete_dt_tm = vc
         4 s_accession = vc
         4 s_o_catalog_disp = vc
         4 s_o_exam_status_disp = vc
         4 s_o_report_status_disp = vc
 ) WITH protect
 FREE RECORD facility
 RECORD facility(
   1 facility[*]
     2 f_facility_cd = f8
 ) WITH protect
 FREE RECORD ord_cat
 RECORD ord_cat(
   1 catalog[*]
     2 s_orderable = vc
     2 f_catalog_cd = f8
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 DECLARE mf_final_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14202,"FINAL"))
 DECLARE mf_addendum_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14202,"ADDENDUM"))
 DECLARE mf_na_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14202,"NA"))
 DECLARE mf_transcribed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14202,
   "TRANSCRIBED"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE ms_location_var = vc WITH protect, noconstant("")
 DECLARE ml_cat_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_fac_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loc_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pat_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_exp_fac_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_exp_cat_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_exp_mrn_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
 SET ml_exp_mrn_cnt = 0
 SELECT
  IF (cnvtint( $MF_LOCATION)=0)
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="FACILITY"
     AND cv.display_key IN ("BMC", "BMLH", "BRI", "BWH", "BNH",
    "BFMC"))
  ELSE
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="FACILITY"
     AND (cv.code_value= $MF_LOCATION))
  ENDIF
  INTO "nl:"
  FROM code_value cv
  ORDER BY cv.display
  HEAD REPORT
   ml_fac_cnt = 0
  HEAD cv.code_value
   ml_fac_cnt += 1, stat = alterlist(facility->facility,ml_fac_cnt), facility->facility[ml_fac_cnt].
   f_facility_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=200
    AND cv.display_key IN ("CTOUTSIDEFILMCONSULT", "CTOUTSIDEIMAGES", "OUTSIDEIMAGESMM",
   "OUTSIDEIMAGESMRI", "OUTSIDEIMAGESUS",
   "XROUTSIDEIMAGESDIAGRAD", "MRIOUTSIDEFILMCONSULT", "USOUTSIDEFILMCONSULT", "TCCHEST1VIEW"))
  ORDER BY cv.display
  HEAD REPORT
   ml_cat_cnt = 0
  HEAD cv.code_value
   ml_cat_cnt += 1, stat = alterlist(ord_cat->catalog,ml_cat_cnt), ord_cat->catalog[ml_cat_cnt].
   s_orderable = cv.display,
   ord_cat->catalog[ml_cat_cnt].f_catalog_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_radiology o,
   exam_data e,
   person p,
   encounter en
  PLAN (o
   WHERE  NOT (o.report_status_cd IN (cnvtreal(mf_final_cd), cnvtreal(mf_addendum_cd), cnvtreal(
    mf_na_cd), cnvtreal(mf_transcribed_cd)))
    AND o.complete_dt_tm BETWEEN cnvtdatetime( $MD_STARTDATE) AND cnvtdatetime(concat( $MD_ENDDATE,
     char(32),"23:59:59"))
    AND  NOT (expand(ml_exp_cat_cnt,1,ml_cat_cnt,o.catalog_cd,ord_cat->catalog[ml_exp_cat_cnt].
    f_catalog_cd)))
   JOIN (e
   WHERE e.order_id=o.order_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (en
   WHERE en.encntr_id=o.encntr_id
    AND expand(ml_exp_fac_cnt,1,ml_fac_cnt,en.loc_facility_cd,facility->facility[ml_exp_fac_cnt].
    f_facility_cd))
  ORDER BY en.loc_facility_cd, p.person_id, o.order_id
  HEAD REPORT
   ml_loc_cnt = 0, ml_pat_cnt = 0, ml_ord_cnt = 0
  HEAD en.loc_facility_cd
   ml_loc_cnt += 1, ml_pat_cnt = 0, ml_ord_cnt = 0,
   stat = alterlist(rec_str->location,ml_loc_cnt), rec_str->location[ml_loc_cnt].s_complete_locn_disp
    = uar_get_code_display(en.loc_facility_cd), ms_location_var = uar_get_code_display(en
    .loc_facility_cd)
  HEAD p.person_id
   ml_pat_cnt += 1, ml_ord_cnt = 0, stat = alterlist(rec_str->location[ml_loc_cnt].person,ml_pat_cnt),
   rec_str->location[ml_loc_cnt].person[ml_pat_cnt].s_name_full_formatted = p.name_full_formatted
  HEAD o.order_id
   ml_ord_cnt += 1, stat = alterlist(rec_str->location[ml_loc_cnt].person[ml_pat_cnt].orders,
    ml_ord_cnt), rec_str->location[ml_loc_cnt].person[ml_pat_cnt].orders[ml_ord_cnt].ml_ord_cnt =
   ml_ord_cnt,
   rec_str->location[ml_loc_cnt].person[ml_pat_cnt].orders[ml_ord_cnt].f_encntr_id = e.encntr_id,
   rec_str->location[ml_loc_cnt].person[ml_pat_cnt].orders[ml_ord_cnt].s_complete_dt_tm = format(o
    .complete_dt_tm,"MM/DD/YYYY HH:MM:SS"), rec_str->location[ml_loc_cnt].person[ml_pat_cnt].orders[
   ml_ord_cnt].s_o_catalog_disp = uar_get_code_display(o.catalog_cd),
   rec_str->location[ml_loc_cnt].person[ml_pat_cnt].orders[ml_ord_cnt].s_accession = o.accession,
   rec_str->location[ml_loc_cnt].person[ml_pat_cnt].orders[ml_ord_cnt].s_o_exam_status_disp =
   uar_get_code_display(o.exam_status_cd), rec_str->location[ml_loc_cnt].person[ml_pat_cnt].orders[
   ml_ord_cnt].s_o_report_status_disp = uar_get_code_display(o.report_status_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(rec_str->location,5))),
   dummyt d2,
   dummyt d3,
   encntr_alias ea
  PLAN (d1
   WHERE maxrec(d2,size(rec_str->location[d1.seq].person,5)))
   JOIN (d2
   WHERE maxrec(d3,size(rec_str->location[d1.seq].person[d2.seq].orders,5)))
   JOIN (d3)
   JOIN (ea
   WHERE (ea.encntr_id=rec_str->location[d1.seq].person[d2.seq].orders[d3.seq].f_encntr_id)
    AND ea.encntr_alias_type_cd=mf_mrn_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   rec_str->location[d1.seq].person[d2.seq].orders[d3.seq].s_mrn = ea.alias
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  location = trim(substring(1,100,rec_str->location[d1.seq].s_complete_locn_disp),3), patient_name =
  trim(substring(1,150,rec_str->location[d1.seq].person[d2.seq].s_name_full_formatted),3),
  order_accession = trim(substring(1,30,rec_str->location[d1.seq].person[d2.seq].orders[d3.seq].
    s_accession),3),
  order_catalog = trim(substring(1,30,rec_str->location[d1.seq].person[d2.seq].orders[d3.seq].
    s_o_catalog_disp),3), order_complete_dt = trim(substring(1,30,rec_str->location[d1.seq].person[d2
    .seq].orders[d3.seq].s_complete_dt_tm),3)
  FROM (dummyt d1  WITH seq = value(size(rec_str->location,5))),
   dummyt d2,
   dummyt d3
  PLAN (d1
   WHERE maxrec(d2,size(rec_str->location[d1.seq].person,5)))
   JOIN (d2
   WHERE maxrec(d3,size(rec_str->location[d1.seq].person[d2.seq].orders,5)))
   JOIN (d3)
  ORDER BY order_complete_dt, location, patient_name
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
END GO
