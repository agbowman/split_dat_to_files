CREATE PROGRAM bed_aud_pft_cli_errors:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 RECORD temp(
   1 org[*]
     2 id = f8
     2 name = vc
     2 missing_bus_addr_ind = i2
     2 facility_ind = i2
     2 no_tier_ind = i2
     2 no_cli_acct_ind = i2
 )
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Organization Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "organization_id"
 SET reply->collist[2].data_type = 2
 SET reply->collist[2].hide_ind = 1
 SET reply->collist[3].header_text = "Missing Business Address"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "No Tier Association"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "No Client Account Association"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET business_addr = get_code_value(212,"BUSINESS")
 SET unauth = get_code_value(8,"UNAUTH")
 SET facility_cd = get_code_value(278,"FACILITY")
 SET client = get_code_value(278,"CLIENT")
 SET client_account = get_code_value(20849,"CLIENT")
 SET high_volume_cnt = 0
 CALL echo(high_volume_cnt)
 IF ((request->skip_volume_check_ind=0))
  IF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET ocnt = 0
 SELECT INTO "nl:"
  FROM org_type_reltn ot,
   organization o
  PLAN (ot
   WHERE ot.org_type_cd=client
    AND ot.active_ind=1
    AND ot.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND ot.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (o
   WHERE o.organization_id=ot.organization_id
    AND o.active_ind=1
    AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
  ORDER BY o.org_name_key
  HEAD REPORT
   ocnt = 0
  DETAIL
   ocnt = (ocnt+ 1), stat = alterlist(temp->org,ocnt), temp->org[ocnt].name = o.org_name,
   temp->org[ocnt].id = o.organization_id, temp->org[ocnt].missing_bus_addr_ind = 1, temp->org[ocnt].
   no_tier_ind = 1,
   temp->org[ocnt].no_cli_acct_ind = 1, temp->org[ocnt].facility_ind = 0
  WITH nocounter
 ;end select
 IF (ocnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ocnt),
   address a
  PLAN (d)
   JOIN (a
   WHERE (a.parent_entity_id=temp->org[d.seq].id)
    AND a.parent_entity_name="ORGANIZATION"
    AND a.address_type_cd=business_addr
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
  DETAIL
   temp->org[d.seq].missing_bus_addr_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ocnt),
   org_type_reltn otr
  PLAN (d)
   JOIN (otr
   WHERE (otr.organization_id=temp->org[d.seq].id)
    AND otr.org_type_cd=facility_cd
    AND otr.active_ind=1
    AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND otr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
  DETAIL
   temp->org[d.seq].facility_ind = 1
  WITH nocounter
 ;end select
 FOR (oidx = 1 TO ocnt)
   IF ((temp->org[oidx].facility_ind=1))
    SET temp->org[oidx].no_tier_ind = 0
    SET temp->org[oidx].no_cli_acct_ind = 0
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ocnt),
   bill_org_payor bop
  PLAN (d
   WHERE (temp->org[d.seq].facility_ind=0))
   JOIN (bop
   WHERE (bop.organization_id=temp->org[d.seq].id)
    AND bop.bill_org_type_id != 0
    AND bop.active_ind=1
    AND bop.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND bop.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
  DETAIL
   temp->org[d.seq].no_tier_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ocnt),
   pft_acct_reltn par,
   account acc
  PLAN (d
   WHERE (temp->org[d.seq].facility_ind=0))
   JOIN (par
   WHERE (par.parent_entity_id=temp->org[d.seq].id)
    AND par.parent_entity_name="ORGANIZATION"
    AND par.active_ind=1
    AND par.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND par.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (acc
   WHERE acc.acct_id=par.acct_id
    AND acc.active_ind=1
    AND acc.acct_sub_type_cd=client_account)
  DETAIL
   temp->org[d.seq].no_cli_acct_ind = 0
  WITH nocounter
 ;end select
 SET missing_bus_addr_tot = 0
 SET no_tier_tot = 0
 SET no_cli_acct_tot = 0
 SET rrow = 0
 FOR (x = 1 TO ocnt)
   IF ((((temp->org[x].missing_bus_addr_ind=1)) OR ((((temp->org[x].no_tier_ind=1)) OR ((temp->org[x]
   .no_cli_acct_ind=1))) )) )
    SET rrow = (rrow+ 1)
    SET stat = alterlist(reply->rowlist,rrow)
    SET stat = alterlist(reply->rowlist[rrow].celllist,5)
    SET reply->rowlist[rrow].celllist[1].string_value = temp->org[x].name
    SET reply->rowlist[rrow].celllist[2].double_value = temp->org[x].id
    IF ((temp->org[x].missing_bus_addr_ind=1))
     SET reply->rowlist[rrow].celllist[3].string_value = "X"
     SET missing_bus_addr_tot = (missing_bus_addr_tot+ 1)
    ELSE
     SET reply->rowlist[rrow].celllist[3].string_value = " "
    ENDIF
    IF ((temp->org[x].no_tier_ind=1))
     SET reply->rowlist[rrow].celllist[4].string_value = "X"
     SET no_tier_tot = (no_tier_tot+ 1)
    ELSE
     SET reply->rowlist[rrow].celllist[4].string_value = " "
    ENDIF
    IF ((temp->org[x].no_cli_acct_ind=1))
     SET reply->rowlist[rrow].celllist[5].string_value = "X"
     SET no_cli_acct_tot = (no_cli_acct_tot+ 1)
    ELSE
     SET reply->rowlist[rrow].celllist[5].string_value = " "
    ENDIF
   ENDIF
 ENDFOR
 IF (missing_bus_addr_tot=0
  AND no_tier_tot=0
  AND no_cli_acct_tot=0)
  SET reply->run_status_flag = 1
 ELSE
  SET reply->run_status_flag = 3
 ENDIF
 SET stat = alterlist(reply->statlist,3)
 SET reply->statlist[1].statistic_meaning = "PFTCLINOBUSADDR"
 SET reply->statlist[1].total_items = ocnt
 SET reply->statlist[1].qualifying_items = missing_bus_addr_tot
 IF (missing_bus_addr_tot=0)
  SET reply->statlist[1].status_flag = 1
 ELSE
  SET reply->statlist[1].status_flag = 3
 ENDIF
 SET reply->statlist[2].statistic_meaning = "PFTCLINOTIER"
 SET reply->statlist[2].total_items = ocnt
 SET reply->statlist[2].qualifying_items = no_tier_tot
 IF (no_tier_tot=0)
  SET reply->statlist[2].status_flag = 1
 ELSE
  SET reply->statlist[2].status_flag = 3
 ENDIF
 SET reply->statlist[3].statistic_meaning = "PFTCLINOCLIACCT"
 SET reply->statlist[3].total_items = ocnt
 SET reply->statlist[3].qualifying_items = no_cli_acct_tot
 IF (no_cli_acct_tot=0)
  SET reply->statlist[3].status_flag = 1
 ELSE
  SET reply->statlist[3].status_flag = 3
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("pft_cli_errors_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
