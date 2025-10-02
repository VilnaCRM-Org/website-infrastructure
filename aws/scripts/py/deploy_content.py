import json
import subprocess
import os

CLOUDFRONT_REGION = os.environ["CLOUDFRONT_REGION"]


def get_bucket():
    print("Getting bucket...")
    return os.environ["BUCKET_NAME"]


def fetch_distributions():
    print("Fetching CloudFront distributions...")
    result = subprocess.check_output(
        [
            "aws",
            "cloudfront",
            "list-distributions",
            "--region",
            CLOUDFRONT_REGION,
            "--no-cli-pager",
        ]
    )
    distributions = json.loads(result.decode())
    print(f"Fetched distributions: {distributions}")
    return distributions


def get_staging_distribution(distributions):
    print("Finding staging distribution...")
    for item in distributions["DistributionList"]["Items"]:
        if item["Staging"]:
            print(f"Staging distribution found: {item}")
            return item


def get_origins(distribution):
    print("Fetching origins...")
    return distribution["Origins"]["Items"]


def check_origins(origins):
    print("Checking origins...")
    if origins[0]["DomainName"].startswith("staging"):
        print("Origins belong to staging environment.")
        return True
    print("Origins belong to production environment.")
    return False


def deploy_files(target_bucket):
    print(f"Deploying files to target bucket: {target_bucket}")
    try:
        result = subprocess.check_output(
            ["aws", "s3", "sync", "./out", f"s3://{target_bucket}"]
        )
        print(f"Successfully deployed to bucket: {target_bucket}")
        return result
    except subprocess.CalledProcessError as e:
        print(f"Error deploying to bucket {target_bucket}: {e}")
        raise


def find_project_distributions(bucket_name):
    """
    Find the specific distributions for this project based on bucket name.
    Filters out distributions from other projects like app.vilnacrm.com.
    """
    print(f"Finding distributions for project with bucket: {bucket_name}")
    
    cloudfront_distributions = fetch_distributions()
    project_distributions = {
        "production": None,
        "staging": None
    }
    
    for dist in cloudfront_distributions["DistributionList"]["Items"]:
        aliases = dist.get("Aliases", {}).get("Items", [])
        origins = dist.get("Origins", {}).get("Items", [])
        
        # Check if this distribution belongs to our project
        is_our_project = False
        
        # Method 1: Check if any alias matches our domain exactly
        domain_from_bucket = bucket_name  # e.g., "vilnacrm.com"
        for alias in aliases:
            if alias == domain_from_bucket or alias == f"www.{domain_from_bucket}":
                is_our_project = True
                print(f"Distribution {dist['Id']} matches domain: {alias}")
                break
        
        # Method 2: Check if origins point to our specific buckets
        if not is_our_project:
            for origin in origins:
                origin_domain = origin.get("DomainName", "")
                if (f"{bucket_name}.s3." in origin_domain or 
                    f"staging.{bucket_name}.s3." in origin_domain):
                    is_our_project = True
                    print(f"Distribution {dist['Id']} matches origin: {origin_domain}")
                    break
        
        if not is_our_project:
            print(f"Skipping distribution {dist['Id']} - not for project {bucket_name}")
            continue
            
        # Determine if this is production or staging distribution
        if dist.get("Staging", False):
            project_distributions["staging"] = dist
            print(f"Found staging distribution: {dist['Id']}")
        elif aliases:  # Production has aliases (domain names)
            project_distributions["production"] = dist
            print(f"Found production distribution: {dist['Id']}")
    
    return project_distributions

def determine_deployment_target(bucket_name):
    """
    Determine which bucket to deploy to based on current production setup.
    Deploy to the environment that is NOT currently serving production traffic.
    Only considers distributions for this specific project.
    """
    print("Determining deployment target for blue-green deployment...")
    
    project_distributions = find_project_distributions(bucket_name)
    
    production_distribution = project_distributions["production"]
    staging_distribution = project_distributions["staging"]
    
    if not production_distribution:
        print(f"ERROR: Could not find production distribution for {bucket_name}")
        print("This might happen if:")
        print("1. The distribution aliases don't match the bucket name")
        print("2. The distribution origins don't point to the expected buckets")
        print("3. Multiple projects exist and filtering failed")
        raise ValueError(f"No production distribution found for {bucket_name}")
    
    if not staging_distribution:
        print(f"WARNING: Could not find staging distribution for {bucket_name}")
        print("Defaulting to staging bucket")
        return f"staging.{bucket_name}"
    
    # Check which bucket production is currently pointing to
    origins = production_distribution["Origins"]["Items"]
    current_prod_origin = origins[0]["DomainName"]
    
    print(f"Production distribution {production_distribution['Id']} points to: {current_prod_origin}")
    
    if "staging." in current_prod_origin:
        # Production is on Green (staging bucket), deploy to Blue (main bucket)
        target_bucket = bucket_name
        environment = "Blue"
        print("Production is currently on Green, deploying to Blue")
    else:
        # Production is on Blue (main bucket), deploy to Green (staging bucket)
        target_bucket = f"staging.{bucket_name}"
        environment = "Green"
        print("Production is currently on Blue, deploying to Green")
    
    print(f"Deploying to {environment} environment: {target_bucket}")
    return target_bucket


def main():
    print("Starting blue-green deployment...")
    bucket_name = get_bucket()
    print(f"Base bucket name: {bucket_name}")

    # Determine which environment to deploy to (the non-production one)
    target_bucket = determine_deployment_target(bucket_name)

    # Deploy to the target environment only
    deploy_files(target_bucket)
    print(f"Blue-green deployment completed. New version deployed to: {target_bucket}")
    print("Use the release pipeline to promote this version to production.")

    print("Main function completed.")


if __name__ == "__main__":
    main()
