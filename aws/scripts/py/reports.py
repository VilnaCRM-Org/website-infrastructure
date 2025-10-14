import os
import subprocess
import glob
import json


def get_environment_variables():
    return {
        "region": os.environ["AWS_REGION"],
        "account_id": os.environ["ACCOUNT_ID"],
        "build_id": os.environ["CODEBUILD_BUILD_ID"],
        "git_repository_last_commit_sha": os.environ[
            "WEBSITE_GIT_REPOSITORY_LAST_COMMIT_SHA"
        ],
        "git_repository_link": os.environ["WEBSITE_GIT_REPOSITORY_LINK"],
        "git_author": os.environ["WEBSITE_GIT_REPOSITORY_LAST_COMMIT_AUTHOR"],
        "git_name": os.environ["WEBSITE_GIT_REPOSITORY_LAST_COMMIT_NAME"],
        "lhci_reports_bucket_name": os.environ.get("LHCI_REPORTS_BUCKET"),
        "test_reports_bucket_name": os.environ.get("TEST_REPORTS_BUCKET"),
        "build_succeeding": os.environ["CODEBUILD_BUILD_SUCCEEDING"],
    }


def get_html_files(directory):
    html_files = glob.glob(directory + "/*.html")
    return [file.split("/")[-1] for file in html_files]


def generate_codebuild_link(region, account_id, build_id):
    build_name = build_id.split(":")[0]
    return (
        f"https://{region}.console.aws.amazon.com/codesuite/codebuild/"
        f"{account_id}/projects/{build_name}/build/{build_id}?region={region}"
    )


def generate_git_commit_link(git_repository_link, git_repository_last_commit_sha):
    return f"{git_repository_link}/commit/{git_repository_last_commit_sha}"


def generate_report(name, links):
    return {"name": name, "links": links}


def does_reports_exists(path):
    return os.path.exists(path)


def generate_report_link(bucket_name, region, build_id, directory, file="."):
    return (
        f"http://{bucket_name}.s3-website.{region}.amazonaws.com/"
        f"{build_id}/{directory}/{file}"
    )


def create_lhci_reports_links(reports_path, bucket_name, region, build_id, reports_dir):
    html_files = get_html_files(reports_path)

    links = []

    for file in html_files:
        links.append(
            generate_report_link(bucket_name, region, build_id, reports_dir, file)
        )

    return links


def copy_to_s3(source_dir, bucket_name, build_id, destination_dir):
    subprocess.run(
        [
            "aws",
            "s3",
            "cp",
            f"{source_dir}/.",
            f"s3://{bucket_name}/{build_id}/{destination_dir}",
            "--recursive",
        ]
    )


def run_handler(
    run, test_name, reports_path, region, bucket_name, build_id, reports_dir
):
    match run:
        case "LHCI_DESKTOP_RUN" | "LHCI_MOBILE_RUN":
            copy_to_s3(reports_path, bucket_name, build_id, reports_dir)
            return (
                test_name,
                generate_report(
                    test_name.rsplit(" ", 1)[0],
                    create_lhci_reports_links(
                        reports_path, bucket_name, region, build_id, reports_dir
                    ),
                ),
            )
        case "LINT_RUN" | "MEMORY_RUN":
            return test_name, ""
        case "MUTATION_RUN":
            copy_to_s3(reports_path, bucket_name, build_id, reports_dir)
            return (
                test_name,
                generate_report(
                    test_name.rsplit(" ", 1)[0],
                    [
                        generate_report_link(
                            bucket_name, region, build_id, reports_dir, "mutation.html"
                        )
                    ],
                ),
            )
        case _:
            copy_to_s3(reports_path, bucket_name, build_id, reports_dir)
            return (
                test_name,
                generate_report(
                    test_name.rsplit(" ", 1)[0],
                    [generate_report_link(bucket_name, region, build_id, reports_dir)],
                ),
            )


def process_test(run, config, repository_dir, region, build_id):
    test_name = config[0]
    reports_dir = config[1]
    bucket_name = config[2]

    if not does_reports_exists(f"{repository_dir}/{reports_dir}"):
        return test_name, ""

    return run_handler(
        run,
        test_name,
        f"{repository_dir}/{reports_dir}",
        region,
        bucket_name,
        build_id,
        reports_dir,
    )


def compile_data(
    build_succeeding, codebuild_link, git_info, tests, reports, project_name
):
    data = {
        "build_succeeding": build_succeeding,
        "codebuild_link": codebuild_link,
        "github": git_info,
        "tests": tests,
        "project_name": project_name,
    }

    if len(reports) != 0 and reports[0] != "":
        data["reports"] = reports

    return data


def write_to_file(data):
    try:
        json_string = json.dumps(data)
        with open("payload.json", "w") as file:
            file.write(json_string)
    except (IOError, json.JSONEncodeError) as e:
        raise RuntimeError(f"Failed to write payload file: {e}")


def main():
    env_variables = get_environment_variables()

    git_info = {
        "gh_link": generate_git_commit_link(
            env_variables["git_repository_link"],
            env_variables["git_repository_last_commit_sha"],
        ),
        "sha": env_variables["git_repository_last_commit_sha"],
        "author": env_variables["git_author"],
        "name": env_variables["git_name"],
    }

    tests = []
    reports = []

    repository_dir = os.path.join(os.environ["CODEBUILD_SRC_DIR"], "website")

    test_configs = {
        "LHCI_DESKTOP_RUN": (
            "Lighthouse Desktop Test",
            "lhci-reports-desktop",
            env_variables["lhci_reports_bucket_name"],
        ),
        "LHCI_MOBILE_RUN": (
            "Lighthouse Mobile Test",
            "lhci-reports-mobile",
            env_variables["lhci_reports_bucket_name"],
        ),
        "PW_E2E_RUN": (
            "Playwright E2E Test",
            "playwright-e2e-reports",
            env_variables["test_reports_bucket_name"],
        ),
        "PW_VISUAL_RUN": (
            "Playwright Visual Test",
            "playwright-visual-reports",
            env_variables["test_reports_bucket_name"],
        ),
        "MUTATION_RUN": (
            "Mutation Test",
            "reports/mutation",
            env_variables["test_reports_bucket_name"],
        ),
        "UNIT_RUN": (
            "Unit Test",
            "coverage/lcov-report",
            env_variables["test_reports_bucket_name"],
        ),
        "LOAD_RUN": (
            "Load Test",
            "src/test/load/results",
            env_variables["test_reports_bucket_name"],
        ),
        "MEMORY_LEAK_RUN": ("Memory Leak Test", "", ""),
        "LINT_RUN": ("Lint Test", "", ""),
    }

    for key, config in test_configs.items():
        if key in os.environ:
            test_result, report = process_test(
                key,
                config,
                repository_dir,
                env_variables["region"],
                env_variables["build_id"],
            )
            tests.append(test_result)
            reports.append(report)

    # Extract project name from build ID (format: "project-name:build-uuid")
    project_name = env_variables["build_id"].split(":")[0]

    data = compile_data(
        env_variables["build_succeeding"],
        generate_codebuild_link(
            env_variables["region"],
            env_variables["account_id"],
            env_variables["build_id"],
        ),
        git_info,
        tests,
        reports,
        project_name,
    )

    write_to_file(data)


if __name__ == "__main__":
    main()
