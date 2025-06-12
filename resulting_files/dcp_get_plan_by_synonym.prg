CREATE PROGRAM dcp_get_plan_by_synonym
 SET modify = predeclare
 RECORD reply(
   1 planlist[*]
     2 plan_description = vc
     2 phase_description = vc
     2 type_mean = c12
     2 person_full_name = vc
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 version = i4
     2 plan_catalog_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE listcnt = i4 WITH noconstant(0)
 DECLARE replycnt = i4 WITH noconstant(0)
 DECLARE dummy = i4 WITH noconstant(0)
 DECLARE end_date_string = c20 WITH constant("31-DEC-2100 00:00:00")
 SET reply->status_data.status = "F"
 RECORD temp(
   1 list[*]
     2 plan_catalog_id = f8
     2 plan_description = vc
     2 phase_cat_id = f8
     2 phase_description = vc
     2 type_mean = c12
     2 ref_owner_person_id = f8
     2 person_name = vc
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 version = i4
 )
 SELECT DISTINCT INTO "nl:"
  pc.pathway_catalog_id, pwc1.pathway_catalog_id, pcr.pathway_comp_s_id,
  pwc2.pathway_catalog_id
  FROM pathway_comp pc,
   pathway_catalog pwc1,
   pw_cat_reltn pcr,
   pathway_catalog pwc2
  PLAN (pc
   WHERE (pc.parent_entity_id=request->synonym_id)
    AND pc.parent_entity_name="ORDER_CATALOG_SYNONYM"
    AND pc.active_ind=1)
   JOIN (pwc1
   WHERE pwc1.pathway_catalog_id=pc.pathway_catalog_id
    AND pwc1.end_effective_dt_tm=cnvtdatetime(end_date_string)
    AND ((pwc1.type_mean="CAREPLAN") OR (pwc1.type_mean="PHASE"
    AND pwc1.active_ind=1)) )
   JOIN (pcr
   WHERE pcr.pw_cat_t_id=outerjoin(pwc1.pathway_catalog_id)
    AND pcr.type_mean=outerjoin("GROUP"))
   JOIN (pwc2
   WHERE pwc2.pathway_catalog_id=outerjoin(pcr.pw_cat_s_id)
    AND pwc2.pathway_catalog_id > outerjoin(0)
    AND pwc2.end_effective_dt_tm=outerjoin(cnvtdatetime(end_date_string)))
  ORDER BY pc.pathway_catalog_id, pwc1.pathway_catalog_id
  HEAD REPORT
   listcnt = 0
  HEAD pc.pathway_catalog_id
   IF (pwc1.type_mean="PHASE")
    listcnt = (listcnt+ 1)
    IF (listcnt > size(temp->list,5))
     stat = alterlist(temp->list,(listcnt+ 10))
    ENDIF
    temp->list[listcnt].plan_catalog_id = pwc2.pathway_catalog_id, temp->list[listcnt].
    plan_description = pwc2.description, temp->list[listcnt].phase_cat_id = pwc1.pathway_catalog_id,
    temp->list[listcnt].phase_description = pwc1.description, temp->list[listcnt].type_mean = pwc2
    .type_mean, temp->list[listcnt].active_ind = pwc2.active_ind,
    temp->list[listcnt].beg_effective_dt_tm = pwc2.beg_effective_dt_tm, temp->list[listcnt].
    end_effective_dt_tm = pwc2.end_effective_dt_tm, temp->list[listcnt].version = pwc2.version
   ELSEIF (pwc1.type_mean="CAREPLAN")
    listcnt = (listcnt+ 1)
    IF (listcnt > size(temp->list,5))
     stat = alterlist(temp->list,(listcnt+ 10))
    ENDIF
    temp->list[listcnt].plan_catalog_id = pwc1.pathway_catalog_id, temp->list[listcnt].
    plan_description = pwc1.description, temp->list[listcnt].type_mean = pwc1.type_mean,
    temp->list[listcnt].ref_owner_person_id = pwc1.ref_owner_person_id, temp->list[listcnt].
    active_ind = pwc1.active_ind, temp->list[listcnt].beg_effective_dt_tm = pwc1.beg_effective_dt_tm,
    temp->list[listcnt].end_effective_dt_tm = pwc1.end_effective_dt_tm, temp->list[listcnt].version
     = pwc1.version
   ENDIF
  FOOT REPORT
   IF (listcnt > 0)
    stat = alterlist(temp->list,listcnt)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  typemean = temp->list[d.seq].type_mean, person_id = temp->list[d.seq].ref_owner_person_id, p
  .name_full_formatted
  FROM (dummyt d  WITH seq = value(size(temp->list,5))),
   person p
  PLAN (d
   WHERE (temp->list[d.seq].type_mean="CAREPLAN")
    AND (temp->list[d.seq].ref_owner_person_id > 0))
   JOIN (p
   WHERE (p.person_id=temp->list[d.seq].ref_owner_person_id))
  HEAD REPORT
   dummy = 0
  DETAIL
   temp->list[d.seq].person_name = p.name_full_formatted
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
 SET listcnt = value(size(temp->list,5))
 IF (listcnt > 0)
  SELECT INTO "nl:"
   plandesc = temp->list[d.seq].plan_description, phasedesc = temp->list[d.seq].phase_description
   FROM (dummyt d  WITH seq = listcnt)
   PLAN (d)
   ORDER BY plandesc, phasedesc
   HEAD REPORT
    replycnt = 0
   DETAIL
    IF (d.seq > 0)
     replycnt = (replycnt+ 1)
     IF (replycnt > size(reply->planlist,5))
      stat = alterlist(reply->planlist,(replycnt+ 10))
     ENDIF
     reply->planlist[replycnt].plan_description = temp->list[d.seq].plan_description, reply->
     planlist[replycnt].phase_description = temp->list[d.seq].phase_description, reply->planlist[
     replycnt].type_mean = temp->list[d.seq].type_mean,
     reply->planlist[replycnt].person_full_name = temp->list[d.seq].person_name, reply->planlist[
     replycnt].active_ind = temp->list[d.seq].active_ind, reply->planlist[replycnt].
     beg_effective_dt_tm = temp->list[d.seq].beg_effective_dt_tm,
     reply->planlist[replycnt].end_effective_dt_tm = temp->list[d.seq].end_effective_dt_tm, reply->
     planlist[replycnt].version = temp->list[d.seq].version, reply->planlist[replycnt].
     plan_catalog_id = temp->list[d.seq].plan_catalog_id
    ENDIF
   FOOT REPORT
    IF (replycnt > 0)
     stat = alterlist(reply->planlist,replycnt)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
END GO
