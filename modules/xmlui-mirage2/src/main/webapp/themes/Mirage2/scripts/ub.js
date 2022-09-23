/*
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */

// Automatically select CC license text when selecting CC uri
$(function() {

  $('#aspect_submission_StepTransformer_field_dc_rights_uri').on('change', function() {
   var selectText = $(this).find(":selected").text();

   var targetValue = $("#aspect_submission_StepTransformer_field_dc_rights").find(":contains('" + selectText + "')").val();
   $("#aspect_submission_StepTransformer_field_dc_rights").val(targetValue);

   });

});
