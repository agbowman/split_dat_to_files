CREATE PROGRAM dcp_get_pw_maint_criteria:dba
 RECORD reply(
   1 criterialist[*]
     2 pw_maintenance_criteria_id = f8
     2 type_mean = c12
     2 encounter_type_flag = i2
     2 version_pw_cat_id = f8
     2 plan_description = vc
     2 time_qty = i4
     2 time_unit_cd = f8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD loadtypes(
   1 typemeanlist[*]
     2 type_mean = c12
 )
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE discharge_ind = i2 WITH protect, constant(validate(request->load_discharge_criteria_ind,0))
 DECLARE expiration_ind = i2 WITH protect, constant(validate(request->load_expiration_criteria_ind,0)
  )
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE criteriacnt = i4 WITH noconstant(0), protect
 DECLARE index = i4 WITH noconstant(0), protect
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 IF (discharge_ind > 0)
  SET stat = alterlist(loadtypes->typemeanlist,1)
  SET loadtypes->typemeanlist[1].type_mean = "DISCHARGE"
 ELSEIF (expiration_ind > 0)
  SET stat = alterlist(loadtypes->typemeanlist,2)
  SET loadtypes->typemeanlist[1].type_mean = "EXPIRATION"
  SET loadtypes->typemeanlist[2].type_mean = "EXPIREPROP"
 ENDIF
 SELECT INTO "nl:"
  FROM pw_maintenance_criteria pmc
  WHERE expand(index,1,size(loadtypes->typemeanlist,5),pmc.type_mean,loadtypes->typemeanlist[index].
   type_mean)
   AND pmc.version_pw_cat_id=0
  HEAD REPORT
   criteriacnt = 0, stat = alterlist(reply->criterialist,5)
  DETAIL
   criteriacnt = (criteriacnt+ 1)
   IF (mod(criteriacnt,5)=1
    AND criteriacnt != 1)
    stat = alterlist(reply->criterialist,(criteriacnt+ 4))
   ENDIF
   reply->criterialist[criteriacnt].pw_maintenance_criteria_id = pmc.pw_maintenance_criteria_id,
   reply->criterialist[criteriacnt].type_mean = pmc.type_mean, reply->criterialist[criteriacnt].
   encounter_type_flag = pmc.encounter_type_flag,
   reply->criterialist[criteriacnt].version_pw_cat_id = pmc.version_pw_cat_id, reply->criterialist[
   criteriacnt].time_qty = pmc.time_qty, reply->criterialist[criteriacnt].time_unit_cd = pmc
   .time_unit_cd,
   reply->criterialist[criteriacnt].updt_cnt = pmc.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->criterialist,criteriacnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL report_failure("LOAD_GLOBAL_DISCHARGE_CRITERIA","F","DCP_GET_MAINT_CRITERIA",
   "Unable to find PW_MAINTENANCE_CRITERIA global records")
  SET cstatus = "F"
  GO TO exit_script
 ENDIF
 IF (curqual > 2
  AND discharge_ind > 0)
  CALL report_failure("LOAD_GLOBAL_DISCHARGE_CRITERIA","F","DCP_GET_MAINT_CRITERIA",
   "Found invalid number of PW_MAINTENANCE_CRITERIA global discharge records")
  SET cstatus = "F"
  GO TO exit_script
 ENDIF
 IF (curqual > 1
  AND expiration_ind > 0)
  CALL report_failure("LOAD_GLOBAL_DISCHARGE_CRITERIA","F","DCP_GET_MAINT_CRITERIA",
   "Found invalid number of PW_MAINTENANCE_CRITERIA global expiration records")
  SET cstatus = "F"
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  pmc.version_pw_cat_id
  FROM pw_maintenance_criteria pmc,
   pathway_catalog pc
  WHERE expand(index,1,size(loadtypes->typemeanlist,5),pmc.type_mean,loadtypes->typemeanlist[index].
   type_mean)
   AND pmc.version_pw_cat_id > 0
   AND pmc.version_pw_cat_id=pc.version_pw_cat_id
   AND pc.beg_effective_dt_tm != cnvtdate(12312100)
  HEAD REPORT
   stat = alterlist(reply->criterialist,(criteriacnt+ 4))
  DETAIL
   criteriacnt = (criteriacnt+ 1)
   IF (mod(criteriacnt,5)=1
    AND criteriacnt != 1)
    stat = alterlist(reply->criterialist,(criteriacnt+ 4))
   ENDIF
   reply->criterialist[criteriacnt].pw_maintenance_criteria_id = pmc.pw_maintenance_criteria_id,
   reply->criterialist[criteriacnt].type_mean = pmc.type_mean, reply->criterialist[criteriacnt].
   encounter_type_flag = pmc.encounter_type_flag,
   reply->criterialist[criteriacnt].version_pw_cat_id = pmc.version_pw_cat_id, reply->criterialist[
   criteriacnt].plan_description = trim(pc.description,3), reply->criterialist[criteriacnt].time_qty
    = pmc.time_qty,
   reply->criterialist[criteriacnt].time_unit_cd = pmc.time_unit_cd, reply->criterialist[criteriacnt]
   .updt_cnt = pmc.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->criterialist,criteriacnt)
  WITH nocounter
 ;end select
 SET cstatus = "S"
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = cstatus
END GO
