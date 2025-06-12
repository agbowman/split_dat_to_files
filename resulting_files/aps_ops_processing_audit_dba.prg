CREATE PROGRAM aps_ops_processing_audit:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 request_number = i4
     2 format_script = c30
     2 target_request_number = i4
     2 destination_step_id = f8
     2 reprocess_reply_ind = i2
     2 expected_cnt = i2
     2 actual_cnt = i2
     2 epi_pro_script = i2
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
   1 missing = vc
   1 apsrpt = vc
   1 ddate = vc
   1 directory = vc
   1 ttime = vc
   1 reopsprocessingaudit = vc
   1 bby = vc
   1 ppage = vc
   1 req = vc
   1 status = vc
   1 sequence = vc
   1 pfmt = vc
   1 target = vc
   1 dest = vc
   1 reprocess = vc
   1 epipro = vc
   1 continued = vc
   1 endofreport = vc
 )
#script
 SET captions->apsrpt = uar_i18ngetmessage(i18nhandle,"h1","REPORT: APS_OPS_PROCESSING_AUDIT.PRG")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"h2","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h3","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h4","TIME:")
 SET captions->reopsprocessingaudit = uar_i18ngetmessage(i18nhandle,"h5","OPS PROCESSING AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h6","BY:")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h8","PAGE:")
 SET captions->req = uar_i18ngetmessage(i18nhandle,"h13","REQUEST")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"h13","STATUS")
 SET captions->sequence = uar_i18ngetmessage(i18nhandle,"h13","SEQUENCE")
 SET captions->pfmt = uar_i18ngetmessage(i18nhandle,"h13","FORMAT SCRIPT")
 SET captions->target = uar_i18ngetmessage(i18nhandle,"h13","TARGET REQUEST")
 SET captions->dest = uar_i18ngetmessage(i18nhandle,"h13","DESTINATION STEP ID")
 SET captions->reprocess = uar_i18ngetmessage(i18nhandle,"h13","REPROCESS REPLY")
 SET captions->missing = uar_i18ngetmessage(i18nhandle,"h14","MISSING")
 SET captions->epipro = uar_i18ngetmessage(i18nhandle,"h15","EPILOG/PROLOG")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET captions->endofreport = uar_i18ngetmessage(i18nhandle,"f1","*** END OF ERPORT ***")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET processing_cnt = 16
 SET stat = alterlist(temp->qual,processing_cnt)
 SET temp->qual[1].request_number = 200005
 SET temp->qual[1].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET temp->qual[1].target_request_number = 560201
 SET temp->qual[1].destination_step_id = 560201
 SET temp->qual[1].reprocess_reply_ind = 1
 SET temp->qual[1].expected_cnt = 2
 SET temp->qual[2].request_number = 200005
 SET temp->qual[2].format_script = "PFMT_APS_INITIATE_SPC_PROT"
 SET temp->qual[2].target_request_number = 0
 SET temp->qual[2].destination_step_id = 0
 SET temp->qual[2].reprocess_reply_ind = 0
 SET temp->qual[2].expected_cnt = 1
 SET temp->qual[3].request_number = 200006
 SET temp->qual[3].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET temp->qual[3].target_request_number = 560201
 SET temp->qual[3].destination_step_id = 560201
 SET temp->qual[3].reprocess_reply_ind = 1
 SET temp->qual[3].expected_cnt = 2
 SET temp->qual[4].request_number = 200006
 SET temp->qual[4].format_script = "PFMT_APS_INITIATE_SPC_PROT"
 SET temp->qual[4].target_request_number = 0
 SET temp->qual[4].destination_step_id = 0
 SET temp->qual[4].reprocess_reply_ind = 0
 SET temp->qual[4].expected_cnt = 1
 SET temp->qual[5].request_number = 200011
 SET temp->qual[5].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET temp->qual[5].target_request_number = 560201
 SET temp->qual[5].destination_step_id = 560201
 SET temp->qual[5].reprocess_reply_ind = 1
 SET temp->qual[5].expected_cnt = 1
 SET temp->qual[6].request_number = 200012
 SET temp->qual[6].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET temp->qual[6].target_request_number = 560201
 SET temp->qual[6].destination_step_id = 560201
 SET temp->qual[6].reprocess_reply_ind = 1
 SET temp->qual[6].expected_cnt = 1
 SET temp->qual[7].request_number = 200014
 SET temp->qual[7].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET temp->qual[7].target_request_number = 560201
 SET temp->qual[7].destination_step_id = 560201
 SET temp->qual[7].reprocess_reply_ind = 1
 SET temp->qual[7].expected_cnt = 1
 SET temp->qual[8].request_number = 200019
 SET temp->qual[8].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET temp->qual[8].target_request_number = 560201
 SET temp->qual[8].destination_step_id = 560201
 SET temp->qual[8].reprocess_reply_ind = 1
 SET temp->qual[8].expected_cnt = 1
 SET temp->qual[9].request_number = 200021
 SET temp->qual[9].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET temp->qual[9].target_request_number = 560201
 SET temp->qual[9].destination_step_id = 560201
 SET temp->qual[9].reprocess_reply_ind = 1
 SET temp->qual[9].expected_cnt = 1
 SET temp->qual[10].request_number = 200118
 SET temp->qual[10].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET temp->qual[10].target_request_number = 560201
 SET temp->qual[10].destination_step_id = 560201
 SET temp->qual[10].reprocess_reply_ind = 1
 SET temp->qual[10].expected_cnt = 1
 SET temp->qual[11].request_number = 200138
 SET temp->qual[11].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET temp->qual[11].target_request_number = 560201
 SET temp->qual[11].destination_step_id = 560201
 SET temp->qual[11].reprocess_reply_ind = 1
 SET temp->qual[11].expected_cnt = 1
 SET temp->qual[12].request_number = 200150
 SET temp->qual[12].format_script = "PFMT_APS_PROC_TASKS_TO_ORDER"
 SET temp->qual[12].target_request_number = 0
 SET temp->qual[12].destination_step_id = 0
 SET temp->qual[12].reprocess_reply_ind = 0
 SET temp->qual[12].expected_cnt = 1
 SET temp->qual[13].request_number = 200150
 SET temp->qual[13].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET temp->qual[13].target_request_number = 560201
 SET temp->qual[13].destination_step_id = 560201
 SET temp->qual[13].reprocess_reply_ind = 1
 SET temp->qual[13].expected_cnt = 1
 SET temp->qual[14].request_number = 200386
 SET temp->qual[14].format_script = "PFMT_APS_OPS_EXCEPTION"
 SET temp->qual[14].target_request_number = 560201
 SET temp->qual[14].destination_step_id = 560201
 SET temp->qual[14].reprocess_reply_ind = 1
 SET temp->qual[14].expected_cnt = 1
 SET temp->qual[15].request_number = 200390
 SET temp->qual[15].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET temp->qual[15].target_request_number = 560201
 SET temp->qual[15].destination_step_id = 560201
 SET temp->qual[15].reprocess_reply_ind = 1
 SET temp->qual[15].expected_cnt = 2
 SET temp->qual[16].request_number = 200390
 SET temp->qual[16].format_script = "PFMT_APS_COMP_BILLING_TASKS"
 SET temp->qual[16].target_request_number = 0
 SET temp->qual[16].destination_step_id = 0
 SET temp->qual[16].reprocess_reply_ind = 0
 SET temp->qual[16].expected_cnt = 1
 SELECT INTO "nl:"
  rp.request_number, rp.sequence
  FROM request_processing rp,
   (dummyt d  WITH seq = value(processing_cnt))
  PLAN (d)
   JOIN (rp
   WHERE (temp->qual[d.seq].request_number=rp.request_number)
    AND trim(temp->qual[d.seq].format_script)=trim(rp.format_script)
    AND (temp->qual[d.seq].target_request_number=rp.target_request_number)
    AND (temp->qual[d.seq].destination_step_id=rp.destination_step_id)
    AND (temp->qual[d.seq].reprocess_reply_ind=rp.reprocess_reply_ind)
    AND rp.active_ind=1)
  DETAIL
   temp->qual[d.seq].actual_cnt = (temp->qual[d.seq].actual_cnt+ 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  rq.request_number
  FROM request rq,
   (dummyt d  WITH seq = value(processing_cnt))
  PLAN (d)
   JOIN (rq
   WHERE (temp->qual[d.seq].request_number=rq.request_number))
  DETAIL
   IF (textlen(trim(rq.epilog_script))=0)
    temp->qual[d.seq].epi_pro_script = 1, temp->qual[d.seq].actual_cnt = (temp->qual[d.seq].
    actual_cnt - 1)
   ELSEIF (textlen(trim(rq.prolog_script))=0)
    temp->qual[d.seq].epi_pro_script = 1, temp->qual[d.seq].actual_cnt = (temp->qual[d.seq].
    actual_cnt - 1)
   ENDIF
  WITH nocounter
 ;end select
#report_maker
 SELECT INTO mine
  req_number = temp->qual[d1.seq].request_number, format_script = temp->qual[d1.seq].format_script,
  target_request = temp->qual[d1.seq].target_request_number,
  destination_step = temp->qual[d1.seq].destination_step_id, reprocess_reply = temp->qual[d1.seq].
  reprocess_reply_ind, expected_cnt = temp->qual[d1.seq].expected_cnt,
  actual_cnt = temp->qual[d1.seq].actual_cnt
  FROM (dummyt d1  WITH seq = value(processing_cnt))
  PLAN (d1)
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->apsrpt,
   CALL center(captions->reopsprocessingaudit,0,132), col 110, captions->ddate,
   col 117, curdate"@SHORTDATE;;Q", row + 1,
   col 0, captions->directory, col 110,
   captions->ttime, col 117, curtime,
   row + 1, col 110, captions->ppage,
   col 117, curpage"###", row + 2,
   col 0, captions->status, col 10,
   captions->req, col 20, captions->pfmt,
   col 50, captions->target, col 70,
   captions->dest, col 90, captions->reprocess,
   col 108, captions->epipro, row + 1,
   col 0, "---------", col 10,
   "---------", col 20, "-----------------------------",
   col 50, "-------------------", col 70,
   "-------------------", col 90, "-------------------",
   col 108, "-------------"
  DETAIL
   IF (expected_cnt > actual_cnt)
    row + 1, col 0, captions->missing,
    col 10, req_number"######", col 20,
    format_script, col 50, target_request"########",
    col 70, destination_step"########", col 90,
    reprocess_reply"#"
    IF ((temp->qual[d1.seq].epi_pro_script=1))
     col 108, captions->missing
    ENDIF
   ENDIF
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
  SET reply->status_data.status = "S"
 ENDIF
END GO
