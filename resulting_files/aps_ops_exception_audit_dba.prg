CREATE PROGRAM aps_ops_exception_audit:dba
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
 )
 RECORD temp(
   1 qual[*]
     2 accession_number = c21
     2 parent_id = f8
     2 order_type = c15
     2 description_cd = f8
     2 description = c40
     2 status = c15
     2 action = c15
     2 attempts = i4
     2 last_attempt = dq8
     2 order_id = f8
 )
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 apsrpt = vc
   1 ddate = vc
   1 directory = vc
   1 ttime = vc
   1 reopsexceptionaudit = vc
   1 bby = vc
   1 ppage = vc
   1 accn = vc
   1 ordertype = vc
   1 description = vc
   1 action = vc
   1 parent = vc
   1 orderid = vc
   1 status = vc
   1 attempts = vc
   1 last = vc
   1 continued = vc
   1 endofreport = vc
   1 emailfrom = vc
   1 active = vc
   1 inactive = vc
   1 _report = vc
   1 qverify = vc
   1 _order = vc
   1 complete = vc
   1 cancel = vc
   1 hverify = vc
   1 specimen = vc
   1 proc_task = vc
 )
#script
 SET captions->apsrpt = uar_i18ngetmessage(i18nhandle,"h1","REPORT: APS_OPS_EXCEPTION_AUDIT.PRG")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"h2","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h3","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h4","TIME:")
 SET captions->reopsexceptionaudit = uar_i18ngetmessage(i18nhandle,"h5","OPS EXCEPTION AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h6","BY:")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h8","PAGE:")
 SET captions->accn = uar_i18ngetmessage(i18nhandle,"h13","ACCESSION")
 SET captions->ordertype = uar_i18ngetmessage(i18nhandle,"h14","ORDER TYPE")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"h15","DESCRIPTION")
 SET captions->action = uar_i18ngetmessage(i18nhandle,"h16","ACTION TYPE")
 SET captions->parent = uar_i18ngetmessage(i18nhandle,"h17","PARENT ID")
 SET captions->orderid = uar_i18ngetmessage(i18nhandle,"h18","ORDER ID")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"h19","STATUS")
 SET captions->attempts = uar_i18ngetmessage(i18nhandle,"h20","ATTEMPTS")
 SET captions->last = uar_i18ngetmessage(i18nhandle,"h21","LAST ATTEMPT")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET captions->endofreport = uar_i18ngetmessage(i18nhandle,"f2","*** END OF ERPORT ***")
 SET captions->emailfrom = uar_i18ngetmessage(i18nhandle,"f3","Ops_Job_AP_Recovery_Report")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"t1","ACTIVE")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"t2","INACTIVE")
 SET captions->_report = uar_i18ngetmessage(i18nhandle,"t3","REPORT")
 SET captions->qverify = uar_i18ngetmessage(i18nhandle,"t4","QVERIFY")
 SET captions->_order = uar_i18ngetmessage(i18nhandle,"t5","ORDER")
 SET captions->complete = uar_i18ngetmessage(i18nhandle,"t6","COMPLETE")
 SET captions->cancel = uar_i18ngetmessage(i18nhandle,"t7","CANCEL")
 SET captions->hverify = uar_i18ngetmessage(i18nhandle,"t8","HVERIFY")
 SET captions->specimen = uar_i18ngetmessage(i18nhandle,"t9","SPECIMEN")
 SET captions->proc_task = uar_i18ngetmessage(i18nhandle,"t10","PROC TASK")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET raw_output_dest = fillstring(100," ")
 SET raw_printer_name = fillstring(100," ")
 SET raw_nbr_copies = 0
 SET output_dest_id = 0.0
 SET error_number = 0
 SET index = 0
 SET ops_exception_cnt = 0
 SET accession_display = fillstring(21," ")
 SET output_dest = fillstring(100," ")
 DECLARE nemailind = i2 WITH protect, noconstant(false)
 DECLARE text = c100
 DECLARE real = f8
 DECLARE six = i2
 DECLARE pos = i2
 DECLARE startpos2 = i2
 DECLARE len = i4
 DECLARE endstring = c2
 SUBROUTINE get_text(startpos,textstring,delimit)
   SET siz = size(trim(textstring),1)
   SET pos = startpos
   SET endstring = "F"
   WHILE (pos <= siz)
    IF (substring(pos,1,trim(textstring))=delimit)
     IF (pos=siz)
      SET endstring = "T"
     ENDIF
     SET len = (pos - startpos)
     SET text = substring(startpos,len,trim(textstring))
     SET real = cnvtreal(trim(text))
     SET startpos = (pos+ 1)
     SET startpos2 = (pos+ 1)
     SET pos = siz
    ENDIF
    SET pos = (pos+ 1)
   ENDWHILE
 END ;Subroutine
 EXECUTE pcs_email_subs
 IF (validate(request->output_dist,null) != null)
  IF (findstring("email:",cnvtlower(request->output_dist)) != 1)
   SELECT INTO "nl:"
    x = 1
    DETAIL
     IF (textlen(trim(request->output_dist)) > 0)
      CALL get_text(1,trim(request->output_dist),"|"), raw_output_dest = trim(text), raw_printer_name
       = substring(1,4,trim(raw_output_dest))
     ENDIF
     CALL get_text(startpos2,trim(request->output_dist),"|"), raw_nbr_copies = cnvtint(trim(text))
    WITH nocounter
   ;end select
   IF (textlen(trim(request->output_dist))=0)
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with output_dist!"
    SET error_number = 1
    GO TO end_script
   ENDIF
   IF (trim(raw_output_dest) != "")
    SELECT INTO "nl:"
     o.output_dest_cd
     FROM output_dest o
     WHERE raw_output_dest=o.name
     DETAIL
      output_dest_id = o.output_dest_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->ops_event = "Failure - Error with output_dest_id!"
     SET error_number = 4
     GO TO end_script
    ENDIF
    IF (raw_nbr_copies < 1)
     SET raw_nbr_copies = 1
    ENDIF
   ENDIF
  ELSE
   IF (textlen(trim(request->output_dist)) > 6)
    SET nemailind = true
    SET request->output_dist = trim(substring(7,(textlen(request->output_dist) - 6),request->
      output_dist))
   ELSE
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Invalid Email Address Entry"
    SET error_number = 1
   ENDIF
  ENDIF
 ENDIF
 SET stat = alterlist(temp->qual,1)
 SELECT INTO "nl:"
  aoe.parent_id, join_path = decode(cr.seq,"R",cs.seq,"S",pt2.seq,
   "T"," "), rt_exists = decode(rt.seq,"Y","N"),
  pt_exists = decode(pt.seq,"Y","N")
  FROM ap_ops_exception aoe,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   (dummyt d5  WITH seq = 1),
   case_report cr,
   report_task rt,
   case_specimen cs,
   processing_task pt,
   processing_task pt2,
   pathology_case pc,
   pathology_case pc2,
   pathology_case pc3
  PLAN (aoe)
   JOIN (((d1
   WHERE aoe.action_flag IN (1, 3, 6, - (1)))
   JOIN (cr
   WHERE cr.report_id=aoe.parent_id)
   JOIN (pc
   WHERE pc.case_id=cr.case_id)
   JOIN (d4
   WHERE 1=d4.seq)
   JOIN (rt
   WHERE cr.report_id=rt.report_id)
   ) ORJOIN ((((d2
   WHERE aoe.action_flag IN (2, 5))
   JOIN (cs
   WHERE cs.case_specimen_id=aoe.parent_id)
   JOIN (pc2
   WHERE pc2.case_id=cs.case_id)
   JOIN (d5
   WHERE 1=d5.seq)
   JOIN (pt
   WHERE cs.case_specimen_id=pt.case_specimen_id
    AND 4=pt.create_inventory_flag)
   ) ORJOIN ((d3
   WHERE aoe.action_flag IN (4, 7))
   JOIN (pt2
   WHERE pt2.processing_task_id=aoe.parent_id)
   JOIN (pc3
   WHERE pc3.case_id=pt2.case_id)
   )) ))
  ORDER BY pc.accession_nbr
  HEAD REPORT
   ops_exception_cnt = 0
  DETAIL
   ops_exception_cnt = (ops_exception_cnt+ 1), stat = alterlist(temp->qual,ops_exception_cnt), temp->
   qual[ops_exception_cnt].parent_id = aoe.parent_id,
   temp->qual[ops_exception_cnt].attempts = aoe.updt_cnt, temp->qual[ops_exception_cnt].last_attempt
    = cnvtdatetime(aoe.updt_dt_tm)
   IF (aoe.active_ind=1)
    temp->qual[ops_exception_cnt].status = captions->active
   ELSE
    temp->qual[ops_exception_cnt].status = captions->inactive
   ENDIF
   CASE (join_path)
    OF "R":
     temp->qual[ops_exception_cnt].description_cd = cr.catalog_cd,accession_display =
     uar_fmt_accession(pc.accession_nbr,size(pc.accession_nbr)),temp->qual[ops_exception_cnt].
     accession_number = accession_display,
     temp->qual[ops_exception_cnt].order_type = captions->_report,
     IF (aoe.action_flag=1)
      temp->qual[ops_exception_cnt].action = captions->qverify
     ELSEIF (aoe.action_flag=3)
      temp->qual[ops_exception_cnt].action = captions->_order
     ELSEIF (aoe.action_flag=6
      AND cr.cancel_cd IN (0.0, null))
      temp->qual[ops_exception_cnt].action = captions->complete
     ELSEIF (aoe.action_flag=6)
      temp->qual[ops_exception_cnt].action = captions->cancel
     ELSEIF ((aoe.action_flag=- (1)))
      temp->qual[ops_exception_cnt].action = captions->hverify
     ENDIF
     ,
     IF (rt_exists="Y")
      temp->qual[ops_exception_cnt].order_id = rt.order_id
     ENDIF
    OF "S":
     temp->qual[ops_exception_cnt].description_cd = cs.specimen_cd,accession_display =
     uar_fmt_accession(pc2.accession_nbr,size(pc2.accession_nbr)),temp->qual[ops_exception_cnt].
     accession_number = accession_display,
     temp->qual[ops_exception_cnt].order_type = captions->specimen,
     IF (aoe.action_flag=2)
      temp->qual[ops_exception_cnt].action = captions->_order
     ELSEIF (aoe.action_flag=5
      AND cs.cancel_cd IN (0.0, null))
      temp->qual[ops_exception_cnt].action = captions->complete
     ELSEIF (aoe.action_flag=5)
      temp->qual[ops_exception_cnt].action = captions->cancel
     ENDIF
     ,
     IF (pt_exists="Y")
      temp->qual[ops_exception_cnt].order_id = pt.order_id
     ENDIF
    OF "T":
     temp->qual[ops_exception_cnt].description_cd = pt2.task_assay_cd,accession_display =
     uar_fmt_accession(pc3.accession_nbr,size(pc3.accession_nbr)),temp->qual[ops_exception_cnt].
     accession_number = accession_display,
     temp->qual[ops_exception_cnt].order_type = captions->proc_task,
     IF (aoe.action_flag=4)
      temp->qual[ops_exception_cnt].action = captions->_order
     ELSEIF (aoe.action_flag=7
      AND pt2.cancel_cd IN (0.0, null))
      temp->qual[ops_exception_cnt].action = captions->complete
     ELSEIF (aoe.action_flag=7)
      temp->qual[ops_exception_cnt].action = captions->cancel
     ENDIF
     ,temp->qual[ops_exception_cnt].order_id = pt2.order_id
   ENDCASE
  FOOT REPORT
   stat = alterlist(temp->qual,ops_exception_cnt)
  WITH nocounter, outerjoin = d4, outerjoin = d5
 ;end select
 IF (ops_exception_cnt > 0)
  SELECT INTO "nl:"
   d.seq, cv.display
   FROM code_value cv,
    (dummyt d  WITH seq = value(ops_exception_cnt))
   PLAN (d
    WHERE (temp->qual[d.seq].description_cd != 0.0))
    JOIN (cv
    WHERE (cv.code_value=temp->qual[d.seq].description_cd))
   DETAIL
    temp->qual[d.seq].description = cv.display
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->ops_event = "No rows to process."
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#report_maker
 EXECUTE cpm_create_file_name_logical "apsrecovery", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 IF (output_dest_id=0.0
  AND nemailind=false)
  SET output_dest = "Mine"
 ELSE
  SET output_dest = reply->print_status_data.print_filename
  IF ((reply->status_data.status="Z"))
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO value(output_dest)
  accession_number = trim(temp->qual[d1.seq].accession_number), parent_id = trim(cnvtstring(temp->
    qual[d1.seq].parent_id,14,0)), order_type = trim(temp->qual[d1.seq].order_type),
  description = substring(1,20,trim(temp->qual[d1.seq].description)), action = trim(temp->qual[d1.seq
   ].action), attempts = trim(cnvtstring(temp->qual[d1.seq].attempts)),
  last_attempt = temp->qual[d1.seq].last_attempt, order_id = trim(cnvtstring(temp->qual[d1.seq].
    order_id,14,0)), status = trim(temp->qual[d1.seq].status)
  FROM (dummyt d1  WITH seq = value(ops_exception_cnt))
  PLAN (d1)
  ORDER BY accession_number
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->apsrpt,
   CALL center(captions->reopsexceptionaudit,0,132), col 110, captions->ddate,
   col 117, curdate"@SHORTDATE;;Q", row + 1,
   col 0, captions->directory, col 110,
   captions->ttime, col 117, curtime,
   row + 1, col 110, captions->ppage,
   col 117, curpage"###", row + 2,
   col 0, captions->accn, col 22,
   captions->ordertype, col 33, captions->description,
   col 54, captions->action, col 66,
   captions->status, col 75, captions->attempts,
   col 84, captions->last, col 101,
   captions->parent, col 115, captions->orderid,
   row + 1, col 0, "---------------------",
   col 22, "----------", col 33,
   "--------------------", col 54, "-----------",
   col 66, "--------", col 75,
   "--------", col 84, "---------------",
   col 101, "---------", col 115,
   "-------------"
  DETAIL
   row + 1, col 0, accession_number,
   col 22, order_type, col 33,
   description, col 54, action,
   col 66, status, col 75,
   attempts
   IF (attempts != "0")
    col 84, last_attempt"@SHORTDATE;;D", col 94,
    last_attempt"@TIMENOSECONDS;;M"
   ENDIF
   col 101, parent_id, col 115,
   order_id
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->apsrpt,
   today = concat(week," ",day), col 53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->continued
  FOOT REPORT
   col 55, captions->endofreport
  WITH nocounter, outerjoin = d1, maxcol = 132,
   nullreport, maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
 GO TO exit_script
#end_script
 SET reply->status_data.subeventstatus[1].operationname = "Invalid Operations Parameters"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "Param Number"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(error_number)
 SET failed = "T"
#exit_script
 IF (failed="F")
  IF ((reply->status_data.status="S"))
   IF (output_dest_id != 0.0)
    SET spool value(reply->print_status_data.print_dir_and_filename) value(raw_output_dest) WITH copy
     = value(raw_nbr_copies)
    SET reply->ops_event = concat("Successful ",trim(reply->print_status_data.print_dir_and_filename)
     )
   ENDIF
   IF (nemailind=true)
    DECLARE semailaddress = vc WITH protect, noconstant("")
    DECLARE snotfound = vc WITH protect, constant("<not_found>")
    DECLARE lnum = i4 WITH protect, noconstant(1)
    DECLARE sdelim = c1 WITH protect, noconstant(";")
    DECLARE semailfrom = vc WITH protect, noconstant(captions->emailfrom)
    IF (findstring(",",request->output_dist) > 0)
     SET sdelim = ","
    ENDIF
    IF (findstring("from:",cnvtlower(request->batch_selection))=1)
     SET semailfrom = trim(substring(6,(textlen(request->batch_selection) - 5),request->
       batch_selection))
    ENDIF
    WHILE (assign(semailaddress,piece(request->output_dist,sdelim,lnum,snotfound)) != snotfound)
     SET lnum = (lnum+ 1)
     CALL emailfile(semailaddress,semailfrom,captions->apsrpt,reply->print_status_data.
      print_dir_and_filename)
    ENDWHILE
   ENDIF
  ENDIF
 ENDIF
END GO
