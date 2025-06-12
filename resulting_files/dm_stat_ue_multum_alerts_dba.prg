CREATE PROGRAM dm_stat_ue_multum_alerts:dba
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
 DECLARE dsvm_error(msg=vc) = null
 DECLARE stat_seq = i4 WITH protect, noconstant(0)
 DECLARE ms_snapshot_type = vc WITH protect, constant("UE_MULTUM_ALERTS.2")
 DECLARE ml_idx = i4
 DECLARE ml_pos = i4
 DECLARE mn_cvg_size = i4
 DECLARE cvg_parent_val = f8 WITH protect, noconstant(0)
 SET ds_begin_snapshot = cnvtdatetime((curdate - 1),0)
 SET ds_end_snapshot = cnvtdatetime((curdate - 1),235959)
 FREE RECORD code_value_groups
 RECORD code_value_groups(
   1 qual[*]
     2 child_code_value = f8
     2 parent_code_value = f8
 )
 DECLARE cnt = f8 WITH protect, noconstant(0)
 SET ds_cnt = 1
 SET pos_cnt = 0
 SELECT INTO "nl:"
  cvg.child_code_value, cvg.parent_code_value
  FROM code_value_group cvg
  WHERE (cvg.parent_code_value=
  (SELECT
   c.code_value
   FROM code_value c
   WHERE c.code_set=69
    AND c.code_value=cvg.parent_code_value))
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(code_value_groups->qual,(ds_cnt+ 9))
   ENDIF
   code_value_groups->qual[ds_cnt].child_code_value = cvg.child_code_value, code_value_groups->qual[
   ds_cnt].parent_code_value = cvg.parent_code_value, ds_cnt = (ds_cnt+ 1)
  FOOT REPORT
   mn_cvg_size = (ds_cnt - 1), stat = alterlist(code_value_groups->qual,mn_cvg_size)
  WITH nocounter
 ;end select
 SET ds_cnt = 1
 SET qualcnt = 0
 SET stat_seq = 0
 RECORD eksdlgevent(
   1 qual_cnt = i4
   1 status = c1
   1 status_msg = vc
   1 qual[*]
     2 dlg_event_id = f8
     2 dlg_name = vc
     2 module_name = c30
     2 dlg_prsnl_id = f8
     2 updt_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 long_text_id = f8
     2 trigger_entity_id = f8
     2 trigger_entity_name = c32
     2 trigger_order_id = f8
     2 override_reason_cd = f8
     2 long_text_id = f8
     2 alert_long_text_id = f8
     2 srcstring = vc
     2 catdisp = c40
     2 severity = vc
     2 attr_cnt = i4
     2 attr[*]
       3 attr_name = c32
       3 attr_id = f8
       3 attr_value = vc
 )
 INSERT  FROM shared_value_gttd ovrdtmp
  (ovrdtmp.source_entity_value, ovrdtmp.source_entity_name)(SELECT
   override_reason_cd = bdv.parent_entity_id, "DM_EKS_OVERRIDE"
   FROM br_datamart_category b,
    br_datamart_report bdr,
    br_datamart_report_filter_r bdrf,
    br_datamart_filter bd,
    br_datamart_value bdv
   WHERE b.category_mean="MP_MCDS"
    AND bdr.br_datamart_category_id=b.br_datamart_category_id
    AND bdrf.br_datamart_report_id=bdr.br_datamart_report_id
    AND bd.br_datamart_filter_id=bdrf.br_datamart_filter_id
    AND bd.filter_category_mean="OVERRIDE_REASON_CDS"
    AND bd.filter_mean != "OR_ALLERGY"
    AND bd.filter_mean != "OR_DRUGDRUG"
    AND bd.filter_mean != "OR_DRUGFOOD"
    AND bd.filter_mean != "OR_DUPTHER"
    AND bd.filter_mean != "OR_ALL"
    AND bdv.br_datamart_category_id=bd.br_datamart_category_id
    AND bdv.br_datamart_filter_id=bd.br_datamart_filter_id
    AND ((bdv.end_effective_dt_tm > sysdate) UNION (
   (SELECT
    override_reason_cd = cve.code_value, "DM_EKS_OVERRIDE"
    FROM code_value_extension cve
    WHERE cve.code_set=800
     AND cve.field_value="1"
     AND cve.field_name IN ("HXIP", "IP", "RX", "IPRX")
     AND ((cve.code_value != 0) UNION (
    (SELECT
     override_reason_cd = cv.code_value, "DM_EKS_OVERRIDE"
     FROM code_value cv
     WHERE cv.code_set=800
      AND cv.cdf_meaning="CONTRAINDIC"
      AND cv.code_value != 0))) )))
   WITH rdbunion)
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  dlgname = trim(e.dlg_name)
  FROM eks_dlg_event e,
   eks_dlg_event_attr ea
  PLAN (e
   WHERE e.dlg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND e.dlg_name="MUL_MED*"
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM shared_value_gttd ovrdtmp
    WHERE ovrdtmp.source_entity_name="DM_EKS_OVERRIDE"
     AND ovrdtmp.source_entity_value=e.override_reason_cd))))
   JOIN (ea
   WHERE outerjoin(e.dlg_event_id)=ea.dlg_event_id)
  ORDER BY e.dlg_event_id
  HEAD REPORT
   rec_cnt = 0
  HEAD e.dlg_event_id
   rec_cnt = (rec_cnt+ 1)
   IF (mod(rec_cnt,100)=1)
    stat = alterlist(eksdlgevent->qual,(rec_cnt+ 99))
   ENDIF
   eksdlgevent->qual[rec_cnt].dlg_event_id = e.dlg_event_id, eksdlgevent->qual[rec_cnt].dlg_name =
   dlgname, exclptr = findstring("!",dlgname)
   IF (exclptr)
    eksdlgevent->qual[rec_cnt].module_name = substring((exclptr+ 1),(size(dlgname) - exclptr),dlgname
     )
   ELSE
    eksdlgevent->qual[rec_cnt].module_name = dlgname
   ENDIF
   eksdlgevent->qual[rec_cnt].dlg_prsnl_id = e.dlg_prsnl_id, eksdlgevent->qual[rec_cnt].updt_dt_tm =
   e.dlg_dt_tm, eksdlgevent->qual[rec_cnt].person_id = e.person_id,
   eksdlgevent->qual[rec_cnt].encntr_id = e.encntr_id, eksdlgevent->qual[rec_cnt].long_text_id = e
   .long_text_id, eksdlgevent->qual[rec_cnt].trigger_entity_id = e.trigger_entity_id,
   eksdlgevent->qual[rec_cnt].trigger_entity_name = e.trigger_entity_name, eksdlgevent->qual[rec_cnt]
   .trigger_order_id = e.trigger_order_id, eksdlgevent->qual[rec_cnt].override_reason_cd = e
   .override_reason_cd,
   eksdlgevent->qual[rec_cnt].long_text_id = e.long_text_id, eksdlgevent->qual[rec_cnt].
   alert_long_text_id = e.alert_long_text_id, eksdlgevent->qual[rec_cnt].attr_cnt = 0,
   attr_cnt = 0
  DETAIL
   IF (ea.dlg_event_id > 0)
    attr_cnt = (attr_cnt+ 1)
    IF (mod(attr_cnt,10)=1)
     stat = alterlist(eksdlgevent->qual[rec_cnt].attr,(attr_cnt+ 9))
    ENDIF
    eksdlgevent->qual[rec_cnt].attr[attr_cnt].attr_name = ea.attr_name, eksdlgevent->qual[rec_cnt].
    attr[attr_cnt].attr_id = ea.attr_id, eksdlgevent->qual[rec_cnt].attr[attr_cnt].attr_value = ea
    .attr_value
    IF (trim(ea.attr_name) IN ("CATALOG_CD", "ORDER_CATALOG")
     AND ea.attr_id > 0)
     eksdlgevent->qual[rec_cnt].catdisp = uar_get_code_display(ea.attr_id)
    ELSEIF (trim(ea.attr_name)="MAJOR_CONTRAINDICATED_IND"
     AND trim(ea.attr_value)="1")
     eksdlgevent->qual[rec_cnt].severity = "4"
    ELSEIF (trim(ea.attr_name)="SEVERITY*"
     AND trim(eksdlgevent->qual[rec_cnt].severity) != "4")
     eksdlgevent->qual[rec_cnt].severity = trim(ea.attr_value)
    ENDIF
   ENDIF
  FOOT  e.dlg_event_id
   stat = alterlist(eksdlgevent->qual[rec_cnt].attr,attr_cnt), eksdlgevent->qual[rec_cnt].attr_cnt =
   attr_cnt
  FOOT REPORT
   stat = alterlist(eksdlgevent->qual,rec_cnt), eksdlgevent->qual_cnt = rec_cnt, eksdlgevent->status
    = "S",
   eksdlgevent->status_msg = build(rec_cnt," qualifying records were found")
  WITH nocounter
 ;end select
 IF ((eksdlgevent->qual_cnt=0))
  SET qualcnt = (qualcnt+ 1)
  SET stat = alterlist(dsr->qual,qualcnt)
  SET dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot)
  SET dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
  SET stat = alterlist(dsr->qual[qualcnt].qual,1)
  SET dsr->qual[qualcnt].qual[1].stat_name = "NO_NEW_DATA"
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = eksdlgevent->qual_cnt),
    (dummyt d2  WITH seq = eksdlgevent->qual[d1.seq].attr_cnt),
    nomenclature n
   PLAN (d1
    WHERE maxrec(d2,eksdlgevent->qual[d1.seq].attr_cnt))
    JOIN (d2
    WHERE (eksdlgevent->qual[d1.seq].attr[d2.seq].attr_name="NOMENCLATURE_ID")
     AND (eksdlgevent->qual[d1.seq].attr[d2.seq].attr_id > 0))
    JOIN (n
    WHERE (eksdlgevent->qual[d1.seq].attr[d2.seq].attr_id=n.nomenclature_id))
   DETAIL
    eksdlgevent->qual[d1.seq].srcstring = n.source_string
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   dlgdttm = format(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm),"yyyy/mm/dd hh:mm:ss;;d"),
   trigger = trim(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id)), dlgname =
   substring(1,255,eksdlgevent->qual[d1.seq].dlg_name),
   reason = trim(uar_get_code_display(eksdlgevent->qual[d1.seq].override_reason_cd)), ft_reason =
   IF (lt.long_text_id > 0) substring(1,75,lt.long_text)
   ELSE " "
   ENDIF
   , allergy = substring(1,50,eksdlgevent->qual[d1.seq].srcstring),
   interaction = trim(eksdlgevent->qual[d1.seq].catdisp), severity = substring(1,10,eksdlgevent->
    qual[d1.seq].severity), headval = build(trim(uar_get_code_display(eksdlgevent->qual[d1.seq].
      trigger_entity_id)),substring(1,255,eksdlgevent->qual[d1.seq].dlg_name),trim(
     uar_get_code_display(eksdlgevent->qual[d1.seq].override_reason_cd)),
    IF (lt.long_text_id > 0) substring(1,75,lt.long_text)
    ELSE " "
    ENDIF
    ,substring(1,50,eksdlgevent->qual[d1.seq].srcstring),
    trim(eksdlgevent->qual[d1.seq].catdisp),eksdlgevent->qual[d1.seq].severity,eksdlgevent->qual[d1
    .seq].dlg_prsnl_id)
   FROM (dummyt d1  WITH seq = eksdlgevent->qual_cnt),
    encounter e,
    long_text lt
   PLAN (d1)
    JOIN (lt
    WHERE outerjoin(eksdlgevent->qual[d1.seq].long_text_id)=lt.long_text_id)
    JOIN (e
    WHERE (eksdlgevent->qual[d1.seq].encntr_id=e.encntr_id))
   ORDER BY eksdlgevent->qual[d1.seq].updt_dt_tm, trim(uar_get_code_display(eksdlgevent->qual[d1.seq]
      .trigger_entity_id)), substring(1,255,eksdlgevent->qual[d1.seq].dlg_name),
    trim(uar_get_code_display(eksdlgevent->qual[d1.seq].override_reason_cd)),
    IF (lt.long_text_id > 0) substring(1,75,lt.long_text)
    ELSE " "
    ENDIF
    , substring(1,50,eksdlgevent->qual[d1.seq].srcstring),
    trim(eksdlgevent->qual[d1.seq].catdisp), eksdlgevent->qual[d1.seq].severity, eksdlgevent->qual[d1
    .seq].dlg_prsnl_id
   HEAD REPORT
    IF (ds_cnt=1)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
    ENDIF
   HEAD headval
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    ml_idx = 0, ml_idx = locateval(ml_pos,(ml_idx+ 1),mn_cvg_size,e.encntr_type_cd,code_value_groups
     ->qual[ml_pos].child_code_value)
    IF (ml_idx > 0)
     cvg_parent_val = code_value_groups->qual[ml_idx].parent_code_value
    ELSE
     cvg_parent_val = 0
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_MULTUM_ALERTS", dsr->qual[qualcnt].qual[
    ds_cnt].stat_clob_val = build(trigger,"||",dlgname,"||",reason,
     "||",interaction,"||",severity,"||",
     uar_get_code_display(e.loc_facility_cd),"||",uar_get_code_meaning(e.loc_facility_cd),"||",e
     .loc_facility_cd,
     "||",uar_get_code_display(cvg_parent_val),"||",uar_get_code_meaning(cvg_parent_val),"||",
     cvg_parent_val,"||",uar_get_code_display(e.encntr_type_cd),"||",uar_get_code_meaning(e
      .encntr_type_cd),
     "||",e.encntr_type_cd,"||",eksdlgevent->qual[d1.seq].dlg_prsnl_id,"||",
     ft_reason,"||",allergy,"||"), dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1,
    dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), cnt = 0
   DETAIL
    cnt = (cnt+ 1)
   FOOT  headval
    dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt, ds_cnt = (ds_cnt+ 1)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   dlgdttm = format(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm),"yyyy/mm/dd hh:mm:ss;;d"),
   trigger = trim(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id)), dlgname =
   substring(1,255,eksdlgevent->qual[d1.seq].dlg_name),
   reason = trim(uar_get_code_display(eksdlgevent->qual[d1.seq].override_reason_cd)), interaction =
   trim(eksdlgevent->qual[d1.seq].catdisp), severity = substring(1,10,eksdlgevent->qual[d1.seq].
    severity),
   headval = build(trim(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id)),substring(
     1,255,eksdlgevent->qual[d1.seq].dlg_name),trim(uar_get_code_display(eksdlgevent->qual[d1.seq].
      override_reason_cd)),trim(eksdlgevent->qual[d1.seq].catdisp),eksdlgevent->qual[d1.seq].severity,
    eksdlgevent->qual[d1.seq].dlg_prsnl_id)
   FROM (dummyt d1  WITH seq = eksdlgevent->qual_cnt),
    encounter e,
    orders o
   PLAN (d1)
    JOIN (o
    WHERE (eksdlgevent->qual[d1.seq].trigger_order_id=o.order_id))
    JOIN (e
    WHERE (e.encntr_id=eksdlgevent->qual[d1.seq].encntr_id))
   ORDER BY eksdlgevent->qual[d1.seq].updt_dt_tm, trim(uar_get_code_display(eksdlgevent->qual[d1.seq]
      .trigger_entity_id)), substring(1,255,eksdlgevent->qual[d1.seq].dlg_name),
    trim(uar_get_code_display(eksdlgevent->qual[d1.seq].override_reason_cd)), trim(eksdlgevent->qual[
     d1.seq].catdisp), eksdlgevent->qual[d1.seq].severity,
    eksdlgevent->qual[d1.seq].dlg_prsnl_id
   HEAD REPORT
    IF (ds_cnt=1)
     qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
      = cnvtdatetime(ds_begin_snapshot),
     dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
    ENDIF
   HEAD headval
    pos_cnt = 0
   DETAIL
    IF (o.order_id=0)
     pos_cnt = (pos_cnt+ 1)
    ENDIF
   FOOT  headval
    IF (pos_cnt > 0)
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
     ENDIF
     ml_idx = 0, ml_idx = locateval(ml_pos,(ml_idx+ 1),mn_cvg_size,e.encntr_type_cd,code_value_groups
      ->qual[ml_pos].child_code_value)
     IF (ml_idx > 0)
      cvg_parent_val = code_value_groups->qual[ml_idx].parent_code_value
     ELSE
      cvg_parent_val = 0
     ENDIF
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_POSITIVE_MULTUM_ALERTS", dsr->qual[qualcnt].
     qual[ds_cnt].stat_clob_val = build(trigger,"||",dlgname,"||",reason,
      "||",interaction,"||",severity,"||",
      uar_get_code_display(e.loc_facility_cd),"||",uar_get_code_meaning(e.loc_facility_cd),"||",e
      .loc_facility_cd,
      "||",uar_get_code_display(cvg_parent_val),"||",uar_get_code_meaning(cvg_parent_val),"||",
      cvg_parent_val,"||",uar_get_code_display(e.encntr_type_cd),"||",uar_get_code_meaning(e
       .encntr_type_cd),
      "||",e.encntr_type_cd,"||",eksdlgevent->qual[d1.seq].dlg_prsnl_id), dsr->qual[qualcnt].qual[
     ds_cnt].stat_type = 1,
     dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), dsr->qual[qualcnt
     ].qual[ds_cnt].stat_number_val = pos_cnt,
     ds_cnt = (ds_cnt+ 1)
    ENDIF
   WITH nocounter, outerjoin = d1
  ;end select
  IF (ds_cnt > 0)
   SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt - 1))
  ENDIF
 ENDIF
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
  ENDIF
 END ;Subroutine
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
#exit_program
END GO
