CREATE PROGRAM ec_get_ord_prefs_by_val:dba
 PROMPT
  "Enter position code: " = 441.00,
  "Enter group_by_key value: " = "3",
  "Enter then_by_key value: " = "0",
  "Enter sort_key value: " = "1",
  "Enter sort_order value: " = "2",
  "Enter columns value: " = "2,3,4,5,6"
  WITH position_cd, groupbykey, thenbykey,
  sortkey, sortorder, columns
 DECLARE positioncd = f8 WITH noconstant(cnvtreal( $POSITION_CD)), protect
 DECLARE groupbykey = vc WITH noconstant(trim( $GROUPBYKEY,3)), protect
 DECLARE thenbykey = vc WITH noconstant(trim( $THENBYKEY,3)), protect
 DECLARE sortkey = vc WITH noconstant(trim( $SORTKEY,3)), protect
 DECLARE sortorder = vc WITH noconstant(trim( $SORTORDER,3)), protect
 DECLARE columns = vc WITH noconstant(trim( $COLUMNS,3)), protect
 DECLARE num = i4 WITH noconstant(0)
 DECLARE iusercnt = i4 WITH noconstant(0)
 DECLARE iloop_cnt = i4 WITH noconstant(0)
 DECLARE istart = i4 WITH noconstant(0)
 DECLARE iexpandidx = i4 WITH noconstant(0)
 DECLARE ibatch_size = i4 WITH constant(50)
 FREE RECORD rpt
 RECORD rpt(
   1 user_cnt = i4
   1 users[*]
     2 person_id = vc
     2 name_full_formatted = vc
     2 position_cd = f8
     2 position_display = vc
 )
 SELECT INTO "nl:"
  FROM prsnl p,
   code_value cv
  PLAN (p
   WHERE p.position_cd=positioncd)
   JOIN (cv
   WHERE cv.code_value=p.position_cd)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (rpt->user_cnt+ 1), rpt->user_cnt = cnt, stat = alterlist(rpt->users,cnt),
   rpt->users[cnt].person_id = cnvtstring(p.person_id,19,2), rpt->users[cnt].name_full_formatted = p
   .name_full_formatted, rpt->users[cnt].position_cd = p.position_cd,
   rpt->users[cnt].position_display = cv.display
  WITH nocounter
 ;end select
 SET iusercnt = size(rpt->users,5)
 SET iloop_cnt = ceil((cnvtreal(iusercnt)/ ibatch_size))
 SET istart = 1
 SET iexpandidx = 0
 SELECT DISTINCT
  position = substring(1,40,rpt->users[locateval(num,1,iusercnt,pg.value,rpt->users[num].person_id)].
   position_display), person_id = substring(1,20,pg.value), person_name = substring(1,40,rpt->users[
   locateval(num,1,iusercnt,pg.value,rpt->users[num].person_id)].name_full_formatted)
  FROM (dummyt d  WITH seq = value(iloop_cnt)),
   prefdir_entrydata p1,
   prefdir_entrydata p2,
   prefdir_entrydata p3,
   prefdir_entrydata p4,
   prefdir_entrydata p5,
   prefdir_entrydata p6,
   prefdir_entrydata p7,
   prefdir_entrydata p8,
   prefdir_entry pe,
   prefdir_value pv,
   prefdir_group pg
  PLAN (d
   WHERE initarray(istart,evaluate(d.seq,1,1,(istart+ ibatch_size))))
   JOIN (p1
   WHERE p1.dist_name_short="prefcontext=user,prefroot=prefroot")
   JOIN (p2
   WHERE p2.parent_id=p1.entry_id)
   JOIN (pg
   WHERE pg.entry_id=p2.entry_id
    AND expand(iexpandidx,istart,minval((istart+ (ibatch_size - 1)),iusercnt),pg.value,rpt->users[
    iexpandidx].person_id))
   JOIN (p3
   WHERE p3.parent_id=p2.entry_id
    AND substring(1,19,p3.dist_name_short)="prefgroup=component")
   JOIN (p4
   WHERE p4.parent_id=p3.entry_id
    AND substring(1,12,p4.dist_name_short)="prefgroup=om")
   JOIN (p5
   WHERE p5.parent_id=p4.entry_id
    AND substring(1,21,p5.dist_name_short)="prefgroup=powerorders")
   JOIN (p6
   WHERE p6.parent_id=p5.entry_id
    AND substring(1,22,p6.dist_name_short)="prefgroup=orderprofile")
   JOIN (p7
   WHERE p7.parent_id=p6.entry_id
    AND substring(1,28,p7.dist_name_short)="prefgroup=ordlist-customview")
   JOIN (p8
   WHERE p8.parent_id=p7.entry_id)
   JOIN (pe
   WHERE pe.entry_id=p8.entry_id
    AND pe.value_upper IN ("GROUPBYKEY", "THENBYKEY", "SORTKEY", "SORTORDER", "COLUMNS"))
   JOIN (pv
   WHERE pv.entry_id=p8.entry_id
    AND ((pe.value_upper="GROUPBYKEY"
    AND pv.value_upper != groupbykey) OR (((pe.value_upper="THENBYKEY"
    AND pv.value_upper != thenbykey) OR (((pe.value_upper="SORTKEY"
    AND pv.value_upper != sortkey) OR (((pe.value_upper="SORTORDER"
    AND pv.value_upper != sortorder) OR (pe.value_upper="COLUMNS"
    AND pv.value_upper != columns)) )) )) )) )
  ORDER BY p2.entry_id
  WITH nocounter
 ;end select
#exit_script
END GO
