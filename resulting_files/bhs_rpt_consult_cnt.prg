CREATE PROGRAM bhs_rpt_consult_cnt
 FREE RECORD consult
 RECORD consult(
   1 mds[*]
     2 name = vc
     2 consults[*]
       3 person_id = f8
       3 order_id = f8
       3 orig_order_dt_tm = dq8
       3 encntr_id = f8
       3 loc_nurse = vc
       3 loc_room = vc
 )
 SET stat = alterlist(consult->mds,2)
 SET consult->mds[1].name = "Miranda-Sousa MD , Alejandro J"
 SET consult->mds[2].name = "Padmanabhan MD, Balaji"
 DECLARE mf_consult_phys_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTPHYSICIAN"))
 DECLARE mf_consult_phys_appt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTPHYSICIANAPPT"))
 DECLARE md_start_date = dq8 WITH protect, constant(cnvtdatetime("19-Feb-2009 00:00:00"))
 DECLARE md_end_date = dq8 WITH protect, constant(cnvtdatetime("18-Feb-2010 23:59:59"))
 DECLARE ivar = i4 WITH protect, noconstant(0)
 DECLARE mn_md_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_consult_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_max_consult_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_pdaterange = vc WITH protect, noconstant(concat(format(md_start_date,"@LONGDATE;;D"),
   " - ",format(md_end_date,"@LONGDATE;;D")))
 DECLARE ms_int = vc WITH protect, noconstant("-1")
 DECLARE ms_date = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM order_detail od,
   orders o
  PLAN (od
   WHERE expand(ivar,1,size(consult->mds,5),od.oe_field_display_value,consult->mds[ivar].name)
    AND od.oe_field_meaning="CONSULTDOC")
   JOIN (o
   WHERE o.order_id=od.order_id
    AND ((o.catalog_cd+ 0) IN (mf_consult_phys_cd, mf_consult_phys_appt_cd))
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(md_start_date) AND cnvtdatetime(md_end_date))
  ORDER BY od.oe_field_display_value, o.person_id
  HEAD od.oe_field_display_value
   mn_consult_cnt = 0, mn_md_cnt = locateval(ivar,1,size(consult->mds,5),od.oe_field_display_value,
    consult->mds[ivar].name)
  DETAIL
   mn_consult_cnt = (mn_consult_cnt+ 1), stat = alterlist(consult->mds[mn_md_cnt].consults,
    mn_consult_cnt), consult->mds[mn_md_cnt].consults[mn_consult_cnt].person_id = o.person_id,
   consult->mds[mn_md_cnt].consults[mn_consult_cnt].order_id = o.order_id, consult->mds[mn_md_cnt].
   consults[mn_consult_cnt].orig_order_dt_tm = o.orig_order_dt_tm, consult->mds[mn_md_cnt].consults[
   mn_consult_cnt].encntr_id = o.encntr_id
  WITH nocounter
 ;end select
 FOR (mn_md_cnt = 1 TO size(consult->mds,5))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(consult->mds[mn_md_cnt].consults,5))),
     encntr_loc_hist elh
    PLAN (d)
     JOIN (elh
     WHERE (elh.encntr_id=consult->mds[mn_md_cnt].consults[d.seq].encntr_id)
      AND elh.beg_effective_dt_tm < cnvtdatetime(consult->mds[mn_md_cnt].consults[d.seq].
      orig_order_dt_tm)
      AND elh.end_effective_dt_tm > cnvtdatetime(consult->mds[mn_md_cnt].consults[d.seq].
      orig_order_dt_tm))
    DETAIL
     consult->mds[mn_md_cnt].consults[d.seq].loc_nurse = uar_get_code_display(elh.loc_nurse_unit_cd),
     consult->mds[mn_md_cnt].consults[d.seq].loc_room = uar_get_code_display(elh.loc_room_cd)
    WITH nocounter
   ;end select
 ENDFOR
 CALL echorecord(consult)
 SET mn_max_consult_cnt = 0
 FOR (mn_md_cnt = 1 TO size(consult->mds,5))
   IF (size(consult->mds[mn_md_cnt].consults,5) > mn_max_consult_cnt)
    SET mn_max_consult_cnt = size(consult->mds[mn_md_cnt].consults,5)
   ENDIF
 ENDFOR
 CALL echo(build("Max consults:",mn_max_consult_cnt))
 SELECT INTO "MINE"
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   row 0, col 0, "Consult Comparison (",
   col + 0, ms_pdaterange, col + 0,
   ")", row + 2, col 0,
   consult->mds[1].name, col 65, consult->mds[2].name,
   row + 1, col 0, "Total:",
   ms_int = cnvtstring(size(consult->mds[1].consults,5)), col + 1, ms_int,
   col 65, "Total:", ms_int = cnvtstring(size(consult->mds[2].consults,5)),
   col + 1, ms_int, row + 2,
   col 0, "PERSON_ID", col 65,
   "PERSON_ID", col 11, "ORDER_DATE",
   col 76, "ORDER_DATE", col 32,
   "LOC_NURSE", col 97, "LOC_NURSE",
   col 43, "LOC_ROOM", col 108,
   "LOC_ROOM"
   FOR (mn_consult_cnt = 1 TO mn_max_consult_cnt)
     row + 1
     IF (mn_consult_cnt <= size(consult->mds[1].consults,5))
      ms_int = cnvtstring(consult->mds[1].consults[mn_consult_cnt].person_id), col 0, ms_int,
      ms_date = format(consult->mds[1].consults[mn_consult_cnt].orig_order_dt_tm,
       "YYYY/MM/DD HH:MM:SS;;D"), col 11, ms_date,
      col 32, consult->mds[1].consults[mn_consult_cnt].loc_nurse, col 43,
      consult->mds[1].consults[mn_consult_cnt].loc_room
     ENDIF
     IF (mn_consult_cnt <= size(consult->mds[2].consults,5))
      ms_int = cnvtstring(consult->mds[2].consults[mn_consult_cnt].person_id), col 65, ms_int,
      ms_date = format(consult->mds[2].consults[mn_consult_cnt].orig_order_dt_tm,
       "YYYY/MM/DD HH:MM:SS;;D"), col 76, ms_date,
      col 97, consult->mds[2].consults[mn_consult_cnt].loc_nurse, col 108,
      consult->mds[2].consults[mn_consult_cnt].loc_room
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
END GO
