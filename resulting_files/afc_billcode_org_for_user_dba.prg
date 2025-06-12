CREATE PROGRAM afc_billcode_org_for_user:dba
 DECLARE getbillcodeschedsecuritypreference(dummy=vc) = i2
 DECLARE afc_billcode_org_for_user_vern = vc
 SET afc_billcode_org_for_user_vern = "001"
 DECLARE bdm_info_char = i2
 RECORD reply(
   1 bc_usr_org_reltn[*]
     2 code_value = f8
     2 display = vc
   1 bc_usr_org_count = f8
 )
 DECLARE codeset = f8
 SET codeset = 14002
 DECLARE 26078_bc_sched = f8
 SET stat = uar_get_meaning_by_codeset(26078,request->key1_entity_name,1,26078_bc_sched)
 CALL echo(build("26078_BC_SCHED ",cnvtstring(26078_bc_sched)))
 SET count1 = 0
 SET bdm_info_char = getbillcodeschedsecuritypreference(null)
 CALL echo(build("Info_Char=>",bdm_info_char))
 SELECT
  IF (bdm_info_char
   AND (request->key1_entity_name != "")
   AND (request->info_name != ""))
   FROM prsnl_org_reltn por,
    cs_org_reltn cor,
    code_value cv
   PLAN (por
    WHERE (por.person_id=reqinfo->updt_id)
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (cor
    WHERE cor.organization_id=por.organization_id
     AND cor.cs_org_reltn_type_cd=26078_bc_sched
     AND (cor.key1_entity_name=request->key1_entity_name)
     AND cor.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=cor.key1_id
     AND cv.code_set=codeset
     AND (cv.cdf_meaning=request->bc_sched_type)
     AND cv.active_ind=1)
  ELSE
   FROM code_value cv
   WHERE cv.code_set=codeset
    AND (cv.cdf_meaning=request->bc_sched_type)
    AND cv.active_ind=1
  ENDIF
  INTO "nl:"
  ORDER BY cv.code_value
  HEAD cv.code_value
   count1 = (count1+ 1), stat = alterlist(reply->bc_usr_org_reltn,count1), reply->bc_usr_org_reltn[
   count1].code_value = cv.code_value,
   reply->bc_usr_org_reltn[count1].display = cv.display, reply->bc_usr_org_count = count1
  WITH nocounter
 ;end select
 SUBROUTINE getbillcodeschedsecuritypreference(dummy)
   FREE RECORD afc_dm_info_request
   RECORD afc_dm_info_request(
     1 info_name_qual = i2
     1 info[*]
       2 info_name = vc
     1 info_name = vc
   )
   FREE RECORD afc_dm_info_reply
   RECORD afc_dm_info_reply(
     1 dm_info_qual = i2
     1 dm_info[*]
       2 info_name = vc
       2 info_date = dq8
       2 info_char = vc
       2 info_number = f8
       2 info_long_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c15
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = vc
   )
   SET afc_dm_info_request->info_name_qual = 1
   SET stat = alterlist(afc_dm_info_request->info,1)
   SET afc_dm_info_request->info[1].info_name = request->info_name
   EXECUTE afc_get_dm_info  WITH replace("REQUEST",afc_dm_info_request), replace("REPLY",
    afc_dm_info_reply)
   IF ((afc_dm_info_reply->status_data.status="S"))
    IF (cnvtupper(afc_dm_info_reply->dm_info[1].info_char)="Y")
     RETURN(true)
    ELSE
     RETURN(false)
    ENDIF
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 CALL echorecord(reply)
END GO
