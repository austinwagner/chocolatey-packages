import requests
from bs4 import BeautifulSoup
import re
from semantic_version import Version
from pathlib import Path
import hashlib
from datetime import datetime
import typing as t
import subprocess


ReleaseKind = t.Literal["stable", "beta"]
T = t.TypeVar("T")

PACKAGE_REPO = "https://push.chocolatey.org/"


def single(iterable: t.Iterator[T]) -> T:
    result = next(iterable)

    try:
        next(iterable)
        raise Exception("single() found more than one match")
    except StopIteration:
        return result


def get_soup(url: str) -> BeautifulSoup:
    print(f"Requesting {url}")
    with requests.get(url) as resp:
        resp.raise_for_status()
        return BeautifulSoup(resp.content, "lxml")


def find_href(soup: BeautifulSoup, regex: str) -> re.Match:
    matches = (re.match(regex, x.get("href") or "") for x in soup.find_all("a"))
    return single((x for x in matches if x))


def hash_file_from_url(url: str) -> str:
    print("Hashing", url)
    with requests.get(url) as resp:
        hasher = hashlib.sha512(resp.content)
        digest = hasher.hexdigest().upper()
        print("Hash calculated as", digest)
        return digest


def split_by_regex(regex, text) -> list[tuple[re.Match, str]]:
    matches = [x for x in re.finditer(regex, text)]
    parts = []
    last_pos = 0
    last_match = None

    for match in matches:
        pos = match.start()
        if last_match is not None:
            parts.append((last_match, text[last_pos:pos]))
        last_pos = pos
        last_match = match

    if last_match is not None:
        parts.append((last_match, text[last_pos:]))

    return parts


def find_release_notes(
    soup: BeautifulSoup, version: Version, release_kind: ReleaseKind
) -> str:
    version = version.truncate("minor")
    changelog = (
        soup.find(id="changelog").find_next_sibling("div", class_="row0").text.strip()
    )

    def kind_matches(kind: str) -> bool:
        if release_kind == "stable":
            return "final" in kind.lower()
        elif release_kind == "beta":
            return "beta" in kind.lower()
        else:
            return False

    release_notes = ""
    for match, section in split_by_regex(
        r".*Icaros v\.(?P<version>[\w\.]+)\s+(?P<kind>[\w ]+)", changelog
    ):
        if Version(match["version"]).truncate("minor") == version and kind_matches(
            match["kind"]
        ):
            release_notes += section.strip() + "\n\n"

    return release_notes.strip()


def prompt_yn(question: str, default: t.Union[None, t.Literal["y", "n"]]) -> bool:
    choices = "y/n" if default is None else "Y/n" if default == "y" else "y/N"
    while True:
        choice = input(f"{question} ({choices}) ").strip().lower() or default
        if choice in ("y", "yes", "n", "no"):
            return choice.startswith("y")
        print("Enter y or n")


bs = get_soup("https://www.videohelp.com/software/Icaros")

base_path = Path(__file__).resolve().parent


def update_package(release_kind: ReleaseKind, match: re.Match, latest_version: Version):
    print("Checking Icaros", release_kind)
    release_path = base_path / release_kind
    nuspec_path = release_path / "icaros.nuspec"
    nupkg_name = f"icaros.{str(latest_version)}.nupkg"

    bs_hist = get_soup("https://www.videohelp.com/software/Icaros/version-history")

    print("Reading nuspec file", str(nuspec_path))
    with nuspec_path.open("rb") as f:
        spec = BeautifulSoup(f.read(), "lxml-xml")

    curr_version = Version(spec.version.text)

    if latest_version > curr_version:
        print(latest_version, "newer than", curr_version)

        notes = find_release_notes(bs_hist, latest_version, release_kind)

        spec.version.string.replace_with(str(latest_version))
        spec.copyright.string.replace_with(
            re.sub(r"\d{4}$", str(datetime.now().year), spec.copyright.text)
        )
        spec.releaseNotes.string.replace_with(notes)

        pattern = f'.*/{re.escape(match["filename"])}.*'
        dl_url = single(
            x["href"]
            for x in get_soup(match[0]).find_all("a")
            if re.match(pattern, x.get("href") or "")
        )
        sha512 = hash_file_from_url(dl_url)

        install_script_path = release_path / "tools" / "chocolateyInstall.ps1"

        print("Reading install script", str(install_script_path))
        with install_script_path.open("r") as f:
            install_script = f.read()

        install_script = re.sub(
            r"(\$version = ')[^']*(')", rf'\g<1>{match["version"]}\g<2>', install_script
        )
        install_script = re.sub(
            r"(\$sha512 = ')[^']*(')", rf"\g<1>{sha512}\g<2>", install_script
        )

        print("Writing nuspec file", str(nuspec_path))
        spec_str = spec.prettify()
        with nuspec_path.open("wb") as f:
            f.write(spec_str.encode("utf-8"))

        print("Writing install script", str(install_script_path))
        with install_script_path.open("w") as f:
            f.write(install_script)

        print()
        print("-------------------")
        print(f"Contents of nuspec")
        print("-------------------")
        print(spec_str)
        print("-------------------")
        print("End of nuspec")
        print("-------------------")
        print()

        if not prompt_yn("Publish with this nuspec?", "n"):
            print(
                f"Fix the nuspec file manually then run 'choco pack' and 'choco push {nupkg_name} --source {PACKAGE_REPO}'"
            )
            return

        print("Creating nupkg")
        subprocess.check_call(["choco", "pack"], cwd=release_path)

        print("Publishing nupkg")
        subprocess.check_call(
            ["choco", "push", nupkg_name, "--source", PACKAGE_REPO], cwd=release_path
        )

        print("Icaros", release_kind, "updated")
    else:
        print(latest_version, "not newer than", curr_version)
        print("Icaros", release_kind, "unchanged")


stable_match = find_href(
    bs, r".*/(?P<filename>Icaros_v(?P<version>(?:\d+)(?:\.\d+)*)\.exe)$"
)
stable_version = Version(stable_match["version"])
update_package("stable", stable_match, stable_version)

try:
    beta_match = find_href(
        bs,
        r".*/(?P<filename>Icaros_v(?P<version>(?P<version_number>(?:\d+)(?:\.\d+)*)(?:_b(?P<beta>\d+)))\.exe)$",
    )
except StopIteration:
    beta_match = None

if beta_match is not None:
    beta_version = Version(f'{beta_match["version_number"]}-beta{beta_match["beta"]}')
    update_package("beta", beta_match, beta_version)
