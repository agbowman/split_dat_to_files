CREATE PROGRAM dcp_fire_demog_rules:dba
 DECLARE initializerulerequest(null) = null
 DECLARE executerules(null) = null
 DECLARE invokerule(index=i4) = null
 DECLARE conditioncnt = i4 WITH noconstant(0)
 RECORD reply(
   1 display_item[*]
     2 rule_cd = f8
     2 display_text = vc
     2 dll_name = vc
     2 comp_name = vc
     2 priority = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD rulerequest(
   1 person_id = f8
   1 birth_dt = dq8
   1 gender_cd = f8
   1 encntr_id = f8
   1 registration_dt = dq8
   1 discharge_dt = dq8
   1 encntr_type_cd = f8
   1 encntr_status_cd = f8
   1 facility_cd = f8
   1 building_cd = f8
   1 unit_cd = f8
   1 room_cd = f8
   1 bed_cd = f8
   1 properties[*]
     2 name = vc
     2 value = vc
 )
 RECORD rulereply(
   1 display_item[*]
     2 display_text = vc
     2 dll_name = vc
     2 comp_name = vc
     2 priority = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL initializerulerequest(null)
 CALL executerules(null)
 SUBROUTINE initializerulerequest(null)
   SET rulerequest->person_id = request->person_id
   SET rulerequest->gender_cd = request->gender_cd
   SET rulerequest->encntr_id = request->encntr_id
   SET rulerequest->birth_dt = request->birth_dt
   SET rulerequest->registration_dt = request->registration_dt
   SET rulerequest->discharge_dt = request->discharge_dt
   SET rulerequest->encntr_type_cd = request->encntr_type_cd
   SET rulerequest->encntr_status_cd = request->encntr_status_cd
   SET rulerequest->facility_cd = request->facility_cd
   SET rulerequest->building_cd = request->building_cd
   SET rulerequest->unit_cd = request->unit_cd
   SET rulerequest->room_cd = request->room_cd
   SET rulerequest->bed_cd = request->bed_cd
 END ;Subroutine
 SUBROUTINE executerules(null)
   DECLARE rulecnt = i4 WITH constant(size(request->rule,5)), private
   SET reply->status_data.status = "Z"
   FOR (x = 1 TO rulecnt)
     CALL invokerule(x)
   ENDFOR
   IF (conditioncnt > 0)
    SET reply->status_data.status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE invokerule(index)
   DECLARE propcnt = i4 WITH constant(size(request->rule[index].properties,5))
   SET stat = alterlist(rulerequest->properties,propcnt)
   FOR (x = 1 TO propcnt)
    SET rulerequest->properties[x].name = request->rule[index].properties[x].name
    SET rulerequest->properties[x].value = request->rule[index].properties[x].value
   ENDFOR
   SET rulereply->status_data.status = "Z"
   EXECUTE value(cnvtupper(trim(request->rule[index].script)))  WITH replace(request,rulerequest),
   replace(reply,rulereply)
   IF ((((rulereply->status_data.status="S")) OR ((rulereply->status_data.status="s"))) )
    SET cnt = size(rulereply->display_item,5)
    SET stat = alterlist(reply->display_item,(conditioncnt+ cnt))
    FOR (y = 1 TO cnt)
      SET conditioncnt = (conditioncnt+ 1)
      SET reply->display_item[conditioncnt].comp_name = rulereply->display_item[y].comp_name
      SET reply->display_item[conditioncnt].dll_name = rulereply->display_item[y].dll_name
      SET reply->display_item[conditioncnt].display_text = rulereply->display_item[y].display_text
      SET reply->display_item[conditioncnt].priority = rulereply->display_item[y].priority
      SET reply->display_item[conditioncnt].rule_cd = request->rule[index].rule_cd
    ENDFOR
   ENDIF
 END ;Subroutine
END GO
