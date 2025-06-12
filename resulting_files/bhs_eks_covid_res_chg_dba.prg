CREATE PROGRAM bhs_eks_covid_res_chg:dba
 RECORD m_rec(
   1 ord_qual[*]
     2 f_order_id = f8
   1 ce_qual[*]
     2 f_clinical_event_id = f8
 ) WITH protect
 DECLARE mf_encntr_id = f8 WITH protect, constant(trigger_encntrid)
 DECLARE mf_person_id = f8 WITH protect, constant(trigger_personid)
 DECLARE mf_lookbackdays = f8 WITH protect, constant( $1)
 DECLARE ms_module = vc WITH protect, constant(trim(eks_common->cur_module_name,3))
 DECLARE ms_rh2bl = vc WITH protect, constant("\pard\plain\f0\fs20\b ")
 DECLARE ms_rh2rl = vc WITH protect, constant("\pard\plain\f0\fs20 ")
 DECLARE ms_rhead = vc WITH protect, constant(
  "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}}\deftab750\plain \f0 \fs18 ")
 DECLARE ms_reol = vc WITH protect, constant("\par ")
 DECLARE ms_reop = vc WITH protect, constant("\pard ")
 DECLARE ms_rh2r = vc WITH protect, constant("\pard\plain\f0\fs18 ")
 DECLARE ms_rh2b = vc WITH protect, constant("\pard\plain\f0\fs18\b ")
 DECLARE ms_rh2bu = vc WITH protect, constant("\pard\plain\f0\fs18\b\ul ")
 DECLARE ms_rh2u = vc WITH protect, constant("\pard\plain\f0\fs18\u ")
 DECLARE ms_rh2i = vc WITH protect, constant("\pard\plain\f0\fs18\i ")
 DECLARE ms_rtab = vc WITH protect, constant("\tab ")
 DECLARE ms_rbopt = vc WITH protect, constant(
  "\pard \tx1200\tx1900\tx2650\tx3325\tx3800\tx4400\tx5050\tx5750\tx6500 ")
 DECLARE ms_wr = vc WITH protect, constant("\plain\f0\fs18 ")
 DECLARE ms_wb = vc WITH protect, constant("\plain\f0\fs18\b ")
 DECLARE ms_wu = vc WITH protect, constant("\plain\f0\fs18 \ul\b ")
 DECLARE ms_wbi = vc WITH protect, constant("\plain\f0\fs18\b\i ")
 DECLARE ms_ws = vc WITH protect, constant("\plain\f0\fs18\strike ")
 DECLARE ms_hi = vc WITH protect, constant("\pard\fi-2340\li2340 ")
 DECLARE ms_rtfeof = vc WITH protect, constant("}")
 DECLARE mn_result_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_order_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE mf_order_id = f8 WITH protect, noconstant(0)
 DECLARE mf_result_log_id = f8 WITH protect, noconstant(0)
 DECLARE mf_order_log_id = f8 WITH protect, noconstant(0)
 DECLARE mf_last_result_dt = f8 WITH protect, noconstant(0)
 DECLARE ms_result = vc WITH protect, noconstant("")
 DECLARE ms_mnemonic = vc WITH protect, noconstant("")
 DECLARE ms_temp_str = vc WITH protect, noconstant("")
 DECLARE ms_result_str = vc WITH protect, noconstant("")
 DECLARE ms_rtfhead = vc WITH protect, noconstant("")
 IF (validate(retval)=0)
  DECLARE retval = i4 WITH public, noconstant(0)
 ENDIF
 IF (validate(log_message)=0)
  DECLARE log_message = vc WITH public, noconstant("")
 ENDIF
 IF (validate(log_misc1)=0)
  DECLARE log_misc1 = vc WITH public, noconstant("")
 ENDIF
 SET ml_idx = locateval(ml_cnt,1,size(eksdata->tqual[tcurindex].qual,5),"COVID19ORD",cnvtupper(trim(
    eksdata->tqual[tcurindex].qual[ml_cnt].template_alias,3)))
 SET ml_idx2 = locateval(ml_cnt2,1,size(eksdata->tqual[tcurindex].qual,5),"COVID19RESULT",cnvtupper(
   trim(eksdata->tqual[tcurindex].qual[ml_cnt2].template_alias,3)))
 SET ms_rtfhead = build2("{\rtf1\ansi \deff0","{\fonttbl{\f0\fswiss MS Sans Serif;}}",
  "{\colortbl;\red0\green0\blue0;\red255\green255\blue255;\red255\green0\blue0;\red0\green0\blue255;}",
  "\deftab1500\plain \f0 \fs18 ")
 SET ms_temp_str = ms_rtfhead
 SET log_misc1 = ""
 SET ml_cnt = 0
 IF (ml_idx2 > 0)
  FOR (ml_loop = 1 TO size(eksdata->tqual[tcurindex].qual[ml_idx2].data,5))
    IF (trim(eksdata->tqual[tcurindex].qual[ml_idx2].data[ml_loop].misc,3) != "<CLINICAL_EVENT_ID>")
     SET ml_cnt += 1
     IF (mod(ml_cnt,10)=1)
      CALL alterlist(m_rec->ce_qual,(ml_cnt+ 9))
     ENDIF
     SET m_rec->ce_qual[ml_cnt].f_clinical_event_id = cnvtreal(trim(eksdata->tqual[tcurindex].qual[
       ml_idx2].data[ml_loop].misc,3))
    ENDIF
  ENDFOR
  CALL alterlist(m_rec->ce_qual,ml_cnt)
 ENDIF
 SET ml_cnt = 0
 SET ml_cnt2 = 0
 IF (size(m_rec->ce_qual,5) > 0)
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE expand(ml_cnt,1,size(m_rec->ce_qual,5),ce.clinical_event_id,m_rec->ce_qual[ml_cnt].
     f_clinical_event_id)
     AND ce.person_id=mf_person_id
     AND ce.event_end_dt_tm BETWEEN (sysdate - mf_lookbackdays) AND sysdate
     AND trim(cnvtupper(ce.result_val),3) IN ("PRESUMPTIVE POSITIVE", "POSITIVE", "DETECTED",
    "PRESUMPTIVE POS", "POSITIVE FOR COVID-19 ANTIGEN")
     AND ce.publish_flag=1
     AND ce.view_level=1
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   ORDER BY ce.event_end_dt_tm DESC
   HEAD REPORT
    mn_result_ind = 1, ms_result_str = ""
    IF (mf_order_id=0)
     mf_order_id = ce.order_id
    ENDIF
    IF (ce.event_end_dt_tm > mf_last_result_dt)
     ms_result = trim(cnvtupper(ce.result_val),3)
    ENDIF
    ms_temp_str = build2(ms_temp_str,ms_rh2rl)
   HEAD ce.clinical_event_id
    ms_result_str = build2("\cf3 {",trim(cnvtupper(ce.result_val),3),"}"), ms_temp_str = build2(
     ms_temp_str," {",trim(uar_get_code_display(ce.event_cd),3),": } ",ms_result_str,
     " \cf0 { (",trim(format(ce.event_end_dt_tm,"mm/dd/yy HH:mm;;D"),3),")}",ms_reol)
   WITH nocounter
  ;end select
 ENDIF
 IF (mn_result_ind=0)
  SET log_message = "There are no qualifying orders or results for this patient, returning false."
  SET retval = 0
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_log b,
   bhs_log_detail bd,
   bhs_log_detail bd2,
   bhs_log_detail bd3
  PLAN (b
   WHERE b.object_name="BHS_EKS_COVID_RES_CHG"
    AND (b.updt_id=reqinfo->updt_id)
    AND b.updt_dt_tm BETWEEN (sysdate - mf_lookbackdays) AND sysdate
    AND b.msg="005"
    AND b.parameters=ms_module)
   JOIN (bd
   WHERE bd.bhs_log_id=b.bhs_log_id
    AND bd.parent_entity_name="PERSON_ID"
    AND bd.parent_entity_id=mf_person_id)
   JOIN (bd2
   WHERE bd2.bhs_log_id=b.bhs_log_id
    AND bd2.parent_entity_name="ENCNTR_ID")
   JOIN (bd3
   WHERE bd3.bhs_log_id=b.bhs_log_id
    AND bd3.parent_entity_name="ORDER_ID")
  ORDER BY b.updt_dt_tm DESC, bd.updt_dt_tm DESC, bd2.updt_dt_tm DESC,
   bd3.updt_dt_tm DESC
  HEAD bd2.bhs_log_detail_id
   IF (((bd2.parent_entity_id != mf_encntr_id) OR (bd2.msg != ms_result)) )
    mf_result_log_id = bd2.bhs_log_detail_id
   ENDIF
  HEAD bd3.bhs_log_detail_id
   IF (bd3.parent_entity_id != mf_order_id)
    mf_order_log_id = bd3.bhs_log_detail_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET retval = 100
  SET log_message = "User has not received an alert for this result, returning true."
  EXECUTE bhs_hlp_ccl
  CALL bhs_sbr_log("start",ms_module,0,"",0.0,
   "","Begin Script","")
  CALL bhs_sbr_log("log","",1,"PERSON_ID",mf_person_id,
   "","","S")
  CALL bhs_sbr_log("log","",1,"ENCNTR_ID",mf_encntr_id,
   "RESULT",ms_result,"S")
  CALL bhs_sbr_log("log","",1,"ORDER_ID",mf_order_id,
   "MNEMONIC",ms_mnemonic,"S")
  CALL bhs_sbr_log("stop","",0,"",0.0,
   "","005","S")
 ELSEIF (((mf_result_log_id > 0) OR (mf_order_log_id > 0)) )
  SET retval = 100
  SET log_message =
  "User has not received an alert for this encounter/order/result change, returning true."
  IF (mf_result_log_id > 0)
   UPDATE  FROM bhs_log_detail bd
    SET bd.parent_entity_id = mf_encntr_id, bd.msg = ms_result, bd.updt_dt_tm = sysdate
    WHERE bd.bhs_log_detail_id=mf_result_log_id
    WITH nocounter
   ;end update
   COMMIT
  ENDIF
  IF (mf_order_log_id > 0)
   UPDATE  FROM bhs_log_detail bd
    SET bd.parent_entity_id = mf_order_id, bd.msg = ms_mnemonic, bd.updt_dt_tm = sysdate
    WHERE bd.bhs_log_detail_id=mf_order_log_id
    WITH nocounter
   ;end update
   COMMIT
  ENDIF
 ELSE
  SET retval = 0
  SET log_message =
  "User has already received an alert for this encounter/order/lab result, returning false."
 ENDIF
#exit_program
 IF (retval=100)
  SET log_misc1 = build(ms_temp_str,ms_rtfeof)
 ENDIF
 CALL echo(build2(";log_misc1: ",log_misc1))
 CALL echorecord(m_rec,build2("bhs_eks_covid_res_chg_",trim(cnvtstring(mf_person_id),3),"_mrec"),1)
 CALL echorecord(eksdata,build("bhs_eks_covid_res_chg_",trim(cnvtstring(mf_person_id),3),"_eksdata"),
  1)
END GO
