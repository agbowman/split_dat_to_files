CREATE PROGRAM ccl_menu_get_prompts:dba
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
 RECORD reply(
   1 qual[*]
     2 prompt_num = i4
     2 prompts = c132
     2 defaults = c132
     2 data_type = c1
     2 prompt_name = vc
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errmsg = c255
 DECLARE boutputset = c
 DECLARE programname = vc
 DECLARE _objfnd = i2
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET output = fillstring(100," ")
 SET errmsg = fillstring(255," ")
 DECLARE delim_char = c1
 DECLARE test_char = c1
 SET pos = 0
 SET i18nhandle = 0
 SET lretval = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE line_remain = vc
 SET stat = error(errmsg,1)
 SET boutputset = "F"
 EXECUTE cpm_create_file_name "cer_temp:mnup", "dat"
 SET output = cpm_cfn_info->file_name
 SET group = 0
 SET _objfnd = 0
 SET programname = cnvtupper(request->program_name)
 SET findgroup = findstring(":",programname)
 IF (((curcclrev=8.2
  AND validate(currevminor2,0) >= 4) OR (curcclrev > 8.2)) )
  IF (findgroup=0)
   SET _objfnd = checkdic(programname,"P",0)
   IF (_objfnd=2)
    SET group = 0
   ELSE
    SET _objfnd = checkdic(programname,"P",1)
    IF (_objfnd=2)
     SET group = 1
    ENDIF
   ENDIF
   CALL echo(concat("checkdic() for object= ",programname,", stat= ",build(_objfnd)))
  ELSE
   SET _objfnd = checkprg(programname)
   CALL echo(concat("checkprg() for object= ",programname,", stat= ",build(_objfnd)))
  ENDIF
 ELSE
  IF (findgroup)
   SET programname = substring(1,(findgroup - 1),programname)
  ENDIF
  CALL echo(concat("Query dprotect for: ",programname))
  SELECT INTO "nl:"
   grp = p.group
   FROM dprotect p
   WHERE p.object="P"
    AND p.object_name=value(programname)
   ORDER BY p.group
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt += 1
    IF (cnt=1)
     group = p.group, _objfnd = 1
    ENDIF
   WITH nocounter, maxqual(p,1)
  ;end select
 ENDIF
 IF (_objfnd=0)
  SET reply->message = uar_i18nbuildmessage(i18nhandle,"KeyBuild1",
   "Program: %1 is not found in object library for current environment.","s",nullterm(trim(
     programname)))
  CALL echo(reply->message)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (group=0)
  IF (curgroup=0)
   SET command1 = cnvtlower(concat("translate into ","'",trim(output),"' ",trim(request->program_name
      ),
     " with prompts go"))
  ELSE
   IF (findgroup=0)
    SET _progname = concat(trim(request->program_name),":dba with prompts go")
   ELSE
    SET _progname = concat(trim(request->program_name)," with prompts go")
   ENDIF
   SET command1 = cnvtlower(concat("translate into ","'",trim(output),"' ",_progname))
  ENDIF
  CALL parser(command1)
 ELSE
  SET groupnum = build("GROUP",floor(group))
  SET command1 = cnvtlower(concat("translate into ","'",trim(output),"' ",trim(programname),
    ":",groupnum," with prompts go"))
  CALL parser(command1)
 ENDIF
 SET errcode = error(errmsg,0)
 IF (errcode != 0)
  SET pos = findstring("Could not execute program",errmsg)
  IF (pos)
   SET reply->message = uar_i18nbuildmessage(i18nhandle,"KeyBuild2",
    "Program: %1 failed to translate object for current environment.","s",nullterm(trim(request->
      program_name)))
  ELSE
   SET reply->message = substring(1,132,errmsg)
  ENDIF
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET cnt = 0
 CALL echo(concat("Command to get prompts: ",command1))
 FREE DEFINE rtl
 FREE SET file_loc
 SET logical file_loc value(nullterm(cnvtlower(output)))
 DEFINE rtl "file_loc"
 SELECT INTO "nl:"
  *
  FROM rtlt
  WITH nocounter, maxrec = 1
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   new_line = r.line
   FROM rtlt r
   HEAD REPORT
    default = fillstring(132," "), cnt1 = 0, cnt2 = 0,
    stat = alterlist(reply->qual,10), bprompts = 1
   DETAIL
    CALL echo(new_line), screenappind = substring(1,2,new_line)
    IF (screenappind="$0")
     reply->message = uar_i18nbuildmessage(i18nhandle,"KeyBuild3",
      "%1 is a screen app program. Unable to execute","s",nullterm(trim(programname))), bprompts = 0,
     BREAK
    ENDIF
    cnt += 1
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alterlist(reply->qual,(cnt+ 9))
    ENDIF
    default = fillstring(132," "), pos = findstring(":: ",new_line), reply->qual[cnt].prompt_name =
    substring(2,(pos - 2),new_line),
    line_remain = trim(substring((pos+ 2),((textlen(new_line) - pos) - 1),new_line),3), delim_char =
    substring(1,1,line_remain), cnt1 = (findstring(delim_char,line_remain,1)+ 1),
    cnt2 = (findstring(delim_char,line_remain,cnt1) - 1), x = movestring(line_remain,cnt1,reply->
     qual[cnt].prompts,1,((cnt2 - cnt1)+ 1)), pos = findstring(":: ",line_remain),
    line_remain = trim(substring((pos+ 2),((textlen(line_remain) - pos) - 1),line_remain),3),
    test_char = substring(1,1,line_remain),
    CALL echo(concat("char = ",test_char))
    IF (test_char != '"'
     AND test_char != "'"
     AND test_char != "^"
     AND test_char != "~")
     reply->qual[cnt].data_type = "N", reply->qual[cnt].defaults = default, reply->qual[cnt].defaults
      = line_remain
    ELSE
     cnt2 = findstring(test_char,line_remain,2), reply->qual[cnt].data_type = "C",
     CALL echo(cnt2),
     CALL echo(cnt1)
     IF (2 != cnt2)
      x = movestring(line_remain,2,reply->qual[cnt].defaults,1,(cnt2 - 2))
     ELSE
      reply->qual[cnt] = ""
     ENDIF
     IF (((cnvtalphanum(reply->qual[cnt].defaults)="CURDATE") OR (cnvtalphanum(reply->qual[cnt].
      defaults)="CURTIME")) )
      reply->qual[cnt].data_type = "N"
     ENDIF
    ENDIF
    reply->qual[cnt].prompt_num = cnt
    IF (cnvtalphanum(reply->qual[cnt].defaults)="MINE")
     reply->qual[cnt].data_type = "O", boutputset = "T"
    ENDIF
   FOOT REPORT
    IF (bprompts=0)
     cnt = - (1)
    ELSEIF (boutputset="F")
     reply->qual[1].data_type = "O"
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->qual,cnt)
  CALL echo(build("Prompt count: ",cnt))
  IF (cnt >= 0)
   SET reply->status_data.status = "S"
  ELSE
   SET failed = "T"
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->qual,cnt)
  CALL echo(concat("No prompts found for program: ",trim(request->program_name)))
  GO TO endit
 ENDIF
 SET stat = remove(cnvtlower(output))
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET failed = "F"
  GO TO exit_script
 ELSE
  SET errcode = error(errmsg,1)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 SET msg1 = uar_i18ngetmessage(i18nhandle,"KeyGet1","get prompts")
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[0].operationname = msg1
  SET reply->status_data.subeventstatus[0].operationstatus = "F"
  SET reply->status_data.subeventstatus[0].targetobjectname = "ccl_menu_get_prompts"
  SET reply->status_data.subeventstatus[0].targetobjectvalue = errmsg
  GO TO endit
 ELSE
  SET reply->status_data.status = "S"
  GO TO endit
 ENDIF
#endit
END GO
