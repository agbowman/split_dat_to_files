CREATE PROGRAM dcp_get_plan_cycle_evidence:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 planlist[*]
     2 requested_pathway_catalog_id = f8
     2 pathway_catalog_id = f8
     2 version_pw_cat_id = f8
     2 display_description = vc
     2 plan_type_cd = f8
     2 active_ind = i2
     2 evidence_locator = vc
     2 ref_text_ind = i2
     2 cycle_ind = i2
     2 cycle_nbr = i4
     2 cycle_label_cd = f8
     2 cycle_begin_nbr = i4
     2 cycle_standard_nbr = i4
     2 cycle_end_nbr = i4
     2 cycle_increment_nbr = i4
     2 cycle_display_end_ind = i2
     2 all_facilities_ind = i2
     2 facilitylist[*]
       3 facility_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE req_plan_cnt = i4 WITH constant(value(size(request->planlist,5)))
 DECLARE plancnt = i4 WITH noconstant(0), protect
 DECLARE facilityidx = i4 WITH protect, noconstant(0)
 DECLARE facilitycnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF (req_plan_cnt <= 0)
  GO TO exit_script
 ENDIF
 CALL echorecord(request)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(req_plan_cnt)),
   pathway_catalog pc,
   pathway_catalog pc2,
   pw_evidence_reltn per,
   ref_text_reltn rtr,
   pw_cat_flex pcf
  PLAN (d)
   JOIN (pc
   WHERE (pc.pathway_catalog_id=request->planlist[d.seq].pathway_catalog_id))
   JOIN (pc2
   WHERE pc2.version_pw_cat_id=pc.version_pw_cat_id
    AND pc2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pc2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (per
   WHERE per.pathway_catalog_id=outerjoin(pc2.pathway_catalog_id)
    AND per.dcp_clin_cat_cd=outerjoin(0.0)
    AND per.dcp_clin_sub_cat_cd=outerjoin(0.0)
    AND per.pathway_comp_id=outerjoin(0.0))
   JOIN (rtr
   WHERE rtr.parent_entity_name=outerjoin("PATHWAY_CATALOG")
    AND rtr.parent_entity_id=outerjoin(pc2.pathway_catalog_id)
    AND rtr.active_ind=outerjoin(1))
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=outerjoin(pc2.pathway_catalog_id)
    AND pcf.parent_entity_name=outerjoin("CODE_VALUE"))
  ORDER BY pc.pathway_catalog_id, pc2.version DESC, pcf.parent_entity_id
  HEAD REPORT
   plancnt = 0, stat = alterlist(reply->planlist,req_plan_cnt)
  HEAD pc.pathway_catalog_id
   plancnt = (plancnt+ 1), reply->planlist[plancnt].requested_pathway_catalog_id = pc
   .pathway_catalog_id, reply->planlist[plancnt].pathway_catalog_id = pc2.pathway_catalog_id,
   reply->planlist[plancnt].version_pw_cat_id = pc2.version_pw_cat_id, reply->planlist[plancnt].
   display_description = pc2.display_description, reply->planlist[plancnt].plan_type_cd = pc2
   .pathway_type_cd,
   reply->planlist[plancnt].active_ind = pc2.active_ind, reply->planlist[plancnt].cycle_ind = pc2
   .cycle_ind, reply->planlist[plancnt].cycle_label_cd = pc2.cycle_label_cd,
   reply->planlist[plancnt].cycle_begin_nbr = pc2.cycle_begin_nbr, reply->planlist[plancnt].
   cycle_standard_nbr = pc2.standard_cycle_nbr, reply->planlist[plancnt].cycle_end_nbr = pc2
   .cycle_end_nbr,
   reply->planlist[plancnt].cycle_increment_nbr = pc2.cycle_increment_nbr, reply->planlist[plancnt].
   cycle_display_end_ind = pc2.cycle_display_end_ind, reply->planlist[plancnt].ref_text_ind = rtr
   .active_ind
   IF (((per.type_mean="URL") OR (per.type_mean="ZYNX")) )
    reply->planlist[plancnt].evidence_locator = per.evidence_locator
   ENDIF
   facilityidx = 0, facilitycnt = 0
  HEAD pcf.parent_entity_id
   IF (pcf.parent_entity_id=0.0)
    reply->planlist[plancnt].all_facilities_ind = 1
   ELSE
    facilityidx = (facilityidx+ 1)
    IF (facilityidx > facilitycnt)
     facilitycnt = (facilitycnt+ 10), stat = alterlist(reply->planlist[plancnt].facilitylist,
      facilitycnt)
    ENDIF
    reply->planlist[plancnt].facilitylist[facilityidx].facility_cd = pcf.parent_entity_id
   ENDIF
  FOOT  pc.pathway_catalog_id
   facilitycnt = facilityidx, stat = alterlist(reply->planlist[plancnt].facilitylist,facilitycnt)
  FOOT REPORT
   stat = alterlist(reply->planlist,plancnt)
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
