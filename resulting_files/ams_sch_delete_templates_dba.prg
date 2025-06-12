CREATE PROGRAM ams_sch_delete_templates:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose the templates, inactive or unassociated" = "Inactive",
  "Inactive Templates" = 0,
  "Unassociated Templates" = 0
  WITH outdev, option, inactivetemplates,
  unassociatedtemplates
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET script_failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE SET temp_request
 RECORD temp_request(
   1 call_echo_ind = i2
   1 allow_partial_ind = i2
   1 qual[*]
     2 def_sched_id = f8
     2 info_sch_text_id = f8
     2 text_updt_cnt = i4
     2 updt_cnt = i4
     2 force_updt_ind = i2
     2 res_partial_ind = i2
     2 res_list_cnt = i4
     2 res_list[*]
       3 resource_cd = f8
       3 updt_cnt = i4
       3 force_updt_ind = i2
     2 slot_partial_ind = i2
     2 slot_list_cnt = i4
     2 slot_list[*]
       3 def_slot_id = f8
       3 seq_nbr = i4
       3 updt_cnt = i4
       3 force_updt_ind = i2
 )
 SET temp_request->call_echo_ind = true
 SET temp_request->allow_partial_ind = false
 SET t_index = 0
 SELECT INTO "nl:"
  a.def_sched_id, lt.updt_cnt
  FROM sch_def_sched a,
   long_text_reference lt
  PLAN (a
   WHERE a.def_sched_id IN ( $UNASSOCIATEDTEMPLATES,  $INACTIVETEMPLATES)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (lt
   WHERE lt.long_text_id=a.info_sch_text_id)
  DETAIL
   t_index = (t_index+ 1), stat = alterlist(temp_request->qual,t_index), temp_request->qual[t_index].
   def_sched_id = a.def_sched_id,
   temp_request->qual[t_index].info_sch_text_id = a.info_sch_text_id, temp_request->qual[t_index].
   text_updt_cnt = lt.updt_cnt, temp_request->qual[t_index].updt_cnt = a.updt_cnt,
   temp_request->qual[t_index].force_updt_ind = false, temp_request->qual[t_index].res_partial_ind =
   false, temp_request->qual[t_index].res_list_cnt = 0,
   temp_request->qual[t_index].slot_partial_ind = false, temp_request->qual[t_index].slot_list_cnt =
   0
  WITH nocounter
 ;end select
 SET inum = 0
 SET t_index2 = 0
 SELECT INTO "nl:"
  FROM sch_def_res s
  WHERE expand(inum,1,size(temp_request->qual,5),s.def_sched_id,temp_request->qual[inum].def_sched_id
   )
  HEAD s.def_sched_id
   t_index2 = 0
  DETAIL
   t_index2 = (t_index2+ 1), ipos = 0, ilocidx = 0,
   ipos = locateval(ilocidx,1,size(temp_request->qual,5),s.def_sched_id,temp_request->qual[ilocidx].
    def_sched_id), stat = alterlist(temp_request->qual[ilocidx].res_list,t_index2), temp_request->
   qual[ilocidx].res_list[t_index2].resource_cd = s.resource_cd,
   temp_request->qual[ilocidx].res_list[t_index2].updt_cnt = s.updt_cnt, temp_request->qual[ilocidx].
   res_list[t_index2].force_updt_ind = true
  FOOT  s.def_sched_id
   temp_request->qual[ilocidx].res_list_cnt = t_index2
  WITH nocounter, expand = 1
 ;end select
 SET inum2 = 0
 SET t_index3 = 0
 SELECT INTO "nl:"
  s.def_slot_id
  FROM sch_def_slot s
  WHERE expand(inum2,1,size(temp_request->qual,5),s.def_sched_id,temp_request->qual[inum2].
   def_sched_id)
  HEAD s.def_sched_id
   t_index3 = 0
  DETAIL
   t_index3 = (t_index3+ 1), ipos2 = 0, ilocidx2 = 0,
   ipos2 = locateval(ilocidx2,1,size(temp_request->qual,5),s.def_sched_id,temp_request->qual[ilocidx2
    ].def_sched_id), stat = alterlist(temp_request->qual[ilocidx2].slot_list,t_index3), temp_request
   ->qual[ilocidx2].slot_list[t_index3].def_slot_id = s.def_slot_id,
   temp_request->qual[ilocidx2].slot_list[t_index3].updt_cnt = s.updt_cnt, temp_request->qual[
   ilocidx2].slot_list[t_index3].force_updt_ind = true, temp_request->qual[ilocidx2].slot_list[
   t_index3].seq_nbr = s.seq_nbr
  FOOT  s.def_sched_id
   temp_request->qual[ilocidx2].slot_list_cnt = t_index3
  WITH nocounter, expand = 1
 ;end select
 EXECUTE sch_delw_def_sched  WITH replace("REQUEST",temp_request)
 SELECT INTO value( $OUTDEV)
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   col 5, "Selected templates were deleted."
  WITH nocounter
 ;end select
#exit_script
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SET last_mod = "001 09/30/14 ZA030646  Initial Release"
END GO
