CREATE PROGRAM drc_print_route_groupings_rpt
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD temp
 RECORD temp(
   1 rec[*]
     2 drc_premise_id = f8
     2 route_group = c100
     2 grouper_name = vc
 )
 FREE RECORD temp_sorted
 RECORD temp_sorted(
   1 rec[*]
     2 drc_premise_id = f8
     2 route_group = vc
     2 grouper_name = vc
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE route_grp = c100 WITH public
 DECLARE flexed = vc WITH public, noconstant("F")
 SELECT INTO "nl:"
  FROM dm_info dm
  WHERE dm.info_domain="KNOWLEDGE INDEX APPLICATIONS"
   AND dm.info_name="DRC_FLEX"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET flexed = "T"
 ENDIF
 SELECT INTO "nl:"
  dpl.drc_premise_id, route = uar_get_code_display(dpl.parent_entity_id), drc.dose_range_check_name
  FROM drc_premise_list dpl,
   drc_premise dp,
   dose_range_check drc,
   drc_facility_r dfr
  PLAN (dpl
   WHERE dpl.drc_premise_id > 0.0
    AND dpl.active_ind=1)
   JOIN (dp
   WHERE dp.drc_premise_id=dpl.drc_premise_id
    AND dp.active_ind=1)
   JOIN (drc
   WHERE drc.dose_range_check_id=dp.dose_range_check_id
    AND drc.active_ind=1)
   JOIN (dfr
   WHERE dfr.dose_range_check_id=drc.dose_range_check_id)
  ORDER BY dpl.drc_premise_id, route
  HEAD REPORT
   rec_cnt = 0
  HEAD dpl.drc_premise_id
   rec_cnt = (rec_cnt+ 1)
   IF (mod(rec_cnt,10)=1)
    stat = alterlist(temp->rec,(rec_cnt+ 9))
   ENDIF
   temp->rec[rec_cnt].drc_premise_id = dpl.drc_premise_id
   IF (flexed="T")
    IF (dfr.facility_cd > 0.0)
     temp->rec[rec_cnt].grouper_name = concat(trim(drc.dose_range_check_name)," - ",
      uar_get_code_display(dfr.facility_cd))
    ELSE
     temp->rec[rec_cnt].grouper_name = concat(trim(drc.dose_range_check_name)," -  Default")
    ENDIF
   ELSE
    temp->rec[rec_cnt].grouper_name = drc.dose_range_check_name
   ENDIF
   route_grp = " "
  DETAIL
   route_grp = build(route_grp,route,", ")
  FOOT  dpl.drc_premise_id
   temp->rec[rec_cnt].route_group = route_grp
  FOOT REPORT
   stat = alterlist(temp->rec,rec_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET failed = "T"
  CALL echo("No dose range information found.")
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  temp->rec[d.seq].route_group, temp->rec[d.seq].grouper_name
  FROM (dummyt d  WITH seq = value(size(temp->rec,5)))
  ORDER BY temp->rec[d.seq].route_group, temp->rec[d.seq].grouper_name
  HEAD REPORT
   rec_cnt = 0
  DETAIL
   rec_cnt = (rec_cnt+ 1)
   IF (mod(rec_cnt,10)=1)
    stat = alterlist(temp_sorted->rec,(rec_cnt+ 9))
   ENDIF
   temp_sorted->rec[rec_cnt].drc_premise_id = temp->rec[d.seq].drc_premise_id, temp_sorted->rec[
   rec_cnt].grouper_name = temp->rec[d.seq].grouper_name, temp_sorted->rec[rec_cnt].route_group =
   substring(1,(size(trim(temp->rec[d.seq].route_group),1) - 1),trim(temp->rec[d.seq].route_group))
  FOOT REPORT
   stat = alterlist(temp_sorted->rec,rec_cnt)
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  rt_grp = temp_sorted->rec[d.seq].route_group, temp_sorted->rec[d.seq].grouper_name
  FROM (dummyt d  WITH seq = size(temp_sorted->rec,5))
  HEAD REPORT
   line = fillstring(125,"_"), end_line = fillstring(156,"_")
  HEAD PAGE
   col 0, "{PS/792 0 translate 90 rotate/}", row + 1,
   "{cpi/12}", row + 1, col 50,
   "ROUTE GROUPINGS DATA REPORT", row + 1, col 1,
   "Date: ", dttm = format(cnvtdatetime(curdate,curtime3),cclfmt->shortdatetime), col 7,
   dttm, pageend = concat("Page no: ",cnvtstring(curpage)), col 110,
   pageend, row + 1, col 1,
   line, row + 1, "{cpi/15}",
   row + 1
  HEAD rt_grp
   col 1, temp_sorted->rec[d.seq].route_group, row + 1
  DETAIL
   col 3, temp_sorted->rec[d.seq].grouper_name, row + 1
  FOOT  rt_grp
   col 1, line, row + 1
  FOOT REPORT
   row + 1, col 55, "End of Report"
  WITH nocounter, nullreport, dio = 08,
   maxrow = 56, maxcol = 200
 ;end select
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "001 09/26/06 NC011227"
END GO
