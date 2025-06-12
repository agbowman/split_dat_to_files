CREATE PROGRAM dcp_check_med_notgiven:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 not_given_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE notdone = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE")), protect
 DECLARE med = f8 WITH constant(uar_get_code_by("MEANING",53,"MED")), protect
 DECLARE irepcnt = i2 WITH noconstant(0), protect
 DECLARE person_cnt = i4 WITH protect, noconstant(size(request->medtask_list,5))
 IF (person_cnt=0)
  GO TO exit_script
 ENDIF
 DECLARE checknotgiven(null) = null
 CALL checknotgiven(null)
 SUBROUTINE checknotgiven(null)
   DECLARE numx = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE loc_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE expand(numx,1,size(request->medtask_list,5),ce.parent_event_id,request->medtask_list[numx].
     parent_event_id)
     AND ce.result_status_cd=notdone
     AND ce.event_class_cd=med
    ORDER BY ce.parent_event_id
    HEAD REPORT
     irepcnt = 1, reply->not_given_ind = 1
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
#exit_script
 IF (person_cnt=0
  AND irepcnt=0)
  SET reply->status_data.status = "Z"
 ELSEIF (irepcnt=1)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 SET modify = nopredeclare
END GO
