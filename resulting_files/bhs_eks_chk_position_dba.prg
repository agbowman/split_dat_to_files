CREATE PROGRAM bhs_eks_chk_position:dba
 DECLARE ms_list = vc WITH protect, noconstant(" ")
 DECLARE mn_num = i4
 DECLARE ms_tempval = vc WITH noconstant(" ")
 DECLARE mn_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_cnt1 = i4 WITH protect, noconstant(0)
 DECLARE mn_list = i4 WITH protect, noconstant(0)
 DECLARE mf_eid = f8 WITH protect, noconstant(0.0)
 DECLARE mf_curr_user = f8 WITH protect, noconstant(0.0)
 SET mf_eid = trigger_encntrid
 SET mf_curr_user = reqinfo->updt_id
 IF (reflect(parameter(1,0))="C*")
  SET ms_list = parameter(1,0)
 ELSE
  GO TO exit_script
 ENDIF
 FREE RECORD pos_list
 RECORD pos_list(
   1 qual[*]
     2 position = vc
     2 position_cd = f8
 )
 SET opt_list_type = replace(ms_list,"'","")
 WHILE (mn_list < 100
  AND mn_list != 100)
   SET mn_list += 1
   SET ms_tempval = piece(opt_list_type,"|",mn_list,"1",0)
   IF (ms_tempval != "1")
    CALL echo(build("ms_tempVal = ",ms_tempval))
    CALL echo(build(" mn_list = ",mn_list))
    SET stat = alterlist(pos_list->qual,mn_list)
    SET pos_list->qual[mn_list].position = ms_tempval
    SET mn_cnt = mn_list
   ENDIF
 ENDWHILE
 SET retval = - (1)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=88
    AND expand(mn_num,1,mn_cnt,cv.display_key,pos_list->qual[mn_num].position)
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
  DETAIL
   mn_cnt1 = locateval(mn_num,1,mn_cnt,cv.display_key,pos_list->qual[mn_num].position), pos_list->
   qual[mn_cnt1].position_cd = cv.code_value,
   CALL echo(build("pos_cd = ",pos_list->qual[mn_cnt1].position_cd))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.person_id=mf_curr_user
    AND expand(mn_num,1,mn_cnt,p.position_cd,pos_list->qual[mn_num].position_cd))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 100
  SET log_message = build2("Success. Position confirmed.")
  GO TO exit_script
 ELSE
  SET retval = 0
  SET log_message = build2("Position not associate with user.")
 ENDIF
#exit_script
 CALL echo(log_message)
END GO
