describe('linter.checkov', function()
  it('can parse checkov output', function()
    assert.are.same(1, 1)
    local parser = require('lint.linters.checkov').parser
    local result = parser([[
 {
     "check_type": "terraform",
     "results": {
         "passed_checks": [],
         "failed_checks": [
             {
                 "check_id": "CKV_GCP_32",
                 "bc_check_id": "BC_GCP_NETWORKING_8",
                 "check_name": "Ensure 'Block Project-wide SSH keys' is enabled for VM instances",
                 "check_result": {
                     "result": "FAILED",
                     "evaluated_keys": [
                         "metadata/block-project-ssh-keys"
                     ]
                 },
                 "code_block": [
                 ],
                 "file_path": "/something.tf",
                 "file_abs_path": "/Users/test/repo/something.tf",
                 "repo_file_path": "/something.tf",
                 "file_line_range": [
                     14,
                     42
                 ],
                 "resource": "google_compute_instance_template.something",
                 "evaluations": null,
                 "check_class": "checkov.terraform.checks.resource.gcp.GoogleComputeBlockProjectSSH",
                 "fixed_definition": null,
                 "entity_tags": null,
                 "caller_file_path": null,
                 "caller_file_line_range": null,
                 "resource_address": null,
                 "guideline": "https://docs.bridgecrew.io/docs/bc_gcp_networking_8"
             },
             {
                 "check_id": "CKV_GCP_39",
                 "bc_check_id": "BC_GCP_GENERAL_3",
                 "check_name": "Ensure Compute instances are launched with Shielded VM enabled",
                 "check_result": {
                     "result": "FAILED",
                     "evaluated_keys": []
                 },
                 "code_block": [
                 ],
                 "file_path": "/something.tf",
                 "file_abs_path": "/Users/test/repo/something.tf",
                 "repo_file_path": "/something.tf",
                 "file_line_range": [
                     14,
                     42
                 ],
                 "resource": "google_compute_instance_template.something",
                 "evaluations": null,
                 "check_class": "checkov.terraform.checks.resource.gcp.GoogleComputeShieldedVM",
                 "fixed_definition": null,
                 "entity_tags": null,
                 "caller_file_path": null,
                 "caller_file_line_range": null,
                 "resource_address": null,
                 "guideline": "https://docs.bridgecrew.io/docs/bc_gcp_general_y"
             }
         ],
         "skipped_checks": [],
         "parsing_errors": []
     },
     "summary": {
         "passed": 6,
         "failed": 2,
         "skipped": 0,
         "parsing_errors": 0,
         "resource_count": 3,
         "checkov_version": "2.0.690"
     },
     "url": "Add an api key '--bc-api-key <api-key>' to see more detailed insights via https://bridgecrew.cloud"
 }
 ]])
     assert.are.same(2, #result)

     local expected_1 = {
       message = [[
Ensure 'Block Project-wide SSH keys' is enabled for VM instances: CKV_GCP_32
https://docs.bridgecrew.io/docs/bc_gcp_networking_8]],
       lnum = 14,
       col = 0,
       end_lnum = 42,
       end_col = 0,
       severity = vim.diagnostic.severity.WARN,
       source = "checkov: terraform",
     }

     assert.are.same(expected_1, result[1])

     local expected_2 = {
       message = [[
Ensure Compute instances are launched with Shielded VM enabled: CKV_GCP_39
https://docs.bridgecrew.io/docs/bc_gcp_general_y]],
       lnum = 14,
       col = 0,
       end_lnum = 42,
       end_col = 0,
       severity = vim.diagnostic.severity.WARN,
       source = "checkov: terraform",
     }

     assert.are.same(expected_2, result[2])
   end)
 end)
