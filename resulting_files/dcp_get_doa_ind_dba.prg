CREATE PROGRAM dcp_get_doa_ind:dba
 RECORD reply(
   1 person_cnt = i4
   1 person_list[*]
     2 person_id = f8
     2 doa_ind = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE doa_code_value = f8 WITH protected, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET doa_code_value = uar_get_code_by("MEANING",4002127,"DENIALACCESS")
 IF (doa_code_value <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "UAR_GET_CODE_BY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "UAR_GET_CODE_BY function call failed for DENIALOFACCESS"
  GO TO end_script
 ENDIF
 DECLARE indx = i4 WITH public, noconstant(0)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE pos = i4 WITH public, noconstant(0)
 DECLARE person_cnt = i4 WITH public, noconstant(0)
 SET actual_size = size(reply->person_list,5)
 SET stat = alterlist(reply->person_list,5)
 SET reply->person_cnt = 0
 SELECT INTO "nl:"
  s.seal_id
  FROM seal s,
   seal_participant sp
  PLAN (s
   WHERE expand(indx,1,size(request->person_list,5),s.person_id,request->person_list[indx].person_id)
    AND s.seal_type_cd=doa_code_value
    AND s.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND s.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND s.active_ind=1)
   JOIN (sp
   WHERE sp.seal_id=s.seal_id
    AND (sp.prsnl_id=request->prsnl_id))
  HEAD s.person_id
   person_cnt = (person_cnt+ 1)
   IF (size(reply->person_list,5)=person_cnt)
    stat = alterlist(reply->person_list,(person_cnt+ 5))
   ENDIF
   reply->person_list[person_cnt].person_id = s.person_id, reply->person_list[person_cnt].doa_ind = 1
  WITH nocounter
 ;end select
 SET reply->person_cnt = person_cnt
 SET stat = alterlist(reply->person_list,person_cnt)
 IF (curqual < 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SEAL or SEAL_PARTICIPANT"
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
 ENDIF
#end_script
END GO
