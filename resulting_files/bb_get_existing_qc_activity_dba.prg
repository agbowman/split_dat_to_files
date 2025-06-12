CREATE PROGRAM bb_get_existing_qc_activity:dba
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 RECORD reply(
   1 qc_found_ind = i2
   1 schedule_group_list[*]
     2 schedule_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE linterpretations_cs = i4 WITH constant(325575), protect
 DECLARE lstatus = i4 WITH noconstant(0), protect
 DECLARE dinterpretationcd = f8 WITH noconstant(0.0), protect
 DECLARE nschedgroupcnt = i2 WITH noconstant(0), protect
 DECLARE sinterpmean = vc WITH noconstant(""), protect
 DECLARE lcodecnt = i4 WITH noconstant(1), protect
#begin_script
 SET reply->status_data.status = "F"
 IF (trim(request->interp_mean)="")
  SET sinterpmean = "PENDING"
 ELSE
  SET sinterpmean = request->interp_mean
 ENDIF
 SET lstatus = uar_get_meaning_by_codeset(linterpretations_cs,sinterpmean,lcodecnt,dinterpretationcd)
 IF (dinterpretationcd=0.0)
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=linterpretations_cs
    AND c.cdf_meaning=sinterpmean
    AND c.active_ind=1
   DETAIL
    dinterpretationcd = c.code_value
   WITH nocounter
  ;end select
  IF (dinterpretationcd=0.0)
   SET reply->status_data.status = "F"
   CALL subevent_add("SELECT","F","CODE_VALUE","Interpretation code not found from meaning.")
   GO TO end_script
  ENDIF
 ENDIF
 IF ((request->group_reagent_lot_id > 0.0))
  SELECT INTO "nl:"
   FROM bb_qc_grp_reagent_activity gra,
    bb_qc_group_activity ga
   PLAN (gra
    WHERE (gra.group_reagent_lot_id=request->group_reagent_lot_id))
    JOIN (ga
    WHERE ga.group_activity_id=gra.group_activity_id
     AND ga.scheduled_dt_tm < cnvtdatetime(curdate,curtime3))
   ORDER BY ga.group_activity_id, ga.scheduled_dt_tm
   HEAD REPORT
    reply->qc_found_ind = 1
   HEAD ga.group_activity_id
    nschedgroupcnt = (nschedgroupcnt+ 1)
    IF (nschedgroupcnt > size(reply->schedule_group_list,5))
     lstatus = alterlist(reply->schedule_group_list,(nschedgroupcnt+ 10))
    ENDIF
    reply->schedule_group_list[nschedgroupcnt].schedule_dt_tm = cnvtdatetime(ga.scheduled_dt_tm)
   FOOT REPORT
    lstatus = alterlist(reply->schedule_group_list,nschedgroupcnt)
   WITH nocounter
  ;end select
 ELSEIF ((request->group_id > 0.0))
  SELECT INTO "nl:"
   FROM bb_qc_group_activity ga,
    bb_qc_grp_reagent_activity gra
   PLAN (ga
    WHERE (ga.group_id=request->group_id)
     AND ga.scheduled_dt_tm < cnvtdatetime(curdate,curtime3))
    JOIN (gra
    WHERE gra.group_activity_id=ga.group_activity_id
     AND gra.interpretation_cd=dinterpretationcd)
   ORDER BY ga.group_activity_id, ga.scheduled_dt_tm
   HEAD REPORT
    reply->qc_found_ind = 1
   HEAD ga.group_activity_id
    nschedgroupcnt = (nschedgroupcnt+ 1)
    IF (nschedgroupcnt > size(reply->schedule_group_list,5))
     lstatus = alterlist(reply->schedule_group_list,(nschedgroupcnt+ 10))
    ENDIF
    reply->schedule_group_list[nschedgroupcnt].schedule_dt_tm = cnvtdatetime(ga.scheduled_dt_tm)
   FOOT REPORT
    lstatus = alterlist(reply->schedule_group_list,nschedgroupcnt)
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#end_script
END GO
