CREATE PROGRAM cr_get_route_info:dba
 RECORD reply(
   1 file_name = vc
   1 qual[*]
     2 line = c132
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD report_writer
 RECORD report_writer(
   1 qual[*]
     2 route_name = vc
     2 route_type_flag = i2
     2 chart_route_id = f8
     2 useme = i2
     2 group[*]
       3 group_name = vc
       3 sequence_group_id = f8
       3 locs[*]
         4 locsorperson = vc
     2 dists[*]
       3 dist_name = vc
 )
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 charting_op_id = f8
     2 dist_id = f8
 )
#initialize
 DECLARE loginname = vc
 DECLARE prsnl_type_cd = f8
 DECLARE count = i4
 DECLARE count2 = i4
 DECLARE tempstr = vc
 DECLARE tempstr2 = vc
 DECLARE tempstr3 = vc
 DECLARE tempval = i4
 DECLARE x = i2
 DECLARE amountleft = i4
 DECLARE where_clause = vc
 DECLARE use_clause = vc
 DECLARE errorhold = i2
 DECLARE error_code = i4
 DECLARE errmsg = vc
 DECLARE currentdate = c8
 DECLARE currenttime = c5
 DECLARE req_nbr = i4
 DECLARE outfile = vc
 DECLARE date = vc
 SET date = format(cnvtdatetime(curdate,curtime3),"MMDDHHMMSS;;D")
 SET outfile = concat("ccluserdir:Dlog",date,".log")
 SET reply->file_name = outfile
 DECLARE after_route = i2 WITH constant(21)
 DECLARE group_start = i2 WITH constant(5)
 DECLARE after_group = i2 WITH constant(17)
 DECLARE loc_start = i2 WITH constant(9)
 DECLARE after_loc = i2 WITH constant(20)
 DECLARE login_start = i2 WITH constant(57)
 DECLARE dist_start = i2 WITH constant(5)
 DECLARE after_dist = i2 WITH constant(9)
 DECLARE after_dist_none = i2 WITH constant(32)
 DECLARE colonhold = vc WITH constant(": ")
 DECLARE numcols = i2 WITH constant(80)
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
 DECLARE h = i4
 DECLARE i18nhandle = i4 WITH noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET stat = uar_get_meaning_by_codeset(213,"PRSNL",1,prsnl_type_cd)
 SET currentdate = format(curdate,"@SHORTDATE")
 SET currenttime = format(curtime3,"@TIMENOSECONDS")
 SET errorhold = 0
 SELECT INTO "nl:"
  p.username, p.person_id
  FROM prsnl p,
   person_name pn
  PLAN (p
   WHERE p.username=trim(request->username))
   JOIN (pn
   WHERE pn.person_id=outerjoin(p.person_id)
    AND pn.active_ind=outerjoin(1)
    AND pn.name_type_cd=outerjoin(prsnl_type_cd))
  DETAIL
   IF (trim(pn.name_full) != "")
    loginname = pn.name_full
   ELSE
    loginname = p.name_full_formatted
   ENDIF
  WITH maxqual(p,1)
 ;end select
 IF (curqual=0)
  SET loginname = uar_i18ngetmessage(i18nhandle,"CHARTSRV","Chart Server")
 ENDIF
 IF ((((request->chart_route_id > 0)) OR ((((request->route_type_flag > 0)) OR ((request->
 sequence_group_id > 0))) )) )
  IF ((request->chart_route_id > 0))
   SET where_clause = build("cr.chart_route_id = ",request->chart_route_id)
  ELSE
   SET where_clause = "0=0"
  ENDIF
  IF ((request->route_type_flag > 0))
   SET where_clause = build(where_clause," and cr.route_type_flag = ",request->route_type_flag)
  ELSE
   SET where_clause = build(where_clause," and 0=0")
  ENDIF
  SET count = 0
  SELECT INTO "nl:"
   cr.route_type_flag, cr.route_name, cr.chart_route_id
   FROM chart_route cr
   WHERE parser(where_clause)
    AND cr.active_ind=1
   ORDER BY cr.route_name
   DETAIL
    count = (count+ 1)
    IF (count > size(report_writer->qual,5))
     stat = alterlist(report_writer->qual,(count+ 9))
    ENDIF
    report_writer->qual[count].route_type_flag = cr.route_type_flag, report_writer->qual[count].
    route_name = cr.route_name, report_writer->qual[count].chart_route_id = cr.chart_route_id,
    report_writer->qual[count].useme = 1
   FOOT REPORT
    stat = alterlist(report_writer->qual,count)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET errorhold = 1
   GO TO exit_script
  ENDIF
  IF ((request->sequence_group_id > 0))
   SET where_clause = build("csg.sequence_group_id = ",request->sequence_group_id)
  ELSE
   SET where_clause = "0=0"
  ENDIF
  FOR (i = 1 TO size(report_writer->qual,5))
    SET count = 0
    SET use_clause = build(where_clause," and csg.chart_route_id = ",report_writer->qual[i].
     chart_route_id)
    SELECT INTO "nl:"
     csg.group_name, csg.sequence_group_id
     FROM chart_sequence_group csg
     WHERE parser(use_clause)
      AND csg.active_ind=1
     ORDER BY csg.sequence_nbr
     DETAIL
      count = (count+ 1)
      IF (count > size(report_writer->qual[i].group,5))
       stat = alterlist(report_writer->qual[i].group,(count+ 9))
      ENDIF
      report_writer->qual[i].group[count].group_name = csg.group_name, report_writer->qual[i].group[
      count].sequence_group_id = csg.sequence_group_id
     FOOT REPORT
      stat = alterlist(report_writer->qual[i].group,count)
     WITH nocounter
    ;end select
    IF (curqual=0
     AND (request->chart_route_id < 1))
     SET report_writer->qual[i].useme = 0
    ENDIF
    IF ((request->distribution_id < 1))
     SET count = 0
     SELECT DISTINCT INTO "nl:"
      co.charting_operations_id, co.param
      FROM charting_operations co
      WHERE co.param_type_flag=21
       AND co.active_ind=1
       AND trim(co.param)=trim(cnvtstring(report_writer->qual[i].chart_route_id))
      ORDER BY co.charting_operations_id
      DETAIL
       count = (count+ 1)
       IF (count > size(temp->qual,5))
        stat = alterlist(temp->qual,(count+ 9))
       ENDIF
       temp->qual[count].charting_op_id = co.charting_operations_id
      FOOT REPORT
       stat = alterlist(temp->qual,count)
      WITH nocounter
     ;end select
     IF (curqual > 0)
      FOR (j = 1 TO size(temp->qual,5))
        SELECT DISTINCT INTO "nl:"
         co.param
         FROM charting_operations co
         WHERE co.param_type_flag=2
          AND co.active_ind=1
          AND (co.charting_operations_id=temp->qual[j].charting_op_id)
         DETAIL
          temp->qual[j].dist_id = cnvtreal(co.param)
         WITH nocounter
        ;end select
      ENDFOR
      SET stat = alterlist(report_writer->qual[i].dists,size(temp->qual,5))
      FOR (j = 1 TO size(temp->qual,5))
        SELECT DISTINCT INTO "nl:"
         cd.dist_descr
         FROM chart_distribution cd
         WHERE (cd.distribution_id=temp->qual[j].dist_id)
          AND cd.active_ind=1
         DETAIL
          report_writer->qual[i].dists[j].dist_name = cd.dist_descr
         WITH nocounter
        ;end select
      ENDFOR
     ENDIF
    ELSE
     SET stat = alterlist(report_writer->qual[i].dists,1)
     SELECT DISTINCT INTO "nl:"
      cd.dist_descr
      FROM chart_distribution cd
      WHERE (cd.distribution_id=request->distribution_id)
       AND cd.active_ind=1
      DETAIL
       report_writer->qual[i].dists[1].dist_name = cd.dist_descr
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
  FOR (i = 1 TO size(report_writer->qual,5))
    FOR (j = 1 TO size(report_writer->qual[i].group,5))
     SET count = 0
     IF ((report_writer->qual[i].route_type_flag=3))
      SELECT INTO "nl:"
       csgr.location_cd
       FROM chart_seq_group_reltn csgr
       WHERE (csgr.sequence_group_id=report_writer->qual[i].group[j].sequence_group_id)
        AND csgr.active_ind=1
       ORDER BY csgr.sequence_nbr
       DETAIL
        count = (count+ 1)
        IF (count > size(report_writer->qual[i].group[j].locs,5))
         stat = alterlist(report_writer->qual[i].group[j].locs,(count+ 9))
        ENDIF
        report_writer->qual[i].group[j].locs[count].locsorperson = uar_get_code_display(csgr
         .location_cd)
       FOOT REPORT
        stat = alterlist(report_writer->qual[i].group[j].locs,count)
       WITH nocounter
      ;end select
     ELSEIF ((report_writer->qual[i].route_type_flag=1))
      SELECT INTO "nl:"
       p.name_full_formatted
       FROM chart_seq_group_reltn csgr,
        prsnl p
       PLAN (csgr
        WHERE (csgr.sequence_group_id=report_writer->qual[i].group[j].sequence_group_id)
         AND csgr.active_ind=1)
        JOIN (p
        WHERE csgr.prsnl_id=p.person_id)
       ORDER BY csgr.sequence_nbr
       DETAIL
        count = (count+ 1)
        IF (count > size(report_writer->qual[i].group[j].locs,5))
         stat = alterlist(report_writer->qual[i].group[j].locs,(count+ 9))
        ENDIF
        report_writer->qual[i].group[j].locs[count].locsorperson = p.name_full_formatted
       FOOT REPORT
        stat = alterlist(report_writer->qual[i].group[j].locs,count)
       WITH nocounter
      ;end select
     ELSE
      SET errorhold = 1
     ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SET req_nbr = size(report_writer->qual,5)
 SELECT INTO value(outfile)
  FROM (dummyt d  WITH seq = value(req_nbr))
  HEAD REPORT
   line_s = fillstring(80,"-"), row + 1
   IF ((report_writer->qual[1].route_type_flag=1))
    tempstr2 = uar_i18ngetmessage(i18nhandle,"PRONAME","Provider")
   ELSEIF ((report_writer->qual[1].route_type_flag=3))
    tempstr2 = uar_i18ngetmessage(i18nhandle,"LOCNAME","Location")
   ELSE
    tempstr2 = uar_i18ngetmessage(i18nhandle,"UNKNOWN","Unknown")
   ENDIF
   tempstr = uar_i18ngetmessage(i18nhandle,"RPTHEAD2","Routing Type:  "), col 25, tempstr,
   col 39, tempstr2, row + 2,
   tempstr = uar_i18ngetmessage(i18nhandle,"RPTPRINT","Printed: "), col 0, tempstr,
   col 9, currentdate, col 18,
   currenttime, tempstr = uar_i18ngetmessage(i18nhandle,"RPTPRINTBY","Printed by: "), col 45,
   tempstr, tempval = size(trim(loginname),1)
   IF (tempval <= 29)
    col login_start, loginname
   ELSE
    tempstr = substring(1,26,loginname), tempstr = concat(tempstr,"..."), col login_start,
    tempstr
   ENDIF
   row + 1, line_s, row + 1,
   line_s, row + 1
  DETAIL
   IF ((request->chart_route_id < 1)
    AND (request->route_type_flag < 1)
    AND (request->sequence_group_id < 1))
    tempstr = uar_i18ngetmessage(i18nhandle,"NOREPORT",
     "Additional charts qualified for distributions"), tempstr2 = uar_i18ngetmessage(i18nhandle,
     "NOREPORT2"," but not included in defined route."), col 18,
    tempstr, row + 1, col 23,
    tempstr2
   ELSE
    IF ((report_writer->qual[d.seq].useme > 0))
     IF ((report_writer->qual[d.seq].route_type_flag=1))
      tempstr2 = uar_i18ngetmessage(i18nhandle,"PRONAME2","Provider")
     ELSEIF ((report_writer->qual[d.seq].route_type_flag=3))
      tempstr2 = uar_i18ngetmessage(i18nhandle,"LOCNAME2","Location")
     ELSE
      tempstr2 = uar_i18ngetmessage(i18nhandle,"UNKNOWN2","Unknown")
     ENDIF
     tempstr = uar_i18ngetmessage(i18nhandle,"LOCRTNAME"," Route Name: "), col 0, tempstr2,
     col 8, tempstr, amountleft = (numcols - after_route),
     tempstr = build(trim(report_writer->qual[d.seq].route_name)," (",trim(cnvtstring(report_writer->
        qual[d.seq].chart_route_id),3),")"), tempval = size(tempstr,1), x = 1
     WHILE (tempval >= amountleft)
       tempstr3 = substring(x,amountleft,tempstr), col after_route, tempstr3,
       tempval = (tempval - amountleft), x = (x+ amountleft), row + 1
     ENDWHILE
     tempstr3 = substring(x,amountleft,tempstr), col after_route, tempstr3,
     row + 1
     FOR (i = 1 TO size(report_writer->qual[d.seq].group,5))
       tempstr = uar_i18ngetmessage(i18nhandle,"GRPNAME","Route Stop: "), col group_start, tempstr,
       amountleft = (numcols - after_group), tempstr = build(trim(report_writer->qual[d.seq].group[i]
         .group_name)," (",trim(cnvtstring(report_writer->qual[d.seq].group[i].sequence_group_id),3),
        ")"), tempval = size(tempstr,1),
       x = 1
       WHILE (tempval >= amountleft)
         tempstr3 = substring(x,amountleft,tempstr), col after_group, tempstr3,
         tempval = (tempval - amountleft), x = (x+ amountleft), row + 1
       ENDWHILE
       tempstr3 = substring(x,amountleft,tempstr), col after_group, tempstr3,
       row + 1
       FOR (j = 1 TO size(report_writer->qual[d.seq].group[i].locs,5))
         col loc_start, tempstr2, colonhold,
         amountleft = (numcols - after_loc), tempstr = report_writer->qual[d.seq].group[i].locs[j].
         locsorperson, tempval = size(tempstr,1),
         x = 1
         WHILE (tempval >= amountleft)
           tempstr3 = substring(x,amountleft,tempstr), col after_loc, tempstr3,
           tempval = (tempval - amountleft), x = (x+ amountleft), row + 1
         ENDWHILE
         tempstr3 = substring(x,amountleft,tempstr), col after_loc, tempstr3,
         row + 1
       ENDFOR
     ENDFOR
     IF ((request->distribution_id < 1))
      tempstr = uar_i18ngetmessage(i18nhandle,"ASSOCDIST","Associated Distributions: "), col
      dist_start, tempstr
      IF (size(report_writer->qual[d.seq].dists,5) > 0)
       FOR (i = 1 TO size(report_writer->qual[d.seq].dists,5))
         row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"DISTRIB","Distribution"), col after_dist,
         tempstr, colonhold, amountleft = (numcols - after_loc),
         tempstr = report_writer->qual[d.seq].dists[i].dist_name, tempval = size(tempstr,1), x = 1
         WHILE (tempval >= amountleft)
           tempstr3 = substring(x,amountleft,tempstr), col after_dist, tempstr3,
           tempval = (tempval - amountleft), x = (x+ amountleft), row + 1
         ENDWHILE
         tempstr3 = substring(x,amountleft,tempstr), col after_dist, tempstr3,
         row + 1
       ENDFOR
      ELSE
       tempstr = uar_i18ngetmessage(i18nhandle,"NONE","None"), col after_dist_none, tempstr
      ENDIF
      row + 1
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FREE DEFINE rtl
 DEFINE rtl value(outfile)
 SELECT INTO "nl:"
  r.line
  FROM rtlt r
  HEAD REPORT
   count2 = 0
  DETAIL
   count2 = (count2+ 1), stat = alterlist(reply->qual,count2), reply->qual[count2].line = r.line
  WITH nocounter
 ;end select
 FOR (i = 1 TO size(reply->qual,5))
   CALL echo(reply->qual[i].line)
 ENDFOR
 IF (curqual=0)
  SET errorhold = 1
 ENDIF
#exit_script
 SET error_code = error(errmsg,0)
 IF (((error_code != 0) OR (errorhold != 0)) )
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
