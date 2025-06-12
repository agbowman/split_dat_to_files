CREATE PROGRAM cpmstartup_afc:dba
 SET trace = callecho
 CALL echo("Executing cpmstartup_afc")
 IF (validate(from_afctest,999)=999)
  SET from_afctest = 0
 ENDIF
 IF (from_afctest=1)
  CALL echo("called from cpmstartup_afctest")
 ELSE
  CALL echo("calling cpmstartup")
  EXECUTE cpmstartup
 ENDIF
 SET trace progcachesize 60
 RECORD code_val(
   1 13029_bbreturn = f8
   1 13029_bbreturning = f8
   1 13029_cancel = f8
   1 13029_canceling = f8
   1 13029_collected = f8
   1 13029_collecting = f8
   1 13029_complete = f8
   1 13029_completing = f8
   1 13029_corrected = f8
   1 13029_correcting = f8
   1 13029_dispensed = f8
   1 13029_dispensing = f8
   1 13029_examcomplete = f8
   1 13029_loaded = f8
   1 13029_ordered = f8
   1 13029_ordering = f8
   1 13029_performed = f8
   1 13029_performing = f8
   1 13029_signout = f8
   1 13029_transfused = f8
   1 13029_transfusing = f8
   1 13029_verified = f8
   1 13029_verifying = f8
   1 13029_setup = f8
   1 13029_uncomplete = f8
   1 13016_charge_event = f8
   1 13016_task_cat = f8
   1 13016_rad_result = f8
   1 13028_collection = f8
   1 13028_nocharge = f8
   1 13028_chargenow = f8
   1 13028_creditnow = f8
   1 13019_workload = f8
   1 13036_discount = f8
   1 13036_diagreqd = f8
   1 13036_physreqd = f8
   1 13036_servres = f8
   1 13019_bill_code = f8
   1 14002_icd9 = f8
 ) WITH persist
 RECORD phlebgroup(
   1 group[*]
     2 prsnl_group_id = f8
 ) WITH persist
 RECORD interfacefiles(
   1 files[*]
     2 interface_file_id = f8
     2 realtime_ind = i2
 ) WITH persist
 CALL echo("CacheCodeValues")
 CALL echo("    Populating code_val struct")
 DECLARE iret = i4
 DECLARE codeset = i4
 DECLARE meaning = c12
 DECLARE index = i4
 DECLARE codevalue = f8
 SET codeset = 13029
 SET meaning = "BBRETURN"
 SET index = 1
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,1,codevalue)
 SET code_val->13029_bbreturn = - (1)
 IF (iret=0)
  SET code_val->13029_bbreturn = codevalue
 ENDIF
 SET meaning = "BBRETURNING"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_bbreturning = - (1)
 IF (iret=0)
  SET code_val->13029_bbreturning = codevalue
 ENDIF
 SET meaning = "CANCEL"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_cancel = - (1)
 IF (iret=0)
  SET code_val->13029_cancel = codevalue
 ENDIF
 SET meaning = "CANCELING"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_canceling = - (1)
 IF (iret=0)
  SET code_val->13029_canceling = codevalue
 ENDIF
 SET meaning = "COLLECTED"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_collected = - (1)
 IF (iret=0)
  SET code_val->13029_collected = codevalue
 ENDIF
 SET meaning = "COLLECTING"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_collecting = - (1)
 IF (iret=0)
  SET code_val->13029_collecting = codevalue
 ENDIF
 SET meaning = "COMPLETE"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_complete = - (1)
 IF (iret=0)
  SET code_val->13029_complete = codevalue
 ENDIF
 SET meaning = "COMPLETING"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_completing = - (1)
 IF (iret=0)
  SET code_val->13029_completing = codevalue
 ENDIF
 SET meaning = "CORRECTED"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_corrected = - (1)
 IF (iret=0)
  SET code_val->13029_corrected = codevalue
 ENDIF
 SET meaning = "CORRECTING"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_correcting = - (1)
 IF (iret=0)
  SET code_val->13029_correcting = codevalue
 ENDIF
 SET meaning = "DISPENSED"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_dispensed = - (1)
 IF (iret=0)
  SET code_val->13029_dispensed = codevalue
 ENDIF
 SET meaning = "DISPENSING"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_dispensing = - (1)
 IF (iret=0)
  SET code_val->13029_dispensing = codevalue
 ENDIF
 SET meaning = "EXAMCOMPLETE"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_examcomplete = - (1)
 IF (iret=0)
  SET code_val->13029_examcomplete = codevalue
 ENDIF
 SET meaning = "LOADED"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_loaded = - (1)
 IF (iret=0)
  SET code_val->13029_loaded = codevalue
 ENDIF
 SET meaning = "ORDERED"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_ordered = - (1)
 IF (iret=0)
  SET code_val->13029_ordered = codevalue
 ENDIF
 SET meaning = "ORDERING"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_ordering = - (1)
 IF (iret=0)
  SET code_val->13029_ordering = codevalue
 ENDIF
 SET meaning = "PERFORMED"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_performed = - (1)
 IF (iret=0)
  SET code_val->13029_performed = codevalue
 ENDIF
 SET meaning = "PERFORMING"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_performing = - (1)
 IF (iret=0)
  SET code_val->13029_performing = codevalue
 ENDIF
 SET meaning = "SIGNOUT"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_signout = - (1)
 IF (iret=0)
  SET code_val->13029_signout = codevalue
 ENDIF
 SET meaning = "TRANSFUSED"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_transfused = - (1)
 IF (iret=0)
  SET code_val->13029_transfused = codevalue
 ENDIF
 SET meaning = "TRANSFUSING"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_transfusing = - (1)
 IF (iret=0)
  SET code_val->13029_transfusing = codevalue
 ENDIF
 SET meaning = "VERIFIED"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_verified = - (1)
 IF (iret=0)
  SET code_val->13029_verified = codevalue
 ENDIF
 SET meaning = "VERIFYING"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_verifying = - (1)
 IF (iret=0)
  SET code_val->13029_verifying = codevalue
 ENDIF
 SET meaning = "SETUP"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_setup = - (1)
 IF (iret=0)
  SET code_val->13029_setup = codevalue
 ENDIF
 SET meaning = "UNCOMPLETE"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13029_uncomplete = - (1)
 IF (iret=0)
  SET code_val->13029_uncomplete = codevalue
 ENDIF
 SET codeset = 13016
 SET meaning = "CHARGE EVENT"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13016_charge_event = - (1)
 IF (iret=0)
  SET code_val->13016_charge_event = codevalue
 ENDIF
 SET meaning = "TASKCAT"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13016_task_cat = - (1)
 IF (iret=0)
  SET code_val->13016_task_cat = codevalue
 ENDIF
 SET meaning = "RAD RESULT"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13016_rad_result = - (1)
 IF (iret=0)
  SET code_val->13016_rad_result = codevalue
 ENDIF
 SET codeset = 13028
 SET meaning = "COLLECTION"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13028_collection = - (1)
 IF (iret=0)
  SET code_val->13028_collection = codevalue
 ENDIF
 SET meaning = "NO CHARGE"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13028_nocharge = - (1)
 IF (iret=0)
  SET code_val->13028_nocharge = codevalue
 ENDIF
 SET meaning = "CHARGE NOW"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13028_chargenow = - (1)
 IF (iret=0)
  SET code_val->13028_chargenow = codevalue
 ENDIF
 SET meaning = "CREDIT NOW"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13028_creditnow = - (1)
 IF (iret=0)
  SET code_val->13028_creditnow = codevalue
 ENDIF
 SET codeset = 13019
 SET meaning = "WORKLOAD"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13019_workload = - (1)
 IF (iret=0)
  SET code_val->13019_workload = codevalue
 ENDIF
 SET codeset = 13036
 SET meaning = "FLAT_DISC"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13036_discount = - (1)
 IF (iret=0)
  SET code_val->13036_discount = codevalue
 ENDIF
 SET meaning = "DIAGREQD"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13036_diagreqd = - (1)
 IF (iret=0)
  SET code_val->13036_diagreqd = codevalue
 ENDIF
 SET meaning = "PHYSREQD"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13036_physreqd = - (1)
 IF (iret=0)
  SET code_val->13036_physreqd = codevalue
 ENDIF
 SET meaning = "SERVICERES"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13036_servres = - (1)
 IF (iret=0)
  SET code_val->13036_servres = codevalue
 ENDIF
 SET codeset = 13019
 SET meaning = "BILL CODE"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->13019_bill_code = - (1)
 IF (iret=0)
  SET code_val->13019_bill_code = codevalue
 ENDIF
 SET codeset = 14002
 SET meaning = "ICD9"
 SET codevalue = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 SET code_val->14002_icd9 = - (1)
 IF (iret=0)
  SET code_val->14002_icd9 = codevalue
 ENDIF
 CALL echorecord(code_val)
 SET codeset = 357
 SET meaning = "PHLEBCHARGE"
 SET codevalue = 0.0
 SET g_phleb_cd = 0.0
 SET iret = uar_get_meaning_by_codeset(codeset,meaning,index,codevalue)
 IF (iret=0)
  SET g_phleb_cd = codevalue
 ELSE
  SET g_phleb_cd = - (1)
 ENDIF
 CALL echo("Begin read Phleb Group")
 SET phleb_cnt = 0
 SELECT INTO "nl:"
  pg.prsnl_group_id
  FROM prsnl_group pg
  WHERE pg.prsnl_group_type_cd=g_phleb_cd
   AND pg.active_ind=1
  DETAIL
   phleb_cnt += 1, stat = alterlist(phlebgroup->group,phleb_cnt), phlebgroup->group[phleb_cnt].
   prsnl_group_id = pg.prsnl_group_id,
   CALL echo(phlebgroup->group[phleb_cnt].prsnl_group_id)
  WITH nocounter
 ;end select
 CALL echo("End read Phleb Group")
 SET count1 = 0
 SELECT INTO "nl:"
  i.interface_file_id, i.realtime_ind
  FROM interface_file i
  WHERE i.active_ind=1
  DETAIL
   count1 += 1, stat = alterlist(interfacefiles->files,count1), interfacefiles->files[count1].
   interface_file_id = i.interface_file_id,
   interfacefiles->files[count1].realtime_ind = i.realtime_ind,
   CALL echo(build("interface_file_id: ",interfacefiles->files[count1].interface_file_id,
    " realtime_ind: ",interfacefiles->files[count1].realtime_ind))
  WITH nocounter
 ;end select
END GO
