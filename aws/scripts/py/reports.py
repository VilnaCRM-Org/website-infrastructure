import os
import subprocess
import glob
import json

def get_environment_variables():
    return {
        "region": os.environ['AWS_REGION'],
        "account_id": os.environ['ACCOUNT_ID'],
        "build_id": os.environ['CODEBUILD_BUILD_ID'],
        "git_repository_last_commit_sha": os.environ['WEBSITE_GIT_REPOSITORY_LAST_COMMIT_SHA'],
        "git_repository_link": os.environ['WEBSITE_GIT_REPOSITORY_LINK'],
        "git_author": os.environ['WEBSITE_GIT_REPOSITORY_LAST_COMMIT_AUTHOR'],
        "git_name": os.environ['WEBSITE_GIT_REPOSITORY_LAST_COMMIT_NAME'],
        "lhci_reports_bucket_name": os.environ.get('LHCI_REPORTS_BUCKET'),
        "test_reports_bucket_name": os.environ.get('TEST_REPORTS_BUCKET'),
        "build_succeeding": os.environ['CODEBUILD_BUILD_SUCCEEDING']
    }

def get_html_files(directory):
    html_files = glob.glob(directory + "/*.html")
    return [file.split("/")[-1] for file in html_files]

def generate_codebuild_link(region, account_id, build_id):
    build_name = build_id.split(':')[0]
    return f"https://{region}.console.aws.amazon.com/codesuite/codebuild/{account_id}/projects/{build_name}/build/{build_id}?region={region}"

def generate_git_commit_link(git_repository_link, git_repository_last_commit_sha):
    return f"{git_repository_link}/commit/{git_repository_last_commit_sha}"

def generate_report(name, links):
    return {"name": name, "links": links}

def generate_report_link(bucket_name, region, build_id, directory, file='.'):
    return f"http://{bucket_name}.s3-website.{region}.amazonaws.com/{build_id}/{directory}/{file}"

def copy_to_s3(source_dir, bucket_name, build_id, destination_dir):
    subprocess.run(['aws', 's3', 'cp', f'{source_dir}/.', f's3://{bucket_name}/{build_id}/{destination_dir}', '--recursive'])


def main():
    env_variables = get_environment_variables()

    region = env_variables["region"]
    account_id = env_variables["account_id"]
    build_id = env_variables["build_id"]
    git_repository_last_commit_sha = env_variables["git_repository_last_commit_sha"]
    git_repository_link = env_variables["git_repository_link"]
    lhci_reports_bucket_name = env_variables["lhci_reports_bucket_name"]
    test_reports_bucket_name = env_variables["test_reports_bucket_name"]
    build_succeeding = env_variables["build_succeeding"]

    codebuild_link = generate_codebuild_link(region, account_id, build_id)
    git_commit_link = generate_git_commit_link(git_repository_link, git_repository_last_commit_sha)

    reports = []
    tests = []

    repository_dir = "/codebuild-user/website"

    if "LHCI_DESKTOP_RUN" in os.environ:
        tests.append("Lighthouse Desktop Test")

        reports_dir = "lhci-reports-desktop"

        html_files = get_html_files(f"{repository_dir}/{reports_dir}")

        links = []

        for file in html_files:
            links.append(generate_report_link(lhci_reports_bucket_name, region, build_id, reports_dir, file))
        
        reports.append(generate_report("Lighthouse Desktop",links))

        copy_to_s3(f"{repository_dir}/{reports_dir}", lhci_reports_bucket_name, build_id, reports_dir)

    if "LHCI_MOBILE_RUN" in os.environ:
        tests.append("Lighthouse Mobile Test"
)
        reports_dir = "lhci-reports-mobile"

        html_files = get_html_files(f"{repository_dir}/{reports_dir}")

        links = []

        for file in html_files:
            links.append(generate_report_link(lhci_reports_bucket_name, region, build_id, reports_dir, file))
        
        reports.append(generate_report("Lighthouse Mobile",links))

        copy_to_s3(f"{repository_dir}/{reports_dir}", lhci_reports_bucket_name, build_id, reports_dir)


    if "PW_E2E_RUN" in os.environ:
        tests.append("Playwright E2E Test")

        reports_dir = "playwright-e2e-reports"

        reports.append(generate_report("Playwright E2E",[ generate_report_link(test_reports_bucket_name, region, build_id, reports_dir) ]))
        
        copy_to_s3(f"{repository_dir}/{reports_dir}", test_reports_bucket_name, build_id, reports_dir)

    if "PW_VISUAL_RUN" in os.environ:
        tests.append("Playwright Visual Test")

        reports_dir = "playwright-visual-reports"

        reports.append(generate_report("Playwright Visual", [ generate_report_link(test_reports_bucket_name, region, build_id, reports_dir) ]))
        
        copy_to_s3(f"{repository_dir}/{reports_dir}", test_reports_bucket_name, build_id, reports_dir)

    if "MUTATION_RUN" in os.environ:
        tests.append("Mutation Test")

        reports_dir = "reports/mutation"

        reports.append(generate_report("Mutation Test",[ generate_report_link(test_reports_bucket_name, region, build_id, reports_dir) ]))
        
        copy_to_s3(f"{repository_dir}/{reports_dir}", test_reports_bucket_name, build_id, reports_dir)

    if "UNIT_RUN" in os.environ:
        tests.append("Unit Test")

        reports_dir = "coverage/lcov-report"

        reports.append(generate_report("Unit Test",[ generate_report_link(test_reports_bucket_name, region, build_id, reports_dir) ]))
        
        copy_to_s3(f"{repository_dir}/{reports_dir}", test_reports_bucket_name, build_id, reports_dir)
    
    if "MEMORY_LEAK_RUN" in os.environ:
        tests.append("Memory Leak Test")

    if "LINT_RUN" in os.environ:
        tests.append("Lint Test")

    data = {
        "build_succeeding" : build_succeeding,
        "codebuild_link": codebuild_link,
        "github": {
            "gh_link": git_commit_link,
            "sha": git_repository_last_commit_sha,
            "author": env_variables["git_author"],
            "name": env_variables["git_name"]
        },
        "tests" : tests
    }

    if len(reports) != 0:
        data["reports"] = reports

    json_string = json.dumps(data)

    open('payload.json', 'w').write(json_string)

if __name__ == "__main__":
    main()