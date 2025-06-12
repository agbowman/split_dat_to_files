CREATE PROGRAM bhs_gvw_gyn_gen_testing:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 s_gyn_gen_testing = vc
     2 f_gyn_gen_testing_date = f8
     2 s_gyn_gen_testing_date = vc
 ) WITH protect
 DECLARE mf_gynoncgenetictesting_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GYNONCGENETICTESTING"))
 DECLARE mf_gynoncgenetictestingdate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GYNONCGENETICTESTINGDATE"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
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
 DECLARE ms_hi = vc WITH protect, constant("\pard\fi-2800\li2800 ")
 DECLARE ms_rtfeof = vc WITH protect, constant("}")
 DECLARE mf_per_id = f8 WITH protect, noconstant(0.00)
 DECLARE md_reg_dt_tm = dq8 WITH protect
 DECLARE ms_text_temp = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 SET mf_per_id = request->person[1].person_id
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_date_result cdr
  PLAN (ce
   WHERE ce.person_id=mf_per_id
    AND ce.event_cd IN (mf_gynoncgenetictesting_cd, mf_gynoncgenetictestingdate_cd)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.task_assay_cd > 0.00
    AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd))
   JOIN (cdr
   WHERE (cdr.event_id= Outerjoin(ce.event_id))
    AND (cdr.valid_until_dt_tm= Outerjoin(ce.valid_until_dt_tm)) )
  ORDER BY ce.event_end_dt_tm DESC, ce.parent_event_id, ce.event_cd
  HEAD REPORT
   ml_cnt = 0
  HEAD ce.event_end_dt_tm
   null
  HEAD ce.parent_event_id
   ml_cnt += 1, m_rec->l_cnt = ml_cnt, stat = alterlist(m_rec->qual,ml_cnt)
  HEAD ce.event_cd
   CASE (ce.event_cd)
    OF mf_gynoncgenetictestingdate_cd:
     m_rec->qual[ml_cnt].s_gyn_gen_testing_date = format(cdr.result_dt_tm,"mm/dd/yy;;D"),m_rec->qual[
     ml_cnt].f_gyn_gen_testing_date = cdr.result_dt_tm
    OF mf_gynoncgenetictesting_cd:
     m_rec->qual[ml_cnt].s_gyn_gen_testing = trim(ce.result_val)
   ENDCASE
  WITH nocounter
 ;end select
 IF (ml_cnt < 1)
  GO TO exit_script
 ENDIF
 SET ms_text_temp = ms_rhead
 SET reply->text = ms_text_temp
 SET ms_text_temp = concat(ms_rh2b,"{Gyn Genetic Testing}",ms_reol)
 SET reply->text = concat(reply->text," ",ms_text_temp)
 IF ((reqinfo->updt_task=3202004))
  SET ms_text_temp = concat("\trowd\trgaph30\cellx4000\cellx8000\intbl",ms_wb,
   "{Gyn Genetic Testing} ","\cell ",ms_wb,
   "{Gyn Genetic Testing Date} ","\cell ","\row ")
  SET reply->text = concat(reply->text," ",ms_text_temp)
 ENDIF
 SELECT INTO "nl:"
  gyn_gen_testing_date = m_rec->qual[d.seq].f_gyn_gen_testing_date
  FROM (dummyt d  WITH seq = m_rec->l_cnt)
  ORDER BY gyn_gen_testing_date DESC
  DETAIL
   IF ((reqinfo->updt_task=3202004))
    ms_text_temp = concat("\trowd\trgaph30\cellx4000\cellx8000\intbl",ms_wr,"{",trim(m_rec->qual[d
      .seq].s_gyn_gen_testing),"} ",
     "\cell ",ms_wr,"{",trim(m_rec->qual[d.seq].s_gyn_gen_testing_date),"} ",
     "\cell ","\row "), reply->text = concat(reply->text," ",ms_text_temp)
   ELSE
    ms_text_temp = concat(ms_wb,ms_hi,"{Gyn Genetic Testing: } ",ms_wr,"{",
     trim(m_rec->qual[d.seq].s_gyn_gen_testing),"} ",ms_reol,ms_wb,"{Gyn Genetic Testing Date: } ",
     ms_wr,"{",trim(m_rec->qual[d.seq].s_gyn_gen_testing_date),"} ",ms_reol,
     ms_reol), reply->text = concat(reply->text," ",ms_text_temp)
   ENDIF
  WITH nocounter
 ;end select
 SET ms_text_temp = concat(ms_reol,ms_rtfeof)
 SET reply->text = concat(reply->text," ",ms_text_temp)
#exit_script
 SET reply->status_data.status = "S"
END GO
