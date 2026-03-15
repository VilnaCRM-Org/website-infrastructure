#!/usr/bin/env python3
import argparse
import re
import socket
import ssl
import time
import urllib.request
from urllib.parse import urlparse


def parse_name(entries):
    values = {}
    for entry in entries:
        for key, value in entry:
            values[key] = value
    return values


def fetch_response(url, timeout):
    parsed_url = urlparse(url)
    if parsed_url.scheme not in {"http", "https"}:
        raise ValueError("URL scheme must be http or https")

    request = urllib.request.Request(
        url,
        headers={"User-Agent": "vilnacrm-healthcheck/1.0"},
    )
    context = ssl.create_default_context() if parsed_url.scheme == "https" else None
    with urllib.request.urlopen(request, timeout=timeout, context=context) as response:
        body = response.read().decode("utf-8", errors="replace")
        return response.status, response.headers, body


def fetch_certificate(hostname, port, timeout):
    context = ssl.create_default_context()
    with socket.create_connection((hostname, port), timeout=timeout) as sock:
        with context.wrap_socket(sock, server_hostname=hostname) as tls_sock:
            return tls_sock.getpeercert()


def assert_equal(actual, expected, label):
    if actual != expected:
        raise AssertionError(f"{label}: expected {expected!r}, got {actual!r}")


def assert_regex(value, pattern, label):
    if not re.fullmatch(pattern, value or ""):
        raise AssertionError(f"{label}: value {value!r} does not match {pattern!r}")


def main():
    parser = argparse.ArgumentParser(description="Lightweight HTTP(S) healthcheck")
    parser.add_argument("--url", required=True)
    parser.add_argument("--timeout", type=int, default=30)
    parser.add_argument("--expect-body")
    parser.add_argument("--require-content-type", action="store_true")
    parser.add_argument("--expect-cn")
    parser.add_argument("--expect-issuer-country")
    parser.add_argument("--expect-issuer-org")
    parser.add_argument("--expect-issuer-cn-regex")
    parser.add_argument("--min-cert-days", type=int)
    args = parser.parse_args()

    print(f"Checking {args.url}")
    status, headers, body = fetch_response(args.url, args.timeout)
    assert_equal(status, 200, "HTTP status")
    print("HTTP 200")

    if args.require_content_type and not headers.get("Content-Type"):
        raise AssertionError("Content-Type header is missing")
    if args.require_content_type:
        print(f"Content-Type: {headers['Content-Type']}")

    if args.expect_body:
        if args.expect_body not in body:
            raise AssertionError(f"Response body does not contain {args.expect_body!r}")
        print(f"Body contains {args.expect_body!r}")

    if any(
        [
            args.expect_cn,
            args.expect_issuer_country,
            args.expect_issuer_org,
            args.expect_issuer_cn_regex,
            args.min_cert_days is not None,
        ]
    ):
        parsed = urlparse(args.url)
        if parsed.scheme != "https":
            raise AssertionError("Certificate assertions require an https URL")

        certificate = fetch_certificate(
            parsed.hostname,
            parsed.port or 443,
            args.timeout,
        )
        subject = parse_name(certificate.get("subject", ()))
        issuer = parse_name(certificate.get("issuer", ()))

        if args.expect_cn:
            assert_equal(subject.get("commonName"), args.expect_cn, "Certificate CN")
            print(f"Certificate CN: {subject['commonName']}")

        if args.expect_issuer_country:
            assert_equal(
                issuer.get("countryName"),
                args.expect_issuer_country,
                "Issuer country",
            )

        if args.expect_issuer_org:
            assert_equal(
                issuer.get("organizationName"),
                args.expect_issuer_org,
                "Issuer organization",
            )

        if args.expect_issuer_cn_regex:
            assert_regex(
                issuer.get("commonName"),
                args.expect_issuer_cn_regex,
                "Issuer common name",
            )
            print(f"Issuer CN: {issuer['commonName']}")

        if args.min_cert_days is not None:
            seconds_until_expiry = (
                ssl.cert_time_to_seconds(certificate["notAfter"]) - time.time()
            )
            days_until_expiry = seconds_until_expiry / 86400
            if days_until_expiry <= args.min_cert_days:
                raise AssertionError(
                    f"Certificate expires too soon: {days_until_expiry:.2f} days left",
                )
            print(f"Certificate expires in {days_until_expiry:.2f} days")

        serial_number = certificate.get("serialNumber", "")
        assert_regex(serial_number, r"[0-9A-F]+", "Certificate serial number")
        print(f"Certificate serial: {serial_number}")


if __name__ == "__main__":
    main()
