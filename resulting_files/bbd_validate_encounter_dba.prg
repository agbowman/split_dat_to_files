CREATE PROGRAM bbd_validate_encounter:dba
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
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 encntr_id = f8
     2 donor_encntr_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nstatus = i2 WITH protect, noconstant(0)
 DECLARE nerrorstatus = i2 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  encounter_type_mean = uar_get_code_meaning(e.encntr_type_class_cd)
  FROM encounter e,
   (dummyt d1  WITH seq = value(size(request->qual,5)))
  PLAN (d1)
   JOIN (e
   WHERE (e.encntr_id=request->qual[d1.seq].encntr_id))
  HEAD REPORT
   lcount = 0
  DETAIL
   lcount = (lcount+ 1), stat = alterlist(reply->qual,lcount), reply->qual[lcount].encntr_id = e
   .encntr_id
   IF (encounter_type_mean="BLOODDONOR")
    reply->qual[lcount].donor_encntr_ind = 1
   ELSE
    reply->qual[lcount].donor_encntr_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  CALL subevent_add("SELECT","F","ENCOUNTER",serrormsg)
 ENDIF
#exit_script
 SET modify = nopredeclare
END GO
