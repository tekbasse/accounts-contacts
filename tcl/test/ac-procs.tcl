ad_library {
    Automated tests for accounts-contacts
    @creation-date 2017-05-01
}

aa_register_case -cats {api smoke} -procs {
	    qal_contact_read
	    qal_contact_write
	    qal_contact_create
	    qal_other_address_map_keys
	    qal_address_keys
	    qal_address_type_is_postal_q
	    qal_namelur
	} qal_entities_check {
    Test qal entities ie contact+customer+vendor procs for CRUD consistency
} {
    aa_run_with_teardown \
	-test_code {
            # -rollback \
			ns_log Notice "aa_register_case.13: Begin test contact_check"

                        set instance_id [ad_conn package_id]
                        # use the sysadmin user, because we aren't testing permissions
                        set sysowner_email [ad_system_owner]
                        set sysowner_user_id [party::get_by_email -email $sysowner_email]
                        set user_id $sysowner_user_id
                        set this_user_id [ad_conn user_id]
                        set org_admin_id [qc_role_id_of_label org_admin $instance_id]
                        ns_log Notice "qal-procs.tcl.21: this_user_id ${this_user_id}' org_admin_id '${org_admin_id}' user_id '${user_id}' instance_id '${instance_id}'"

                        # CRURTRDR tests for contact, customer, vendor
                        #    C=Create, R=Read, U=Update T=Trash D=Delete
                        #

                        # co = contact, cu = customer, ve = vendor
                        set create_start_cs [clock seconds]
                        set co_id [qal_demo_contact_create contact_arr "" $user_id]
                        set co_created_p [qf_is_natural_number $co_id] 
                        if { $co_created_p } {
                            set perm_granted_p [qc_user_role_add $co_id $this_user_id $org_admin_id $instance_id]
                        }
                        aa_true "A1 Created a contact" $co_created_p

                        set create_end_cs [clock seconds]
                        if { $create_end_cs ne $create_start_cs } {
                            aa_log "Created field may have a timing error of 1 second."
                        }

                        aa_log "B0 Read and verify each value"

                        set co_v2_list [qal_contact_read $co_id]
                        set co_v2_list_len [llength $co_v2_list]
                        set co_keys_list [qal_contact_keys]
                        set co_v2_list_keys [dict keys $co_v2_list]
                        foreach key $co_keys_list {
                            if { $key ne "id" && $key ne "rev_id" } {
                                if { $co_v2_list_len > 0 } {
                                    set actual [dict get $co_v2_list $key] 
                                    set expected $contact_arr(${key})
                                    if { $key in [list time_start time_end created] } {
                                        # compare epochs
                                        aa_log "B1-0 ${key} field actual from db: '${actual}', expected from var cache: '${expected}'"
                                        if { $actual ne "" } {
                                            set actual [qf_clock_scan_from_db $actual]
                                        }
                                        if { $expected ne "" } {
                                            set expected [qf_clock_scan $expected]
                                        } else {
                                            if { $key eq "created" } {
                                                set expected $create_start_cs
                                            }
                                        }
                                    }
                                } 
                                aa_equals "B1 Contact read/write test key ${key}" $actual $expected
                            } else {
                                set is_nn_p 0
                                if { $key in $co_v2_list_keys } {
                                    set is_nn_p [qf_is_natural_number [dict get $co_v2_list $key ]]
                                }
                                aa_true "B1 Contact read/write test key ${key}'s value is natural number" $is_nn_p
                            }
                        }


                        aa_log "C0  Change/update each value"

                        set co2_id [qal_demo_contact_create contact_arr $co_id $user_id]
                        if { [qf_is_natural_number $co2_id] && $co_id eq $co2_id } {
                            set co_updated_p 1
                        } else {
                            set co_updated_p 0
                        }

                        aa_true "C1  Updated a contact" $co_updated_p


                        aa_log "D0  Read and verify each updated value"

                        set co_v3_list [qal_contact_read $co_id]
                        set co_v3_list_len [llength $co_v3_list]
                        set co_keys_list [qal_contact_keys]
                        set co_v3_list_keys [dict keys $co_v3_list]
                        foreach key $co_keys_list {
                            if { $key ne "id" && $key ne "rev_id" } {
                                if { $co_v3_list_len > 0 } {
                                    set actual [dict get $co_v3_list $key] 
                                    set expected $contact_arr(${key})
                                    if { $key in [list time_start time_end created] } {
                                        # compare epochs
                                        aa_log "D1-0 ${key} field actual from db: '${actual}', expected from var cache: '${expected}'"
                                        if { $actual ne "" } {
                                            set actual [qf_clock_scan_from_db $actual]
                                        }
                                        if { $expected ne "" } {
                                            set expected [qf_clock_scan $expected]
                                        } else {
                                            if { $key eq "created" } {
                                                set expected $create_start_cs
                                            }
                                        }
                                    }
                                } 
                                aa_equals "D1 Contact read/write test key ${key}" $actual $expected
                            } else {
                                set is_nn_p 0
                                if { $key in $co_v3_list_keys } {
                                    set is_nn_p [qf_is_natural_number [dict get $co_v3_list $key ]]
                                }
                                aa_true "D1 Contact read/write test key ${key}'s value is natural number" $is_nn_p
                            }
                        }


                        # Iterate through creating contact to test more trash/delete cases
                        # Build the permutations randomly to help flush out any business logic idiosyncracies

                        # ico = iterating contact_id list 

                        # These values change according to request, then
                        # verify requests successful by comparing to db results.
                        # deleted_p_arr(id) = has been deleted?
                        # trashed_p_arr(id) = has been trashed?
                        # is_co_p_arr(id) = is a contact?

                        # permu_ids_larr(type) = list of permutations of this type.
                        # permutations:
			## This has been simplified
			# the complete test is in accounts-ledger package.
                        set permutations_list [list co ]
                        foreach p $permutations_list {
                            set permu_ids_larr(${p}) [list ]
                        }
                        # Careful: co_cu_ve  includes cases of co_ve-cu..
                        # Make 4 x 3 of each type
                        # which means 4 x 3 x 4 contacts.
			## revised, only 'co' in list
                        for {set i 0} {$i < 1} {incr i} {
                            append types_list $permutations_list
                        }
                        # Randomize the types in an evolving way, kind of like how it will be used.
                        # 
                        # acc_fin::shuffle_list is defined in a package not required. So, using its code:
                        set len [llength $types_list]
                        while { $len > 0 } {
                            set n_idx [expr { int( $len * [random] ) } ]
                            set tmp [lindex $types_list $n_idx]
                            lset types_list $n_idx [lindex $types_list [incr len -1]]
                            lset types_list $len $tmp
                        }

                        # There must be:
                        # At least 16 contacts of which 4 are not customers or vendors
                        # And for each permutation, a case of do nothing, trash, and delete 
                        # each subtype co,cu,ve
                        # 3 x 1 
                        set min_arr(co) 3
                        # of which 8 become customers at some point, and 4 customers only (not vendors)
                        # 3 x 2 
                        set min_arr(co_cu) 0
                        # 8 become vendors (4 only vendors not customers), and
                        # 3 x 2
                        set min_arr(co_ve) 0
                        # 4 become customers and vendors
                        # 3 x 3
                        set min_arr(co_cu_ve) 0
                        
                        set permutations_met_p 0
                        set i 0
                        while { !$permutations_met_p && $i < 2000 } {
                            # type = type to create
                            set type [lindex $permutations_list [randomRange 3]]
                            ns_log Notice "qal_entitites-procs.tcl.302 i '${i}' type '${type}' id count: [llength $permu_ids_larr(${type})]"
                            # create some co types, 2 to 7 of them
                            set k_max [randomRange 5]
                            incr k_max 2
                            for {set k 0} {$k < $k_max} {incr k } {
                                set co_id [qal_demo_contact_create dco_arr "" $user_id]
                                
                                set deleted_p_arr(${co_id}) 0
                                set trashed_p_arr(${co_id}) 0
                                set is_co_p_arr(${co_id}) 1
                                set is_cu_p_arr(${co_id}) 0
                                set is_ve_p_arr(${co_id}) 0
                                
                                unset dco_arr
                                set ck 0
                                if { $co_id ne "" } {
                                    lappend permu_ids_larr(co) $co_id
                                    set p_granted_p [qc_user_role_add $co_id $this_user_id $org_admin_id $instance_id]
                                    set ck 1
                                }
                                aa_true "E.299: qal_demo_contact_create failed unexpectedly" $ck
                                
                            }
                            set co_id ""
                            switch -exact -- $type {
                                co {
                                    # see create a co type or two before switch
                                }
                                default {
                                    ns_log Warning "E.399. Switch should not be provided type '${type}'"
                                }
                            }
                            if { $i > 1999 } {
                                set i_gt_2k_p 1
                                aa_false "E.439 'Permutation count is over 2000.' If true and repeatable, there's an error somewhere in loop." $i_gt_2k_p
                            }
                            set permutations_met_p 1

                            foreach p $permutations_list {
                                if { [llength $permu_ids_larr(${p})] >= $min_arr(${p}) } {
                                    set perms_met_for_this_type_p 1
                                } else {
                                    set perms_met_for_this_type_p 0
                                }
                                set permutations_met_p [expr { $permutations_met_p && $perms_met_for_this_type_p } ]
                            }
                            incr i
                        }

                        # For each permutation, choose one of each type it is (co, cu, and ve)
                        # and trash, or delete.
                        set j 0
                        set type_list [list co cu ve]
                        foreach p $permutations_list {
                            set p_id_list $permu_ids_larr(${p}) 
                            set p_idx_max [llength $p_id_list]
                            incr p_idx_max -1
                            foreach t $type_list {
                                if { [string match "*${t}*" $p] } {
                                    foreach action [list trash del ] {
                                        set p_idx [randomRange $p_idx_max]
                                        set co_id [lindex $p_id_list $p_idx]
                                        set p_id_list [lreplace $p_id_list $p_idx $p_idx]
                                        incr p_idx_max -1
                                        set toggle $action
                                        append toggle "_" $t
                                        incr j
                                       # ns_log Notice "qal_entitites-procs.tcl.486 j '${j}' p '${p}' type '${t}' action '${action}' co_id '${co_id}' toggle '${toggle}' id count: $p_idx_max"
                                        switch -exact -- $toggle {
                                            trash_co {
                                                set r [qal_contact_trash $co_id]
                                                if { $r } {
                                                    set trashed_p_arr(${co_id}) $r
                                                    set is_ve_p_arr(${co_id}) 0
                                                    set is_cu_p_arr(${co_id}) 0
                                                } 
                                            }
                                            del_co {
                                                set r [qal_contact_delete $co_id]
                                                if { $r } {
                                                    set deleted_p_arr(${co_id}) 1
                                                    set is_ve_p_arr(${co_id}) 0
                                                    set is_cu_p_arr(${co_id}) 0
                                                }
                                            }
                                            default {
                                                ns_log Warning "qal_entities_procs.tcl.531 toggle '${toggle}' not found for switch."
                                            }
                                        }
                                        aa_true "E.550 action '${action}' type '${t}' with contact_id '${co_id}' reports success." $r
                                    }
                                }
                            }
                        }


                        foreach p $permutations_list {
                            foreach co_id $permu_ids_larr(${p}) {
                                # verify status using  qal_contact_id_exists_q qal_customer_id_exists_q qal_vendor_id_exists_q
                                # type co
                                set actual [qal_contact_id_exists_q $co_id]
                                set expected_co [expr { !( $deleted_p_arr(${co_id}) || $trashed_p_arr(${co_id}) )}] 
                                aa_equals "E. Permutation '${p}' contact_id '${co_id}' exists?" $actual $expected_co

                            }
                        }

                        ns_log Notice "tcl/test/qal-procs.tcl.429 end"


                    } \
        -teardown_code {
            # 
            #acs_user::delete -user_id $user_arr(user_id) -permanent

        }
    #aa_true "Test for .." $passed_p
    #aa_equals "Test for .." $test_value $expected_value

}

