CREATE PROGRAM bhs_rpt_future_lab_orders:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Order Date Start:" = "CURDATE",
  "Order Date End:" = "CURDATE"
  WITH outdev, s_start_dt, s_stop_dt
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs16449_perfloc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "PERFORMINGLOCATIONAMBULATORY"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs6000_lab_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3081"))
 DECLARE mf_cs6004_future_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!11559"))
 DECLARE mf_cs16449_orderloc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ORDER LOCATION"))
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 SELECT INTO  $OUTDEV
  o.order_mnemonic, order_detail_display_line = replace(replace(o.order_detail_display_line,char(10),
    " "),char(13)," "), order_dt = format(o.orig_order_dt_tm,";;q"),
  order_status = uar_get_code_display(o.order_status_cd), catalog_type = uar_get_code_display(o
   .catalog_type_cd), pat_name = p.name_full_formatted,
  originating_fin = ea.alias, originating_location = uar_get_code_display(e.loc_nurse_unit_cd), o
  .template_order_id,
  o.order_id, performing_location = od.oe_field_display_value, order_detail_order_loc = od2
  .oe_field_display_value
  FROM orders o,
   person p,
   encounter e,
   encntr_alias ea,
   order_detail od,
   order_detail od2
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND o.catalog_type_cd=mf_cs6000_lab_cd
    AND o.order_status_cd=mf_cs6004_future_cd)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (e
   WHERE e.encntr_id=o.originating_encntr_id)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(o.originating_encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm> Outerjoin(sysdate))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_cs319_fin_cd)) )
   JOIN (od
   WHERE (od.order_id= Outerjoin(o.order_id))
    AND (od.oe_field_id= Outerjoin(mf_cs16449_perfloc_cd)) )
   JOIN (od2
   WHERE (od2.order_id= Outerjoin(o.order_id))
    AND (od2.oe_field_id= Outerjoin(mf_cs16449_orderloc_cd)) )
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
END GO
