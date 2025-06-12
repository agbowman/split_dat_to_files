CREATE PROGRAM dm_get_purge_log_rows:dba
 SET reply->status_data.status = "F"
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
 SET v_days_to_keep = - (1)
 SET v_days_between = - (1)
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = cnvtreal(request->tokens[tok_ndx].value)
   ELSEIF ((request->tokens[tok_ndx].token_str="DAYSBETWEEN"))
    SET v_days_between = cnvtreal(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 5)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1","%1 %2 %3","sss",
   "You must keep at least 5 days worth of data.  You entered ",
   nullterm(trim(cnvtstring(v_days_to_keep),3))," days or did not enter any value.")
 ELSEIF (v_days_between < 1)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k2","%1 %2 %3","sss",
   "You must have at least 1 day between runs.  You entered ",
   nullterm(trim(cnvtstring(v_days_between),3))," days or did not enter any value.")
 ELSE
  SET v_num_days = datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(cnvtdate2(substring(1,8,
      request->last_run_date),"YYYYMMDD"),cnvtint(substring(9,6,request->last_run_date))))
  IF (v_num_days < v_days_between)
   SET reply->status_data.status = "K"
  ELSE
   SET reply->table_name = "DM_PURGE_JOB_LOG"
   SET reply->rows_between_commit = 50
   SET v_rows = 0
   SELECT INTO "nl:"
    jl.rowid
    FROM dm_purge_job_log jl
    WHERE jl.updt_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
    HEAD REPORT
     v_rows = 0
    DETAIL
     v_rows = (v_rows+ 1)
     IF (mod(v_rows,20)=1)
      stat = alterlist(reply->rows,(v_rows+ 19))
     ENDIF
     reply->rows[v_rows].row_id = jl.rowid
    FOOT REPORT
     stat = alterlist(reply->rows,v_rows)
    WITH nocounter, maxqual(jl,value(request->max_rows))
   ;end select
   SET v_errmsg2 = fillstring(132," ")
   SET v_err_code2 = 0
   SET v_err_code2 = error(v_errmsg2,1)
   IF (v_err_code2=0)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->err_code = v_err_code2
    SET reply->err_msg = v_errmsg2
   ENDIF
  ENDIF
 ENDIF
END GO
