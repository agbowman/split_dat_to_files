CREATE PROGRAM ams_fax_station_creation:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Pass Input File Name" = ""
  WITH outdev, directory, inputfile
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
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
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
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 FREE RECORD file_content
 RECORD file_content(
   1 line[*]
     2 col[*]
       3 value = vc
 )
 SELECT INTO "nl:"
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, stat = alterlist(file_content->line,10)
  DETAIL
   line1 = r.line
   IF (size(trim(line1),1) > 0)
    row_count = (row_count+ 1)
    IF (mod(row_count,10)=1
     AND row_count > 10)
     stat = alterlist(file_content->line,(row_count+ 9))
    ENDIF
    stat = alterlist(file_content->line[row_count].col,10), count = 0
    WHILE (size(trim(line1),1) > 0)
      count = (count+ 1)
      IF (count > 10
       AND mod(count,10)=1)
       stat = alterlist(file_content->line[row_count].col,(count+ 9))
      ENDIF
      IF (substring(1,1,line1)="(")
       position = findstring(")",line1,1,0), position = (position+ 1)
      ELSE
       position = findstring(",",line1,1,0)
      ENDIF
      IF (position > 0)
       file_content->line[row_count].col[count].value = substring(1,(position - 1),line1), line1 =
       substring((position+ 1),size(trim(line1),1),line1)
      ELSE
       file_content->line[row_count].col[count].value = line1, line1 = ""
      ENDIF
    ENDWHILE
    stat = alterlist(file_content->line[row_count].col,count)
   ENDIF
  FOOT REPORT
   stat = alterlist(file_content->line,row_count), row_count = 10
  WITH nocounter
 ;end select
 FREE RECORD fax_request
 RECORD fax_request(
   1 active_ind = i2
   1 station_cd = f8
   1 station_name = c20
   1 device_cd = f8
   1 device_name = c40
   1 remote_dev_type_id = f8
   1 country_code = c25
   1 area_code = c25
   1 exchange = c25
   1 phone_suffix = c50
   1 local_flag = i2
   1 device_type_cd = f8
   1 time_scheme_id = f8
   1 phone_mask_id = f8
   1 template_id = f8
   1 delivery_class_q_id = f8
   1 report_list_size_cutoff = i4
   1 report_list = i4
   1 immediate_priority = f8
   1 non_immediate_priority = f8
   1 disabled_ind = i2
   1 send_eot = i2
   1 bundle_page = i4
   1 aging_change = i4
   1 age_criteria = i4
   1 no_of_retries = i4
   1 number_of_copies = i4
   1 qual[*]
     2 retry_type_cd = f8
     2 immed_retry = i4
     2 immed_delay = i4
     2 queued_retry = i4
     2 queued_delay = i4
     2 retry_priority = i4
   1 eot_template_id = f8
   1 station_description = vc
   1 location_cd = f8
   1 send_flag = i2
   1 set_as_default = i2
 )
 DECLARE fax_ind = i2
 DECLARE fax_count = i4
 DECLARE fax_cd = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",3000,"FAX"))
 DECLARE busy_cd = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",2202,"BUSY"))
 DECLARE disconnect_cd = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",2202,
   "DISCONNECTDURINGTRANSMISSION"))
 DECLARE noconnect_cd = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",2202,"NOCONNECT"))
 FOR (fax_ind = 1 TO value(size(file_content->line,5)))
   SET fax_request->active_ind = 0
   SET fax_request->station_cd = 0.00
   SET fax_request->station_name = file_content->line[fax_ind].col[1].value
   SET fax_request->device_cd = 0.00
   SET fax_request->device_name = file_content->line[fax_ind].col[1].value
   SELECT INTO "nl:"
    FROM remote_device_type rdt
    WHERE rdt.output_format_cd=output_format_cd
    DETAIL
     fax_request->remote_dev_type_id = rdt.remote_dev_type_id
    WITH nocounter
   ;end select
   SET fax_request->country_code = file_content->line[fax_ind].col[4].value
   SET fax_request->area_code = file_content->line[fax_ind].col[5].value
   SET fax_request->exchange = file_content->line[fax_ind].col[6].value
   SET fax_request->phone_suffix = file_content->line[fax_ind].col[7].value
   SET fax_request->local_flag = cnvtint(file_content->line[fax_ind].col[3].value)
   IF ((file_content->line[fax_ind].col[3].value=""))
    SET fax_request->local_flag = 0.0
   ENDIF
   SET fax_request->device_type_cd = fax_cd
   SELECT INTO "nl:"
    FROM time_scheme_window tsw
    WHERE tsw.description="24/7"
    DETAIL
     fax_request->time_scheme_id = tsw.time_scheme_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM wp_template wt
    WHERE (wt.short_desc=file_content->line[fax_ind].col[8].value)
    DETAIL
     fax_request->template_id = wt.template_id
    WITH nocounter
   ;end select
   IF ((file_content->line[fax_ind].col[8].value=""))
    SET fax_request->template_id = 0.0
   ENDIF
   SET fax_request->phone_mask_id = 0.00
   SELECT INTO "nl:"
    FROM delivery_class_queue dcq
    WHERE (dcq.description=file_content->line[fax_ind].col[2].value)
    DETAIL
     fax_request->delivery_class_q_id = dcq.delivery_class_queue_id
    WITH nocounter
   ;end select
   SET fax_request->report_list_size_cutoff = 10
   SET fax_request->report_list = 0
   SET fax_request->immediate_priority = 0.00
   SET fax_request->non_immediate_priority = 0.00
   SET fax_request->disabled_ind = 0
   SET fax_request->send_eot = 0
   SET fax_request->bundle_page = 0
   SET fax_request->aging_change = 0
   SET fax_request->age_criteria = 60
   SET fax_request->no_of_retries = 3
   SET fax_request->number_of_copies = 1
   SET stat = alterlist(fax_request->qual,3)
   SET fax_request->qual[0].retry_type_cd = busy_cd
   SET fax_request->qual[0].immed_retry = 2
   SET fax_request->qual[0].immed_delay = 1
   SET fax_request->qual[0].queued_retry = 1
   SET fax_request->qual[0].queued_delay = 5
   SET fax_request->qual[0].retry_priority = 0
   SET fax_request->qual[1].retry_type_cd = disconnect_cd
   SET fax_request->qual[1].immed_retry = 2
   SET fax_request->qual[1].immed_delay = 1
   SET fax_request->qual[1].queued_retry = 1
   SET fax_request->qual[1].queued_delay = 5
   SET fax_request->qual[1].retry_priority = 1
   SET fax_request->qual[2].retry_type_cd = noconnect_cd
   SET fax_request->qual[2].immed_retry = 2
   SET fax_request->qual[2].immed_delay = 1
   SET fax_request->qual[2].queued_retry = 1
   SET fax_request->qual[2].queued_delay = 5
   SET fax_request->qual[2].retry_priority = 1
   SELECT INTO "nl:"
    FROM wp_template wt
    WHERE (wt.short_desc=file_content->line[fax_ind].col[9].value)
    DETAIL
     fax_request->eot_template_id = wt.template_id
    WITH nocounter
   ;end select
   IF ((file_content->line[fax_ind].col[9].value=""))
    SET fax_request->eot_template_id = 0.0
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE (cv.description=file_content->line[fax_ind].col[10].value)
    DETAIL
     fax_request->location_cd = cv.code_value
    WITH nocounter
   ;end select
   IF ((file_content->line[fax_ind].col[10].value=""))
    SET fax_request->location_cd = 0.0
   ENDIF
   SET fax_request->send_flag = 0
   SET fax_request->set_as_default = 0
   EXECUTE rrd_add_station  WITH replace("REQUEST","FAX_REQUEST")
   SET fax_count = (fax_count+ 1)
   FREE RECORD add_device_request
   RECORD add_device_request(
     1 parent_entity_name = c30
     1 parent_entity_id = f8
     1 device_cd = f8
     1 usage_type_cd = f8
   )
   SELECT INTO "nl:"
    FROM device d
    WHERE (d.name=file_content->line[fax_ind].col[1].value)
    DETAIL
     add_device_request->device_cd = d.device_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM prsnl pr
    WHERE pr.name_first_key=cnvtupper(file_content->line[fax_ind].col[11].value)
     AND pr.name_last_key=cnvtupper(file_content->line[fax_ind].col[12].value)
    DETAIL
     add_device_request->parent_entity_id = pr.person_id
    WITH nocounter
   ;end select
   SET add_device_request->parent_entity_name = "PRSNL"
   SET add_device_request->usage_type_cd = fax_cd
   EXECUTE sys_add_devicexref  WITH replace("REQUEST","ADD_DEVICE_REQUEST")
 ENDFOR
 SELECT INTO  $1
  FROM dummyt
  DETAIL
   col 10, "A total of ", fax_count,
   " fax stations were created."
 ;end select
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
