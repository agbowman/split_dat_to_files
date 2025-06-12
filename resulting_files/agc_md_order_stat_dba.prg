CREATE PROGRAM agc_md_order_stat:dba
 PROMPT
  "Enter print option (file/printer/MINE): " = "MINE",
  "Enter Start Date (mmddyyyy): " = "01012003",
  "Enter End Date (mmddyyyy): " = "09052003"
 EXECUTE cclseclogin
 DECLARE esi_default = f8
 SET esi_default = 0.0
 SET stat = uar_get_meaning_by_codeset(6006,"ESIDEFAULT",1,esi_default)
 DECLARE mrn_var = f8
 SET mrn_var = 0.0
 SET mrnvar = uar_get_meaning_by_codeset(4,"MRN",1,mrn_var)
 DECLARE fin_var = f8
 SET fin_var = 0.0
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_var)
 DECLARE home_address_type = f8
 SET home_address_type = 0.0
 SET stat = uar_get_meaning_by_codeset(212,"HOME",1,home_address_type)
 DECLARE home_phone_type = f8
 SET home_phone_type = 0.0
 SET stat = uar_get_meaning_by_codeset(43,"HOME",1,home_phone_type)
 DECLARE phone_format = f8
 SET phone_format = 0.0
 SET stat = uar_get_meaning_by_codeset(281,"US",1,phone_format)
 DECLARE action_order = f8
 SET action_order = 0.0
 SET stat = uar_get_meaning_by_codeset(6003,"ORDER",1,action_order)
 DECLARE action_cancel = f8
 SET action_cancel = 0.0
 SET stat = uar_get_meaning_by_codeset(6003,"CANCEL",1,action_cancel)
 DECLARE order_status_cancel = f8
 SET order_status_cancel = 0.0
 SET stat = uar_get_meaning_by_codeset(6004,"CANCELED",1,order_status_cancel)
 DECLARE order_status_deleted = f8
 SET order_status_deleted = 0.0
 SET stat = uar_get_meaning_by_codeset(6004,"DELETED",1,order_status_deleted)
 DECLARE catalog_type_pharm = f8
 SET catalog_type_pharm = 0.0
 SET stat = uar_get_meaning_by_codeset(6000,"PHARMACY",1,catalog_type_pharm)
 DECLARE deceased_exp = f8
 SET deceased_exp = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=268
   AND cv.display_key="EXPIRED"
  DETAIL
   deceased_exp = cv.code_value
  WITH noformat
 ;end select
 DECLARE attend_doc = f8
 SET attend_doc = 0.0
 SET stat = uar_get_meaning_by_codeset(333,"ATTENDDOC",1,attend_doc)
 SET printer =  $1
 SET startdate = cnvtdate( $2)
 SET enddate = cnvtdate( $3)
 FREE RECORD comm
 RECORD comm(
   1 qual = i4
   1 list[*]
     2 code_value = f8
     2 disp = c20
     2 print_order = i4
 )
 SELECT INTO "nl:"
  cv.code_value, cv.display_key, cv.display
  FROM code_value cv
  WHERE cv.code_set=6006
   AND cv.code_value != esi_default
   AND cv.active_ind=1
  ORDER BY cv.display
  HEAD REPORT
   cnt = 0, po = 0
  HEAD cv.display
   cnt = (cnt+ 1), po = (po+ 1), stat = alterlist(comm->list,cnt),
   comm->list[cnt].code_value = cv.code_value, comm->list[cnt].disp = cv.display, comm->list[cnt].
   print_order = po
  DETAIL
   x = 0
  FOOT REPORT
   comm->qual = cnt
  WITH nocounter
 ;end select
 FREE RECORD etc
 RECORD etc(
   1 qual = i4
   1 list[*]
     2 code_value = f8
     2 disp = c20
 )
 SELECT INTO "nl:"
  cv.code_value, cv.display_key
  FROM code_value cv
  WHERE cv.code_set=71
   AND cv.display_key IN ("INPATIENT", "DAYSTAY", "OBSERVATION", "DISCHIP", "DISCHDAYSTAY",
  "DISCHOBV", "EXPIREDIP", "EXPIREDOBV")
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(etc->list,cnt), etc->list[cnt].code_value = cv.code_value,
   etc->list[cnt].disp = substring(1,20,cv.display), row + 1
  FOOT REPORT
   etc->qual = cnt
  WITH nocounter
 ;end select
 FREE RECORD pats
 RECORD pats(
   1 qual = i4
   1 list[*]
     2 person_id = f8
     2 encntr_id = f8
 )
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(etc->qual)),
   encntr_loc_hist elh,
   encounter e,
   person p
  PLAN (d)
   JOIN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime(startdate,0) AND cnvtdatetime(enddate,2359)
    AND e.active_ind=1)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.beg_effective_dt_tm BETWEEN cnvtdatetime(startdate,0) AND cnvtdatetime(enddate,2359)
    AND (elh.encntr_type_cd=etc->list[d.seq].code_value))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e.encntr_id
  HEAD REPORT
   cnt = 0
  HEAD e.encntr_id
   cnt = (cnt+ 1), stat = alterlist(pats->list,cnt), pats->list[cnt].encntr_id = e.encntr_id,
   pats->list[cnt].person_id = p.person_id
  DETAIL
   x = 0
  FOOT REPORT
   pats->qual = cnt
  WITH check
 ;end select
 FREE RECORD phys
 RECORD phys(
   1 qual = i4
   1 list[*]
     2 order_id = f8
     2 phys_id = f8
     2 position_cd = f8
     2 facility_cd = f8
     2 comm_type_cd = f8
     2 cat_type = i2
 )
 SELECT
  o.order_id, facility = uar_get_code_display(e.loc_facility_cd), position_prsnl =
  uar_get_code_display(pl.position_cd),
  ord_prsnl = oa.action_personnel_id, ord_prsnl_name = substring(1,30,pl.name_full_formatted),
  catalog_type = uar_get_code_display(o.catalog_type_cd),
  catalog = uar_get_code_display(o.catalog_cd), communication_type = uar_get_code_display(oa
   .communication_type_cd), activity_type = uar_get_code_display(o.activity_type_cd),
  action_type = uar_get_code_display(oa.action_type_cd), order_status = uar_get_code_display(o
   .order_status_cd), order_dt_tm = format(oa.order_dt_tm,"mm/dd/yy hh:mm;;q")
  FROM (dummyt d1  WITH seq = value(comm->qual)),
   (dummyt d  WITH seq = value(pats->qual)),
   orders o,
   order_action oa,
   prsnl pl,
   encounter e
  PLAN (d)
   JOIN (o
   WHERE (o.person_id=pats->list[d.seq].person_id)
    AND (o.encntr_id=pats->list[d.seq].encntr_id)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(startdate,0) AND cnvtdatetime(enddate,2359)
    AND o.order_status_cd != order_status_cancel
    AND o.order_status_cd != order_status_deleted)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=action_order
    AND oa.order_provider_id > 1.0
    AND oa.communication_type_cd != esi_default)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (d1
   WHERE (comm->list[d1.seq].code_value=oa.communication_type_cd))
   JOIN (pl
   WHERE pl.person_id=oa.order_provider_id)
  ORDER BY o.order_id
  HEAD REPORT
   cnt = 0, col 0, "phys_id",
   col 40, "position_cd", col 80,
   "order_id", col 100, "facility_cd",
   col 150, "comm_type_cd", col 200,
   "cat_type", row + 1
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(phys->list,cnt), phys->list[cnt].phys_id = ord_prsnl,
   phys->list[cnt].position_cd = pl.position_cd, phys->list[cnt].order_id = o.order_id, phys->list[
   cnt].facility_cd = e.loc_facility_cd,
   phys->list[cnt].comm_type_cd = oa.communication_type_cd
   IF (o.catalog_type_cd=catalog_type_pharm)
    phys->list[cnt].cat_type = 1
   ELSE
    phys->list[cnt].cat_type = 0
   ENDIF
   col 0, phys->list[cnt].phys_id, col 40,
   phys->list[cnt].position_cd, col 80, phys->list[cnt].order_id,
   col 100, phys->list[cnt].facility_cd, col 150,
   phys->list[cnt].comm_type_cd, col 200, phys->list[cnt].cat_type,
   row + 1
  FOOT REPORT
   phys->qual = cnt
  WITH check, maxcol = 2000
 ;end select
 FREE RECORD sats
 RECORD stats(
   1 fac_qual = i4
   1 fac_list[*]
     2 facility_cd = f8
     2 pos_qual = i4
     2 pos_list[*]
       3 position_cd = f8
       3 phys_qual = i4
       3 phys_list[*]
         4 phys_id = f8
         4 order_qual = i4
         4 order_list[2]
           5 comm_type = f8
           5 comm_count = i4
           5 print_order = i4
 )
 SELECT INTO "nl:"
  order_id = phys->list[d.seq].order_id, facility_cd = phys->list[d.seq].facility_cd, facility_disp
   = uar_get_code_display(phys->list[d.seq].facility_cd),
  position_cd = phys->list[d.seq].position_cd, position_disp = uar_get_code_display(phys->list[d.seq]
   .position_cd), phys_id = phys->list[d.seq].phys_id,
  cat_type = phys->list[d.seq].cat_type, comm_type_cd = phys->list[d.seq].comm_type_cd
  FROM (dummyt d  WITH seq = value(phys->qual))
  ORDER BY facility_cd, position_cd, phys_id,
   cat_type, comm_type_cd
  HEAD REPORT
   fac_cnt = 0, pos_cnt = 0, ord_cnt = 0,
   comm_cnt = 0
  HEAD facility_cd
   fac_cnt = (fac_cnt+ 1), pos_cnt = 0, phys_cnt = 0,
   ord_cnt = 0, comm_cnt = 0, stat = alterlist(stats->fac_list,fac_cnt),
   stats->fac_list[fac_cnt].facility_cd = facility_cd
  HEAD position_cd
   pos_cnt = (pos_cnt+ 1), phys_cnt = 0, ord_cnt = 0,
   comm_cnt = 0, stat = alterlist(stats->fac_list[fac_cnt].pos_list,pos_cnt), stats->fac_list[fac_cnt
   ].pos_list[pos_cnt].position_cd = position_cd
  HEAD phys_id
   phys_cnt = (phys_cnt+ 1), ord_cnt = 0, comm_cnt = 0,
   stat = alterlist(stats->fac_list[fac_cnt].pos_list[pos_cnt].phys_list,phys_cnt), stats->fac_list[
   fac_cnt].pos_list[pos_cnt].phys_list[phys_cnt].phys_id = phys_id
  HEAD cat_type
   comm_cnt = (comm_cnt+ 1)
   CASE (cat_type)
    OF 1:
     stats->fac_list[fac_cnt].pos_list[pos_cnt].phys_list[phys_cnt].order_list[1].comm_type =
     comm_type_cd,stats->fac_list[fac_cnt].pos_list[pos_cnt].phys_list[phys_cnt].order_list[1].
     comm_count = comm_cnt
    OF 0:
     stats->fac_list[fac_cnt].pos_list[pos_cnt].phys_list[phys_cnt].order_list[2].comm_type =
     comm_type_cd,stats->fac_list[fac_cnt].pos_list[pos_cnt].phys_list[phys_cnt].order_list[2].
     comm_count = comm_cnt
   ENDCASE
  DETAIL
   ord_cnt = (ord_cnt+ 1)
  FOOT  phys_id
   stats->fac_list[fac_cnt].pos_list[pos_cnt].phys_list[phys_cnt].order_qual = ord_cnt
  FOOT  position_cd
   stats->fac_list[fac_cnt].pos_list[pos_cnt].phys_qual = phys_cnt
  FOOT  facility_cd
   stats->fac_list[fac_cnt].pos_qual = pos_cnt
  FOOT REPORT
   stats->fac_qual = fac_cnt
  WITH nocounter
 ;end select
 FREE RECORD print_req
 RECORD print_req(
   1 qual = i4
   1 list[*]
     2 facility_cd = f8
     2 position_cd = f8
     2 physician = f8
     2 order_type = i2
     2 comm_qual = i4
     2 comm_list[*]
       3 comm_header = vc
       3 comm_subtotal = i4
       3 comm_percent = vc
     2 cpoe_percent = vc
     2 total = i4
 )
 SELECT INTO  $1
  FROM (dummyt d  WITH seq = value(stats->fac_qual))
  HEAD REPORT
   cnt = 0, comm
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(print_req->list,cnt)
   FOR (x = 1 TO stats->fac_list[d.seq].pos_qual)
     print_req->list[cnt].facility_cd = stats->fac_list[d.seq].pos_list[x].facility_cd, print_req->
     list[cnt].position_cd = stats->fac_list[d.seq].pos_list[x].position_cd
     FOR (y = 1 TO stats->fac_list[d.seq].pos_list[x].phys_qual)
      print_req->list[cnt].physician = stats->fac_list[d.seq].pos_list[x].phys_list[y].phys_id,
      FOR (z = 1 TO stats->fac_list[d.seq].pos_list[x].phys_list[y].order_qual)
        IF (z=1)
         print_req->list[cnt].order_type = 1
        ELSEIF (z=2)
         print_req->list[cnt].order_type = 0
        ENDIF
        stat = alterlist(print_req->list[d.seq].comm_list)
        FOR (xx = 1 TO comm->qual)
          print_req->list[cnt].comm_list[xx].comm_header, print_req->list[cnt].comm_list[xx].
          comm_subtotal, print_req->list[cnt].comm_list[xx].comm_percent
        ENDFOR
      ENDFOR
     ENDFOR
   ENDFOR
 ;end select
END GO
