CREATE PROGRAM bhs_eks_find_prob_diag_preg:dba
 DECLARE mf_canceled = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"CANCELED"))
 DECLARE mf_resolved = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"RESOLVED"))
 DECLARE mf_inactive = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"INACTIVE"))
 DECLARE log_message = vc WITH protect, noconstant(" ")
 DECLARE mn_found = i2 WITH protect, noconstant(0)
 DECLARE mn_num = i4
 DECLARE ms_tempval = vc WITH noconstant(" ")
 DECLARE mn_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_list = i4 WITH protect, noconstant(0)
 SET retval = - (1)
 DECLARE ms_list = vc WITH protect, noconstant(" ")
 IF (reflect(parameter(1,0))="C*")
  SET ms_list = parameter(1,0)
 ELSE
  GO TO exit_script
 ENDIF
 FREE RECORD nomen_list
 RECORD nomen_list(
   1 qual[*]
     2 list_key = vc
 )
 SET opt_list_type = replace(ms_list,"'","")
 WHILE (mn_list < 100
  AND mn_list != 100)
   SET mn_list = (mn_list+ 1)
   SET ms_tempval = piece(opt_list_type,"|",mn_list,"1",0)
   IF (ms_tempval != "1")
    CALL echo(build("ms_tempVal = ",ms_tempval))
    CALL echo(build(" mn_list = ",mn_list))
    SET stat = alterlist(nomen_list->qual,mn_list)
    SET nomen_list->qual[mn_list].list_key = ms_tempval
    SET mn_cnt = mn_list
   ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  FROM bhs_nomen_list b,
   problem p
  PLAN (b
   WHERE expand(mn_num,1,mn_cnt,b.nomen_list_key,nomen_list->qual[mn_num].list_key)
    AND b.active_ind=1)
   JOIN (p
   WHERE p.nomenclature_id=b.nomenclature_id
    AND p.person_id=trigger_personid
    AND  NOT (p.life_cycle_status_cd IN (mf_canceled, mf_resolved, mf_inactive))
    AND p.active_ind=1
    AND p.beg_effective_dt_tm > cnvtlookbehind("1,Y",sysdate)
    AND p.end_effective_dt_tm > sysdate)
  DETAIL
   mn_found = 1
  WITH nocounter
 ;end select
 IF (mn_found=1)
  SET retval = 100
  SET log_message = build2("Success. Problem found.")
  GO TO exit_script
 ELSE
  SET retval = 0
  SET log_message = build2("Problem not found.")
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_nomen_list b,
   diagnosis d
  PLAN (b
   WHERE expand(mn_num,1,mn_cnt,b.nomen_list_key,nomen_list->qual[mn_num].list_key)
    AND b.active_ind=1)
   JOIN (d
   WHERE d.nomenclature_id=b.nomenclature_id
    AND d.encntr_id=trigger_encntrid
    AND d.active_ind=1
    AND d.beg_effective_dt_tm < sysdate
    AND d.end_effective_dt_tm > sysdate)
  DETAIL
   mn_found = 1
  WITH nocounter
 ;end select
 CALL echo(build("curqual= ",curqual))
 IF (curqual > 0)
  SET retval = 100
  SET log_message = build2("Success. Diagnosis found.")
  GO TO exit_script
 ELSE
  SET retval = 0
  SET log_message = build2("Failure. Neither problem nor diagnosis found.")
 ENDIF
#exit_script
 CALL echo(log_message)
END GO
