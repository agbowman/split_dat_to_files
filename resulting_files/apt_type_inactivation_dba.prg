CREATE PROGRAM apt_type_inactivation:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed_mess = false
 SET table_name = fillstring(50," ")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed_mess = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE apt_type_name = vc
 FOR (o = 1 TO value(size(file_content->qual,5)))
   FREE RECORD request_details
   RECORD request_details(
     1 call_echo_ind = i2
     1 allow_partial_ind = i2
     1 qual[*]
       2 appt_type_cd = f8
       2 info_sch_text_id = f8
       2 text_updt_cnt = i4
       2 updt_cnt = i4
       2 force_updt_ind = i2
       2 version_dt_tm = di8
       2 active_status_cd = f8
       2 version_ind = i2
       2 appt_object_partial_ind = i2
       2 appt_object_qual[*]
         3 assoc_type_cd = f8
         3 sch_object_id = f8
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 force_updt_ind = i2
         3 version_ind = i2
       2 appt_routing_partial_ind = i2
       2 appt_routing_qual[*]
         3 location_cd = f8
         3 sch_action_cd = f8
         3 seq_nbr = i4
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 force_updt_ind = i2
         3 version_ind = i2
       2 filter_partial_ind = i2
       2 filter[*]
         3 free_type_cd = f8
         3 free_type_cd_meaning = c12
         3 child_cd = f8
         3 updt_cnt = i4
         3 force_updt_ind = i2
         3 version_dt_tm = di8
         3 active_status_cd = f8
         3 version_ind = i2
       2 syn_partial_ind = i2
       2 syn[*]
         3 appt_synonym_cd = f8
         3 info_sch_text_id = f8
         3 text_updt_cnt = i4
         3 updt_cnt = i4
         3 force_updt_ind = i2
         3 version_dt_tm = di8
         3 active_status_cd = f8
         3 version_ind = i2
       2 rel_appt_syn_partial_ind = i2
       2 rel_appt_syn_qual[*]
         3 sch_appt_type_syn_r_id = f8
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 allow_partial_ind = i2
         3 version_ind = i2
         3 force_updt_ind = i2
       2 state_partial_ind = i2
       2 state[*]
         3 sch_state_cd = f8
         3 updt_cnt = i4
         3 force_updt_ind = i2
         3 version_dt_tm = di8
         3 active_status_cd = f8
         3 version_ind = i2
       2 loc_partial_ind = i2
       2 loc[*]
         3 location_cd = f8
         3 updt_cnt = i4
         3 force_updt_ind = i2
         3 version_dt_tm = di8
         3 active_status_cd = f8
         3 version_ind = i2
       2 option_partial_ind = i2
       2 option[*]
         3 sch_option_cd = f8
         3 updt_cnt = i4
         3 force_updt_ind = i2
         3 version_dt_tm = di8
         3 active_status_cd = f8
         3 version_ind = i2
       2 product_partial_ind = i2
       2 product[*]
         3 product_cd = f8
         3 updt_cnt = i4
         3 force_updt_ind = i2
         3 version_dt_tm = di8
         3 active_status_cd = f8
         3 version_ind = i2
       2 text_partial_ind = i2
       2 text[*]
         3 text_link_id = f8
         3 updt_cnt = i4
         3 force_updt_ind = i2
         3 version_dt_tm = di8
         3 active_status_cd = f8
         3 version_ind = i2
         3 sub_list_partial_ind = i2
         3 sub_list[*]
           4 parent_table = c32
           4 parent_id = f8
           4 required_ind = i2
           4 seq_nbr = i4
           4 version_dt_tm = di8
           4 active_status_cd = f8
           4 updt_cnt = i4
           4 version_ind = i2
           4 force_updt_ind = i2
           4 temp_flex_partial_ind = i2
           4 temp_flex[*]
             5 version_dt_tm = di8
             5 active_status_cd = f8
             5 updt_cnt = i4
             5 version_ind = i2
             5 force_updt_ind = i2
             5 parent2_table = c32
             5 parent2_id = f8
       2 ord_partial_ind = i2
       2 ord[*]
         3 required_ind = i2
         3 seq_nbr = i4
         3 updt_cnt = i4
         3 force_updt_ind = i2
         3 version_dt_tm = di8
         3 active_status_cd = f8
         3 version_ind = i2
       2 dup_partial_ind = i2
       2 dup[*]
         3 dup_type_cd = f8
         3 dup_action_cd = f8
         3 location_cd = f8
         3 seq_nbr = i4
         3 version_dt_tm = di8
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 version_ind = i2
         3 force_updt_ind = i2
       2 comp_partial_ind = i2
       2 comp[*]
         3 location_cd = f8
         3 seq_nbr = i4
         3 version_dt_tm = di8
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 version_ind = i2
         3 force_updt_ind = i2
         3 comp_loc_partial_ind = i2
         3 comp_loc[*]
           4 comp_location_cd = f8
           4 version_dt_tm = di8
           4 active_status_cd = f8
           4 updt_cnt = i4
           4 version_ind = i2
           4 force_updt_ind = i2
       2 nomen_partial_ind = i2
       2 nomen[*]
         3 appt_nomen_cd = f8
         3 version_dt_tm = di8
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 version_ind = i2
         3 force_updt_ind = i2
         3 nomen_list_partial_ind = i2
         3 nomen_list[*]
           4 seq_nbr = i4
           4 version_dt_tm = di8
           4 active_status_cd = f8
           4 updt_cnt = i4
           4 version_ind = i2
           4 force_updt_ind = i2
       2 notify_partial_ind = i2
       2 notify[*]
         3 location_cd = f8
         3 sch_action_cd = f8
         3 seq_nbr = i4
         3 version_dt_tm = di8
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 version_ind = i2
         3 force_updt_ind = i2
       2 inter_partial_ind = i2
       2 inter[*]
         3 location_cd = f8
         3 inter_type_cd = f8
         3 seq_group_id = f8
         3 version_dt_tm = di8
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 version_ind = i2
         3 force_updt_ind = i2
       2 appt_action_partial_ind = i2
       2 appt_action[*]
         3 location_cd = f8
         3 sch_action_cd = f8
         3 seq_nbr = i4
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 force_updt_ind = i2
         3 version_ind = i2
       2 rel_med_svc_partial_ind = i2
       2 rel_med_svc_qual[*]
         3 rel_med_svc_id = f8
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 allow_partial_ind = i2
         3 version_ind = i2
         3 force_updt_ind = i2
       2 rel_enc_type_partial_ind = i2
       2 rel_enc_type_qual[*]
         3 rel_enc_type_id = f8
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 allow_partial_ind = i2
         3 version_ind = i2
         3 force_updt_ind = i2
   )
   SET apt_type_name = trim(file_content->qual[o].appointment_type_name)
   SET cnt = 0
   SELECT
    s.appt_type_cd, s.updt_cnt
    FROM sch_appt_type s
    WHERE s.description=apt_type_name
    ORDER BY s.appt_type_cd
    HEAD s.appt_type_cd
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(request_details->qual,(cnt+ 9))
     ENDIF
     request_details->qual[cnt].appt_type_cd = s.appt_type_cd, request_details->qual[cnt].
     force_updt_ind = 1, request_details->qual[cnt].updt_cnt = s.updt_cnt
    FOOT REPORT
     stat = alterlist(request_details->qual,cnt)
    WITH nocounter
   ;end select
   SET idx = 0
   SET idx3 = 0
   SELECT
    s.appt_synonym_cd, s.updt_cnt
    FROM sch_appt_syn s
    WHERE expand(idx,1,size(request_details->qual,5),s.appt_type_cd,request_details->qual[idx].
     appt_type_cd)
    ORDER BY s.appt_type_cd, s.appt_synonym_cd
    HEAD s.appt_type_cd
     idx2 = 0, ipos = 0, ipos = locateval(idx3,1,size(request_details->qual,5),s.appt_type_cd,
      request_details->qual[idx3].appt_type_cd)
    HEAD s.appt_synonym_cd
     idx2 = (idx2+ 1)
     IF (mod(idx2,10)=1)
      stat = alterlist(request_details->qual[ipos].syn,(idx2+ 9))
     ENDIF
     request_details->qual[ipos].syn[idx2].appt_synonym_cd = s.appt_synonym_cd, request_details->
     qual[ipos].syn[idx2].force_updt_ind = 1, request_details->qual[ipos].syn[idx2].updt_cnt = s
     .updt_cnt
    FOOT  s.appt_type_cd
     stat = alterlist(request_details->qual[ipos].syn,idx2)
    WITH nocounter
   ;end select
   SET idx = 0
   SET idx3 = 0
   SELECT
    s.location_cd, s.updt_cnt
    FROM sch_appt_loc s
    WHERE expand(idx,1,size(request_details->qual,5),s.appt_type_cd,request_details->qual[idx].
     appt_type_cd)
    ORDER BY s.appt_type_cd, s.location_cd
    HEAD s.appt_type_cd
     idx2 = 0, ipos = 0, ipos = locateval(idx3,1,size(request_details->qual,5),s.appt_type_cd,
      request_details->qual[idx3].appt_type_cd)
    HEAD s.location_cd
     idx2 = (idx2+ 1)
     IF (mod(idx2,10)=1)
      stat = alterlist(request_details->qual[ipos].loc,(idx2+ 9))
     ENDIF
     request_details->qual[ipos].loc[idx2].location_cd = s.location_cd, request_details->qual[ipos].
     loc[idx2].force_updt_ind = 1, request_details->qual[ipos].loc[idx2].updt_cnt = s.updt_cnt
    FOOT  s.appt_type_cd
     stat = alterlist(request_details->qual[ipos].loc,idx2)
    WITH nocounter
   ;end select
   SET idx = 0
   SET idx3 = 0
   SELECT
    s.product_cd, s.updt_cnt
    FROM sch_appt_product s
    WHERE expand(idx,1,size(request_details->qual,5),s.appt_type_cd,request_details->qual[idx].
     appt_type_cd)
    ORDER BY s.appt_type_cd, s.product_cd
    HEAD s.appt_type_cd
     idx2 = 0, ipos = 0, ipos = locateval(idx3,1,size(request_details->qual,5),s.appt_type_cd,
      request_details->qual[idx3].appt_type_cd)
    HEAD s.product_cd
     idx2 = (idx2+ 1)
     IF (mod(idx2,10)=1)
      stat = alterlist(request_details->qual[ipos].product,(idx2+ 9))
     ENDIF
     request_details->qual[ipos].product[idx2].product_cd = s.product_cd, request_details->qual[ipos]
     .product[idx2].force_updt_ind = 1, request_details->qual[ipos].product[idx2].updt_cnt = s
     .updt_cnt
    FOOT  s.appt_type_cd
     stat = alterlist(request_details->qual[ipos].product,idx2)
    WITH nocounter
   ;end select
   SET idx = 0
   SET idx3 = 0
   SELECT
    s.text_link_id, s.updt_cnt
    FROM sch_text_link s
    WHERE expand(idx,1,size(request_details->qual,5),s.parent_id,request_details->qual[idx].
     appt_type_cd)
    ORDER BY s.parent_id, s.text_link_id
    HEAD s.parent_id
     idx2 = 0, ipos = 0, ipos = locateval(idx3,1,size(request_details->qual,5),s.parent_id,
      request_details->qual[idx3].appt_type_cd)
    HEAD s.text_link_id
     idx2 = (idx2+ 1)
     IF (mod(idx2,10)=1)
      stat = alterlist(request_details->qual[ipos].text,(idx2+ 9))
     ENDIF
     request_details->qual[ipos].text[idx2].text_link_id = s.text_link_id, request_details->qual[ipos
     ].text[idx2].force_updt_ind = 1, request_details->qual[ipos].text[idx2].updt_cnt = s.updt_cnt
    FOOT  s.parent_id
     stat = alterlist(request_details->qual[ipos].text,idx2)
    WITH nocounter
   ;end select
   CALL echorecord(request_details)
   EXECUTE sch_inaw_appt_type  WITH replace("REQUEST",request_details)
 ENDFOR
#exit_script
 SET script_ver = " 000 26/06/15 MS035369         Initial Release "
END GO
