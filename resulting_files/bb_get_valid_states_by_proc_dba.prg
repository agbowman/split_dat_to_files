CREATE PROGRAM bb_get_valid_states_by_proc:dba
 RECORD reply(
   1 category_list[*]
     2 category_cd = f8
     2 category_disp = c40
     2 category_mean = c12
     2 valid_states_list[*]
       3 state_cd = f8
       3 state_disp = c40
       3 state_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE lblood_bank_process_cs = i4 WITH constant(1664)
 DECLARE sblood_bank_process_mean = c12 WITH constant(request->process_meaning)
 DECLARE sscript_name = c27 WITH constant("bb_get_valid_states_by_proc")
 DECLARE suarerrstring = vc WITH noconstant("")
 DECLARE serrmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE ierrorcheck = i2 WITH noconstant(error(serrmsg,1))
 DECLARE inovalidstates = i2 WITH noconstant(0)
 DECLARE lcategorycount = i4 WITH noconstant(0)
 DECLARE lvalidstatecount = i4 WITH noconstant(0)
 DECLARE dbloodbankprocesscd = f8 WITH noconstant(0.0)
 SET dbloodbankprocesscd = uar_get_code_by("MEANING",lblood_bank_process_cs,nullterm(
   sblood_bank_process_mean))
 IF (dbloodbankprocesscd <= 0.0)
  SET suarerrstring = concat("Failed to retrieve Blood Bank process code with meaning of ",trim(
    sblood_bank_process_mean),".")
  CALL errorhandler("F","uar_get_code_by",suarerrstring)
 ENDIF
 SET inovalidstates = 0
 SELECT INTO "nl:"
  vs.category_cd, vs.state_cd
  FROM valid_state vs
  PLAN (vs
   WHERE vs.process_cd=dbloodbankprocesscd
    AND vs.active_ind=1)
  ORDER BY vs.category_cd
  HEAD REPORT
   stat = alterlist(reply->category_list,10), lcategorycount = 0
  HEAD vs.category_cd
   lcategorycount += 1
   IF (mod(lcategorycount,10)=1
    AND lcategorycount != 1)
    stat = alterlist(reply->category_list,(lcategorycount+ 9))
   ENDIF
   reply->category_list[lcategorycount].category_cd = vs.category_cd, stat = alterlist(reply->
    category_list[lcategorycount].valid_states_list,10), lvalidstatecount = 0
  DETAIL
   lvalidstatecount += 1
   IF (mod(lvalidstatecount,10)=1
    AND lvalidstatecount != 1)
    stat = alterlist(reply->category_list[lcategorycount].valid_states_list,(lvalidstatecount+ 9))
   ENDIF
   reply->category_list[lcategorycount].valid_states_list[lvalidstatecount].state_cd = vs.state_cd
  FOOT  vs.category_cd
   stat = alterlist(reply->category_list[lcategorycount].valid_states_list,lvalidstatecount)
  FOOT REPORT
   stat = alterlist(reply->category_list,lcategorycount)
  WITH nocounter
 ;end select
 SET ierrorcheck = error(serrmsg,0)
 IF (ierrorcheck=0)
  IF (curqual=0)
   SET inovalidstates = 1
  ENDIF
 ELSE
  CALL errorhandler("F","Get valid states",serrmsg)
 ENDIF
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = sscript_name
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
 IF (inovalidstates=1)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
