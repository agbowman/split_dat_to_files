CREATE PROGRAM dcp_get_patient_list
 RECORD reply(
   1 patient_list_id = f8
   1 name = vc
   1 description = vc
   1 patient_list_type_cd = f8
   1 owner_id = f8
   1 prsnl_access_cd = f8
   1 execution_dt_tm = dq8
   1 execution_status_cd = f8
   1 execution_status_disp = vc
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
   1 patients[*]
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 priority = i4
     2 active_ind = i2
     2 filter_ind = i2
     2 responsible_prsnl_id = f8
     2 responsible_prsnl_name = vc
     2 responsible_reltn_cd = f8
     2 responsible_reltn_disp = vc
     2 responsible_reltn_id = f8
     2 responsible_reltn_flag = i2
     2 organization_id = f8
     2 confid_level_cd = f8
     2 confid_level_disp = c40
     2 confid_level = i4
     2 birthdate = dq8
     2 birth_tz = i4
     2 end_effective_dt_tm = dq8
     2 service_cd = f8
     2 service_disp = c40
     2 gender_cd = f8
     2 gender_disp = c40
     2 temp_location_cd = f8
     2 temp_location_disp = c40
     2 vip_cd = f8
     2 visit_reason = vc
     2 visitor_status_cd = f8
     2 visitor_status_disp = c40
     2 deceased_date = dq8
     2 deceased_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE listtype = vc WITH constant(uar_get_code_meaning(request->patient_list_type_cd))
 DECLARE encntr_org_sec_ind = i2 WITH noconstant(0)
 DECLARE confid_ind = i2 WITH noconstant(0)
 DECLARE logstatistics(seconds=f8) = null
 DECLARE performbestencntr(null) = null
 DECLARE begin_time = f8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE finish_time = f8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE stat = i4 WITH noconstant(0)
 CASE (listtype)
  OF "CUSTOM":
   EXECUTE dcp_get_pl_custom2
  OF "CARETEAM":
   EXECUTE dcp_get_pl_careteam2
  OF "LOCATION":
   EXECUTE dcp_get_pl_census
  OF "LOCATIONGRP":
   EXECUTE dcp_get_pl_census
  OF "VRELTN":
   EXECUTE dcp_get_pl_reltn
  OF "LRELTN":
   EXECUTE dcp_get_pl_reltn
  OF "RELTN":
   EXECUTE dcp_get_pl_reltn
  OF "PROVIDERGRP":
   EXECUTE dcp_get_pl_provider_group2
  OF "SERVICE":
   EXECUTE dcp_get_pl_census
  OF "ASSIGNMENT":
   EXECUTE dcp_get_pl_asgmt
  OF "ANC_ASGMT":
   EXECUTE dcp_get_pl_ancillary_asgmt
  OF "QUERY":
   EXECUTE dcp_get_pl_query
  OF "SCHEDULE":
   EXECUTE dcp_get_pl_schedule
  ELSE
   GO TO error
 ENDCASE
 SET finish_time = cnvtdatetime(curdate,curtime3)
 CALL logstatistics(datetimediff(finish_time,begin_time,5))
 IF ((request->best_encntr_flag=1))
  CALL performbestencntr(null)
 ENDIF
 SUBROUTINE performbestencntr(null)
   RECORD encntrrequest(
     1 persons[*]
       2 person_id = f8
   )
   RECORD encntrreply(
     1 encounters[*]
       2 encntr_id = f8
       2 person_id = f8
     1 lookup_status = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   DECLARE patcount = i4 WITH constant(size(reply->patients,5)), private
   DECLARE encntrcnt = i4 WITH noconstant(0), private
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE y = i4 WITH noconstant(0), private
   SET stat = alterlist(encntrrequest->persons,patcount)
   FOR (x = 1 TO patcount)
     IF ((reply->patients[x].encntr_id=0))
      SET encntrcnt = (encntrcnt+ 1)
      SET encntrrequest->persons[encntrcnt].person_id = reply->patients[x].person_id
     ENDIF
   ENDFOR
   IF (encntrcnt > 0)
    SET stat = alterlist(encntrrequest->persons,encntrcnt)
    EXECUTE pts_get_best_encntr_list  WITH replace(request,encntrrequest), replace(reply,encntrreply)
    SET encntrcnt = size(encntrreply->encounters,5)
    FOR (x = 1 TO encntrcnt)
      FOR (y = 1 TO patcount)
        IF ((reply->patients[y].person_id=encntrreply->encounters[x].person_id)
         AND (reply->patients[y].encntr_id=0))
         SET reply->patients[y].encntr_id = encntrreply->encounters[x].encntr_id
         SET y = (patcount+ 1)
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   FREE RECORD encntrreply
   FREE RECORD encntrrequest
 END ;Subroutine
 SUBROUTINE logstatistics(seconds)
   DECLARE log = i2 WITH noconstant(0)
   DECLARE cnt = i4 WITH constant(size(reply->patients,5))
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain="PATIENT_LIST"
      AND di.info_name="STATISTICS")
    DETAIL
     IF (di.info_number=1.0)
      log = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (log > 0)
    INSERT  FROM dcp_pl_statistics stat
     SET stat.patient_list_id = request->patient_list_id, stat.patient_list_type = listtype, stat
      .qual = cnt,
      stat.response = seconds, stat.security_ind = encntr_org_sec_ind, stat.confid_ind = confid_ind,
      stat.updt_applctx = reqinfo->updt_applctx, stat.updt_cnt = 0, stat.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      stat.updt_id = reqinfo->updt_id, stat.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    SET reqinfo->commit_ind = 1
   ENDIF
 END ;Subroutine
#error
END GO
