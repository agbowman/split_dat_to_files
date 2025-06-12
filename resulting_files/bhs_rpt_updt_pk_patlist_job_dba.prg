CREATE PROGRAM bhs_rpt_updt_pk_patlist_job:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select action" = "",
  "Items Remove/ADD (to VIEW current list select execute)" = 0,
  "Select Active(uncheck to see deactivated lists)" = 1
  WITH outdev, selected_action, uptdpklist,
  select_active
 DECLARE mf_careteam = f8 WITH constant(uar_get_code_by("DISPLAYKEY",19189,"CARETEAM")), protect
 DECLARE ml_sel_cnt = i4 WITH noconstant(0), protect
 RECORD pk_list_details(
   1 pat_lists[*]
     2 s_list_name = vc
     2 s_description = vc
     2 s_list_key = vc
     2 f_prsnl_grp_id = f8
     2 d_updt_dt_tm = vc
     2 f_update_id = f8
     2 i_active_status = i4
     2 f_dm_info_status = f8
     2 s_action = vc
 )
 SELECT INTO "nl:"
  pg.prsnl_group_name, pg.prsnl_group_id
  FROM prsnl_group pg
  PLAN (pg
   WHERE pg.prsnl_group_class_cd=mf_careteam
    AND (pg.prsnl_group_id= $UPTDPKLIST)
    AND pg.active_ind=1)
  HEAD REPORT
   stat = alterlist(pk_list_details->pat_lists,(ml_sel_cnt+ 9))
  DETAIL
   ml_sel_cnt = (ml_sel_cnt+ 1)
   IF (ml_sel_cnt > size(pk_list_details->pat_lists,5))
    stat = alterlist(pk_list_details->pat_lists,(ml_sel_cnt+ 9))
   ENDIF
   pk_list_details->pat_lists[ml_sel_cnt].s_list_name = "BHS_LIST_KEYS:PK_PAT_LIST", pk_list_details
   ->pat_lists[ml_sel_cnt].s_description = concat(trim(pg.prsnl_group_name,3)," PK"), pk_list_details
   ->pat_lists[ml_sel_cnt].s_list_key = concat("CT",trim(format(pg.prsnl_group_id,"#############"),3)
    ),
   pk_list_details->pat_lists[ml_sel_cnt].d_updt_dt_tm = format(cnvtdatetime(curdate,curtime3),";;q"),
   pk_list_details->pat_lists[ml_sel_cnt].f_update_id = reqinfo->updt_id, pk_list_details->pat_lists[
   ml_sel_cnt].f_prsnl_grp_id = pg.prsnl_group_id,
   pk_list_details->pat_lists[ml_sel_cnt].i_active_status = 0, pk_list_details->pat_lists[ml_sel_cnt]
   .f_dm_info_status = 0.0, pk_list_details->pat_lists[ml_sel_cnt].s_action =  $SELECTED_ACTION
  FOOT REPORT
   stat = alterlist(pk_list_details->pat_lists,ml_sel_cnt), ml_sel_cnt = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pat_lists_f_prsnl_grp_id = pk_list_details->pat_lists[d1.seq].f_prsnl_grp_id
  FROM (dummyt d1  WITH seq = value(size(pk_list_details->pat_lists,5))),
   dm_info d
  PLAN (d1)
   JOIN (d
   WHERE (d.info_number=pk_list_details->pat_lists[d1.seq].f_prsnl_grp_id)
    AND d.info_domain="BHS_LIST_KEYS:PK_PAT_LIST")
  ORDER BY d1.seq
  DETAIL
   IF (d.info_domain="BHS_LIST_KEYS:PK_PAT_LIST"
    AND d.info_long_id=1.0
    AND ( $SELECTED_ACTION="REMOVE"))
    pk_list_details->pat_lists[d1.seq].i_active_status = 3, pk_list_details->pat_lists[d1.seq].
    f_dm_info_status = d.info_long_id
   ELSEIF (d.info_domain="BHS_LIST_KEYS:PK_PAT_LIST"
    AND d.info_long_id=0.0
    AND ( $SELECTED_ACTION="ADD"))
    pk_list_details->pat_lists[d1.seq].i_active_status = 1, pk_list_details->pat_lists[d1.seq].
    f_dm_info_status = d.info_long_id
   ENDIF
  WITH nocounter, separator = " ", format
 ;end select
 CALL echorecord(pk_list_details)
 IF (( $SELECTED_ACTION="ADD"))
  UPDATE  FROM dm_info d,
    (dummyt d2  WITH seq = value(size(pk_list_details->pat_lists,5)))
   SET d.info_long_id = 1, d.updt_dt_tm = sysdate, d.updt_cnt = (d.updt_cnt+ 1),
    d.updt_id = reqinfo->updt_id, d.info_name = pk_list_details->pat_lists[d2.seq].s_description, d
    .updt_task = 1000
   PLAN (d
    WHERE d.info_domain="BHS_LIST_KEYS:PK_PAT_LIST"
     AND d.info_long_id=0
     AND (d.info_number= $UPTDPKLIST))
    JOIN (d2
    WHERE trim(pk_list_details->pat_lists[d2.seq].s_list_name)=d.info_domain
     AND trim(pk_list_details->pat_lists[d2.seq].s_list_key)=d.info_char
     AND (pk_list_details->pat_lists[d2.seq].f_prsnl_grp_id=d.info_number)
     AND (pk_list_details->pat_lists[d2.seq].i_active_status=1))
   WITH nocounter
  ;end update
  COMMIT
  INSERT  FROM dm_info d,
    (dummyt d3  WITH seq = value(size(pk_list_details->pat_lists,5)))
   SET d.info_domain = trim(pk_list_details->pat_lists[d3.seq].s_list_name), d.info_name = trim(
     pk_list_details->pat_lists[d3.seq].s_description,3), d.info_char = trim(pk_list_details->
     pat_lists[d3.seq].s_list_key),
    d.info_number = pk_list_details->pat_lists[d3.seq].f_prsnl_grp_id, d.info_long_id = 1, d
    .updt_dt_tm = sysdate,
    d.updt_id = reqinfo->updt_id, d.updt_task = 1000
   PLAN (d3
    WHERE (pk_list_details->pat_lists[d3.seq].s_list_name="BHS_LIST_KEYS:PK_PAT_LIST")
     AND (pk_list_details->pat_lists[d3.seq].i_active_status=0))
    JOIN (d)
   WITH nocounter
  ;end insert
  COMMIT
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "List is Updated", col 0, "{ps/792 0}",
    y_pos = 18, row + 1, "{f/1}{cpi/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
 ELSEIF (( $SELECTED_ACTION="REMOVE"))
  CALL echorecord(pk_list_details)
  UPDATE  FROM dm_info d,
    (dummyt d2  WITH seq = value(size(pk_list_details->pat_lists,5)))
   SET d.info_long_id = 0, d.updt_dt_tm = sysdate, d.updt_cnt = (d.updt_cnt+ 1),
    d.updt_id = reqinfo->updt_id, d.info_name = trim(pk_list_details->pat_lists[d2.seq].s_description,
     3)
   PLAN (d
    WHERE d.info_domain="BHS_LIST_KEYS:PK_PAT_LIST"
     AND d.info_long_id=1
     AND (d.info_number= $UPTDPKLIST)
     AND d.updt_task=1000)
    JOIN (d2
    WHERE trim(pk_list_details->pat_lists[d2.seq].s_list_name)=d.info_domain
     AND trim(pk_list_details->pat_lists[d2.seq].s_list_key)=d.info_char
     AND (pk_list_details->pat_lists[d2.seq].f_prsnl_grp_id=d.info_number)
     AND (pk_list_details->pat_lists[d2.seq].i_active_status=3))
   WITH nocounter
  ;end update
  COMMIT
  IF (curqual > 0)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "List is Updated", col 0, "{ps/792 0}",
     y_pos = 18, row + 1, "{f/1}{cpi/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1
    WITH dio = 08
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "List is Empty Nothing to Remove", col 0, "{ps/792 0}",
     y_pos = 18, row + 1, "{f/1}{cpi/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1
    WITH dio = 08
   ;end select
  ENDIF
 ELSEIF (( $SELECTED_ACTION="VIEW"))
  SELECT INTO  $OUTDEV
   stored_lists_name = d.info_domain, patient_lis_name = d.info_name, patient_keeper_id = d.info_char,
   personel_grp_id = d.info_number, updated_by = p.name_full_formatted, active_ind = d.info_long_id,
   list_number = d.updt_task
   FROM dm_info d,
    prsnl p
   PLAN (d
    WHERE d.info_domain="BHS_LIST_KEYS:PK_PAT_LIST"
     AND (d.info_long_id= $SELECT_ACTIVE))
    JOIN (p
    WHERE p.person_id=d.updt_id)
   WITH nocounter, separator = " ", format
  ;end select
  IF (curqual=0)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "List is Empty", col 0, "{ps/792 0}",
     y_pos = 18, row + 1, "{f/1}{cpi/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1
    WITH dio = 08
   ;end select
  ENDIF
 ENDIF
END GO
