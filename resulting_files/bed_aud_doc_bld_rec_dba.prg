CREATE PROGRAM bed_aud_doc_bld_rec:dba
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
 RECORD temp(
   1 vlist[*]
     2 view_name = vc
     2 prim_event_cnt = f8
 )
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 EXECUTE prefrtl
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Recommendation"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Grade"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET rcnt = 1
 SET stat = alterlist(reply->statlist,rcnt)
 SET stat = alterlist(reply->rowlist,rcnt)
 FOR (rcnt = 1 TO 1)
   SET stat = alterlist(reply->rowlist[rcnt].celllist,2)
 ENDFOR
 SET reply->run_status_flag = 1
 SET reply->rowlist[1].celllist[1].string_value = concat(
  "All flowsheets have the same setting of chronological",
  " or reverse chronological order, not a mixture.")
 SET reply->rowlist[1].celllist[2].string_value = "Pass"
 SET reply->statlist[1].statistic_meaning = "DOCBRFLOWSHEETSAMEORDER"
 SET reply->statlist[1].total_items = 0
 SET reply->statlist[1].qualifying_items = 0
 SET reply->statlist[1].status_flag = 1
 SET sort_order = " "
 SET order_ok = "Y"
 SELECT INTO "nl:"
  FROM name_value_prefs n
  PLAN (n
   WHERE n.pvc_name IN ("R_TIME_SORT", "MAR_TIME_SORT", "MAR_SUMMARY_TIME_SORT"))
  DETAIL
   IF (sort_order=" ")
    IF (n.pvc_value="1")
     sort_order = "R"
    ELSE
     sort_order = "C"
    ENDIF
   ELSEIF (sort_order="C"
    AND n.pvc_value="1")
    order_ok = "N"
   ELSEIF (n.pvc_value != "1")
    order_ok = "N"
   ENDIF
  WITH nocounter
 ;end select
 IF (order_ok="Y")
  SET sort_value = 0
  SET hpref = uar_prefcreateinstance(18)
  SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
  SET stat = uar_prefaddattr(hpref,"prefvalue")
  SET stat = uar_prefaddattr(hpref,"prefcontext")
  SET stat = uar_prefaddfilter(hpref,"prefentry=chrono_time_sort")
  SET stat = uar_prefperform(hpref)
  DECLARE count = i4
  SET stat = uar_prefgetentrycount(hpref,count)
  SET i = 0
  DECLARE dnstr = c255 WITH noconstant("")
  SET strlen = 255
  FOR (x = 0 TO (count - 1))
    SET hentry = uar_prefgetentry(hpref,x)
    SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
    SET i = findstring("prefcontext=reference",dnstr)
    IF (i=0)
     SET acnt = 0
     SET stat = uar_prefgetentryattrcount(hentry,acnt)
     FOR (y = 0 TO (acnt - 1))
       SET hattr = uar_prefgetentryattr(hentry,y)
       SET valcnt = 0
       DECLARE xvalue = c255 WITH noconstant("")
       SET stat = uar_prefgetattrval(hattr,xvalue,255,0)
       CALL echo(build("value:",xvalue))
       SET sort_value = cnvtint(trim(xvalue))
       IF (sort_order=" ")
        IF (sort_value=0)
         SET sort_order = "R"
        ELSE
         SET sort_order = "C"
        ENDIF
       ELSEIF (sort_order="C"
        AND sort_value=0)
        SET order_ok = "N"
       ELSEIF (sort_value != 1)
        SET order_ok = "N"
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  CALL uar_prefdestroyinstance(hpref)
 ENDIF
 IF (order_ok="N")
  SET reply->rowlist[1].celllist[2].string_value = "Fail"
  SET reply->statlist[1].status_flag = 3
  SET reply->run_status_flag = 3
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("doc_build_rec_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
