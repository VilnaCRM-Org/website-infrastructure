"""Fail promotion when a localized route serves the root fallback or an error."""

import argparse
import json
import os
from html.parser import HTMLParser
from urllib.request import Request, urlopen


class Page(HTMLParser):
    def __init__(self):
        super().__init__()
        self.lang = None
        self.next_data = ""
        self.in_next_data = False

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "html":
            self.lang = attrs.get("lang")
        if tag == "script" and attrs.get("id") == "__NEXT_DATA__":
            self.in_next_data = True

    def handle_data(self, data):
        if self.in_next_data:
            self.next_data += data

    def handle_endtag(self, tag):
        if tag == "script":
            self.in_next_data = False


def check(url, headers, locale, route):
    with urlopen(Request(url, headers=headers), timeout=30) as response:
        if response.status != 200:
            raise RuntimeError(f"{url}: expected HTTP 200, got {response.status}")
        page = Page()
        page.feed(response.read().decode("utf-8"))
    actual_route = json.loads(page.next_data).get("page")
    if page.lang != locale or actual_route != route:
        raise RuntimeError(
            f"{url}: expected {locale}/{route}, got {page.lang}/{actual_route}"
        )
    print(f"PASS {url}: HTTP 200, lang={locale}, page={route}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--url", required=True)
    parser.add_argument("--staging", action="store_true")
    args = parser.parse_args()
    headers = {"User-Agent": "vilnacrm-route-healthcheck/1.0"}
    if args.staging:
        header = os.environ.get("CLOUDFRONT_HEADER", "staging")
        headers[f"aws-cf-cd-{header}"] = header
    for path, locale, route in [("/", "uk", "/"), ("/en", "en", "/en"), ("/en/", "en", "/en")]:
        check(args.url.rstrip("/") + path, headers, locale, route)


if __name__ == "__main__":
    main()
