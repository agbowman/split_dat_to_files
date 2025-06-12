CREATE PROGRAM cco_get_care_team_list_id:dba
 RECORD reply(
   1 patient_list_id = f8
   1 patient_list_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
 DECLARE careteamcd = f8
 SET careteamcd = meaning_code(27360,"CARETEAM")
 CALL echo(build("CARECODE=",careteamcd))
 SET reply->patient_list_id = 0.0
 SET reply->patient_list_type_cd = 0.0
 SET reply->status_data.status = "Z"
 IF ((((request->list_name=null)) OR (size(request->list_name) < 1)) )
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "QUERY"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CCO_GET_CARE_TEAM_LIST_ID"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "LIST NAME NOT PROVIDED"
 ENDIF
 SET found_owner_list = 0
 SELECT INTO "nl:"
  FROM dcp_patient_list dcp
  WHERE (dcp.name=request->list_name)
   AND dcp.patient_list_type_cd=careteamcd
  ORDER BY dcp.updt_dt_tm DESC
  DETAIL
   IF (found_owner_list=0)
    reply->patient_list_id = dcp.patient_list_id, reply->patient_list_type_cd = dcp
    .patient_list_type_cd, reply->status_data.status = "S"
    IF ((dcp.owner_prsnl_id=reqinfo->updt_id))
     found_owner_list = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->status_data.status="Z"))
  SET reply->status_data.subeventstatus[1].operationname = "QUERY"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CCO_GET_CARE_TEAM_LIST_ID"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build("UNABLE TO RESOLVE LIST NAME-",
   trim(request->list_name))
 ENDIF
#endprogram
 CALL echorecord(reply)
END GO
