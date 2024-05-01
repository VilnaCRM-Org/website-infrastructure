import os
import subprocess
import glob
import json

region = os.environ['AWS_REGION']
account_id = os.environ['ACCOUNT_ID']
build_id = os.environ['CODEBUILD_BUILD_ID']
git_repository_last_commit_sha = os.environ['WEBSITE_GIT_REPOSITORY_LAST_COMMIT_SHA']
git_repository_link = os.environ['WEBSITE_GIT_REPOSITORY_LINK']
git_author = os.environ['WEBSITE_GIT_REPOSITORY_LAST_COMMIT_AUTHOR']
git_name = os.environ['WEBSITE_GIT_REPOSITORY_LAST_COMMIT_NAME']

if "LHCI_REPORTS_BUCKET" in os.environ:
    lhci_reports_bucket_name = os.environ['LHCI_REPORTS_BUCKET']

if "TEST_REPORTS_BUCKET" in os.environ:
    test_reports_bucket_name = os.environ['TEST_REPORTS_BUCKET']

build_name = build_id.split(':')[0]

codebuild_link = f"https://{region}.console.aws.amazon.com/codesuite/codebuild/{account_id}/projects/{build_name}/build/{build_id}?region={region}"
git_commit_link = f"{git_repository_link}/commit/{git_repository_last_commit_sha}"

reports = []

if "LHCI_DESKTOP_RUN" in os.environ:
    directory="/root/website/lhci-reports-desktop"
    lhci_desktop_run_name="Lighthouse Desktop"
    
    html_files = glob.glob(directory + "/*.html")
    html_file_names = [file.split("/")[-1] for file in html_files]
    
    lhci_desktop_run_links = []
    for file in html_file_names:
        temp_link = f"http://{lhci_reports_bucket_name}.s3-website.{region}.amazonaws.com/{build_id}/lhci-reports-desktop/{file}"
        lhci_desktop_run_links.append(temp_link)
    
    reports.append({"name": lhci_desktop_run_name, "links": lhci_desktop_run_links})
    
    subprocess.run(['aws', 's3', 'cp', '/root/website/lhci-reports-desktop/.', f's3://{lhci_reports_bucket_name}/{build_id}/lhci-reports-desktop', '--recursive'])

if "LHCI_MOBILE_RUN" in os.environ:
    directory = "/root/website/lhci-reports-mobile"
    lhci_mobile_run_name="Lighthouse Mobile"
    
    html_files = glob.glob(directory + "/*.html")
    html_file_names = [file.split("/")[-1] for file in html_files]
    
    lhci_mobile_run_links = []
    for file in html_file_names:
        temp_link = f"http://{lhci_reports_bucket_name}.s3-website.{region}.amazonaws.com/{build_id}/lhci-reports-mobile/{file}"
        lhci_mobile_run_links.append(temp_link)
    
    reports.append({"name": lhci_mobile_run_name, "links": lhci_mobile_run_links})
    
    subprocess.run(['aws', 's3', 'cp', '/root/website/lhci-reports-mobile/.', f's3://{lhci_reports_bucket_name}/{build_id}/lhci-reports-mobile', '--recursive'])


if "PW_E2E_RUN" in os.environ:
    pw_e2e_run_name="Playwright E2E"
    pw_e2e_run_link=f"http://{test_reports_bucket_name}.s3-website.{region}.amazonaws.com/{build_id}/playwright-e2e-reports"
    
    reports.append({"name": pw_e2e_run_name, "links": [pw_e2e_run_link]})
    
    subprocess.run(['aws', 's3', 'cp', '/root/website/playwright-e2e-reports/.', f's3://{test_reports_bucket_name}/{build_id}/playwright-e2e-reports', '--recursive'])

if "PW_VISUAL_RUN" in os.environ:
    pw_visual_run_name = "Playwright Visual"
    pw_visual_run_link = f"http://{test_reports_bucket_name}.s3-website.{region}.amazonaws.com/{build_id}/playwright-visual-reports"
    
    reports.append({"name": pw_visual_run_name, "links": [pw_visual_run_link]})
    
    subprocess.run(['aws', 's3', 'cp', '/root/website/playwright-e2e-reports/.', f's3://{test_reports_bucket_name}/{build_id}/playwright-e2e-reports', '--recursive'])

if "MUTATION_RUN" in os.environ:
    mutation_run_name = "Mutation Test"
    mutation_run_link = f"http://{test_reports_bucket_name}.s3-website.{region}.amazonaws.com/{build_id}/mutation"

    reports.append({"name": mutation_run_name, "links": [mutation_run_link]})
    
    subprocess.run(['aws', 's3', 'cp', '/root/website/reports/mutation/.', f's3://{test_reports_bucket_name}/{build_id}/mutation', '--recursive'])

if "UNIT_RUN" in os.environ:
    unit_run_name = "Unit Test"
    unit_run_link = f"http://{test_reports_bucket_name}.s3-website.{region}.amazonaws.com/{build_id}/unit"

    reports.append({"name": unit_run_name, "links": [unit_run_link]})
    
    subprocess.run(['aws', 's3', 'cp', '/root/website/coverage/lcov-report/.', f's3://{test_reports_bucket_name}/{build_id}/unit', '--recursive'])

data = {
    "codebuild_link" : codebuild_link,
    "github" : {
        "gh_link" : git_commit_link,
        "sha" : git_repository_last_commit_sha,
        "author" : git_author,
        "name" : git_name
    },
    "reports" : reports
}

json_string = json.dumps(data)

open('payload.json', 'w').write(json_string)