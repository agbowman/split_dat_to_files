CREATE PROGRAM bhs_gvw_encntr_prim_hp_carrier:dba
 DECLARE mf_cs370_carrier_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!5204"))
 DECLARE ms_carrier_name = vc WITH protect, noconstant("")
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
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_plan_reltn epr,
   health_plan hp,
   org_plan_reltn opr,
   organization o
  PLAN (epr
   WHERE (epr.encntr_id=request->visit[1].encntr_id)
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id)
   JOIN (opr
   WHERE (opr.health_plan_id= Outerjoin(hp.health_plan_id))
    AND (opr.active_ind= Outerjoin(1))
    AND (opr.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (opr.org_plan_reltn_cd= Outerjoin(mf_cs370_carrier_cd)) )
   JOIN (o
   WHERE (o.organization_id= Outerjoin(opr.organization_id)) )
  ORDER BY epr.priority_seq
  HEAD REPORT
   ms_carrier_name = trim(o.org_name,3)
  WITH nocounter
 ;end select
 IF (size(trim(ms_carrier_name,3)) > 0)
  SET reply->text = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}","\fs18 ",
   ms_carrier_name," \par}")
 ENDIF
 CALL echorecord(reply)
#exit_script
END GO
