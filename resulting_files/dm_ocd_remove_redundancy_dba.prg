CREATE PROGRAM dm_ocd_remove_redundancy:dba
 SET redundancy_rpt_file = "dm_ocd_redundancy_rpt.log"
 SET max_dsize = 0
 SET maxcolsize = 132
 SET header_str = fillstring(80,"-")
 DECLARE disp_text("Display text ...",cnt) = null
 DECLARE determine_redundancy(src_env_name,trg_env_name,src_cnt) = null
 CALL determine_redundancy(doc->source_env_name,doc->target_env_name,doc->source_ocd_cnt)
 GO TO end_script
 SUBROUTINE disp_text(disp_field,count)
   IF (count=1)
    CALL echo(build(header_str))
    CALL echo(disp_field)
    CALL echo(build(header_str))
    SELECT INTO value(redundancy_rpt_file)
     FROM dual
     DETAIL
      disp_field, row + 1
     WITH nocounter, maxcol = value(maxcolsize), append
    ;end select
   ELSE
    CALL echo(disp_field)
   ENDIF
 END ;Subroutine
 SUBROUTINE determine_redundancy(src_env_name,trg_env_name,src_cnt)
   CALL disp_text("Copy Master OCD list into Temporary list ...",0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(src_cnt)),
     dummyt d1
    PLAN (d)
     JOIN (d1)
    HEAD REPORT
     doc->red_cnt = src_cnt, stat = alterlist(doc->rlst,doc->red_cnt)
    DETAIL
     doc->rlst[d.seq].ocd_nbr = doc->qual[d.seq].ocd_nbr, doc->rlst[d.seq].redundancy_ind = 0, doc->
     rlst[d.seq].highest_ocd_nbr = 0
    WITH nocounter
   ;end select
   CALL disp_text("Determine if Redundancy exists in the Temporary list ...",0)
   SELECT INTO "nl:"
    df.product_area_number, df.alpha_feature_nbr
    FROM dm_alpha_features df,
     (dummyt d  WITH seq = value(doc->red_cnt))
    PLAN (d)
     JOIN (df
     WHERE (df.alpha_feature_nbr=doc->rlst[d.seq].ocd_nbr)
      AND df.product_area_number > 0)
    ORDER BY df.product_area_number, df.alpha_feature_nbr DESC
    HEAD REPORT
     doc->prd_area_cnt = 0, stat = alterlist(doc->lst,doc->prd_area_cnt)
    HEAD df.product_area_number
     doc->prd_area_cnt = (doc->prd_area_cnt+ 1), stat = alterlist(doc->lst,doc->prd_area_cnt), doc->
     lst[doc->prd_area_cnt].product_area_number = df.product_area_number,
     doc->lst[doc->prd_area_cnt].product_area_name = trim(df.product_area_name), ocd_cnt = 0, doc->
     lst[doc->prd_area_cnt].ocd_cnt = ocd_cnt,
     stat = alterlist(doc->lst[doc->prd_area_cnt].olst,ocd_cnt)
    DETAIL
     ocd_cnt = (ocd_cnt+ 1), stat = alterlist(doc->lst[doc->prd_area_cnt].olst,ocd_cnt), doc->lst[doc
     ->prd_area_cnt].olst[ocd_cnt].ocd_nbr = df.alpha_feature_nbr
     IF (ocd_cnt > 1)
      doc->rlst[d.seq].redundancy_ind = 1, doc->rlst[d.seq].highest_ocd_nbr = doc->lst[doc->
      prd_area_cnt].olst[1].ocd_nbr, redundancy_ind = 1
     ENDIF
    FOOT  df.product_area_number
     doc->lst[doc->prd_area_cnt].ocd_cnt = ocd_cnt
    WITH nocounter, formfeed = none, format = variable,
     maxcol = value(maxcolsize)
   ;end select
   IF (redundancy_ind=1)
    FREE SET junk_fld
    SET junk_fld = concat("Create Redundancy Report -> ",cnvtupper(redundancy_rpt_file)," (data) ..."
     )
    CALL disp_text(junk_fld,0)
    FREE SET junk_fld
    SELECT INTO value(redundancy_rpt_file)
     product_area_nbr = doc->lst[d1.seq].product_area_number, rocd_nbr = doc->lst[d1.seq].olst[d2.seq
     ].ocd_nbr
     FROM (dummyt d1  WITH seq = value(doc->prd_area_cnt)),
      (dummyt d2  WITH seq = value(max_dsize))
     PLAN (d1
      WHERE maxrec(d2,doc->lst[d1.seq].ocd_cnt) > 0)
      JOIN (d2
      WHERE (doc->lst[d1.seq].ocd_cnt > 1))
     ORDER BY product_area_nbr, rocd_nbr DESC
     HEAD REPORT
      row 0, header_str, row + 1,
      "Ocd Redundancy Report from ", src_env_name, " (source) to ",
      trg_env_name, " (target)", row + 1,
      header_str
     HEAD product_area_nbr
      ocd_trk_cnt = 0, pan = build("(",product_area_nbr,")"), row + 1,
      col 2, "- Product Area Name: ", doc->lst[d1.seq].product_area_name,
      " ", pan, row + 2,
      col 6, "OCD #", col 15,
      "ORDER", col 30, "STATUS",
      row + 1, col 5, "------",
      col 15, "----------", col 30,
      "--------", row + 1
     DETAIL
      ocd_trk_cnt = (ocd_trk_cnt+ 1), col 5, doc->lst[d1.seq].olst[d2.seq].ocd_nbr"######"
      IF (ocd_trk_cnt=1)
       col 15, "(highest)", col 30,
       "Kept"
      ELSEIF (((doc->lst[d1.seq].ocd_cnt - ocd_trk_cnt)=0))
       col 15, "(lowest)", col 30,
       "Removed"
      ELSE
       col 30, "Removed"
      ENDIF
      row + 1
     FOOT REPORT
      row + 1, header_str, row + 1,
      "End of Ocd Redundancy Report from ", src_env_name, " (source) to ",
      trg_env_name, " (target)", row + 1,
      header_str
     WITH nocounter, formfeed = none, format = streamm,
      maxcol = value(maxcolsize)
    ;end select
    CALL disp_text("Copy Temporary OCD list into Master list ...",0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(doc->red_cnt)),
      dummyt d1
     PLAN (d
      WHERE (doc->rlst[d.seq].redundancy_ind=0))
      JOIN (d1)
     HEAD REPORT
      doc->source_ocd_cnt = 0, stat = alterlist(doc->qual,doc->source_ocd_cnt)
     DETAIL
      doc->source_ocd_cnt = (doc->source_ocd_cnt+ 1), stat = alterlist(doc->qual,doc->source_ocd_cnt),
      doc->qual[doc->source_ocd_cnt].ocd_nbr = doc->rlst[d.seq].ocd_nbr
     WITH nocounter, formfeed = none, format = stream,
      maxcol = value(maxcolsize)
    ;end select
   ELSE
    FREE SET junk_fld
    SET junk_fld = concat("Create Redundancy Report -> ",cnvtupper(redundancy_rpt_file),
     " (no data) ...")
    CALL disp_text(junk_fld,0)
    FREE SET junk_fld
    SELECT INTO value(redundancy_rpt_file)
     FROM dual
     DETAIL
      row 0, header_str, row + 1,
      "Ocd Redundancy Report from ", src_env_name, " (source) to ",
      trg_env_name, " (target)", row + 1,
      header_str, row + 1, row + 1,
      "There are no Redundant OCDs in this Mass Move Process.", row + 1
     FOOT REPORT
      row + 1, header_str, row + 1,
      "End of Ocd Redundancy Report from ", src_env_name, " (source) to ",
      trg_env_name, " (target)", row + 1,
      header_str
     WITH nocounter, formfeed = none, format = streamm,
      maxcol = value(maxcolsize)
    ;end select
   ENDIF
 END ;Subroutine
#end_script
END GO
