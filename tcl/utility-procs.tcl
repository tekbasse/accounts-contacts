#accounts-contacts/tcl/utility-procs.tcl
ad_library {

    misc API for accounts-contacts
    @creation-date 7 Aug 2018
    @Copyright (c) 2018 Benjamin Brink
    @license GNU General Public License 2
    @project home: http://github.com/tekbasse/accounts-contacts
    
}

# qc_properties  returns list of properties (defined in accounts-ledger)

# accounts-contacts.contact_id references refer to accounts-ledeger.contact_id
# so that package can be used  with contacts, contacts, or vendors.

ad_proc -public qal_keys_by {
    keys_list
    {separator ""}
} {
    if { $separator ne ""} {
        set keys ""
        if { $separator eq ",:" } {
            # for db
            set keys ":"
        }
        append keys [join $keys_list $separator]
    } else {
        set keys $keys_list
    }
    return $keys
}

ad_proc -public qal_contact_tz {
    contact_id
} {
    Retuns the timezone of the contact. 
    If not known, will guess based on primary user_id or system default.
    If timezone exists, will use it instead.
} {
    set tz [qal_contact_id_read $contact_id [list timezone user_id]]
    if { $tz eq "" && [qf_is_natural_number $user_id] } {
        set tz [lang::user::timezone $user_id]
    }
    if { $tz eq "" } {
        set tz [lang::system::timezone]
    }
    return $tz
}

ad_proc -public qal_timestamp_to_tz {
    timestamp_any_tz
    {tz ""}
    {timestamp_format "%Y-%m-%d %H:%M:%S%z"}
} {
    Converts a timestamp to specified timezone. 
    If timezone (tz) is empty string, converts to connected users's timezone otherwise system's default.
    If timestamp_format is empty string, uses clock scan's default interpretation.
} {
    if { $timestamp_format eq "" } {
        # let clock scan do a best guess
        set cs_s [clock scan $timestamp_any_tz]
    } else {
        set cs_s [clock scan $timestamp_any_tz -format $timestamp_format]
    }
    set yyyymmdd_hhmmss_utc [clock format $cs_s -gmt true]
    #redundant:
    # if $tz eq "", set tz \lang::system::timezone 
    set timestamp_ltz [lc_time_utc_to_local $yyyymmdd_hhmmss_utc $tz]
    return $timestamp_ltz
}


ad_proc -public qaf_interpolatep1p2_at_x {
    p1_x
    p1_y
    p2_x
    p2_y
    p3_x
} {
    Returns y value of third point (p3) assuming p2_x > p1_y and p3_x is between p1_x and p2_x.
} {
    set x_diff [expr { $p2_x - $p1_x } ]

    if { $x_diff == 0 } {
        set p3_y $p1_y
    } else {
        set y_diff [expr { $p2_y - $p1_y } ]
        set x3_diff [expr { $p3_x - $p1_x } ]
        set x_pct_diff [expr { $x3_diff / $x_diff } ]
        set p3_y [expr { $x_pct_diff * $y_diff + $p1_y } ]
    }
    return $p3_y
}

ad_proc -public qaf_y_of_x_dist_curve {
    p
    y_x_lol
    {interpolate_p 0}
} {
    returns y where p is in the range of x ie y(p,x).  Where p is some probability between 0 and 1. 
    Assumes y_x_lol is an ordered list of lists representing a curve. Set interpolate_p to 1
    to interpolate when p is between two discrete points that represent a continuous curve. if first row contains labels x and y as labels, 
    these positions will be used to extract data from remaining rows. a pair y,x is assumed
}  {
    #ns_log Notice "qaf_y_of_x_dist_curve.82: *****************************************************************" 
#    ns_log Notice "qaf_y_of_x_dist_curve.83: p $p interpolate_p $interpolate_p "
    set p [expr { $p + 0. } ]
    set first_row_list [lindex $y_x_lol 0]
    set x_idx [lsearch -exact $first_row_list "x"]
    set y_idx [lsearch -exact $first_row_list "y"]
    if { $y_idx == -1 || $x_idx == -1 } {
        set x_idx 1
        set y_idx 0
        set data_row_1 0
    } else {
        set data_row_1 1
    }

    # normalize x to 1.. first extract x list
    set x_list [list ]
    foreach y_x [lrange $y_x_lol $data_row_1 end] {
        lappend x_list [lindex $y_x $x_idx]
    }
    #ns_log Notice "qaf_y_of_x_dist_curve.102: y_x_lol length [llength $y_x_lol] y_x_lol $y_x_lol " 
#    ns_log Notice "qaf_y_of_x_dist_curve.103: x_list length [llength $x_list] x_list $x_list"
    set x_sum [f::sum $x_list]
    set x_len [llength $x_list]
    set loop_limit [expr { $x_len + 1 } ]
    # normalize p to range of x
    set p_normalized [expr { $p * $x_sum * 1. } ]

    #ns_log Notice "qaf_y_of_x_dist_curve.104: x_sum '$x_sum' p '$p' p_normalized '$p_normalized' y_idx '$y_idx' x_idx '$x_idx' data_row_1 '$data_row_1'"
    # determine y @ x

    set i 0
    set p_idx $i
    set p_test 0.
    while { $p_test < $p_normalized && $i < $loop_limit } {
        set x [lindex $x_list $i]
        #    ns_log Notice "qaf_y_of_x_dist_curve.117: i '$i' x '$x' p_test '$p_test'"
        if { $x ne "" } {
            set p_test [expr { $p_test + $x } ]
            set p_idx $i
        }
        incr i
    }
    # $p_idx is the index point in x_list where p is in the range of p_idx
    set y_x_i [expr { $data_row_1 + $p_idx } ]
    set row_list [lindex $y_x_lol $y_x_i]
    #ns_log Notice "qaf_y_of_x_dist_curve.120: i $i p_test $p_test x '$x' row_list '$row_list' y_x_i '$y_x_i'"
    if { $interpolate_p && $p_test != $p_normalized } {
        # point(i) is p(x2,y2)
        set x2 [lindex $row_list $x_idx]
        set y2 [lindex $row_list $y_idx]
        # point(i-1) is p(x1,y1)
        set y_x_i_1 [expr { $y_x_i - 1 } ]
        set row_list [lindex $y_x_lol $y_x_i_1]
        set x1 [lindex $row_list $x_idx]
        set y1 [lindex $row_list $y_idx]
        set y [qaf_interpolatep1p2_at_x $x1 $y1 $x2 $y2 $p_normalized 1]

    } else {
        set y [lindex $row_list $y_idx]
        if { [qf_is_natural_number $y] } {
            set y [expr { $y + 0. } ]
        }
    }

    #ns_log Notice "qaf_y_of_x_dist_curve.141: y $y"
    return $y
}
