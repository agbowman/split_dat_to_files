CREATE PROGRAM ct_protocol_refhelp:dba
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
 DECLARE addreply(strdisplay=vc,strhidden=vc) = null
 DECLARE closereply(bstandard=i2) = null
 DECLARE getparameters(stringparam=vc) = null
 DECLARE initreply(strcol1header=vc,strcol2header=vc) = null
 DECLARE parsearguments(strvararg=vc,strdelimiter=vc,result=vc(ref)) = null
 DECLARE printstring(lpstring=vc) = null
 DECLARE helprecipient(nlevel=i2,strextraparam=vc) = null
 DECLARE helppriority(ncnt=i2) = null
 DECLARE addreply(strdisplay=vc,strdescription=vc,strhidden=vc) = null
 DECLARE getprotocols(sparameters=vc) = null
 DECLARE getamendments(sparameters=vc) = null
 DECLARE concept_cd = f8 WITH protect, noconstant(0.00)
 DECLARE invalid_cd = f8 WITH protect, noconstant(0.00)
 DECLARE i18nlabel = i4 WITH protect, noconstant(0)
 DECLARE prot_name = vc WITH protect
 DECLARE curr_status_label = vc WITH protect, noconstant("")
 DECLARE status_label = vc WITH protect, noconstant("")
 DECLARE ip_label = vc WITH protect, noconstant("")
 DECLARE amd_str_label = vc WITH protect, noconstant("")
 DECLARE seperator = vc WITH protect, noconstant("")
 DECLARE amd_str = vc WITH protect, noconstant("")
 DECLARE rev_str = vc WITH protect, noconstant("")
 DECLARE rev_label = vc WITH protect, noconstant("")
 DECLARE amendment_name = vc WITH protect
 DECLARE label = vc WITH protect
 DECLARE prot_master_id = f8 WITH protect, noconstant(0.00)
 DECLARE cur_param = i2 WITH protect, noconstant(0)
 DECLARE param_end = i2 WITH protect, noconstant(0)
 DECLARE param_start = i2 WITH protect, noconstant(0)
 DECLARE del_start = i2 WITH protect, noconstant(0)
 DECLARE del_end = i2 WITH protect, noconstant(0)
 DECLARE delim = c1 WITH protect
 DECLARE cut_to = i2 WITH protect, noconstant(0)
 DECLARE cut_len = i2 WITH protect, noconstant(0)
 DECLARE strtext = vc WITH protect
 DECLARE len = i2 WITH protect, noconstant(0)
 DECLARE pos = i2 WITH protect, noconstant(0)
 DECLARE any_prot = vc WITH protect, noconstant("")
 DECLARE any_prot_ind = i2 WITH protect, noconstant(0)
 DECLARE parameter_cnt = i2 WITH protect, noconstant(0)
 DECLARE display = vc WITH protect
 DECLARE desc = vc WITH protect
 DECLARE hidden_value = vc WITH protect
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 RECORD treply(
   1 fieldname = vc
   1 opt_fieldname = vc
   1 cnt = i4
   1 qual[*]
     2 display = vc
     2 opt_desc = vc
     2 hidden = vc
 )
 SET stat = uar_get_meaning_by_codeset(17274,"CONCEPT",1,concept_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"INVALID",1,invalid_cd)
 SET prot_label = uar_i18ngetmessage(i18nlabel,"PROTOCOL_NAME","Protocol Name")
 SET curr_status_label = uar_i18ngetmessage(i18nlabel,"CURRENT_STATUS","Current Status")
 SET status_label = uar_i18ngetmessage(i18nlabel,"STATUS","Status")
 SET ip_label = uar_i18ngetmessage(i18nlabel,"INITIAL_PROT","Initial Protocol")
 SET amd_str_label = uar_i18ngetmessage(i18nlabel,"AMENDMENT","Amd")
 SET seperator = uar_i18ngetmessage(i18nlabel,"PROTAMD_SEPERATOR","-")
 SET rev_label = uar_i18ngetmessage(i18nlabel,"REVISION","Rev")
 SET any_prot = uar_i18ngetmessage(i18nlabel,"ANY_PROTOCOL","*Any Protocol")
 SET parameterarray[10] = fillstring(100," ")
 IF (findstring("^", $1) > 0)
  CALL getparameters( $1)
 ELSE
  SET parameterarray[1] =  $1
 ENDIF
 CASE (parameterarray[1])
  OF "GETPROTOCOLS":
   CALL getprotocols("")
  OF "GETAMENDMENTS":
   CALL getamendments(parameterarray[2])
 ENDCASE
 SUBROUTINE getprotocols(sparameters)
   CALL initreply(prot_label,curr_status_label)
   CALL addreply(any_prot,any_prot,"*|Any Protocol")
   SELECT INTO "nl:"
    FROM prot_master pm
    WHERE pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND  NOT (pm.prot_status_cd IN (concept_cd, invalid_cd))
    ORDER BY cnvtupper(pm.primary_mnemonic)
    DETAIL
     display = substring(1,40,pm.primary_mnemonic), desc = uar_get_code_display(pm.prot_status_cd),
     hidden_value = concat(trim(cnvtstring(pm.prot_master_id)),"|",pm.primary_mnemonic),
     CALL addreply(display,desc,hidden_value)
    WITH nocounter
   ;end select
   CALL closereply(0)
 END ;Subroutine
 SUBROUTINE getamendments(sparameters)
   SET amendment_label = uar_i18ngetmessage(i18nlabel,"AMENDMENT","Amendment")
   CALL initreply(amendment_label,status_label)
   RECORD args(
     1 count = i2
     1 items[*]
       2 value = vc
   )
   CALL parsearguments(parameterarray[2],"|",args)
   IF (size(args->items,5) > 1)
    SET display = concat("*",args->items[2].value)
   ENDIF
   IF ((args->items[1].value="*")
    AND (args->items[2].value="Any Protocol"))
    SET hidden_value = concat(args->items[1].value,"|","Any Protocol and Amendment")
    SET any_prot_ind = 1
   ELSE
    SET hidden_value = args->items[1].value
   ENDIF
   SET desc = concat(uar_i18ngetmessage(i18nlabel,"ALLAMDS","All Amendments for "),args->items[2].
    value)
   CALL addreply(display,desc,hidden_value)
   SET prot_master_id = cnvtreal(hidden_value)
   IF (any_prot_ind != 1)
    SELECT INTO "nl:"
     FROM prot_amendment pa,
      prot_master pm
     PLAN (pm
      WHERE pm.prot_master_id=prot_master_id
       AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (pa
      WHERE pa.prot_master_id=pm.prot_master_id
       AND (pa.amendment_nbr > - (1)))
     ORDER BY pa.amendment_nbr, pa.revision_seq
     DETAIL
      IF (pa.amendment_nbr=0)
       amd_str = ip_label
      ELSE
       amd_str = concat(amd_str_label," ",trim(cnvtstring(pa.amendment_nbr)))
      ENDIF
      IF (pa.revision_ind=1)
       display = concat(amd_str," ",seperator," ",rev_label,
        " ",trim(pa.revision_nbr_txt))
      ELSE
       display = amd_str
      ENDIF
      desc = uar_get_code_display(pa.amendment_status_cd), hidden_value = concat(trim(cnvtstring(
         prot_master_id)),"|",trim(cnvtstring(pa.prot_amendment_id))),
      CALL addreply(display,desc,hidden_value)
     WITH nocounter
    ;end select
   ENDIF
   CALL closereply(0)
   FREE RECORD args
 END ;Subroutine
 SUBROUTINE getparameters(stringparam)
   SET cur_param = 1
   SET param_end = 0
   SET parameter_cnt = 0
   WHILE (param_end < size(trim(stringparam)))
     SET param_start = (param_end+ 1)
     SET param_end = findstring("^",stringparam,param_start)
     IF (param_end=0)
      SET param_end = (size(trim(stringparam))+ 1)
     ENDIF
     SET parameterarray[cur_param] = substring(param_start,(param_end - param_start),stringparam)
     CALL echo(build("parameter:",parameterarray[cur_param]))
     SET cur_param = (cur_param+ 1)
   ENDWHILE
   SET parameter_cnt = (cur_param - 1)
 END ;Subroutine
 SUBROUTINE parsearguments(strvararg,strdelimiter,result)
   RECORD targuments(
     1 count = i2
     1 items[*]
       2 value = vc
   )
   SET del_start = 1
   SET del_end = size(trim(strvararg),1)
   SET delim = trim(strdelimiter)
   IF ( NOT (delim > ""))
    SET delim = "|"
   ENDIF
   SET targuments->count = 0
   SET stat = alterlist(targuments->items,25)
   WHILE (findstring(delim,strvararg,del_start) > 0
    AND (targuments->count <= 25))
     SET cut_to = findstring(delim,strvararg,del_start)
     SET cut_len = (cut_to - del_start)
     SET targuments->count = (targuments->count+ 1)
     SET targuments->items[targuments->count].value = substring(del_start,cut_len,strvararg)
     SET del_start = (cut_to+ 1)
   ENDWHILE
   CALL echo(build("args size:",targuments->count))
   SET cut_to = ((del_end - del_start)+ 1)
   SET targuments->count = (targuments->count+ 1)
   SET stat = alterlist(targuments->items,targuments->count)
   SET targuments->items[targuments->count].value = substring(del_start,cut_to,strvararg)
   SET stat = moverec(targuments,result)
   CALL echorecord(result)
   FREE RECORD targuments
 END ;Subroutine
 SUBROUTINE initreply(strcol1header,strcol2header)
  IF (size(trim(strcol1header)) > 0)
   SET treply->fieldname = replace(trim(strcol1header)," ","_",0)
   SET treply->opt_fieldname = replace(trim(strcol2header)," ","_",0)
  ELSE
   SET treply->fieldname = uar_i18ngetmessage(i18nlabel,"DISPLAY","DISPLAY")
   SET treply->opt_fieldname = ""
  ENDIF
  SET treply->cnt = 0
 END ;Subroutine
 SUBROUTINE addreply(strdisplay,strdescription,strhidden)
   SET treply->cnt = (treply->cnt+ 1)
   SET stat = alterlist(treply->qual,treply->cnt)
   SET treply->qual[treply->cnt].display = strdisplay
   SET treply->qual[treply->cnt].opt_desc = strdescription
   SET treply->qual[treply->cnt].hidden = strhidden
 END ;Subroutine
 SUBROUTINE closereply(bstandard)
   DECLARE sql = vc WITH notrim
   DECLARE sqlreply = vc WITH private, notrim
   DECLARE sqlselect = vc WITH private, notrim
   SET reply->cnt = 0
   IF (bstandard=false)
    SET sqlselect = concat('select into "NL:"  ',trim(treply->fieldname),
     " = SubString(1, 1024, tReply->qual[d.seq].display), ",
     "_HIDDEN_PAR = SubString(1, 1024, tReply->qual[d.seq].hidden) ")
    IF ((treply->opt_fieldname > " "))
     SET sqlselect = concat(sqlselect,", ",trim(treply->opt_fieldname),
      "= SubString(1, 1024, tReply->qual[d.seq].opt_desc) ")
    ENDIF
   ELSE
    SET sqlselect = concat('select into "NL:"  ',trim(treply->fieldname),
     " = SubString(1, 256, tReply->qual[d.seq].display), ",' _hidden = " " ')
    IF ((treply->opt_fieldname > " "))
     SET sqlselect = concat(sqlselect,", ",trim(treply->opt_fieldname),
      "= SubString(1, 256, tReply->qual[d.seq].opt_desc) ")
    ENDIF
   ENDIF
   SET sqlreply = concat("from (dummyt d with seq = Value(tReply->cnt)) /**/",
    " where tReply->qual[d.seq].display > ' ' ",
    " order by CnvtUpper(Trim(tReply->qual[d.seq].display)) "," head report ",
    "stat = alterlist(reply->qual,reply->cnt + 50) ",
    "stat = 0 ",'reply->fieldname = concat(reportinfo(1),"^") ',
    "reply->fieldsize = size(reply->fieldname) ","detail ","reply->cnt = reply->cnt + 1 ",
    "if(mod(reply->cnt,50) = 1) ","stat = alterlist(reply->qual,reply->cnt + 50) ","endif ",
    'reply->qual[reply->cnt].result = concat(Trim(reportinfo(2)),"^") ',"foot report ",
    "stat = alterlist(reply->qual,reply->cnt) ","with maxrow = 1, reporthelp, check go ")
   SET sql = concat(sqlselect,sqlreply)
   CALL parser(sql,1)
   IF ((reply->cnt=0))
    SET label = uar_i18ngetmessage(i18nlabel,"NO_ITEMS","No items found")
    CALL helperror(label)
   ENDIF
   SET treply->cnt = 0
   SET stat = alterlist(treply->qual,0)
   FREE RECORD treply
 END ;Subroutine
 SUBROUTINE helperror(errmsgx)
  SET strtext = errmsgx
  SELECT DISTINCT INTO "NL:"
   error_message = strtext, _hidden = d1.seq
   FROM (dummyt d1  WITH seq = 1)
   PLAN (d1)
   ORDER BY d1.seq
   HEAD REPORT
    stat = 0, reply->cnt = 0, reply->fieldname = concat(reportinfo(1),"^"),
    reply->fieldsize = size(reply->fieldname)
   DETAIL
    reply->cnt = (reply->cnt+ 1)
    IF (mod(reply->cnt,50)=1)
     stat = alterlist(reply->qual,(reply->cnt+ 50))
    ENDIF
    reply->qual[reply->cnt].result = concat(reportinfo(2),"^")
   FOOT REPORT
    stat = alterlist(reply->qual,reply->cnt)
   WITH maxrow = 1, reporthelp, check
  ;end select
 END ;Subroutine
 SUBROUTINE writeexitmessage(wemekmmessage)
   SET eksdata->tqual[tinx].qual[curindex].logging = wemekmmessage
   IF (berror)
    SET retval = false
    CALL writemessage("Error status, returning FALSE to EKS")
   ENDIF
   SET retval = (bresult * 100)
   CALL writemessage(wemekmmessage)
   CALL writemessage(concat("**** ",format(curdate,"MM/DD/YYYY;;d")," ",format(curtime,"hh:mm:ss;;m")
     ))
   CALL writemessage(concat("******** END OF ",trim(tname)," ***********"))
 END ;Subroutine
 SUBROUTINE writemessage(wmekmlogmessage)
   IF (wmekmlogmessage > "")
    SET len = size(trim(wmekmlogmessage))
    SET pos = 1
    IF (len > 130)
     WHILE (((len - pos) <= 130))
      CALL printstring(substring(pos,130,wmekmlogmessage))
      SET pos = (pos+ 130)
     ENDWHILE
    ELSE
     CALL printstring(wmekmlogmessage)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE printstring(lpstring)
   IF (substring((size(trim(lpstring)) - 2),3,lpstring)="...")
    CALL echo(substring(1,(size(trim(lpstring)) - 3),lpstring),0)
   ELSE
    CALL echo(lpstring)
   ENDIF
 END ;Subroutine
 SET last_mod = "004"
 SET mod_date = "December 29, 2014"
END GO
