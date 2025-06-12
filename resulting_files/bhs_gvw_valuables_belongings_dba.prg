CREATE PROGRAM bhs_gvw_valuables_belongings:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
    1 large_text_qual[*]
      2 text_segment = vc
  )
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 f_grid_event_cd = f8
   1 l_rcnt = i4
   1 rlst[*]
     2 f_event_cd = f8
     2 c_display = vc
     2 l_ccnt = i4
     2 clst[*]
       3 f_task_assay_cd = f8
       3 f_event_cd = f8
       3 c_display = vc
       3 c_value = vc
 )
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
 DECLARE mf_enc_id = f8 WITH protect, noconstant(0.00)
 DECLARE mf_per_id = f8 WITH protect, noconstant(0.00)
 DECLARE md_reg_dt_tm = dq8 WITH protect
 DECLARE ml_rcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_dcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loopr = i4 WITH protect, noconstant(0)
 DECLARE ml_loopc = i4 WITH protect, noconstant(0)
 DECLARE ml_cellsize = i4 WITH protect, noconstant(0)
 DECLARE ms_tabledef = vc WITH protect, noconstant(" ")
 DECLARE ms_headerrow = vc WITH protect, noconstant(" ")
 DECLARE ms_border_string = vc WITH protect, noconstant(" ")
 SET mf_enc_id = request->visit[1].encntr_id
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=mf_enc_id)
  HEAD REPORT
   mf_per_id = e.person_id, md_reg_dt_tm = e.reg_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvpg,
   name_value_prefs nvpr,
   discrete_task_assay dtar,
   name_value_prefs nvpc,
   discrete_task_assay dtac
  PLAN (dfr
   WHERE dfr.description="Valuables and Belongings"
    AND dfr.active_ind=1)
   JOIN (dfd
   WHERE dfr.dcp_form_instance_id=dfd.dcp_form_instance_id
    AND dfd.active_ind=1)
   JOIN (dsr
   WHERE dfd.dcp_section_ref_id=dsr.dcp_section_ref_id
    AND dsr.active_ind=1)
   JOIN (dir
   WHERE dsr.dcp_section_instance_id=dir.dcp_section_instance_id
    AND dir.active_ind=1
    AND dir.description="Ultra Grid 4")
   JOIN (nvpg
   WHERE nvpg.parent_entity_id=dir.dcp_input_ref_id
    AND nvpg.active_ind=1
    AND nvpg.pvc_name="grid_event_cd")
   JOIN (nvpr
   WHERE nvpr.parent_entity_id=dir.dcp_input_ref_id
    AND nvpr.active_ind=1
    AND nvpr.pvc_name="discrete_task_assay2")
   JOIN (dtar
   WHERE dtar.task_assay_cd=nvpr.merge_id
    AND dtar.active_ind=1)
   JOIN (nvpc
   WHERE nvpc.parent_entity_id=dir.dcp_input_ref_id
    AND nvpc.active_ind=1
    AND nvpc.pvc_name="discrete_task_assay")
   JOIN (dtac
   WHERE dtac.task_assay_cd=nvpc.merge_id
    AND dtac.active_ind=1)
  ORDER BY nvpr.sequence, nvpc.sequence
  HEAD REPORT
   m_rec->f_grid_event_cd = nvpg.merge_id, ml_rcnt = 0, ms_border_string =
   "\clvertalt\clbrdrl\brdrs\brdrw10\clbrdrt\brdrs\brdrw10\clbrdrr\brdrs\brdrw10\clbrdrb\brdrs\brdrw10",
   ms_tabledef = "\trowd\trgaph108\trleft-180\trpaddl75\trpaddr75\trpaddfl3\trpaddfr3", ml_cellsize
    = 2000, ms_tabledef = concat(ms_tabledef,ms_border_string,"\cellx",build(ml_cellsize)),
   ml_cellsize += 2000, ms_headerrow = concat(ms_wb,"{ } \cell ")
  HEAD nvpr.sequence
   ml_rcnt += 1, m_rec->l_rcnt = ml_rcnt, stat = alterlist(m_rec->rlst,ml_rcnt),
   m_rec->rlst[ml_rcnt].f_event_cd = dtar.event_cd, m_rec->rlst[ml_rcnt].c_display = trim(
    uar_get_code_display(dtar.event_cd),3), ml_ccnt = 0
  HEAD nvpc.sequence
   ml_ccnt += 1, m_rec->rlst[ml_rcnt].l_ccnt = ml_ccnt, stat = alterlist(m_rec->rlst[ml_rcnt].clst,
    ml_ccnt),
   m_rec->rlst[ml_rcnt].clst[ml_ccnt].f_event_cd = dtac.event_cd, m_rec->rlst[ml_rcnt].clst[ml_ccnt].
   c_display = trim(uar_get_code_display(dtac.event_cd),3)
   IF (ml_rcnt=1)
    ms_tabledef = concat(ms_tabledef,ms_border_string,"\cellx",build(ml_cellsize)), ml_cellsize +=
    2000, ms_headerrow = concat(ms_headerrow,ms_wb,"{",trim(m_rec->rlst[ml_rcnt].clst[ml_ccnt].
      c_display,3),"} ",
     "\cell ")
   ENDIF
  FOOT REPORT
   ms_tabledef = concat(ms_tabledef,"\intbl"), ms_headerrow = concat(ms_headerrow,"\row")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = m_rec->l_rcnt),
   (dummyt d2  WITH seq = 1),
   clinical_event ceg,
   clinical_event cer,
   clinical_event cec
  PLAN (d1
   WHERE maxrec(d2,m_rec->rlst[d1.seq].l_ccnt))
   JOIN (ceg
   WHERE ceg.person_id=mf_per_id
    AND (ceg.event_cd=m_rec->f_grid_event_cd)
    AND ceg.event_end_dt_tm IN (
   (SELECT
    max(ceg0.event_end_dt_tm)
    FROM clinical_event ceg0
    WHERE ceg0.person_id=mf_per_id
     AND (ceg0.event_cd=m_rec->f_grid_event_cd)
     AND ceg0.event_end_dt_tm >= cnvtdatetime(md_reg_dt_tm)
     AND ceg0.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ceg0.encntr_id=mf_enc_id))
    AND ceg.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ceg.encntr_id=mf_enc_id)
   JOIN (cer
   WHERE cer.parent_event_id=ceg.event_id
    AND (cer.event_cd=m_rec->rlst[d1.seq].f_event_cd)
    AND cer.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (d2)
   JOIN (cec
   WHERE cec.parent_event_id=cer.event_id
    AND (cec.event_cd=m_rec->rlst[d1.seq].clst[d2.seq].f_event_cd)
    AND cec.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY ceg.event_end_dt_tm DESC, d1.seq, d2.seq,
   cec.event_end_dt_tm DESC
  HEAD ceg.event_end_dt_tm
   null
  HEAD d1.seq
   null
  HEAD d2.seq
   m_rec->rlst[d1.seq].clst[d2.seq].c_value = trim(cec.result_val)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SET reply->text = ms_rhead
 SET reply->text = concat(reply->text," ",ms_rh2b,"{Valuables & Belongings}",ms_reol)
 SET reply->text = concat(reply->text," ",ms_tabledef)
 SET reply->text = concat(reply->text," ",ms_headerrow)
 FOR (ml_loopr = 1 TO m_rec->l_rcnt)
   SET reply->text = concat(reply->text," ",ms_wb,"{",trim(m_rec->rlst[ml_loopr].c_display,3),
    "} ","\cell ")
   FOR (ml_loopc = 1 TO m_rec->rlst[ml_loopr].l_ccnt)
     SET reply->text = concat(reply->text," ",ms_wb,"{",trim(m_rec->rlst[ml_loopr].clst[ml_loopc].
       c_value,3),
      "} ","\cell ")
   ENDFOR
   SET reply->text = concat(reply->text," ","\row ")
 ENDFOR
 SET reply->text = concat(reply->text," ",ms_reol,ms_rtfeof)
#exit_script
 SET reply->status_data.status = "S"
END GO
