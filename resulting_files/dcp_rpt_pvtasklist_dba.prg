CREATE PROGRAM dcp_rpt_pvtasklist:dba
 RECORD reply(
   1 text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD temp(
   1 col_cnt = i2
   1 col[*]
     2 lbl = vc
     2 def = i2
     2 min = i2
     2 wrap = i2
     2 wont_fit = i2
     2 pad = i2
   1 row_cnt = i2
   1 row[*]
     2 col_cnt = i2
     2 max_data_lcnt = i2
     2 col[*]
       3 col_data_lcnt = i2
       3 cdl[*]
         4 data_text = vc
     2 col_note_ind = i2
     2 order_id = f8
     2 blob_out = vc
     2 col_note_cnt = i2
     2 cnl[*]
       3 note_text = vc
 )
 RECORD hold(
   1 col[*]
     2 mean = vc
     2 lbl = vc
     2 def = i2
     2 min = i2
     2 wrap = i2
     2 spl_def = i2
     2 pad = i2
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET max_width_norm = 132
 SET force_sp_landscape = 0
 SET max_width_landscape = 200
 SET report_name = request->report_name
 IF (report_name=" ")
  SET report_name = "TASK LIST REPORT"
 ENDIF
 SET title_line = 50
 SET left_marg = 50
 SET last_row = 0
 SET data_inc = 12
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET ord_cd = 0
 SET code_value = 0
 SET code_set = 14
 SET cdf_meaning = "ORD COMMENT"
 EXECUTE cpm_get_cd_for_cdf
 SET ord_cd = code_value
 SET stat = alterlist(hold->col,51)
 SET hold->col[1].mean = "ADDBY"
 SET hold->col[1].lbl = "Added By"
 SET hold->col[1].def = 30
 SET hold->col[1].min = 20
 SET hold->col[1].wrap = 0
 SET hold->col[1].pad = 0
 SET hold->col[2].mean = "ALTWITH"
 SET hold->col[2].lbl = "Alternate With"
 SET hold->col[2].def = 30
 SET hold->col[2].min = 20
 SET hold->col[2].wrap = 0
 SET hold->col[2].pad = 0
 SET hold->col[3].mean = "BAGSTAT"
 SET hold->col[3].lbl = "Bag Status"
 SET hold->col[3].def = 12
 SET hold->col[3].min = 5
 SET hold->col[3].wrap = 0
 SET hold->col[3].pad = 0
 SET hold->col[4].mean = "CLINICIAN"
 SET hold->col[4].lbl = "Clinician"
 SET hold->col[4].def = 30
 SET hold->col[4].min = 20
 SET hold->col[4].wrap = 0
 SET hold->col[4].pad = 0
 SET hold->col[5].mean = "COMPLTDT"
 SET hold->col[5].lbl = "Completed Dt/Tm"
 SET hold->col[5].def = 20
 SET hold->col[5].min = 15
 SET hold->col[5].wrap = 0
 SET hold->col[5].pad = 0
 SET hold->col[6].mean = "CONFIDNTL"
 SET hold->col[6].lbl = "Confidential"
 SET hold->col[6].def = 12
 SET hold->col[6].min = 12
 SET hold->col[6].wrap = 0
 SET hold->col[6].pad = 0
 SET hold->col[7].mean = "DEPT"
 SET hold->col[7].lbl = "Department"
 SET hold->col[7].def = 20
 SET hold->col[7].min = 15
 SET hold->col[7].wrap = 0
 SET hold->col[7].pad = 0
 SET hold->col[8].mean = "DESOUTCOME"
 SET hold->col[8].lbl = "Desired Outcome"
 SET hold->col[8].def = 30
 SET hold->col[8].min = 20
 SET hold->col[8].wrap = 1
 SET hold->col[8].pad = 0
 SET hold->col[9].mean = "DOSE"
 SET hold->col[9].lbl = "Dose"
 SET hold->col[9].def = 25
 SET hold->col[9].min = 15
 SET hold->col[9].wrap = 0
 SET hold->col[9].pad = 0
 SET hold->col[10].mean = "FINNBR"
 SET hold->col[10].lbl = "Financial Nbr"
 SET hold->col[10].def = 15
 SET hold->col[10].min = 15
 SET hold->col[10].wrap = 0
 SET hold->col[10].pad = 0
 SET hold->col[11].mean = "FREQ"
 SET hold->col[11].lbl = "Frequency"
 SET hold->col[11].def = 15
 SET hold->col[11].min = 9
 SET hold->col[11].wrap = 0
 SET hold->col[11].pad = 0
 SET hold->col[12].mean = "FROM"
 SET hold->col[12].lbl = "From"
 SET hold->col[12].def = 30
 SET hold->col[12].min = 20
 SET hold->col[12].wrap = 0
 SET hold->col[12].pad = 0
 SET hold->col[13].mean = "INFUSEOVER"
 SET hold->col[13].lbl = "Infuse Over"
 SET hold->col[13].def = 12
 SET hold->col[13].min = 10
 SET hold->col[13].wrap = 0
 SET hold->col[13].pad = 0
 SET hold->col[14].mean = "INGREDS"
 SET hold->col[14].lbl = "Ingredients"
 SET hold->col[14].def = 25
 SET hold->col[14].min = 20
 SET hold->col[14].wrap = 1
 SET hold->col[14].pad = 0
 SET hold->col[15].mean = "ISOLATION"
 SET hold->col[15].lbl = "Isolation"
 SET hold->col[15].def = 15
 SET hold->col[15].min = 10
 SET hold->col[15].wrap = 0
 SET hold->col[15].pad = 0
 SET hold->col[16].mean = "LASTDONEDT"
 SET hold->col[16].lbl = "Last Done Dt/Tm"
 SET hold->col[16].def = 20
 SET hold->col[16].min = 15
 SET hold->col[16].wrap = 0
 SET hold->col[16].pad = 0
 SET hold->col[17].mean = "LASTDOSE"
 SET hold->col[17].lbl = "Last Dose Given"
 SET hold->col[17].def = 15
 SET hold->col[17].min = 15
 SET hold->col[17].wrap = 0
 SET hold->col[17].pad = 0
 SET hold->col[18].mean = "LASTVALUE"
 SET hold->col[18].lbl = "Last Entered Value"
 SET hold->col[18].def = 20
 SET hold->col[18].min = 18
 SET hold->col[18].wrap = 0
 SET hold->col[18].pad = 0
 SET hold->col[19].mean = "LASTGIVEBY"
 SET hold->col[19].lbl = "Last Given By"
 SET hold->col[19].def = 30
 SET hold->col[19].min = 20
 SET hold->col[19].wrap = 0
 SET hold->col[19].pad = 0
 SET hold->col[20].mean = "LASTGIVEDT"
 SET hold->col[20].lbl = "Last Given Dt/Tm"
 SET hold->col[20].def = 20
 SET hold->col[20].min = 15
 SET hold->col[20].wrap = 0
 SET hold->col[20].pad = 0
 SET hold->col[21].mean = "LASTSITE"
 SET hold->col[21].lbl = "Last Site"
 SET hold->col[21].def = 20
 SET hold->col[21].min = 15
 SET hold->col[21].wrap = 0
 SET hold->col[21].pad = 0
 SET hold->col[22].mean = "MNEMONIC"
 SET hold->col[22].lbl = "Mnemonic"
 SET hold->col[22].def = 25
 SET hold->col[22].min = 15
 SET hold->col[22].wrap = 0
 SET hold->col[22].pad = 0
 SET hold->col[23].mean = "NOTBEFORE"
 SET hold->col[23].lbl = "Not Before"
 SET hold->col[23].def = 20
 SET hold->col[23].min = 15
 SET hold->col[23].wrap = 0
 SET hold->col[23].pad = 0
 SET hold->col[24].mean = "ORDDET"
 SET hold->col[24].lbl = "Order Details"
 SET hold->col[24].def = 45
 SET hold->col[24].spl_def = 75
 SET hold->col[24].min = 25
 SET hold->col[24].wrap = 1
 SET hold->col[24].pad = 10
 SET hold->col[25].mean = "ORDSTATUS"
 SET hold->col[25].lbl = "Order Status"
 SET hold->col[25].def = 15
 SET hold->col[25].min = 15
 SET hold->col[25].wrap = 0
 SET hold->col[25].pad = 0
 SET hold->col[26].mean = "PRIO"
 SET hold->col[26].lbl = "Priority"
 SET hold->col[26].def = 20
 SET hold->col[26].min = 12
 SET hold->col[26].wrap = 0
 SET hold->col[26].pad = 0
 SET hold->col[27].mean = "PROVNAME"
 SET hold->col[27].lbl = "Provider Name"
 SET hold->col[27].def = 30
 SET hold->col[27].min = 20
 SET hold->col[27].wrap = 0
 SET hold->col[27].pad = 0
 SET hold->col[28].mean = "RATE"
 SET hold->col[28].lbl = "Rate"
 SET hold->col[28].def = 15
 SET hold->col[28].min = 15
 SET hold->col[28].wrap = 0
 SET hold->col[28].pad = 0
 SET hold->col[29].mean = "REASONGIVE"
 SET hold->col[29].lbl = "Reason for Giving"
 SET hold->col[29].def = 25
 SET hold->col[29].min = 17
 SET hold->col[29].wrap = 0
 SET hold->col[29].pad = 0
 SET hold->col[30].mean = "RECEIVED"
 SET hold->col[30].lbl = "Received"
 SET hold->col[30].def = 20
 SET hold->col[30].min = 15
 SET hold->col[30].wrap = 0
 SET hold->col[30].pad = 0
 SET hold->col[31].mean = "RESPONSEREQ"
 SET hold->col[31].lbl = "Response Required"
 SET hold->col[31].def = 17
 SET hold->col[31].min = 17
 SET hold->col[31].wrap = 0
 SET hold->col[31].pad = 0
 SET hold->col[32].mean = "ROUTE"
 SET hold->col[32].lbl = "Route"
 SET hold->col[32].def = 20
 SET hold->col[32].min = 15
 SET hold->col[32].wrap = 0
 SET hold->col[32].pad = 0
 SET hold->col[33].mean = "SCHEDDATE"
 SET hold->col[33].lbl = "Scheduled Date"
 SET hold->col[33].def = 15
 SET hold->col[33].min = 15
 SET hold->col[33].wrap = 0
 SET hold->col[33].pad = 0
 SET hold->col[34].mean = "SCHEDDTTM"
 SET hold->col[34].lbl = "Scheduled Dt/Tm"
 SET hold->col[34].def = 22
 SET hold->col[34].spl_def = 22
 SET hold->col[34].min = 18
 SET hold->col[34].wrap = 0
 SET hold->col[34].pad = 0
 SET hold->col[35].mean = "SCHEDTIME"
 SET hold->col[35].lbl = "Scheduled Time"
 SET hold->col[35].def = 20
 SET hold->col[35].min = 20
 SET hold->col[35].wrap = 0
 SET hold->col[35].pad = 0
 SET hold->col[36].mean = "STARTDT"
 SET hold->col[36].lbl = "Start Dt/Tm"
 SET hold->col[36].def = 20
 SET hold->col[36].min = 15
 SET hold->col[36].wrap = 0
 SET hold->col[36].pad = 0
 SET hold->col[37].mean = "STOPDT"
 SET hold->col[37].lbl = "Stop Dt/Tm"
 SET hold->col[37].def = 20
 SET hold->col[37].min = 15
 SET hold->col[37].wrap = 0
 SET hold->col[37].pad = 0
 SET hold->col[38].mean = "STRENGTH"
 SET hold->col[38].lbl = "Strength"
 SET hold->col[38].def = 20
 SET hold->col[38].min = 15
 SET hold->col[38].wrap = 0
 SET hold->col[38].pad = 0
 SET hold->col[39].mean = "SUBJECT"
 SET hold->col[39].lbl = "Subject"
 SET hold->col[39].def = 25
 SET hold->col[39].min = 20
 SET hold->col[39].wrap = 0
 SET hold->col[39].pad = 0
 SET hold->col[40].mean = "TASKDESC"
 SET hold->col[40].lbl = "Task Description"
 SET hold->col[40].def = 35
 SET hold->col[40].spl_def = 55
 SET hold->col[40].min = 20
 SET hold->col[40].wrap = 0
 SET hold->col[40].pad = 0
 SET hold->col[41].mean = "STATUS"
 SET hold->col[41].lbl = "Task Status"
 SET hold->col[41].def = 14
 SET hold->col[41].spl_def = 14
 SET hold->col[41].min = 12
 SET hold->col[41].wrap = 0
 SET hold->col[41].pad = 0
 SET hold->col[42].mean = "TO"
 SET hold->col[42].lbl = "To"
 SET hold->col[42].def = 30
 SET hold->col[42].min = 20
 SET hold->col[42].wrap = 0
 SET hold->col[42].pad = 0
 SET hold->col[43].mean = "TYPE"
 SET hold->col[43].lbl = "Type"
 SET hold->col[43].def = 20
 SET hold->col[43].min = 15
 SET hold->col[43].wrap = 0
 SET hold->col[43].pad = 0
 SET hold->col[44].mean = "LOCATION"
 SET hold->col[44].lbl = "Location"
 SET hold->col[44].def = 25
 SET hold->col[44].min = 15
 SET hold->col[44].wrap = 0
 SET hold->col[44].pad = 0
 SET hold->col[45].mean = "LOCROOMBED"
 SET hold->col[45].lbl = "Loc/Room/Bed"
 SET hold->col[45].def = 20
 SET hold->col[45].min = 17
 SET hold->col[45].wrap = 0
 SET hold->col[45].pad = 0
 SET hold->col[46].mean = "MRN"
 SET hold->col[46].lbl = "MRN"
 SET hold->col[46].def = 15
 SET hold->col[46].min = 15
 SET hold->col[46].wrap = 0
 SET hold->col[46].pad = 0
 SET hold->col[47].mean = "NAME"
 SET hold->col[47].lbl = "Name"
 SET hold->col[47].def = 30
 SET hold->col[47].min = 25
 SET hold->col[47].wrap = 0
 SET hold->col[47].pad = 0
 SET hold->col[48].mean = "ROOMBD"
 SET hold->col[48].lbl = "Room/Bed"
 SET hold->col[48].def = 10
 SET hold->col[48].min = 10
 SET hold->col[48].wrap = 0
 SET hold->col[48].pad = 0
 SET hold->col[49].mean = "LOCROOMBD"
 SET hold->col[49].lbl = "Loc/Room/Bed"
 SET hold->col[49].def = 20
 SET hold->col[49].min = 17
 SET hold->col[49].wrap = 0
 SET hold->col[49].pad = 0
 SET hold->col[50].mean = "DEFAULT"
 SET hold->col[50].lbl = "default col head"
 SET hold->col[50].def = 17
 SET hold->col[50].min = 17
 SET hold->col[50].wrap = 0
 SET hold->col[50].pad = 0
 SET hold->col[51].mean = "UPDTUSERNAME"
 SET hold->col[51].lbl = "Charted By"
 SET hold->col[51].def = 30
 SET hold->col[51].min = 20
 SET hold->col[51].wrap = 0
 SET hold->col[51].pad = 0
 SET hold_cnt = 51
 SET ccnt = size(request->tlp[1].nvl,5)
 SET temp->col_cnt = value(ccnt)
 SET stat = alterlist(temp->col,value(ccnt))
 SET width_tot = 0
 SET min_tot = 0
 SET found_col = 0
 FOR (y = 1 TO value(ccnt))
   SET found_col = 0
   FOR (z = 1 TO hold_cnt)
     IF ((hold->col[z].mean=request->tlp[1].nvl[y].pvc_name))
      SET found_col = 1
      SET temp->col[y].lbl = hold->col[z].lbl
      SET temp->col[y].def = hold->col[z].def
      IF ((request->multi_pt_ind=0)
       AND force_sp_landscape=1
       AND (hold->col[z].spl_def > 0))
       SET temp->col[y].def = hold->col[z].spl_def
      ENDIF
      SET width_tot = (width_tot+ hold->col[z].def)
      SET temp->col[y].min = hold->col[z].min
      SET min_tot = (min_tot+ hold->col[z].min)
      SET temp->col[y].wrap = hold->col[z].wrap
      SET temp->col[y].pad = hold->col[z].pad
      SET z = (hold_cnt+ 1)
     ENDIF
   ENDFOR
   IF (found_col=0)
    SET temp->col[y].lbl = hold->col[50].lbl
    SET temp->col[y].def = hold->col[50].def
    SET width_tot = (width_tot+ hold->col[50].def)
    SET temp->col[y].min = hold->col[50].min
    SET min_tot = (min_tot+ hold->col[50].min)
    SET temp->col[y].wrap = hold->col[50].wrap
    SET temp->col[y].pad = hold->col[50].pad
   ENDIF
 ENDFOR
 IF (width_tot <= max_width_norm)
  SET lscape = 0
  SET last_row = 720
  SET last_col = 540
 ELSE
  SET lscape = 1
  SET last_row = 500
  SET last_col = 765
 ENDIF
 IF (width_tot <= max_width_landscape)
  SET width_to_use = "DEF"
 ELSE
  SET width_to_use = "MIN"
 ENDIF
 SET rcnt = size(request->tlp,5)
 SET temp->row_cnt = value(rcnt)
 SET stat = alterlist(temp->row,value(rcnt))
 SET max_data_lcnt = 0
 FOR (x = 1 TO value(rcnt))
   SET temp->row[x].col_cnt = value(ccnt)
   SET stat = alterlist(temp->row[x].col,value(ccnt))
   IF ((request->tlp[x].order_id > 0))
    SELECT INTO "nl:"
     FROM orders o
     WHERE (o.order_id=request->tlp[x].order_id)
     DETAIL
      IF (o.order_comment_ind=1)
       temp->row[x].order_id = o.order_id, temp->row[x].col_note_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   FOR (y = 1 TO value(ccnt))
     IF ((request->tlp[x].nvl[y].pvc_value > " "))
      SET pt->line_cnt = 0
      IF (width_to_use="DEF")
       SET max_length = temp->col[y].def
      ELSE
       SET max_length = temp->col[y].min
      ENDIF
      EXECUTE dcp_parse_text value(request->tlp[x].nvl[y].pvc_value), value(max_length)
      SET temp->row[x].col[y].col_data_lcnt = pt->line_cnt
      SET stat = alterlist(temp->row[x].col[y].cdl,pt->line_cnt)
      FOR (z = 1 TO pt->line_cnt)
        SET temp->row[x].col[y].cdl[z].data_text = pt->lns[z].line
      ENDFOR
      IF ((pt->line_cnt > max_data_lcnt))
       SET max_data_lcnt = pt->line_cnt
      ENDIF
     ELSE
      SET temp->row[x].col[y].col_data_lcnt = 0
     ENDIF
   ENDFOR
   SET temp->row[x].max_data_lcnt = max_data_lcnt
   SET max_data_lcnt = 0
 ENDFOR
 FOR (x = 1 TO value(rcnt))
   IF ((temp->row[x].col_note_ind=1))
    SELECT INTO "nl:"
     FROM order_comment oc,
      long_text lt
     PLAN (oc
      WHERE (oc.order_id=temp->row[x].order_id)
       AND oc.comment_type_cd=ord_cd)
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id)
     HEAD REPORT
      blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," ")
     DETAIL
      blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), y1 = size(trim(lt
        .long_text)),
      blob_out = substring(1,y1,lt.long_text),
      CALL uar_rtf(blob_out,y1,blob_out2,32000,32000,0), temp->row[x].blob_out = blob_out2
     WITH nocounter
    ;end select
    SET pt->line_cnt = 0
    IF (lscape=1)
     SET max_length = 100
    ELSE
     SET max_length = 100
    ENDIF
    IF ((temp->row[x].blob_out > " "))
     EXECUTE dcp_parse_text value(temp->row[x].blob_out), value(max_length)
     SET temp->row[x].col_note_cnt = pt->line_cnt
     SET stat = alterlist(temp->row[x].cnl,pt->line_cnt)
     FOR (z = 1 TO pt->line_cnt)
       SET temp->row[x].cnl[z].note_text = pt->lns[z].line
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 SET new_timedisp = cnvtstring(curtime3)
 SET tempfile1a = build(concat("cer_temp:tskrpt","_",new_timedisp),".dat")
 SELECT INTO value(tempfile1a)
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   x100 = fillstring(100," "), x300 = fillstring(300," "), x30 = fillstring(85," "),
   start_x = 1, start_y = 1, colnbr = 0,
   st_idx = 0, col_inc = 0, xcol = 0,
   ycol = 0, something_wont_fit = 0
  HEAD PAGE
   something_wont_fit = 0
   IF (lscape=1)
    "{ps/792 0 translate 90 rotate/}", row + 1, xcol = 285
   ELSE
    xcol = 230
   ENDIF
   ycol = title_line,
   CALL print(calcpos(xcol,ycol)), "{b}{f/5}{cpi/8}",
   report_name, "{endb}{cpi/14}{f/4}", row + 1,
   xcol = left_marg
   IF ((request->multi_pt_ind=1))
    ycol = (ycol+ 50)
   ELSE
    ycol = (ycol+ 20),
    CALL print(calcpos(xcol,ycol)), "{b}{cpi/11}Patient Name: {endb}",
    xcol = (xcol+ 80), x30 = trim(request->name_full_formatted),
    CALL print(calcpos(xcol,ycol)),
    x30, ycol = (ycol+ data_inc), row + 1,
    xcol = left_marg,
    CALL print(calcpos(xcol,ycol)), "{b}MRN: {endb}",
    xcol = (xcol+ 30), x30 = request->mrn,
    CALL print(calcpos(xcol,ycol)),
    x30, "{cpi/14}", ycol = (ycol+ data_inc),
    row + 1, ycol = (ycol+ data_inc), row + 1
   ENDIF
   xcol = left_marg
   FOR (w = 1 TO temp->col_cnt)
    IF (width_to_use="MIN")
     col_inc = temp->col[w].min
    ELSE
     col_inc = temp->col[w].def
    ENDIF
    ,
    IF (((xcol+ (col_inc * 4)) > last_col))
     temp->col[w].wont_fit = 1, something_wont_fit = (something_wont_fit+ 1)
    ELSE
     x30 = trim(temp->col[w].lbl),
     CALL print(calcpos(xcol,ycol)), "{b}",
     x30, row + 1, xcol = (xcol+ (col_inc * 4)),
     xcol = (xcol+ (temp->col[w].pad * 4))
    ENDIF
   ENDFOR
   row + 1, ycol = (ycol+ 15), row + 1
  DETAIL
   FOR (x = start_x TO temp->row_cnt)
     IF ((((ycol+ (data_inc * something_wont_fit))+ (data_inc * 3)) > last_row))
      start_x = x, BREAK
     ENDIF
     xcol = left_marg
     FOR (z = 1 TO temp->row[x].max_data_lcnt)
       xcol = left_marg
       FOR (y = start_y TO temp->row[x].col_cnt)
        IF ((((z > temp->row[x].col[y].col_data_lcnt)) OR ((temp->col[y].wont_fit=1))) )
         row + 0
        ELSE
         x30 = trim(temp->row[x].col[y].cdl[z].data_text),
         CALL print(calcpos(xcol,ycol)), "{f/4}",
         x30, row + 1
         IF (ycol > last_row)
          BREAK
         ENDIF
        ENDIF
        ,
        IF (width_to_use="MIN")
         xcol = (xcol+ (temp->col[y].min * 4)), xcol = (xcol+ (temp->col[y].pad * 4))
        ELSE
         xcol = (xcol+ (temp->col[y].def * 4)), xcol = (xcol+ (temp->col[y].pad * 4))
        ENDIF
       ENDFOR
       ycol = (ycol+ data_inc), row + 1
     ENDFOR
     ycol = (ycol+ (data_inc/ 2)), row + 1
     IF (something_wont_fit > 0)
      FOR (y = 1 TO temp->col_cnt)
        IF ((temp->col[y].wont_fit=1))
         IF (width_to_use="MIN")
          col_inc = temp->col[y].min
         ELSE
          col_inc = temp->col[y].def
         ENDIF
         xcol = 100, x30 = concat(trim(temp->col[y].lbl),":"),
         CALL print(calcpos(xcol,ycol)),
         "{f/7}", x30, xcol = (xcol+ (col_inc * 5))
         FOR (z = 1 TO temp->row[x].col[y].col_data_lcnt)
           x30 = trim(temp->row[x].col[y].cdl[z].data_text),
           CALL print(calcpos(xcol,ycol)), "{f/6}",
           x30, "{f/4}", ycol = (ycol+ data_inc),
           row + 1
         ENDFOR
         ycol = (ycol+ data_inc), row + 1
        ENDIF
      ENDFOR
     ENDIF
     IF ((temp->row[x].col_note_ind=1)
      AND (temp->row[x].col_note_cnt > 0))
      xcol = 100,
      CALL print(calcpos(xcol,ycol)), "{f/7}Order Comment:"
      FOR (y = 1 TO temp->row[x].col_note_cnt)
        xcol = 180, x100 = trim(temp->row[x].cnl[y].note_text),
        CALL print(calcpos(xcol,ycol)),
        "{f/6}", x100, "{f/4}",
        ycol = (ycol+ data_inc), row + 1
        IF (ycol > last_row)
         BREAK
        ENDIF
      ENDFOR
      ycol = (ycol+ (data_inc/ 2)), row + 1
      IF (ycol > last_row)
       BREAK
      ENDIF
     ENDIF
   ENDFOR
  FOOT PAGE
   xcol = 100, ycol = 525
   IF (lscape=1)
    xcol = 375, ycol = 525
   ELSE
    xcol = 250, ycol = 750
   ENDIF
   CALL print(calcpos(xcol,ycol)), "{cpi/16}{f/4}Page", curpage,
   row + 1, xcol = (xcol+ 60),
   CALL print(calcpos(xcol,ycol)),
   curdate, "  ", curtime,
   row + 1
  WITH nocounter, maxrow = 200, maxcol = 770,
   dio = postscript
 ;end select
 SET reply->text = tempfile1a
END GO
