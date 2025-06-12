CREATE PROGRAM bhs_case_mgmt_disch_plan_rpt:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 action_dt_tm = dq8
   1 beg_date = dq8
   1 end_date = dq8
   1 encntr_cnt = i4
   1 encntr_qual[*]
     2 pid = f8
     2 encntr_id = f8
     2 event_id = f8
     2 has_dta_ind = i2
     2 dta1_val = vc
     2 dta2_val = vc
     2 dta3_val = vc
     2 dta4_val = vc
     2 dta5_val = vc
     2 dta6_val = vc
     2 dta7_val = vc
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE form_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CASEMANAGEMENTDISCHARGEPLANFORM"
   ))
 DECLARE dta1_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DISCHARGELEVELOFCAREATDISCHARGE"
   ))
 DECLARE dta2_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DISCHARGETRANSPORTATIONARRANGED"
   ))
 DECLARE dta3_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MODEOFTRANSPORTATIONARRANGED"))
 DECLARE dta4_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DISCHARGELONGTERMCAREFACILITY"))
 DECLARE dta5_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DISCHARGENURSINGFACILITIES"))
 DECLARE dta6_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DISCHARGEVNAHOMECARE"))
 DECLARE dta7_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGEMEDICALEQUIPMENTCOMPANIES"))
 DECLARE dcp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DCPGENERICCODE"))
 DECLARE fin_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE email_list = vc
 DECLARE dclcom = vc
 DECLARE indx = i4
 DECLARE t_line = vc
 IF (validate(request->batch_selection))
  SET t_record->action_dt_tm = cnvtdatetime(request->ops_date)
  IF ((t_record->action_dt_tm <= 0))
   SET t_record->action_dt_tm = cnvtdatetime(curdate,curtime3)
  ENDIF
  SET t_record->action_dt_tm = datetimeadd(t_record->action_dt_tm,- (28))
  SET t_record->beg_date = datetimefind(t_record->action_dt_tm,"M","B","B")
  SET t_record->end_date = datetimefind(t_record->action_dt_tm,"M","E","E")
  SET email_list =  $1
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.clinsig_updt_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND ce.clinsig_updt_dt_tm <= cnvtdatetime(t_record->end_date)
    AND ce.event_cd=form_cd)
  ORDER BY ce.encntr_id
  HEAD ce.encntr_id
   t_record->encntr_cnt = (t_record->encntr_cnt+ 1)
   IF (mod(t_record->encntr_cnt,100)=1)
    stat = alterlist(t_record->encntr_qual,(t_record->encntr_cnt+ 99))
   ENDIF
   t_record->encntr_qual[t_record->encntr_cnt].event_id = ce.event_id, t_record->encntr_qual[t_record
   ->encntr_cnt].encntr_id = ce.encntr_id, t_record->encntr_qual[t_record->encntr_cnt].pid = ce
   .person_id
  FOOT REPORT
   stat = alterlist(t_record->encntr_qual,t_record->encntr_cnt)
  WITH maxcol = 1000
 ;end select
 SELECT INTO TABLE cmdp_t
  event_id = t_record->encntr_qual[d.seq].event_id
  FROM (dummyt d  WITH seq = t_record->encntr_cnt)
  PLAN (d)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM cmdp_t c,
   clinical_event ce,
   clinical_event ce1
  PLAN (c)
   JOIN (ce
   WHERE ce.parent_event_id=c.event_id
    AND ce.event_cd=dcp_cd)
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.event_cd=dta1_cd)
  ORDER BY c.event_id, ce1.clinsig_updt_dt_tm DESC
  HEAD c.event_id
   idx = locateval(indx,1,t_record->encntr_cnt,c.event_id,t_record->encntr_qual[indx].event_id)
   IF (idx > 0)
    t_record->encntr_qual[idx].dta1_val = ce1.result_val, t_record->encntr_qual[idx].has_dta_ind = 1
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM cmdp_t c,
   clinical_event ce,
   clinical_event ce1
  PLAN (c)
   JOIN (ce
   WHERE ce.parent_event_id=c.event_id
    AND ce.event_cd=dcp_cd)
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.event_cd=dta2_cd)
  ORDER BY c.event_id, ce1.clinsig_updt_dt_tm DESC
  HEAD c.event_id
   idx = locateval(indx,1,t_record->encntr_cnt,c.event_id,t_record->encntr_qual[indx].event_id)
   IF (idx > 0)
    t_record->encntr_qual[idx].dta2_val = ce1.result_val, t_record->encntr_qual[idx].has_dta_ind = 1
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM cmdp_t c,
   clinical_event ce,
   clinical_event ce1
  PLAN (c)
   JOIN (ce
   WHERE ce.parent_event_id=c.event_id
    AND ce.event_cd=dcp_cd)
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.event_cd=dta3_cd)
  ORDER BY c.event_id, ce1.clinsig_updt_dt_tm DESC
  HEAD c.event_id
   idx = locateval(indx,1,t_record->encntr_cnt,c.event_id,t_record->encntr_qual[indx].event_id)
   IF (idx > 0)
    t_record->encntr_qual[idx].dta3_val = ce1.result_val, t_record->encntr_qual[idx].has_dta_ind = 1
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM cmdp_t c,
   clinical_event ce,
   clinical_event ce1
  PLAN (c)
   JOIN (ce
   WHERE ce.parent_event_id=c.event_id
    AND ce.event_cd=dcp_cd)
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.event_cd=dta4_cd)
  ORDER BY c.event_id, ce1.clinsig_updt_dt_tm DESC
  HEAD c.event_id
   idx = locateval(indx,1,t_record->encntr_cnt,c.event_id,t_record->encntr_qual[indx].event_id)
   IF (idx > 0)
    t_record->encntr_qual[idx].dta4_val = ce1.result_val, t_record->encntr_qual[idx].has_dta_ind = 1
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM cmdp_t c,
   clinical_event ce,
   clinical_event ce1
  PLAN (c)
   JOIN (ce
   WHERE ce.parent_event_id=c.event_id
    AND ce.event_cd=dcp_cd)
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.event_cd=dta5_cd)
  ORDER BY c.event_id, ce1.clinsig_updt_dt_tm DESC
  HEAD c.event_id
   idx = locateval(indx,1,t_record->encntr_cnt,c.event_id,t_record->encntr_qual[indx].event_id)
   IF (idx > 0)
    t_record->encntr_qual[idx].dta5_val = ce1.result_val, t_record->encntr_qual[idx].has_dta_ind = 1
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM cmdp_t c,
   clinical_event ce,
   clinical_event ce1
  PLAN (c)
   JOIN (ce
   WHERE ce.parent_event_id=c.event_id
    AND ce.event_cd=dcp_cd)
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.event_cd=dta6_cd)
  ORDER BY c.event_id, ce1.clinsig_updt_dt_tm DESC
  HEAD c.event_id
   idx = locateval(indx,1,t_record->encntr_cnt,c.event_id,t_record->encntr_qual[indx].event_id)
   IF (idx > 0)
    t_record->encntr_qual[idx].dta6_val = ce1.result_val, t_record->encntr_qual[idx].has_dta_ind = 1
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM cmdp_t c,
   clinical_event ce,
   clinical_event ce1
  PLAN (c)
   JOIN (ce
   WHERE ce.parent_event_id=c.event_id
    AND ce.event_cd=dcp_cd)
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.event_cd=dta7_cd)
  ORDER BY c.event_id, ce1.clinsig_updt_dt_tm DESC
  HEAD c.event_id
   idx = locateval(indx,1,t_record->encntr_cnt,c.event_id,t_record->encntr_qual[indx].event_id)
   IF (idx > 0)
    t_record->encntr_qual[idx].dta7_val = ce1.result_val, t_record->encntr_qual[idx].has_dta_ind = 1
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "case_mgmt_disch_plan_report.xls"
  org = uar_get_code_display(e.loc_facility_cd)
  FROM (dummyt d  WITH seq = t_record->encntr_cnt),
   person p,
   encounter e,
   encntr_alias ea
  PLAN (d
   WHERE (t_record->encntr_qual[d.seq].has_dta_ind=1))
   JOIN (p
   WHERE (p.person_id=t_record->encntr_qual[d.seq].pid)
    AND p.active_ind=1)
   JOIN (e
   WHERE e.person_id=p.person_id)
   JOIN (ea
   WHERE (ea.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
    AND ea.encntr_alias_type_cd=fin_cd)
  ORDER BY ea.alias
  HEAD REPORT
   t_line = "Case Management Discharge Plan Report", col 0, t_line,
   row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q")), col 0,
   t_line, row + 1, t_line = concat("FIN",char(9),"Level of Care at Discharge",char(9),
    "Transportation Arranged",
    char(9),"Mode of Transportation Arranged",char(9),"Long Term Care Facility",char(9),
    "Nursing Facilities",char(9),"VNA Home Care",char(9),"Medical Equipment Companies"),
   col 0, t_line, row + 1
  HEAD ea.alias
   IF (cnvtupper(org) != "MOCK*")
    t_line = concat(trim(ea.alias),char(9),t_record->encntr_qual[d.seq].dta1_val,char(9),t_record->
     encntr_qual[d.seq].dta2_val,
     char(9),t_record->encntr_qual[d.seq].dta3_val,char(9),t_record->encntr_qual[d.seq].dta4_val,char
     (9),
     t_record->encntr_qual[d.seq].dta5_val,char(9),t_record->encntr_qual[d.seq].dta6_val,char(9),
     t_record->encntr_qual[d.seq].dta7_val), col 0, t_line,
    row + 1
   ENDIF
  WITH maxcol = 1000, formfeed = none
 ;end select
 IF (findfile("case_mgmt_disch_plan_report.xls")=1)
  SET subject_line = concat("Case Management Discharge Plan Report ",format(t_record->beg_date,
    "DD-MMM-YYYY;;Q")," to ",format(t_record->end_date,"DD-MMM-YYYY;;Q"))
  CALL emailfile("case_mgmt_disch_plan_report.xls","case_mgmt_disch_plan_report.xls",email_list,
   subject_line,1)
 ENDIF
 DROP TABLE cmdp_t
 SET dclcom = "rm -f cmdp_t"
 SET len = size(trim(dclcom))
 SET status = 0
 SET stat = dcl(dclcom,len,status)
END GO
