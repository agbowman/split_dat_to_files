CREATE PROGRAM bhs_athn_get_admin_routes_v2
 FREE RECORD out_rec
 RECORD out_rec(
   1 routes[*]
     2 route = vc
     2 route_code = vc
     2 route_value = vc
 )
 DECLARE r_cnt = i4 WITH protect, noconstant(0)
 IF (( $2 > 0))
  SELECT INTO "nl:"
   FROM route_form_r rfr,
    code_value cv
   PLAN (rfr
    WHERE (rfr.form_cd= $2))
    JOIN (cv
    WHERE cv.code_value=rfr.route_cd
     AND cv.active_ind=1
     AND cv.end_effective_dt_tm > sysdate)
   ORDER BY cv.display
   HEAD REPORT
    r_cnt = 0
   HEAD cv.display
    r_cnt = (r_cnt+ 1)
    IF (mod(r_cnt,1000)=1)
     stat = alterlist(out_rec->routes,(r_cnt+ 999))
    ENDIF
    out_rec->routes[r_cnt].route = cv.display, out_rec->routes[r_cnt].route_code = cv.display_key,
    out_rec->routes[r_cnt].route_value = cnvtstring(rfr.route_cd)
   FOOT REPORT
    stat = alterlist(out_rec->routes,r_cnt)
   WITH nocounter, time = 30
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv,
    code_value_extension cve
   PLAN (cv
    WHERE cv.code_set=4001
     AND cv.active_ind=1)
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="ORDERED AS"
     AND cve.field_value != "4")
   ORDER BY cv.display
   HEAD REPORT
    r_cnt = 0
   HEAD cv.display
    r_cnt = (r_cnt+ 1)
    IF (mod(r_cnt,1000)=1)
     stat = alterlist(out_rec->routes,(r_cnt+ 999))
    ENDIF
    out_rec->routes[r_cnt].route = cv.display, out_rec->routes[r_cnt].route_code = cv.display_key,
    out_rec->routes[r_cnt].route_value = cnvtstring(cv.code_value)
   FOOT REPORT
    stat = alterlist(out_rec->routes,r_cnt)
   WITH nocounter, time = 30
  ;end select
 ENDIF
 CALL echorecord(out_rec)
 CALL echojson(out_rec, $1)
END GO
