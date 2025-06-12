CREATE PROGRAM bhs_gvw_active_kcl_ord:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
  SET request->visit[1].encntr_id = 0.0
  SET request->output_device = "MINE"
  SET request->visit_cnt = 1
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 ord[*]
     2 s_order_mnemonic = vc
     2 s_order_disp_line = vc
     2 s_order_dt_tm = vc
 ) WITH protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mf_kcl_syn_id = f8 WITH protect, noconstant(0.0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_person_id = f8 WITH protect, noconstant(0)
 DECLARE mf_pharm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE mf_kcl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"POTASSIUMCHLORIDE"))
 DECLARE mf_encntr_id = f8 WITH protect, constant(request->visit[1].encntr_id)
 CALL echo(concat("pharm cd: ",trim(cnvtstring(mf_pharm_cd))))
 CALL echo(concat("kcl_cd: ",trim(cnvtstring(mf_kcl_cd))))
 DECLARE ms_wb = vc WITH protect, constant("{\b\cb2")
 DECLARE ms_uf = vc WITH protect, constant(" }")
 DECLARE ms_reol = vc WITH protect, constant("\par ")
 DECLARE ms_pard = vc WITH protect, constant("\pard ")
 DECLARE ms_rtab = vc WITH protect, constant("\tab ")
 DECLARE ms_wr = vc WITH protect, constant("\f0 \fs18 \cb2 ")
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE ocs.catalog_cd=mf_kcl_cd
    AND ocs.catalog_type_cd=mf_pharm_cd
    AND ocs.active_ind=1
    AND ocs.mnemonic_key_cap="POTASSIUM CHLORIDE 4 MEQ/10 ML IVPB")
  HEAD ocs.synonym_id
   mf_kcl_syn_id = ocs.synonym_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=mf_encntr_id
    AND e.active_ind=1)
  HEAD e.encntr_id
   mf_person_id = e.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.catalog_cd=mf_kcl_cd
    AND o.catalog_type_cd=mf_pharm_cd
    AND o.synonym_id=mf_kcl_syn_id
    AND o.encntr_id=mf_encntr_id
    AND o.person_id=mf_person_id
    AND o.orig_order_dt_tm >= cnvtlookbehind("24,H",sysdate))
  ORDER BY o.orig_order_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1),
   CALL echo(build2("order: ",pl_cnt)), stat = alterlist(m_rec->ord,pl_cnt),
   CALL echo(concat("order mnemonic: ",o.order_mnemonic)),
   CALL echo(concat("catalog_cd: ",uar_get_code_display(o.catalog_cd))),
   CALL echo(concat("clin disp line: ",o.clinical_display_line)),
   CALL echo(concat("dept misc line: ",o.dept_misc_line)),
   CALL echo(concat("hna mnemonic: ",o.hna_order_mnemonic)),
   CALL echo(concat("order detail disp line: ",o.order_detail_display_line)),
   CALL echo(concat("ordered as mnemonic: ",o.ordered_as_mnemonic)),
   CALL echo(concat("simplified disp line: ",o.simplified_display_line)), m_rec->ord[pl_cnt].
   s_order_mnemonic = trim(o.ordered_as_mnemonic),
   m_rec->ord[pl_cnt].s_order_disp_line = trim(o.clinical_display_line), m_rec->ord[pl_cnt].
   s_order_dt_tm = concat("ordered: ",trim(format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")))
  WITH nocounter
 ;end select
 SET ms_tmp = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fs8\fswiss\fcharset0 Arial;}}"
 IF (size(m_rec->ord,5) > 0)
  FOR (ml_cnt = 1 TO size(m_rec->ord,5))
    SET ms_tmp = concat(ms_tmp,ms_wr,ms_wb," ",m_rec->ord[ml_cnt].s_order_mnemonic,
     " ",m_rec->ord[ml_cnt].s_order_dt_tm," \b0 ",ms_wr," ",
     m_rec->ord[ml_cnt].s_order_disp_line,ms_reol,ms_pard)
  ENDFOR
  SET reply->text = concat(ms_tmp,"}}")
 ELSE
  SET reply->text = ""
 ENDIF
 CALL echorecord(reply)
END GO
