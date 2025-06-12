CREATE PROGRAM ec_security_matrix:dba
 PROMPT
  "Enter output device (MINE)       : " = "MINE",
  "Enter application number (600005): " = 600005,
  "Enter position (All)             : " = "*"
  WITH outputdevice, appnumber, positiondisp
 DECLARE output_device = vc WITH noconstant( $OUTPUTDEVICE), protect
 DECLARE appnumber = i4 WITH noconstant( $APPNUMBER), protect
 DECLARE position = vc WITH noconstant( $POSITIONDISP), protect
 FREE RECORD reply
 RECORD reply(
   1 position_cnt = i2
   1 positions[*]
     2 position_cd = f8
     2 position_txt = vc
     2 view_cnt = i2
     2 priv_cnt = i2
     2 pref_cnt = i2
     2 prefs[*]
       3 pref_name = vc
       3 pref_value = vc
     2 views[*]
       3 level = vc
       3 view_name = vc
       3 view_caption = vc
       3 view_seq = i4
       3 table_view_seq = i4
       3 sub_view_cnt = i2
       3 sub_views[*]
         4 sub_level = vc
         4 sub_view_name = vc
         4 sub_view_caption = vc
         4 sub_view_seq = i4
 )
 SELECT INTO "nl"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.display_key=patstring(cnvtupper(position))
    AND cv.active_ind=1)
  HEAD REPORT
   positioncnt = 0
  DETAIL
   positioncnt = (reply->position_cnt+ 1), reply->position_cnt = positioncnt, stat = alterlist(reply
    ->positions,positioncnt),
   reply->positions[positioncnt].position_cd = cv.code_value, reply->positions[positioncnt].
   position_txt = cv.display
 ;end select
 SELECT INTO "nl"
  FROM (dummyt d1  WITH seq = size(reply->positions,5)),
   view_prefs vp,
   name_value_prefs nvp,
   name_value_prefs nvp2
  PLAN (d1)
   JOIN (vp
   WHERE vp.prsnl_id=0
    AND (vp.position_cd=reply->positions[d1.seq].position_cd)
    AND vp.application_number=appnumber
    AND vp.frame_type IN ("CHART", "ORG"))
   JOIN (nvp
   WHERE nvp.parent_entity_id=vp.view_prefs_id
    AND nvp.parent_entity_name="VIEW_PREFS"
    AND trim(nvp.pvc_name)="VIEW_CAPTION")
   JOIN (nvp2
   WHERE nvp2.parent_entity_id=vp.view_prefs_id
    AND nvp2.parent_entity_name="VIEW_PREFS"
    AND trim(nvp2.pvc_name)="DISPLAY_SEQ")
  ORDER BY vp.view_prefs_id
  HEAD REPORT
   viewcnt = 0
  HEAD vp.view_prefs_id
   viewcnt = (reply->positions[d1.seq].view_cnt+ 1), reply->positions[d1.seq].view_cnt = viewcnt,
   stat = alterlist(reply->positions[d1.seq].views,viewcnt),
   reply->positions[d1.seq].views[viewcnt].level = vp.frame_type, reply->positions[d1.seq].views[
   viewcnt].view_name = vp.view_name, reply->positions[d1.seq].views[viewcnt].table_view_seq = vp
   .view_seq,
   reply->positions[d1.seq].views[viewcnt].view_caption = nvp.pvc_value, reply->positions[d1.seq].
   views[viewcnt].view_seq = cnvtint(nvp2.pvc_value)
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  FROM (dummyt d1  WITH seq = size(reply->positions,5)),
   (dummyt d2  WITH seq = value(1)),
   view_prefs vp,
   name_value_prefs nvp,
   name_value_prefs nvp2
  PLAN (d1
   WHERE maxrec(d2,size(reply->positions[d1.seq].views,5)))
   JOIN (d2)
   JOIN (vp
   WHERE vp.prsnl_id=0
    AND (vp.position_cd=reply->positions[d1.seq].position_cd)
    AND vp.application_number=appnumber
    AND (vp.frame_type=reply->positions[d1.seq].views[d2.seq].view_name))
   JOIN (nvp
   WHERE nvp.parent_entity_id=vp.view_prefs_id
    AND nvp.parent_entity_name="VIEW_PREFS"
    AND trim(nvp.pvc_name)="VIEW_CAPTION")
   JOIN (nvp2
   WHERE nvp2.parent_entity_id=vp.view_prefs_id
    AND nvp2.parent_entity_name="VIEW_PREFS"
    AND trim(nvp2.pvc_name)="DISPLAY_SEQ")
  ORDER BY vp.view_prefs_id
  HEAD REPORT
   subviewcnt = 0
  HEAD vp.view_prefs_id
   subviewcnt = (reply->positions[d1.seq].views[d2.seq].sub_view_cnt+ 1), reply->positions[d1.seq].
   views[d2.seq].sub_view_cnt = subviewcnt, stat = alterlist(reply->positions[d1.seq].views[d2.seq].
    sub_views,subviewcnt),
   reply->positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_level = vp.frame_type, reply->
   positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_view_name = vp.view_name, reply->
   positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_view_caption = nvp.pvc_value,
   reply->positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_view_seq = cnvtint(nvp2.pvc_value
    )
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  FROM (dummyt d1  WITH seq = size(reply->positions,5)),
   (dummyt d2  WITH seq = value(1)),
   detail_prefs dp,
   name_value_prefs nvp
  PLAN (d1
   WHERE maxrec(d2,size(reply->positions[d1.seq].views,5)))
   JOIN (d2)
   JOIN (dp
   WHERE dp.prsnl_id=0
    AND (dp.position_cd=reply->positions[d1.seq].position_cd)
    AND dp.application_number=appnumber
    AND (dp.view_name=reply->positions[d1.seq].views[d2.seq].view_name)
    AND dp.view_name="CHARTSUMM"
    AND (dp.view_seq=reply->positions[d1.seq].views[d2.seq].table_view_seq))
   JOIN (nvp
   WHERE nvp.parent_entity_id=dp.detail_prefs_id
    AND trim(nvp.pvc_name) IN ("R_EVENT_SET_NAME", "GENSPREADINFO", "GENVIEWINFO"))
  ORDER BY dp.detail_prefs_id
  HEAD REPORT
   subviewcnt = 0
  HEAD dp.detail_prefs_id
   subviewcnt = (reply->positions[d1.seq].views[d2.seq].sub_view_cnt+ 1), reply->positions[d1.seq].
   views[d2.seq].sub_view_cnt = subviewcnt, stat = alterlist(reply->positions[d1.seq].views[d2.seq].
    sub_views,subviewcnt),
   reply->positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_level = dp.comp_name, reply->
   positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_view_name = nvp.pvc_name, reply->
   positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_view_caption = nvp.pvc_value,
   reply->positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_view_seq = cnvtint(dp.comp_seq)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = size(reply->positions,5)),
   app_prefs ap,
   name_value_prefs nvp
  PLAN (d1)
   JOIN (ap
   WHERE ap.prsnl_id=0
    AND (ap.position_cd=reply->positions[d1.seq].position_cd)
    AND ap.application_number=appnumber)
   JOIN (nvp
   WHERE nvp.parent_entity_id=ap.app_prefs_id
    AND nvp.parent_entity_name="APP_PREFS"
    AND nvp.pvc_name IN ("VIEW_CHARGES", "CHARGE_ENTRY", "CHART_CernerApplicationButton",
   "ADHOC_CHART", "PATIENTEDUCATION",
   "DEPARTPROCESS", "CHART_ACCESS", "MED_ADMIN_WIZARD", "CHART_PMACTION", "UNIFIED_ORDERING_CONFIG",
   "STICKYNOTES", "ORM_DISP_DX_ASSN"))
  ORDER BY nvp.name_value_prefs_id
  HEAD REPORT
   prefcnt = 0
  HEAD nvp.name_value_prefs_id
   prefcnt = (reply->positions[d1.seq].pref_cnt+ 1), reply->positions[d1.seq].pref_cnt = prefcnt,
   stat = alterlist(reply->positions[d1.seq].prefs,prefcnt),
   reply->positions[d1.seq].prefs[prefcnt].pref_name = nvp.pvc_name, reply->positions[d1.seq].prefs[
   prefcnt].pref_value = nvp.pvc_value
  WITH nocounter
 ;end select
 DECLARE appnbr = vc
 SELECT INTO "nl:"
  a.description, a.application_number
  FROM (dummyt d1  WITH seq = size(reply->positions,5)),
   application a,
   (dummyt d2  WITH seq = value(1))
  PLAN (d1
   WHERE maxrec(d2,size(reply->positions[d1.seq].prefs,5)))
   JOIN (d2
   WHERE (reply->positions[d1.seq].prefs[d2.seq].pref_name="CHART_CernerApplicationButton"))
   JOIN (a
   WHERE a.application_number=cnvtint(reply->positions[d1.seq].prefs[d2.seq].pref_value))
  DETAIL
   appnbr = reply->positions[d1.seq].prefs[d2.seq].pref_value, reply->positions[d1.seq].prefs[d2.seq]
   .pref_value = concat(trim(a.description)," (",trim(cnvtstring(a.application_number)),")")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = size(reply->positions,5)),
   app_prefs ap,
   name_value_prefs nvp
  PLAN (d1)
   JOIN (ap
   WHERE ap.prsnl_id=0
    AND (ap.position_cd=reply->positions[d1.seq].position_cd)
    AND ap.application_number=4250111)
   JOIN (nvp
   WHERE nvp.parent_entity_id=ap.app_prefs_id
    AND nvp.parent_entity_name="APP_PREFS"
    AND nvp.pvc_name="CHART_ACCESS")
  ORDER BY nvp.name_value_prefs_id
  HEAD REPORT
   prefcnt = 0
  HEAD nvp.name_value_prefs_id
   prefcnt = (reply->positions[d1.seq].pref_cnt+ 1), reply->positions[d1.seq].pref_cnt = prefcnt,
   stat = alterlist(reply->positions[d1.seq].prefs,prefcnt),
   reply->positions[d1.seq].prefs[prefcnt].pref_name = nvp.pvc_name, reply->positions[d1.seq].prefs[
   prefcnt].pref_value = nvp.pvc_value
  WITH nocounter
 ;end select
 SELECT INTO value(output_device)
  reply->positions[d1.seq].position_cd, position = substring(1,40,reply->positions[d1.seq].
   position_txt), level = substring(1,12,reply->positions[d1.seq].views[d2.seq].level),
  view_name = substring(1,12,reply->positions[d1.seq].views[d2.seq].view_name), view_caption =
  substring(1,50,reply->positions[d1.seq].views[d2.seq].view_caption), view_seq = reply->positions[d1
  .seq].views[d2.seq].view_seq,
  sub_level = substring(1,12,reply->positions[d1.seq].views[d2.seq].sub_views[d4.seq].sub_level),
  sub_view_name = substring(1,16,reply->positions[d1.seq].views[d2.seq].sub_views[d4.seq].
   sub_view_name), sub_view_caption = substring(1,50,reply->positions[d1.seq].views[d2.seq].
   sub_views[d4.seq].sub_view_caption),
  sub_view_seq = reply->positions[d1.seq].views[d2.seq].sub_views[d4.seq].sub_view_seq, pref_name =
  substring(1,32,reply->positions[d1.seq].prefs[d6.seq].pref_name), pref_value = substring(1,100,
   reply->positions[d1.seq].prefs[d6.seq].pref_value)
  FROM (dummyt d1  WITH seq = value(size(reply->positions,5))),
   (dummyt d2  WITH seq = value(1)),
   dummyt d3,
   dummyt d11,
   (dummyt d4  WITH seq = value(1)),
   (dummyt d5  WITH seq = value(1)),
   dummyt d9,
   (dummyt d6  WITH seq = value(1))
  PLAN (d1
   WHERE maxrec(d2,size(reply->positions[d1.seq].views,5)))
   JOIN (d3)
   JOIN (d2
   WHERE maxrec(d4,size(reply->positions[d1.seq].views[d2.seq].sub_views,5)))
   JOIN (d11)
   JOIN (d4)
   JOIN (d5
   WHERE maxrec(d6,size(reply->positions[d1.seq].prefs,5)))
   JOIN (d6)
   JOIN (d9)
  ORDER BY position, level, view_seq,
   sub_view_seq
  WITH nocounter, outerjoin = d3, outerjoin = d11,
   outerjoin = d9, pcformat('"',",",1), format = stream
 ;end select
END GO
