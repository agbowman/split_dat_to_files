CREATE PROGRAM dm_stat_gather_solcap:dba
 DECLARE initializescriptlog(parent_script=vc) = null
 DECLARE startscriptlog(script_name=vc,script_type=vc) = null
 DECLARE stopscriptlog("X") = null
 DECLARE parent_script_name = vc WITH noconstant("NOT_INITIALIZED")
 DECLARE current_script_type = vc WITH noconstant("NOT_INITIALIZED")
 DECLARE current_script_name = vc WITH noconstant("NOT_INITIALIZED")
 DECLARE current_script_start_time = dq8 WITH noconstant(cnvtdatetime("01-JAN-1800"))
 DECLARE current_script_stop_time = dq8 WITH noconstant(cnvtdatetime("01-JAN-1800"))
 DECLARE execution_duration = f8 WITH noconstant(0)
 DECLARE filename = vc WITH noconstant("")
 SUBROUTINE initializescriptlog(parent_script)
   SET parent_script_name = parent_script
 END ;Subroutine
 SUBROUTINE startscriptlog(script_name,script_type)
   SET current_script_name = script_name
   SET current_script_type = script_type
   SET current_script_start_time = cnvtdatetime(curdate,curtime3)
 END ;Subroutine
 SUBROUTINE stopscriptlog("X")
   SET current_script_stop_time = cnvtdatetime(curdate,curtime3)
   SET execution_duration = datetimediff(current_script_stop_time,current_script_start_time,5)
   SET filename = concat("dm_script_log_",format(cnvtdatetime(curdate,0),"mmddyy;;D"),".csv")
   SELECT INTO value(filename)
    build2(format(current_script_stop_time,"hh:mm:ss;;m"),",",current_script_name,",",
     execution_duration,
     ",",current_script_type,",",parent_script_name)
    FROM dummyt
    WITH nocounter, append, noheading
   ;end select
 END ;Subroutine
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 IF (validate(rtms_uar_def,999)=999)
  CALL echo("Declaring timerpository_def")
  DECLARE timerepository_def = i2 WITH persist
  SET rtms_uar_def = 1
  IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 81203))
   FREE SET uar_timer_create
   DECLARE uar_timer_create(p1=h(value)) = h WITH image_axp = "timerepository", image_aix =
   "libtimerepository.a(libtimerepository.o)", uar = "TIMER_Create",
   persist
   FREE SET uar_timer_start
   DECLARE uar_timer_start(p1=h(value),p2=vc(ref),p3=h(value)) = i4 WITH image_axp = "timerepository",
   image_aix = "libtimerepository.a(libtimerepository.o)", uar = "TIMER_Start",
   persist
   FREE SET uar_timer_stop
   DECLARE uar_timer_stop(p1=h(value),p2=h(value)) = i4 WITH image_axp = "timerepository", image_aix
    = "libtimerepository.a(libtimerepository.o)", uar = "TIMER_Stop",
   persist
   FREE SET uar_timer_destroy
   DECLARE uar_timer_destroy(p1=h(value)) = i4 WITH image_axp = "timerepository", image_aix =
   "libtimerepository.a(libtimerepository.o)", uar = "TIMER_Destroy",
   persist
   FREE SET uar_createproplist
   DECLARE uar_createproplist() = h WITH image_axp = "srvcore", image_aix =
   "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreatePropList",
   persist
   FREE SET uar_setpropstring
   DECLARE uar_setpropstring(p1=h(value),p2=vc(ref),p3=vc(ref)) = i4 WITH image_axp = "srvcore",
   image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropString",
   persist
   FREE SET uar_closehandle
   DECLARE uar_closehandle(p1=h(value)) = i4 WITH image_axp = "srvcore", image_aix =
   "libsrvcore.a(libsrvcore.o)", uar = "SRV_CloseHandle",
   persist
  ELSE
   FREE SET uar_timer_create
   DECLARE uar_timer_create(p1=i4(value)) = i4 WITH image_axp = "timerepository", image_aix =
   "libtimerepository.a(libtimerepository.o)", uar = "TIMER_Create",
   persist
   FREE SET uar_timer_start
   DECLARE uar_timer_start(p1=i4(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp =
   "timerepository", image_aix = "libtimerepository.a(libtimerepository.o)", uar = "TIMER_Start",
   persist
   FREE SET uar_timer_stop
   DECLARE uar_timer_stop(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "timerepository",
   image_aix = "libtimerepository.a(libtimerepository.o)", uar = "TIMER_Stop",
   persist
   FREE SET uar_timer_destroy
   DECLARE uar_timer_destroy(p1=i4(value)) = i4 WITH image_axp = "timerepository", image_aix =
   "libtimerepository.a(libtimerepository.o)", uar = "TIMER_Destroy",
   persist
   FREE SET uar_createproplist
   DECLARE uar_createproplist() = i4 WITH image_axp = "srvcore", image_aix =
   "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreatePropList",
   persist
   FREE SET uar_setpropstring
   DECLARE uar_setpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref)) = i4 WITH image_axp = "srvcore",
   image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropString",
   persist
   FREE SET uar_closehandle
   DECLARE uar_closehandle(p1=i4(value)) = i4 WITH image_axp = "srvcore", image_aix =
   "libsrvcore.a(libsrvcore.o)", uar = "SRV_CloseHandle",
   persist
  ENDIF
 ENDIF
 IF ( NOT (validate(dsr,0)))
  RECORD dsr(
    1 qual[*]
      2 stat_snap_dt_tm = dq8
      2 snapshot_type = c100
      2 client_mnemonic = c10
      2 domain_name = c20
      2 node_name = c30
      2 qual[*]
        3 stat_name = vc
        3 stat_seq = i4
        3 stat_str_val = vc
        3 stat_type = i4
        3 stat_number_val = f8
        3 stat_date_val = dq8
        3 stat_clob_val = vc
  )
 ENDIF
 DECLARE mss_subtimer = vc WITH constant(cnvtupper(trim(request->solcap_script)))
 DECLARE mss_index = i4 WITH constant(request->solcap_script_index)
 DECLARE mss_start_time = dq8 WITH constant(request->start_dt_tm)
 DECLARE mss_end_time = dq8 WITH constant(request->end_dt_tm)
 FREE RECORD request
 RECORD request(
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
 )
 FREE RECORD reply
 RECORD reply(
   1 solcap[*]
     2 identifier = vc
     2 degree_of_use_num = i4
     2 degree_of_use_str = vc
     2 distinct_user_count = i4
     2 position[*]
       3 display = vc
       3 value_num = i4
       3 value_str = vc
     2 facility[*]
       3 display = vc
       3 value_num = i4
       3 value_str = vc
     2 other[*]
       3 category_name = vc
       3 value[*]
         4 display = vc
         4 value_num = i4
         4 value_str = vc
 )
 FREE RECORD issues
 RECORD issues(
   1 issue[*]
     2 passfail = vc
     2 issuetext = vc
 )
 DECLARE idx = i4 WITH noconstant, protect
 DECLARE idx2 = i4 WITH noconstant, protect
 DECLARE idx3 = i4 WITH noconstant, protect
 DECLARE ds_cnt = i4 WITH noconstant, protect
 DECLARE ds_cnt2 = i4 WITH noconstant, protect
 CALL initializescriptlog("DM_STAT_GATHER_SOLCAP")
 DECLARE logfile = c100
 DECLARE debug_msg_ind = i2
 DECLARE d_err_msg = c132
 SET logfile = build("DM_STAT_SOLCAP_",curnode,"_",day(curdate),".txt")
 CALL getdebugrow("x")
 CALL log_msg("BeginSession",logfile)
 SET stat = alterlist(reply->solcap,100)
 SET idx = 0
 WHILE (idx < 100)
   SET idx = (idx+ 1)
   SET reply->solcap[idx].degree_of_use_num = - (1)
   SET reply->solcap[idx].degree_of_use_str = "NA"
   SET reply->solcap[idx].distinct_user_count = - (1)
 ENDWHILE
 SET request->start_dt_tm = mss_start_time
 SET request->end_dt_tm = mss_end_time
 CALL log_msg(build("StartTime: ",format(mss_start_time,";;q")),logfile)
 CALL log_msg(build("EndTime: ",format(mss_end_time,";;q")),logfile)
 CALL log_msg(build("Subtimer: ",mss_subtimer),logfile)
 CALL log_msg(build("INDEX: ",mss_index),logfile)
 SET stat = alterlist(dsr->qual,1)
 SET dsr->qual[1].stat_snap_dt_tm = cnvtdatetime((curdate - 1),0)
 SET dsr->qual[1].snapshot_type = build("SOLCAP||",mss_subtimer)
 IF (checkprg(mss_subtimer))
  CALL startscriptlog(mss_subtimer,"SOLCAP")
  EXECUTE value(mss_subtimer)
  CALL stopscriptlog("x")
  IF (debug_msg_ind=1)
   CALL echorecord(reply)
  ENDIF
 ELSE
  SET stat = alterlist(dsr->qual[1].qual,1)
  SET dsr->qual[1].qual[1].stat_name = "SCRIPT_NOT_FOUND"
  SET dsr->qual[1].qual[1].stat_seq = 1
  IF (debug_msg_ind=1)
   CALL esmerror(build2("Script ",mss_subtimer," was not found in the object library"),esmreturn)
  ENDIF
  GO TO exit_program
 ENDIF
 CALL auditreply("x")
 SET idx = 0
 SET idx2 = 0
 SET idx3 = 0
 SET ds_cnt = 0
 SET ds_cnt2 = 0
 IF (size(reply->solcap,5)=0)
  SET stat = alterlist(dsr->qual[1].qual,1)
  SET dsr->qual[1].qual[1].stat_name = "NO_NEW_DATA"
  SET dsr->qual[1].qual[1].stat_seq = 1
 ELSE
  WHILE (idx < size(reply->solcap,5))
    SET ds_cnt2 = 0
    SET idx = (idx+ 1)
    SET ds_cnt2 = (ds_cnt2+ 1)
    SET ds_cnt = (ds_cnt+ 1)
    IF (mod(ds_cnt,10)=1)
     SET stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
    ENDIF
    SET dsr->qual[1].qual[ds_cnt].stat_name = trim(substring(1,80,reply->solcap[idx].identifier))
    SET dsr->qual[1].qual[ds_cnt].stat_str_val = "DATA_INTEGRITY"
    SET dsr->qual[1].qual[ds_cnt].stat_seq = ds_cnt2
    IF ((issues->issue[idx].passfail="FAIL"))
     SET dsr->qual[1].qual[ds_cnt].stat_clob_val = build2("FAIL||",issues->issue[idx].issuetext)
    ELSE
     SET dsr->qual[1].qual[ds_cnt].stat_clob_val = "PASS"
    ENDIF
    SET ds_cnt = (ds_cnt+ 1)
    SET ds_cnt2 = (ds_cnt2+ 1)
    IF (mod(ds_cnt,10)=1)
     SET stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
    ENDIF
    SET dsr->qual[1].qual[ds_cnt].stat_name = trim(substring(1,80,reply->solcap[idx].identifier))
    SET dsr->qual[1].qual[ds_cnt].stat_str_val = "DEGREEOFUSE"
    SET dsr->qual[1].qual[ds_cnt].stat_seq = ds_cnt2
    SET dsr->qual[1].qual[ds_cnt].stat_clob_val = build(reply->solcap[idx].degree_of_use_num,"||",
     trim(substring(1,1024,reply->solcap[idx].degree_of_use_str)))
    SET ds_cnt = (ds_cnt+ 1)
    SET ds_cnt2 = (ds_cnt2+ 1)
    IF (mod(ds_cnt,10)=1)
     SET stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
    ENDIF
    SET dsr->qual[1].qual[ds_cnt].stat_name = trim(substring(1,80,reply->solcap[idx].identifier))
    SET dsr->qual[1].qual[ds_cnt].stat_str_val = "USERCOUNT"
    SET dsr->qual[1].qual[ds_cnt].stat_seq = ds_cnt2
    SET dsr->qual[1].qual[ds_cnt].stat_clob_val = build(reply->solcap[idx].distinct_user_count)
    SET idx2 = 0
    WHILE (idx2 < size(reply->solcap[idx].position,5))
      SET idx2 = (idx2+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET ds_cnt2 = (ds_cnt2+ 1)
      IF (mod(ds_cnt,10)=1)
       SET stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
      ENDIF
      SET dsr->qual[1].qual[ds_cnt].stat_name = trim(substring(1,80,reply->solcap[idx].identifier))
      SET dsr->qual[1].qual[ds_cnt].stat_str_val = "POSITION"
      SET dsr->qual[1].qual[ds_cnt].stat_seq = ds_cnt2
      SET dsr->qual[1].qual[ds_cnt].stat_clob_val = build(trim(substring(1,128,reply->solcap[idx].
         position[idx2].display)),"||",reply->solcap[idx].position[idx2].value_num,"||",trim(
        substring(1,1024,reply->solcap[idx].position[idx2].value_str)))
    ENDWHILE
    SET idx2 = 0
    WHILE (idx2 < size(reply->solcap[idx].facility,5))
      SET idx2 = (idx2+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET ds_cnt2 = (ds_cnt2+ 1)
      IF (mod(ds_cnt,10)=1)
       SET stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
      ENDIF
      SET dsr->qual[1].qual[ds_cnt].stat_name = trim(substring(1,80,reply->solcap[idx].identifier))
      SET dsr->qual[1].qual[ds_cnt].stat_str_val = "FACILITY"
      SET dsr->qual[1].qual[ds_cnt].stat_seq = ds_cnt2
      SET dsr->qual[1].qual[ds_cnt].stat_clob_val = build(trim(substring(1,128,reply->solcap[idx].
         facility[idx2].display)),"||",reply->solcap[idx].facility[idx2].value_num,"||",trim(
        substring(1,1024,reply->solcap[idx].facility[idx2].value_str)))
    ENDWHILE
    SET idx2 = 0
    WHILE (idx2 < size(reply->solcap[idx].other,5))
      SET idx2 = (idx2+ 1)
      SET idx3 = 0
      WHILE (idx3 < size(reply->solcap[idx].other[idx2].value,5))
        SET idx3 = (idx3+ 1)
        SET ds_cnt = (ds_cnt+ 1)
        SET ds_cnt2 = (ds_cnt2+ 1)
        IF (mod(ds_cnt,10)=1)
         SET stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
        ENDIF
        SET dsr->qual[1].qual[ds_cnt].stat_name = trim(substring(1,80,reply->solcap[idx].identifier))
        SET dsr->qual[1].qual[ds_cnt].stat_str_val = trim(substring(1,255,reply->solcap[idx].other[
          idx2].category_name))
        SET dsr->qual[1].qual[ds_cnt].stat_seq = ds_cnt2
        SET dsr->qual[1].qual[ds_cnt].stat_clob_val = build(trim(substring(1,128,reply->solcap[idx].
           other[idx2].value[idx3].display)),"||",reply->solcap[idx].other[idx2].value[idx3].
         value_num,"||",trim(substring(1,1024,reply->solcap[idx].other[idx2].value[idx3].value_str)))
      ENDWHILE
    ENDWHILE
  ENDWHILE
  SET stat = alterlist(dsr->qual[1].qual,ds_cnt)
 ENDIF
 GO TO exit_program
 SUBROUTINE log_msg(logmsg,sbr_dlogfile)
   IF (debug_msg_ind=1)
    SELECT INTO value(sbr_dlogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      beg_pos = 1, end_pos = 132, not_done = 1,
      dm_eproc_length = textlen(logmsg)
     DETAIL
      IF (logmsg="BeginSession")
       row + 1, "DM_STAT_GATHER_SOLCAP Begins:", row + 1,
       curdate"mm/dd/yyyy;;d", " ", curtime3"hh:mm:ss;3;m"
      ELSEIF (logmsg="EndSession")
       row + 1, "DM_STAT_GATHER_SOLCAP Ends:", row + 1,
       curdate"mm/dd/yyyy;;d", " ", curtime3"hh:mm:ss;3;m"
      ELSE
       dm_txt = substring(beg_pos,end_pos,logmsg)
       WHILE (not_done=1)
         row + 1, col 0, dm_txt,
         row + 1, curdate"mm/dd/yyyy;;d", " ",
         curtime3"hh:mm:ss;3;m"
         IF (end_pos > dm_eproc_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,logmsg)
         ENDIF
       ENDWHILE
      ENDIF
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 200, append
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE getdebugrow(x)
  SELECT INTO "nl:"
   di.info_number
   FROM dm_info di
   WHERE info_domain="DM_STAT_GATHER_SOLCAP_DEBUG"
    AND info_name="DEBUG_IND"
   DETAIL
    debug_msg_ind = di.info_number
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_info
    SET info_domain = "DM_STAT_GATHER_SOLCAP_DEBUG", info_name = "DEBUG_IND", info_number = 0
    WITH nocounter
   ;end insert
   COMMIT
   SET debug_msg_ind = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE auditreply(x)
   SET idx = 0
   SET idx2 = 0
   SET idx3 = 0
   SET issuecount = 0
   WHILE (idx < size(reply->solcap,5))
     SET idx = (idx+ 1)
     SET stat = alterlist(issues->issue,idx)
     IF (substring(1,7,reply->solcap[idx].identifier)="2009.01")
      CALL addissue(idx,build2("Capability: ",reply->solcap[idx].identifier,
        " should not start with 2009.01"))
     ENDIF
     IF (size(reply->solcap[idx].identifier,3)=0)
      CALL addissue(idx,build2("Capability identifier is empty for capability number ",trim(
         cnvtstring(idx))))
     ENDIF
     IF ((reply->solcap[idx].degree_of_use_num < 0)
      AND (reply->solcap[idx].degree_of_use_str="NA"))
      CALL addissue(idx,build2("Either Degree_of_use_num or Degree_of_use_Str must be filled out for",
        reply->solcap[idx].identifier))
     ENDIF
     IF (size(reply->solcap[idx].identifier,3) > 80)
      CALL addissue(idx,build2("Capability: ",reply->solcap[idx].identifier,
        " cannot be more than 80 characters.  Size: ",trim(cnvtstring(size(reply->solcap[idx].
           identifier,3)))))
     ENDIF
     IF (size(reply->solcap[idx].degree_of_use_str,3) > 1024)
      CALL addissue(idx,build2("Degree of Use Str for ",reply->solcap[idx].identifier,
        " cannot be more than 1024 characters. ","Size: ",trim(cnvtstring(size(reply->solcap[idx].
           degree_of_use_str,3)))))
     ENDIF
     SET idx2 = 0
     WHILE (idx2 < size(reply->solcap[idx].position,5))
       SET idx2 = (idx2+ 1)
       IF (size(reply->solcap[idx].position[idx2].display,3) > 128)
        CALL addissue(idx,build2("Position display cannot be more than 128 characters. ","Size: ",
          trim(cnvtstring(size(reply->solcap[idx].position[idx2].display,3)))))
       ENDIF
       IF ((reply->solcap[idx].position[idx2].value_num < 0))
        CALL addissue(idx,build2("Value_num for position field cannot be less than zero"))
       ENDIF
       IF (size(reply->solcap[idx].position[idx2].value_str,3) > 1024)
        CALL addissue(idx,build2("Position value_str cannot be more than 1024 characters. ","Size: ",
          trim(cnvtstring(size(reply->solcap[idx].position[idx2].value_str,3)))))
       ENDIF
     ENDWHILE
     SET idx2 = 0
     WHILE (idx2 < size(reply->solcap[idx].facility,5))
       SET idx2 = (idx2+ 1)
       IF (size(reply->solcap[idx].facility[idx2].display,3) > 128)
        CALL addissue(idx,build2("Facility display cannot be more than 128 characters. ","Size: ",
          trim(cnvtstring(size(reply->solcap[idx].facility[idx2].display,3)))))
       ENDIF
       IF ((reply->solcap[idx].facility[idx2].value_num < 0))
        CALL addissue(idx,build2("Value_num for facility field cannot be less than zero"))
       ENDIF
       IF (size(reply->solcap[idx].facility[idx2].value_str,3) > 1024)
        CALL addissue(idx,build2("Facility value_str cannot be more than 1024 characters. ","Size: ",
          trim(cnvtstring(size(reply->solcap[idx].facility[idx2].value_str,3)))))
       ENDIF
     ENDWHILE
     SET idx2 = 0
     WHILE (idx2 < size(reply->solcap[idx].other,5))
       SET idx2 = (idx2+ 1)
       SET idx3 = 0
       IF (size(reply->solcap[idx].other[idx2].category_name,3) > 255)
        CALL addissue(idx,build2("Category Name cannot be more than 255 characters. ","Size: ",trim(
           cnvtstring(size(reply->solcap[idx].other[idx2].category_name,3)))))
       ENDIF
       IF (size(reply->solcap[idx].other[idx2].category_name,3)=0)
        CALL addissue(idx,build2("Category Name cannot be empty. "))
       ENDIF
       WHILE (idx3 < size(reply->solcap[idx].other[idx2].value,5))
         SET idx3 = (idx3+ 1)
         IF (size(reply->solcap[idx].other[idx2].value[idx3].display,3) > 128)
          CALL addissue(idx,build2("Value display cannot be more than 128 characters. ","Size: ",trim
            (cnvtstring(size(reply->solcap[idx].other[idx2].value[idx3].display,3)))))
         ENDIF
         IF (size(reply->solcap[idx].other[idx2].value[idx3].value_str,3) > 1024)
          CALL addissue(idx,build2("Value value_str cannot be more than 1024 characters. ","Size: ",
            trim(cnvtstring(size(reply->solcap[idx].other[idx2].value[idx3].value_str,3)))))
         ENDIF
         IF ((reply->solcap[idx].other[idx2].value[idx3].value_num < 0))
          CALL addissue(idx,build2("Value_num for Value field cannot be less than zero"))
         ENDIF
       ENDWHILE
       SET idx3 = 0
     ENDWHILE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE addissue(index,text)
   IF ((issues->issue[index].passfail=""))
    SET issues->issue[index].issuetext = text
    SET issues->issue[index].passfail = "FAIL"
   ENDIF
 END ;Subroutine
#exit_program
 EXECUTE dm_stat_snaps_load
 EXECUTE dm_stat_export_solcap mss_subtimer, mss_index
 CALL log_msg("EndSession",logfile)
END GO
