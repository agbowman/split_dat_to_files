CREATE PROGRAM bhs_gvw_sn_surgical_case:dba
 FREE RECORD m_surg
 RECORD m_surg(
   1 c_surg_area = c100
   1 c_surg_case_nbr = c100
   1 c_surg_case_dt = c20
   1 c_surg_case_start_tm = c20
   1 c_surg_case_stop_tm = c20
   1 c_asa_class = c1
   1 c_case_level = c100
   1 c_would_class = c100
   1 s_operation = vc
   1 s_surgeons = vc
   1 s_assistants = vc
   1 s_anesth_type = vc
   1 s_anesth = vc
   1 s_other = vc
 ) WITH protect
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
 DECLARE ms_hi = vc WITH protect, constant("\pard\fi-1050\li1050 ")
 DECLARE ms_rtfeof = vc WITH protect, constant("}")
 DECLARE mf_enc_id = f8 WITH protect, noconstant(0.00)
 DECLARE mf_per_id = f8 WITH protect, noconstant(0.00)
 DECLARE mf_surg_case_id = f8 WITH protect, noconstant(0.00)
 DECLARE ms_proc_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_text_temp = vc WITH protect, noconstant(" ")
 SET mf_enc_id = request->visit[1].encntr_id
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=mf_enc_id)
  HEAD REPORT
   mf_per_id = e.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surgical_case sc
  PLAN (sc
   WHERE sc.encntr_id=mf_enc_id
    AND sc.surg_start_dt_tm != null)
  ORDER BY sc.surg_start_dt_tm DESC
  HEAD REPORT
   mf_surg_case_id = sc.surg_case_id
  WITH nocounter
 ;end select
 IF (mf_surg_case_id=0.00)
  SET reply->text = concat(ms_rhead,ms_rh2r,"{No Surgery Data Found}",ms_rtfeof)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM surgical_case sc,
   surg_case_procedure scp,
   prsnl pr,
   orders o
  PLAN (sc
   WHERE sc.surg_case_id=mf_surg_case_id)
   JOIN (scp
   WHERE scp.surg_case_id=sc.surg_case_id)
   JOIN (pr
   WHERE pr.person_id=scp.primary_surgeon_id)
   JOIN (o
   WHERE (o.order_id= Outerjoin(scp.order_id)) )
  ORDER BY scp.primary_proc_ind
  HEAD REPORT
   m_surg->c_surg_area = trim(uar_get_code_display(sc.surg_area_cd)), m_surg->c_surg_case_nbr = trim(
    sc.surg_case_nbr_formatted), m_surg->c_surg_case_dt = format(sc.surg_start_dt_tm,"@SHORTDATE"),
   m_surg->c_surg_case_start_tm = format(sc.surg_start_dt_tm,"@TIMENOSECONDS"), m_surg->
   c_surg_case_stop_tm = format(sc.surg_stop_dt_tm,"@TIMENOSECONDS"), m_surg->c_asa_class = trim(
    uar_get_code_display(sc.asa_class_cd)),
   m_surg->c_case_level = trim(uar_get_code_display(sc.case_level_cd)), m_surg->c_would_class = trim(
    uar_get_code_display(sc.wound_class_cd)), m_surg->s_anesth_type = " ",
   m_surg->s_operation = " ", m_surg->s_surgeons = " ", m_surg->s_assistants = " ",
   m_surg->s_anesth = " ", m_surg->s_other = " "
  HEAD scp.primary_proc_ind
   null
  DETAIL
   ms_proc_temp = trim(uar_get_code_display(scp.surg_proc_cd))
   IF (scp.modifier > " ")
    ms_proc_temp = concat(ms_proc_temp," ",trim(scp.modifier))
   ENDIF
   IF (scp.primary_proc_ind=1)
    ms_proc_temp = concat(ms_proc_temp," (Primary Procedure)")
   ENDIF
   IF ((m_surg->s_operation=" "))
    m_surg->s_operation = concat("{",ms_proc_temp,"}")
   ELSE
    m_surg->s_operation = concat(m_surg->s_operation,ms_reol,"{",ms_proc_temp,"}")
   ENDIF
   CALL echo(build2("scp.anesth_type_cd: ",build(cnvtint(scp.anesth_type_cd))))
   IF (scp.anesth_type_cd > 0.00)
    IF ((m_surg->s_anesth_type=" "))
     m_surg->s_anesth_type = concat("{",trim(uar_get_code_display(scp.anesth_type_cd)),"}")
    ELSE
     m_surg->s_anesth_type = concat(m_surg->s_anesth_type,ms_reol,"{",trim(uar_get_code_display(scp
        .anesth_type_cd)),"}")
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  role_sort = evaluate2(
   IF (uar_get_code_display(ca.role_perf_cd) IN ("Primary Surgeon", "Second Surgeon",
   "Physician Assistant", "Physician", "Resident")) "SURGEON"
   ELSEIF (uar_get_code_display(ca.role_perf_cd) IN ("First Assistant", "Second Assistant",
   "Surgeon - Assist")) "ASSIST"
   ELSEIF (uar_get_code_display(ca.role_perf_cd) IN ("Att Anesthesiologist", "Res Anesthesiologist",
   "CRNA")) "ANESTH"
   ELSE "OTHER"
   ENDIF
   )
  FROM case_attendance ca,
   prsnl pr
  PLAN (ca
   WHERE ca.surg_case_id=mf_surg_case_id
    AND ca.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=ca.case_attendee_id)
  ORDER BY role_sort, ca.display_seq, pr.person_id
  HEAD role_sort
   null
  HEAD ca.display_seq
   null
  HEAD pr.person_id
   CASE (role_sort)
    OF "SURGEON":
     IF ((m_surg->s_surgeons=" "))
      m_surg->s_surgeons = concat("{",trim(pr.name_full_formatted)," (",trim(uar_get_code_display(ca
         .role_perf_cd)),")}")
     ELSE
      m_surg->s_surgeons = concat(m_surg->s_surgeons,ms_reol,"{",trim(pr.name_full_formatted)," (",
       trim(uar_get_code_display(ca.role_perf_cd)),")}")
     ENDIF
    OF "ASSIST":
     IF ((m_surg->s_assistants=" "))
      m_surg->s_assistants = concat("{",trim(pr.name_full_formatted)," (",trim(uar_get_code_display(
         ca.role_perf_cd)),")}")
     ELSE
      m_surg->s_assistants = concat(m_surg->s_assistants,ms_reol,"{",trim(pr.name_full_formatted),
       " (",
       trim(uar_get_code_display(ca.role_perf_cd)),")}")
     ENDIF
    OF "ANESTH":
     IF ((m_surg->s_anesth=" "))
      m_surg->s_anesth = concat("{",trim(pr.name_full_formatted)," (",trim(uar_get_code_display(ca
         .role_perf_cd)),")}")
     ELSE
      m_surg->s_anesth = concat(m_surg->s_anesth,ms_reol,"{",trim(pr.name_full_formatted)," (",
       trim(uar_get_code_display(ca.role_perf_cd)),")}")
     ENDIF
    OF "OTHER":
     IF ((m_surg->s_other=" "))
      m_surg->s_other = concat("{",trim(pr.name_full_formatted)," (",trim(uar_get_code_display(ca
         .role_perf_cd)),")}")
     ELSE
      m_surg->s_other = concat(m_surg->s_other,ms_reol,"{",trim(pr.name_full_formatted)," (",
       trim(uar_get_code_display(ca.role_perf_cd)),")}")
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dummyt d1
  HEAD REPORT
   ms_text_temp = ms_rhead, ms_text_temp = concat(ms_text_temp,ms_rh2r,"{",m_surg->c_surg_area,"}",
    ms_reol), ms_text_temp = concat(ms_text_temp,ms_wr,"{",m_surg->c_surg_case_nbr,"}",
    ms_reol),
   ms_text_temp = concat(ms_text_temp,ms_wr,"{Case Date: ",m_surg->c_surg_case_dt,"}",
    ms_reol), ms_text_temp = concat(ms_text_temp,ms_wr,"{Case Start: ",m_surg->c_surg_case_start_tm,
    "}",
    ms_rtab,"{Case Stop: ",m_surg->c_surg_case_stop_tm,"}",ms_reol), ms_text_temp = concat(
    ms_text_temp,ms_wr,"{ASA Class: ",m_surg->c_asa_class,"}",
    ms_rtab,ms_rtab,"{Case Level: ",m_surg->c_case_level,"}",
    ms_reol),
   ms_text_temp = concat(ms_text_temp,ms_wr,"{Wound Class: ",m_surg->c_would_class,"}",
    ms_reol), ms_text_temp = concat(ms_text_temp,ms_wb,"{Operation}",ms_wr,ms_reol), ms_text_temp =
   concat(ms_text_temp,ms_wr,m_surg->s_operation,ms_reol),
   ms_text_temp = concat(ms_text_temp,ms_wb,"{Surgeon(s)}",ms_wr,ms_reol), ms_text_temp = concat(
    ms_text_temp,ms_wr,m_surg->s_surgeons,ms_reol), ms_text_temp = concat(ms_text_temp,ms_wb,
    "{Assistant(s)}",ms_wr,ms_reol),
   ms_text_temp = concat(ms_text_temp,ms_wr,m_surg->s_assistants,ms_reol), ms_text_temp = concat(
    ms_text_temp,ms_wb,"{Anesthesia}",ms_wr,ms_reol), ms_text_temp = concat(ms_text_temp,ms_wr,m_surg
    ->s_anesth_type,ms_reol),
   ms_text_temp = concat(ms_text_temp,ms_wr,m_surg->s_anesth,ms_reol), ms_text_temp = concat(
    ms_text_temp,ms_rtfeof)
  FOOT REPORT
   reply->text = ms_text_temp
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
