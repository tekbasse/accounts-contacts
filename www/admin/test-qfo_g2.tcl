set title "#acs-subsite.Administration#"
set context [list ]



set user_id [ad_conn user_id]
set instance_id [ad_conn package_id]
set admin_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege admin]
if { !$admin_p } {
    ad_redirect_for_registration
    ad_script_abort
}

set one_choice_tag_attribute_list [list [list label " debitcard 1 " value debit1] [list label " debitcard 2 " value debit2] [list label " debitcard 3 " value debit3] ]

set multi_choice_tag_attribute_list [list \
                                         [list name card1 label " Bank 1 " value plastic1 selected 1] \
                                         [list name card2 label " Bank 2 " value plastic2 selected 0] \
                                         [list name card3 label " Bank 3 " value plastic3] ]


# to switch multiple between checkbox and select, switch value checkbox and select.
# to make them work identical,
# change all the names in multi_choice_tag_attribute_list to be the same
# as value as the select name's value.
set f_lol [list \
               [list type text value "example value" name "input_text" label "input text" size 40 maxlength 80 ] \
               [list type select name creditcard value ${one_choice_tag_attribute_list}] \
               [list type checkbox name test value ${multi_choice_tag_attribute_list} multiple 1] \
               [list type submit name charlie value bravo tabindex 9 datatype text_nonempty] \
               [list tabindex 8 type submit name submit value "#acs-kernel.common_Save#" datatype text_nonempty]
          ]
#ns_log Notice "[ad_conn url] one_choice_tag_attr.. '$one_choice_tag_attribute_list'"
#ns_log Notice "[ad_conn url] multi_choice_tag_attr.. '$multi_choice_tag_attribute_list'"
#ns_log Notice "[ad_conn url] f_lol '$f_lol'"
set form_html ""
qfo::form_list_def_to_array \
    -array_name f_arr \
    -list_of_lists_name f_lol \
    -ignore_parse_issues_p 0
ns_log Notice "[ad_conn url] array get f_arr '[array get f_arr]'"
set validated_p [qfo_2g \
                     -form_id 20180425 \
                     -fields_array f_arr \
                     -form_varname form_html \
                     -hash_check 1]

append content $form_html
append content "<span>  &nbsp; &nbsp; &nbsp; </span> <a href=\"test-qfo_g2\">clear</a>"


if { $validated_p } {
    # output inputs
    append content "<pre>Validated name values returned:<br>"
    append content "<ul>"
    foreach name [array names qfi_arr] {
        append content "<li>'${name}' : '$qfi_arr(${name})'</li>\n"
    }
    append content "</ul></pre>"


} else {


}
