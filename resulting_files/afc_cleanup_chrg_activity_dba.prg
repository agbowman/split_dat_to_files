CREATE PROGRAM afc_cleanup_chrg_activity:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET today = cnvtdatetime(curdate,curtime3)
 SET reply->status_data.status = "F"
 SET total_c_rows_found = 0
 CALL echo("Checking for rows to purge from charge where process_flg = 1 and ")
 CALL echo("the (tier_group_cd = 0 or charge_event_act_id = 0)")
 SELECT INTO TABLE t_cleanup_c
  c.charge_item_id, c.person_id, c.updt_dt_tm,
  c.charge_description
  FROM charge c
  WHERE c.process_flg=1
   AND ((c.tier_group_cd=0) OR (c.charge_event_act_id=0))
  WITH counter
 ;end select
 SET total_c_rows_found = (total_c_rows_found+ curqual)
 CALL echo(build("total_c_rows_found is: ",total_c_rows_found))
 IF (curqual <= 0)
  CALL echo("No rows qualified for the suspended charges select.")
 ELSE
  DELETE  FROM charge c,
    t_cleanup_c t
   SET c.seq = 1
   PLAN (t)
    JOIN (c
    WHERE c.charge_item_id=t.charge_item_id)
  ;end delete
  COMMIT
 ENDIF
 SET total_ce_rows_found = 0
 CALL echo("Checking for rows to purge from charge_event where")
 CALL echo("any of the ext_m fields are 0")
 SELECT INTO TABLE t_cleanup_ce
  ce.charge_event_id, ce.ext_m_event_id, ce.person_id,
  ce.updt_dt_tm
  FROM charge_event ce
  WHERE ((ce.ext_m_event_id=0) OR (((ce.ext_m_event_cont_cd=0) OR (((ce.ext_m_reference_id=0) OR (ce
  .ext_m_reference_cont_cd=0)) )) ))
  WITH counter
 ;end select
 SET total_ce_rows_found = (total_ce_rows_found+ curqual)
 CALL echo(build("total_ce_rows_found is: ",total_ce_rows_found))
 IF (curqual <= 0)
  CALL echo("No rows qualified for the purge where ext_m fields are 0 on the charge_event table.")
 ELSE
  DELETE  FROM charge_event ce,
    t_cleanup_ce t
   SET ce.seq = 1
   PLAN (t)
    JOIN (ce
    WHERE ce.charge_event_id=t.charge_event_id)
  ;end delete
  COMMIT
 ENDIF
 IF (((total_c_rows_found > 0) OR (total_ce_rows_found > 0)) )
  IF (total_c_rows_found > 0)
   SET file_name = concat("rpt_cln_chrg_",format(today,"dd-mmm-yyyy;;d"),".dat")
   CALL echo(file_name)
   SET equal_line = fillstring(130,"=")
   CALL echo("printing charge audit report")
   SELECT INTO value(file_name)
    charge_item_id = t.charge_item_id, date = format(t.updt_dt_tm,"DD-MMM-YYYY HH:MM;;d"), name =
    concat(trim(p.name_last_key),", ",trim(p.name_first_key)),
    num_rows = total_c_rows_found, rpt_date = concat(format(today,"DD-MMM-YYYY;;D"),format(today,
      " HH:MM:SS;;S")), desc = trim(t.charge_description)
    FROM t_cleanup_c t,
     person p
    PLAN (t)
     JOIN (p
     WHERE t.person_id=p.person_id)
    ORDER BY name, charge_item_id, date
    HEAD REPORT
     col 50, "** AFC_CLEANUP_CHRG_ACTIVITY **", col 90,
     "Run Date: ", rpt_date, row + 2
    HEAD PAGE
     col 120, "Page: ", curpage"##",
     row + 1, col 00, equal_line,
     row + 2, col 00, "Person Name",
     col 50, "Charge Item Id", col 70,
     "Charge Desc", col 97, "Updt_dt_tm",
     row + 2
    DETAIL
     col 00, name"##############################################", col 50,
     charge_item_id, col 70, desc"####################",
     col 97, date, row + 1
    FOOT REPORT
     row + 2, col 70, "# of rows purged: ",
     num_rows
    WITH nocounter
   ;end select
  ENDIF
  IF (total_ce_rows_found > 0)
   SET file_name = concat("rpt_cln_ce_",format(today,"dd-mmm-yyyy;;d"),".dat")
   CALL echo(file_name)
   SET equal_line = fillstring(130,"=")
   CALL echo("printing charge_event audit report")
   SELECT INTO value(file_name)
    charge_event_id = t.charge_event_id, date = format(t.updt_dt_tm,"DD-MMM-YYYY HH:MM;;d"), name =
    concat(trim(p.name_last_key),", ",trim(p.name_first_key)),
    num_rows = total_ce_rows_found, rpt_date = concat(format(today,"DD-MMM-YYYY;;D"),format(today,
      " HH:MM:SS;;S")), ext_m_event_id = t.ext_m_event_id
    FROM t_cleanup_ce t,
     person p
    PLAN (t)
     JOIN (p
     WHERE p.person_id=t.person_id)
    ORDER BY name, charge_event_id, date
    HEAD REPORT
     col 50, "** AFC_PURGE_ACTIVITY **", col 90,
     "Run Date: ", rpt_date, row + 2
    HEAD PAGE
     col 120, "Page: ", curpage"##",
     row + 1, col 00, equal_line,
     row + 2, col 00, "Person Name",
     col 40, "Charge Event Id", col 56,
     "Ext M Event Id", col 72, "Updt_dt_tm",
     row + 2
    DETAIL
     col 00, name"##############################################", col 40,
     charge_event_id, col 56, ext_m_event_id,
     col 72, date, row + 1
    FOOT REPORT
     row + 2, col 70, "# of rows purged: ",
     num_rows
    WITH nocounter
   ;end select
  ENDIF
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echo("Finished.")
 CALL echo(build("Beg Time: "," ",format(today,"DD-MMM-YYYY;;d"),format(today," HH:MM:SS;;S")))
 CALL echo(build("End Time: "," ",format(curdate,"DD-MMM-YYYY;;D"),format(curtime," HH:MM:SS;;S")))
 SET clean = remove("ccluserdir:t_cleanup_c.dat;*")
 SET clean = remove("ccluserdir:t_cleanup_ce.dat;*")
END GO
