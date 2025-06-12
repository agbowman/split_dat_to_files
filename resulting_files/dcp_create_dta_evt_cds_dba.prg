CREATE PROGRAM dcp_create_dta_evt_cds:dba
 PAINT
 RECORD internal(
   1 dta_qual[*]
     2 task_assay_cd = f8
     2 mnemonic = vc
     2 event_cd = f8
   1 activity_types[*]
     2 code_value = f8
 )
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET tmp_cdf_meaning = fillstring(12," ")
 SET at_cnt = 0
 SET dta_cnt = 0
 SET temp_task_description = fillstring(40," ")
 SET temp_event_cd = 0.0
 SET work_ind = 1
 SET interaction_cntr = 0
#loop
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,24,79)
 CALL text(2,15,"W E L C O M E   T O   T H E   D T A / E V T  C D")
 CALL text(3,20,"A S S O C I A T I O N   P R O G R A M ")
 CALL text(5,10,"The purpose of this program is to allow the user to enter")
 CALL text(6,10,"an activity type cdf meaning and find the best possible ")
 CALL text(7,10,"event cd for the chosen activity type's dta's.")
 CALL text(11,12,"Please enter the activity type cdf meaning: (enter spaces to exit)")
 CALL text(13,12,"Activity Type CDF Meaning: ")
 CALL accept(13,45,"AAAAAAAAAAAA;CU")
 SET cdf_meaning = curaccept
 IF (cdf_meaning=" ")
  GO TO exit_script
 ENDIF
 SET code_set = 106
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=code_set
   AND c.cdf_meaning=cdf_meaning
   AND c.active_ind=1
  DETAIL
   at_cnt = (at_cnt+ 1)
   IF (at_cnt > size(internal->activity_types,5))
    stat = alterlist(internal->activity_types,(at_cnt+ 2))
   ENDIF
   internal->activity_types[at_cnt].code_value = c.code_value
  WITH nocounter
 ;end select
 IF (at_cnt=0)
  SET work_ind = 0
  GO TO continue
 ENDIF
 SET stat = alterlist(internal->activity_types,at_cnt)
 SELECT INTO "nl:"
  dta.mnemonic, dta.task_assay_cd
  FROM (dummyt d1  WITH seq = value(at_cnt)),
   discrete_task_assay dta
  PLAN (d1)
   JOIN (dta
   WHERE (dta.activity_type_cd=internal->activity_types[d1.seq].code_value)
    AND dta.active_ind=1)
  DETAIL
   dta_cnt = (dta_cnt+ 1)
   IF (dta_cnt > size(internal->dta_qual,5))
    stat = alterlist(internal->dta_qual,(dta_cnt+ 5))
   ENDIF
   internal->dta_qual[dta_cnt].task_assay_cd = dta.task_assay_cd, internal->dta_qual[dta_cnt].
   mnemonic = dta.mnemonic, internal->dta_qual[dta_cnt].event_cd = dta.event_cd
  WITH nocounter
 ;end select
 IF (dta_cnt=0)
  SET work_ind = 0
  GO TO continue
 ENDIF
 CALL text(20,10,"Working...")
 FOR (x = 1 TO dta_cnt)
   SET temp_task_description = internal->dta_qual[x].mnemonic
   SET temp_event_cd = 0.0
   EXECUTE tsk_post_event_code
   UPDATE  FROM discrete_task_assay dta
    SET dta.event_cd = temp_event_cd, dta.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (internal->dta_qual[x].task_assay_cd=dta.task_assay_cd)
     AND (internal->dta_qual[x].mnemonic=dta.mnemonic)
    WITH nocounter
   ;end update
   COMMIT
 ENDFOR
#continue
 IF (work_ind=0)
  CALL text(20,10,"There was nothing to build for the chosen cdf meaning.")
  CALL text(21,10,"Press Enter to continue...")
  CALL accept(21,36,";C")
 ENDIF
 CALL clear(20,5,59)
 CALL clear(21,5,59)
 GO TO loop
#exit_script
 CALL clear(1,1)
END GO
