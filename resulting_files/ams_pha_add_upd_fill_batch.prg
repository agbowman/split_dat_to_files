CREATE PROGRAM ams_pha_add_upd_fill_batch
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "File Name" = "",
  "Select the task you would like to perform" = 0
  WITH outdev, pdirectory, pfilename,
  poption
 EXECUTE ams_define_toolkit_common
 IF (isamsuser(reqinfo->updt_id)=false)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "ERROR: You are not recognized as an AMS Associate. Operation Denied."
   WITH nocounter
  ;end select
 ENDIF
 IF (size(trim(curdomain,3))=0)
  EXECUTE cclseclogin
 ENDIF
 DECLARE filepath = vc WITH protect
 DECLARE inputfile = vc WITH protect
 DECLARE path = vc WITH protect
 DECLARE script_name = vc WITH protect, constant("ams_pha_add_fill_batch")
 DECLARE addcount = i4 WITH protect, noconstant(0)
 DECLARE updcount = i4 WITH protect, noconstant(0)
 SET path = value(logical( $PDIRECTORY))
 SET inputfile =  $PFILENAME
 SET file_path = build(path,":",inputfile)
 IF (findfile(trim(file_path,3)))
  DECLARE location = vc WITH protect, noconstant("")
  DECLARE notfound = vc WITH constant("<not_found>")
  DECLARE num = i4 WITH noconstant(1)
  DECLARE dispcat = vc WITH protect, noconstant("")
  DECLARE num2 = i4 WITH noconstant(1)
  FREE RECORD filecontent
  RECORD filecontent(
    1 rowcount = i4
    1 rowqual[*]
      2 fillbatchcd = f8
      2 batchupdtcnt = i4
      2 codevalueupdtcnt = i4
      2 description = vc
      2 locationstr = vc
      2 locationcount = i4
      2 locations[*]
        3 locationdisp = vc
        3 locationcd = f8
      2 dispensecatstr = vc
      2 dispensecatcount = i4
      2 dispensecats[*]
        3 dispensecatdisp = vc
        3 dispcatcd = f8
      2 defaultopdef = vc
      2 defaultopflag = i2
      2 ordertypedef = vc
      2 ordertypeflag = i2
      2 locfacility = vc
      2 locfaccd = f8
      2 disploc = vc
      2 disploccd = f8
      2 cycletime = i4
      2 maxcycletime = i4
      2 minelapsedtime = i4
      2 outputformatdisp = vc
      2 outputformatcd = f8
      2 defaultprintername = vc
      2 defaultprintercd = f8
      2 prnfilltime = i4
      2 discontinuetime = i4
      2 suspendtime = i4
      2 filltime = i4
      2 maxfilltime = i4
  )
  FREE DEFINE rtl3
  DEFINE rtl3 file_path
  SELECT
   FROM rtl3t r
   WHERE r.line > " "
   HEAD REPORT
    rowcount = 0
   DETAIL
    curline = r.line
    IF (size(trim(curline),3) > 0)
     rowcount = (rowcount+ 1)
     IF (mod(rowcount,10)=1)
      stat = alterlist(filecontent->rowqual,(rowcount+ 9))
     ENDIF
     filecontent->rowqual[rowcount].description = piece(curline,",",1,"",3), filecontent->rowqual[
     rowcount].locfacility = piece(curline,",",2,"",3), filecontent->rowqual[rowcount].locationstr =
     piece(curline,",",3,"",3),
     filecontent->rowqual[rowcount].ordertypedef = piece(curline,",",4,"",3), filecontent->rowqual[
     rowcount].dispensecatstr = piece(curline,",",5,"",3), filecontent->rowqual[rowcount].
     defaultopdef = piece(curline,",",6,"",3),
     filecontent->rowqual[rowcount].disploc = piece(curline,",",7,"",3), filecontent->rowqual[
     rowcount].cycletime = cnvtint(piece(curline,",",8,"",3)), filecontent->rowqual[rowcount].
     maxcycletime = cnvtint(piece(curline,",",9,"",3)),
     filecontent->rowqual[rowcount].minelapsedtime = cnvtint(piece(curline,",",10,"",3)), filecontent
     ->rowqual[rowcount].outputformatdisp = piece(curline,",",11,"",3), filecontent->rowqual[rowcount
     ].defaultprintername = piece(curline,",",12,"",3),
     filecontent->rowqual[rowcount].prnfilltime = cnvtint(piece(curline,",",13,"",3)), filecontent->
     rowqual[rowcount].discontinuetime = cnvtint(piece(curline,",",14,"",3)), filecontent->rowqual[
     rowcount].suspendtime = cnvtint(piece(curline,",",15,"",3)),
     filecontent->rowqual[rowcount].filltime = cnvtint(piece(curline,",",16,"",3)), filecontent->
     rowqual[rowcount].maxfilltime = cnvtint(piece(curline,",",17,"",3))
    ENDIF
   FOOT REPORT
    filecontent->rowcount = rowcount, stat = alterlist(filecontent->rowqual,rowcount)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(filecontent->rowqual,5))),
    dm_flags df,
    device d,
    code_value cv
   PLAN (d1)
    JOIN (df
    WHERE df.table_name="FILL_BATCH"
     AND df.column_name IN ("DEF_OPERATION_FLAG", "ORDER_TYPE_FLAG"))
    JOIN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning IN ("FACILITY", "PHARM"))
    JOIN (d
    WHERE cnvtupper(d.name)=cnvtupper(filecontent->rowqual[d1.seq].defaultprintername))
   HEAD d1.seq
    filecontent->rowqual[d1.seq].defaultprintercd = d.device_cd, filecontent->rowqual[d1.seq].
    outputformatcd = uar_get_code_by("DISPLAY",4039,filecontent->rowqual[d1.seq].outputformatdisp),
    dispcatcount = 0,
    loccount = 0, location = "", dispcat = "",
    num = 1, num2 = 1
    IF ((filecontent->rowqual[d1.seq].locationstr > " "))
     locstr = filecontent->rowqual[d1.seq].locationstr
     WHILE (location != notfound)
       location = piece(locstr,",",num,notfound,3), num = (num+ 1)
       IF (location > " "
        AND location != notfound)
        loccount = (loccount+ 1)
        IF (mod(loccount,10)=1)
         stat = alterlist(filecontent->rowqual[d1.seq].locations,(loccount+ 9))
        ENDIF
        filecontent->rowqual[d1.seq].locations[loccount].locationdisp = location, filecontent->
        rowqual[d1.seq].locations[loccount].locationcd = uar_get_code_by("DISPLAY",220,location)
       ENDIF
     ENDWHILE
    ENDIF
    IF ((filecontent->rowqual[d1.seq].dispensecatstr > " "))
     dispcatstr = filecontent->rowqual[d1.seq].dispensecatstr
     WHILE (dispcat != notfound)
       dispcat = piece(dispcatstr,",",num2,notfound,3), num2 = (num2+ 1)
       IF (dispcat > " "
        AND dispcat != notfound)
        dispcatcount = (dispcatcount+ 1)
        IF (mod(dispcatcount,10)=1)
         stat = alterlist(filecontent->rowqual[d1.seq].dispensecats,(dispcatcount+ 9))
        ENDIF
        filecontent->rowqual[d1.seq].dispensecats[dispcatcount].dispensecatdisp = dispcat,
        filecontent->rowqual[d1.seq].dispensecats[dispcatcount].dispcatcd = uar_get_code_by("DISPLAY",
         4008,dispcat)
       ENDIF
     ENDWHILE
    ENDIF
   DETAIL
    IF (cnvtupper(df.definition)=cnvtupper(filecontent->rowqual[d1.seq].defaultopdef)
     AND df.column_name="DEF_OPERATION_FLAG")
     filecontent->rowqual[d1.seq].defaultopflag = cnvtint(df.flag_value)
    ELSEIF (cnvtupper(df.definition)=cnvtupper(filecontent->rowqual[d1.seq].ordertypedef)
     AND df.column_name="ORDER_TYPE_FLAG")
     filecontent->rowqual[d1.seq].ordertypeflag = cnvtint(df.flag_value)
    ENDIF
    IF ((cv.display=filecontent->rowqual[d1.seq].locfacility)
     AND cv.cdf_meaning="FACILITY")
     filecontent->rowqual[d1.seq].locfaccd = cv.code_value
    ELSEIF ((cv.display=filecontent->rowqual[d1.seq].disploc)
     AND cv.cdf_meaning="PHARM")
     filecontent->rowqual[d1.seq].disploccd = cv.code_value
    ENDIF
   FOOT  d1.seq
    filecontent->rowqual[d1.seq].locationcount = loccount, filecontent->rowqual[d1.seq].
    dispensecatcount = dispcatcount, stat = alterlist(filecontent->rowqual[d1.seq].locations,loccount
     ),
    stat = alterlist(filecontent->rowqual[d1.seq].dispensecats,dispcatcount)
   WITH nocounter
  ;end select
  IF (( $POPTION=1))
   SELECT INTO "nl:"
    FROM fill_batch f,
     code_value cv,
     (dummyt d1  WITH seq = value(size(filecontent->rowqual,5)))
    PLAN (d1)
     JOIN (cv
     WHERE (cv.display=filecontent->rowqual[d1.seq].description)
      AND cv.code_set=4035
      AND cv.active_ind=1)
     JOIN (f
     WHERE f.fill_batch_cd=cv.code_value)
    HEAD d1.seq
     filecontent->rowqual[d1.seq].fillbatchcd = f.fill_batch_cd, filecontent->rowqual[d1.seq].
     batchupdtcnt = f.updt_cnt, filecontent->rowqual[d1.seq].codevalueupdtcnt = cv.updt_cnt
   ;end select
  ENDIF
 ELSE
  SET error_status = "FILE_NOT_FOUND"
  GO TO exit_script
 ENDIF
 IF (( $POPTION=0))
  FREE RECORD addrequest
  RECORD addrequest(
    1 fill_time = i4
    1 fill_unit_flag = i2
    1 cycle_time = i4
    1 cycle_unit_flag = i2
    1 discontinue_time = i4
    1 discontinue_unit_flag = i2
    1 suspend_time = i4
    1 suspend_unit_flag = i2
    1 unverified_order_ind = i2
    1 incomplete_order_ind = i2
    1 prn_fill_time = i4
    1 prn_fill_unit_flag = i2
    1 def_operation_flag = i2
    1 max_fill_time = i4
    1 max_fill_unit_flag = i2
    1 max_cycle_time = i4
    1 max_cycle_unit_flag = i2
    1 min_elapsed_time = i4
    1 min_elapsed_unit_flag = i2
    1 order_type_flag = i2
    1 output_format_cd = f8
    1 default_printer_cd = f8
    1 display = c40
    1 description = c60
    1 active_ind = i2
    1 cycle_cnt = i4
    1 cycle[*]
      2 fill_batch_cd = f8
      2 location_cd = f8
      2 dispense_category_cd = f8
      2 from_dt_tm = dq8
      2 to_dt_tm = dq8
      2 last_operation_flag = i2
      2 audit_flag = i2
    1 cyclebatchr_cnt = i4
    1 cyclebatchr[*]
      2 fill_batch_cd = f8
      2 location_cd = f8
      2 dispense_category_cd = f8
    1 location_cd = f8
    1 loc_facility_cd = f8
    1 calendar_day_nbr = i4
    1 monthly_week_flag = i2
    1 monthly_dow_flag = i2
  )
  FREE RECORD addoutput
  RECORD addoutput(
    1 fillbatchqual[*]
      2 fill_batch_cd = f8
      2 fill_batch_disp = vc
  )
  FOR (i = 2 TO size(filecontent->rowqual,5))
    SET addrequest->fill_time = filecontent->rowqual[i].filltime
    SET addrequest->fill_unit_flag = 2
    SET addrequest->cycle_time = filecontent->rowqual[i].cycletime
    SET addrequest->cycle_unit_flag = 2
    SET addrequest->discontinue_time = filecontent->rowqual[i].discontinuetime
    SET addrequest->discontinue_unit_flag = 2
    SET addrequest->suspend_time = filecontent->rowqual[i].suspendtime
    SET addrequest->suspend_unit_flag = 2
    SET addrequest->prn_fill_time = filecontent->rowqual[i].prnfilltime
    SET addrequest->prn_fill_unit_flag = 2
    SET addrequest->max_fill_time = filecontent->rowqual[i].maxfilltime
    SET addrequest->max_fill_unit_flag = 2
    SET addrequest->max_cycle_time = filecontent->rowqual[i].maxcycletime
    SET addrequest->max_cycle_unit_flag = 2
    SET addrequest->min_elapsed_time = filecontent->rowqual[i].minelapsedtime
    SET addrequest->min_elapsed_unit_flag = 2
    SET addrequest->display = filecontent->rowqual[i].description
    SET addrequest->description = filecontent->rowqual[i].description
    SET addrequest->active_ind = 1
    SET addrequest->def_operation_flag = filecontent->rowqual[i].defaultopflag
    SET addrequest->order_type_flag = filecontent->rowqual[i].ordertypeflag
    SET addrequest->output_format_cd = filecontent->rowqual[i].outputformatcd
    SET addrequest->default_printer_cd = filecontent->rowqual[i].defaultprintercd
    SET addrequest->loc_facility_cd = filecontent->rowqual[i].locfaccd
    SET addrequest->location_cd = filecontent->rowqual[i].disploccd
    SET cyclecount = 0
    SET cyclebatchrcount = 0
    FOR (j = 1 TO filecontent->rowqual[i].locationcount)
      FOR (k = 1 TO filecontent->rowqual[i].dispensecatcount)
        SELECT INTO "nl:"
         FROM fill_cycle f
         WHERE (f.location_cd=filecontent->rowqual[i].locations[j].locationcd)
          AND (f.dispense_category_cd=filecontent->rowqual[i].dispensecats[k].dispcatcd)
         WITH nocounter
        ;end select
        IF (curqual=0)
         SET cyclecount = (cyclecount+ 1)
         IF (mod(cyclecount,10)=1)
          SET stat = alterlist(addrequest->cycle,(cyclecount+ 9))
         ENDIF
         SET addrequest->cycle[cyclecount].location_cd = filecontent->rowqual[i].locations[j].
         locationcd
         SET addrequest->cycle[cyclecount].dispense_category_cd = filecontent->rowqual[i].
         dispensecats[k].dispcatcd
        ENDIF
        SET cyclebatchrcount = (cyclebatchrcount+ 1)
        IF (mod(cyclebatchrcount,10)=1)
         SET stat = alterlist(addrequest->cyclebatchr,(cyclebatchrcount+ 9))
        ENDIF
        SET addrequest->cyclebatchr[cyclebatchrcount].location_cd = filecontent->rowqual[i].
        locations[j].locationcd
        SET addrequest->cyclebatchr[cyclebatchrcount].dispense_category_cd = filecontent->rowqual[i].
        dispensecats[k].dispcatcd
      ENDFOR
    ENDFOR
    SET stat = alterlist(addrequest->cycle,cyclecount)
    SET stat = alterlist(addrequest->cyclebatchr,cyclebatchrcount)
    SET addrequest->cycle_cnt = cyclecount
    SET addrequest->cyclebatchr_cnt = cyclebatchrcount
    SET stat = tdbexecute(301300,305062,305062,"REC",addrequest,
     "REC",addreply)
    IF ((addreply->status_data.status="S"))
     SET addcount = (addcount+ 1)
     IF (mod(addcount,10)=1)
      SET stat = alterlist(addoutput->fillbatchqual,(addcount+ 9))
     ENDIF
     SET addoutput->fillbatchqual[addcount].fill_batch_cd = addreply->fill_batch_cd
     SET addoutput->fillbatchqual[addcount].fill_batch_disp = uar_get_code_display(addreply->
      fill_batch_cd)
    ENDIF
  ENDFOR
  SET stat = alterlist(addoutput->fillbatchqual,addcount)
  IF (addcount > 0)
   CALL updtdminfo(script_name,cnvtreal(addcount))
   SELECT INTO  $OUTDEV
    action = "Add", fill_batch_cd = addoutput->fillbatchqual[d1.seq].fill_batch_cd, fill_batch_disp
     = substring(1,30,addoutput->fillbatchqual[d1.seq].fill_batch_disp)
    FROM (dummyt d1  WITH seq = value(size(addoutput->fillbatchqual,5)))
    PLAN (d1)
    WITH nocounter, separator = " ", format
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 20, "Fill_Batch not created. Please check the path of csv file and its contents."
    WITH nocounter, separator = " ", format
   ;end select
  ENDIF
 ELSEIF (( $POPTION=1))
  CALL echo("Modify")
  FREE RECORD updrequest
  RECORD updrequest(
    1 fill_batch_cd = f8
    1 fill_time = i4
    1 fill_unit_flag = i2
    1 cycle_time = i4
    1 cycle_unit_flag = i2
    1 discontinue_time = i4
    1 discontinue_unit_flag = i2
    1 suspend_time = i4
    1 suspend_unit_flag = i2
    1 unverified_order_ind = i2
    1 incomplete_order_ind = i2
    1 prn_fill_time = i4
    1 prn_fill_unit_flag = i2
    1 def_operation_flag = i2
    1 max_fill_time = i4
    1 max_fill_unit_flag = i2
    1 max_cycle_time = i4
    1 max_cycle_unit_flag = i2
    1 min_elapsed_time = i4
    1 min_elapsed_unit_flag = i2
    1 order_type_flag = i2
    1 output_format_cd = f8
    1 default_printer_cd = f8
    1 batch_updt_cnt = i4
    1 display = c40
    1 description = c60
    1 active_ind = i2
    1 codeval_updt_cnt = i4
    1 location_cd = f8
    1 loc_facility_cd = f8
    1 calendar_day_nbr = i4
    1 monthly_week_flag = i2
    1 monthly_dow_flag = i2
  )
  FREE RECORD addfillcycle
  RECORD addfillcycle(
    1 cycle[*]
      2 location_cd = f8
      2 dispense_category_cd = f8
      2 from_dt_tm = dq8
      2 to_dt_tm = dq8
      2 last_operation_flag = i2
      2 audit_flag = i2
  )
  FREE RECORD addfillcyclebatch
  RECORD addfillcyclebatch(
    1 cyclebatchr[*]
      2 fill_batch_cd = f8
      2 location_cd = f8
      2 dispense_category_cd = f8
  )
  FREE RECORD updoutput
  RECORD updoutput(
    1 fillbatchqual[*]
      2 fill_batch_cd = f8
      2 fill_batch_disp = vc
  )
  FOR (i = 2 TO size(filecontent->rowqual,5))
    SET updrequest->fill_batch_cd = filecontent->rowqual[i].fillbatchcd
    SET updrequest->fill_time = filecontent->rowqual[i].filltime
    SET updrequest->fill_unit_flag = 2
    SET updrequest->cycle_time = filecontent->rowqual[i].cycletime
    SET updrequest->cycle_unit_flag = 2
    SET updrequest->discontinue_time = filecontent->rowqual[i].discontinuetime
    SET updrequest->discontinue_unit_flag = 2
    SET updrequest->suspend_time = filecontent->rowqual[i].suspendtime
    SET updrequest->suspend_unit_flag = 2
    SET updrequest->prn_fill_time = filecontent->rowqual[i].prnfilltime
    SET updrequest->prn_fill_unit_flag = 2
    SET updrequest->def_operation_flag = filecontent->rowqual[i].defaultopflag
    SET updrequest->max_fill_time = filecontent->rowqual[i].maxfilltime
    SET updrequest->max_fill_unit_flag = 2
    SET updrequest->max_cycle_time = filecontent->rowqual[i].maxcycletime
    SET updrequest->max_cycle_unit_flag = 2
    SET updrequest->min_elapsed_time = filecontent->rowqual[i].minelapsedtime
    SET updrequest->min_elapsed_unit_flag = 2
    SET updrequest->order_type_flag = filecontent->rowqual[i].ordertypeflag
    SET updrequest->output_format_cd = filecontent->rowqual[i].outputformatcd
    SET updrequest->default_printer_cd = filecontent->rowqual[i].defaultprintercd
    SET updrequest->batch_updt_cnt = filecontent->rowqual[i].batchupdtcnt
    SET updrequest->display = filecontent->rowqual[i].description
    SET updrequest->description = filecontent->rowqual[i].description
    SET updrequest->active_ind = 1
    SET updrequest->codeval_updt_cnt = filecontent->rowqual[i].codevalueupdtcnt
    SET updrequest->loc_facility_cd = filecontent->rowqual[i].locfaccd
    SET updrequest->location_cd = filecontent->rowqual[i].disploccd
    CALL echorecord(updrequest)
    SET stat = tdbexecute(301300,305002,305002,"REC",updrequest,
     "REC",updreply)
    CALL echorecord(updreply)
    IF ((updreply->status_data.status="S"))
     SET updcount = (updcount+ 1)
     IF (mod(updcount,10)=1)
      SET stat = alterlist(updoutput->fillbatchqual,(updcount+ 9))
     ENDIF
     SET updoutput->fillbatchqual[updcount].fill_batch_cd = updreply->fill_batch_cd
     SET updoutput->fillbatchqual[updcount].fill_batch_disp = uar_get_code_display(updreply->
      fill_batch_cd)
    ENDIF
    SET cyclecount = 0
    FOR (j = 1 TO filecontent->rowqual[i].locationcount)
      FOR (k = 1 TO filecontent->rowqual[i].dispensecatcount)
       SELECT INTO "nl:"
        FROM fill_cycle f
        WHERE (f.location_cd=filecontent->rowqual[i].locations[j].locationcd)
         AND (f.dispense_category_cd=filecontent->rowqual[i].dispensecats[k].dispcatcd)
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET cyclecount = (cyclecount+ 1)
        IF (mod(cyclecount,10)=1)
         SET stat = alterlist(addfillcycle->cycle,(cyclecount+ 9))
        ENDIF
        SET addfillcycle->cycle[cyclecount].location_cd = filecontent->rowqual[i].locations[j].
        locationcd
        SET addfillcycle->cycle[cyclecount].dispense_category_cd = filecontent->rowqual[i].
        dispensecats[k].dispcatcd
       ENDIF
      ENDFOR
    ENDFOR
    SET stat = alterlist(addfillcycle->cycle,cyclecount)
    IF (cyclecount > 0)
     SET stat = tdbexecute(301300,305061,305061,"REC",addfillcycle,
      "REC",addfillrep)
    ENDIF
    SET cyclebatchcount = 0
    FOR (j = 1 TO filecontent->rowqual[i].locationcount)
      FOR (k = 1 TO filecontent->rowqual[i].dispensecatcount)
       SELECT INTO "nl:"
        FROM fill_cycle_batch f
        WHERE (f.fill_batch_cd=filecontent->rowqual[i].fillbatchcd)
         AND (f.location_cd=filecontent->rowqual[i].locations[j].locationcd)
         AND (f.dispense_category_cd=filecontent->rowqual[i].dispensecats[k].dispcatcd)
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET cyclebatchcount = (cyclebatchcount+ 1)
        IF (mod(cyclebatchcount,10)=1)
         SET stat = alterlist(addfillcyclebatch->cyclebatchr,(cyclebatchcount+ 9))
        ENDIF
        SET addfillcyclebatch->cyclebatchr[cyclebatchcount].fill_batch_cd = filecontent->rowqual[i].
        fillbatchcd
        SET addfillcyclebatch->cyclebatchr[cyclebatchcount].location_cd = filecontent->rowqual[i].
        locations[j].locationcd
        SET addfillcyclebatch->cyclebatchr[cyclebatchcount].dispense_category_cd = filecontent->
        rowqual[i].dispensecats[k].dispcatc
       ENDIF
      ENDFOR
    ENDFOR
    SET stat = alterlist(addfillcyclebatch->cyclebatchr,cyclebatchcount)
    IF (cyclebatchcount > 0)
     SET stat = tdbexecute(301300,305064,305064,"REC",addfillcyclebatch,
      "REC",addfillcyclebatrep)
    ENDIF
  ENDFOR
  SET stat = alterlist(updoutput->fillbatchqual,updcount)
  IF (updcount > 0)
   CALL updtdminfo(script_name,cnvtreal(updcount))
   SELECT INTO  $OUTDEV
    action = "Update", fill_batch_cd = updoutput->fillbatchqual[d1.seq].fill_batch_cd,
    fill_batch_disp = substring(1,30,updoutput->fillbatchqual[d1.seq].fill_batch_disp)
    FROM (dummyt d1  WITH seq = value(size(updoutput->fillbatchqual,5)))
    PLAN (d1)
    WITH nocounter, separator = " ", format
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 20, "Fill_Batch not updated. Please check the path of csv file and its contents."
    WITH nocounter, separator = " ", format
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET last_mod = "000 04/04/16 ZA030646 Initial Release"
END GO
