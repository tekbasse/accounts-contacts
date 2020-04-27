set title "#acs-subsite.Application#"
set context [list $title]
set contents ""
qc_set_instance_id
# 1. Identify the lib/templates to add to the complement .adp page
#    that determine the overall presenation structure.

# 2. Define the form as a list to list.
#    Each list item represents an HTML form element.
#    Value of 'context' becomes a variable that gets passed
#    to the templates in the complement .adp page.
#    Only requires the name/value pairs of 'name', 'context', 'datatype'.
#    Datatype comes from q-data-types, which provides defaults for all
#    values.
#    Any additional attributes overwrite the defaults provided by datatype.
#    Best practices:  include a label and title, and use internationalization
#    keys if possible.
#    To add html before an element, add name/value attribute 'html_before'.
#    To add html after an element, add name/value attribute 'html_after'.
#    Put the definition of the list of lists into a proc,
#     and keep it with package_name-defaults.tcl, where other field
#     values are kept.. so the M part of C of MVC is all in one place.
#     The M part of MVC is the sql defintions sql/*/package_name-create.sql

set f_lol [qal_contact_form_def ]

ns_log Notice "[ns_conn url] instance_id $instance_id"
# Start rendering form definition..
::qfo::form_list_def_to_array \
    -list_of_lists_name f_lol \
    -fields_ordered_list_name qf_fields_ordered_list \
    -array_name f_arr \
    -ignore_parse_issues_p 0

set form_submitted_p 0

# ..and validate any form input
set validated_p [qal_3g \
                     -form_id 20200419 \
                     -fields_ordered_list $qf_fields_ordered_list \
                     -fields_array f_arr \
                     -inputs_as_array input_array \
                     -form_submitted_p $form_submitted_p \
                     -dev_mode_p 1 \
                     -form_verify_varname "confirmed" \
                     -form_varname "content_c" ]



# Process validated input.
if { $validated_p } {
    if { f_arr(contact_id) eq "" } {
        qal_contact_create f_arr
    } else {
        qal_contact_write f_arr
    }
    # Presenting a new blank form?  Consider rp_internal_redirect
    # which resets form to default values
    # rp_internal_redirect [ns_conn url]
    # Would it be better if qal_3g supplied the default form as well
    # as a changed one when validated,
    # so the app could decide to present a fresh form?
    # Alternately, if validated, could present form data as write_p=0.then
    # offer UI for new, edit, etc.
    # qal_3g should be able to offer both methods available OR not XOR
    # They should be available as separate flags, or maybe default
    # behavior where decision is deferred to the app biz code (best).
}


