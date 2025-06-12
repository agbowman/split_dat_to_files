CREATE PROGRAM dcp_get_pl_military_unit:dba
 FREE RECORD criteria
 RECORD criteria(
   1 organizations[*]
     2 organization_id = f8
 )
 DECLARE errmsg = vc WITH noconstant("")
 DECLARE patient_cnt = i4 WITH noconstant(0)
 DECLARE security_flag = i2 WITH noconstant(0)
 DECLARE parsearguments(null) = null
 DECLARE checkorgsecurity(null) = null
 DECLARE queryforpatients(null) = null
 IF (size(request->arguments,5) > 0)
  CALL parsearguments(null)
  IF (size(criteria->organizations,5) > 0)
   CALL queryforpatients(null)
  ENDIF
 ENDIF
 SUBROUTINE parsearguments(null)
   DECLARE arg_nbr = i4 WITH noconstant(size(request->arguments,5)), private
   DECLARE org_cnt = i4 WITH noconstant(0), private
   FOR (counter = 1 TO arg_nbr)
     IF (cnvtlower(request->arguments[counter].argument_name)="organization")
      SET org_cnt = (org_cnt+ 1)
      IF (mod(org_cnt,10)=1)
       SET stat = alterlist(criteria->organizations,(org_cnt+ 9))
      ENDIF
      SET criteria->organizations[org_cnt].organization_id = request->arguments[counter].
      parent_entity_id
     ENDIF
   ENDFOR
   SET stat = alterlist(criteria->organizations,org_cnt)
 END ;Subroutine
 SUBROUTINE queryforpatients(null)
  DECLARE num = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM person_military pm,
    person p,
    (dummyt d  WITH seq = size(criteria->organizations,5))
   PLAN (d)
    JOIN (pm
    WHERE (((pm.assigned_unit_org_id=criteria->organizations[d.seq].organization_id)) OR ((pm
    .attached_unit_org_id=criteria->organizations[d.seq].organization_id))) )
    JOIN (p
    WHERE p.person_id=pm.person_id
     AND p.active_ind=1)
   DETAIL
    IF (locateval(num,1,patient_cnt,p.person_id,reply->patients[num].person_id)=0)
     patient_cnt = (patient_cnt+ 1)
     IF (mod(patient_cnt,10)=1)
      stat = alterlist(reply->patients,(patient_cnt+ 9))
     ENDIF
     reply->patients[patient_cnt].organization_id = criteria->organizations[d.seq].organization_id,
     reply->patients[patient_cnt].person_name = p.name_full_formatted, reply->patients[patient_cnt].
     person_id = p.person_id,
     reply->patients[patient_cnt].active_ind = 1
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->patients,patient_cnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SET errorcode = error(errmsg,0)
 IF (errorcode != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ErrorMessage"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
 ELSEIF (patient_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
