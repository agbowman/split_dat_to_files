CREATE PROGRAM bhs_gvw_pc_hosp_readmit_score:dba
 FREE RECORD m_hosprscore
 RECORD m_hosprscore(
   1 hrslst[*]
     2 s_label = vc
     2 s_result = vc
     2 s_date = vc
 ) WITH protect
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_deleted_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"DELETED"))
 DECLARE mf_hospitalreadmissionscore_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HOSPITALREADMISSIONSCORE"))
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
 DECLARE ms_wbu = vc WITH protect, constant("\plain\f0\fs18 \ul\b ")
 DECLARE ms_wbi = vc WITH protect, constant("\plain\f0\fs18\b\i ")
 DECLARE ms_ws = vc WITH protect, constant("\plain\f0\fs18\strike ")
 DECLARE ms_hi = vc WITH protect, constant("\pard\fi-1050\li1050 ")
 DECLARE ms_rtfeof = vc WITH protect, constant("}")
 DECLARE ml_hrsknt = i4 WITH protect, noconstant(0)
 IF ( NOT ((request->person[1].person_id > 0.00)))
  SET reply->text = concat(ms_rhead,ms_rh2r,"{No Person Found}",ms_rtfeof)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce1
  PLAN (ce1
   WHERE (ce1.person_id=request->person[1].person_id)
    AND ce1.event_cd=mf_hospitalreadmissionscore_cd
    AND ce1.event_end_dt_tm >= cnvtdatetime((curdate - 365),0)
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00")
    AND ce1.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd))
  ORDER BY ce1.event_cd, ce1.event_end_dt_tm DESC
  HEAD REPORT
   reply->text = ms_rhead, reply->text = concat(reply->text,ms_rh2b,"{Hospital}",ms_reol,ms_wb,
    "{Readmission}",ms_reol,ms_wbu,"{Score}",ms_rtab,
    ms_rtab,"{Date                              }",ms_reol), ml_hrsknt = 0
  HEAD ce1.event_cd
   null
  HEAD ce1.event_end_dt_tm
   IF (ml_hrsknt < 10)
    ml_hrsknt += 1, reply->text = concat(reply->text,ms_wr,"{",trim(ce1.result_val),"}",
     ms_rtab,ms_rtab,"{",format(ce1.event_end_dt_tm,"mm/dd/yyyy HH:mm;;D"),"}",
     ms_reol)
   ENDIF
  FOOT REPORT
   reply->text = concat(reply->text,ms_rtfeof)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->text = concat(ms_rhead,ms_rh2r,"{No Hospital Readmission Scores Found}",ms_rtfeof)
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
