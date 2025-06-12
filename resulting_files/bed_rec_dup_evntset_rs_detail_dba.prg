CREATE PROGRAM bed_rec_dup_evntset_rs_detail:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 paramlist[*]
      2 meaning = vc
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 res_collist[*]
      2 header_text = vc
    1 res_rowlist[*]
      2 res_celllist[*]
        3 cell_text = vc
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 tqual[*]
     2 event_set_name = vc
 )
 FREE RECORD dups
 RECORD dups(
   1 event_sets[*]
     2 code_value = f8
     2 level = i4
 )
 FREE RECORD dups2
 RECORD dups2(
   1 event_sets[*]
     2 code_value = f8
 )
 FREE RECORD fin_dups
 RECORD fin_dups(
   1 event_sets[*]
     2 code_value = f8
 )
 DECLARE all_results_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM v500_event_set_code vsc
  WHERE vsc.event_set_name="ALL RESULT SECTIONS"
  DETAIL
   all_results_cd = vsc.event_set_cd
  WITH nocounter
 ;end select
 SET plsize = size(request->paramlist,5)
 SET stat = alterlist(reply->res_collist,2)
 SET reply->res_collist[1].header_text = "Check Name"
 SET reply->res_collist[2].header_text = "Resolution"
 SET stat = alterlist(reply->res_rowlist,plsize)
 FOR (p = 1 TO plsize)
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE (b.rec_mean=request->paramlist[p].meaning))
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     stat = alterlist(reply->res_rowlist[p].res_celllist,2), reply->res_rowlist[p].res_celllist[1].
     cell_text = b.short_desc, reply->res_rowlist[p].res_celllist[2].cell_text = bl2.long_text
    WITH nocounter
   ;end select
 ENDFOR
 SET col_cnt = 1
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Event Set Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="DUPEVENTSETINALLRES"))
    SET ecnt = 0
    SET ecnt2 = 0
    SELECT INTO "nl:"
     FROM v500_event_set_canon c
     PLAN (c
      WHERE c.parent_event_set_cd=all_results_cd)
     ORDER BY c.event_set_cd
     HEAD c.event_set_cd
      ecnt = (ecnt+ 1), stat = alterlist(dups->event_sets,ecnt), dups->event_sets[ecnt].code_value =
      c.event_set_cd,
      dups->event_sets[ecnt].level = 1
     WITH nocounter
    ;end select
    SET temp_level = 1
    SET found_ind = 1
    SET tcnt = 0
    IF (ecnt > 0)
     WHILE (found_ind=1)
      SET found_ind = 0
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(ecnt)),
        v500_event_set_canon c
       PLAN (d
        WHERE (dups->event_sets[d.seq].level=temp_level))
        JOIN (c
        WHERE (c.parent_event_set_cd=dups->event_sets[d.seq].code_value))
       ORDER BY c.parent_event_set_cd
       DETAIL
        ecnt = (ecnt+ 1), stat = alterlist(dups->event_sets,ecnt), dups->event_sets[ecnt].code_value
         = c.event_set_cd,
        dups->event_sets[ecnt].level = (temp_level+ 1)
       FOOT REPORT
        temp_level = (temp_level+ 1), found_ind = 1
       WITH nocounter
      ;end select
     ENDWHILE
     SET fincount = 0
     SET ecnt3 = 0
     SELECT INTO "nl:"
      c = dups->event_sets[d.seq].code_value
      FROM (dummyt d  WITH seq = value(ecnt))
      PLAN (d)
      ORDER BY c
      HEAD c
       cnt = 0
      DETAIL
       cnt = (cnt+ 1)
       IF (cnt=2)
        ecnt3 = (ecnt3+ 1), stat = alterlist(fin_dups->event_sets,ecnt3), fin_dups->event_sets[ecnt3]
        .code_value = c
       ENDIF
      WITH nocounter
     ;end select
     IF (ecnt3 > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = ecnt3),
        code_value cv
       PLAN (d)
        JOIN (cv
        WHERE (cv.code_value=fin_dups->event_sets[d.seq].code_value)
         AND  EXISTS (
        (SELECT
         e.event_set_cd
         FROM v500_event_set_explode e
         WHERE e.event_set_cd=cv.code_value
          AND e.event_set_level=0)))
       ORDER BY cv.display_key
       DETAIL
        tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].event_set_name = cv
        .display
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    SET row_nbr = 0
    FOR (x = 1 TO tcnt)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,col_cnt)
      SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].event_set_name
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 CALL echorecord(reply)
END GO
