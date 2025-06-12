CREATE PROGRAM dcp_get_pat_list_definition:dba
 RECORD reply(
   1 patient_list_id = f8
   1 name = vc
   1 description = vc
   1 patient_list_type_cd = f8
   1 owner_id = f8
   1 access_cd = f8
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
     2 encntr_class_cd = f8
   1 proxies[*]
     2 prsnl_id = f8
     2 prsnl_group_id = f8
     2 list_access_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE loadpatientlist(null) = f8
 DECLARE loadarguments(null) = null
 DECLARE loadfilters(null) = null
 DECLARE transformdefinition(version=i4) = null
 DECLARE transformdefinition0(null) = null
 DECLARE deleteargument(item=i4) = null
 SET reply->status_data.status = "F"
 DECLARE counter = i4 WITH noconstant(0)
 DECLARE argument_ctr = i4 WITH noconstant(0)
 DECLARE encntr_ctr = i4 WITH noconstant(0)
 DECLARE reltn_ctr = i4 WITH noconstant(0)
 DECLARE prsnl_id = f8 WITH noconstant(reqinfo->updt_id)
 IF ((request->prsnl_id > 0))
  SET prsnl_id = request->prsnl_id
 ENDIF
 IF (loadpatientlist(null) > 0.0)
  CALL loadarguments(null)
  CALL loadfilters(null)
  IF ((request->definition_version=0))
   CALL transformdefinition(request->definition_version)
  ENDIF
  SET stat = alterlist(reply->arguments,argument_ctr)
  SET stat = alterlist(reply->encntr_type_filters,encntr_ctr)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 IF ((reply->access_cd=0))
  SET reply->status_data.status = "F"
 ENDIF
 SUBROUTINE loadpatientlist(null)
   SELECT INTO "nl:"
    FROM dcp_patient_list pl,
     dcp_pl_reltn pr
    PLAN (pl
     WHERE (pl.patient_list_id=request->patient_list_id))
     JOIN (pr
     WHERE outerjoin(pl.patient_list_id)=pr.patient_list_id
      AND pr.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
    ORDER BY pr.reltn_id
    HEAD REPORT
     reply->patient_list_id = pl.patient_list_id, reply->name = pl.name, reply->description = pl
     .description,
     reply->patient_list_type_cd = pl.patient_list_type_cd, reply->owner_id = pl.owner_prsnl_id
     IF (pl.owner_prsnl_id=prsnl_id)
      reply->access_cd = uar_get_code_by("MEANING",27380,"OWNER")
     ENDIF
    HEAD pr.reltn_id
     IF (pr.reltn_id != 0)
      reltn_ctr = (reltn_ctr+ 1)
      IF (mod(reltn_ctr,10)=1)
       stat = alterlist(reply->proxies,(reltn_ctr+ 9))
      ENDIF
      reply->proxies[reltn_ctr].prsnl_id = pr.prsnl_id, reply->proxies[reltn_ctr].prsnl_group_id = pr
      .prsnl_group_id, reply->proxies[reltn_ctr].list_access_cd = pr.list_access_cd,
      reply->proxies[reltn_ctr].beg_effective_dt_tm = cnvtdatetime(pr.beg_effective_dt_tm), reply->
      proxies[reltn_ctr].end_effective_dt_tm = cnvtdatetime(pr.end_effective_dt_tm)
      IF ((reply->access_cd=0)
       AND pr.prsnl_id=prsnl_id)
       reply->access_cd = pr.list_access_cd
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->proxies,reltn_ctr)
    WITH nocounter
   ;end select
   IF ((reply->patient_list_id > 0)
    AND (reply->access_cd=0))
    SELECT INTO "nl:"
     FROM dcp_pl_reltn pr,
      prsnl_group_reltn pgr
     PLAN (pr
      WHERE (pr.patient_list_id=request->patient_list_id)
       AND pr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
      JOIN (pgr
      WHERE pgr.prsnl_group_id=pr.prsnl_group_id
       AND pgr.person_id=prsnl_id)
     HEAD pr.patient_list_id
      reply->access_cd = pr.list_access_cd
     WITH nocounter
    ;end select
   ENDIF
   RETURN(reply->access_cd)
 END ;Subroutine
 SUBROUTINE loadarguments(null)
   SELECT INTO "nl:"
    FROM dcp_pl_argument pa
    PLAN (pa
     WHERE (pa.patient_list_id=request->patient_list_id))
    DETAIL
     argument_ctr = (argument_ctr+ 1)
     IF (mod(argument_ctr,10)=1)
      stat = alterlist(reply->arguments,(argument_ctr+ 9))
     ENDIF
     reply->arguments[argument_ctr].argument_name = pa.argument_name, reply->arguments[argument_ctr].
     argument_value = pa.argument_value, reply->arguments[argument_ctr].parent_entity_name = pa
     .parent_entity_name,
     reply->arguments[argument_ctr].parent_entity_id = pa.parent_entity_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadfilters(null)
   SELECT INTO "nl:"
    FROM dcp_pl_encntr_filter pef
    PLAN (pef
     WHERE (pef.patient_list_id=request->patient_list_id))
    DETAIL
     IF ((request->definition_version=0))
      encntr_ctr = (encntr_ctr+ 1)
      IF (mod(encntr_ctr,10)=1)
       stat = alterlist(reply->encntr_type_filters,(encntr_ctr+ 9))
      ENDIF
      reply->encntr_type_filters[encntr_ctr].encntr_class_cd = pef.encntr_class_cd, reply->
      encntr_type_filters[encntr_ctr].encntr_type_cd = pef.encntr_type_cd
     ELSE
      argument_ctr = (argument_ctr+ 1)
      IF (mod(argument_ctr,10)=1)
       stat = alterlist(reply->arguments,(argument_ctr+ 9))
      ENDIF
      IF (pef.encntr_class_cd != 0)
       reply->arguments[argument_ctr].argument_name = "encntr_class", reply->arguments[argument_ctr].
       parent_entity_id = pef.encntr_class_cd, reply->arguments[argument_ctr].parent_entity_name =
       "CODE_VALUE"
      ELSE
       reply->arguments[argument_ctr].argument_name = "encntr_type", reply->arguments[argument_ctr].
       parent_entity_id = pef.encntr_type_cd, reply->arguments[argument_ctr].parent_entity_name =
       "CODE_VALUE"
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE deleteargument(item)
  IF (item < argument_ctr)
   SET reply->arguments[item].argument_name = reply->arguments[argument_ctr].argument_name
   SET reply->arguments[item].argument_value = reply->arguments[argument_ctr].argument_value
   SET reply->arguments[item].parent_entity_id = reply->arguments[argument_ctr].parent_entity_id
   SET reply->arguments[item].parent_entity_name = reply->arguments[argument_ctr].parent_entity_name
  ENDIF
  SET argument_ctr = (argument_ctr - 1)
 END ;Subroutine
 SUBROUTINE transformdefinition(version)
   CASE (version)
    OF 0:
     CALL transformdefinition0(null)
   ENDCASE
 END ;Subroutine
 SUBROUTINE transformdefinition0(null)
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE reltn_cd = f8 WITH constant(uar_get_code_by("MEANING",27360,"RELTN")), private
   DECLARE vreltn_cd = f8 WITH constant(uar_get_code_by("MEANING",27360,"VRELTN")), private
   DECLARE lreltn_cd = f8 WITH constant(uar_get_code_by("MEANING",27360,"LRELTN")), private
   DECLARE location_cd = f8 WITH constant(uar_get_code_by("MEANING",27360,"LOCATION")), private
   DECLARE locgroup_cd = f8 WITH constant(uar_get_code_by("MEANING",27360,"LOCATIONGRP")), private
   DECLARE loctype = c12 WITH noconstant(fillstring(12," "))
   FOR (x = 1 TO argument_ctr)
     IF ((reply->arguments[x].argument_name="visit_reltn_cd"))
      IF ((reply->arguments[x].parent_entity_id != 0.0))
       SET reply->arguments[x].argument_name = "reltn_cd"
      ENDIF
      IF ((reply->patient_list_type_cd=reltn_cd))
       SET reply->patient_list_type_cd = vreltn_cd
      ENDIF
     ENDIF
     IF ((reply->arguments[x].argument_name="life_reltn_cd"))
      IF ((reply->arguments[x].parent_entity_id != 0.0))
       SET reply->arguments[x].argument_name = "reltn_cd"
      ENDIF
      IF ((reply->patient_list_type_cd=reltn_cd))
       SET reply->patient_list_type_cd = lreltn_cd
      ENDIF
     ENDIF
     IF ((reply->arguments[x].argument_name="careteam_id"))
      SET reply->arguments[x].argument_name = "prsnl_group_id"
     ENDIF
     IF ((reply->arguments[x].argument_name="provider_group_id"))
      SET reply->arguments[x].argument_name = "prsnl_group_id"
     ENDIF
     IF ((reply->arguments[x].argument_name="admit_mins"))
      SET reply->arguments[x].argument_name = "patient_status_minutes"
      SET argument_ctr = (argument_ctr+ 1)
      IF (mod(argument_ctr,10)=1)
       SET stat = alterlist(reply->arguments,(argument_ctr+ 9))
      ENDIF
      SET reply->arguments[argument_ctr].argument_name = "patient_status_flag"
      SET reply->arguments[argument_ctr].argument_value = "1"
     ENDIF
     IF ((reply->arguments[x].argument_name="disch_mins"))
      SET reply->arguments[x].argument_name = "patient_status_minutes"
      SET argument_ctr = (argument_ctr+ 1)
      IF (mod(argument_ctr,10)=1)
       SET stat = alterlist(reply->arguments,(argument_ctr+ 9))
      ENDIF
      SET reply->arguments[argument_ctr].argument_name = "patient_status_flag"
      IF (cnvtint(reply->arguments[x].argument_value) > 0)
       SET reply->arguments[argument_ctr].argument_value = "2"
      ELSE
       SET reply->arguments[argument_ctr].argument_value = "3"
      ENDIF
     ENDIF
     IF ((reply->arguments[x].argument_name="encntr_type"))
      SET encntr_ctr = (encntr_ctr+ 1)
      IF (mod(encntr_ctr,10)=1)
       SET stat = alterlist(reply->encntr_type_filters,(encntr_ctr+ 9))
      ENDIF
      SET reply->encntr_type_filters[encntr_ctr].encntr_class_cd = 0.0
      SET reply->encntr_type_filters[encntr_ctr].encntr_type_cd = reply->arguments[x].
      parent_entity_id
      CALL deleteargument(x)
      SET x = (x - 1)
     ENDIF
     IF ((reply->arguments[x].argument_name="encntr_class"))
      SET encntr_ctr = (encntr_ctr+ 1)
      IF (mod(encntr_ctr,10)=1)
       SET stat = alterlist(reply->encntr_type_filters,(encntr_ctr+ 9))
      ENDIF
      SET reply->encntr_type_filters[encntr_ctr].encntr_class_cd = reply->arguments[x].
      parent_entity_id
      SET reply->encntr_type_filters[encntr_ctr].encntr_type_cd = 0.0
      CALL deleteargument(x)
      SET x = (x - 1)
     ENDIF
     IF ((reply->arguments[x].argument_name="location"))
      SET loctype = uar_get_code_meaning(reply->arguments[x].parent_entity_id)
      IF (loctype="PATLISTROOT"
       AND (reply->patient_list_type_cd=location_cd))
       SET reply->patient_list_type_cd = locgroup_cd
       SET reply->arguments[x].argument_name = "location_group"
      ELSEIF (loctype="FACILITY"
       AND (reply->patient_list_type_cd != location_cd))
       SET reply->arguments[x].argument_name = "facility_filter"
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
END GO
