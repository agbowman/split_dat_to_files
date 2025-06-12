CREATE PROGRAM dcpordsheet:dba
 RECORD request(
   1 printer_id = f8
   1 printer_name = vc
   1 order_cnt = i4
   1 order_list[10]
     2 order_id = f8
 )
 SET request->printer_name = "MINE"
 SET request->order_cnt = 10
 SET request->order_list[1].order_id = 2479
 SET request->order_list[2].order_id = 2479
 SET request->order_list[3].order_id = 652300
 SET request->order_list[4].order_id = 354262
 SET request->order_list[5].order_id = 652298
 SET request->order_list[6].order_id = 652300
 SET request->order_list[7].order_id = 354262
 SET request->order_list[8].order_id = 652298
 SET request->order_list[9].order_id = 652300
 SET request->order_list[10].order_id = 354262
 SET mrn_alias_cd = 0.0
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET stat = alterlist(request->order_list,request->order_cnt)
 SET desc_list[10] = fillstring(100," ")
 SET description[10] = fillstring(15," ")
 SET order_list[10] = fillstring(100," ")
 SET order1[10] = fillstring(100," ")
 SET action_list[10] = fillstring(100," ")
 SET action[10] = fillstring(10," ")
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admit_doc_cd = code_value
 FOR (x = 1 TO request->order_cnt)
   SELECT INTO "NL:"
    oc.description, o.order_detail_display_line, cva.display
    FROM order_catalog oc,
     code_value cva,
     order_action oa,
     orders o
    WHERE (o.order_id=request->order_list[x].order_id)
     AND oc.catalog_cd=o.catalog_cd
     AND oa.order_id=o.order_id
     AND cva.code_value=oa.action_type_cd
    DETAIL
     desc_list[x] = oc.description, order_list[x] = o.order_detail_display_line, action_list[x] = cva
     .display
   ;end select
 ENDFOR
 SELECT INTO request->printer_name
  p.name_full_formatted, p.birth_dt_tm, o.orig_order_dt_tm,
  o.order_mnemonic, oa.action_dt_tm, oa.action_personnel_id,
  oa.order_provider_id, pl.name_full_formatted, pl2.name_full_formatted,
  pl3.name_full_formatted, pl4.name_full_formatted, pa.alias,
  epr.prsnl_person_id, epr.encntr_prsnl_r_cd, cvr.display,
  cvb.display, cvd.display, cvl.display
  FROM orders o,
   person p,
   prsnl pl,
   (dummyt d1  WITH seq = 1),
   person_alias pa,
   prsnl pl2,
   encounter e,
   encntr_prsnl_reltn epr,
   prsnl pl3,
   prsnl pl4,
   order_action oa,
   code_value cvr,
   code_value cvb,
   code_value cvd,
   code_value cvl
  PLAN (o
   WHERE (o.order_id=request->order_list[1].order_id))
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (pl
   WHERE pl.person_id=o.last_update_provider_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=admit_doc_cd)
   JOIN (oa
   WHERE oa.order_id=o.order_id)
   JOIN (pl2
   WHERE pl2.person_id=epr.prsnl_person_id)
   JOIN (pl3
   WHERE pl3.person_id=oa.action_personnel_id)
   JOIN (pl4
   WHERE pl4.person_id=oa.order_provider_id)
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=o.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pa.active_ind=1)
   JOIN (cvr
   WHERE cvr.code_value=e.loc_room_cd)
   JOIN (cvb
   WHERE cvb.code_value=e.loc_bed_cd)
   JOIN (cvd
   WHERE cvd.code_value=pl.department_cd)
   JOIN (cvl
   WHERE cvl.code_value=e.location_cd)
  HEAD REPORT
   patientname = substring(1,50,p.name_full_formatted), persname = substring(1,50,pl
    .name_full_formatted), mrnumber = substring(1,50,pa.alias),
   persname2 = substring(1,35,pl2.name_full_formatted), room = substring(1,5,cvr.display), department
    = substring(1,20,cvd.display),
   entered = substring(1,50,pl3.name_full_formatted), orderingdr = substring(1,50,pl4
    .name_full_formatted), nurse = substring(1,50,cvl.display),
   row + 2,
   CALL center("MMC ORDER SHEET",1,130), row + 2,
   col 2, "PATIENT NAME: ", patientname,
   col 65, "MED NBR: ", mrnumber,
   col 105, "DOB: ", p.birth_dt_tm,
   row + 1, col 2, "RM/BED: ",
   room, "/", cvb.display,
   col 35, "ADM DATE: ", o.orig_order_dt_tm,
   col 65, "ADMITTING PHYSICIAN: ", persname2,
   row + 1, col 2, "NURSE STATION: ",
   nurse, row + 1, col 2,
   "ENTRY DATE/TIME: ", oa.action_dt_tm"mm/dd/yyyy hh:mm:ss;;q", row + 1,
   col 2, "ENTERED BY: ", entered,
   col 85, "DEPARTMENT: ", department,
   row + 1, col 2, "ORDERING OR: ",
   orderingdr, row + 1
   FOR (x = 1 TO request->order_cnt)
     action[x] = substring(1,1,action_list[x]), description[x] = substring(1,15,desc_list[x]), order1
     [x] = substring(1,80,order_list[x]),
     row + 1, col 2, action[x],
     col 5, description[x], col 25,
     order1[x], row + 1
   ENDFOR
  DETAIL
   row + 0
  WITH nocounter, outerjoin = d1, dontcare = cvr,
   dontcare = cvb, dontcare = e
 ;end select
END GO
