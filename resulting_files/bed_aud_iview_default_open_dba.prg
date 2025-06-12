CREATE PROGRAM bed_aud_iview_default_open:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 tqual[*]
     2 view_name = vc
     2 view_display = vc
     2 level_type = vc
     2 details = vc
     2 section_name = vc
     2 section_display = vc
 )
 FREE RECORD sort_temp
 RECORD sort_temp(
   1 tqual[*]
     2 view_name = vc
     2 view_display = vc
     2 level_type = vc
     2 details = vc
     2 section_name = vc
     2 section_display = vc
 )
 EXECUTE prefrtl
 DECLARE hpref = i4 WITH noconstant(0)
 SET tcnt = 0
 DECLARE count = i4
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE cxtstr = c255 WITH noconstant("")
 DECLARE viewstr = c255 WITH noconstant("")
 DECLARE posstr = c40 WITH noconstant("")
 DECLARE locstr = c40 WITH noconstant("")
 DECLARE pos_cd = f8 WITH noconstant(0.0), protected
 DECLARE loc_cd = f8 WITH noconstant(0.0), protected
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=default,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=default_open")
 SET stat = uar_prefperform(hpref)
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 SET strlen = 255
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET a = findstring("prefcontext=",dnstr,1)
   SET b = findstring("=",dnstr,a)
   SET c = findstring(",",dnstr,(b+ 1))
   SET cxtstr = substring((b+ 1),((c - b) - 1),dnstr)
   SET a = findstring("prefgroup=",dnstr,1)
   SET b = findstring("=",dnstr,a)
   SET c = findstring(",",dnstr,a)
   SET viewstr = substring((b+ 1),((c - b) - 1),dnstr)
   SET acnt = 0
   SET stat = uar_prefgetentryattrcount(hentry,acnt)
   FOR (y = 0 TO (acnt - 1))
     SET hattr = uar_prefgetentryattr(hentry,y)
     SET valcnt = 0
     SET stat = uar_prefgetattrvalcount(hattr,valcnt)
     FOR (z = 0 TO (valcnt - 1))
       DECLARE xvalue = c255 WITH noconstant("")
       SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
       IF (xvalue != "0")
        SET tcnt = (tcnt+ 1)
        SET stat = alterlist(temp->tqual,tcnt)
        SET temp->tqual[tcnt].view_name = trim(viewstr)
        SET temp->tqual[tcnt].section_name = trim(xvalue)
        SET temp->tqual[tcnt].level_type = "1"
        SET temp->tqual[tcnt].details = "default"
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=position,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=default_open")
 SET stat = uar_prefperform(hpref)
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 SET strlen = 255
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET a = findstring("prefgroup=",dnstr,1,1)
   SET b = findstring("=",dnstr,a)
   SET c = findstring(",",dnstr,a)
   SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
   SET a = findstring("prefcontext=",dnstr,1)
   SET b = findstring("=",dnstr,a)
   SET c = findstring(",",dnstr,(b+ 1))
   SET cxtstr = substring((b+ 1),((c - b) - 1),dnstr)
   SET a = findstring("prefgroup=",dnstr,1)
   SET b = findstring("=",dnstr,a)
   SET c = findstring(",",dnstr,a)
   SET viewstr = substring((b+ 1),((c - b) - 1),dnstr)
   SET acnt = 0
   SET stat = uar_prefgetentryattrcount(hentry,acnt)
   FOR (y = 0 TO (acnt - 1))
     SET hattr = uar_prefgetentryattr(hentry,y)
     SET valcnt = 0
     SET stat = uar_prefgetattrvalcount(hattr,valcnt)
     FOR (z = 0 TO (valcnt - 1))
       DECLARE xvalue = c255 WITH noconstant("")
       SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
       IF (xvalue != "0")
        SET tcnt = (tcnt+ 1)
        SET stat = alterlist(temp->tqual,tcnt)
        SET temp->tqual[tcnt].view_name = trim(viewstr)
        SET temp->tqual[tcnt].section_name = trim(xvalue)
        SET temp->tqual[tcnt].level_type = "2"
        SET pos_cd = cnvtreal(grpstr)
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          temp->tqual[tcnt].details = trim(c.display)
         WITH nocounter
        ;end select
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=position location,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=default_open")
 SET stat = uar_prefperform(hpref)
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 SET strlen = 255
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET a = findstring("prefgroup=",dnstr,1,1)
   SET b = findstring("=",dnstr,a)
   SET c = findstring(",",dnstr,a)
   SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
   SET a = findstring("prefcontext=",dnstr,1)
   SET b = findstring("=",dnstr,a)
   SET c = findstring(",",dnstr,(b+ 1))
   SET cxtstr = substring((b+ 1),((c - b) - 1),dnstr)
   SET a = findstring("prefgroup=",dnstr,1)
   SET b = findstring("=",dnstr,a)
   SET c = findstring(",",dnstr,a)
   SET viewstr = substring((b+ 1),((c - b) - 1),dnstr)
   SET acnt = 0
   SET stat = uar_prefgetentryattrcount(hentry,acnt)
   FOR (y = 0 TO (acnt - 1))
     SET hattr = uar_prefgetentryattr(hentry,y)
     SET valcnt = 0
     SET stat = uar_prefgetattrvalcount(hattr,valcnt)
     FOR (z = 0 TO (valcnt - 1))
       DECLARE xvalue = c255 WITH noconstant("")
       SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
       IF (xvalue != "0")
        SET tcnt = (tcnt+ 1)
        SET stat = alterlist(temp->tqual,tcnt)
        SET temp->tqual[tcnt].view_name = trim(viewstr)
        SET temp->tqual[tcnt].section_name = trim(xvalue)
        SET temp->tqual[tcnt].level_type = "3"
        SET a = findstring("^",grpstr)
        SET pos_cd = cnvtreal(substring(1,(a - 1),grpstr))
        SET b = textlen(grpstr)
        SET loc_cd = cnvtreal(substring((a+ 1),((b - a) - 1),grpstr))
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          posstr = c.display
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=loc_cd)
         DETAIL
          locstr = c.display
         WITH nocounter
        ;end select
        SET temp->tqual[tcnt].details = concat(trim(posstr),"/",trim(locstr))
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "View Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "View Display"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Level at which the preference exists"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Details"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Section Name"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Section Display"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt),
   working_view wv
  PLAN (d)
   JOIN (wv
   WHERE cnvtupper(wv.display_name)=cnvtupper(temp->tqual[d.seq].view_name))
  DETAIL
   temp->tqual[d.seq].view_display = wv.display_name
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt),
   v500_event_set_code esc
  PLAN (d)
   JOIN (esc
   WHERE esc.event_set_name_key=cnvtalphanum(cnvtupper(temp->tqual[d.seq].section_name)))
  DETAIL
   temp->tqual[d.seq].section_display = esc.event_set_cd_disp
  WITH nocounter
 ;end select
 SET stat = alterlist(sort_temp->tqual,tcnt)
 SET sort_cnt = 0
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt)
  PLAN (d)
  ORDER BY temp->tqual[d.seq].view_name, temp->tqual[d.seq].level_type, temp->tqual[d.seq].details,
   temp->tqual[d.seq].section_name
  DETAIL
   sort_cnt = (sort_cnt+ 1), sort_temp->tqual[sort_cnt].view_name = temp->tqual[d.seq].view_name,
   sort_temp->tqual[sort_cnt].view_display = temp->tqual[d.seq].view_display,
   sort_temp->tqual[sort_cnt].level_type = temp->tqual[d.seq].level_type, sort_temp->tqual[sort_cnt].
   details = temp->tqual[d.seq].details, sort_temp->tqual[sort_cnt].section_name = temp->tqual[d.seq]
   .section_name,
   sort_temp->tqual[sort_cnt].section_display = temp->tqual[d.seq].section_display
  WITH nocounter
 ;end select
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,6)
   SET reply->rowlist[row_nbr].celllist[1].string_value = sort_temp->tqual[x].view_name
   SET reply->rowlist[row_nbr].celllist[2].string_value = sort_temp->tqual[x].view_display
   IF ((sort_temp->tqual[x].level_type="1"))
    SET reply->rowlist[row_nbr].celllist[3].string_value = "default"
   ELSEIF ((sort_temp->tqual[x].level_type="2"))
    SET reply->rowlist[row_nbr].celllist[3].string_value = "position"
   ELSEIF ((sort_temp->tqual[x].level_type="3"))
    SET reply->rowlist[row_nbr].celllist[3].string_value = "position location"
   ENDIF
   IF ((sort_temp->tqual[x].level_type="1"))
    SET reply->rowlist[row_nbr].celllist[4].string_value = " "
   ELSE
    SET reply->rowlist[row_nbr].celllist[4].string_value = sort_temp->tqual[x].details
   ENDIF
   SET reply->rowlist[row_nbr].celllist[5].string_value = sort_temp->tqual[x].section_name
   SET reply->rowlist[row_nbr].celllist[6].string_value = sort_temp->tqual[x].section_display
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("iview_sections_open_by_default.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
