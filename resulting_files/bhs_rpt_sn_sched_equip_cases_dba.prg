CREATE PROGRAM bhs_rpt_sn_sched_equip_cases:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "Stop Date" = "CURDATE",
  "Select Surgical Area" = 0,
  "Item Number:" = "",
  "Equipment Description" = ""
  WITH outdev, start, stop,
  area, s_item_num, s_equip_desc
 DECLARE ms_item_num_parser = vc WITH protect, noconstant(" 1 = 1 ")
 DECLARE ms_equip_desc_parser = vc WITH protect, noconstant(" 1 = 1 ")
 IF (size(trim( $S_ITEM_NUM,3)) > 0)
  SET ms_item_num_parser = concat(" oi.value = '",trim( $S_ITEM_NUM),"'")
 ENDIF
 IF (size(trim( $S_EQUIP_DESC,3)) > 0)
  SET ms_equip_desc_parser = concat(" oi2.value = '",trim( $S_EQUIP_DESC),"'")
 ENDIF
 SELECT DISTINCT INTO  $1
  surgical_area = uar_get_code_display(sc.sched_surg_area_cd), case_number = substring(1,15,sc
   .surg_case_nbr_formatted), start_date = format(sc.sched_start_dt_tm,"mm/dd/yy;;d"),
  start_time = cnvttime(sc.sched_start_dt_tm)"HH:MM;;M", primary_surgeon = p.name_full_formatted,
  item_number = substring(1,20,oi.value),
  equipment_description = substring(1,50,oi2.value), requested_qty = cnvtint(pcpl.request_open_qty),
  hold_qty = cnvtint(pcpl.request_hold_qty),
  total_qty = cnvtint((pcpl.request_open_qty+ pcpl.request_hold_qty))
  FROM surgical_case sc,
   surg_case_procedure scp,
   object_identifier_index oi,
   object_identifier_index oi2,
   prsnl p,
   preference_card pc,
   pref_card_pick_list pcpl
  PLAN (sc
   WHERE sc.sched_start_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $2,"mm/dd/yyyy"),0) AND cnvtdatetime(
    cnvtdate2( $3,"mm/dd/yyyy"),235959)
    AND (sc.sched_surg_area_cd= $4))
   JOIN (scp
   WHERE scp.surg_case_id=sc.surg_case_id)
   JOIN (pc
   WHERE pc.prsnl_id=scp.sched_primary_surgeon_id
    AND pc.catalog_cd=scp.sched_surg_proc_cd)
   JOIN (pcpl
   WHERE pcpl.pref_card_id=pc.pref_card_id)
   JOIN (oi
   WHERE pcpl.item_id=oi.object_id
    AND oi.object_type_cd=3117
    AND oi.generic_object=outerjoin(0)
    AND parser(ms_item_num_parser))
   JOIN (oi2
   WHERE oi2.object_id=outerjoin(pcpl.item_id)
    AND oi2.identifier_type_cd=outerjoin(3097)
    AND oi2.generic_object=outerjoin(0)
    AND parser(ms_equip_desc_parser))
   JOIN (p
   WHERE p.person_id=scp.sched_primary_surgeon_id)
  ORDER BY surgical_area, sc.surg_case_nbr_formatted, start_date,
   start_time
  WITH format, separator = " "
 ;end select
#exit_script
END GO
