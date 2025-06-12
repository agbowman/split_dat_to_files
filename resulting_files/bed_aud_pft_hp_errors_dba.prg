CREATE PROGRAM bed_aud_pft_hp_errors:dba
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
 FREE SET hp
 RECORD hp(
   1 hp_cnt = i4
   1 hp[*]
     2 id = f8
     2 name = vc
     2 financial_class_cd = f8
     2 unauth_ind = i2
     2 dup_ind = i2
     2 missing_fin_class_ind = i2
     2 missing_bus_addr_ind = i2
 )
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Plan Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "health_plan_id"
 SET reply->collist[2].data_type = 2
 SET reply->collist[2].hide_ind = 1
 SET reply->collist[3].header_text = "Unauthenticated"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Duplicate"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Missing Financial Class"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Missing Business Address"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET self_pay = get_code_value(354,"SELFPAY")
 SET business_addr = get_code_value(212,"BUSINESS")
 SET unauth = get_code_value(8,"UNAUTH")
 SET client = get_code_value(278,"CLIENT")
 SET facility = get_code_value(278,"FACILITY")
 SET client_account = get_code_value(20849,"CLIENT")
 DECLARE save_plan_name_key = vc
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
 SELECT INTO "NL:"
  FROM health_plan h
  WHERE h.active_ind=1
   AND h.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND h.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND h.plan_name_key > " "
  ORDER BY h.plan_name_key
  HEAD REPORT
   save_plan_name_key = " "
  DETAIL
   hp->hp_cnt = (hp->hp_cnt+ 1)
   IF ((hp->hp_cnt > size(hp->hp,5)))
    stat = alterlist(hp->hp,(hp->hp_cnt+ 50))
   ENDIF
   hp->hp[hp->hp_cnt].id = h.health_plan_id, hp->hp[hp->hp_cnt].name = h.plan_name
   IF (h.plan_name_key=save_plan_name_key)
    hp->hp[(hp->hp_cnt - 1)].dup_ind = 1, hp->hp[hp->hp_cnt].dup_ind = 1
   ELSE
    save_plan_name_key = h.plan_name_key
   ENDIF
   IF (h.financial_class_cd=0)
    hp->hp[hp->hp_cnt].missing_fin_class_ind = 1
   ENDIF
   IF (h.data_status_cd=unauth)
    hp->hp[hp->hp_cnt].unauth_ind = 1
   ENDIF
   hp->hp[hp->hp_cnt].financial_class_cd = h.financial_class_cd
   IF (h.financial_class_cd=self_pay)
    hp->hp[hp->hp_cnt].missing_bus_addr_ind = 0
   ELSE
    hp->hp[hp->hp_cnt].missing_bus_addr_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(hp->hp,hp->hp_cnt)
 IF ((hp->hp_cnt > 0))
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = hp->hp_cnt),
    address a
   PLAN (d
    WHERE (hp->hp[d.seq].financial_class_cd != self_pay))
    JOIN (a
    WHERE (a.parent_entity_id=hp->hp[d.seq].id)
     AND a.parent_entity_name="HEALTH_PLAN"
     AND a.address_type_cd=business_addr
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   DETAIL
    hp->hp[d.seq].missing_bus_addr_ind = 0
   WITH nocounter
  ;end select
  SET rows = 0
  SET dup_tot = 0
  SET missing_fin_class_tot = 0
  SET missing_bus_addr_tot = 0
  FOR (i = 1 TO hp->hp_cnt)
    IF ((((hp->hp[i].dup_ind > 0)) OR ((((hp->hp[i].missing_fin_class_ind > 0)) OR ((hp->hp[i].
    missing_bus_addr_ind > 0))) )) )
     SET rows = (rows+ 1)
     SET stat = alterlist(reply->rowlist,rows)
     SET stat = alterlist(reply->rowlist[rows].celllist,6)
     SET reply->rowlist[rows].celllist[1].string_value = hp->hp[i].name
     SET reply->rowlist[rows].celllist[2].double_value = hp->hp[i].id
     IF ((hp->hp[i].unauth_ind=1))
      SET reply->rowlist[rows].celllist[3].string_value = "X"
     ELSE
      SET reply->rowlist[rows].celllist[3].string_value = " "
     ENDIF
     IF ((hp->hp[i].dup_ind=1))
      SET dup_tot = (dup_tot+ 1)
      SET reply->rowlist[rows].celllist[4].string_value = "X"
     ELSE
      SET reply->rowlist[rows].celllist[4].string_value = " "
     ENDIF
     IF ((hp->hp[i].missing_fin_class_ind=1))
      SET missing_fin_class_tot = (missing_fin_class_tot+ 1)
      SET reply->rowlist[rows].celllist[5].string_value = "X"
     ELSE
      SET reply->rowlist[rows].celllist[5].string_value = " "
     ENDIF
     IF ((hp->hp[i].missing_bus_addr_ind=1))
      SET missing_bus_addr_tot = (missing_bus_addr_tot+ 1)
      SET reply->rowlist[rows].celllist[6].string_value = "X"
     ELSE
      SET reply->rowlist[rows].celllist[6].string_value = " "
     ENDIF
    ENDIF
  ENDFOR
  IF (dup_tot=0
   AND missing_fin_class_tot=0
   AND missing_bus_addr_tot=0)
   SET reply->run_status_flag = 1
  ELSE
   SET reply->run_status_flag = 3
  ENDIF
  SET stat = alterlist(reply->statlist,3)
  SET reply->statlist[1].statistic_meaning = "HEALTHPLANDUP"
  SET reply->statlist[1].total_items = hp->hp_cnt
  SET reply->statlist[1].qualifying_items = dup_tot
  IF (dup_tot=0)
   SET reply->statlist[1].status_flag = 1
  ELSE
   SET reply->statlist[1].status_flag = 3
  ENDIF
  SET reply->statlist[2].statistic_meaning = "HEALTHPLANMISSINGFINCLASS"
  SET reply->statlist[2].total_items = hp->hp_cnt
  SET reply->statlist[2].qualifying_items = missing_fin_class_tot
  IF (missing_fin_class_tot=0)
   SET reply->statlist[2].status_flag = 1
  ELSE
   SET reply->statlist[2].status_flag = 3
  ENDIF
  SET reply->statlist[3].statistic_meaning = "HEALTHPLANMISSINGBUSADDR"
  SET reply->statlist[3].total_items = hp->hp_cnt
  SET reply->statlist[3].qualifying_items = missing_bus_addr_tot
  IF (missing_bus_addr_tot=0)
   SET reply->statlist[3].status_flag = 1
  ELSE
   SET reply->statlist[3].status_flag = 3
  ENDIF
 ENDIF
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
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("pft_hp_errors_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
