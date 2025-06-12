CREATE PROGRAM bhs_athn_get_admin_routes
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
   route = uar_get_code_display(rfr.route_cd), route_code = cv2.display_key
   FROM route_form_r rfr,
    code_value cv2
   PLAN (rfr
    WHERE (rfr.form_cd= $2))
    JOIN (cv2
    WHERE cv2.code_value=rfr.route_cd
     AND cv2.active_ind=1)
   ORDER BY route
   HEAD route
    r_cnt = (r_cnt+ 1), stat = alterlist(out_rec->routes,r_cnt), out_rec->routes[r_cnt].route = route,
    out_rec->routes[r_cnt].route_code = route_code, out_rec->routes[r_cnt].route_value = cnvtstring(
     rfr.route_cd)
   WITH nocounter, time = 30
  ;end select
 ELSE
  SELECT INTO "nl:"
   route = cv2.display, route_code = cv2.display_key
   FROM code_value cv2
   PLAN (cv2
    WHERE cv2.code_set=4001
     AND cv2.active_ind=1)
   ORDER BY route
   HEAD route
    r_cnt = (r_cnt+ 1), stat = alterlist(out_rec->routes,r_cnt), out_rec->routes[r_cnt].route = route,
    out_rec->routes[r_cnt].route_code = route_code, out_rec->routes[r_cnt].route_value = cnvtstring(
     cv2.code_value)
   WITH nocounter, time = 30
  ;end select
 ENDIF
 CALL echorecord(out_rec)
 CALL echojson(out_rec, $1)
 FREE RECORD out_rec
END GO
