CREATE PROGRAM dm_stat_ue_erx_encounter:dba
 IF ( NOT (validate(dsr,0)))
  RECORD dsr(
    1 qual[*]
      2 stat_snap_dt_tm = dq8
      2 snapshot_type = c100
      2 client_mnemonic = c10
      2 domain_name = c20
      2 node_name = c30
      2 qual[*]
        3 stat_name = vc
        3 stat_seq = i4
        3 stat_str_val = vc
        3 stat_type = i4
        3 stat_number_val = f8
        3 stat_date_val = dq8
        3 stat_clob_val = vc
  )
 ENDIF
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 DECLARE dsvm_error(msg=vc) = null
 DECLARE ds_cnt = i4 WITH protect, noconstant(1)
 DECLARE stat_seq = i4 WITH protect, noconstant(0)
 DECLARE dtl_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_snapshot_type = vc WITH protect, constant("UE_ERX_ENCOUNTER.3")
 SET order_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET success_cd = uar_get_code_by("MEANING",27400,"SUCCESS")
 SET pharmedi_cd = uar_get_code_by("MEANING",3575,"PHARMEDI")
 SET error_cd = uar_get_code_by("MEANING",3401,"ERROR")
 SET inerror_cd = uar_get_code_by("MEANING",3401,"INERROR")
 SET errorretry_cd = uar_get_code_by("MEANING",3401,"ERRORRETRY")
 SET rxnonmatch_cd = uar_get_code_by("MEANING",6026,"RXNONMATCH")
 SET rxsusmatch_cd = uar_get_code_by("MEANING",6026,"RXSUSMATCH")
 SET rxrenewal_cd = uar_get_code_by("MEANING",6026,"RXRENEWAL")
 SET pharm_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET ds_begin_snapshot = cnvtdatetime((curdate - 1),0)
 SET ds_end_snapshot = cnvtdatetime((curdate - 1),235959)
 SET ds_cnt = 1
 SET dtl_cnt = 0
 SET qualcnt = 0
 SET stat_seq = 0
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  si.msg_trig_action_txt, elh.loc_facility_cd, elh.loc_nurse_unit_cd,
  elh.encntr_type_cd, o.activity_type_cd, cnt = count(1)
  FROM order_action oa,
   orders o,
   encntr_loc_hist elh,
   si_audit si
  PLAN (si
   WHERE si.msg_trig_action_txt IN ("NEWRX", "REFRES")
    AND si.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND si.status_cd=success_cd)
   JOIN (o
   WHERE si.parent_entity_id=o.order_id
    AND ((o.orderable_type_flag+ 0) != 6)
    AND ((o.encntr_id+ 0) > 0))
   JOIN (oa
   WHERE o.order_id=oa.order_id
    AND oa.action_type_cd=order_cd
    AND oa.template_order_flag IN (0, 1, 5))
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.beg_effective_dt_tm <= oa.action_dt_tm
    AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
    AND elh.active_ind=1)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   si.msg_trig_action_txt, elh.loc_facility_cd, elh.loc_nurse_unit_cd,
   elh.encntr_type_cd, o.activity_type_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "TX_ELECTRONIC", dsr->qual[qualcnt].qual[ds_cnt].
   stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(elh.loc_facility_cd),"||",
    uar_get_code_meaning(elh.loc_facility_cd),
    "||",elh.loc_facility_cd,"||",uar_get_code_display(elh.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(elh.loc_nurse_unit_cd),"||",elh.loc_nurse_unit_cd,"||",uar_get_code_display(
     elh.encntr_type_cd),
    "||",uar_get_code_meaning(elh.encntr_type_cd),"||",elh.encntr_type_cd,"||",
    oa.order_provider_id,"||",oa.action_personnel_id,"||",o.orig_ord_as_flag,
    "||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o.activity_type_cd),"||",
    o.activity_type_cd,"||",si.msg_trig_action_txt), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val
    = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1), dtl_cnt = (dtl_cnt+ 1)
  FOOT REPORT
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   IF (dtl_cnt=0)
    dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].
    stat_name = "TX_ELECTRONIC", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
    ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+ 1)
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("UE_ERX_ENCOUNTER_ENCOUNTER - TX_ELECTRONIC")
 SET dtl_cnt = 0
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  si.msg_trig_action_txt, o.activity_type_cd, cnt = count(1)
  FROM order_action oa,
   orders o,
   si_audit si
  PLAN (si
   WHERE si.msg_trig_action_txt IN ("NEWRX", "REFRES")
    AND si.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND si.status_cd=success_cd)
   JOIN (o
   WHERE si.parent_entity_id=o.order_id
    AND ((o.orderable_type_flag+ 0) != 6)
    AND ((o.encntr_id+ 0) > 0))
   JOIN (oa
   WHERE o.order_id=oa.order_id
    AND oa.action_type_cd=order_cd
    AND oa.template_order_flag IN (0, 1, 5)
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM encntr_loc_hist elh
    WHERE elh.encntr_id=o.encntr_id
     AND elh.beg_effective_dt_tm <= oa.action_dt_tm
     AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
     AND elh.active_ind=1
     AND ((elh.encntr_id+ 0) > 0)))))
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   si.msg_trig_action_txt, o.activity_type_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "TX_ELECTRONIC", dsr->qual[qualcnt].qual[ds_cnt].
   stat_str_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",oa.order_provider_id,"||",oa.action_personnel_id,
    "||",o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",
    uar_get_code_meaning(o.activity_type_cd),"||",o.activity_type_cd,"||",si.msg_trig_action_txt),
   dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1), dtl_cnt = (dtl_cnt+ 1)
  FOOT REPORT
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   IF (dtl_cnt=0)
    dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].
    stat_name = "TX_ELECTRONIC", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
    ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+ 1)
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("UE_ERX_ENCOUNTER_ENCOUNTER - TX_ELECTRONIC ;No encounter")
 SET stat_seq = 0
 SET dtl_cnt = 0
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  elh.loc_facility_cd, elh.loc_nurse_unit_cd, elh.encntr_type_cd,
  o.activity_type_cd, cnt = count(1)
  FROM orders o,
   order_detail od,
   order_action oa,
   encntr_loc_hist elh
  PLAN (oa
   WHERE oa.action_type_cd=order_cd
    AND oa.template_order_flag IN (0, 1, 5)
    AND oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   JOIN (o
   WHERE oa.order_id=o.order_id
    AND o.orig_ord_as_flag=1
    AND o.catalog_type_cd=pharm_cd
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM si_audit si
    WHERE si.parent_entity_id=o.order_id
     AND si.msg_trig_action_txt IN ("NEWRX", "REFRES")
     AND si.status_cd=success_cd))))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND oa.action_sequence=od.action_sequence
    AND od.oe_field_meaning="REQROUTINGTYPE"
    AND  NOT (od.oe_field_value IN (pharmedi_cd)))
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.beg_effective_dt_tm <= oa.action_dt_tm
    AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
    AND elh.active_ind=1)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   elh.loc_facility_cd, elh.loc_nurse_unit_cd, elh.encntr_type_cd,
   o.activity_type_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "TX_NOT_ELECTRONIC", dsr->qual[qualcnt].qual[ds_cnt].
   stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(elh.loc_facility_cd),"||",
    uar_get_code_meaning(elh.loc_facility_cd),
    "||",elh.loc_facility_cd,"||",uar_get_code_display(elh.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(elh.loc_nurse_unit_cd),"||",elh.loc_nurse_unit_cd,"||",uar_get_code_display(
     elh.encntr_type_cd),
    "||",uar_get_code_meaning(elh.encntr_type_cd),"||",elh.encntr_type_cd,"||",
    oa.order_provider_id,"||",oa.action_personnel_id,"||",o.orig_ord_as_flag,
    "||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o.activity_type_cd),"||",
    o.activity_type_cd), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1), dtl_cnt = (dtl_cnt+ 1)
  FOOT REPORT
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   IF (dtl_cnt=0)
    dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].
    stat_name = "TX_NOT_ELECTRONIC", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
    ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+ 1)
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("UE_ERX_ENCOUNTER - TX_NOT_ELECTRONIC")
 SET dtl_cnt = 0
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  o.activity_type_cd, cnt = count(1)
  FROM orders o,
   order_detail od,
   order_action oa
  PLAN (oa
   WHERE oa.action_type_cd=order_cd
    AND oa.template_order_flag IN (0, 1, 5)
    AND oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   JOIN (o
   WHERE oa.order_id=o.order_id
    AND o.orig_ord_as_flag=1
    AND o.catalog_type_cd=pharm_cd
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM si_audit si
    WHERE si.parent_entity_id=o.order_id
     AND si.msg_trig_action_txt IN ("NEWRX", "REFRES")
     AND si.status_cd=success_cd))))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND oa.action_sequence=od.action_sequence
    AND od.oe_field_meaning="REQROUTINGTYPE"
    AND  NOT (od.oe_field_value IN (pharmedi_cd)))
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   o.activity_type_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "TX_NOT_ELECTRONIC", dsr->qual[qualcnt].qual[ds_cnt].
   stat_str_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",oa.order_provider_id,"||",oa.action_personnel_id,
    "||",o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",
    uar_get_code_meaning(o.activity_type_cd),"||",o.activity_type_cd), dsr->qual[qualcnt].qual[ds_cnt
   ].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1), dtl_cnt = (dtl_cnt+ 1)
  FOOT REPORT
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   IF (dtl_cnt=0)
    dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].
    stat_name = "TX_NOT_ELECTRONIC", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
    ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+ 1)
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("UE_ERX_ENCOUNTER - TX_NOT_ELECTRONIC ;No encounter")
 SET stat_seq = 0
 SET dtl_cnt = 0
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  si.msg_trig_action_txt, elh.loc_facility_cd, elh.loc_nurse_unit_cd,
  elh.encntr_type_cd, o.activity_type_cd, ma.status_cd,
  cnt = count(1)
  FROM order_action oa,
   orders o,
   encntr_loc_hist elh,
   si_audit si,
   messaging_audit ma
  PLAN (si
   WHERE si.msg_trig_action_txt IN ("NEWRX", "REFRES")
    AND si.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   JOIN (ma
   WHERE ma.rx_identifier=si.msg_ident
    AND ma.publish_ind=1
    AND ma.status_cd IN (error_cd, inerror_cd, errorretry_cd)
    AND ma.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   JOIN (o
   WHERE ma.order_id=o.order_id
    AND ((o.orderable_type_flag+ 0) != 6)
    AND ((o.encntr_id+ 0) > 0))
   JOIN (oa
   WHERE o.order_id=oa.order_id
    AND oa.action_type_cd=order_cd
    AND oa.template_order_flag IN (0, 1, 5))
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.beg_effective_dt_tm <= oa.action_dt_tm
    AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
    AND elh.active_ind=1)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   si.msg_trig_action_txt, elh.loc_facility_cd, elh.loc_nurse_unit_cd,
   elh.encntr_type_cd, o.activity_type_cd, ma.status_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "TX_ELECTRONIC_ERROR", dsr->qual[qualcnt].qual[ds_cnt]
   .stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(elh.loc_facility_cd),"||",
    uar_get_code_meaning(elh.loc_facility_cd),
    "||",elh.loc_facility_cd,"||",uar_get_code_display(elh.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(elh.loc_nurse_unit_cd),"||",elh.loc_nurse_unit_cd,"||",uar_get_code_display(
     elh.encntr_type_cd),
    "||",uar_get_code_meaning(elh.encntr_type_cd),"||",elh.encntr_type_cd,"||",
    oa.order_provider_id,"||",oa.action_personnel_id,"||",o.orig_ord_as_flag,
    "||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o.activity_type_cd),"||",
    o.activity_type_cd,"||",uar_get_code_display(ma.status_cd),"||",uar_get_code_meaning(ma.status_cd
     ),
    "||",ma.status_cd,"||",si.msg_trig_action_txt), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val
    = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1), dtl_cnt = (dtl_cnt+ 1)
  FOOT REPORT
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   IF (dtl_cnt=0)
    dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].
    stat_name = "TX_ELECTRONIC_ERROR", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
    ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+ 1)
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("UE_ERX_ENCOUNTER - TX_ELECTRONIC_ERROR")
 SET dtl_cnt = 0
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  si.msg_trig_action_txt, o.activity_type_cd, ma.status_cd,
  cnt = count(1)
  FROM order_action oa,
   orders o,
   si_audit si,
   messaging_audit ma
  PLAN (si
   WHERE si.msg_trig_action_txt IN ("NEWRX", "REFRES")
    AND si.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   JOIN (ma
   WHERE ma.rx_identifier=si.msg_ident
    AND ma.publish_ind=1
    AND ma.status_cd IN (error_cd, inerror_cd, errorretry_cd)
    AND ma.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   JOIN (o
   WHERE ma.order_id=o.order_id
    AND ((o.orderable_type_flag+ 0) != 6)
    AND ((o.encntr_id+ 0) > 0))
   JOIN (oa
   WHERE o.order_id=oa.order_id
    AND oa.action_type_cd=order_cd
    AND oa.template_order_flag IN (0, 1, 5)
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM encntr_loc_hist elh
    WHERE elh.encntr_id=o.encntr_id
     AND elh.beg_effective_dt_tm <= oa.action_dt_tm
     AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
     AND elh.active_ind=1
     AND ((elh.encntr_id+ 0) > 0)))))
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   o.activity_type_cd, ma.status_cd, si.msg_trig_action_txt
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "TX_ELECTRONIC_ERROR", dsr->qual[qualcnt].qual[ds_cnt]
   .stat_str_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",oa.order_provider_id,"||",oa.action_personnel_id,
    "||",o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",
    uar_get_code_meaning(o.activity_type_cd),"||",o.activity_type_cd,"||",uar_get_code_display(ma
     .status_cd),
    "||",uar_get_code_meaning(ma.status_cd),"||",ma.status_cd,"||",
    si.msg_trig_action_txt), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1), dtl_cnt = (dtl_cnt+ 1)
  FOOT REPORT
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   IF (dtl_cnt=0)
    dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].
    stat_name = "TX_ELECTRONIC_ERROR", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
    ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+ 1)
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("UE_ERX_ENCOUNTER - TX_ELECTRONIC_ERROR ;No encounter")
 SET stat_seq = 0
 SET dtl_cnt = 0
 IF (checkdic("IB_RX_REQ","T",0)=2)
  SELECT INTO "nl:"
   ibr.to_prsnl_id, cnt = count(DISTINCT ibr.ib_rx_req_id)
   FROM task_activity ta,
    task_subactivity ts,
    ib_rx_req ibr
   PLAN (ta
    WHERE ta.updt_dt_tm >= cnvtdatetime(ds_begin_snapshot)
     AND ta.task_type_cd IN (rxnonmatch_cd, rxrenewal_cd, rxsusmatch_cd)
     AND ta.person_id >= 0)
    JOIN (ts
    WHERE ta.task_id=ts.task_id)
    JOIN (ibr
    WHERE ts.ib_rx_req_id=ibr.ib_rx_req_id
     AND ibr.to_prsnl_id > 0
     AND ibr.create_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   GROUP BY ibr.to_prsnl_id
   HEAD REPORT
    IF (ds_cnt=1)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
    ENDIF
   DETAIL
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "ELECTRONIC_RENWAL_RCVD", dsr->qual[qualcnt].qual[
    ds_cnt].stat_str_val = build(ibr.to_prsnl_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val =
    cnt,
    dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
    stat_seq, ds_cnt = (ds_cnt+ 1),
    stat_seq = (stat_seq+ 1), dtl_cnt = (dtl_cnt+ 1)
   FOOT REPORT
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    IF (dtl_cnt=0)
     dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].
     stat_name = "ELECTRONIC_RENWAL_RCVD", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
     ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+ 1)
    ENDIF
   WITH nocounter, nullreport
  ;end select
 ELSE
  IF (mod(ds_cnt,10)=1)
   SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
  ENDIF
  IF (dtl_cnt=0)
   SET dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA"
   SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = "ELECTRONIC_RENWAL_RCVD"
   SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
   SET ds_cnt = (ds_cnt+ 1)
   SET stat_seq = (stat_seq+ 1)
  ENDIF
 ENDIF
 CALL dsvm_error("UE_ERX_ENCOUNTER - ELECTRONIC_RENWAL_RCVD")
 SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt - 1))
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
  ENDIF
 END ;Subroutine
 EXECUTE dm_stat_snaps_load
END GO
