import requests
from bs4 import BeautifulSoup
import re
from semantic_version import Version
from pathlib import Path
import hashlib
from datetime import datetime
import subprocess
import os

def single(iterable):
    result = next(iterable)

    try:
        next(iterable)
        raise Exception('single() found more than one match')
    except StopIteration:
        return result


def get_soup(url):
    print(f'Requesting {url}')
    with requests.get(url) as resp:
        resp.raise_for_status()
        return BeautifulSoup(resp.content, 'lxml')


def find_href(soup, regex):
    matches = (re.match(regex, x.get('href') or '') for x in soup.find_all('a'))
    return single((x for x in matches if x))


def hash_file_from_url(url):
    print('Hashing', url)
    with requests.get(url) as resp:
        hasher = hashlib.sha512(resp.content)
        digest = hasher.hexdigest().upper()
        print('Hash calculated as', digest)
        return digest


bs = get_soup('https://www.videohelp.com/software/Icaros')

base_path = Path(__file__).resolve().parent


def update_package(release_kind, match, latest_version):
    print('Checking Icaros', release_kind)
    release_path = base_path / release_kind
    nuspec_path = release_path / 'icaros.nuspec'

    print('Reading nuspec file', str(nuspec_path))
    with nuspec_path.open('rb') as f:
        spec = BeautifulSoup(f.read(), 'lxml-xml')

    curr_version = Version(spec.version.text)

    if latest_version > curr_version:
        print(latest_version, 'newer than', curr_version)

        spec.version.string.replace_with(str(latest_version))
        spec.copyright.string.replace_with(re.sub(r'\d{4}$', str(datetime.now().year), spec.copyright.text))

        pattern = f'.*/{re.escape(match["filename"])}.*'
        dl_url = single(x['href'] for x in get_soup(match[0]).find_all('a') if re.match(pattern, x.get('href') or ''))
        sha512 = hash_file_from_url(dl_url)

        install_script_path = release_path / 'tools' / 'chocolateyInstall.ps1'

        print('Reading install script', str(install_script_path))
        with install_script_path.open('r') as f:
            install_script = f.read()

        install_script = re.sub(r"(\$version = ')[^']*(')", rf'\g<1>{match["version"]}\g<2>', install_script)
        install_script = re.sub(r"(\$sha512 = ')[^']*(')", rf'\g<1>{sha512}\g<2>', install_script)

        print('Writing nuspec file', str(nuspec_path))
        with nuspec_path.open('wb') as f:
            f.write(spec.prettify('utf8'))

        print('Writing install script', str(install_script_path))
        with install_script_path.open('w') as f:
            f.write(install_script)

        print('Creating nupkg')
        subprocess.check_call(['choco', 'pack'], cwd=release_path)

        print('Publishing nupkg')
        subprocess.check_call(['choco', 'push', f'icaros.{str(latest_version)}.nupkg'], cwd=release_path)

        print('Icaros', release_kind, 'updated')
    else:
        print(latest_version, 'not newer than', curr_version)
        print('Icaros', release_kind, 'unchanged')


stable_match = find_href(bs, r'.*/(?P<filename>Icaros_v(?P<version>(?:\d+)(?:\.\d+)*)\.exe)$')
stable_version = Version(stable_match['version'])
update_package('stable', stable_match, stable_version)

try:
    beta_match = find_href(
        bs, r'.*/(?P<filename>Icaros_v(?P<version>(?P<version_number>(?:\d+)(?:\.\d+)*)(?:_b(?P<beta>\d+)))\.exe)$')
except StopIteration:
    beta_match = None

if beta_match is not None:
    beta_version = Version(f'{beta_match["version_number"]}-beta{beta_match["beta"]}')
    update_package('beta', beta_match, beta_version)
