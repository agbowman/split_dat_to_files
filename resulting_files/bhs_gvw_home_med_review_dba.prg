CREATE PROGRAM bhs_gvw_home_med_review:dba
 FREE RECORD t_record
 RECORD t_record(
   1 mr1 = vc
   1 mr2 = vc
   1 mr3 = vc
   1 mr4 = vc
   1 mr5 = vc
   1 mr6 = vc
 )
 DECLARE mr1_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"HOMEMEDICATIONREVIEW"))
 DECLARE mr2_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"REASONUNABLETOOBTAINVERIFYMEDS"))
 DECLARE mr3_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"HOMEMEDICATIONREVIEWCOMMENTS"))
 DECLARE mr4_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "HOMEMEDICATIONINFORMATIONPROVIDEDBY"))
 DECLARE mr5_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"LOCALPHARMACIES"))
 DECLARE mr6_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"AREYOUORCOULDYOUBEPREGNANT"))
 DECLARE done_ind = i2
 DECLARE outline = vc
 SET reol = "\PAR "
 SET wr = " \plain \f0 \fs18 \cb2 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SELECT INTO "nl:"
  FROM clinical_event ce,
   clinical_event ce1,
   clinical_event ce2,
   clinical_event ce3,
   clinical_event ce4
  PLAN (ce
   WHERE (ce.encntr_id=request->visit[1].encntr_id)
    AND ce.event_cd=mr1_cd)
   JOIN (ce1
   WHERE ce1.parent_event_id=outerjoin(ce.parent_event_id)
    AND ce1.event_cd=outerjoin(mr2_cd))
   JOIN (ce2
   WHERE ce2.parent_event_id=outerjoin(ce.parent_event_id)
    AND ce2.event_cd=outerjoin(mr3_cd))
   JOIN (ce3
   WHERE ce3.parent_event_id=outerjoin(ce.parent_event_id)
    AND ce3.event_cd=outerjoin(mr4_cd))
   JOIN (ce4
   WHERE ce4.parent_event_id=outerjoin(ce.parent_event_id)
    AND ce4.event_cd=outerjoin(mr5_cd))
  ORDER BY ce.clinsig_updt_dt_tm DESC
  HEAD ce.clinsig_updt_dt_tm
   IF (done_ind=0)
    t_record->mr1 = ce.result_val, t_record->mr2 = ce1.result_val, t_record->mr3 = ce2.result_val,
    t_record->mr4 = ce3.result_val, t_record->mr5 = ce4.result_val, done_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   clinical_event ce5
  PLAN (ce
   WHERE (ce.encntr_id=request->visit[1].encntr_id)
    AND ce.event_cd=mr6_cd)
   JOIN (ce5
   WHERE ce5.parent_event_id=outerjoin(ce.parent_event_id)
    AND ce5.event_cd=outerjoin(mr6_cd))
  ORDER BY ce.clinsig_updt_dt_tm DESC
  HEAD ce.clinsig_updt_dt_tm
   t_record->mr6 = ce5.result_val
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  DETAIL
   outline = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}",
   outline = concat(outline,wb,"{Home Medication Review}",reol,wr,
    "{",t_record->mr1,"}",reol,reol,
    wb,"{Reason Unable to Obtain/Verify Meds}",reol,wr,"{",
    t_record->mr2,"}",reol,reol,wb,
    "{Home Medication Review Comments}",reol,wr,"{",t_record->mr3,
    "}",reol,reol,wb,"{Home Medication Information Provided by}",
    reol,wr,"{",t_record->mr4,"}",
    reol,reol,wb,"{Are you or could you be pregnant?}",reol,
    wr,"{",t_record->mr6,"}",reol,
    reol,wb,"{Patient Pharmacy}",reol,wr,
    "{",t_record->mr5,"}}"), reply->text = outline
  WITH maxcol = 32000
 ;end select
END GO
