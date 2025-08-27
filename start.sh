dname=$(dirname $(realpath $0))
"${dname}/.venv/bin/python" -Ic "from astral_body.cli import cli; cli()"
