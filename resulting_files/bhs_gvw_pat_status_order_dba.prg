CREATE PROGRAM bhs_gvw_pat_status_order:dba
 DECLARE mf_status_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSDAYSTAYPATIENT"))
 DECLARE mf_status_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSINPATIENT"))
 DECLARE mf_status_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSOBSERVATIONPATIENT"))
 DECLARE mf_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE ms_beg_doc = vc WITH protect, constant(
  "{\rtf1\ansi\deff0{\fonttbl{\f0\froman times new roman;}{\f1\fmodern courier new;}}\fs20 ")
 DECLARE ms_end_doc = vc WITH protect, constant("}")
 DECLARE ms_newline = vc WITH protect, constant(concat("\par",char(10)))
 DECLARE ms_replystring = vc WITH protect, noconstant(concat(ms_beg_doc,
   "\b \ul  Most Recent Status Order\b0 \ul0",ms_newline))
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   prsnl pl
  PLAN (o
   WHERE o.catalog_cd IN (mf_status_daystay_cd, mf_status_inpatient_cd, mf_status_observation_cd)
    AND o.order_status_cd=mf_ordered_cd
    AND (o.encntr_id=request->visit[1].encntr_id)
    AND o.active_ind=1)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_order_cd)
   JOIN (pl
   WHERE pl.person_id=oa.order_provider_id)
  ORDER BY o.orig_order_dt_tm DESC, oa.action_dt_tm DESC
  HEAD REPORT
   ms_replystring = concat(ms_replystring,"\b Order: \b0 ",trim(o.order_mnemonic,3),ms_newline,
    "\b Placed On: \b0 ",
    trim(format(o.orig_order_dt_tm,"@SHORTDATETIME"),3),ms_newline,"\b Placed By: \b0 ",trim(pl
     .name_full_formatted,3))
  FOOT REPORT
   ms_replystring = concat(ms_replystring,ms_end_doc)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_replystring = concat(ms_replystring,"No Status Order Found",ms_end_doc)
 ENDIF
 SET reply->text = ms_replystring
END GO
