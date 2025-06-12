CREATE PROGRAM bmdi_get_association_hints:dba
 DECLARE readconfig(dummy) = i2
 IF (validate(info_domain,999)=999)
  DECLARE info_domain = vc WITH protect, noconstant("bmdi_get_association_hints")
 ENDIF
 IF (validate(info_name,999)=999)
  DECLARE info_name = vc WITH protect, noconstant("LOG_MSGVIEW")
 ENDIF
 IF (validate(log_msgview,999)=999)
  DECLARE log_msgview = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(execmsgrtl,999)=999)
  DECLARE execmsgrtl = i2 WITH protect, constant(1)
 ENDIF
 IF (validate(emsglog_commit,999)=999)
  DECLARE emsglog_commit = i4 WITH protect, constant(0)
 ENDIF
 IF (validate(emsglvl_debug,999)=999)
  DECLARE emsglvl_debug = i4 WITH protect, constant(4)
 ENDIF
 IF (validate(msg_debug,999)=999)
  DECLARE msg_debug = i4 WITH protect, noconstant(0)
 ENDIF
 IF (validate(msg_default,999)=999)
  DECLARE msg_default = i4 WITH protect, noconstant(0)
 ENDIF
 RECORD reply(
   1 hints_list[*]
     2 hint_id = f8
     2 person_id = f8
     2 hint_dt_tm = dq8
     2 location_cd = f8
     2 hint_type_cd = f8
     2 hint_processing_cd = f8
     2 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL readconfig(0)
 DECLARE act_hint_processing_cd = f8 WITH noconstant(0.0)
 DECLARE defer_hint_processing_cd = f8 WITH noconstant(0.0)
 DECLARE idx = i2 WITH noconstant(0)
 DECLARE nbr_hints_retrieved = i2 WITH noconstant(0)
 CALL msgwrite("Entering the script association hints..")
 SET act_hint_processing_cd = uar_get_code_by("MEANING",359576,"ACT")
 SET defer_hint_processing_cd = uar_get_code_by("MEANING",359576,"DEFER")
 SET reply->status_data.status = "F"
 IF ((request->hint_id > 0.0))
  SET nbr_codes_requested = 1
 ELSE
  SET nbr_codes_requested = size(request->hint_processing_list,5)
  IF (nbr_codes_requested <= 0)
   SET stat = alterlist(request->hint_processing_list,2)
   SET nbr_codes_requested = size(request->hint_processing_list,5)
   SET request->hint_processing_list[1].hint_processing_cd = act_hint_processing_cd
   SET request->hint_processing_list[2].hint_processing_cd = defer_hint_processing_cd
  ENDIF
 ENDIF
 CALL msgwrite(build2("request->hint_id= ",request->hint_id,"nbr_codes_requested= ",
   nbr_codes_requested,"request->person_id= ",
   request->person_id,"request->location_cd= ",request->location_cd))
 FOR (idx = 1 TO nbr_codes_requested)
   CALL msgwrite(build2("request->hint_processing_list[idx].hint_processing_cd= ",request->
     hint_processing_list[idx].hint_processing_cd))
 ENDFOR
 SET idx = 0
 SELECT
  IF ((request->hint_id > 0.0))
   PLAN (d1)
    JOIN (bah
    WHERE (bah.hint_id=request->hint_id)
     AND bah.active_ind=1)
    JOIN (p
    WHERE p.person_id=bah.person_id)
  ELSEIF ((request->person_id > 0.0)
   AND (request->location_cd=0.0))
   PLAN (d1)
    JOIN (bah
    WHERE (bah.person_id=request->person_id)
     AND (bah.hint_processing_cd=request->hint_processing_list[d1.seq].hint_processing_cd)
     AND bah.active_ind=1)
    JOIN (p
    WHERE p.person_id=bah.person_id)
  ELSEIF ((request->person_id > 0.0)
   AND (request->location_cd > 0.0))
   PLAN (d1)
    JOIN (bah
    WHERE (bah.person_id=request->person_id)
     AND (bah.location_cd=request->location_cd)
     AND (bah.hint_processing_cd=request->hint_processing_list[d1.seq].hint_processing_cd)
     AND bah.active_ind=1)
    JOIN (p
    WHERE p.person_id=bah.person_id)
  ELSEIF ((request->person_id=0.0)
   AND (request->location_cd > 0.0))
   PLAN (d1)
    JOIN (bah
    WHERE (bah.location_cd=request->location_cd)
     AND (bah.hint_processing_cd=request->hint_processing_list[d1.seq].hint_processing_cd)
     AND bah.active_ind=1)
    JOIN (p
    WHERE p.person_id=bah.person_id)
  ELSE
   PLAN (d1)
    JOIN (bah
    WHERE (bah.hint_processing_cd=request->hint_processing_list[d1.seq].hint_processing_cd)
     AND bah.active_ind=1)
    JOIN (p
    WHERE p.person_id=bah.person_id)
  ENDIF
  INTO "nl:"
  FROM (dummyt d1  WITH seq = value(nbr_codes_requested)),
   bmdi_association_hints bah,
   person p
  DETAIL
   idx += 1, stat = alterlist(reply->hints_list,idx), reply->hints_list[idx].hint_id = bah.hint_id,
   reply->hints_list[idx].person_id = bah.person_id, reply->hints_list[idx].hint_dt_tm = bah
   .hint_dt_tm, reply->hints_list[idx].location_cd = bah.location_cd,
   reply->hints_list[idx].hint_type_cd = bah.hint_type_cd, reply->hints_list[idx].hint_processing_cd
    = bah.hint_processing_cd, reply->hints_list[idx].name_full_formatted = p.name_full_formatted
  WITH nocounter
 ;end select
 SET nbr_hints_retrieved = idx
 CALL msgwrite(build2("Number of hints retrieved= ",nbr_hints_retrieved))
 IF (curqual < 1)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
  FOR (idx = 1 TO nbr_hints_retrieved)
    CALL msgwrite(build2("*** Hint details #",idx,"hint_id= ",reply->hints_list[idx].hint_id,
      "person_id= ",
      reply->hints_list[idx].person_id,"hint_dt_tm= ",reply->hints_list[idx].hint_dt_tm,
      "location_cd= ",reply->hints_list[idx].location_cd,
      "hint_type_cd= ",reply->hints_list[idx].hint_type_cd,"hint_processing_cd= ",reply->hints_list[
      idx].hint_processing_cd,"name_full_formatted= ",
      reply->hints_list[idx].name_full_formatted))
  ENDFOR
 ENDIF
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = reply->status_data.status
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_association_hint"
  IF ((reply->status_data.status="Z"))
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "No Records Found"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Script Failed"
  ENDIF
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE readconfig(null)
   IF (validate(execmsgrtl,999)=999)
    EXECUTE msgrtl
   ENDIF
   SET msg_default = uar_msgdefhandle()
   SET msg_debug = uar_msgopen("bmdi_get_association_hint")
   CALL uar_msgsetlevel(msg_debug,emsglvl_debug)
   DECLARE msgout = vc
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=info_domain
      AND di.info_name=info_name)
    DETAIL
     log_msgview = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (msgwrite(msg=vc) =i2)
  SET log_msgview = 1
  IF (log_msgview=1)
   CALL uar_msgwrite(msg_debug,emsglog_commit,nullterm("BMDI"),emsglvl_debug,nullterm(msg))
  ENDIF
 END ;Subroutine
END GO
